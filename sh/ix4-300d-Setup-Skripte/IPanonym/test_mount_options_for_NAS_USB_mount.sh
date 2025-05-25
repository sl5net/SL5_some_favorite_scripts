#!/bin/bash

# --- Konfiguration ---
MOUNT_UNIT_FILE="/etc/systemd/system/mnt-ix4\\x2d300d-usb.mount"
MOUNT_UNIT_SERVICE_NAME="mnt-ix4\\x2d300d-usb.mount"
AUTOMOUNT_UNIT_SERVICE_NAME="mnt-ix4\\x2d300d-usb.automount"
MOUNT_POINT="/mnt[YourNASMount]/usb"
CREDENTIALS_FILE="/etc/samba/credentials/nas_usb.cred" # Anpassen, falls anders
UID_USER="1000" # Deine Benutzer-ID
GID_USER="1001" # Deine Gruppen-ID
NAS_WORKGROUP="WORKGROUP" # Anpassen, falls bekannt und anders

echo "--- hello from test_mount_options_for_NAS_USB_mount_v3.sh"

# Originaldatei sichern
BACKUP_FILE_PREFIX="${MOUNT_UNIT_FILE}.bak_$(date +%F_%H-%M-%S)"
if [ ! -f "${MOUNT_UNIT_FILE}.original_backup_v3" ]; then
    echo "Erstelle initiales Backup: ${MOUNT_UNIT_FILE}.original_backup_v3"
    sudo cp "$MOUNT_UNIT_FILE" "${MOUNT_UNIT_FILE}.original_backup_v3"
fi

# --- Zu testende Options-Kombinationen ---

# 1. Absolut minimaler Test
MINIMAL_OPTIONS="credentials=${CREDENTIALS_FILE},vers=1.0"

# 2. Basis-Optionen für weitere Tests (gute Standardwerte)
STANDARD_BASE_OPTIONS="credentials=${CREDENTIALS_FILE},uid=${UID_USER},gid=${GID_USER},iocharset=utf8,vers=1.0,nofail"

# 3. Zusätzliche Optionen, die an STANDARD_BASE_OPTIONS angehängt werden
ADDITIONAL_OPTIONS_SETS=(
    # Fokus auf sec und noserverino (basierend auf Kernel-Log Analyse)
    "sec=ntlmssp"
    "sec=ntlmssp,noserverino"
    "sec=ntlmsspi"
    "sec=ntlmsspi,noserverino"
    "noserverino" # Nur noserverino, mit impliziter sec-Aushandlung
    # Mit domain
    "sec=ntlmssp,domain=${NAS_WORKGROUP}"
    "sec=ntlmssp,noserverino,domain=${NAS_WORKGROUP}"
    "noserverino,domain=${NAS_WORKGROUP}"
    # Weniger wahrscheinliche sec-Optionen
    "sec=ntlmv2"
    "sec=ntlmv2,noserverino"
    "" # Nur die STANDARD_BASE_OPTIONS (hatten wir als error 11, aber zum Vergleich)
)

# --- Hilfsfunktion zum Schreiben der Mount-Unit ---
write_mount_file() {
    local current_options_to_write="$1"
    echo "Schreibe neue Optionen in $MOUNT_UNIT_FILE: $current_options_to_write"
    sudo bash -c "cat > '$MOUNT_UNIT_FILE'" <<EOF
[Unit]
Description=Mount ix4-300d NAS Share to $MOUNT_POINT (Automated Test v3)
Requires=network-online.target
After=network-online.target

[Mount]
What=//[YourNASip]/usb
Where=$MOUNT_POINT
Type=cifs
Options=$current_options_to_write

[Install]
WantedBy=multi-user.target
EOF
}

# --- Hilfsfunktion für einen einzelnen Testdurchlauf ---
run_test_cycle() {
    local options_to_test="$1"
    local test_label="$2"

    echo ""
    echo "===================================================================="
    echo "TEST ($test_label): $options_to_test"
    echo "===================================================================="

    # Aktuelle Konfiguration für diesen Test sichern
    # sudo cp "$MOUNT_UNIT_FILE" "${BACKUP_FILE_PREFIX}_${test_label//\//_}.mount" # Slashes im Label ersetzen

    write_mount_file "$options_to_test"

    echo "Führe systemctl daemon-reload aus..."
    sudo systemctl daemon-reload
    echo "Stoppe und deaktiviere Automount-Unit (für sauberen Start)..."
    sudo systemctl stop "$AUTOMOUNT_UNIT_SERVICE_NAME" >/dev/null 2>&1
    sudo systemctl disable "$AUTOMOUNT_UNIT_SERVICE_NAME" >/dev/null 2>&1
    echo "Aktiviere und starte Automount-Unit neu..."
    sudo systemctl enable "$AUTOMOUNT_UNIT_SERVICE_NAME" >/dev/null 2>&1
    sudo systemctl start "$AUTOMOUNT_UNIT_SERVICE_NAME"

    echo "Warte 10 Sekunden..."
    sleep 10

    echo "Versuche Zugriff auf $MOUNT_POINT..."
    if ls "$MOUNT_POINT" 2>/dev/null | grep -q '.'; then
        echo ""
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "!!!! ERFOLG GEFUNDEN ($test_label) mit Optionen: $options_to_test !!!!"
        echo "!!!! Inhalt von $MOUNT_POINT:"
        ls -la "$MOUNT_POINT"
        echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        echo "Das Skript bricht ab. Funktionierende Konfiguration in $MOUNT_UNIT_FILE."
        return 0 # Erfolg
    else
        echo "FEHLSCHLAG ($test_label) mit Optionen: $options_to_test"
        echo "Status von $MOUNT_UNIT_SERVICE_NAME:"
        sudo systemctl --no-pager -l status "$MOUNT_UNIT_SERVICE_NAME"
        echo "Letzte Einträge im Journal für $MOUNT_UNIT_SERVICE_NAME:"
        sudo journalctl --no-pager -n 20 -u "$MOUNT_UNIT_SERVICE_NAME"
        echo "Letzte relevante Kernel-Log Einträge:"
        sudo journalctl -k --no-pager -n 20 | grep -iE "cifs|smb|[YourNASip]|ix4|usb|status|error|fail|send error|nt_status"
        return 1 # Fehlschlag
    fi
}


# --- Haupt-Testlogik ---
SUCCESS=0
TEST_ID_COUNTER=0

# 1. Minimaler Test
TEST_ID_COUNTER=$((TEST_ID_COUNTER + 1))
if run_test_cycle "$MINIMAL_OPTIONS" "Minimal_${TEST_ID_COUNTER}"; then
    SUCCESS=1
fi

# 2. Erweiterte Tests, wenn minimaler Test fehlschlug
if [ "$SUCCESS" -eq 0 ]; then
    for additional_opts in "${ADDITIONAL_OPTIONS_SETS[@]}"; do
        TEST_ID_COUNTER=$((TEST_ID_COUNTER + 1))
        current_test_options="$STANDARD_BASE_OPTIONS" # Beginne mit der Standardbasis
        if [ -n "$additional_opts" ]; then # Füge zusätzliche Optionen hinzu, wenn vorhanden
            current_test_options="${current_test_options},${additional_opts}"
        fi
        # Entferne ggf. doppelte Kommas oder Kommas am Ende (falls additional_opts leer war und ein Komma zu viel ist)
        current_test_options=$(echo "$current_test_options" | sed 's/,,/,/g' | sed 's/,$//')

        if run_test_cycle "$current_test_options" "Extended_${TEST_ID_COUNTER}"; then
            SUCCESS=1
            break # Bei Erfolg die Schleife verlassen
        fi
    done
fi

# --- Abschlussmeldung ---
echo ""
echo "===================================================================="
if [ "$SUCCESS" -eq 1 ]; then
    echo "Automatischer Test beendet. Funktionierende Konfiguration gefunden."
else
    echo "Automatischer Test beendet. KEINE funktionierende Konfiguration gefunden."
    echo "Stelle ggf. die ursprüngliche Konfiguration wieder her von: ${MOUNT_UNIT_FILE}.original_backup_v3"
    echo "Letzte getestete (nicht funktionierende) Konfiguration ist in $MOUNT_UNIT_FILE."
fi
echo "===================================================================="

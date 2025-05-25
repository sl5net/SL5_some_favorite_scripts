#!/bin/bash

echo "=== Automatisches Setup-Skript für NFS-Mount: /mnt/ix4_share_nfs ==="
echo ""

# ---- Konfiguration für die NEUE Unit ----
NEW_LOCAL_MOUNT_POINT="/mnt/ix4_share_nfs"
NAS_IP="[YourNASip]"
NFS_EXPORT_PATH="/nfs/share"

NEW_MOUNT_UNIT_FILENAME="mnt-ix4_share_nfs.mount"
NEW_AUTOMOUNT_UNIT_FILENAME="mnt-ix4_share_nfs.automount"
NEW_MOUNT_UNIT_FILE_PATH="/etc/systemd/system/${NEW_MOUNT_UNIT_FILENAME}"
NEW_AUTOMOUNT_UNIT_FILE_PATH="/etc/systemd/system/${NEW_AUTOMOUNT_UNIT_FILENAME}"
NEW_UNIT_NAME_FOR_COMMANDS="mnt-ix4_share_nfs" # Basisname für systemctl-Befehle

# ---- Konfiguration für die VORHERIGE funktionierende Unit (zum Aufräumen) ----
PREVIOUS_UNIT_BASENAME="mnt-ix4_nfs" # Der funktionierende von /mnt/ix4_nfs
PREVIOUS_MOUNT_UNIT_FILE="/etc/systemd/system/${PREVIOUS_UNIT_BASENAME}.mount"
PREVIOUS_AUTOMOUNT_UNIT_FILE="/etc/systemd/system/${PREVIOUS_UNIT_BASENAME}.automount"

# ---- Aufräumen der vorherigen Unit (für /mnt/ix4_nfs) ----
echo "Schritt 0: Aufräumen der vorherigen NFS-Unit (${PREVIOUS_UNIT_BASENAME}.automount)..."
echo "-> Stoppe ${PREVIOUS_UNIT_BASENAME}.automount (falls aktiv)..."
sudo systemctl stop "${PREVIOUS_UNIT_BASENAME}.automount" > /dev/null 2>&1
echo "-> Deaktiviere ${PREVIOUS_UNIT_BASENAME}.automount (falls enabled)..."
sudo systemctl disable "${PREVIOUS_UNIT_BASENAME}.automount" > /dev/null 2>&1
echo "-> Lösche alte Unit-Dateien (falls vorhanden):"
if [ -f "$PREVIOUS_MOUNT_UNIT_FILE" ]; then
    sudo rm -f "$PREVIOUS_MOUNT_UNIT_FILE"
    echo "   -> '$PREVIOUS_MOUNT_UNIT_FILE' gelöscht."
fi
if [ -f "$PREVIOUS_AUTOMOUNT_UNIT_FILE" ]; then
    sudo rm -f "$PREVIOUS_AUTOMOUNT_UNIT_FILE"
    echo "   -> '$PREVIOUS_AUTOMOUNT_UNIT_FILE' gelöscht."
fi
echo "-> Führe daemon-reload nach dem Aufräumen aus..."
sudo systemctl daemon-reload
echo "-> Aufräumen abgeschlossen."
echo ""


# ---- Schritte für die NEUE Unit ----

echo "Schritt 1: Lokalen Mountpunkt '$NEW_LOCAL_MOUNT_POINT' erstellen (falls nicht vorhanden)..."
sudo mkdir -p "$NEW_LOCAL_MOUNT_POINT"
if [ $? -eq 0 ]; then
    echo "-> Mountpunkt '$NEW_LOCAL_MOUNT_POINT' existiert oder wurde erstellt."
else
    echo "FEHLER: Konnte Mountpunkt '$NEW_LOCAL_MOUNT_POINT' nicht erstellen. Bitte manuell prüfen."
    exit 1
fi
echo ""

# ---- .mount Unit-Datei erstellen/überschreiben ----
echo "Schritt 2: Erstelle/Überschreibe Unit-Datei '$NEW_MOUNT_UNIT_FILE_PATH'..."
sudo rm -f "$NEW_MOUNT_UNIT_FILE_PATH" # Sicherstellen, dass keine Reste da sind
sudo tee "$NEW_MOUNT_UNIT_FILE_PATH" > /dev/null <<EOF
[Unit]
Description=Mount ix4-300d INTERNAL Share (NFS) to ${NEW_LOCAL_MOUNT_POINT}
Requires=network-online.target
After=network-online.target

[Mount]
What=${NAS_IP}:${NFS_EXPORT_PATH}
Where=${NEW_LOCAL_MOUNT_POINT}
Type=nfs
Options=vers=3,rw,sync,hard,intr,nofail

[Install]
WantedBy=multi-user.target
EOF
if [ -f "$NEW_MOUNT_UNIT_FILE_PATH" ]; then
    echo "-> '$NEW_MOUNT_UNIT_FILE_PATH' wurde erfolgreich erstellt/überschrieben."
    echo "   Inhalt wird überprüft:"
    sudo systemd-analyze verify "$NEW_MOUNT_UNIT_FILE_PATH"
    if [ $? -ne 0 ]; then
        echo "   WARNUNG: 'systemd-analyze verify' meldet ein Problem mit der .mount-Datei!"
    else
        echo "   -> 'systemd-analyze verify' für .mount-Datei: OK"
    fi
else
    echo "FEHLER: Konnte '$NEW_MOUNT_UNIT_FILE_PATH' nicht erstellen."
    exit 1
fi
echo ""

# ---- .automount Unit-Datei erstellen/überschreiben ----
echo "Schritt 3: Erstelle/Überschreibe Unit-Datei '$NEW_AUTOMOUNT_UNIT_FILE_PATH'..."
sudo rm -f "$NEW_AUTOMOUNT_UNIT_FILE_PATH" # Sicherstellen, dass keine Reste da sind
sudo tee "$NEW_AUTOMOUNT_UNIT_FILE_PATH" > /dev/null <<EOF
[Unit]
Description=Automount ix4-300d INTERNAL Share (NFS) to ${NEW_LOCAL_MOUNT_POINT}
Requires=network-online.target
After=network-online.target

[Automount]
Where=${NEW_LOCAL_MOUNT_POINT}
TimeoutIdleSec=600

[Install]
WantedBy=multi-user.target
EOF
if [ -f "$NEW_AUTOMOUNT_UNIT_FILE_PATH" ]; then
    echo "-> '$NEW_AUTOMOUNT_UNIT_FILE_PATH' wurde erfolgreich erstellt/überschrieben."
    echo "   Inhalt wird überprüft:"
    sudo systemd-analyze verify "$NEW_AUTOMOUNT_UNIT_FILE_PATH"
    if [ $? -ne 0 ]; then
        echo "   WARNUNG: 'systemd-analyze verify' meldet ein Problem mit der .automount-Datei!"
    else
        echo "   -> 'systemd-analyze verify' für .automount-Datei: OK"
    fi
else
    echo "FEHLER: Konnte '$NEW_AUTOMOUNT_UNIT_FILE_PATH' nicht erstellen."
    exit 1
fi
echo ""

# ---- Systemd-Befehle ----
echo "Schritt 4: Systemd-Konfiguration neu laden..."
sudo systemctl daemon-reload
echo "-> daemon-reload ausgeführt."
echo ""

echo "Schritt 5: Deaktiviere (falls vorhanden) und aktiviere die Automount-Unit..."
echo "-> Versuche Deaktivierung über Dateipfad: $NEW_AUTOMOUNT_UNIT_FILE_PATH"
sudo systemctl disable "$NEW_AUTOMOUNT_UNIT_FILE_PATH" # Sollte "no such file or directory" oder Warnung geben, da Symlink noch nicht existiert
echo "-> Aktiviere über Dateipfad: $NEW_AUTOMOUNT_UNIT_FILE_PATH"
sudo systemctl enable "$NEW_AUTOMOUNT_UNIT_FILE_PATH"
if [ $? -eq 0 ]; then
    echo "-> Automount-Unit erfolgreich aktiviert."
else
    echo "FEHLER: Konnte Automount-Unit nicht aktivieren."
    sudo systemctl status "${NEW_UNIT_NAME_FOR_COMMANDS}.automount" --no-pager -n 0
    exit 1
fi
echo ""

echo "Schritt 6: Starte die Automount-Unit neu..."
echo "-> Versuche Neustart über Unit-Namen: ${NEW_UNIT_NAME_FOR_COMMANDS}.automount"
sudo systemctl restart "${NEW_UNIT_NAME_FOR_COMMANDS}.automount"
if [ $? -eq 0 ]; then
    echo "-> Automount-Unit erfolgreich neu gestartet."
else
    echo "FEHLER: Konnte Automount-Unit nicht neu starten."
    echo "   Status der Automount-Unit:"
    sudo systemctl status "${NEW_UNIT_NAME_FOR_COMMANDS}.automount" --no-pager -n 0
    echo "   Mögliche Ursache: 'systemd-analyze verify' hat Probleme in den Unit-Dateien gemeldet."
    exit 1
fi
echo ""

# ---- Überprüfung ----
echo "Schritt 7: Überprüfe den Status der Units..."
echo "-> Status für ${NEW_UNIT_NAME_FOR_COMMANDS}.automount:"
sudo systemctl status "${NEW_UNIT_NAME_FOR_COMMANDS}.automount" --no-pager
echo ""
echo "-> Warte 5 Sekunden, dann versuche Zugriff auf '$NEW_LOCAL_MOUNT_POINT'..."
sleep 5
ls "$NEW_LOCAL_MOUNT_POINT" > /dev/null 2>&1
ls_exit_code=$?

if [ $ls_exit_code -eq 0 ]; then
    echo "-> Zugriff auf '$NEW_LOCAL_MOUNT_POINT' erfolgreich!"
    echo "   Inhalt:"
    ls -l "$NEW_LOCAL_MOUNT_POINT"
    echo ""
    echo "-> Status für ${NEW_UNIT_NAME_FOR_COMMANDS}.mount (sollte jetzt aktiv sein):"
    sudo systemctl status "${NEW_UNIT_NAME_FOR_COMMANDS}.mount" --no-pager
else
    echo "FEHLER: Zugriff auf '$NEW_LOCAL_MOUNT_POINT' fehlgeschlagen (Exit Code: $ls_exit_code)."
    echo "-> Status für ${NEW_UNIT_NAME_FOR_COMMANDS}.mount (wird wahrscheinlich Fehler zeigen):"
    sudo systemctl status "${NEW_UNIT_NAME_FOR_COMMANDS}.mount" --no-pager
    echo ""
    echo "-> Journal für ${NEW_UNIT_NAME_FOR_COMMANDS}.mount (letzte 20 Zeilen):"
    sudo journalctl -n 20 -xeu "${NEW_UNIT_NAME_FOR_COMMANDS}.mount" --no-pager
fi
echo ""

echo "=== Setup-Skript abgeschlossen ==="

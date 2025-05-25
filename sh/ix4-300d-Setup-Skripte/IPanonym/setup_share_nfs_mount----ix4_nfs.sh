#!/bin/bash


sudo systemctl stop mnt-ix4share.automount
sudo systemctl disable mnt-ix4share.automount
sudo rm /etc/systemd/system/mnt-ix4share.mount # Alte Unit-Dateien löschen
sudo rm /etc/systemd/system/mnt-ix4share.automount # Alte Unit-Dateien löschen
sudo systemctl daemon-reload


echo "=== Automatisches Setup-Skript für NFS-Mount: /mnt/ix4_nfs ==="
echo ""

# ---- Konfiguration ----
LOCAL_MOUNT_POINT="/mnt/ix4_nfs" # Neuer, kurzer Name mit NFS-Indikator
NAS_IP="[YourNASip]"
NFS_EXPORT_PATH="/nfs/share"

# Dateinamen für die systemd-Units
# /mnt/ix4_nfs -> mnt-ix4_nfs
MOUNT_UNIT_FILENAME="mnt-ix4_nfs.mount"
AUTOMOUNT_UNIT_FILENAME="mnt-ix4_nfs.automount"

# Vollständige Pfade zu den Unit-Dateien
MOUNT_UNIT_FILE_PATH="/etc/systemd/system/${MOUNT_UNIT_FILENAME}"
AUTOMOUNT_UNIT_FILE_PATH="/etc/systemd/system/${AUTOMOUNT_UNIT_FILENAME}"

# Von systemd abgeleiteter Unit-Name für Befehle
# Für /mnt/ix4_nfs: mnt-ix4_nfs (Unterstrich sollte okay sein)
UNIT_NAME_FOR_COMMANDS="mnt-ix4_nfs"

# ---- Schritte ----

echo "Schritt 1: Lokalen Mountpunkt '$LOCAL_MOUNT_POINT' erstellen (falls nicht vorhanden)..."
sudo mkdir -p "$LOCAL_MOUNT_POINT"
if [ $? -eq 0 ]; then
    echo "-> Mountpunkt existiert oder wurde erstellt."
else
    echo "FEHLER: Konnte Mountpunkt nicht erstellen. Bitte manuell prüfen."
    exit 1
fi
echo ""

# ---- .mount Unit-Datei erstellen/überschreiben ----
echo "Schritt 2: Erstelle/Überschreibe Unit-Datei '$MOUNT_UNIT_FILE_PATH'..."
sudo rm -f "$MOUNT_UNIT_FILE_PATH"
sudo tee "$MOUNT_UNIT_FILE_PATH" > /dev/null <<EOF
[Unit]
Description=Mount ix4-300d INTERNAL Share (NFS) to ${LOCAL_MOUNT_POINT}
Requires=network-online.target
After=network-online.target

[Mount]
What=${NAS_IP}:${NFS_EXPORT_PATH}
Where=${LOCAL_MOUNT_POINT}
Type=nfs
Options=vers=3,rw,sync,hard,intr,nofail

[Install]
WantedBy=multi-user.target
EOF
if [ -f "$MOUNT_UNIT_FILE_PATH" ]; then
    echo "-> '$MOUNT_UNIT_FILE_PATH' wurde erfolgreich erstellt/überschrieben."
    echo "   Inhalt wird überprüft:"
    sudo systemd-analyze verify "$MOUNT_UNIT_FILE_PATH"
    if [ $? -ne 0 ]; then
        echo "   WARNUNG: 'systemd-analyze verify' meldet ein Problem mit der .mount-Datei!"
    else
        echo "   -> 'systemd-analyze verify' für .mount-Datei: OK"
    fi
else
    echo "FEHLER: Konnte '$MOUNT_UNIT_FILE_PATH' nicht erstellen."
    exit 1
fi
echo ""

# ---- .automount Unit-Datei erstellen/überschreiben ----
echo "Schritt 3: Erstelle/Überschreibe Unit-Datei '$AUTOMOUNT_UNIT_FILE_PATH'..."
sudo rm -f "$AUTOMOUNT_UNIT_FILE_PATH"
sudo tee "$AUTOMOUNT_UNIT_FILE_PATH" > /dev/null <<EOF
[Unit]
Description=Automount ix4-300d INTERNAL Share (NFS) to ${LOCAL_MOUNT_POINT}
Requires=network-online.target
After=network-online.target

[Automount]
Where=${LOCAL_MOUNT_POINT}
TimeoutIdleSec=600

[Install]
WantedBy=multi-user.target
EOF
if [ -f "$AUTOMOUNT_UNIT_FILE_PATH" ]; then
    echo "-> '$AUTOMOUNT_UNIT_FILE_PATH' wurde erfolgreich erstellt/überschrieben."
    echo "   Inhalt wird überprüft:"
    sudo systemd-analyze verify "$AUTOMOUNT_UNIT_FILE_PATH"
    if [ $? -ne 0 ]; then
        echo "   WARNUNG: 'systemd-analyze verify' meldet ein Problem mit der .automount-Datei!"
    else
        echo "   -> 'systemd-analyze verify' für .automount-Datei: OK"
    fi
else
    echo "FEHLER: Konnte '$AUTOMOUNT_UNIT_FILE_PATH' nicht erstellen."
    exit 1
fi
echo ""

# ---- Systemd-Befehle ----
echo "Schritt 4: Systemd-Konfiguration neu laden..."
sudo systemctl daemon-reload
echo "-> daemon-reload ausgeführt."
echo ""

echo "Schritt 5: Deaktiviere (falls vorhanden) und aktiviere die Automount-Unit..."
echo "-> Versuche Deaktivierung über Dateipfad: $AUTOMOUNT_UNIT_FILE_PATH"
sudo systemctl disable "$AUTOMOUNT_UNIT_FILE_PATH"
echo "-> Versuche Deaktivierung über Unit-Namen: ${UNIT_NAME_FOR_COMMANDS}.automount"
sudo systemctl disable "${UNIT_NAME_FOR_COMMANDS}.automount" > /dev/null 2>&1

echo "-> Aktiviere über Dateipfad: $AUTOMOUNT_UNIT_FILE_PATH"
sudo systemctl enable "$AUTOMOUNT_UNIT_FILE_PATH"
if [ $? -eq 0 ]; then
    echo "-> Automount-Unit erfolgreich aktiviert."
else
    echo "FEHLER: Konnte Automount-Unit nicht aktivieren."
    sudo systemctl status "${UNIT_NAME_FOR_COMMANDS}.automount" --no-pager -n 0
    exit 1
fi
echo ""

echo "Schritt 6: Starte die Automount-Unit neu..."
echo "-> Versuche Neustart über Unit-Namen: ${UNIT_NAME_FOR_COMMANDS}.automount"
sudo systemctl restart "${UNIT_NAME_FOR_COMMANDS}.automount"
if [ $? -eq 0 ]; then
    echo "-> Automount-Unit erfolgreich neu gestartet."
else
    echo "FEHLER: Konnte Automount-Unit nicht neu starten."
    echo "   Status der Automount-Unit:"
    sudo systemctl status "${UNIT_NAME_FOR_COMMANDS}.automount" --no-pager -n 0
    echo "   Mögliche Ursache: 'systemd-analyze verify' hat Probleme in den Unit-Dateien gemeldet."
    exit 1
fi
echo ""

# ---- Überprüfung ----
echo "Schritt 7: Überprüfe den Status der Units..."
echo "-> Status für ${UNIT_NAME_FOR_COMMANDS}.automount:"
sudo systemctl status "${UNIT_NAME_FOR_COMMANDS}.automount" --no-pager
echo ""
echo "-> Warte 5 Sekunden, dann versuche Zugriff auf '$LOCAL_MOUNT_POINT'..."
sleep 5
ls "$LOCAL_MOUNT_POINT" > /dev/null 2>&1
ls_exit_code=$?

if [ $ls_exit_code -eq 0 ]; then
    echo "-> Zugriff auf '$LOCAL_MOUNT_POINT' erfolgreich!"
    echo "   Inhalt:"
    ls -l "$LOCAL_MOUNT_POINT"
    echo ""
    echo "-> Status für ${UNIT_NAME_FOR_COMMANDS}.mount (sollte jetzt aktiv sein):"
    sudo systemctl status "${UNIT_NAME_FOR_COMMANDS}.mount" --no-pager
else
    echo "FEHLER: Zugriff auf '$LOCAL_MOUNT_POINT' fehlgeschlagen (Exit Code: $ls_exit_code)."
    echo "-> Status für ${UNIT_NAME_FOR_COMMANDS}.mount (wird wahrscheinlich Fehler zeigen):"
    sudo systemctl status "${UNIT_NAME_FOR_COMMANDS}.mount" --no-pager
    echo ""
    echo "-> Journal für ${UNIT_NAME_FOR_COMMANDS}.mount (letzte 20 Zeilen):"
    sudo journalctl -n 20 -xeu "${UNIT_NAME_FOR_COMMANDS}.mount" --no-pager
fi
echo ""

echo "=== Setup-Skript abgeschlossen ==="

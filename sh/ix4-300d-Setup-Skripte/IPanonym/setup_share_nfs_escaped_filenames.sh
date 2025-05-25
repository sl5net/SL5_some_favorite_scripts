#!/bin/bash

echo "=== Experimentelles Setup V2: NFS-Mount für /mnt[YourNASMount]/share ==="
echo "=== mit '\\x2d' direkt im Unit-Dateinamen ==="
echo ""

# ---- Konfiguration ----
LOCAL_MOUNT_POINT="/mnt[YourNASMount]/share"
NAS_IP="[YourNASip]"
NFS_EXPORT_PATH="/nfs/share"

# Dateinamen für die systemd-Units - MIT LITERALEM '\x2d' IM NAMEN
# Wichtig: Die einfachen Anführungszeichen sind hier für die Shell, damit der Backslash
# als Teil des Dateinamens interpretiert wird, den wir erstellen wollen.
MOUNT_UNIT_FILENAME_LITERAL='mnt-ix4\x2d300d-share.mount'
AUTOMOUNT_UNIT_FILENAME_LITERAL='mnt-ix4\x2d300d-share.automount'

# Vollständige Pfade zu den Unit-Dateien (für tee und Dateiprüfungen)
MOUNT_UNIT_FILE_PATH_FOR_FS="/etc/systemd/system/${MOUNT_UNIT_FILENAME_LITERAL}"
AUTOMOUNT_UNIT_FILE_PATH_FOR_FS="/etc/systemd/system/${AUTOMOUNT_UNIT_FILENAME_LITERAL}"

# Der Unit-Name, wie er in systemctl-Befehlen verwendet werden soll,
# wenn der Dateiname '\x2d' enthält. Der Backslash muss für die Shell escaped werden.
UNIT_NAME_FOR_SHELL_COMMANDS='mnt-ix4\x2d300d-share' # Basisname

# ---- Vorbereitung: Alte/Konkurrierende Units entfernen ----
echo "Schritt 1: Bereinige mögliche alte/konkurrierende Unit-Dateien für '$LOCAL_MOUNT_POINT'..."
sudo rm -f "/etc/systemd/system/mnt-ix4-300d-share.mount" # Normaler Name
sudo rm -f "/etc/systemd/system/mnt-ix4-300d-share.automount" # Normaler Name
# Auch die mit \x2d im Namen, falls sie von früheren Tests noch da sind:
sudo rm -f "$MOUNT_UNIT_FILE_PATH_FOR_FS" # Verwendet die Variable mit ' '
sudo rm -f "$AUTOMOUNT_UNIT_FILE_PATH_FOR_FS" # Verwendet die Variable mit ' '
echo "-> Bereinigung (Versuch) abgeschlossen."
echo ""

# ---- .mount Unit-Datei mit literalem '\x2d' im Namen erstellen ----
echo "Schritt 2: Erstelle Unit-Datei '$MOUNT_UNIT_FILE_PATH_FOR_FS' (NFS)..."
sudo bash -c "tee '$MOUNT_UNIT_FILE_PATH_FOR_FS' > /dev/null" <<EOF
[Unit]
Description=Mount ix4-300d Share to ${LOCAL_MOUNT_POINT} (NFS, escaped filename)
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

if [ -f "$MOUNT_UNIT_FILE_PATH_FOR_FS" ]; then
    echo "-> '$MOUNT_UNIT_FILE_PATH_FOR_FS' wurde erfolgreich erstellt."
    echo "   Inhalt wird überprüft (Verwendung des Dateipfads für verify):"
    sudo systemd-analyze verify "$MOUNT_UNIT_FILE_PATH_FOR_FS"
    if [ $? -ne 0 ]; then
        echo "   WARNUNG: 'systemd-analyze verify' meldet ein Problem mit der .mount-Datei!"
    else
        echo "   -> 'systemd-analyze verify' für .mount-Datei: OK"
    fi
else
    echo "FEHLER: Konnte '$MOUNT_UNIT_FILE_PATH_FOR_FS' nicht erstellen."
    exit 1
fi
echo ""

# ---- .automount Unit-Datei mit literalem '\x2d' im Namen erstellen ----
echo "Schritt 3: Erstelle Unit-Datei '$AUTOMOUNT_UNIT_FILE_PATH_FOR_FS' (NFS)..."
sudo bash -c "tee '$AUTOMOUNT_UNIT_FILE_PATH_FOR_FS' > /dev/null" <<EOF
[Unit]
Description=Automount ix4-300d Share to ${LOCAL_MOUNT_POINT} (NFS, escaped filename)
Requires=network-online.target
After=network-online.target

[Automount]
Where=${LOCAL_MOUNT_POINT}
TimeoutIdleSec=600

[Install]
WantedBy=multi-user.target
EOF

if [ -f "$AUTOMOUNT_UNIT_FILE_PATH_FOR_FS" ]; then
    echo "-> '$AUTOMOUNT_UNIT_FILE_PATH_FOR_FS' wurde erfolgreich erstellt."
    echo "   Inhalt wird überprüft (Verwendung des Dateipfads für verify):"
    sudo systemd-analyze verify "$AUTOMOUNT_UNIT_FILE_PATH_FOR_FS"
    if [ $? -ne 0 ]; then
        echo "   WARNUNG: 'systemd-analyze verify' meldet ein Problem mit der .automount-Datei!"
    else
        echo "   -> 'systemd-analyze verify' für .automount-Datei: OK"
    fi
else
    echo "FEHLER: Konnte '$AUTOMOUNT_UNIT_FILE_PATH_FOR_FS' nicht erstellen."
    exit 1
fi
echo ""

# ---- Systemd-Befehle ----
echo "Schritt 4: Systemd-Konfiguration neu laden..."
sudo systemctl daemon-reload
echo "-> daemon-reload ausgeführt."
echo ""

echo "Schritt 5: Aktiviere die Automount-Unit..."
echo "-> Aktiviere über Dateipfad: '$AUTOMOUNT_UNIT_FILE_PATH_FOR_FS'"
sudo systemctl enable "$AUTOMOUNT_UNIT_FILE_PATH_FOR_FS"
if [ $? -eq 0 ]; then
    echo "-> Automount-Unit erfolgreich aktiviert."
else
    echo "FEHLER: Konnte Automount-Unit nicht aktivieren."
    sudo systemctl status "'${UNIT_NAME_FOR_SHELL_COMMANDS}.automount'" --no-pager -n 0
    exit 1
fi
echo ""

echo "Schritt 6: Starte die Automount-Unit neu..."
# Der Unit-Name für systemctl Befehle muss den Backslash für die Shell escapen,
# oder in einfache Anführungszeichen gesetzt werden, die den Backslash schützen.
echo "-> Versuche Neustart über Unit-Namen: '${UNIT_NAME_FOR_SHELL_COMMANDS}.automount'"
sudo systemctl restart "${UNIT_NAME_FOR_SHELL_COMMANDS}.automount" # Hier keine zusätzlichen Anführungszeichen um die Variable
if [ $? -eq 0 ]; then
    echo "-> Automount-Unit erfolgreich neu gestartet."
else
    echo "FEHLER: Konnte Automount-Unit nicht neu starten."
    echo "   Status der Automount-Unit:"
    sudo systemctl status "${UNIT_NAME_FOR_SHELL_COMMANDS}.automount" --no-pager -n 0
    echo "   Mögliche Ursache: 'systemd-analyze verify' hat Probleme in den Unit-Dateien gemeldet (sollte aber OK sein)."
    exit 1
fi
echo ""

# ---- Überprüfung ----
echo "Schritt 7: Überprüfe den Status der Units..."
echo "-> Status für ${UNIT_NAME_FOR_SHELL_COMMANDS}.automount:"
sudo systemctl status "${UNIT_NAME_FOR_SHELL_COMMANDS}.automount" --no-pager
echo ""
echo "-> Warte 5 Sekunden, dann versuche Zugriff auf '$LOCAL_MOUNT_POINT'..."
sleep 5
ls "$LOCAL_MOUNT_POINT" > /dev/null 2>&1
ls_exit_code=$?

if [ $ls_exit_code -eq 0 ]; then
    echo "-> Zugriff auf '$LOCAL_MOUNT_POINT' (NFS) erfolgreich!"
    echo "   Inhalt:"
    ls -l "$LOCAL_MOUNT_POINT"
    echo ""
    echo "-> Status für '$LOCAL_MOUNT_POINT' (sollte jetzt aktiv sein):"
    sudo systemctl status "$LOCAL_MOUNT_POINT" --no-pager
else
    echo "FEHLER: Zugriff auf '$LOCAL_MOUNT_POINT' (NFS) fehlgeschlagen (Exit Code: $ls_exit_code)."
    echo "-> Status für '$LOCAL_MOUNT_POINT':"
    sudo systemctl status "$LOCAL_MOUNT_POINT" --no-pager
    echo ""
    echo "-> Journal für ${UNIT_NAME_FOR_SHELL_COMMANDS}.mount (NFS, letzte 20 Zeilen):"
    sudo journalctl -n 20 -xeu "${UNIT_NAME_FOR_SHELL_COMMANDS}.mount" --no-pager
fi
echo ""

echo "=== Experimentelles Setup-Skript V2 abgeschlossen ==="

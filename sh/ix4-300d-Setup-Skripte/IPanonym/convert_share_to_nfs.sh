#!/bin/bash

echo "=== Umstellungs-Skript: /mnt[YourNASMount]/share von CIFS auf NFS ==="
echo ""

# ---- Konfiguration ----
LOCAL_MOUNT_POINT="/mnt[YourNASMount]/share" # Der bestehende Mountpunkt
NAS_IP="[YourNASip]"
NFS_EXPORT_PATH="/nfs/share" # Der NFSv3-Exportpfad für den internen Share

# Dateinamen für die systemd-Units (mit normalen Bindestrichen, wie sie für CIFS waren)
# Diese werden jetzt für NFS verwendet, aber der Name bleibt gleich, da der Mountpunkt gleich bleibt.
MOUNT_UNIT_FILENAME="mnt-ix4-300d-share.mount"
AUTOMOUNT_UNIT_FILENAME="mnt-ix4-300d-share.automount"

# Vollständige Pfade zu den Unit-Dateien
MOUNT_UNIT_FILE_PATH="/etc/systemd/system/${MOUNT_UNIT_FILENAME}"
AUTOMOUNT_UNIT_FILE_PATH="/etc/systemd/system/${AUTOMOUNT_UNIT_FILENAME}"

# Von systemd abgeleiteter Unit-Name für Befehle (mit Escaping für die Shell)
UNIT_NAME_ESCAPED="mnt-ix4\\x2d300d-share"

# ---- Schritte ----

echo "Schritt 1: Stoppe und deaktiviere bestehende Automount-Unit für '$LOCAL_MOUNT_POINT' (CIFS)..."
sudo systemctl stop "${UNIT_NAME_ESCAPED}.automount" > /dev/null 2>&1
sudo systemctl disable "${UNIT_NAME_ESCAPED}.automount" > /dev/null 2>&1 # Verwendet den escapeten Namen
# Sicherstellen, dass auch der Symlink via Pfad entfernt wird, falls der Namens-disable nicht greift
if [ -f "$AUTOMOUNT_UNIT_FILE_PATH" ]; then # Nur wenn die Originaldatei existiert
    sudo systemctl disable "$AUTOMOUNT_UNIT_FILE_PATH" > /dev/null 2>&1
fi
echo "-> Alte Automount-Unit gestoppt und deaktiviert (Versuch)."
echo ""

echo "Schritt 2: Benenne alte CIFS Unit-Dateien um (Backup)..."
if [ -f "$MOUNT_UNIT_FILE_PATH" ]; then
    sudo mv "$MOUNT_UNIT_FILE_PATH" "${MOUNT_UNIT_FILE_PATH}.cifs_bak"
    echo "-> Alte Mount-Datei umbenannt zu ${MOUNT_UNIT_FILE_PATH}.cifs_bak"
else
    echo "-> Keine alte Mount-Datei '$MOUNT_UNIT_FILE_PATH' zum Umbenennen gefunden."
fi
if [ -f "$AUTOMOUNT_UNIT_FILE_PATH" ]; then
    sudo mv "$AUTOMOUNT_UNIT_FILE_PATH" "${AUTOMOUNT_UNIT_FILE_PATH}.cifs_bak"
    echo "-> Alte Automount-Datei umbenannt zu ${AUTOMOUNT_UNIT_FILE_PATH}.cifs_bak"
else
    echo "-> Keine alte Automount-Datei '$AUTOMOUNT_UNIT_FILE_PATH' zum Umbenennen gefunden."
fi
echo ""

echo "Schritt 3: Systemd-Konfiguration neu laden, um alte Units zu 'vergessen'..."
sudo systemctl daemon-reload
echo "-> daemon-reload ausgeführt."
echo ""

# ---- Neue NFS .mount Unit-Datei erstellen ----
echo "Schritt 4: Erstelle NEUE Unit-Datei '$MOUNT_UNIT_FILE_PATH' für NFS..."
sudo tee "$MOUNT_UNIT_FILE_PATH" > /dev/null <<EOF
[Unit]
Description=Mount ix4-300d Share to ${LOCAL_MOUNT_POINT} (NFS)
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
    echo "-> '$MOUNT_UNIT_FILE_PATH' (NFS) wurde erfolgreich erstellt."
    echo "   Inhalt wird überprüft:"
    sudo systemd-analyze verify "$MOUNT_UNIT_FILE_PATH"
    if [ $? -ne 0 ]; then
        echo "   WARNUNG: 'systemd-analyze verify' meldet ein Problem mit der NEUEN .mount-Datei!"
    else
        echo "   -> 'systemd-analyze verify' für NEUE .mount-Datei: OK"
    fi
else
    echo "FEHLER: Konnte '$MOUNT_UNIT_FILE_PATH' (NFS) nicht erstellen."
    exit 1
fi
echo ""

# ---- Neue NFS .automount Unit-Datei erstellen ----
echo "Schritt 5: Erstelle NEUE Unit-Datei '$AUTOMOUNT_UNIT_FILE_PATH' für NFS..."
sudo tee "$AUTOMOUNT_UNIT_FILE_PATH" > /dev/null <<EOF
[Unit]
Description=Automount ix4-300d Share to ${LOCAL_MOUNT_POINT} (NFS)
Requires=network-online.target
After=network-online.target

[Automount]
Where=${LOCAL_MOUNT_POINT}
TimeoutIdleSec=600

[Install]
WantedBy=multi-user.target
EOF
if [ -f "$AUTOMOUNT_UNIT_FILE_PATH" ]; then
    echo "-> '$AUTOMOUNT_UNIT_FILE_PATH' (NFS) wurde erfolgreich erstellt."
    echo "   Inhalt wird überprüft:"
    sudo systemd-analyze verify "$AUTOMOUNT_UNIT_FILE_PATH"
    if [ $? -ne 0 ]; then
        echo "   WARNUNG: 'systemd-analyze verify' meldet ein Problem mit der NEUEN .automount-Datei!"
    else
        echo "   -> 'systemd-analyze verify' für NEUE .automount-Datei: OK"
    fi
else
    echo "FEHLER: Konnte '$AUTOMOUNT_UNIT_FILE_PATH' (NFS) nicht erstellen."
    exit 1
fi
echo ""

# ---- Systemd-Befehle für die neuen NFS-Units ----
echo "Schritt 6: Systemd-Konfiguration erneut neu laden..."
sudo systemctl daemon-reload
echo "-> daemon-reload ausgeführt."
echo ""

echo "Schritt 7: Aktiviere die NEUE NFS-Automount-Unit..."
echo "-> Aktiviere über Dateipfad: $AUTOMOUNT_UNIT_FILE_PATH"
sudo systemctl enable "$AUTOMOUNT_UNIT_FILE_PATH"
if [ $? -eq 0 ]; then
    echo "-> NEUE Automount-Unit (NFS) erfolgreich aktiviert."
else
    echo "FEHLER: Konnte NEUE Automount-Unit (NFS) nicht aktivieren."
    sudo systemctl status "${UNIT_NAME_ESCAPED}.automount" --no-pager -n 0 # Status mit altem escapeten Namen prüfen
    exit 1
fi
echo ""

echo "Schritt 8: Starte die NEUE NFS-Automount-Unit neu..."
echo "-> Versuche Neustart über Unit-Namen: ${UNIT_NAME_ESCAPED}.automount"
sudo systemctl restart "${UNIT_NAME_ESCAPED}.automount"
if [ $? -eq 0 ]; then
    echo "-> NEUE Automount-Unit (NFS) erfolgreich neu gestartet."
else
    echo "FEHLER: Konnte NEUE Automount-Unit (NFS) nicht neu starten."
    echo "   Status der Automount-Unit:"
    sudo systemctl status "${UNIT_NAME_ESCAPED}.automount" --no-pager -n 0
    echo "   Mögliche Ursache: 'systemd-analyze verify' hat Probleme in den Unit-Dateien gemeldet."
    exit 1
fi
echo ""

# ---- Überprüfung ----
echo "Schritt 9: Überprüfe den Status der NEUEN NFS-Units..."
echo "-> Status für ${UNIT_NAME_ESCAPED}.automount (NFS):"
sudo systemctl status "${UNIT_NAME_ESCAPED}.automount" --no-pager
echo ""
echo "-> Warte 5 Sekunden, dann versuche Zugriff auf '$LOCAL_MOUNT_POINT' (sollte jetzt NFS sein)..."
sleep 5
ls "$LOCAL_MOUNT_POINT" > /dev/null 2>&1
ls_exit_code=$?

if [ $ls_exit_code -eq 0 ]; then
    echo "-> Zugriff auf '$LOCAL_MOUNT_POINT' (NFS) erfolgreich!"
    echo "   Inhalt:"
    ls -l "$LOCAL_MOUNT_POINT"
    echo ""
    echo "-> Status für ${UNIT_NAME_ESCAPED}.mount (NFS, sollte jetzt aktiv sein):"
    # Status über Mountpunkt abfragen, da Namensauflösung problematisch sein kann
    sudo systemctl status "$LOCAL_MOUNT_POINT" --no-pager
else
    echo "FEHLER: Zugriff auf '$LOCAL_MOUNT_POINT' (NFS) fehlgeschlagen (Exit Code: $ls_exit_code)."
    echo "-> Status für ${UNIT_NAME_ESCAPED}.mount (NFS, wird wahrscheinlich Fehler zeigen):"
    sudo systemctl status "$LOCAL_MOUNT_POINT" --no-pager # oder "${UNIT_NAME_ESCAPED}.mount"
    echo ""
    echo "-> Journal für ${UNIT_NAME_ESCAPED}.mount (NFS, letzte 20 Zeilen):"
    sudo journalctl -n 20 -xeu "${UNIT_NAME_ESCAPED}.mount" --no-pager
fi
echo ""

echo "=== Umstellungs-Skript auf NFS für $LOCAL_MOUNT_POINT abgeschlossen ==="

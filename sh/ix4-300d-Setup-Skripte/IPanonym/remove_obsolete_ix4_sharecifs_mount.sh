#!/bin/bash

echo "=== Aufräum-Skript: Entferne obsoleten CIFS-Mount /mnt[YourNASMount]/sharecifs ==="
echo "ACHTUNG: Ziel ist /mnt[YourNASMount]/sharecifs (OHNE Unterstrich vor cifs)"
echo ""

# ---- Konfiguration des zu entfernenden Mounts ----
OBSOLETE_LOCAL_MOUNT_POINT="/mnt[YourNASMount]/sharecifs" # KORREKTER PFAD

# Ableitung der Unit-Namen für diesen Pfad.
# Systemd würde /mnt[YourNASMount]/sharecifs zu mnt-ix4\x2d300d-sharecifs umwandeln.
# Dateinamen könnten "normal" oder "escaped" sein.

# "Escaped" Dateinamen-Variante (mit \x2d im Dateinamen selbst)
OBSOLETE_UNIT_FILENAME_BASE_ESCAPED='mnt-ix4\x2d300d-sharecifs'
OBSOLETE_MOUNT_UNIT_FILE_ESCAPED="/etc/systemd/system/${OBSOLETE_UNIT_FILENAME_BASE_ESCAPED}.mount"
OBSOLETE_AUTOMOUNT_UNIT_FILE_ESCAPED="/etc/systemd/system/${OBSOLETE_UNIT_FILENAME_BASE_ESCAPED}.automount"

# "Normale" Dateinamen-Variante (mit - im Dateinamen)
OBSOLETE_UNIT_FILENAME_BASE_NORMAL="mnt-ix4-300d-sharecifs"
OBSOLETE_MOUNT_UNIT_FILE_NORMAL="/etc/systemd/system/${OBSOLETE_UNIT_FILENAME_BASE_NORMAL}.mount"
OBSOLETE_AUTOMOUNT_UNIT_FILE_NORMAL="/etc/systemd/system/${OBSOLETE_UNIT_FILENAME_BASE_NORMAL}.automount"

# Der Unit-Name für systemctl Befehle (mit \x2d Escaping für die Shell)
OBSOLETE_UNIT_NAME_FOR_SHELL_CMDS='mnt-ix4\x2d300d-sharecifs'


# ---- Schritte ----

echo "Schritt 1: Stoppe und deaktiviere Automount-Unit für '$OBSOLETE_LOCAL_MOUNT_POINT'..."
echo "-> Stoppe Unit '${OBSOLETE_UNIT_NAME_FOR_SHELL_CMDS}.automount' (falls aktiv)..."
sudo systemctl stop "${OBSOLETE_UNIT_NAME_FOR_SHELL_CMDS}.automount" > /dev/null 2>&1

echo "-> Deaktiviere Unit (falls enabled)..."
# Versuche Deaktivierung über beide möglichen Dateipfad-Varianten
# Zuerst die "escaped" Variante, da diese bei Problempfaden eher zutrifft
if [ -f "$OBSOLETE_AUTOMOUNT_UNIT_FILE_ESCAPED" ]; then
    sudo systemctl disable "$OBSOLETE_AUTOMOUNT_UNIT_FILE_ESCAPED"
elif [ -f "$OBSOLETE_AUTOMOUNT_UNIT_FILE_NORMAL" ]; then
    sudo systemctl disable "$OBSOLETE_AUTOMOUNT_UNIT_FILE_NORMAL"
else
    sudo systemctl disable "${OBSOLETE_UNIT_NAME_FOR_SHELL_CMDS}.automount" > /dev/null 2>&1
fi
echo "-> Stopp- und Deaktivierungsversuche abgeschlossen."
echo ""

echo "Schritt 2: Lösche die Unit-Dateien für '$OBSOLETE_LOCAL_MOUNT_POINT'..."
# Lösche beide möglichen Dateinamensvarianten
if [ -f "$OBSOLETE_MOUNT_UNIT_FILE_ESCAPED" ]; then
    sudo rm -f "$OBSOLETE_MOUNT_UNIT_FILE_ESCAPED"
    echo "-> '$OBSOLETE_MOUNT_UNIT_FILE_ESCAPED' gelöscht."
fi
if [ -f "$OBSOLETE_AUTOMOUNT_UNIT_FILE_ESCAPED" ]; then
    sudo rm -f "$OBSOLETE_AUTOMOUNT_UNIT_FILE_ESCAPED"
    echo "-> '$OBSOLETE_AUTOMOUNT_UNIT_FILE_ESCAPED' gelöscht."
fi
if [ -f "$OBSOLETE_MOUNT_UNIT_FILE_NORMAL" ]; then
    sudo rm -f "$OBSOLETE_MOUNT_UNIT_FILE_NORMAL"
    echo "-> '$OBSOLETE_MOUNT_UNIT_FILE_NORMAL' gelöscht."
fi
if [ -f "$OBSOLETE_AUTOMOUNT_UNIT_FILE_NORMAL" ]; then
    sudo rm -f "$OBSOLETE_AUTOMOUNT_UNIT_FILE_NORMAL"
    echo "-> '$OBSOLETE_AUTOMOUNT_UNIT_FILE_NORMAL' gelöscht."
fi
echo ""

echo "Schritt 3: Lösche den lokalen Mountpunkt-Ordner '$OBSOLETE_LOCAL_MOUNT_POINT' (nur wenn leer)..."
if findmnt --mountpoint "$OBSOLETE_LOCAL_MOUNT_POINT" > /dev/null; then
    echo "WARNUNG: '$OBSOLETE_LOCAL_MOUNT_POINT' ist immer noch ein aktiver Mountpunkt laut findmnt!"
    echo "         Bitte manuell unmounten oder Problem untersuchen, bevor der Ordner gelöscht wird."
else
    if [ -d "$OBSOLETE_LOCAL_MOUNT_POINT" ]; then
        if [ -z "$(ls -A $OBSOLETE_LOCAL_MOUNT_POINT 2>/dev/null)" ]; then
            sudo rmdir "$OBSOLETE_LOCAL_MOUNT_POINT"
            if [ $? -eq 0 ]; then
                echo "-> Lokaler Mountpunkt-Ordner '$OBSOLETE_LOCAL_MOUNT_POINT' erfolgreich gelöscht."
            else
                echo "FEHLER: Konnte '$OBSOLETE_LOCAL_MOUNT_POINT' nicht löschen (wahrscheinlich nicht leer oder Berechtigungsproblem oder existiert nicht mehr)."
            fi
        else
            echo "WARNUNG: Lokaler Mountpunkt-Ordner '$OBSOLETE_LOCAL_MOUNT_POINT' ist nicht leer. Wird nicht gelöscht."
            # ls -lA "$OBSOLETE_LOCAL_MOUNT_POINT" # Auskommentiert, um nicht versehentlich viel auszugeben
        fi
    else
        echo "-> Lokaler Mountpunkt-Ordner '$OBSOLETE_LOCAL_MOUNT_POINT' nicht gefunden."
    fi
fi
echo ""

echo "Schritt 4: Systemd-Konfiguration neu laden..."
sudo systemctl daemon-reload
echo "-> daemon-reload ausgeführt."
echo ""

echo "=== Aufräum-Skript für CIFS-Mount $OBSOLETE_LOCAL_MOUNT_POINT abgeschlossen ==="
echo "Überprüfe den Status der verbleibenden gewünschten Mounts:"
echo "Status für /mnt[YourNASMount]/share (NFS):"
sudo systemctl status '/mnt[YourNASMount]/share' --no-pager
echo ""
echo "Status für /mnt[YourNASMount]/share_nfs (NFS) - falls dieser noch existiert und gewünscht ist:"
# Dieser Name war ja von einem vorherigen Test, der funktioniert hat
sudo systemctl status '/mnt[YourNASMount]/share_nfs' --no-pager > /dev/null 2>&1 # Fehler unterdrücken, falls nicht mehr da
if [ $? -eq 0 ]; then
    echo "(Status für /mnt[YourNASMount]/share_nfs wurde ausgegeben)"
else
    echo "(Keine aktive Unit für /mnt[YourNASMount]/share_nfs gefunden, was ok sein kann)"
fi
echo ""
echo "Status für /mnt/ix4_usb_nfs (NFS):"
sudo systemctl status 'mnt-ix4_usb_nfs.automount' --no-pager

#!/bin/bash

echo "=== Aufräum-Skript: Entferne obsoleten NFS-Mount /mnt/ix4_share_nfs ==="
echo ""

# ---- Konfiguration des zu entfernenden Mounts ----
OBSOLETE_LOCAL_MOUNT_POINT="/mnt/ix4_share_nfs"
OBSOLETE_UNIT_BASENAME="mnt-ix4_share_nfs" # Basisname der Unit-Dateien

OBSOLETE_MOUNT_UNIT_FILE="/etc/systemd/system/${OBSOLETE_UNIT_BASENAME}.mount"
OBSOLETE_AUTOMOUNT_UNIT_FILE="/etc/systemd/system/${OBSOLETE_UNIT_BASENAME}.automount"

# ---- Schritte ----

echo "Schritt 1: Stoppe und deaktiviere Automount-Unit '${OBSOLETE_UNIT_BASENAME}.automount'..."
echo "-> Stoppe Unit (falls aktiv)..."
sudo systemctl stop "${OBSOLETE_UNIT_BASENAME}.automount" > /dev/null 2>&1
echo "-> Deaktiviere Unit (falls enabled)..."
# Deaktivieren über Dateipfad ist robuster
if [ -f "$OBSOLETE_AUTOMOUNT_UNIT_FILE" ]; then
    sudo systemctl disable "$OBSOLETE_AUTOMOUNT_UNIT_FILE"
else
    # Falls Datei nicht da, versuche es über den Namen (wird wahrscheinlich "not found" sagen, ist aber ok)
    sudo systemctl disable "${OBSOLETE_UNIT_BASENAME}.automount" > /dev/null 2>&1
fi
echo "-> Stopp- und Deaktivierungsversuche abgeschlossen."
echo ""

echo "Schritt 2: Lösche die Unit-Dateien für '$OBSOLETE_LOCAL_MOUNT_POINT'..."
if [ -f "$OBSOLETE_MOUNT_UNIT_FILE" ]; then
    sudo rm -f "$OBSOLETE_MOUNT_UNIT_FILE"
    echo "-> '$OBSOLETE_MOUNT_UNIT_FILE' gelöscht."
else
    echo "-> '$OBSOLETE_MOUNT_UNIT_FILE' nicht gefunden."
fi

if [ -f "$OBSOLETE_AUTOMOUNT_UNIT_FILE" ]; then
    sudo rm -f "$OBSOLETE_AUTOMOUNT_UNIT_FILE"
    echo "-> '$OBSOLETE_AUTOMOUNT_UNIT_FILE' gelöscht."
else
    echo "-> '$OBSOLETE_AUTOMOUNT_UNIT_FILE' nicht gefunden."
fi
echo ""

echo "Schritt 3: Lösche den lokalen Mountpunkt-Ordner '$OBSOLETE_LOCAL_MOUNT_POINT' (nur wenn leer)..."
# Zuerst prüfen, ob überhaupt etwas darauf gemountet ist (sollte nicht sein)
if findmnt --mountpoint "$OBSOLETE_LOCAL_MOUNT_POINT" > /dev/null; then
    echo "WARNUNG: '$OBSOLETE_LOCAL_MOUNT_POINT' ist immer noch ein aktiver Mountpunkt laut findmnt!"
    echo "         Bitte manuell unmounten oder Problem untersuchen, bevor der Ordner gelöscht wird."
else
    # Prüfen, ob der Ordner existiert und leer ist, bevor rmdir versucht wird
    if [ -d "$OBSOLETE_LOCAL_MOUNT_POINT" ]; then
        if [ -z "$(ls -A $OBSOLETE_LOCAL_MOUNT_POINT)" ]; then
            sudo rmdir "$OBSOLETE_LOCAL_MOUNT_POINT"
            if [ $? -eq 0 ]; then
                echo "-> Lokaler Mountpunkt-Ordner '$OBSOLETE_LOCAL_MOUNT_POINT' erfolgreich gelöscht."
            else
                echo "FEHLER: Konnte '$OBSOLETE_LOCAL_MOUNT_POINT' nicht löschen (wahrscheinlich nicht leer oder Berechtigungsproblem)."
            fi
        else
            echo "WARNUNG: Lokaler Mountpunkt-Ordner '$OBSOLETE_LOCAL_MOUNT_POINT' ist nicht leer. Wird nicht gelöscht."
            echo "         Inhalt:"
            ls -lA "$OBSOLETE_LOCAL_MOUNT_POINT"
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

echo "=== Aufräum-Skript für $OBSOLETE_LOCAL_MOUNT_POINT abgeschlossen ==="
echo "Überprüfe den Status der verbleibenden gewünschten Mounts:"
echo "Status für /mnt[YourNASMount]/share (NFS):"
sudo systemctl status '/mnt[YourNASMount]/share' --no-pager
echo ""
echo "Status für /mnt/ix4_usb_nfs (NFS):"
sudo systemctl status 'mnt-ix4_usb_nfs.automount' --no-pager # Oder sudo systemctl status /mnt/ix4_usb_nfs

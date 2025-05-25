#!/bin/bash

echo "=== Aktiviere und starte alle gewünschten ix4 NFS Automounts ==="
echo ""

# ---- Definitionen der zu aktivierenden Automounts ----

# 1. Interner Share für Vorta (/mnt[YourNASMount]/share) - verwendet "escaped filenames"
#    Dateipfad zur .automount-Datei (enthält literal '\x2d')
AUTOMOUNT_FILE_SHARE='/etc/systemd/system/mnt-ix4\x2d300d-share.automount'
#    Unit-Name für systemctl Befehle (backslash für Shell escaped)
UNIT_NAME_SHARE='mnt-ix4\x2d300d-share.automount'

# 2. Interner Share, alternativer NFS-Zugriff (/mnt[YourNASMount]/share_nfs) - verwendet "escaped filenames"
AUTOMOUNT_FILE_SHARE_NFS='/etc/systemd/system/mnt-ix4\x2d300d-share_nfs.automount'
UNIT_NAME_SHARE_NFS='mnt-ix4\x2d300d-share_nfs.automount'

# 3. USB Share (/mnt/ix4_usb_nfs) - verwendet normale Dateinamen
AUTOMOUNT_FILE_USB_NFS='/etc/systemd/system/mnt-ix4_usb_nfs.automount'
UNIT_NAME_USB_NFS='mnt-ix4_usb_nfs.automount'

# ---- Funktion zum Aktivieren und Starten einer einzelnen Automount-Unit ----
activate_and_start_automount() {
    local automount_file_path="$1"
    local unit_name="$2"
    local mount_description="$3"

    echo "--- Bearbeite Automount für: $mount_description ($unit_name) ---"

    if [ ! -f "$automount_file_path" ]; then
        echo "FEHLER: Unit-Datei '$automount_file_path' nicht gefunden. Überspringe."
        echo "--------------------------------------------------------------"
        return 1
    fi

    echo "-> Aktiviere über Dateipfad: $automount_file_path"
    sudo systemctl enable "$automount_file_path"
    if [ $? -ne 0 ]; then
        echo "FEHLER: Konnte '$unit_name' nicht aktivieren. Status:"
        sudo systemctl status "$unit_name" --no-pager -n 0
        echo "--------------------------------------------------------------"
        return 1
    else
        echo "-> '$unit_name' erfolgreich aktiviert."
    fi

    echo "-> Starte/Restarte '$unit_name'..."
    sudo systemctl restart "$unit_name"
    if [ $? -ne 0 ]; then
        echo "FEHLER: Konnte '$unit_name' nicht starten/neustarten. Status:"
        sudo systemctl status "$unit_name" --no-pager -n 0
        echo "--------------------------------------------------------------"
        return 1
    else
        echo "-> '$unit_name' erfolgreich gestartet/neugestartet."
    fi

    echo "-> Aktueller Status von '$unit_name':"
    sudo systemctl status "$unit_name" --no-pager -n 20 # Zeige mehr Zeilen für den Status
    echo "--------------------------------------------------------------"
    return 0
}

# ---- Hauptlogik ----
echo "Lade systemd daemon neu..."
sudo systemctl daemon-reload
echo ""

# Bearbeite die Automounts
activate_and_start_automount "$AUTOMOUNT_FILE_SHARE" "$UNIT_NAME_SHARE" "/mnt[YourNASMount]/share (NFS für Vorta)"
echo ""
activate_and_start_automount "$AUTOMOUNT_FILE_SHARE_NFS" "$UNIT_NAME_SHARE_NFS" "/mnt[YourNASMount]/share_nfs (Alternativer NFS Zugriff)"
echo ""
activate_and_start_automount "$AUTOMOUNT_FILE_USB_NFS" "$UNIT_NAME_USB_NFS" "/mnt/ix4_usb_nfs (USB NFS)"
echo ""

echo "=== Alle gewünschten NFS Automounts wurden bearbeitet ==="
echo "Bitte überprüfe die Ausgaben und teste den Zugriff auf die Mountpunkte."
echo "Beispiele:"
echo "ls /mnt[YourNASMount]/share"
echo "ls /mnt[YourNASMount]/share_nfs"
echo "ls /mnt/ix4_usb_nfs"

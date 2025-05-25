#!/bin/bash
NAS_SOURCE_PATH="/mnt[YourNASMount]/share/backup_sdb2_manjaro/timeshift/system"
LOCAL_TIMESSHIFT_PATH="/timeshift"

echo "Prüfe NAS-Mount und Quellpfad..."
# Haupt-NAS-Mount auslösen/prüfen
if ! mountpoint -q /mnt[YourNASMount]/share; then
    echo "NAS-Share unter /mnt[YourNASMount]/share ist nicht gemountet. Versuche Zugriff, um Automount auszulösen..."
    ls /mnt[YourNASMount]/share > /dev/null 2>&1
    sleep 3 # Gib Automount Zeit
    if ! mountpoint -q /mnt[YourNASMount]/share; then
        echo "FEHLER: NAS-Share konnte nicht gemountet werden."
        exit 1
    fi
fi

# Quellpfad prüfen/erstellen
if [ ! -d "$NAS_SOURCE_PATH" ]; then
    echo "Quellpfad $NAS_SOURCE_PATH existiert nicht. Erstelle ihn..."
    sudo mkdir -p "$NAS_SOURCE_PATH"
    if [ $? -ne 0 ]; then
        echo "FEHLER: Konnte Quellpfad nicht erstellen."
        exit 1
    fi
fi

# Prüfen, ob /timeshift schon ein Mountpunkt ist
if mountpoint -q "$LOCAL_TIMESSHIFT_PATH"; then
    echo "$LOCAL_TIMESSHIFT_PATH ist bereits ein Mountpunkt. Überspringe erneutes Mounten."
else
    echo "Führe Bind-Mount aus: $NAS_SOURCE_PATH nach $LOCAL_TIMESSHIFT_PATH"
    sudo mount --bind "$NAS_SOURCE_PATH" "$LOCAL_TIMESSHIFT_PATH"
    if [ $? -ne 0 ]; then
        echo "FEHLER: Bind-Mount fehlgeschlagen."
        exit 1
    fi
fi
echo "Bind-Mount sollte aktiv sein. Du kannst Timeshift jetzt starten."
echo "Nach Timeshift, führe 'sudo umount /timeshift' aus oder nutze ein Unmount-Skript."

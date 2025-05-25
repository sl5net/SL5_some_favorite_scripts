#!/bin/bash

# --- Konfiguration ---
# Beide Pfade zeigen jetzt auf unterschiedliche Mounts DESSELBEN internen NAS-Shares
NFS_MOUNT_PATH="/mnt/ix4_share_nfs"    # NFS-Mount des internen Shares

CIFS_MOUNT_PATH="/mnt[YourNASMount]/share_cifs"       # CIFS-Mount des internen Shares

TEST_FILE_NFS="${NFS_MOUNT_PATH}/performance_test_file_intern_nfs.tmp"
TEST_FILE_CIFS="${CIFS_MOUNT_PATH}/performance_test_file_intern_cifs.tmp"

# Größe der Testdatei für dd (z.B. 512M, 1G)
DD_BLOCK_SIZE="1M"
DD_COUNT="512" # Ergibt 512MB bei 1M Blockgröße

# fio Testparameter
FIO_FILE_SIZE="256M" # Kleinere Datei für fio, da es intensiver ist
FIO_RUNTIME="30s"    # Dauer jedes fio Tests
# Für genauere fio-Tests auf schnellen Systemen, die Caching umgehen sollen:
FIO_DIRECT_IO="0" # Setze auf 1, um OS Caching zu umgehen (kann Performance reduzieren, ist aber "roher")
                  # Bei direct=1 muss die Blockgröße (bs) ein Vielfaches der phys. Blockgröße sein.

# --- Hilfsfunktionen ---
cleanup() {
    echo "Bereinige Testdateien..."
    rm -f "$TEST_FILE_NFS"
    rm -f "$TEST_FILE_CIFS"
    echo "Bereinigung abgeschlossen."
}

check_mount() {
    local path="$1"
    local type="$2"
    if ! findmnt -M "$path" > /dev/null; then
        echo "FEHLER: Der $type-Mountpunkt '$path' scheint nicht gemountet zu sein."
        echo "Bitte stelle sicher, dass der Mount aktiv ist und das Skript die korrekten Pfade verwendet."
        exit 1
    fi
    if [ ! -w "$path" ]; then
        echo "FEHLER: Der $type-Mountpunkt '$path' ist nicht beschreibbar."
        exit 1
    fi
    echo "$type-Mountpunkt '$path' ist gemountet und beschreibbar."
}

# Beim Beenden des Skripts (auch bei Fehler) aufräumen
trap cleanup EXIT

echo "======================================================"
echo "      Performance-Vergleich (Interner NAS-Share): NFS vs. CIFS/SMB"
echo "======================================================"
echo ""
echo "NFS Mount (Interner Share):  $NFS_MOUNT_PATH"
echo "CIFS Mount (Interner Share): $CIFS_MOUNT_PATH"
echo ""

# --- Mounts überprüfen ---
check_mount "$NFS_MOUNT_PATH" "NFS (Intern)"
check_mount "$CIFS_MOUNT_PATH" "CIFS (Intern)"
echo ""

# --- dd Tests ---
echo "------------------------------------------------------"
echo "Starte dd Schreibtests (Blockgröße: $DD_BLOCK_SIZE, Anzahl Blöcke: $DD_COUNT)..."
echo "Cache wird vor jedem Test geleert (sudo benötigt)."
echo "------------------------------------------------------"

echo "[NFS - Intern] Schreibe Testdatei ($((DD_COUNT))MB)..."
sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'
dd_nfs_write_output=$(dd if=/dev/zero of="$TEST_FILE_NFS" bs="$DD_BLOCK_SIZE" count="$DD_COUNT" conv=fdatasync 2>&1)
NFS_WRITE_SPEED=$(echo "$dd_nfs_write_output" | awk '/copied/{print $NF " " $(NF-1)}')
echo "NFS (Intern) Schreibgeschwindigkeit: $NFS_WRITE_SPEED"
sync

echo ""
echo "[CIFS - Intern] Schreibe Testdatei ($((DD_COUNT))MB)..."
sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'
dd_cifs_write_output=$(dd if=/dev/zero of="$TEST_FILE_CIFS" bs="$DD_BLOCK_SIZE" count="$DD_COUNT" conv=fdatasync 2>&1)
CIFS_WRITE_SPEED=$(echo "$dd_cifs_write_output" | awk '/copied/{print $NF " " $(NF-1)}')
echo "CIFS (Intern) Schreibgeschwindigkeit: $CIFS_WRITE_SPEED"
sync

echo ""
echo "------------------------------------------------------"
echo "Starte dd Lesetests..."
echo "Cache wird vor jedem Test geleert (sudo benötigt)."
echo "------------------------------------------------------"

echo "[NFS - Intern] Lese Testdatei..."
sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'
dd_nfs_read_output=$(dd if="$TEST_FILE_NFS" of=/dev/null bs="$DD_BLOCK_SIZE" 2>&1)
NFS_READ_SPEED=$(echo "$dd_nfs_read_output" | awk '/copied/{print $NF " " $(NF-1)}')
echo "NFS (Intern) Lesegeschwindigkeit: $NFS_READ_SPEED"

echo ""
echo "[CIFS - Intern] Lese Testdatei..."
sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'
dd_cifs_read_output=$(dd if="$TEST_FILE_CIFS" of=/dev/null bs="$DD_BLOCK_SIZE" 2>&1)
CIFS_READ_SPEED=$(echo "$dd_cifs_read_output" | awk '/copied/{print $NF " " $(NF-1)}')
echo "CIFS (Intern) Lesegeschwindigkeit: $CIFS_READ_SPEED"
echo ""


# --- fio Tests (falls installiert) ---
if command -v fio > /dev/null; then
    echo "======================================================"
    echo "Starte fio Tests (fortgeschrittener)..."
    echo "Dateigröße: $FIO_FILE_SIZE, Laufzeit pro Test: $FIO_RUNTIME, DirectIO: $FIO_DIRECT_IO"
    echo "Cache wird vor jedem fio-Job-Satz versucht zu leeren (sudo benötigt)."
    echo "======================================================"

    FIO_COMMON_OPTS="--size=${FIO_FILE_SIZE} --runtime=${FIO_RUNTIME} --filename_format='fio_test_intern_${jobname}_${filenum}' --stonewall --group_reporting --output-format=terse --direct=${FIO_DIRECT_IO}"

    # Random Read
    echo ""
    echo "------------------------------------------------------"
    echo "[NFS - Intern] fio Random Read Test..."
    echo "------------------------------------------------------"
    sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'
    fio --name=nfs_intern_randread --rw=randread --bs=4k $FIO_COMMON_OPTS \
        --directory="$NFS_MOUNT_PATH" \
        | awk -F';' '{printf "NFS (Intern) Random Read: %s IOPS, %s BW (KB/s)\n", $8, $7}'

    echo ""
    echo "------------------------------------------------------"
    echo "[CIFS - Intern] fio Random Read Test..."
    echo "------------------------------------------------------"
    sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'
    fio --name=cifs_intern_randread --rw=randread --bs=4k $FIO_COMMON_OPTS \
        --directory="$CIFS_MOUNT_PATH" \
        | awk -F';' '{printf "CIFS (Intern) Random Read: %s IOPS, %s BW (KB/s)\n", $8, $7}'

    # Random Write
    echo ""
    echo "------------------------------------------------------"
    echo "[NFS - Intern] fio Random Write Test..."
    echo "------------------------------------------------------"
    sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'
    fio --name=nfs_intern_randwrite --rw=randwrite --bs=4k $FIO_COMMON_OPTS \
        --directory="$NFS_MOUNT_PATH" \
        | awk -F';' '{printf "NFS (Intern) Random Write: %s IOPS, %s BW (KB/s)\n", $49, $48}'

    echo ""
    echo "------------------------------------------------------"
    echo "[CIFS - Intern] fio Random Write Test..."
    echo "------------------------------------------------------"
    sudo sh -c 'sync; echo 3 > /proc/sys/vm/drop_caches'
    fio --name=cifs_intern_randwrite --rw=randwrite --bs=4k $FIO_COMMON_OPTS \
        --directory="$CIFS_MOUNT_PATH" \
        | awk -F';' '{printf "CIFS (Intern) Random Write: %s IOPS, %s BW (KB/s)\n", $49, $48}'
    echo ""
else
    echo "fio ist nicht installiert. Überspringe fio Tests."
    echo "Für detailliertere Tests, installiere fio: sudo pacman -S fio"
fi

echo "======================================================"
echo "Performance-Tests abgeschlossen."
echo "======================================================"

# Cleanup wird automatisch durch 'trap' aufgerufen
exit 0

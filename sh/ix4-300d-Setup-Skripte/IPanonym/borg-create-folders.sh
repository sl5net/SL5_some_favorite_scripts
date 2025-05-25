#!/bin/bash
# Mit borg-create-folders.sh Sicherstellen, dass NAS gemountet ist
ls /mnt[YourNASMount]/share > /dev/null
# Ordner für Borg-Archive erstellen
NAS_PATH1="/mnt[YourNASMount]/share/backup_borg/"
NAS_PATH2="/mnt[YourNASMount]/share/backup_borg/sdb2/"
NAS_PATH3="/mnt[YourNASMount]/share/backup_borg/sdb2/manjaro/"
NAS_PATH3="/mnt[YourNASMount]/share/backup_borg/sdb2/manjaro/"
NAS_PATH4="/mnt[YourNASMount]/share/backup_borg/sdb2/manjaro/system/"
NAS_PATH5="/mnt[YourNASMount]/share/backup_borg/sdb2/manjaro/home/"
NAS_PATH6="/mnt[YourNASMount]/share/backup_borg/sdb2/manjaro/home/seeh/"
sudo mkdir -p / $NAS_PATH1
sudo mkdir -p / $NAS_PATH2
sudo mkdir -p / $NAS_PATH3
sudo mkdir -p / $NAS_PATH4
sudo mkdir -p / $NAS_PATH5
sudo mkdir -p / $NAS_PATH6



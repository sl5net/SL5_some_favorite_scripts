#!/bin/bash

# sudo-Passwort einmalig am Anfang abfragen, wenn nötig
# Das ist optional, aber praktisch, damit man es nicht für jeden Befehl einzeln eingeben muss,
# wenn die sudo-Zeit abgelaufen ist.
# sudo -v
echo "=== systemctl-automaout-extra.sh start"
echo "=== Systemd-Units für USB-Mount neu laden und starten ==="
sudo systemctl daemon-reload
sudo systemctl stop 'mnt-ix4\x2d300d-usb.automount'
sudo systemctl disable 'mnt-ix4\x2d300d-usb.automount'
sudo systemctl enable 'mnt-ix4\x2d300d-usb.automount'
sudo systemctl start 'mnt-ix4\x2d300d-usb.automount'

echo ""
echo "=== 10 Sekunden warten, bis Automount reagieren kann ==="
sleep 10

echo ""
echo "=== Versuch, auf den Mountpoint zuzugreifen (löst Automount aus) ==="
ls /mnt[YourNASMount]/usb

echo ""
echo "========================================="
echo "=== Status der .automount Unit        ==="
echo "========================================="
# sudo hier hinzufügen, um sicherzustellen, dass alle Infos angezeigt werden
sudo systemctl status 'mnt-ix4\x2d300d-usb.automount'

echo ""
echo "========================================="
echo "=== Status der .mount Unit            ==="
echo "========================================="
# sudo hier hinzufügen
sudo systemctl status 'mnt-ix4\x2d300d-usb.mount'

echo ""
echo "========================================="
echo "=== Logs der .mount Unit              ==="
echo "========================================="
# sudo hier hinzufügen
sudo journalctl -n 50 -xeu 'mnt-ix4\x2d300d-usb.mount'

echo ""
echo "========================================="
echo "=== Kernel-Logs (CIFS/NAS spezifisch) ==="
echo "========================================="
# sudo hier hinzufügen
sudo journalctl -k -n 50 | grep -iE "cifs|ix4|smb" # -n 50 für die letzten 50 Kernel-Meldungen

echo 'sudo journalctl -k -n 100 | grep -iE "cifs|smb|[YourNASip]|ix4|usb"'
sudo journalctl -k -n 100 | grep -iE "cifs|smb|[YourNASip]|ix4|usb"


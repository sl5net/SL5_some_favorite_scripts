#!/bin/bash

MOUNT_UNIT_FILE='/etc/systemd/system/mnt-ix4\x2d300d-share.mount'
AUTOMOUNT_UNIT_NAME='mnt-ix4\x2d300d-share.automount'
MOUNT_POINT='/mnt[YourNASMount]/share'

# Basis-Optionen, die wir beibehalten wollen
BASE_OPTIONS="guest,uid=1000,gid=1001,iocharset=utf8"

# Zu testende Optionen-Kombinationen (hier als Beispiel, wir können das erweitern)
# Jedes Element ist ein String, der an BASE_OPTIONS angehängt wird
# Format: ",vers=X.X,sec=YYYY" oder nur ",vers=X.X"
declare -a TEST_OPTIONS_ARRAY=(
    ",vers=1.0"
    ",vers=1.0,sec=none"
    ",vers=1.0,sec=ntlm"
)

# Originale Options-Zeile sichern (sehr rudimentär, nur für diesen Testlauf)
# Besser wäre, die Datei vorher manuell zu sichern!
ORIGINAL_OPTIONS_LINE=$(grep "^Options=" "$MOUNT_UNIT_FILE")

for test_opt_suffix in "${TEST_OPTIONS_ARRAY[@]}"; do
    current_options="${BASE_OPTIONS}${test_opt_suffix}"
    echo "---------------------------------------------------------------------"
    echo "TESTE MIT OPTIONEN: $current_options"
    echo "---------------------------------------------------------------------"

    # .mount Datei modifizieren (vorsichtig!)
    # Dieses sed-Kommando ersetzt die gesamte Zeile, die mit "Options=" beginnt
    sudo sed -i "s|^Options=.*|Options=${current_options}|" "$MOUNT_UNIT_FILE"
    echo "Inhalt der .mount Datei nach Änderung:"
    grep "^Options=" "$MOUNT_UNIT_FILE"
    echo ""

    echo "Führe 'sudo systemctl daemon-reload' aus..."
    sudo systemctl daemon-reload
    echo "Done."
    echo ""

    echo "Starte '$AUTOMOUNT_UNIT_NAME' neu..."
    sudo systemctl restart "$AUTOMOUNT_UNIT_NAME"
    if [ $? -ne 0 ]; then
        echo "FEHLER: Neustart von $AUTOMOUNT_UNIT_NAME fehlgeschlagen."
        # Hier könnten wir den Status der .automount Unit ausgeben
        systemctl status "$AUTOMOUNT_UNIT_NAME"
        continue # Nächste Option testen
    fi
    echo "Done."
    echo ""

    echo "Warte 5 Sekunden..."
    sleep 5
    echo ""

    echo "Versuche Zugriff auf '$MOUNT_POINT' mit 'ls'..."
    ls "$MOUNT_POINT" > /dev/null 2>&1 # Ausgabe unterdrücken, nur Exit-Code prüfen
    ls_exit_code=$?

    if [ $ls_exit_code -eq 0 ]; then
        echo "*********************************************************************"
        echo "ERFOLG! Zugriff auf '$MOUNT_POINT' möglich mit Optionen:"
        echo "$current_options"
        echo "Inhalt von '$MOUNT_POINT':"
        ls -l "$MOUNT_POINT"
        echo "*********************************************************************"
        # Optional: Skript hier beenden oder nach weiteren funktionierenden fragen
        read -p "Erste funktionierende Konfiguration gefunden. Weitere testen? (j/N): " continue_testing
        if [[ "$continue_testing" != "j" && "$continue_testing" != "J" ]]; then
            break
        fi
    else
        echo "FEHLGESCHLAGEN: 'ls $MOUNT_POINT' gab Exit-Code $ls_exit_code."
        echo "Status von '${AUTOMOUNT_UNIT_NAME%.automount}.mount':" # .automount Suffix entfernen für .mount Unit
        systemctl status "${AUTOMOUNT_UNIT_NAME%.automount}.mount" --no-pager -n 0 # -n 0 für nur die Zusammenfassung
        echo ""
        echo "Journal für '${AUTOMOUNT_UNIT_NAME%.automount}.mount' (letzte 10 Zeilen):"
        journalctl -n 10 -xeu "${AUTOMOUNT_UNIT_NAME%.automount}.mount" --no-pager
    fi
    echo ""
    read -p "Drücke Enter, um mit der nächsten Option fortzufahren..."
done

# Originale Options-Zeile wiederherstellen (sehr rudimentär)
echo "Stelle ursprüngliche Options-Zeile (falls gesichert) wieder her..."
if [ ! -z "$ORIGINAL_OPTIONS_LINE" ]; then
    sudo sed -i "s|^Options=.*|${ORIGINAL_OPTIONS_LINE}|" "$MOUNT_UNIT_FILE"
    echo "Ursprüngliche Options-Zeile sollte wiederhergestellt sein."
    grep "^Options=" "$MOUNT_UNIT_FILE"
else
    echo "Keine ursprüngliche Options-Zeile gesichert."
fi

echo "Alle Tests abgeschlossen."

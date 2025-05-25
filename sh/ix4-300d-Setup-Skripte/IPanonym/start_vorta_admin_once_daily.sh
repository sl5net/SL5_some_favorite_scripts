#!/bin/bash
FLAG_DIR="$HOME/.local/share/vorta_admin_start_flags"
FLAG_FILE="$FLAG_DIR/started_today_$(date +%Y-%m-%d).flag"

# Erstelle das Flag-Verzeichnis, falls es nicht existiert
mkdir -p "$FLAG_DIR"

# Prüfe, ob die Flag-Datei für heute schon existiert
if [ -f "$FLAG_FILE" ]; then
    echo "Vorta wurde heute bereits als Admin gestartet (Flag gefunden: $FLAG_FILE)."
    # Optional: Hier könntest du prüfen, ob der Vorta-Prozess als root noch läuft
    # und ihn ggf. in den Vordergrund holen, aber das ist komplexer.
    # Fürs Erste starten wir es einfach nicht erneut.
else
    echo "Starte Vorta als Admin..."
    # pkexec vorta # Bevorzugt, wenn Policy existiert
    # ODER
    # sudo -H vorta # -H setzt HOME auf /root
    # ODER
    # kdesu vorta # Für KDE
    # gksudo vorta # Älter, für GTK
    # Wähle die Methode, die auf deinem System am besten für grafische Sudo-Anwendungen funktioniert
    # und die du sonst auch verwendest, um Vorta als Root zu starten.
    # Einfach 'sudo vorta' kann manchmal Probleme mit dem X-Server oder DBus machen.
    # Eine bessere Methode für grafische Anwendungen mit Root-Rechten ist oft pkexec,
    # falls eine Polkit-Policy für Vorta existiert oder erstellt wird.
    # Wenn 'sudo vorta' für dich bisher gut funktioniert hat, kannst du es dabei belassen.

    sudo vorta # Ersetze dies ggf. durch die passendere Methode (siehe Kommentar oben)

    if [ $? -eq 0 ]; then
        echo "Vorta als Admin gestartet. Setze Flag-Datei: $FLAG_FILE"
        touch "$FLAG_FILE"
        # Optional: Alte Flag-Dateien löschen (z.B. älter als 7 Tage)
        find "$FLAG_DIR" -name "*.flag" -mtime +7 -delete
    else
        echo "Fehler beim Starten von Vorta als Admin."
    fi
fi

exit 0

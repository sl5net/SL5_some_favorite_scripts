#!/bin/bash

# --- Konfiguration ---
TIMESSHIFT_PARTITION="/timeshift" # Die Partition, auf der Timeshift seine Snapshots speichert (z.B. "/" oder "/mnt/timeshift_local_partition")
THRESHOLD_GB=10          # Schwellenwert in GB. Wenn weniger frei ist, wird gehandelt.
NOTIFY_USER="seeh"       # Benutzer, der Desktop-Benachrichtigungen erhalten soll (Anpassen!)
LOG_FILE="/var/log/timeshift_space_monitor.log" # Logdatei für Aktionen

# --- Ende Konfiguration ---

# Funktion zum Loggen und optionalen Anzeigen auf der Konsole
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG_FILE" >/dev/null
    # echo "$1" # Optional: Auch auf Konsole ausgeben, wenn interaktiv gestartet
}

# Funktion für Desktop-Benachrichtigung
send_notification() {
    local message="$1"
    # Versucht, als der angegebene Benutzer eine Desktop-Benachrichtigung zu senden
    # Funktioniert am besten, wenn der Benutzer eingeloggt ist und einen Notification-Daemon hat
    if id "$NOTIFY_USER" &>/dev/null && ps -u "$NOTIFY_USER" -f | grep -q '[X]org|[w]ayland'; then
        sudo -u "$NOTIFY_USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u $NOTIFY_USER)/bus" \
        notify-send -u critical -i dialog-warning "Timeshift Speicherplatz-Warnung" "$message"
    fi
    log_action "Desktop-Benachrichtigung gesendet: $message"
}

# Freien Speicherplatz auf der Timeshift-Partition in GB ermitteln
# df gibt Blöcke in 1K aus, daher /1024/1024 für GB
# awk filtert die Zeile für die Partition und nimmt die 4. Spalte (Available)
FREE_SPACE_KB=$(df -k "$TIMESSHIFT_PARTITION" | awk 'NR==2 {print $4}')
FREE_SPACE_GB=$((FREE_SPACE_KB / 1024 / 1024))

log_action "Aktueller freier Speicherplatz auf '$TIMESSHIFT_PARTITION': ${FREE_SPACE_GB}GB. Schwellenwert: ${THRESHOLD_GB}GB."

if [ "$FREE_SPACE_GB" -lt "$THRESHOLD_GB" ]; then
    log_action "WARNUNG: Freier Speicherplatz ($FREE_SPACE_GB GB) ist unter dem Schwellenwert von $THRESHOLD_GB GB!"
    send_notification "Freier Speicher auf $TIMESSHIFT_PARTITION ist nur noch $FREE_SPACE_GB GB! Timeshift-Aktionen werden durchgeführt."

    # 1. Ältesten Timeshift-Snapshot löschen
    # Timeshift listet Snapshots auf, der älteste ist meist oben oder unten.
    # Wir nehmen an, der erste in der Liste (nach Header) ist der älteste "ondemand", "daily" etc.
    # Dies ist eine Annahme und könnte je nach Namensschema variieren!
    # Sicherer wäre es, Snapshots mit Zeitstempel im Namen zu haben und danach zu sortieren.
    # Beispiel: timeshift --list zeigt etwas wie:
    # Num    Name                      Tags   Description
    # ------------------------------------------------------------------------------
    # 0    > 2023-05-19_10-00-00 O D B  Auto (Daily)
    # 1    > 2023-05-20_10-00-00 O D B  Auto (Daily)   <-- Dieser wäre neuer

    # Wir versuchen, den ältesten Snapshot zu finden und zu löschen.
    # Diese Methode ist nicht perfekt, da die Sortierung von `timeshift --list` nicht garantiert ist.
    # Es ist sicherer, wenn du ein Namensschema verwendest, das eine Sortierung erlaubt.
    # Für eine robustere Lösung bräuchte man eine bessere Methode, den "ältesten" zu identifizieren.
    # Als einfache Annahme: Der erste Snapshot in der Liste (außer dem aktuellsten, falls speziell markiert).
    # Diese Logik ist komplexer und erfordert Parsing der `timeshift --list` Ausgabe.

    # Einfacherer, aber weniger präziser Ansatz für dieses Skript:
    # Lösche *alle* Snapshots außer dem neuesten X (hier nicht implementiert, da riskant ohne genaue Logik)
    # ODER lösche einfach den mit dem ältesten Datum im Namen (wenn das Namensschema das hergibt)

    # Für dieses Skript als Beispiel: Lösche den Snapshot, der am längsten zurückliegt, basierend auf dem Namen
    # (funktioniert nur, wenn das Standard-Datumsformat im Snapshot-Namen ist YYYY-MM-DD_HH-MM-SS)
    OLDEST_SNAPSHOT=$(sudo timeshift --list | grep -Eo '[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2}-[0-9]{2}' | sort | head -n 1)

    if [ -n "$OLDEST_SNAPSHOT" ]; then
        log_action "Versuche, ältesten Snapshot '$OLDEST_SNAPSHOT' zu löschen..."
        sudo timeshift --delete --snapshot "$OLDEST_SNAPSHOT"
        if [ $? -eq 0 ]; then
            log_action "Snapshot '$OLDEST_SNAPSHOT' erfolgreich gelöscht."
            send_notification "Ältester Timeshift-Snapshot '$OLDEST_SNAPSHOT' wurde gelöscht, um Platz zu schaffen."
        else
            log_action "FEHLER beim Löschen des Snapshots '$OLDEST_SNAPSHOT'."
            send_notification "FEHLER beim Löschen des ältesten Timeshift-Snapshots!"
        fi
    else
        log_action "Kein Snapshot zum automatischen Löschen gefunden (oder Namensschema nicht erkannt)."
    fi

    # 2. Timeshift Systemd Timer/Cronjob deaktivieren
    # Timeshift verwendet typischerweise einen Cronjob in /etc/cron.* oder einen Systemd Timer
    # Finde heraus, was bei dir aktiv ist:
    # `ls /etc/cron.*/timeshift*`
    # `systemctl list-timers | grep timeshift`

    # Beispiel für Systemd Timer (Anpassen, falls dein Timer anders heißt!)
    TIMESSHIFT_TIMER_UNIT="timeshift-hourly.timer" # Beispiel, muss angepasst werden!
                                                  # Oder timeshift-daily.timer etc.
                                                  # Finde den korrekten Namen mit `systemctl list-timers`

    if systemctl --quiet is-active "$TIMESSHIFT_TIMER_UNIT"; then
        log_action "Deaktiviere Timeshift Systemd Timer '$TIMESSHIFT_TIMER_UNIT'..."
        sudo systemctl stop "$TIMESSHIFT_TIMER_UNIT"
        sudo systemctl disable "$TIMESSHIFT_TIMER_UNIT" # Optional: Dauerhaft deaktivieren bis manuell reaktiviert
        log_action "Timeshift Timer '$TIMESSHIFT_TIMER_UNIT' gestoppt (und ggf. deaktiviert)."
        send_notification "Timeshift Timer '$TIMESSHIFT_TIMER_UNIT' wurde gestoppt, bis mehr Speicherplatz verfügbar ist."
    elif [ -f "/etc/cron.hourly/timeshift-hourly" ] || [ -f "/etc/cron.daily/timeshift-daily" ]; then # Beispiel für Cron
        # Cronjobs zu deaktivieren ist umständlicher, oft durch Umbenennen oder Ändern der Rechte.
        # Hier nur ein Log-Eintrag als Platzhalter.
        log_action "Timeshift scheint über Cron gesteuert zu werden. Manuelle Deaktivierung des Cronjobs nötig."
        send_notification "Timeshift Cronjob muss manuell deaktiviert werden!"
    else
        log_action "Kein aktiver Timeshift Systemd Timer oder bekannter Cronjob gefunden, der automatisch deaktiviert werden könnte."
    fi
else
    log_action "Genügend freier Speicherplatz vorhanden. Keine Aktion erforderlich."
    # Optional: Wenn der Timer vorher deaktiviert wurde, hier wieder aktivieren:
    # if ! systemctl --quiet is-active "$TIMESSHIFT_TIMER_UNIT" && systemctl --quiet is-enabled "$TIMESSHIFT_TIMER_UNIT"; then
    #     log_action "Reaktiviere Timeshift Systemd Timer '$TIMESSHIFT_TIMER_UNIT'..."
    #     sudo systemctl start "$TIMESSHIFT_TIMER_UNIT"
    # fi
fi

exit 0

#!/bin/bash

# --- Konfiguration (kann angepasst werden) ---
PROJECT_ROOT=$(pwd) # Annahme: Skript wird vom Projekt-Root ausgeführt



get_target_php_version() {
    local php_version_from_df
    local final_php_version_for_tag="unknown"

    # Priorität 1: Versuche, Version aus Dockerfile zu lesen
    php_version_from_df=$(get_php_version_from_dockerfile) # get_php_version_from_dockerfile gibt nur die Version oder nichts aus
    if [ $? -eq 0 ] && [ -n "$php_version_from_df" ]; then
        echo "INFO: PHP-Version aus Dockerfile extrahiert: $php_version_from_df" >&2 # Info nach STDERR
        final_php_version_for_tag="$php_version_from_df"
        echo "$final_php_version_for_tag" # Reine Version nach STDOUT
        return 0
    else
        echo "INFO: PHP-Version konnte nicht aus Dockerfile extrahiert werden. Versuche Git-basierte Erkennung..." >&2 # Info nach STDERR
    fi

    # Priorität 2: Git-basierte Erkennung
    local current_ref
    current_ref=$(git rev-parse --abbrev-ref HEAD)

    if [[ "$current_ref" != "HEAD" ]]; then # Wir sind auf einem Branch
        if [[ "$current_ref" == *php*compat ]]; then
            final_php_version_for_tag=$(echo "$current_ref" | grep -oP 'php\K[0-9]+(?=-compat)')
        elif [[ "$current_ref" == *php[0-9]* ]]; then
             final_php_version_for_tag=$(echo "$current_ref" | grep -oP 'php\K[0-9]+')
        fi
    else # Wir sind im DETACHED HEAD Zustand
        echo "INFO: HEAD ist detached. Versuche PHP-Version aus Branch-Namen zu ermitteln..." >&2 # Info nach STDERR
        local branches_containing_commit
        branches_containing_commit=$(git branch -a --contains HEAD)

        final_php_version_for_tag=$(echo "$branches_containing_commit" | grep -oP 'php\K[0-9]+(?=-compat)' | head -n 1)

        if [[ -z "$final_php_version_for_tag" ]]; then
            final_php_version_for_tag=$(echo "$branches_containing_commit" | grep -oP '/php\K[0-9]+' | head -n 1)
        fi
    fi

    if [[ -n "$final_php_version_for_tag" && "$final_php_version_for_tag" != "unknown" ]]; then
        echo "INFO: PHP-Version aus Git-Kontext (Branch/Commit) ermittelt: $final_php_version_for_tag" >&2 # Info nach STDERR
        echo "$final_php_version_for_tag" | sed 's/\.//g' # Reine Version nach STDOUT
    else
        echo "WARNUNG: Konnte PHP-Version weder aus Dockerfile noch aus Git-Kontext bestimmen." >&2 # Warnung nach STDERR
        if [[ "$current_ref" == "HEAD" ]]; then # Diese Info kann auch nach STDERR
             echo "Branches, die diesen Commit (Detached HEAD) enthalten:" >&2
             echo "$branches_containing_commit" >&2
        fi
        echo "unknown" # "unknown" nach STDOUT
    fi
}


# Funktion, um die PHP-Version aus der FROM-Zeile des Dockerfiles zu extrahieren
get_php_version_from_dockerfile() {
    local dockerfile_path="./Dockerfile" # Annahme: Dockerfile im aktuellen Verzeichnis
    local php_version_raw=""
    local php_version_tag_format=""

    if [ ! -f "$dockerfile_path" ]; then
        # echo "DEBUG: Dockerfile nicht gefunden unter $dockerfile_path" >&2
        return 1 # Dockerfile nicht gefunden
    fi

    # Durchsuche die ersten ~20 Zeilen (oder das ganze File, wenn es klein ist)
    # Ignoriere Kommentarzeilen und Leerzeilen
    # Suche nach "FROM php:..." (Groß-/Kleinschreibung für FROM ignorieren)
    php_version_raw=$(head -n 20 "$dockerfile_path" | grep -i -E '^[[:space:]]*FROM[[:space:]]+php:[0-9]+\.[0-9]+' | \
                      sed -n -E 's/^[[:space:]]*FROM[[:space:]]+php:([0-9]+\.[0-9]+(\.[0-9]+)?).*/\1/pI' | \
                      head -n 1) # Nimm den ersten Treffer

    if [ -n "$php_version_raw" ]; then
        # Konvertiere z.B. "8.1" oder "8.1.2" zu "81", "7.4" zu "74", "5.6" zu "56"
        # Nimmt die erste und zweite Zahl der Version (X.Y)
        local major_version=$(echo "$php_version_raw" | cut -d. -f1)
        local minor_version=$(echo "$php_version_raw" | cut -d. -f2)

        if [[ -n "$major_version" && -n "$minor_version" ]]; then
            php_version_tag_format="${major_version}${minor_version}"
            echo "$php_version_tag_format"
            return 0 # Erfolg
        else
            # echo "DEBUG: Konnte Major/Minor Version nicht aus '$php_version_raw' extrahieren." >&2
            return 1 # Fehler bei der Konvertierung
        fi
    else
        # echo "DEBUG: Keine passende FROM php:X.Y Zeile im Dockerfile gefunden." >&2
        return 1 # Keine passende Zeile gefunden
    fi
}

# Funktion, um den Docker-Image-Namen zu generieren
get_docker_image_name() {
    local php_version_short
    php_version_short=$(get_target_php_version)

    if [[ "$php_version_short" == "unknown" || -z "$php_version_short" ]]; then
        echo "pcf-error-unknown-php-version" # Sicherer Fallback-Name
        echo "WARNUNG: PHP-Version konnte nicht ermittelt werden. Verwende Fallback-Image-Namen." >&2
        return 1
    fi

    # Beispiel: php_version_short könnte "56", "74", "8", "81", "83" sein
    # Das Image soll heißen: sl5-preg-contentfinder-php<version>-dev:latest
    echo "sl5-preg-contentfinder-php${php_version_short}-dev:latest"
}



# Funktion zum Prüfen, ob Docker läuft
check_docker_running() {
    if ! docker ps > /dev/null 2>&1; then
        # Docker ist nicht erreichbar oder läuft nicht
        echo "ERR: Docker not run" # Kurze Fehlermeldung

        # Prüfen, ob der Docker-Dienst über systemctl gestartet werden kann
        if command -v systemctl &> /dev/null && systemctl list-units --full -all | grep -q 'docker.service'; then
            echo "  -> Try: sudo systemctl start docker"
        # Prüfen, ob der Docker-Dienst über 'service' gestartet werden kann (für ältere Systeme)
        elif command -v service &> /dev/null && (service docker status > /dev/null 2>&1 || service --status-all | grep -q docker); then
            echo "  -> Try: sudo service docker start"
        # Wenn keine bekannte Startmethode für einen existierenden Dienst gefunden wurde:
        else
            # Spezifische Hinweise für Manjaro (oder generell Arch-basierte Systeme)
            # Zuerst prüfen, ob Docker überhaupt installiert ist (einfacher Test)
            if command -v docker &> /dev/null; then
                echo "  Docker seems installed, but the service isn't recognized by systemctl/service."
                echo "  On Manjaro:"
                echo "sudo systemctl start docker"
            else
                echo "  Docker command not found. Docker might not be installed."
                echo "  On Manjaro:"
                echo "sudo pacman -Syu docker"
                echo "sudo systemctl start docker"
                echo "  And add your user to the 'docker' group (requires logout/login):"
                echo "sudo usermod -aG docker \$USER"
            fi
        fi
        echo "--------------------------------------------------------------------"
        echo "" # Leerzeile für bessere Lesbarkeit
        return 1 # Fehler signalisieren
    fi
    return 0 # Erfolg, Docker läuft
}


build_image() {
    if ! check_docker_running; then
        # check_docker_running hat bereits eine ausführliche Meldung ausgegeben
        return 1
    fi

    local image_name
    # Um mehrfache Ausgaben von get_target_php_version zu vermeiden, speichern wir das Ergebnis
    local php_version_details # Enthält die volle Ausgabe von get_target_php_version
    php_version_details=$(get_target_php_version)
    local actual_php_version # Enthält nur die reine Versionsnummer für den Tag
    # Extrahieren der reinen Versionsnummer aus den Details (vereinfacht, nimmt die letzte Zeile der Ausgabe von get_target_php_version)
    actual_php_version=$(echo "$php_version_details" | tail -n 1)


    if [[ "$actual_php_version" == "unknown" || -z "$actual_php_version" ]]; then
        echo "Ermittelte PHP-Zielversion: $php_version_details" # Zeige die volle Debug-Info
        echo "Konnte PHP-Version nicht bestimmen. Abbruch des Builds."
        return 1
    fi

    image_name=$(get_docker_image_name) # Ruft get_target_php_version intern erneut auf,
                                        # aber wir brauchen den Namen hier.
                                        # Die Ausgabe von get_target_php_version wird hier nicht direkt angezeigt.

    echo "Aktueller Git-Stand: $(git rev-parse --short HEAD) auf Ref: $(git symbolic-ref -q --short HEAD || git rev-parse HEAD)"
    echo "Ermittelte PHP-Zielversion (Details): $php_version_details"
    echo "Baue Docker-Image als: $image_name"

    if [[ "$image_name" == "pcf-error-unknown-php-version" ]]; then
        echo "Fehler: Image-Name konnte nicht korrekt generiert werden (wegen unbekannter PHP-Version)."
        echo "Abbruch des Builds."
        return 1
    fi

    if docker build -t "$image_name" . ; then
        echo "Image $image_name erfolgreich gebaut."
    else
        echo "Fehler beim Bauen des Images $image_name."
        return 1
    fi
}

run_tests() {
    if ! check_docker_running; then
        return 1
    fi

    local image_name
    local php_version_details
    php_version_details=$(get_target_php_version)
    local actual_php_version
    actual_php_version=$(echo "$php_version_details" | tail -n 1)

    if [[ "$actual_php_version" == "unknown" || -z "$actual_php_version" ]]; then
        echo "Ermittelte PHP-Zielversion: $php_version_details"
        echo "Konnte PHP-Version nicht bestimmen. Abbruch der Tests."
        return 1
    fi

    image_name=$(get_docker_image_name)

    if [[ "$image_name" == "pcf-error-unknown-php-version" ]]; then
        echo "Fehler: Image-Name konnte nicht korrekt generiert werden (wegen unbekannter PHP-Version)."
        echo "Abbruch der Tests."
        return 1
    fi

    echo "Führe Tests mit Image $image_name aus..."
    docker run --rm -v "${PROJECT_ROOT}:/app" "$image_name" php /usr/local/bin/phpunit /app/tests/PHPUnit/Callback_Emty_Test.php
}

cleanup_docker() {
    if ! check_docker_running; then
        # Wenn Docker hier nicht gestartet werden kann, ist Prune eh nicht möglich
        echo "INFO: Docker nicht gestartet, Aufräumen nicht möglich oder nicht nötig."
        return 1 # Oder 0, da die Aktion "nichts tun" war.
    fi

    echo "Räume ungenutzte Docker-Ressourcen auf..."
    docker system prune -af
    echo "Docker-Aufräumarbeiten abgeschlossen."
}

# Hilfefunktion definieren, um Wiederholungen zu vermeiden
show_help() {
    echo "Verwendung: $0 {build|test|cleanup|name|php_version}"
    echo ""
    echo "Aktionen:"
    echo "  build        Baut das Docker-Image basierend auf dem aktuellen Git-Stand."
    echo "               Verwendet das Dockerfile im aktuellen Verzeichnis."
    echo "  test         Führt die PHPUnit-Tests im Docker-Container aus."
    echo "               Mountet das aktuelle Verzeichnis nach /app im Container."
    echo "  cleanup      Räumt ungenutzte Docker-Ressourcen auf (entspricht 'docker system prune -af')."
    echo "  name         Zeigt den ermittelten Docker-Image-Namen an (für Debugging)."
    echo "  php_version  Zeigt die ermittelte PHP-Version an (für Debugging)."
    echo ""
    echo "Das Skript muss aus dem Projekt-Root-Verzeichnis ('SL5_preg_contentFinder') aufgerufen werden."
    echo "Beispiel: ../$(basename "$0") build"
}

# Wenn keine Argumente übergeben wurden, zeige die Hilfe an und beende
if [ $# -eq 0 ]; then
    echo "Fehler: Keine Aktion angegeben."
    show_help
    exit 1
fi

# Verarbeite das erste Argument
case "$1" in
    build)
        build_image
        ;;
    test)
        run_tests
        ;;
    cleanup)
        cleanup_docker
        ;;
    name)
        # Nur den Namen ausgeben, nicht die Fehlermeldung von get_docker_image_name, falls Version unbekannt
        img_name=$(get_docker_image_name)
        if [[ "$?" -eq 0 && "$img_name" != "pcf-error-unknown-php-version" ]]; then
            echo "$img_name"
        else
            # Fehlermeldung wird bereits von get_docker_image_name oder get_target_php_version ausgegeben
            # Hier könnten wir zusätzlich den Hilfetext anzeigen oder einfach mit Fehler beenden
            echo "Fehler beim Ermitteln des Image-Namens. Überprüfen Sie die PHP-Version." >&2
            exit 1
        fi
        ;;
    php_version)
        # Nur die Version ausgeben
        php_ver=$(get_target_php_version)
        if [[ "$php_ver" != "unknown" && -n "$php_ver" ]]; then
            echo "$php_ver"
        else
            # Fehlermeldung wird bereits von get_target_php_version ausgegeben
            echo "Fehler beim Ermitteln der PHP-Version." >&2
            exit 1
        fi
        ;;
    help|--help|-h) # explizite Hilfeoption
        show_help
        exit 0
        ;;
    *) # Ungültige Aktion
        echo "Fehler: Ungültige Aktion '$1'."
        show_help
        exit 1
        ;;
esac

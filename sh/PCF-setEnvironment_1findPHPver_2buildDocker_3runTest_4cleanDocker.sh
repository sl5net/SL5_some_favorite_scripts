#!/bin/bash

clear

# --- Konfiguration ---
RELATIVE_PROJECT_PATH="projects/php/SL5_preg_contentFinder"
TARGET_PROJECT_DIR="$HOME/$RELATIVE_PROJECT_PATH"
# Pfad zum Repository, das dieses Skript enthält, relativ zu $HOME
# WICHTIG: Diesen Pfad an deine Struktur anpassen, falls nötig!
PATH_TO_SCRIPT_REPO_FROM_HOME="projects/SL5_some_favorite_scripts/sh"
SCRIPT_FULL_PATH="$0"
SCRIPT_NAME=$(basename "$0")
SCRIPT_ARGS_STRING="$*"

# Für die Anzeige Pfade mit Tilde aufbereiten
display_target_dir=$(echo "$TARGET_PROJECT_DIR" | sed "s|^$HOME|~|")


# Prüfen, ob das Ziel-Projektverzeichnis existiert
if [ ! -d "$TARGET_PROJECT_DIR" ]; then
    echo "FEHLER: Das Ziel-Projektverzeichnis '$display_target_dir' wurde nicht gefunden." >&2
    echo "Bitte überprüfen Sie den Pfad im Skript (RELATIVE_PROJECT_PATH) oder erstellen Sie das Verzeichnis." >&2
    exit 1
fi

# Logik für Verzeichniswechsel und Neustart-Hinweis
if [ "$(pwd)" != "$TARGET_PROJECT_DIR" ]; then
    # Der Neustart-Hinweis wird nur ausgegeben, wenn man NICHT im Zielverzeichnis ist.
    # Er verwendet $SCRIPT_NAME und $PATH_TO_SCRIPT_REPO_FROM_HOME
    echo "cd $display_target_dir ; ~/$PATH_TO_SCRIPT_REPO_FROM_HOME/$SCRIPT_NAME $SCRIPT_ARGS_STRING" >&2
    echo "" >&2 # Leerzeile nach dem Befehlsvorschlag

    cd "$TARGET_PROJECT_DIR" || { echo "FEHLER: Konnte nicht in '$display_target_dir' wechseln."; exit 1; }
fi

# Für die interne Logik immer den absoluten Pfad verwenden
PROJECT_ROOT=$(pwd)



show_help() {
    # SCRIPT_NAME, TARGET_PROJECT_DIR, PATH_TO_SCRIPT_REPO_FROM_HOME sind oben global definiert
    # display_target_dir für die Anzeige des Projektpfades mit Tilde

    # Konstruiere den Pfad, der in der Funktion/Alias verwendet werden soll (mit $HOME für korrekte Expansion)
    # Dieser Pfad wird dann in den echo-Befehlen verwendet.
    local script_call_path_for_function="\$HOME/$PATH_TO_SCRIPT_REPO_FROM_HOME/$SCRIPT_NAME" # Wichtig: \$HOME damit $HOME literarisch ausgegeben wird

    echo "Verwendung: $SCRIPT_NAME {b|t|c|n|p|h}"
    echo ""
    echo "Dieses Skript verwaltet die Docker-Umgebung für das Projekt:"
    echo "  $display_target_dir"
    echo ""
        echo "Aktionen (erster Buchstabe genügt):"
    echo "  b (build)        Baut das Docker-Image basierend auf dem aktuellen Git-Stand im Zielprojekt."
    echo "  t (test)         Führt die PHPUnit-Tests im Docker-Container aus (Code aus Zielprojekt)."
    echo "  c (cleanup)      Räumt ungenutzte Docker-Ressourcen auf (docker system prune -af)."
    echo "                   Tipp: Mit 'docker system df' oder der Aktion 's' (status) können Sie den Speicherverbrauch prüfen."
    echo "  bcp              Build Cache Prune: Löscht NUR den Docker Build-Cache."
    echo "                   Nützlich, um sicherzustellen, dass der nächste Build frisch ist."
    echo "                   Entspricht 'docker builder prune -af'." # KORRIGIERT

    echo ""
    echo "Hinweise zu Docker Prune Befehlen:"
    echo "  - 'docker system prune -af' (Aktion 'c'): Ist sehr gründlich. Es entfernt alles, was Docker"
    echo "    als 'ungenutzt' betrachtet. Das ist meistens sicher, kann aber manchmal auch Images löschen,"
    echo "    die man vielleicht noch für einen schnellen Wechsel behalten wollte, wenn sie gerade"
    echo "    von keinem Container verwendet werden."
    echo "  - 'docker builder prune -af' (Aktion 'bcp' oder Teil von 'b p'): Konzentriert sich nur auf den"
    echo "    Build-Cache. Das ist oft nützlich, um Build-Probleme zu lösen oder Speicher freizugeben,"
    echo "    ohne andere Docker-Ressourcen zu beeinflussen."
    echo "  - EMPFEHLUNG: Verwenden Sie 's' (Status), um zu sehen, was aufgeräumt werden könnte."
    echo "    Beginnen Sie bei Speicherproblemen vielleicht erst mit 'bcp' und nur bei Bedarf mit 'c'."
    echo ""

    echo "  n (name)         Zeigt den ermittelten Docker-Image-Namen an."
    echo "  p (php_version)  Zeigt die ermittelte PHP-Version an."
    echo "  s (status)       Zeigt den aktuellen Docker-Speicherverbrauch an (docker system df)." # NEUE AKTION
    echo "  h (help)         Zeigt diese Hilfe an."    echo ""
    echo "Das Skript stellt sicher, dass es im Kontext des Ziel-Projektverzeichnisses arbeitet."
    echo ""
    echo "TIPP: Für einen bequemeren Aufruf können Sie eine Funktion 'pcf' einrichten."
    echo "      Das Skript wird weiterhin intern in das Projektverzeichnis '$display_target_dir' wechseln."
    echo ""
    echo "  Für Bash (in ~/.bashrc oder ~/.bash_profile einfügen):"
    echo "    pcf() { \"${script_call_path_for_function}\" \"\$@\"; }" # Zeigt \$HOME/... und \$@
    echo "    # Danach 'source ~/.bashrc' (oder .bash_profile) oder neues Terminal öffnen."
    echo ""
    echo "  Für Zsh (in ~/.zshrc einfügen):"
    echo "    pcf() { \"${script_call_path_for_function}\" \"\$@\"; }" # Zeigt \$HOME/... und \$@
    echo "    # Danach 'source ~/.zshrc' oder neues Terminal öffnen."
    echo ""
    echo "  Für Fish Shell (in ~/.config/fish/config.fish einfügen):"
    echo "    function pcf"
    echo "        \"${script_call_path_for_function}\" \$argv" # Zeigt \$HOME/... und \$argv
    echo "    end"
    echo "    # Optional: 'funcsave pcf' im Terminal ausführen, um die Funktion dauerhaft zu speichern."
    echo "    # Danach neues Terminal öffnen oder Konfiguration neu laden."
    echo ""
    echo "  Nach der Einrichtung können Sie z.B. aufrufen: pcf b, pcf t, etc."
}



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
        return 1
    fi

    local image_name
    local actual_php_version

    echo "--- PHP-Versionserkennung (Ausgabe nach STDERR) ---" >&2
    actual_php_version=$(get_target_php_version) # Ruft Funktionen auf, die im Kontext von TARGET_PROJECT_DIR arbeiten
    echo "---------------------------------------------------" >&2

    echo
    echo "Aktueller Git-Stand im Projekt '$PROJECT_ROOT': $(git rev-parse --short HEAD) auf Ref: $(git symbolic-ref -q --short HEAD || git rev-parse HEAD)"

    if [[ "$actual_php_version" == "unknown" || -z "$actual_php_version" ]]; then
        echo "FEHLER: PHP-Version ist 'unknown'. Abbruch des Builds."
        return 1
    fi

    echo "Verwende PHP-Version für Image-Tag: $actual_php_version"
    image_name="sl5-preg-contentfinder-php${actual_php_version}-dev:latest"
    echo "Baue Docker-Image als: $image_name (aus Kontext: $PROJECT_ROOT)"

    # docker build . bezieht sich auf das aktuelle Verzeichnis, das jetzt TARGET_PROJECT_DIR ist
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
    local actual_php_version

    echo "--- PHP-Versionserkennung (Ausgabe nach STDERR) ---" >&2
    actual_php_version=$(get_target_php_version)
    echo "---------------------------------------------------" >&2

    if [[ "$actual_php_version" == "unknown" || -z "$actual_php_version" ]]; then
        echo "FEHLER: PHP-Version ist 'unknown'. Abbruch der Tests."
        return 1
    fi

    image_name="sl5-preg-contentfinder-php${actual_php_version}-dev:latest"
    echo "Verwende PHP-Version $actual_php_version für Tests mit Image $image_name."
    echo "Führe Tests aus Projekt '$PROJECT_ROOT' aus..."

    # -v "${PROJECT_ROOT}:/app" mountet das korrekte Verzeichnis
    docker run --rm -v "${PROJECT_ROOT}:/app" "$image_name" php /usr/local/bin/phpunit /app/tests/PHPUnit/Callback_Emty_Test.php
}

# Neue Funktion für Docker System Status
show_docker_storage_status() {
    if ! check_docker_running; then
        return 1
    fi
    echo "Aktueller Docker-Speicherverbrauch:" >&2
    docker system df
    echo "" >&2
    echo "Um Speicher freizugeben, verwenden Sie die 'c' (cleanup) Aktion." >&2
}

prune_build_cache() {
    if ! check_docker_running; then
        return 1
    fi
    echo "INFO: Räume Docker Build-Cache auf (docker builder prune -af)..." >&2
    echo "      Dies entfernt alle nicht verwendeten Build-Cache-Layer." >&2
    echo "      Nützlich für frische Builds oder um Speicherplatz freizugeben, der vom Cache belegt wird." >&2
    if docker builder prune -af; then
        echo "INFO: Docker Build-Cache erfolgreich aufgeräumt." >&2
    else
        echo "WARNUNG: Problem beim Aufräumen des Docker Build-Caches." >&2
    fi
}

cleanup_docker() { # Diese Funktion führt 'docker system prune -af' aus
    if ! check_docker_running; then
        echo "INFO: Docker nicht gestartet, Aufräumen nicht möglich oder nicht nötig." >&2
        return 1
    fi
    echo "INFO: Starte umfassendes Docker Cleanup (docker system prune -af)..." >&2
    echo "      Dies löscht: " >&2
    echo "        - Alle gestoppten Container" >&2
    echo "        - Alle ungenutzten Netzwerke" >&2
    echo "        - Alle ungenutzten (dangling und nicht getaggten) Images" >&2
    echo "        - Den gesamten Build-Cache" >&2
    echo "      Laufende Container und getaggte Images, die noch verwendet werden (z.B. als Basis für andere)," >&2
    echo "      sollten NICHT entfernt werden." >&2
    echo "" >&2
    echo "Aktueller Docker-Speicherverbrauch (vor dem Aufräumen):" >&2
    docker system df # Zeige Status vorher
    echo "" >&2

    if docker system prune -af; then
        echo "INFO: Docker System erfolgreich aufgeräumt." >&2
    else
        echo "WARNUNG: Problem beim Aufräumen des Docker Systems." >&2
    fi
    echo "" >&2
    echo "Docker-Speicherverbrauch nach dem Aufräumen:" >&2
    docker system df # Zeige Status nachher
}

# --- Hauptlogik des Skripts (Argument-Parsing) ---
if [ $# -eq 0 ]; then
    echo "Fehler: Keine Aktion angegeben." >&2
    show_help
    exit 1
fi

action=$(echo "$1" | tr '[:upper:]' '[:lower:]')
modifier=$(echo "$2" | tr '[:upper:]' '[:lower:]') # Zweites Argument als Modifikator

case "$action" in
    b|build)
        build_image "$modifier" # Übergib den Modifikator (kann leer sein)
        ;;
    t|test)
        run_tests
        ;;
    c|cleanup)
        cleanup_docker
        ;;
    bcp|"buildcacheprune") # explizit für bcp
        prune_build_cache
        ;;
    s|status)
        show_docker_storage_status # show_docker_storage_status muss definiert sein
        ;;
    n|name)
        img_name=$(get_target_php_version)
        if [[ "$img_name" != "unknown" && -n "$img_name" ]]; then
            echo "sl5-preg-contentfinder-php${img_name}-dev:latest"
        else
            echo "Fehler beim Ermitteln des Image-Namens (PHP-Version 'unknown')." >&2; exit 1
        fi
        ;;
    p|php_version|phpversion)
        php_ver=$(get_target_php_version)
        if [[ "$php_ver" != "unknown" && -n "$php_ver" ]]; then
            echo "$php_ver"
        else
            echo "Fehler beim Ermitteln der PHP-Version ('unknown')." >&2; exit 1
        fi
        ;;
    h|help|-h|--help)
        show_help
        exit 0
        ;;
    *)
        echo "Fehler: Ungültige Aktion '$1'." >&2
        show_help
        exit 1
        ;;
esac

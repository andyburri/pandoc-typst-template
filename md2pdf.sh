#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LUA_FILTERS=(
    "include-files.lua"
    "preserve-ref.lua"
    "citations.lua"
    "pagebreak.lua"
    "newline.lua"
    "caption-code-blocks.lua"
    "plantuml.lua"
    "mermaid.lua"
    "align-figures.lua"
    "align-tables.lua"
    "callouts.lua"
)

TEMPLATE="$SCRIPT_DIR/template/bergfink.typst"
FILTERS_DIR="$SCRIPT_DIR/filters"

INPUT_FILES=()
OUTPUT_FILE=""
METADATA_FILE=""
OUTPUT_TYP=false
CONFIG_FILE=""
WATCH=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -m|--metadata)
            METADATA_FILE="$2"
            shift 2
            ;;
        --typ)
            OUTPUT_TYP=true
            if [[ -n "$2" && "$2" != -* ]]; then
                OUTPUT_FILE="$2"
                shift 2
            else
                shift 1
            fi
            ;;
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -w|--watch)
            WATCH=true
            shift
            ;;
        -*)
            echo "Unknown option: $1"
            exit 1
            ;;
        *)
            INPUT_FILES+=("$1")
            shift
            ;;
    esac
done

if [ ${#INPUT_FILES[@]} -eq 0 ]; then
    echo "Usage: $0 <input_files> [-o <output>] [-m <metadata>] [--typ [<output>]] [-w]"
    exit 1
fi

# Resolve paths
ABS_INPUT_FILES=()
for f in "${INPUT_FILES[@]}"; do
    ABS_INPUT_FILES+=("$(realpath "$f")")
done

FIRST_INPUT="${ABS_INPUT_FILES[0]}"
INPUT_DIR="$(dirname "$FIRST_INPUT")"

if [ "$OUTPUT_TYP" = true ] && [ -z "$OUTPUT_FILE" ]; then
    # Change extension to .typ
    OUTPUT_FILE="${FIRST_INPUT%.*}.typ"
elif [ -z "$OUTPUT_FILE" ]; then
    # Change extension to .pdf
    OUTPUT_FILE="${FIRST_INPUT%.*}.pdf"
fi

# If output file was provided as relative, resolve it relative to current CWD
ABS_OUTPUT_FILE="$(realpath -m "$OUTPUT_FILE")"

if [ -n "$METADATA_FILE" ]; then
    ABS_METADATA_FILE="$(realpath "$METADATA_FILE")"
fi

if [ -n "$CONFIG_FILE" ]; then
    ABS_CONFIG_FILE="$(realpath "$CONFIG_FILE")"
fi

# Build pandoc command
run_conversion() {
    echo "Running conversion..."
    
    local CMD=("pandoc" "${ABS_INPUT_FILES[@]}" "-o" "$ABS_OUTPUT_FILE" "--from" "markdown" "--template" "$TEMPLATE")
    
    if [[ "$ABS_OUTPUT_FILE" == *.typ ]]; then
        CMD+=("--to" "typst")
    else
        CMD+=("--pdf-engine" "typst")
    fi
    
    for f in "${LUA_FILTERS[@]}"; do
        CMD+=("--lua-filter" "$FILTERS_DIR/$f")
    done
    
    if [ -n "$ABS_METADATA_FILE" ]; then
        CMD+=("--metadata-file" "$ABS_METADATA_FILE")
    fi
    
    if [ -n "$ABS_CONFIG_FILE" ]; then
        # Use relative path to avoid Typst root issues when include is used in template
        REL_CONFIG_FILE=$(realpath --relative-to="$INPUT_DIR" "$ABS_CONFIG_FILE")
        CMD+=("-V" "user-config=$REL_CONFIG_FILE")
    fi
    
    # Change to input directory as in Python script: os.chdir(input_paths[0].parent)
    (cd "$INPUT_DIR" && "${CMD[@]}")
    
    local EXIT_CODE=$?
    if [ $EXIT_CODE -eq 0 ]; then
        echo "Done."
        return 0
    else
        echo "Error during conversion (Exit code: $EXIT_CODE)."
        return 1
    fi
}

if [ "$WATCH" = false ]; then
    run_conversion || exit 1
else
    run_conversion
    
    FILES_TO_WATCH=("${ABS_INPUT_FILES[@]}")
    if [ -n "$ABS_METADATA_FILE" ] && [ -f "$ABS_METADATA_FILE" ]; then
        FILES_TO_WATCH+=("$ABS_METADATA_FILE")
    fi
    if [ -n "$ABS_CONFIG_FILE" ] && [ -f "$ABS_CONFIG_FILE" ]; then
        FILES_TO_WATCH+=("$ABS_CONFIG_FILE")
    fi
    
    echo "Watching for changes in ${INPUT_FILES[*]}... (Ctrl+C to stop)"
    
    # Get initial mtimes
    declare -A last_mtimes
    for f in "${FILES_TO_WATCH[@]}"; do
        if [ -f "$f" ]; then
            last_mtimes["$f"]=$(stat -c %Y "$f")
        fi
    done
    
    # Simple loop to check for changes
    while true; do
        sleep 1
        CHANGED=false
        for f in "${FILES_TO_WATCH[@]}"; do
            if [ -f "$f" ]; then
                MTIME=$(stat -c %Y "$f")
                if [ "${last_mtimes["$f"]}" != "$MTIME" ]; then
                    last_mtimes["$f"]=$MTIME
                    CHANGED=true
                fi
            fi
        done
        
        if [ "$CHANGED" = true ]; then
            echo -e "\nChange detected, re-running conversion..."
            run_conversion
        fi
    done
fi

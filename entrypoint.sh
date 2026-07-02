#!/bin/bash

# Entrypoint script for processGPX

perl processGPX -v
echo "--------------------------------"

process_files() {
    local ext="$1"
    local bt_prefix="$2"
    shift 2
    echo "🔄 Processing ${ext^^} files..."
    local files
    files=$(find /tmp/ -name "*.${ext}" ! -name "*_processed*" ! -name ".*" 2>/dev/null)
    if [ -z "$files" ]; then
        echo "❌ No ${ext^^} files to process found"
        exit 1
    fi
    echo "📁 Files found:"
    echo "$files"
    if [ -n "$bt_prefix" ]; then
        while IFS= read -r file; do
            local output="${file%.${ext}}_processed.gpx"
            if [ $# -gt 0 ]; then
                echo "🔧 Additional options: $*"
                perl processGPX "${bt_prefix}:$file" $* -out "$output"
            else
                perl processGPX -auto "${bt_prefix}:$file" -out "$output"
            fi
        done <<< "$files"
    else
        if [ $# -gt 0 ]; then
            echo "🔧 Additional options: $*"
            perl processGPX $* $files
        else
            perl processGPX -auto $files
        fi
    fi
    echo "✅ Processing completed"
}

process_bt_command() {
    local command_name="$1"
    local display_name="$2"
    local source_prefix="$3"
    local output_ext="$4"
    local route_id="$5"
    shift 5

    if [ -z "$route_id" ]; then
        echo "❌ Error: Route ID is required for $command_name"
        exit 1
    fi
    if ! [[ "$route_id" =~ ^[0-9]+$ ]]; then
        echo "❌ Error: Route ID must contain only digits"
        exit 1
    fi

    echo "🔄 Processing $display_name: $route_id"
    if [ $# -gt 0 ]; then
        echo "🔧 Additional options: $*"
        perl processGPX "$@" "${source_prefix}:$route_id" -out "/tmp/${route_id}.${output_ext}"
    else
        perl processGPX -auto "${source_prefix}:$route_id" -out "/tmp/${route_id}.${output_ext}"
    fi
    echo "✅ Processing completed"
}

case "$1" in
    "random")
        RANDOM_NAME=randomRoute_$(date +%s).gpx
        # Déterminer les coordonnées et le message
        if [ "$2" = "random" ]; then
            lat=$(awk -v seed="$RANDOM" 'BEGIN { srand(seed); printf "%.4f", -90 + rand() * 180 }')
            lon=$(awk -v seed="$RANDOM" 'BEGIN { srand(seed); printf "%.4f", -180 + rand() * 360 }')
            echo "🌍 Generating random GPX file at random position: lat=$lat, lon=$lon"
            shift 2  # Remove "random" and "random" from arguments
            if [ $# -gt 0 ]; then
                echo "🔧 Additional options: $*"
                perl makeRandomRoute --out=$RANDOM_NAME --lat0="$lat" --lon0="$lon" $*
            else
                perl makeRandomRoute --out=$RANDOM_NAME --lat0="$lat" --lon0="$lon"
            fi
            success_msg="✅ File $RANDOM_NAME generated at random coordinates ($lat, $lon)"
        elif [ -n "$2" ] && [ -n "$3" ]; then
            lat="$2"
            lon="$3"
            echo "🌍 Generating random GPX file at position: lat=$lat, lon=$lon"
            shift 3  # Remove "random", lat, and lon from arguments
            if [ $# -gt 0 ]; then
                echo "🔧 Additional options: $*"
                perl makeRandomRoute --out=$RANDOM_NAME --lat0="$lat" --lon0="$lon" $*
            else
                perl makeRandomRoute --out=$RANDOM_NAME --lat0="$lat" --lon0="$lon"
            fi
            success_msg="✅ File $RANDOM_NAME generated at coordinates ($lat, $lon)"
        else
            echo "🎲 Generating random GPX file..."
            shift  # Remove "random" from arguments
            if [ $# -gt 0 ]; then
                echo "🔧 Additional options: $*"
                perl makeRandomRoute --out=$RANDOM_NAME $*
            else
                perl makeRandomRoute --out=$RANDOM_NAME
            fi
            success_msg="✅ File $RANDOM_NAME generated"
        fi
        
        # Vérifier le résultat et déplacer le fichier
        if [ -f "$RANDOM_NAME" ]; then
            mv "$RANDOM_NAME" /tmp/
            echo "$success_msg"
        else
            echo "❌ Error: File $RANDOM_NAME not generated"
            exit 1
        fi
        ;;
    "process")
        shift
        process_files "gpx" "" "$@"
        ;;
    "btjson")
        shift
        process_files "json" "BTJSON" "$@"
        ;;
    "btroute")
        process_bt_command "btroute" "BT Route" "BTRoute" "gpx" "$2" "${@:3}"
        ;;
    "btgpx")
        process_bt_command "btgpx" "BT GPX" "BTGPX" "gpx" "$2" "${@:3}"
        ;;
    *)
        echo "Usage: docker run [options] dasgreff/processgpx [random [random|lat lon] [free_args]|process [processGPX_options]]"
        echo ""
        echo "Available commands:"
        echo "  random                    - Generate a random GPX file (default location: Bonneville Salt Flats)"
        echo "  random random             - Generate a random GPX file at random coordinates"
        echo "  random lat lon            - Generate a random GPX file at specified coordinates"
        echo "  random [random|lat lon] [free_args]  - Generate with additional makeRandomRoute arguments"
        echo "  (process|btjson) [options]           - Process existing GPX or JSON files"
        echo "  (btroute|btgpx) <Route_ID> [options] - Process existing BT Route"
        echo ""
        echo "Main processGPX options:"
        echo "  -smooth <m>     - Position/altitude smoothing (ex: -smooth 10)"
        echo "  -smoothZ <m>    - Altitude smoothing only (ex: -smoothZ 20)"
        echo "  -spacing <m>    - Spacing between points (ex: -spacing 5)"
        echo "  -autoSpacing    - Automatic spacing in turns"
        echo "  -prune          - Remove unnecessary points"
        echo "  -loop           - Treat as a closed circuit"
        echo ""
        echo "Examples:"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx random"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx random random"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx random 45.8566 6.8522"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx random 45.8566 6.8522 --hollow --hexagon --L=100 --N=20"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx random random --option1 value1"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx (process|btjson)"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx (process|btjson) -smooth 10 -prune"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx (btroute|btgpx) 1234"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx (btroute|btgpx) 1234 -smooth 10 -prune"
        exit 1
        ;;
esac
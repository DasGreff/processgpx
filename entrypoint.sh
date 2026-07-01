#!/bin/bash

# Entrypoint script for processGPX

perl processGPX -v
echo "--------------------------------"

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
        echo "🔄 Processing GPX files..."
        gpx_files=$(find /tmp/ -name "*.gpx" ! -name "*_processed*" ! -name ".*" 2>/dev/null)
        if [ -z "$gpx_files" ]; then
            echo "❌ No GPX files to process found"
            exit 1
        fi
        echo "📁 Files found:"
        echo "$gpx_files"
        
        # Handle additional options
        shift  # Remove "process" from arguments
        if [ $# -gt 0 ]; then
            echo "🔧 Additional options: $*"
            perl processGPX $* $gpx_files
        else
            perl processGPX -auto $gpx_files
        fi
        echo "✅ Processing completed"
        ;;
    "btroute")
        if [ -z "$2" ]; then
            echo "❌ Error: Route ID is required for btroute"
            exit 1
        fi
        if ! [[ "$2" =~ ^[0-9]+$ ]]; then
            echo "❌ Error: Route ID must contain only digits"
            exit 1
        fi
        route_id="$2"
        shift 2  # Remove "btroute" and Route_ID from arguments
        
        echo "🔄 Processing BT Route: $route_id"
        if [ $# -gt 0 ]; then
            echo "🔧 Additional options: $*"
            perl processGPX $* BTRoute:$route_id -out /tmp/$route_id.gpx
        else
            perl processGPX -auto BTRoute:$route_id -out /tmp/$route_id.gpx
        fi
        echo "✅ Processing completed"
        ;;
    "btgpx")
        if [ -z "$2" ]; then
            echo "❌ Error: Route ID is required for btgpx"
            exit 1
        fi
        if ! [[ "$2" =~ ^[0-9]+$ ]]; then
            echo "❌ Error: Route ID must contain only digits"
            exit 1
        fi
        route_id="$2"
        shift 2  # Remove "btgpx" and Route_ID from arguments
        
        echo "🔄 Processing BT GPX: $route_id"
        if [ $# -gt 0 ]; then
            echo "🔧 Additional options: $*"
            perl processGPX $* BTGPX:$route_id -out /tmp/$route_id.gpx
        else
            perl processGPX -auto BTGPX:$route_id -out /tmp/$route_id.gpx
        fi
        echo "✅ Processing completed"
        ;;
    *)
        echo "Usage: docker run [options] dasgreff/processgpx [random [random|lat lon] [free_args]|process [processGPX_options]]"
        echo ""
        echo "Available commands:"
        echo "  random                    - Generate a random GPX file (default location: Bonneville Salt Flats)"
        echo "  random random             - Generate a random GPX file at random coordinates"
        echo "  random lat lon            - Generate a random GPX file at specified coordinates"
        echo "  random [random|lat lon] [free_args] - Generate with additional makeRandomRoute arguments"
        echo "  process [options]         - Process existing GPX files"
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
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx process"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx process -smooth 10 -prune"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx (btroute|btgpx) 1234"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx (btroute|btgpx) 1234 -smooth 10 -prune"
        exit 1
        ;;
esac
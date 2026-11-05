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
                perl processGPX "${bt_prefix}:$file" $* -out "$output" >/dev/null 2>&1
            else
                perl processGPX -auto "${bt_prefix}:$file" -out "$output" >/dev/null 2>&1
            fi
        done <<< "$files"
    else
        if [ $# -gt 0 ]; then
            echo "🔧 Additional options: $*"
            perl processGPX $* $files >/dev/null 2>&1
        else
            perl processGPX -auto $files >/dev/null 2>&1
        fi
    fi
    chown 1000:1000 /tmp/*.gpx /tmp/*.json 2>/dev/null
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
        perl processGPX "$@" "${source_prefix}:$route_id" -out "/tmp/${route_id}.${output_ext}" >/dev/null 2>&1
    else
        perl processGPX -auto "${source_prefix}:$route_id" -out "/tmp/${route_id}.${output_ext}" >/dev/null 2>&1
    fi
    chown 1000:1000 /tmp/*.gpx /tmp/*.json 2>/dev/null
    echo "✅ Processing completed"
}

get_country_coordinates() {
    local country_code="$1"
    local coordinates

    if [ "$country_code" != "RANDOM" ] && ! [[ "$country_code" =~ ^[A-Za-z]{3}$ ]]; then
        echo "❌ Error: Country code must be a three-letter ISO 3166-1 alpha-3 code" >&2
        return 1
    fi

    if ! coordinates=$(/usr/local/bin/random-country-point.py "${country_code^^}"); then
        return 1
    fi

    printf '%s\n' "$coordinates"
}

get_country_from_coordinates() {
    local lat="$1"
    local lon="$2"

    if ! [[ "$lat" =~ ^-?[0-9]+\.?[0-9]*$ ]] || ! [[ "$lon" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
        echo "❌ Error: Latitude and longitude must be valid numbers" >&2
        return 1
    fi

    # Use Python script to check which country polygon contains the point
    python3 /usr/local/bin/get_country_from_coordinates.py "$lat" "$lon"
}

case "$1" in
    "random")
        # Déterminer les coordonnées et le message
        if [ "$2" = "random" ]; then
            lat=$(awk -v seed="$RANDOM" 'BEGIN { srand(seed); printf "%.4f", -90 + rand() * 180 }')
            lon=$(awk -v seed="$RANDOM" 'BEGIN { srand(seed); printf "%.4f", -180 + rand() * 360 }')
            country_name=$(get_country_from_coordinates "$lat" "$lon")
            country_code=$(echo "$country_name" | awk -F'[()]' '{print $2}')
            RANDOM_NAME=randomRoute_$(date +%s)_$country_code.gpx
            echo "🌍 Generating random GPX file at random position: lat=$lat, lon=$lon, $country_name"
            shift 2  # Remove "random" and "random" from arguments
            if [ $# -gt 0 ]; then
                echo "🔧 Additional options: $*"
                perl makeRandomRoute --out=$RANDOM_NAME --lat0="$lat" --lon0="$lon" $* >/dev/null 2>&1
            else
                perl makeRandomRoute --out=$RANDOM_NAME --lat0="$lat" --lon0="$lon" >/dev/null 2>&1
            fi
            success_msg="✅ File $RANDOM_NAME generated"
        elif [[ "$2" = "country" ]]; then
            if ! read -r lat lon country_code country_name < <(get_country_coordinates "RANDOM"); then
                exit 1
            fi
            RANDOM_NAME=randomRoute_$(date +%s)_$country_code.gpx
            echo "🌍 Generating random GPX file in randomly picked country: $country_name ($country_code), lat=$lat, lon=$lon"
            shift 2  # Remove "random" and "country" from arguments
            if [ $# -gt 0 ]; then
                echo "🔧 Additional options: $*"
                perl makeRandomRoute --out=$RANDOM_NAME --lat0="$lat" --lon0="$lon" "$@" >/dev/null 2>&1
            else
                perl makeRandomRoute --out=$RANDOM_NAME --lat0="$lat" --lon0="$lon" >/dev/null 2>&1
            fi
            success_msg="✅ File $RANDOM_NAME generated"
        elif [[ "$2" = "list_country" ]]; then
            echo "🌍 Listing all available countries:"
            jq -r '.features | sort_by(.properties.name) | to_entries | map("\(.key + 1). \(.value.properties.name) : \(.value.properties."ISO3166-1-Alpha-3")") | .[]' /usr/local/share/countries.geojson
        elif [[ "$2" =~ ^[A-Za-z]{3}$ ]]; then
            country_code="${2^^}"
            RANDOM_NAME=randomRoute_$(date +%s)_$country_code.gpx
            if ! read -r lat lon country_code country_name < <(get_country_coordinates "$country_code"); then
                exit 1
            fi
            echo "🌍 Generating random GPX file in country: $country_name ($country_code), lat=$lat, lon=$lon"
            shift 2  # Remove "random" and the country code from arguments
            if [ $# -gt 0 ]; then
                echo "🔧 Additional options: $*"
                perl makeRandomRoute --out=$RANDOM_NAME --lat0="$lat" --lon0="$lon" "$@" >/dev/null 2>&1
            else
                perl makeRandomRoute --out=$RANDOM_NAME --lat0="$lat" --lon0="$lon" >/dev/null 2>&1
            fi
            success_msg="✅ File $RANDOM_NAME generated"
        elif [ -n "$2" ] && [ -n "$3" ]; then
            lat="$2"
            lon="$3"
            country_name=$(get_country_from_coordinates "$lat" "$lon")
            country_code=$(echo "$country_name" | awk -F'[()]' '{print $2}')
            RANDOM_NAME=randomRoute_$(date +%s)_$country_code.gpx
            echo "🌍 Generating random GPX file at position: lat=$lat, lon=$lon, $country_name"
            shift 3  # Remove "random", lat, and lon from arguments
            if [ $# -gt 0 ]; then
                echo "🔧 Additional options: $*"
                perl makeRandomRoute --out=$RANDOM_NAME --lat0="$lat" --lon0="$lon" $* >/dev/null 2>&1
            else
                perl makeRandomRoute --out=$RANDOM_NAME --lat0="$lat" --lon0="$lon" >/dev/null 2>&1
            fi
            success_msg="✅ File $RANDOM_NAME generated"
        else
            RANDOM_NAME=randomRoute_$(date +%s).gpx
            echo "🎲 Generating random GPX file..."
            shift  # Remove "random" from arguments
            if [ $# -gt 0 ]; then
                echo "🔧 Additional options: $*"
                perl makeRandomRoute --out=$RANDOM_NAME $* >/dev/null 2>&1
            else
                perl makeRandomRoute --out=$RANDOM_NAME >/dev/null 2>&1
            fi
            success_msg="✅ File $RANDOM_NAME generated"
        fi
        
        # Vérifier le résultat et déplacer le fichier
        if [[ "$2" != "list_country" ]]; then
            if [ -f "$RANDOM_NAME" ]; then
                chown 1000:1000 "$RANDOM_NAME"
                mv "$RANDOM_NAME" /tmp/
                echo "$success_msg"
            else
                echo "❌ Error: File $RANDOM_NAME not generated"
                exit 1
            fi
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
    "circle")
        # Circle command: generate circular GPX routes
        # Usage: circle [random|country|ISO-3|lat lon] <dist_km> [num_points] [output_filename]
        shift  # Remove "circle"
        
        if [ $# -lt 1 ]; then
            echo "❌ Error: dist in kilometers is required for circle command" >&2
            echo "Usage: circle [random|country|ISO-3|lat lon] <dist_km> [num_points] [output_filename]" >&2
            exit 1
        fi
        
        distance_km="$1"
        shift  # Remove distance

        # Check if distance is greater than 0 using awk
        if [ "$(echo "$distance_km <= 0" | awk '{print ($1 <= 0) ? "1" : "0"}')" = "1" ]; then
            echo "❌ Error: Distance must be a positive number" >&2
            exit 1
        fi
        
        num_points=100
        output_filename=""
        
        # Determine the center point
        if [ $# -ge 1 ] && [ "$1" = "random" ]; then
            # Random location worldwide
            lat=$(awk -v seed="$RANDOM" 'BEGIN { srand(seed); printf "%.4f", -90 + rand() * 180 }')
            lon=$(awk -v seed="$RANDOM" 'BEGIN { srand(seed); printf "%.4f", -180 + rand() * 360 }')
            country_name=$(get_country_from_coordinates "$lat" "$lon")
            country_code=$(echo "$country_name" | awk -F'[()]' '{print $2}')
            shift  # Remove "random"
            
        elif [ $# -ge 1 ] && [ "$1" = "country" ]; then
            # Random country, then random point inside
            if ! read -r lat lon country_code country_name < <(get_country_coordinates "RANDOM"); then
                exit 1
            fi
            shift  # Remove "country"
            
        elif [ $# -ge 1 ] && [[ "$1" =~ ^[A-Za-z]{3}$ ]]; then
            # ISO 3166-1 alpha-3 country code
            country_code="${1^^}"
            if ! read -r lat lon found_code country_name < <(get_country_coordinates "$country_code"); then
                exit 1
            fi
            shift  # Remove country code
            
        elif [ $# -ge 2 ]; then
            # Specific lat/lon
            if ! [[ "$1" =~ ^-?[0-9]+\.?[0-9]*$ ]] || ! [[ "$2" =~ ^-?[0-9]+\.?[0-9]*$ ]]; then
                echo "❌ Error: Latitude and longitude must be valid numbers" >&2
                exit 1
            fi
            lat="$1"
            lon="$2"
            country_name=$(get_country_from_coordinates "$lat" "$lon")
            country_code=$(echo "$country_name" | awk -F'[()]' '{print $2}')
            shift 2  # Remove lat and lon
            
        else
            # Default: Bonneville Salt Flats
            lat="40.7800"
            lon="-112.2200"
            country_code="USA"
            country_name="United States of America (USA)"
        fi
        
        # Extract num_points and output_filename from remaining args
        while [ $# -gt 0 ]; do
            if [[ "$1" =~ ^[0-9]+$ ]] && [ -z "$output_filename" ]; then
                num_points="$1"
                shift
            elif [ -z "$output_filename" ]; then
                output_filename="$1"
                shift
            else
                shift
            fi
        done
        
        # Generate filename if not provided
        if [ -z "$output_filename" ]; then
            TIMESTAMP=$(date +%s)
            output_filename="circle_${TIMESTAMP}_${country_code}.gpx"
        fi
        
        echo "🔄 Generating GPX circle at: lat=$lat, lon=$lon, $country_name"
        echo "📏 Circumference: ${distance_km}km, Points: $num_points"
        
        # Generate the circle GPX file
        if ! python3 /usr/local/bin/generate_circle_gpx.py "$lat" "$lon" "$distance_km" "$num_points" "/tmp/$output_filename" >/dev/null 2>&1; then
            echo "❌ Error: Failed to generate circle GPX file" >&2
            exit 1
        fi
        
        chown 1000:1000 "/tmp/$output_filename" 2>/dev/null
        echo "✅ GPX circle file generated: $output_filename"
        ;;
    *)
        echo "Usage: docker run [options] dasgreff/processgpx [random|circle|process|btjson|btroute|btgpx] [arguments]"
        echo ""
        echo "Available commands:"
        echo "  random                    - Generate a random GPX file (default location: Bonneville Salt Flats)"
        echo "  random random             - Generate a random GPX file at random coordinates"
        echo "  random country            - Generate a random GPX file in a randomly picked country from the geojson dataset"
        echo "  random ISO-3              - Generate a random GPX file at a random location in an ISO 3166-1 alpha-3 country"
        echo "  random lat lon            - Generate a random GPX file at specified coordinates"
        echo "  random [random|country|ISO-3|lat lon] [free_args]  - Generate with additional makeRandomRoute arguments"
        echo "  circle <distance>          - Generate a circular GPX route at default location (Bonneville Salt Flats)"
        echo "  circle <distance> random   - Generate a circular GPX route at random coordinates"
        echo "  circle <distance> country  - Generate a circular GPX route in a randomly picked country"
        echo "  circle <distance> ISO-3    - Generate a circular GPX route at random location in an ISO 3166-1 alpha-3 country"
        echo "  circle <distance> lat lon  - Generate a circular GPX route at specified coordinates"
        echo "  circle <distance> [options] [num_points] [output_filename] - Generate circular route"
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
        echo "Circle command options:"
        echo "  random          - Random location worldwide"
        echo "  country         - Random country, then random point inside"
        echo "  ISO-3           - ISO 3166-1 alpha-3 country code (e.g., FRA, USA)"
        echo "  lat lon         - Specific coordinates in decimal degrees"
        echo "  <distance>      - Distance (circumference) in kilometers (required)"
        echo "  [num_points]    - Number of points for the circle (default: 100)"
        echo "  [output_filename] - Custom output filename"
        echo ""
        echo "Examples:"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx random"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx random random"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx random country"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx random list_country"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx random FRA"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx random 45.8566 6.8522"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx random 45.8566 6.8522 --hollow --hexagon --L=100 --N=20"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx random random --option1 value1"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx circle 10"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx circle random 25"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx circle country 5"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx circle FRA 15"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx circle 45.8566 6.8522 20 200 my_circle.gpx"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx (process|btjson)"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx (process|btjson) -smooth 10 -prune"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx (btroute|btgpx) 1234"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx (btroute|btgpx) 1234 -smooth 10 -prune"
        exit 1
        ;;
esac
#!/bin/bash

# Entrypoint script for processGPX

perl processGPX -v
echo "--------------------------------"

case "$1" in
    "random")
        echo "🎲 Generating random GPX file..."
        perl makeRandomRoute
        if [ -f "randomRoute.gpx" ]; then
            mv randomRoute.gpx /tmp/
            echo "✅ File randomRoute.gpx generated"
        else
            echo "❌ Error: File randomRoute.gpx not generated"
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
    *)
        echo "Usage: docker run [options] dasgreff/processgpx [random|process [processGPX_options]]"
        echo ""
        echo "Available commands:"
        echo "  random            - Generate a random GPX file"
        echo "  process [options] - Process existing GPX files"
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
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx process"
        echo "  docker run -v <your_GPX_folder>:/tmp --rm dasgreff/processgpx process -smooth 10 -prune"
        exit 1
        ;;
esac
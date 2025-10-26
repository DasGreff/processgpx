# ProcessGPX Container

## Description

This project provides a Docker container for processing GPX (GPS Exchange Format) files using the [processGPX](https://github.com/djconnel/processGPX) tool. The container allows you to generate random routes and automatically process existing GPX files with advanced analysis and optimization features.

## Features

- 🎲 **Random generation**: Create GPX files with random routes
- 🔄 **Automatic processing**: Analysis and optimization of existing GPX files
- 📊 **Complete analysis**: Distance, speed, elevation and statistics calculations
- 🐳 **Containerized**: Easy deployment with Docker
- 📁 **Volume mounting**: Direct access to files on the host system
- ⚡ **Batch mode**: Process multiple files simultaneously

## Prerequisites

- Docker installed on your system
- Folder containing your GPX files (for process mode)

## Usage

### Available Commands

The container supports two operation modes:

#### 1. Random route generation (`random`)
Generates a new GPX file with a random route.

```bash
docker run -v /path/to/your/gpx:/tmp --rm processgpx:latest random
```

**Output:**
- `randomRoute.gpx` file created in the mounted folder
- Contains a randomly generated route

#### 2. Processing existing files (`process`)
Analyzes and processes all GPX files found in the mounted folder.

```bash
# Automatic processing (default)
docker run -v /path/to/your/gpx:/tmp --rm processgpx:latest process

# Processing with custom options
docker run -v /path/to/your/gpx:/tmp --rm processgpx:latest process -smooth 15 -smoothZ 25 -prune
```

**Available processGPX options:**
- `-auto` : Automatic mode with optimal parameters (default if no options)
- `-smooth <meters>` : Position and altitude smoothing (ex: `-smooth 10`)
- `-smoothZ <meters>` : Altitude smoothing only (ex: `-smoothZ 20`)
- `-spacing <meters>` : Spacing between points (ex: `-spacing 5`)
- `-autoSpacing` : Automatic optimized spacing in turns
- `-prune` : Remove unnecessary collinear points
- `-loop` : Treat the route as a closed circuit
- And many other advanced options...

**Processing features:**
- Distance and speed calculations
- Elevation profile analysis
- Detailed route statistics
- GPS data correction
- Report generation

### Practical Examples

#### Random route generation
```bash
# Generate a random route in the local folder
docker run -v $(pwd)/gpx-files:/tmp --rm processgpx:latest random
```

#### Processing existing GPX files
```bash
# Process all GPX files in the folder (auto mode)
docker run -v /home/user/Documents/GPX:/tmp --rm processgpx:latest process

# Processing with custom options
docker run -v /home/user/Documents/GPX:/tmp --rm processgpx:latest process -smooth 10 -prune
```

## Detailed Operation

### `random` Mode
1. **Generation**: Runs the `makeRandomRoute` script from processGPX
2. **Verification**: Checks that the `randomRoute.gpx` file is properly created
3. **Movement**: Places the file in `/tmp/` (mounted folder)
4. **Confirmation**: Displays success or error message

### `process` Mode
1. **Search**: Scans `/tmp/` to find `.gpx` files
2. **Filtering**: Excludes already processed files (`*_processed*`) and hidden files (`.*`)
3. **Options**: Analyzes additional options passed as parameters
4. **Processing**: 
   - Without options: Runs `processGPX -auto` (automatic mode)
   - With options: Runs `processGPX [options]` (custom mode)
5. **Analysis**: Generates statistics and reports according to options

### Included Perl Dependencies

The container automatically includes the necessary Perl modules:
- `Getopt::Long` : Command line options management
- `XML::Descent` : XML/GPX file parsing
- `POSIX` : POSIX system functions
- `Date::Parse` : Date and time parsing
- `Pod::Usage` : Documentation and help
- `Geo::Gpx` : GPX data manipulation

## Output Format

### Generated Files

#### `random` Mode
- `randomRoute.gpx` : GPX file with random route

#### `process` Mode
- Analysis files (variable formats according to processGPX)
- Statistics reports
- Elevation profile data
- Corrected files (according to configuration)

### Output Messages

```bash
# Random mode
🎲 Generating random GPX file...
✅ File randomRoute.gpx generated and moved to /tmp/

# Process mode (without options)
🔄 Processing GPX files...
📁 Files found:
/tmp/track1.gpx
/tmp/track2.gpx
✅ Processing completed

# Process mode (with options)
🔄 Processing GPX files...
📁 Files found:
/tmp/track1.gpx
/tmp/track2.gpx
🔧 Additional options: -smooth 15 -smoothZ 25 -prune
✅ Processing completed
```

## Troubleshooting

### Common Issues

#### "No GPX files to process found"
- **Cause**: No `.gpx` files in the mounted folder
- **Solution**: Check that your GPX files are in the correct folder

#### "File randomRoute.gpx not generated"
- **Cause**: Error in random generation
- **Solution**: Check the container error logs

#### Permission errors
- **Cause**: Insufficient permissions on the mounted folder
- **Solution**: Adjust the host folder permissions

### File verification

```bash
# List GPX files in the folder
ls -la /path/to/your/gpx/*.gpx

# Check permissions
ls -ld /path/to/your/gpx/
```

## Advanced Usage Examples

### Detailed processGPX Options

To know all available processGPX options:

```bash
# Display help
docker run --rm processgpx:latest
```

**Commonly used options:**
- `-auto` : Automatic mode with optimal parameters
- `-smooth <m>` : Position/altitude smoothing (ex: 10-20 meters)
- `-smoothZ <m>` : Altitude smoothing only (generally > smooth)
- `-spacing <m>` : Point density (3-10 meters depending on complexity)
- `-autoSpacing` : Adaptive spacing in turns
- `-prune` : Optimize number of points
- `-loop` : For closed circuits
- `-quiet` : Silent mode

### Advanced Usage Examples

#### Automated processing script
```bash
#!/bin/bash
# Script to automatically process new GPX files

GPX_DIR="/home/user/GPS/tracks"
BACKUP_DIR="/home/user/GPS/processed"

# Create a backup
cp -r "$GPX_DIR" "$BACKUP_DIR/$(date +%Y%m%d_%H%M%S)"

# Detailed processing with custom options
docker run -v "$GPX_DIR":/tmp --rm processgpx:latest process -smooth 12 -smoothZ 18 -autoSpacing -prune

echo "Processing completed. Check results in $GPX_DIR"
```

#### Silent processing
```bash
# Optimized silent processing
docker run -v /path/to/gpx:/tmp --rm processgpx:latest process -auto -quiet -prune
```

## About processGPX

This container uses the [processGPX](https://github.com/djconnel/processGPX) tool developed by djconnel. ProcessGPX is an advanced Perl tool for analyzing and processing GPX files with features including:

- Precise speed and distance calculations
- Elevation profile analysis
- GPS data correction
- Detailed statistics generation
- Multiple output formats support

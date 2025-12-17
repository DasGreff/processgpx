# ProcessGPX Container

Docker container for processing GPX files using the [processGPX](https://github.com/djconnel/processGPX) by [@djconnel](https://github.com/djconnel) - an advanced Perl tool for GPX file analysis and processing.

## Features

- 🎲 Generate random GPX routes at default location
- 🌍 Generate random GPX routes at specific coordinates  
- 🎯 Generate random GPX routes at completely random worldwide locations
- 🔄 Process and optimize existing GPX files  
- 📊 Calculate distance, speed, elevation statistics
- 🐳 Easy Docker deployment

## Usage

### Generate Random Route

#### Default location (Bonneville Salt Flats)
```bash
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest random
```

#### Random coordinates anywhere on Earth
```bash
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest random random
```

#### Specific coordinates
```bash
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest random 45.8566 6.8522
```

### Process Existing GPX Files
```bash
# Basic processing
docker run -v /path/to/gpx/files:/tmp --rm dasgreff/processgpx:latest process

# With options
docker run -v /path/to/gpx/files:/tmp --rm dasgreff/processgpx:latest process -auto -prune
```

### Common Options
- `-auto` : Automatic mode with optimal settings
- `-smooth <meters>` : Smooth position/altitude data
- `-smoothZ <meters>` : Altitude smoothing only
- `-fixSteps` : Fix identical altitude points from Strava Route Editor
- `-prune` : Remove redundant points
- `-quiet` : Silent mode

## Examples

```bash
# Generate random route at default location (Bonneville Salt Flats)
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest random

# Generate random route at completely random coordinates
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest random random

# Generate random route at specific coordinates (Chamonix, France)
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest random 45.8566 6.8522

# Process all GPX files with optimization
docker run -v /home/user/tracks:/tmp --rm dasgreff/processgpx:latest process -auto -prune
```

## Troubleshooting

- **No GPX files found**: Check that `.gpx` files exist in the mounted folder
- **Permission errors**: Ensure the mounted folder has proper read/write permissions
- **Generation failed**: Check container logs for error details

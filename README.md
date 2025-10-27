# ProcessGPX Container

Docker container for processing GPX files using the [processGPX](https://github.com/djconnel/processGPX) by djconnel - an advanced Perl tool for GPX file analysis and processing.

## Features

- 🎲 Generate random GPX routes
- 🔄 Process and optimize existing GPX files  
- 📊 Calculate distance, speed, elevation statistics
- 🐳 Easy Docker deployment

## Usage

### Generate Random Route
```bash
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest random
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
- `-prune` : Remove redundant points
- `-quiet` : Silent mode

## Examples

```bash
# Generate random route in current directory
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest random

# Process all GPX files with optimization
docker run -v /home/user/tracks:/tmp --rm dasgreff/processgpx:latest process -auto -prune
```

## Troubleshooting

- **No GPX files found**: Check that `.gpx` files exist in the mounted folder
- **Permission errors**: Ensure the mounted folder has proper read/write permissions
- **Generation failed**: Check container logs for error details

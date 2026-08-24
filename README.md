# ProcessGPX Container

Docker container for processing GPX files using the [processGPX](https://github.com/djconnel/processGPX) by [@djconnel](https://github.com/djconnel) - an advanced Perl tool for GPX file analysis and processing.

## Features

- 🎲 Generate random GPX routes at default location
- 🌍 Generate random GPX routes at specific coordinates  
- 🎯 Generate random GPX routes at completely random worldwide locations
- 🗺️ Generate random GPX routes from an ISO country code
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

#### Country by ISO code
Use a three-letter ISO 3166-1 alpha-3 country code. The starting point is selected randomly inside the country polygon from the embedded GeoJSON dataset.
```bash
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest random FRA
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

### Process BT Route
Process routes from Biketerra using the route ID (numerics only):
```bash
# Basic BT Route processing
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest btroute 1234

# With options
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest btroute 1234 -auto -prune
```

### Process BT GPX
Process existing Biketerra GPX files using the route ID (numerics only):
```bash
# Basic BT GPX processing
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest btgpx 5678

# With options
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest btgpx 5678 -smooth 10
```

### Common Options
- `-auto` : Automatic mode with optimal settings
- `-smooth <meters>` : Smooth position/altitude data
- `-smoothZ <meters>` : Altitude smoothing only
- `-fixSteps` : Fix identical altitude points from Strava Route Editor
- `-prune` : Remove redundant points
- `-quiet` : Silent mode

### Route ID Requirements
- For `btroute` and `btgpx` commands, the Route ID must contain **only digits** (0-9)
- Route IDs are used to fetch data from Biketerra services

## Examples

```bash
# Generate random route at default location (Bonneville Salt Flats)
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest random

# Generate random route at completely random coordinates
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest random random

# Generate random route in France
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest random FRA

# Generate random route at specific coordinates (Chamonix, France)
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest random 45.8566 6.8522 --hollow --hexagon --L=100 --N=20

# Process all GPX files with optimization
docker run -v /home/user/tracks:/tmp --rm dasgreff/processgpx:latest process -auto -prune

# Process BT Route with ID 10399
docker run -v /share/Public/GPX:/tmp --rm dasgreff/processgpx:latest btroute 10399

# Process BT Route with smoothing
docker run -v /share/Public/GPX:/tmp --rm dasgreff/processgpx:latest btroute 10399 -smooth 10 -prune

# Process BT GPX with ID 5678
docker run -v /share/Public/GPX:/tmp --rm dasgreff/processgpx:latest btgpx 5678

# Process BT GPX with options
docker run -v /share/Public/GPX:/tmp --rm dasgreff/processgpx:latest btgpx 5678 -auto
```

## Troubleshooting

- **No GPX files found**: Check that `.gpx` files exist in the mounted folder
- **Permission errors**: Ensure the mounted folder has proper read/write permissions
- **Generation failed**: Check container logs for error details
- **Invalid Route ID**: Route IDs for `btroute` and `btgpx` must be numeric only (e.g., `10399`, not `route_10399`)
- **JSON module error**: Rebuild the Docker image if you encounter JSON.pm errors

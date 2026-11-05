# ProcessGPX Container

Docker container for processing GPX files using the [processGPX](https://github.com/djconnel/processGPX) by [@djconnel](https://github.com/djconnel) - an advanced Perl tool for GPX file analysis and processing.

## Features

- 🎲 Generate random GPX routes at default location
- 🌍 Generate random GPX routes at specific coordinates  
- 🎯 Generate random GPX routes at completely random worldwide locations
- 🗺️ Generate random GPX routes from an ISO country code
- 🔵 Generate circular GPX routes with custom radius
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

#### Random country
Pick a random country from the embedded GeoJSON dataset (based on its list of ISO 3166-1 alpha-3 codes), then a random starting point inside it.
```bash
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest random country
```

#### Specific coordinates
```bash
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest random 45.8566 6.8522
```

### Generate Circular Route

Generate a perfect circle GPX track with a specified circumference (distance around the circle). The circle is created as a closed track with evenly spaced points.

#### Default location (Bonneville Salt Flats) with distance
```bash
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest circle 10
```

#### Random coordinates worldwide with distance
```bash
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest circle random 25
```

#### Random country with distance
Pick a random country from the embedded GeoJSON dataset, then a random point inside it as the circle center.
```bash
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest circle country 5
```

#### Country by ISO code with circumference
Use a three-letter ISO 3166-1 alpha-3 country code. The circle center is selected randomly inside the country polygon.
```bash
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest circle FRA 15
```

#### Specific coordinates with circumference
```bash
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest circle 45.8566 6.8522 20
```

#### With custom number of points and output filename
```bash
docker run -v /path/to/output:/tmp --rm dasgreff/processgpx:latest circle 45.8566 6.8522 20 200 my_circle.gpx
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

### Random Route Examples
```bash
# Generate random route at default location (Bonneville Salt Flats)
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest random

# Generate random route at completely random coordinates
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest random random

# Generate random route in France
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest random FRA

# Generate random route in a randomly picked country
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest random country

# Generate random route at specific coordinates (Chamonix, France)
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest random 45.8566 6.8522 --hollow --hexagon --L=100 --N=20
```

### Circular Route Examples
```bash
# Generate 10km circle at default location
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest circle 10

# Generate 25km circle at random coordinates worldwide
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest circle random 25

# Generate 5km circle in a random country
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest circle country 5

# Generate 15km circle in France
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest circle FRA 15

# Generate 20km circle at specific coordinates
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest circle 45.8566 6.8522 20

# Generate circle with custom parameters: 20km distance, 200 points, custom filename
docker run -v $(pwd):/tmp --rm dasgreff/processgpx:latest circle 45.8566 6.8522 20 200 my_circle.gpx
```

### Processing Examples
```bash
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

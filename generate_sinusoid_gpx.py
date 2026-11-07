#!/usr/bin/env python3

import math
import sys
from bisect import bisect_left
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta, timezone


def destination_point(lat, lon, distance_km, bearing_deg):
    """
    Calculate destination point given start point, distance, and bearing.
    Uses haversine formula.
    
    Args:
        lat: Start latitude in degrees
        lon: Start longitude in degrees
        distance_km: Distance to destination in kilometers
        bearing_deg: Bearing in degrees (0 = north, 90 = east, 180 = south, 270 = west)
    
    Returns:
        (destination_lat, destination_lon) in degrees
    """
    R = 6371.0  # Earth radius in km
    
    lat1 = math.radians(lat)
    lon1 = math.radians(lon)
    brng = math.radians(bearing_deg)
    
    lat2 = math.asin(math.sin(lat1) * math.cos(distance_km / R) +
                     math.cos(lat1) * math.sin(distance_km / R) * math.cos(brng))
    
    lon2 = lon1 + math.atan2(
        math.sin(brng) * math.sin(distance_km / R) * math.cos(lat1),
        math.cos(distance_km / R) - math.sin(lat1) * math.sin(lat2)
    )
    
    return math.degrees(lat2), math.degrees(lon2)


def generate_sinusoid_gpx(lat, lon, distance_km, filename=None):
    """
    Generate a GPX file with a sinusoidal (sine wave) track.
    
    The route starts at (lat, lon) and extends eastward.
    The path follows: y = amplitude * sin(2 * pi * x / period)
    where x is the horizontal distance from the start point (in km).
    Amplitude and period are each set to 5% of the requested route distance.
    The horizontal span is adjusted so the sinusoid's actual path length
    matches the requested distance.
    
    Args:
        lat: Start latitude in decimal degrees
        lon: Start longitude in decimal degrees
        distance_km: Total route distance in kilometers
        filename: Output filename (optional)
    
    Returns:
        Path to the generated GPX file
    
    Points are spaced no more than 1 meter apart along the route, with denser
    sampling as needed to represent each sinusoid period.
    """
    amplitude_km = distance_km * 0.05
    period_km = distance_km * 0.05
    steps_per_period = 1000
    step_km = period_km / steps_per_period
    cumulative_distance = [0.0]

    def path_speed(x_km):
        slope = (2 * math.pi * amplitude_km / period_km) * math.cos(
            2 * math.pi * x_km / period_km
        )
        return math.sqrt(1 + slope * slope)

    previous_speed = path_speed(0)
    for step in range(1, steps_per_period + 1):
        current_speed = path_speed(step * step_km)
        cumulative_distance.append(
            cumulative_distance[-1]
            + (previous_speed + current_speed) * step_km / 2
        )
        previous_speed = current_speed

    period_path_km = cumulative_distance[-1]
    whole_periods = int(distance_km // period_path_km)
    remaining_distance_km = distance_km - whole_periods * period_path_km
    if remaining_distance_km <= 1e-12:
        horizontal_length_km = whole_periods * period_km
    else:
        index = bisect_left(cumulative_distance, remaining_distance_km)
        before_distance = cumulative_distance[index - 1]
        fraction = (remaining_distance_km - before_distance) / (
            cumulative_distance[index] - before_distance
        )
        horizontal_length_km = (
            whole_periods * period_km + (index - 1 + fraction) * step_km
        )

    point_spacing_km = min(0.001, period_km / 20)
    num_segments = math.ceil(distance_km / point_spacing_km)
    
    if filename is None:
        filename = f"sinusoid_{lat:.4f}_{lon:.4f}_{distance_km}km.gpx"
    
    # Create GPX root element
    gpx = ET.Element('gpx')
    gpx.set('version', '1.1')
    gpx.set('creator', 'processgpx-sinusoid-generator')
    gpx.set('xmlns', 'http://www.topografix.com/GPX/1/1')
    gpx.set('xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance')
    gpx.set('xsi:schemaLocation', 'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd')
    
    # Add metadata
    metadata = ET.SubElement(gpx, 'metadata')
    time_elem = ET.SubElement(metadata, 'time')
    time_elem.text = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
    
    # Create track
    trk = ET.SubElement(gpx, 'trk')
    name = ET.SubElement(trk, 'name')
    name.text = f'Sinusoid at ({lat:.4f}, {lon:.4f}) - {distance_km}km route'
    desc = ET.SubElement(trk, 'desc')
    desc.text = (
        f'Sinusoidal route, target distance: {distance_km}km, '
        f'amplitude: {amplitude_km}km, period: {period_km}km, '
        f'{num_segments + 1} points at up to {point_spacing_km * 1000:g}m spacing'
    )
    
    trkseg = ET.SubElement(trk, 'trkseg')
    
    start_time = datetime.now(timezone.utc)
    
    for i in range(num_segments + 1):
        traveled_km = min(i * point_spacing_km, distance_km)
        whole_periods = int(traveled_km // period_path_km)
        within_period_km = traveled_km - whole_periods * period_path_km
        if within_period_km <= 1e-12:
            x_km = whole_periods * period_km
        else:
            index = bisect_left(cumulative_distance, within_period_km)
            before_distance = cumulative_distance[index - 1]
            fraction = (within_period_km - before_distance) / (
                cumulative_distance[index] - before_distance
            )
            x_km = whole_periods * period_km + (index - 1 + fraction) * step_km

        y_km = amplitude_km * math.sin(2 * math.pi * x_km / period_km)
        
        temp_lat, temp_lon = destination_point(lat, lon, y_km, 0)  # North/South
        new_lat, new_lon = destination_point(temp_lat, temp_lon, x_km, 90)  # East
        
        # Create track point
        trkpt = ET.SubElement(trkseg, 'trkpt')
        trkpt.set('lat', f'{new_lat:.7f}')
        trkpt.set('lon', f'{new_lon:.7f}')
        
        # Add time (evenly spaced)
        time_elem = ET.SubElement(trkpt, 'time')
        time_delta = timedelta(seconds=round(traveled_km * 1000 / 50 * 60))
        time_elem.text = (start_time + time_delta).strftime('%Y-%m-%dT%H:%M:%SZ')
    
    # Write to file
    tree = ET.ElementTree(gpx)
    tree.write(filename, encoding='utf-8', xml_declaration=True)
    
    return filename

def main():
    if len(sys.argv) < 4:
        print("Usage: generate_sinusoid_gpx.py <latitude> <longitude> <distance_km> [output_filename]", file=sys.stderr)
        print("  latitude: Start latitude in decimal degrees", file=sys.stderr)
        print("  longitude: Start longitude in decimal degrees", file=sys.stderr)
        print("  distance_km: Total distance along the sinusoidal route", file=sys.stderr)
        print("  Amplitude and period are each 5% of the route distance", file=sys.stderr)
        print("  output_filename: Output GPX filename (optional)", file=sys.stderr)
        print("  Points are generated at up to 1-meter intervals along the route", file=sys.stderr)
        sys.exit(1)
    
    try:
        lat = float(sys.argv[1])
        lon = float(sys.argv[2])
        distance_km = float(sys.argv[3])
    except ValueError as e:
        print(f"Error: Invalid numeric arguments - {e}", file=sys.stderr)
        sys.exit(1)
    
    if distance_km <= 0:
        print("Error: Distance must be positive", file=sys.stderr)
        sys.exit(1)
    
    # Validate latitude and longitude
    if lat < -90 or lat > 90:
        print("Error: Latitude must be between -90 and 90", file=sys.stderr)
        sys.exit(1)
    if lon < -180 or lon > 180:
        print("Error: Longitude must be between -180 and 180", file=sys.stderr)
        sys.exit(1)
    
    filename = None
    if len(sys.argv) > 4:
        filename = sys.argv[4]
    
    try:
        output_file = generate_sinusoid_gpx(lat, lon, distance_km, filename)
        print(f"✅ GPX sinusoid file generated: {output_file}")
        sys.exit(0)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

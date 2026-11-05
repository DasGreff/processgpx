#!/usr/bin/env python3

import math
import sys
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

def generate_square_gpx(lat, lon, perimeter_km, num_points=100, filename=None):
    """
    Generate a GPX file with a square track.
    
    The start point (lat, lon) is positioned at the MIDDLE of the TOP side.
    The square extends:
    - Left and right by side/2 along the top side
    - Down by side to the bottom side
    
    Args:
        lat: Start latitude (middle of top side) in decimal degrees
        lon: Start longitude (middle of top side) in decimal degrees
        perimeter_km: Perimeter (distance around) of the square in kilometers
        num_points: Number of points to generate for the square (default: 100)
                    Total points in GPX = num_points + 1 (including closing point)
        filename: Output filename (default: square_lat_lon_perimeter.gpx)
    
    Returns:
        Path to the generated GPX file
    """
    R = 6371.0
    side_km = perimeter_km / 4
    half_side_km = side_km / 2
    
    if filename is None:
        filename = f"square_{lat:.4f}_{lon:.4f}_{perimeter_km}km.gpx"
    
    # Create GPX root element
    gpx = ET.Element('gpx')
    gpx.set('version', '1.1')
    gpx.set('creator', 'processgpx-square-generator')
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
    name.text = f'Square at ({lat:.4f}, {lon:.4f}) - {perimeter_km}km perimeter'
    desc = ET.SubElement(trk, 'desc')
    desc.text = f'Square route with {num_points} points, perimeter: {perimeter_km}km, side: {side_km:.2f}km, start at middle of top side'
    
    trkseg = ET.SubElement(trk, 'trkseg')
    
    start_time = datetime.now(timezone.utc)
    
    # The start point (lat, lon) is at the middle of the top side
    # Square path: start(middle top) -> NE -> SE -> SW -> NW -> start
    # Segment distances: half_side(east) -> side(south) -> side(west) -> side(north) -> half_side(east)
    
    # Pre-calculate segment start positions and cumulative distances
    path_segments = [
        (half_side_km, 90),   # start -> NE: east
        (side_km, 180),       # NE -> SE: south
        (side_km, 270),       # SE -> SW: west
        (side_km, 0),         # SW -> NW: north
        (half_side_km, 90),   # NW -> start: east
    ]
    
    # Calculate start position for each segment
    segment_starts = [(lat, lon)]
    for dist, bearing in path_segments[:-1]:
        last_lat, last_lon = segment_starts[-1]
        next_lat, next_lon = destination_point(last_lat, last_lon, dist, bearing)
        segment_starts.append((next_lat, next_lon))
    
    # Calculate cumulative distances at start of each segment
    cumulative_dists = [0.0]
    for dist, bearing in path_segments:
        cumulative_dists.append(cumulative_dists[-1] + dist)
    
    # Generate all points
    all_points = [(lat, lon)]  # Start point
    segment_length = perimeter_km / num_points
    
    for i in range(1, num_points + 1):
        target_distance = i * segment_length
        
        # Find which segment contains this point
        for seg_idx in range(len(path_segments)):
            seg_start = cumulative_dists[seg_idx]
            seg_end = cumulative_dists[seg_idx + 1]
            if seg_start <= target_distance <= seg_end:
                seg_dist, seg_bearing = path_segments[seg_idx]
                seg_start_lat, seg_start_lon = segment_starts[seg_idx]
                offset = target_distance - seg_start
                new_lat, new_lon = destination_point(seg_start_lat, seg_start_lon, offset, seg_bearing)
                all_points.append((new_lat, new_lon))
                break
    
    # Now add all points to the GPX with timestamps
    for i, (new_lat, new_lon) in enumerate(all_points):
        trkpt = ET.SubElement(trkseg, 'trkpt')
        trkpt.set('lat', f'{new_lat:.6f}')
        trkpt.set('lon', f'{new_lon:.6f}')
        
        time_delta = timedelta(seconds=i * 60)
        time_elem = ET.SubElement(trkpt, 'time')
        time_elem.text = (start_time + time_delta).strftime('%Y-%m-%dT%H:%M:%SZ')
    
    # Write to file
    tree = ET.ElementTree(gpx)
    tree.write(filename, encoding='utf-8', xml_declaration=True)
    
    return filename

def main():
    if len(sys.argv) < 4:
        print("Usage: generate_square_gpx.py <latitude> <longitude> <perimeter_km> [num_points] [output_filename]", file=sys.stderr)
        print("  latitude: Start latitude (middle of top side) in decimal degrees", file=sys.stderr)
        print("  longitude: Start longitude (middle of top side) in decimal degrees", file=sys.stderr)
        print("  perimeter_km: Perimeter (distance around) of the square in kilometers", file=sys.stderr)
        print("  num_points: Number of points (default: 100)", file=sys.stderr)
        print("  output_filename: Output GPX filename (optional)", file=sys.stderr)
        sys.exit(1)
    
    try:
        lat = float(sys.argv[1])
        lon = float(sys.argv[2])
        perimeter_km = float(sys.argv[3])
    except ValueError as e:
        print(f"Error: Invalid numeric arguments - {e}", file=sys.stderr)
        sys.exit(1)
    
    if perimeter_km <= 0:
        print("Error: Perimeter must be positive", file=sys.stderr)
        sys.exit(1)
    
    # Validate latitude and longitude
    if lat < -90 or lat > 90:
        print("Error: Latitude must be between -90 and 90", file=sys.stderr)
        sys.exit(1)
    if lon < -180 or lon > 180:
        print("Error: Longitude must be between -180 and 180", file=sys.stderr)
        sys.exit(1)
    
    num_points = 100
    if len(sys.argv) > 4:
        try:
            num_points = int(sys.argv[4])
            if num_points < 4:
                print("Error: num_points must be at least 4", file=sys.stderr)
                sys.exit(1)
        except ValueError:
            print("Error: num_points must be an integer", file=sys.stderr)
            sys.exit(1)
    
    filename = None
    if len(sys.argv) > 5:
        filename = sys.argv[5]
    
    try:
        output_file = generate_square_gpx(lat, lon, perimeter_km, num_points, filename)
        print(f"✅ GPX square file generated: {output_file}")
        sys.exit(0)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

#!/usr/bin/env python3

import math
import sys
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta, timezone

def generate_circle_gpx(lat, lon, circumference_km, num_points=100, filename=None):
    """
    Generate a GPX file with a circular track.
    
    Args:
        lat: Center latitude in decimal degrees
        lon: Center longitude in decimal degrees
        circumference_km: Circumference (distance around) of the circle in kilometers
        num_points: Number of points to generate for the circle (default: 100)
        filename: Output filename (default: circle_lat_lon_circumference.gpx)
    
    Returns:
        Path to the generated GPX file
    """
    # Earth's radius in kilometers
    R = 6371.0
    
    # Calculate radius from circumference: radius = circumference / (2 * pi)
    import math
    radius_km = circumference_km / (2 * math.pi)
    
    if filename is None:
        filename = f"circle_{lat:.4f}_{lon:.4f}_{circumference_km}km.gpx"
    
    # Create GPX root element
    gpx = ET.Element('gpx')
    gpx.set('version', '1.1')
    gpx.set('creator', 'processgpx-circle-generator')
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
    name.text = f'Circle at ({lat:.4f}, {lon:.4f}) - {circumference_km}km circumference'
    desc = ET.SubElement(trk, 'desc')
    desc.text = f'Circular route with {num_points} points, circumference: {circumference_km}km'
    
    trkseg = ET.SubElement(trk, 'trkseg')
    
    # Generate circle points
    start_time = datetime.now(timezone.utc)
    
    for i in range(num_points + 1):  # +1 to close the circle
        angle = 2 * math.pi * i / num_points
        
        # Calculate new latitude and longitude
        # Using haversine formula for destination point with radius calculated from circumference
        new_lat = math.degrees(
            math.asin(
                math.sin(math.radians(lat)) * math.cos(radius_km / R) +
                math.cos(math.radians(lat)) * math.sin(radius_km / R) * math.cos(angle)
            )
        )
        
        new_lon = math.degrees(
            math.radians(lon) +
            math.atan2(
                math.sin(angle) * math.sin(radius_km / R) * math.cos(math.radians(lat)),
                math.cos(radius_km / R) - math.sin(math.radians(lat)) * math.sin(math.radians(new_lat))
            )
        )
        
        # Create track point
        trkpt = ET.SubElement(trkseg, 'trkpt')
        trkpt.set('lat', f'{new_lat:.6f}')
        trkpt.set('lon', f'{new_lon:.6f}')
        
        # Add time (optional, evenly spaced)
        time_elem = ET.SubElement(trkpt, 'time')
        time_delta = timedelta(seconds=i * 60)  # 1 minute per point
        time_elem.text = (start_time + time_delta).strftime('%Y-%m-%dT%H:%M:%SZ')
    
    # Write to file
    tree = ET.ElementTree(gpx)
    tree.write(filename, encoding='utf-8', xml_declaration=True)
    
    return filename

def main():
    if len(sys.argv) < 4:
        print("Usage: generate_circle_gpx.py <latitude> <longitude> <circumference_km> [num_points] [output_filename]", file=sys.stderr)
        print("  latitude: Center latitude in decimal degrees", file=sys.stderr)
        print("  longitude: Center longitude in decimal degrees", file=sys.stderr)
        print("  circumference_km: Circumference (distance around) of the circle in kilometers", file=sys.stderr)
        print("  num_points: Number of points (default: 100)", file=sys.stderr)
        print("  output_filename: Output GPX filename (optional)", file=sys.stderr)
        sys.exit(1)
    
    try:
        lat = float(sys.argv[1])
        lon = float(sys.argv[2])
        circumference_km = float(sys.argv[3])
    except ValueError as e:
        print(f"Error: Invalid numeric arguments - {e}", file=sys.stderr)
        sys.exit(1)
    
    if circumference_km <= 0:
        print("Error: Circumference must be positive", file=sys.stderr)
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
            if num_points < 3:
                print("Error: num_points must be at least 3", file=sys.stderr)
                sys.exit(1)
        except ValueError:
            print("Error: num_points must be an integer", file=sys.stderr)
            sys.exit(1)
    
    filename = None
    if len(sys.argv) > 5:
        filename = sys.argv[5]
    
    try:
        output_file = generate_circle_gpx(lat, lon, circumference_km, num_points, filename)
        print(f"✅ GPX circle file generated: {output_file}")
        sys.exit(0)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()

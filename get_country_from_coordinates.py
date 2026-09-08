#!/usr/bin/env python3

import json
import sys


def contains_ring(point, ring):
    """Check if a point is inside a ring using ray casting algorithm."""
    longitude, latitude = point
    inside = False
    previous_longitude, previous_latitude = ring[-1]

    for current_longitude, current_latitude in ring:
        if (current_latitude > latitude) != (previous_latitude > latitude):
            intersection = (previous_longitude - current_longitude) * (latitude - current_latitude) / (previous_latitude - current_latitude) + current_longitude
            if longitude < intersection:
                inside = not inside
        previous_longitude, previous_latitude = current_longitude, current_latitude

    return inside


def contains_polygon(point, polygon):
    """Check if a point is inside a polygon (with holes support)."""
    return contains_ring(point, polygon[0]) and not any(
        contains_ring(point, hole) for hole in polygon[1:]
    )


def main():
    if len(sys.argv) != 3:
        print("Usage: get_country_from_coordinates.py <latitude> <longitude>", file=sys.stderr)
        sys.exit(1)

    try:
        lat = float(sys.argv[1])
        lon = float(sys.argv[2])
    except ValueError:
        print("❌ Error: Latitude and longitude must be valid numbers", file=sys.stderr)
        sys.exit(1)

    try:
        with open("/usr/local/share/countries.geojson", encoding="utf-8") as f:
            features = json.load(f)["features"]

        point = (lon, lat)

        for feature in features:
            geometry = feature["geometry"]
            if geometry["type"] == "Polygon":
                polygons = [geometry["coordinates"]]
            elif geometry["type"] == "MultiPolygon":
                polygons = geometry["coordinates"]
            else:
                continue

            for polygon in polygons:
                if contains_polygon(point, polygon):
                    country_name = feature["properties"].get("name", "Unknown")
                    country_code = feature["properties"].get("ISO3166-1-Alpha-3", "???")
                    print(f"{country_name} ({country_code})")
                    sys.exit(0)

        # No country found, return default
        print("Middle of Nowhere (NOW)")
        sys.exit(0)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()

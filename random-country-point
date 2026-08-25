#!/usr/bin/env python3

import json
import random
import sys


def contains_ring(point, ring):
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
    return contains_ring(point, polygon[0]) and not any(
        contains_ring(point, hole) for hole in polygon[1:]
    )


def polygon_area(polygon):
    ring = polygon[0]
    return abs(sum(
        longitude * next_latitude - next_longitude * latitude
        for (longitude, latitude), (next_longitude, next_latitude) in zip(ring, ring[1:] + ring[:1])
    )) / 2


def random_point(polygon):
    ring = polygon[0]
    longitudes, latitudes = zip(*ring)
    minimum_longitude, maximum_longitude = min(longitudes), max(longitudes)
    minimum_latitude, maximum_latitude = min(latitudes), max(latitudes)

    for _ in range(10_000):
        point = (
            random.uniform(minimum_longitude, maximum_longitude),
            random.uniform(minimum_latitude, maximum_latitude),
        )
        if contains_polygon(point, polygon):
            return point

    raise RuntimeError("unable to select a point within the country polygon")


def main():
    if len(sys.argv) != 2:
        raise RuntimeError("usage: random-country-point <ISO-3166-1-alpha-3|RANDOM>")

    country_code = sys.argv[1].upper()
    with open("/usr/local/share/countries.geojson", encoding="utf-8") as geojson_file:
        features = json.load(geojson_file)["features"]

    if country_code == "RANDOM":
        candidates = [
            candidate
            for candidate in features
            if candidate["properties"].get("ISO3166-1-Alpha-3")
        ]
        if not candidates:
            raise RuntimeError("no country polygon found in geojson dataset")
        feature = random.choice(candidates)
        country_code = feature["properties"]["ISO3166-1-Alpha-3"]
    else:
        feature = next(
            (
                candidate
                for candidate in features
                if candidate["properties"].get("ISO3166-1-Alpha-3") == country_code
            ),
            None,
        )
        if feature is None:
            raise RuntimeError(f"no country polygon found for {country_code}")

    geometry = feature["geometry"]
    polygons = [geometry["coordinates"]] if geometry["type"] == "Polygon" else geometry["coordinates"]
    if geometry["type"] not in {"Polygon", "MultiPolygon"}:
        raise RuntimeError(f"unsupported geometry type for {country_code}: {geometry['type']}")

    point = random.choices(polygons, weights=[polygon_area(polygon) for polygon in polygons])[0]
    longitude, latitude = random_point(point)
    country_name = feature["properties"].get("name", country_code)
    print(f"{latitude:.4f} {longitude:.4f} {country_code} {country_name}")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, ValueError, KeyError, json.JSONDecodeError) as error:
        print(f"Error: {error}", file=sys.stderr)
        sys.exit(1)
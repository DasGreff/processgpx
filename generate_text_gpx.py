#!/usr/bin/env python3

import math
import sys
import xml.etree.ElementTree as ET
from datetime import datetime, timedelta, timezone


FONT = {
    "A": [[(0, 0), (0.5, 1), (1, 0)], [(0.2, 0.4), (0.8, 0.4)]],
    "B": [[(0, 0), (0, 1), (0.65, 1), (1, 0.85), (1, 0.65), (0.65, 0.5),
           (0, 0.5)], [(0.65, 0.5), (1, 0.35), (1, 0.15), (0.65, 0), (0, 0)]],
    "C": [[(1, 0.85), (0.75, 1), (0.2, 1), (0, 0.8), (0, 0.2),
           (0.2, 0), (0.75, 0), (1, 0.15)]],
    "D": [[(0, 0), (0, 1), (0.6, 1), (1, 0.75), (1, 0.25), (0.6, 0), (0, 0)]],
    "E": [[(1, 1), (0, 1), (0, 0), (1, 0)], [(0, 0.5), (0.8, 0.5)]],
    "F": [[(0, 0), (0, 1), (1, 1)], [(0, 0.5), (0.8, 0.5)]],
    "G": [[(1, 0.85), (0.75, 1), (0.2, 1), (0, 0.8), (0, 0.2),
           (0.2, 0), (1, 0), (1, 0.45), (0.55, 0.45)]],
    "H": [[(0, 0), (0, 1)], [(1, 0), (1, 1)], [(0, 0.5), (1, 0.5)]],
    "I": [[(0.15, 1), (0.85, 1)], [(0.5, 1), (0.5, 0)], [(0.15, 0), (0.85, 0)]],
    "J": [[(0.15, 1), (1, 1), (1, 0.2), (0.8, 0), (0.25, 0), (0, 0.2)]],
    "K": [[(0, 0), (0, 1)], [(1, 1), (0, 0.5), (1, 0)]],
    "L": [[(0, 1), (0, 0), (1, 0)]],
    "M": [[(0, 0), (0, 1), (0.5, 0.5), (1, 1), (1, 0)]],
    "N": [[(0, 0), (0, 1), (1, 0), (1, 1)]],
    "O": [[(0.2, 0), (0, 0.2), (0, 0.8), (0.2, 1), (0.8, 1),
           (1, 0.8), (1, 0.2), (0.8, 0), (0.2, 0)]],
    "P": [[(0, 0), (0, 1), (0.7, 1), (1, 0.8), (1, 0.65),
           (0.7, 0.5), (0, 0.5)]],
    "Q": [[(0.2, 0), (0, 0.2), (0, 0.8), (0.2, 1), (0.8, 1),
           (1, 0.8), (1, 0.2), (0.8, 0), (0.2, 0)], [(0.9, 0.1), (1.1, -0.1)]],
    "R": [[(0, 0), (0, 1), (0.7, 1), (1, 0.8), (1, 0.65),
           (0.7, 0.5), (0, 0.5)], [(0.5, 0.5), (1, 0)]],
    "S": [[(1, 0.85), (0.8, 1), (0.2, 1), (0, 0.8), (0.2, 0.55),
           (0.8, 0.45), (1, 0.2), (0.8, 0), (0.2, 0), (0, 0.15)]],
    "T": [[(0, 1), (1, 1)], [(0.5, 1), (0.5, 0)]],
    "U": [[(0, 1), (0, 0.2), (0.2, 0), (0.8, 0), (1, 0.2), (1, 1)]],
    "V": [[(0, 1), (0.5, 0), (1, 1)]],
    "W": [[(0, 1), (0.2, 0), (0.5, 0.5), (0.8, 0), (1, 1)]],
    "X": [[(0, 1), (0.46, 0.54)], [(0.54, 0.46), (1, 0)],
          [(0, 0), (0.46, 0.46)], [(0.54, 0.54), (1, 1)]],
    "Y": [[(0, 1), (0.5, 0.5), (1, 1)], [(0.5, 0.5), (0.5, 0)]],
    "Z": [[(0, 1), (1, 1), (0, 0), (1, 0)]],
    "0": [[(0.2, 0), (0, 0.2), (0, 0.8), (0.2, 1), (0.8, 1),
           (1, 0.8), (1, 0.2), (0.8, 0), (0.2, 0)]],
    "1": [[(0.15, 0.75), (0.5, 1), (0.5, 0)], [(0.2, 0), (0.8, 0)]],
    "2": [[(0, 0.8), (0.2, 1), (0.8, 1), (1, 0.8), (1, 0.65),
           (0, 0), (1, 0)]],
    "3": [[(0, 0.85), (0.2, 1), (0.8, 1), (1, 0.8), (0.55, 0.52),
           (1, 0.25), (1, 0.15), (0.8, 0), (0.2, 0), (0, 0.15)]],
    "4": [[(0.8, 0), (0.8, 0.46)], [(0.8, 0.54), (0.8, 1)],
          [(0, 0.5), (0.8, 0.5), (1, 0.5)], [(0, 0.35), (0.8, 0.5)]],
    "5": [[(1, 1), (0.15, 1), (0.1, 0.55), (0.75, 0.55),
           (1, 0.35), (1, 0.15), (0.8, 0), (0.2, 0), (0, 0.15)]],
    "6": [[(0.9, 0.9), (0.7, 1), (0.2, 1), (0, 0.75), (0, 0.2),
           (0.2, 0), (0.8, 0), (1, 0.2), (1, 0.35), (0.8, 0.5),
           (0, 0.5)]],
    "7": [[(0, 1), (1, 1), (0.35, 0)]],
    "8": [[(0.2, 0.5), (0, 0.65), (0, 0.85), (0.2, 1), (0.8, 1),
           (1, 0.85), (1, 0.65), (0.8, 0.5), (0.2, 0.5), (0, 0.35),
           (0, 0.15), (0.2, 0), (0.8, 0), (1, 0.15), (1, 0.35), (0.8, 0.5)]],
    "9": [[(1, 0.5), (0.2, 0.5), (0, 0.65), (0, 0.8), (0.2, 1),
           (0.8, 1), (1, 0.8), (1, 0.25), (0.8, 0), (0.2, 0), (0, 0.1)]],
    "-": [[(0.1, 0.5), (0.9, 0.5)]],
    ".": [[(0.5, 0.02), (0.5, 0.04)]],
    ",": [[(0.5, 0.04), (0.4, -0.08)]],
    "!": [[(0.5, 0.25), (0.5, 1)], [(0.5, 0.02), (0.5, 0.04)]],
    "?": [[(0, 0.8), (0.2, 1), (0.8, 1), (1, 0.8), (1, 0.65),
           (0.5, 0.4), (0.5, 0.25)], [(0.5, 0.02), (0.5, 0.04)]],
    "'": [[(0.5, 1), (0.4, 0.75)]],
    ":": [[(0.5, 0.7), (0.5, 0.72)], [(0.5, 0.02), (0.5, 0.04)]],
}

LETTER_WIDTH_RATIO = 0.8
LETTER_GAP_RATIO = 0.4
DEFAULT_LETTER_HEIGHT_M = 250
MAX_POINT_SPACING_M = 1
EARTH_RADIUS_KM = 6371.0


def destination_point(lat, lon, east_m, north_m):
    distance_km = math.hypot(east_m, north_m) / 1000
    bearing = math.atan2(east_m, north_m)
    angular_distance = distance_km / EARTH_RADIUS_KM
    lat1 = math.radians(lat)
    lon1 = math.radians(lon)

    lat2 = math.asin(
        math.sin(lat1) * math.cos(angular_distance)
        + math.cos(lat1) * math.sin(angular_distance) * math.cos(bearing)
    )
    lon2 = lon1 + math.atan2(
        math.sin(bearing) * math.sin(angular_distance) * math.cos(lat1),
        math.cos(angular_distance) - math.sin(lat1) * math.sin(lat2),
    )
    return math.degrees(lat2), math.degrees(lon2)


def text_strokes(text, letter_height_m):
    width_m = letter_height_m * LETTER_WIDTH_RATIO
    gap_m = letter_height_m * LETTER_GAP_RATIO
    cursor_x = 0.0
    for character in text.upper():
        if character == " ":
            cursor_x += width_m + gap_m
            continue
        if character not in FONT:
            raise ValueError(f"Unsupported character: {character!r}")

        for stroke in FONT[character]:
            yield [
                (cursor_x + x * width_m, y * letter_height_m)
                for x, y in stroke
            ]
        cursor_x += width_m + gap_m


def write_track_segment(track, stroke, lat, lon, start_time, elapsed_seconds):
    trkseg = ET.SubElement(track, "trkseg")
    points = [(stroke[0][0], stroke[0][1], 0.0)]
    stroke_duration = 0.0
    for start, end in zip(stroke, stroke[1:]):
        east_delta = end[0] - start[0]
        north_delta = end[1] - start[1]
        length = math.hypot(east_delta, north_delta)
        steps = max(1, math.ceil(length / MAX_POINT_SPACING_M))
        for step in range(1, steps + 1):
            fraction = step / steps
            points.append(
                (
                    start[0] + east_delta * fraction,
                    start[1] + north_delta * fraction,
                    stroke_duration + length * fraction / 1.4,
                )
            )
        stroke_duration += length / 1.4

    for east_m, north_m, point_elapsed_seconds in points:
        point_lat, point_lon = destination_point(lat, lon, east_m, north_m)
        trkpt = ET.SubElement(trkseg, "trkpt")
        trkpt.set("lat", f"{point_lat:.7f}")
        trkpt.set("lon", f"{point_lon:.7f}")
        time_elem = ET.SubElement(trkpt, "time")
        time_elem.text = (
            start_time + timedelta(seconds=elapsed_seconds + point_elapsed_seconds)
        ).strftime(
            "%Y-%m-%dT%H:%M:%SZ"
        )
    return elapsed_seconds + stroke_duration


def generate_text_gpx(lat, lon, text, filename=None):
    if not text.strip():
        raise ValueError("Text must not be empty")

    gpx = ET.Element("gpx")
    gpx.set("version", "1.1")
    gpx.set("creator", "processgpx-text-generator")
    gpx.set("xmlns", "http://www.topografix.com/GPX/1/1")
    gpx.set("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance")
    gpx.set(
        "xsi:schemaLocation",
        "http://www.topografix.com/GPX/1/1 "
        "http://www.topografix.com/GPX/1/1/gpx.xsd",
    )

    metadata = ET.SubElement(gpx, "metadata")
    metadata_time = ET.SubElement(metadata, "time")
    metadata_time.text = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    start_time = datetime.now(timezone.utc)
    elapsed_seconds = 0.0
    strokes = list(text_strokes(text, DEFAULT_LETTER_HEIGHT_M))
    for stroke_index, stroke in enumerate(strokes, start=1):
        track = ET.SubElement(gpx, "trk")
        name = ET.SubElement(track, "name")
        name.text = f'Text "{text}" - stroke {stroke_index}/{len(strokes)}'
        description = ET.SubElement(track, "desc")
        description.text = (
            f'Text "{text}" drawn with {DEFAULT_LETTER_HEIGHT_M}m-high letters'
        )
        elapsed_seconds = write_track_segment(
            track, stroke, lat, lon, start_time, elapsed_seconds
        )

    if filename is None:
        safe_text = "".join(
            character if character.isalnum() else "_" for character in text.upper()
        ).strip("_")
        filename = f"text_{safe_text or 'track'}.gpx"

    ET.ElementTree(gpx).write(filename, encoding="utf-8", xml_declaration=True)
    return filename


def main():
    if len(sys.argv) not in (4, 5):
        print(
            "Usage: generate_text_gpx.py <latitude> <longitude> <text> [output_filename]",
            file=sys.stderr,
        )
        sys.exit(1)

    try:
        lat = float(sys.argv[1])
        lon = float(sys.argv[2])
    except ValueError as error:
        print(f"Error: Invalid coordinates - {error}", file=sys.stderr)
        sys.exit(1)

    if not -90 <= lat <= 90:
        print("Error: Latitude must be between -90 and 90", file=sys.stderr)
        sys.exit(1)
    if not -180 <= lon <= 180:
        print("Error: Longitude must be between -180 and 180", file=sys.stderr)
        sys.exit(1)

    filename = sys.argv[4] if len(sys.argv) == 5 else None
    try:
        output_file = generate_text_gpx(lat, lon, sys.argv[3], filename)
    except (OSError, ValueError) as error:
        print(f"Error: {error}", file=sys.stderr)
        sys.exit(1)
    print(f"GPX text file generated: {output_file}")


if __name__ == "__main__":
    main()

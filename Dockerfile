FROM perl:5.44-slim-trixie

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY random-country-point /usr/local/bin/random-country-point
COPY get_country_from_coordinates.py /usr/local/bin/get_country_from_coordinates.py
COPY countries.geojson /usr/local/share/countries.geojson

RUN apt update && \
    apt upgrade -y && \
    apt install -y jq git cpanminus build-essential libxml2-dev libexpat1-dev python3 && \
    cpanm --notest --force Getopt::Long XML::Descent POSIX Date::Parse Pod::Usage Geo::Gpx JSON && \
    rm -rf /var/lib/apt/lists/* && \
    git clone https://github.com/djconnel/processGPX.git /opt/processGPX && \
    chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/random-country-point /usr/local/bin/get_country_from_coordinates.py

WORKDIR /opt/processGPX

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

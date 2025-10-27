FROM perl:5.43-slim-trixie

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apt update && \
    apt upgrade -y && \
    apt install -y git cpanminus build-essential libxml2-dev libexpat1-dev && \
    cpanm --force Getopt::Long XML::Descent POSIX Date::Parse Pod::Usage Geo::Gpx && \
    rm -rf /var/lib/apt/lists/* && \
    git clone https://github.com/djconnel/processGPX.git /opt/processGPX && \
    chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /opt/processGPX

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

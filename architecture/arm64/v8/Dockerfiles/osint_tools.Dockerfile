## Taking Image from Docker Hub for Programming language support
FROM ghcr.io/rajanagori/nightingale_programming_image:arm64
## Installing tools using apt-get for web vapt
RUN \
    apt-get update -y && \
    apt-get -f --no-install-recommends install -y \
    git \
    make \
    cmake \
    bundler \
    libxml2 \
    libxslt1-dev \
    pipx && \
    # Create directories for tools
    mkdir -p /home/tools_osint

ENV TOOLS_OSINT=/home/tools_osint

# Set working directory
WORKDIR ${TOOLS_OSINT}

# Clone tools repository
RUN git clone --depth 1 https://github.com/lanmaster53/recon-ng.git && \
    git clone --depth 1 https://github.com/smicallef/spiderfoot.git && \
    git clone --depth 1 https://github.com/opsdisk/metagoofil && \
    git clone --depth 1 https://github.com/laramies/theHarvester

# Install recon-ng requirements
RUN cd recon-ng && \
    while read p; do pipx install "$p"; done < REQUIREMENTS && \
    cd ..

# Install Spiderfoot requirements
RUN cd spiderfoot && \
    pip3 install -r requirements.txt --break-system-packages && \
    cd ..

# Install metagoofil requirements
RUN cd metagoofil && \
    python3 -m venv venv && \
    while read p; do pipx install -f --include-deps "$p"; done < requirements.txt && \
    cd ..

# Install theHarvester requirements
RUN cd theHarvester && \
    pip3 install -r requirements/base.txt --break-system-packages && \
    cd ..

# Clean up unnecessary files and libraries
RUN apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* && \
    echo 'export PATH="$PATH:/root/.local/bin"' >> ~/.bashrc

# Set final working directory
WORKDIR /home
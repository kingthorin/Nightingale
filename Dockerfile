# Pulling the base image
FROM debian:latest

MAINTAINER Raja Nagori <rajanagori19@gmail.com>

# Installing Dependencies for kali linux environment
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install -y python3-pip python3-dev &&\
    cd /usr/local/bin &&\
    ln -s /usr/bin/python3 python &&\
    pip3 install --upgrade pip
    
RUN apt-get install -y --no-install-recommends \
    git \
    ruby \
    ruby-dev \
    libcurl4-openssl-dev \
    make \
    software-properties-common \
    curl \
    ca-certificates \
    gnupg \
    libz-dev \
    libiconv-hook1 \
    libiconv-hook-dev \  
    build-essential \
    patch \
    ruby-bundler \
    zlib1g-dev \
    liblzma-dev \
    autoconf \
    libpcap-dev \
    libpq-dev \
    libsqlite3-dev \
    postgresql \
    postgresql-contrib \
    postgresql-client \
    dialog apt-utils \
    nasm

RUN gem install nokogiri 

#Working Directory of tools
RUN cd /home/$USER &&\
    mkdir tool-for-pentester &&\
    cd tool-for-pentester

WORKDIR /home/tool-for-pentester/

# Installing WP-Scan 
RUN git clone https://github.com/wpscanteam/wpscan.git &&\
    cd wpscan &&\
    gem install bundler && \
    bundle install --without test &&\
    gem install wpscan

# Installing SqlMap
RUN git clone https://github.com/sqlmapproject/sqlmap.git &&\
    cd sqlmap

# Installing Dirbuster
RUN apt-get install -y dirb

#Installing Nmap
RUN apt-get install -y nmap

# Installing Impact toolkit for Red-Team 
RUN git clone https://github.com/SecureAuthCorp/impacket.git &&\
    cd impacket &&\
    pip3 install -r requirements.txt &&\
    python setup.py build &&\
    python setup.py install

# Installing HawkScan 
RUN git clone https://github.com/c0dejump/HawkScan.git &&\
    cd HawkScan &&\
    pip3 install $(grep -ivE "urllib" requirements.txt) &&\
    python3 setup.py

# Clone Seclist
RUN git clone https://github.com/danielmiessler/SecLists.git

# Installing automation tool for ofensive security expert
RUN git clone https://github.com/1N3/Sn1per.git

# Installing Metasploit-framework
## PosgreSQL DB
COPY ./configuration/msf-configuration/scripts/db.sql /tmp/

## Startup script
COPY ./configuration/msf-configuration/scripts/init.sh /usr/local/bin/init.sh

## Installation
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
  && git clone https://github.com/rapid7/metasploit-framework.git \
  && cd metasploit-framework \
  && git fetch --tags \
  && latestTag=$(git describe --tags `git rev-list --tags --max-count=1`) \
  && git checkout $latestTag \
  && bundle install \
  && /etc/init.d/postgresql start && su postgres -c "psql -f /tmp/db.sql" \
  && apt-get -y remove --purge build-essential patch ruby-dev zlib1g-dev liblzma-dev git autoconf build-essential libpcap-dev libpq-dev libsqlite3-dev \
  dialog apt-utils \
  && rm -rf /var/lib/apt/lists/*
 
## DB config
COPY ./configuration/msf-configuration/conf/database.yml /home/tool-for-pentester/metasploit-framework/config/ 

## Configuration and sharing folders
VOLUME ~/.msf4: /root/.msf4/
VOLUME /tmp/msf: /tmp/data/

CMD "./configuration/msf-configuration/scripts/init.sh"

#Installing Tor
RUN apt-get install tor

# Expose the service ports
EXPOSE 5432
EXPOSE 9990-9999

# Cleaning Unwanted libraries 
RUN apt-get -y autoremove &&\
    apt-get -y clean


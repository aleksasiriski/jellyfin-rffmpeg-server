FROM docker.io/jellyfin/jellyfin:10.8.8

RUN apt update && \
    apt install --no-install-recommends --no-install-suggests -y openssh-client python3-click python3-yaml wget

RUN mkdir -p /usr/local/bin && \
    wget https://raw.githubusercontent.com/joshuaboniface/rffmpeg/master/rffmpeg -O /usr/local/bin/rffmpeg && \
    chmod +x /usr/local/bin/rffmpeg && \
    ln -s /usr/local/bin/rffmpeg /usr/local/bin/ffmpeg && \
    ln -s /usr/local/bin/rffmpeg /usr/local/bin/ffprobe

RUN mkdir -p /etc/rffmpeg && \
    wget https://raw.githubusercontent.com/joshuaboniface/rffmpeg/master/rffmpeg.yml.sample -O /etc/rffmpeg/rffmpeg.yml && \
    sed -i 's;#logfile: "/var/log/jellyfin/rffmpeg.log";logfile: "/config/log/rffmpeg.log";' /etc/rffmpeg/rffmpeg.yml && \
    sed -i 's;#state: "/var/lib/rffmpeg";state: "/config/rffmpeg";' /etc/rffmpeg/rffmpeg.yml && \
    sed -i 's;#persist: "/run/shm";persist: "/run";' /etc/rffmpeg/rffmpeg.yml && \
    sed -i 's;#owner: jellyfin;owner: root;' /etc/rffmpeg/rffmpeg.yml && \
    sed -i 's;#group: sudo;group: root;' /etc/rffmpeg/rffmpeg.yml && \
    sed -i 's;#user: jellyfin;user: root;' /etc/rffmpeg/rffmpeg.yml && \
    sed -i 's;#args:;args:;' /etc/rffmpeg/rffmpeg.yml && \
    sed -i 's;#    - "-i";    - "-i";' /etc/rffmpeg/rffmpeg.yml && \
    sed -i 's;#    - "/var/lib/jellyfin/id_rsa";    - "/config/rffmpeg/.ssh/id_rsa";' /etc/rffmpeg/rffmpeg.yml

RUN /usr/local/bin/rffmpeg init -y && \
    mkdir -p /config/rffmpeg/.ssh && \
    chmod 700 /config/rffmpeg/.ssh && \
    ssh-keygen -t rsa -f /config/rffmpeg/.ssh/id_rsa -q -N ""

RUN apt purge wget -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt autoremove --purge -y && \
    apt clean

ENTRYPOINT ["./jellyfin/jellyfin", \
    "--datadir", "/config", \
    "--cachedir", "/cache", \
    "--ffmpeg", "/usr/local/bin/ffmpeg"]

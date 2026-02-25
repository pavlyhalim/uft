FROM ubuntu:22.04

RUN apt-get update -qq && \
    apt-get install -y -qq --no-install-recommends \
        bash \
        openssh-client \
        tar \
        lz4 \
        zstd \
        pv \
        pigz \
        rsync \
        netcat-openbsd \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY bin/uft /usr/local/bin/uft
RUN chmod +x /usr/local/bin/uft

ENTRYPOINT ["uft"]

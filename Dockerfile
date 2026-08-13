FROM debian:stable-slim

LABEL org.opencontainers.image.authors="https://github.com/tolvos"
LABEL org.opencontainers.image.description="An OCI container built to act as an isolated IHP (Integrated Haskell Platform) developer environment."
LABEL org.opencontainers.image.documentation="https://github.com/tolvos/ihp-oci#ihp-via-oci"
LABEL org.opencontainers.image.licenses="Unlicense"
LABEL org.opencontainers.image.source="https://github.com/tolvos/ihp-oci"
LABEL org.opencontainers.image.title="IHP via OCI Container"
LABEL org.opencontainers.image.url="https://github.com/tolvos/ihp-oci"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    git \
    nano \
    procps \
    xz-utils \
    build-essential \
    pkg-config \
    libgmp10 \
    libncursesw6 \
    liblzma5 \
    libbz2-1.0 \
    libzstd1 \
    libffi8 \
    postgresql-client \
    locales \
    && rm -rf /var/lib/apt/lists/*
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8

RUN useradd -m -s /bin/bash developer && \
    passwd -l root && \
    mkdir -p /nix && \
    chown developer:developer /nix
USER developer
ENV USER=developer \
    HOME=/home/developer \
    NIX_CONF_DIR=/home/developer/.config/nix

WORKDIR /home/developer
RUN mkdir -p .config/nix .local/state/nix/profiles
COPY --chown=developer:developer nix.conf .config/nix/nix.conf
COPY --chown=developer:developer flake.nix flake.lock ./
RUN curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install \
    | sh -s -- --no-daemon --yes \
    && . ".nix-profile/etc/profile.d/nix.sh" \
    && nix profile add .
COPY --chown=developer:developer .bash_profile ./
RUN mkdir -p /home/developer/app

ENTRYPOINT ["/bin/bash"]
CMD ["--login"]

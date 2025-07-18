# Use a Debian base image with common tools
FROM mcr.microsoft.com/devcontainers/base:debian

# Install bash, curl, and docker CLI
RUN apt-get update && \
    apt-get install -y \
    bash \
    curl \
    docker.io \
    iputils-ping \
    vim \
    git \
    unzip && \
    apt-get clean

# Install Packer
RUN curl -fsSL https://releases.hashicorp.com/packer/1.10.3/packer_1.10.3_linux_amd64.zip -o /tmp/packer.zip \
    && unzip /tmp/packer.zip -d /usr/local/bin \
    && rm /tmp/packer.zip

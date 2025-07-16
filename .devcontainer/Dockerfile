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
    git && \
    apt-get clean

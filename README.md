# Home Lab

This repository contains scripts and configuration files for setting up and managing my home lab environment.

## Overview

My home lab is built behind a basic Orbi router and runs on an Intel Xeon NUC. I use virtual machines (VMs) for testing various scenarios, frequently creating and destroying them as needed.

Some scripts in this repository were generated with the help of GitHub Copilot.

## Scripts

| Script                   | Description                                                                                   |
|--------------------------|-----------------------------------------------------------------------------------------------|
| `avahi-daemon-setup.sh`  | Installs and configures `avahi-daemon` on Ubuntu instances to support local DNS resolution.   |

## Useful Commands

Convert Windows line endings to Linux format:

```bash
sed -i 's/\r$//'
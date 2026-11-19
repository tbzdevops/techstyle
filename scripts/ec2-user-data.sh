#!/bin/bash
# User Data für die EC2-Instanz (Ubuntu Server 24.04 LTS).
# Läuft einmal beim ersten Start und installiert Docker mit dem Compose-Plugin.
set -eu
apt-get update -y
apt-get install -y docker.io docker-compose-v2
usermod -aG docker ubuntu
systemctl enable --now docker

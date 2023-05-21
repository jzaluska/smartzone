#!/bin/bash

read -p "Czy chcesz zainstalować lxqt? " if_lxqt
read -p "Czy chcesz zainstalować NextCloud? " if_nextcloud

# aktualizacje
sudo apt update
sudo apt upgrade -y

# instalowanie zależności
sudo apt install ca-certificates curl gnupg lsb-release -y

# Dodanie docker GPG key do KeyRing
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# dodanie repozytorium do dockera
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# instalowanie dockera (z pluginem docker compose)
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# instalowanie cloudflared
curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && 
sudo dpkg -i cloudflared.deb && 
sudo cloudflared service install eyJhIjoiMWIyMTRlZmI5OWI4MDU2Njg2YWFlMGNhZWRlYmJhMmYiLCJ0IjoiZDNjM2IzZTMtYmY3ZS00MWY5LWJiOTEtNjEyZDM1ZTRiZjJjIiwicyI6Ik16QmhaRGN4TkRjdE9URXdNaTAwWlRsbUxXSXdPV0l0TXpRMk5UUTRNbUUyTXpkbSJ9
# ^tutaj token musi być pobrany od użytkownika

# kopiowanie configu do home assistanta z trusted proxy i ikonkami w menu
use_x_forwarded_for: true
  trusted_proxies:
    - 172.30.33.0/24
    - 172.18.0.0/16
    
panel_iframe:
  portainer:
    title: "Portainer"
    url: "http://localhost:9000/#/containers"
    icon: mdi:docker
    require_admin: true
  nextcloud:
    title: "NextCloud"
    url: "http://localhost:8080"
    icon: mdi:cloud
    require_admin: true

# uruchamianie kilku plików .yml jedną komendą
# docker-compose -f docker-compose.yml -f docker-compose-mongo.yml up -d

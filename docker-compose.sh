#!/bin/bash

read -p "Czy chcesz zainstalować lxqt? " if_lxqt
read -p "Czy chcesz zainstalować NextCloud? " if_nextcloud
read -p "Podaj token do cloudflared? " cloudflared_token

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
sudo curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && 
sudo dpkg -i cloudflared.deb && 
sudo cloudflared service install $cloudflared_token
# ^tutaj token musi być pobrany od użytkownika


# kopiowanie dockera compose z repozytorium i uruchamianie kontenerów
sudo mv docker-compose.yml /opt/docker-compose.yml

sudo docker compose -f /opt/docker-compose.yml up -d

# kopiowanie configu do home assistanta z trusted proxy i ikonkami w menu
sudo echo "http: 
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.30.33.0/24
    - 172.18.0.0/16
    - 172.18.0.2
    - $(hostname -I | cut -d ' ' -f1)" | sudo tee -a /opt/homeassistant/config/configuration.yaml
    
if [ "$if_lxqt" == "y" ]; then
  sudo apt install -y lxqt-core sddm
fi

if [ "$if_nextcloud" == "y" ]; then
  sudo apt install -y snapd
  sudo snap install nextcloud
fi

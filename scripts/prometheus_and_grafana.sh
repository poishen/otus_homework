#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install prometheus -y


sudo apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/oss/release/grafana_10.0.3_amd64.deb
sudo dpkg -i grafana-enterprise_11.5.2_amd64.deb


sudo systemctl daemon-reload
sudo systemctl enable grafana-server prometheus
sudo systemctl restart grafana-server prometheus




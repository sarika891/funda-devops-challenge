#!/bin/bash
 #Installing prometheus
 echo "start installing prometheus"
 sudo useradd --no-create-home --shell /bin/false prometheus
 sudo mkdir /etc/prometheus
 sudo mkdir /var/lib/prometheus
 sudo chown prometheus:prometheus /etc/prometheus
 sudo chown prometheus:prometheus /var/lib/prometheus
 cd ~
 curl -LO https://github.com/prometheus/prometheus/releases/download/v2.16.0/prometheus-2.16.0.linux-amd64.tar.gz
 tar xvf prometheus-2.16.0.linux-amd64.tar.gz
 sudo cp prometheus-2.16.0.linux-amd64/prometheus /usr/local/bin/
 sudo cp prometheus-2.16.0.linux-amd64/promtool /usr/local/bin/
 sudo chown prometheus:prometheus /usr/local/bin/prometheus
 sudo chown prometheus:prometheus /usr/local/bin/promtool
 sudo cp -r prometheus-2.16.0.linux-amd64/consoles /etc/prometheus
 sudo cp -r prometheus-2.16.0.linux-amd64/console_libraries /etc/prometheus
 sudo chown -R prometheus:prometheus /etc/prometheus/consoles
 sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
 rm -rf prometheus-2.16.0.linux-amd64.tar.gz prometheus-2.16.0.linux-amd64
 sudo cp ./prometheus.yml /etc/prometheus/prometheus.yml 
 sudo cp ./alertrule.yml /etc/prometheus/alertrule.yml 
 sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml
 sudo -u prometheus /usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --web.enable-lifecycle &
 
 
  #Installing alertmanagers
 echo "start installing alertmanager"
 cd ~
 curl -LO https://github.com/prometheus/alertmanager/releases/download/v0.20.0/alertmanager-0.20.0.linux-amd64.tar.gz
 tar xvf alertmanager-0.20.0.linux-amd64.tar.gz
 sudo mv alertmanager-0.20.0.linux-amd64/alertmanager /usr/local/bin
 sudo mv alertmanager-0.20.0.linux-amd64/amtool /usr/local/bin
 sudo chown alertmanager:alertmanager /usr/local/bin/alertmanager
 sudo chown alertmanager:alertmanager /usr/local/bin/amtool
 sudo mkdir /etc/alertmanager
 sudo chown alertmanager:alertmanager /etc/alertmanager
 rm -rf alertmanager-0.20.0.linux-amd64 alertmanager-0.20.0.linux-amd64.tar.gz
 sudo cp ./alertmanager.yaml /etc/alertmanager/alertmanager.yaml
 sudo /usr/local/bin/alertmanager --config.file /etc/alertmanager/alertmanager.yaml --web.external-url http://localhost:9093 &


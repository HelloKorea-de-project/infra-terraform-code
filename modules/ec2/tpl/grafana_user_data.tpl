#!/bin/bash
${ssh_setting}

sudo apt update
sudo apt install build-essential -y

wget https://github.com/prometheus/prometheus/releases/download/v2.40.6/prometheus-2.40.6.linux-amd64.tar.gz
tar xvfz prometheus-*.tar.gz # tar 압축 풀기
mv prometheus-2.40.6.linux-amd64 prometheus # 경로를 prometheus로 이름 변경
cd prometheus # prometheus 경로에 들어가서 
export PROMETHEUS_HOME=$(pwd) # home 설정

cat << 'EOF' > /home/ubuntu/prometheus_startup_setup.sh
#!/bin/bash
/home/ubuntu/prometheus/prometheus --config.file /home/ubuntu/prometheus/prometheus.yml
EOF

chmod +x /home/ubuntu/prometheus_startup_setup.sh


sudo cat << 'EOF' > /etc/systemd/system/prometheus_startup.service
[Unit]
Description=Grafana Startup Script
After=network.target

[Service]
ExecStart=/home/ubuntu/prometheus_startup_setup.sh
User=ubuntu
Restart=faliure

[Install]
WantedBy=multi-user.target
EOF

cat << 'EOF' > /home/ubuntu/grafa_startup_setup.sh
#!/bin/bash
cd /home/ubuntu/grafana
/home/ubuntu/grafana/bin/grafana-server
EOF

chmod +x /home/ubuntu/grafa_startup_setup.sh

sudo cat << 'EOF' > /etc/systemd/system/grafana_startup.service
[Unit]
Description=Grafana Startup Script
After=network.target

[Service]
ExecStart=/home/ubuntu/grafa_startup_setup.sh
User=ubuntu
Restart=faliure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable prometheus_startup

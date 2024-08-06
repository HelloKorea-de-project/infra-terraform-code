#!/bin/bash

sudo apt-get update
sudo apt-get install -y python3-pip postgresql-client
sudo apt-get install python3-virtualenv
sudo apt-get install -y libpq-dev
sudo apt install unzip

${ssh_setting}

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

sudo -u ubuntu aws configure set aws_access_key_id "${aws_access_key_id}"
sudo -u ubuntu aws configure set aws_secret_access_key "${aws_secret_access_key}"
sudo -u ubuntu aws configure set region "${aws_region}"

virtualenv airflow
cd airflow
source bin/activate

# Install Airflow
pip install apache-airflow[amazon,postgres]==2.9.1
pip install psycopg2-binary
pip install statsd

# Configure Airflow
export AIRFLOW_HOME=/home/ubuntu/airflow
export AIRFLOW_CONN_S3_CONN=aws://${aws_access_key_id}:${aws_secret_access_key}@/?region_name=${aws_region}
export AIRFLOW_CONN_REDSHIFT_CONN=redshift://devcourse:HelloKorea0818@hellokorea-redshift-cluster.cvkht4jvd430.ap-northeast-2.redshift.amazonaws.com:5439/hellokorea_db
export AIRFLOW_CONN_POSTGRES_CONN=postgresql://devcourse:HelloKorea0818@hellokorea-production-db.ch4xfyi6stod.ap-northeast-2.rds.amazonaws.com:5432/production_db
mkdir -p $AIRFLOW_HOME/dags
mkdir -p $AIRFLOW_HOME/plugins
mkdir -p $AIRFLOW_HOME/config
mkdir -p $AIRFLOW_HOME/tests

sudo -u ubuntu aws s3 cp s3://hellokorea-airflow-dags/ /home/ubuntu/airflow/
pip install -r /home/ubuntu/airflow/dags/requirements.txt

cat << 'EOF' > /home/ubuntu/airflow_startup.sh
#!/bin/bash
source /home/ubuntu/airflow/bin/activate
airflow webserver -D
airflow scheduler
EOF

chmod +x /home/ubuntu/airflow_startup.sh

sudo cat << 'EOF' > /etc/systemd/system/airflow_startup_service.service
[Unit]
Description=Grafana Startup Script
After=network.target

[Service]
ExecStart=/home/ubuntu/airflow_startup.sh
User=ubuntu
Restart=faliure

[Install]
WantedBy=multi-user.target
EOF


sudo systemctl daemon-reload
sudo systemctl enable airflow_startup.service

# Initialize the database
airflow db init

# Create admin user
airflow users create -f Admin -l User -u devcourse -e purotae@gmail.com -r Admin -p HelloKorea0818

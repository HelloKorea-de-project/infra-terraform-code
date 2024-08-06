#!/bin/bash

sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.11 -y
sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 1

sudo apt install python3.11-venv -y
python3.11 -m venv /home/ubuntu/dbt-env
source /home/ubuntu/dbt-env/bin/activate

pip install --upgrade pip setuptools
pip install dbt-redshift

mkdir -p /home/ubuntu/hellokorea-dbt/redshift
cd /home/ubuntu/hellokorea-dbt/redshift
dbt init hellokorea_redshift -s

mkdir /home/ubuntu/.dbt
cat <<EOF >/home/ubuntu/.dbt/profiles.yml
hellokorea_redshift:
  target: production_redshift
  outputs:
    production_redshift:
      type: redshift
      host: ${production_redshift_host}
      user: ${production_redshift_user}
      password: ${production_redshift_password}
      dbname: ${production_redshift_db}
      port: 5439
      schema: raw_data
      threads: 1
EOF

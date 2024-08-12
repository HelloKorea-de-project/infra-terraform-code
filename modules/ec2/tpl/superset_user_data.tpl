#!/bin/bash
# EC2 인스턴스가 시작될 때 실행될 스크립트

# 시스템 업데이트 및 필수 패키지 설치
sudo apt update
sudo apt install -y build-essential libffi-dev python3-dev python3-pip python3-wheel libssl-dev libsasl2-dev libldap2-dev

# virtualenv 설치
sudo apt install python3-venv -y

python3 -m venv /home/admin/superset
source /home/admin/superset/bin/activate

# 필요한 Python 패키지 설치
pip install Pillow
pip install psycopg2-binary
pip install apache-superset

# Superset 환경 변수 설정
export FLASK_APP=superset

# Superset secret key 생성 및 환경 변수에 설정
export SUPERSET_SECRET_KEY=$(openssl rand -base64 42)

# Superset 데이터베이스 초기화 및 설정
superset db upgrade
superset fab create-admin --username admin --firstname Admin --lastname User --email admin@example.com --password admin
superset load_examples
superset init

# Superset 실행
nohup superset run -p 8099 --with-threads --reload --debugger --host 0.0.0.0 >/var/log/superset.log 2>&1 &

#!/bin/bash
sudo apt update

export HOME=/home/ubuntu
git config --global --add safe.directory /home/ubuntu/django

# sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install -y python3 python3-pip python3-venv git
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install

sudo apt install -y nginx
# /etc/nginx/nginx.conf 파일 대체
sudo aws s3 cp s3://hellokorea-test-zone/prod_web_env/nginx.conf /etc/nginx/nginx.conf
sudo systemctl enable nginx
sudo systemctl restart nginx

cd /home/ubuntu
git clone https://github.com/HelloKorea-de-project/django.git
# .env.production 파일 복사
sudo aws s3 cp s3://hellokorea-test-zone/prod_web_env/.env.production /home/ubuntu/django/hellokorea/.env.production
# /etc/systemd/system/gunicorn.service 파일 복사
sudo aws s3 cp s3://hellokorea-test-zone/prod_web_env/gunicorn.service /etc/systemd/system/gunicorn.service

cd /home/ubuntu/django
python3 -m venv venv
. venv/bin/activate
git pull origin main
pip install -r requirements.txt

cd /home/ubuntu/django/hellokorea
python manage.py makemigrations
python manage.py makemigrations airline
python manage.py makemigrations tour
python manage.py migrate
# python manage.py collectstatic --noinput

cd /home/ubuntu/django
sudo chown -R $USER:$USER venv
pip install gunicorn
sudo systemctl daemon-reload
sudo systemctl start gunicorn
sudo systemctl enable gunicorn
sudo systemctl restart gunicorn
#!/bin/bash

sudo apt update && sudo apt upgrade -y
sudo apt install redis-server -y

sed -i 's/bind 127.0.0.1/bind 0.0.0.0/' /etc/redis/redis.conf
sed -i 's/# requirepass foobared/requirepass tjsdud818/' /etc/redis/redis.conf
sed -i 's/protected-mode yes/protected-mode no/' /etc/redis/redis.conf


sudo systemctl enable redis-server
sudo systemctl start redis-server
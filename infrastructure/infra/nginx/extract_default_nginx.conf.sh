#!/bin/bash
cd "$( dirname "$0" )"
sudo docker exec -it nginx cat /etc/nginx/nginx.conf

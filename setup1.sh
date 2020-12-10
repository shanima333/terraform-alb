#!/bin/bash

yum install docker -y 
usermod -a -G docker ec2-user
service docker restart
chkconfig docker on
docker pull fujikomalan/alb-blog:latest
docker run -d -p 80:80 --restart always --name app-blog fujikomalan/alb-blog:latest

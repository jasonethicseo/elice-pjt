#!/bin/bash

echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config

docker plugin install --alias cloudstor:aws --grant-all-permissions docker4x/cloudstor:18.09.2-ce-aws1 CLOUD_PLATFORM=AWS AWS_REGION=${region} EFS_SUPPORTED=0 DEBUG=1

yum update -y
yum install -y amazon-ssm-agent && systemctl start amazon-ssm-agent && systemctl enable amazon-ssm-agent
yum install aws-cli -y

echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
crontab -l > /tmp/mycrontab
echo '10 * * * * docker container prune -f' >> /tmp/mycrontab
crontab /tmp/mycrontab
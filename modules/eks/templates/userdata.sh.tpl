#!/bin/bash -e


B64_CLUSTER_CA=${cluster_auth_base64}
API_SERVER_URL=${cluster_endpoint}
/etc/eks/bootstrap.sh ${cluster_name} --b64-cluster-ca $B64_CLUSTER_CA --apiserver-endpoint $API_SERVER_URL

# Install ssm agent
yum install -y amazon-ssm-agent && systemctl start amazon-ssm-agent && systemctl enable amazon-ssm-agent
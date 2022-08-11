#!/bin/bash
rm /var/lib/cloud/instances/*/sem/config_scripts_user;
sudo -u ubuntu bash << EOF
date >> /home/ubuntu/current_datetime.txt # Troubleshoot
sudo apt install unzip -y
sudo apt install build-essential -y
mkdir /home/ubuntu/actions-runner || true; 
cd /home/ubuntu/actions-runner;
curl -o actions-runner-linux-x64-${runner_version}.tar.gz -L https://github.com/actions/runner/releases/download/v${runner_version}/actions-runner-linux-x64-${runner_version}.tar.gz  || true;
echo "8fa64384d6fdb764797503cf9885e01273179079cf837bfc2b298b1a8fd01d52  actions-runner-linux-x64-${runner_version}.tar.gz" | shasum -a 256 -c  || true;
tar xzf ./actions-runner-linux-x64-${runner_version}.tar.gz  || true;
./config.sh --unattended --replace --url ${repo} --token ${token} --name ${runner_name} --labels ${runner_name} || true;
sudo ./svc.sh install
sudo ./svc.sh start
EOF

# A lot of these stuff is required to execute data_user after everyboot
Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash
rm /var/lib/cloud/instances/*/sem/config_scripts_user;
sudo -u ubuntu bash << EOF
date >> /home/ubuntu/current_datetime.txt # To see if it runned again after restart
mkdir /home/ubuntu/actions-runner || true; 
cd /home/ubuntu/actions-runner;
curl -o actions-runner-linux-x64-2.287.1.tar.gz -L https://github.com/actions/runner/releases/download/v2.287.1/actions-runner-linux-x64-2.287.1.tar.gz  || true;
echo "8fa64384d6fdb764797503cf9885e01273179079cf837bfc2b298b1a8fd01d52  actions-runner-linux-x64-2.287.1.tar.gz" | shasum -a 256 -c  || true;
tar xzf ./actions-runner-linux-x64-2.287.1.tar.gz  || true;
./config.sh --unattended --replace --url ${repo} --token ${token} --name ${runner_name} --labels ${runner_name} || true;
tmux new-session -d -s run-github-actions './run.sh'; 
EOF

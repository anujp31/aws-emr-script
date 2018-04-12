#!/usr/bin/env bash

# Commands to install anaconda python
# Python packages

sudo yum -y update
# Install Anaconda (Python 3) & Set To Default
wget https://repo.continuum.io/archive/Anaconda3-5.1.0-Linux-x86_64.sh -O ~/anaconda.sh
sudo bash ~/anaconda.sh -b -p /opt/anaconda

# Add anaconda to path and other bashrc tweaks
cat <<'EOF' >> /home/hadoop/.bashrc

export PATH=/opt/anaconda/bin:$PATH


nonzero_return(){
    local RETVAL=$?
    [ $RETVAL -ne 0 ] && echo "${RETVAL}:"
}

export PS1="\[\e[31m\]\`nonzero_return\`\[\e[m\]\[\e[34m\]\H:\[\e[m\]\[\e[32m\]\w\[\e[m\] "

shopt -s autocd
EOF

source /home/hadoop/.bashrc

# Install Additional Packages
sudo env "PATH=$PATH" conda install -y psycopg2

# NOTE: Use master-post-init.sh instead of below!!!
# Keeping this here since its a useful snippet to determine if we're on master
# # Run only master node
# if grep isMaster /mnt/var/lib/info/instance.json | grep true; then
#     aws s3 cp s3://${S3_BUCKET}/emr/bootstrap-master.sh .
#     bash bootstrap-master.sh
# fi

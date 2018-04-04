#!/usr/bin/env bash

# Commands to install anaconda python
# Python packages

sudo yum -y update
# Install Anaconda (Python 3) & Set To Default
wget https://repo.continuum.io/archive/Anaconda3-4.2.0-Linux-x86_64.sh -O ~/anaconda.sh
bash ~/anaconda.sh -b -p $HOME/anaconda
echo -e '\nexport PATH=$HOME/anaconda/bin:$PATH' >> $HOME/.bashrc && source $HOME/.bashrc

# Install Additional Packages
conda install -y psycopg2

# Run only master node
if grep isMaster /mnt/var/lib/info/instance.json | grep true; then
    MVN_VER="3.5.3"
    wget -P /tmp http://apache.mirrors.lucidnetworks.net/maven/maven-3/${MVN_VER}/binaries/apache-maven-${MVN_VER}-bin.tar.gz
    sudo mkdir /opt/apache-maven
    sudo tar xzvf /tmp/apache-maven-${MVN_VER}-bin.tar.gz -C /opt/apache-maven
    rm /tmp/apache-maven-${MVN_VER}-bin.tar.gz
    cat <<EOF >> /home/hadoop/.bashrc

# Maven
export MAVEN_HOME=/opt/apache-maven/apache-maven-${MVN_VER}
export PATH=\$MAVEN_HOME/bin:\$PATH
EOF

    . /home/hadoop/.bashrc
    sudo stop zeppelin
    aws s3 cp s3://remine-datascience/emr/resources/ zeppelinsetup --recursive
    # sudo cp ./zeppelinsetup/shiro.ini /usr/lib/zeppelin/conf/shiro.ini
    # sudo cp ./zeppelinsetup/zeppelin-site.xml /usr/lib/zeppelin/conf/zeppelin-site.xml
    sudo cp ./zeppelinsetup/zeppelin-env.sh /usr/lib/zeppelin/conf/zeppelin-env.sh
    sudo chown -R zeppelin /var/lib/zeppelin/local-repo
    sudo chown -R zeppelin /etc/zeppelin/conf
    sudo /usr/lib/zeppelin/bin/install-interpreter.sh --all
    sudo cp ./zeppelinsetup/interpreter.json /usr/lib/zeppelin/conf/interpreter.json
    sudo chown -R zeppelin /var/lib/zeppelin/local-repo
    sudo chown -R zeppelin /etc/zeppelin/conf
    sudo start zeppelin

    echo " completed zeppelin setup"
else
    echo " zeppelin setup is only done on master node"
    exit 0;
fi

# Fix that ugly prompt
cat <<EOF >> /home/hadoop/.bashrc
function nonzero_return() {
    local RETVAL=$?
    [ $RETVAL -ne 0 ] && echo "${RETVAL}:"
}

export PS1="\[\e[31m\]\`nonzero_return\`\[\e[m\]\[\e[34m\]\H:\[\e[m\]\[\e[32m\]\w\[\e[m\] "
EOF

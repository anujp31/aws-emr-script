#!/usr/bin/env bash

# This script runs via script-runner.jar after EMR has finished initializing the master node

# Install Maven
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

# Set local repo to same dir as zeppelin's
mkdir -p /home/hadoop/.m2
cat <<'EOF' >> /home/hadoop/.m2/settings.xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <localRepository>/usr/lib/zeppelin/local-repo</localRepository>
</settings>
EOF

# Set JAVA_HOME to open-jdk
sed -i 's/etc\/alternatives\/jre/etc\/alternatives\/java_sdk/' /home/hadoop/.bashrc

# Configure zeppelin
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
sudo chmod -R 777 /var/lib/zeppelin/local-repo
sudo start zeppelin

#!/usr/bin/env bash

# Compiles xgboost4j with HDFS and S3 support; intended for Zeppelin on EMR

# Usage: run this script as sudo with MAVEN_HOME in your PATH:
#   sudo env "PATH=$PATH" bash build-xgboost.sh

CMAKE_VER=3.11.0
SPARK_VER=2.3.0
HADOOP_VER=2.8.3
CPUS=`nproc --all`

# Install dev tools
yum install gcc gcc-c++ libcurl-devel git hadoop-libhdfs-devel -y

# Build cmake
cd
wget https://cmake.org/files/v3.11/cmake-${CMAKE_VER}.tar.gz
tar -xvzf cmake-${CMAKE_VER}.tar.gz

cd cmake-${CMAKE_VER}
./bootstrap --parallel=${CPUS} --system-curl --prefix=/usr
make -j${CPUS}
make install

cd
rm ~/cmake-${CMAKE_VER}.tar.gz
rm -rf ~/cmake-${CMAKE_VER}

# Get some neccessary HDFS/Hadoop libraries
cd
# wget https://github.com/apache/hadoop/archive/rel/release-${HADOOP_VER}.tar.gz
wget http://mirror.cogentco.com/pub/apache/hadoop/common/hadoop-${HADOOP_VER}/hadoop-${HADOOP_VER}.tar.gz
tar xf hadoop-${HADOOP_VER}.tar.gz

# Build xgboost
git clone --recurse-submodules -j${CPUS} https://github.com/dmlc/xgboost

cd ~/xgboost/jvm-packages

# Enable HDFS, S3 support
sed -i 's;"USE_HDFS": "OFF";"USE_HDFS": "ON";' create_jni.py
sed -i 's;"USE_S3": "OFF";"USE_S3": "ON";' create_jni.py
# Set spark version
sed -i "s/<spark.version>.*<\/spark.version>/<spark.version>$SPARK_VER<\/spark.version>/" pom.xml
# Allow it to load libraries from elswhere
sed -i "s/NO_DEFAULT_PATH/#NO_DEFAULT_PATH/g" ../dmlc-core/cmake/Modules/FindHDFS.cmake

# Definitely need these
export LD_LIBRARY_PATH=${HOME}/hadoop-${HADOOP_VER}/lib:$LD_LIBRARY_PATH
export HADOOP_HOME=/usr/lib/hadoop

# Setting these too just in case
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=/usr/lib/hadoop-hdfs
export HADOOP_MAPRED_HOME=/usr/lib/hadoop-yarn
export HADOOP_YARN_HOME=$HADOOP_MAPRED_HOME
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop

# Specify path to settings.xml because of sudo
mvn -s /home/hadoop/.m2/settings.xml -DskipTests clean install

# Clean up
cd
rm -rf ~/xgboost
rm -rf hadoop-${HADOOP_VER}
rm hadoop-${HADOOP_VER}.tar.gz

# Fix permissions
chown -R zeppelin /var/lib/zeppelin/local-repo
chmod 777 -R /var/lib/zeppelin/local-repo

echo 'Load in zeppelin like so:'
echo '  %spark.dep'
echo '  z.load("ml.dmlc:xgboost4j-spark:0.8-SNAPSHOT")'

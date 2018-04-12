#!/usr/bin/env bash

# Make mmlspark (LightGBM) available to pyspark

# References:
#  https://stackoverflow.com/questions/36397136/importing-pyspark-packages
#  https://github.com/graphframes/graphframes/issues/172

MMLSPARK_VER=0.11

jar xf Azure_mmlspark-${MMLSPARK_VER}.jar

cd mmlspark

zip -r mmlspark-${MMLSPARK_VER}.zip *

# aws s3 cp s3://<s3-bucket>/emr/resources/mmlspark-${MMLSPARK_VER}.zip .
# export PYTHONPATH=$PYTHONPATH:/home/hadoop/mmlspark-${MMLSPARK_VER}.zip
# pyspark --packages Azure:mmlspark:${MMLSPARK_VER} --py-files /home/hadoop/mmlspark-${MMLSPARK_VER}.zip

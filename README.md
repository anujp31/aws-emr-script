# Notes

replace the following command with your desired s3 location in bootstrap_action.sh

    aws s3 cp s3://<s3-bucket>/zeppelin-setup/resources/ zeppelinsetup --recursive

Push the folder setupZeppelin to your desired S3 location.

## Tasks

- Set Zeppelin to use S3 backed notebooks with Spark on Amazon EMR
- Set Anaconda as default python interpreter in Zeppelin

## Getting started

Make sure you have the resources before beginning:

- AWS Command line interface installed
- An SSH client
- A key pair in the region where you'll launch the Zeppelin instance
- An S3 bucket in same region to store your Zeppelin notebooks, and to transfer files from EMR to your Zeppelin instance
- IAM permissions to create S3 buckets, launch EC2 instances, and create EMR clusters

## Create an EMR cluster

The first step is to set up an EMR cluster.

1. On the Amazon EMR console, choose Create cluster.
2. Choose Go to advanced options and enter the following options:
    1. Vendor: Amazon
    2. We require Hadoop, Zeppelin, Ganglia, and Spark are selected.
    3. In the Add steps section, for Step type, choose Custom JAR, and select configure.
        1. Change name to "custom bootstrap action"
        2. in `jar location` add `s3://us-east-1.elasticmapreduce/libs/script-runner/script-runner.jar`
        **replace** `us-east-1` **with the region in which you've created your EMR instance**. _The script runner allows you run a script at any time during the step process._
        3. In `arguments` add `s3://<s3-bucket>/emr/master-post-init.sh`.
3. Choose Add, Next.
4. On the Hardware Configuration page, select your VPC and the subnet where you want to launch the cluster, keep the default selection of one master and two core nodes of m4.xlarge, and choose Next.
5. On the General Options page, give your cluster a name (e.g., Spark-Cluster) and choose Next.
6. In Additional Options section, add a bootstrap action by selecting "Custom action" and setting `s3://<s3-bucket>/emr/bootstrapaction.sh` for the script location
7. On the Security Options page, for EC2 key pair, select a key pair. Keep all other settings at the default values and choose Create cluster.

Your three-node cluster takes a few moments to start up. Your cluster is ready when the cluster status is Waiting.

## Discussion

### Services on EMR use upstart

Note - services on EMR use upstart, and the supported way to restart them is to use `sudo stop <service name>`; `sudo start <service name>`(the start and stop commands are in /sbin, which is in the PATH by default).

- <https://stackoverflow.com/questions/42032490/how-can-i-get-zeppelin-to-restart-cleanly-on-an-emr-cluster>
- <https://aws.amazon.com/premiumsupport/knowledge-center/restart-service-emr/>

## Links
- <https://github.com/arunkundgol/zeppelin-setup/>
- <https://aws.amazon.com/blogs/big-data/running-an-external-zeppelin-instance-using-s3-backed-notebooks-with-spark-on-amazon-emr/>
- <https://dziganto.github.io/zeppelin/spark/zeppelinhub/emr/anaconda/tensorflow/shiro/s3/theano/bootstrap%20script/EMR-From-Scratch/>

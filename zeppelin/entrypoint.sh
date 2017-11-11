service ssh start
ssh-keyscan -H -t rsa 127.0.0.1  >> ~/.ssh/known_hosts
ssh-keyscan -H -t rsa localhost  >> ~/.ssh/known_hosts
ssh-keyscan -H -t rsa $(hostname)  >> ~/.ssh/known_hosts
yes|ssh-keygen -q -N "" -t rsa -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin:/usr/local/zeppelin/bin
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_CONF_DIR=/usr/local/hadoop/etc/hadoop
export ZEPPELIN_HOME=/usr/local/zeppelin

hdfs namenode -format
start-dfs.sh
hdfs dfs -mkdir /user
hdfs dfs -mkdir /user/root
hdfs dfs -mkdir /user/zeppelin
zeppelin.sh

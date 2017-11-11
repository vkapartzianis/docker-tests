service ssh start
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keyscan -H -t rsa 127.0.0.1  >> ~/.ssh/known_hosts
ssh-keyscan -H -t rsa localhost  >> ~/.ssh/known_hosts
ssh-keyscan -H -t rsa $(hostname)  >> ~/.ssh/known_hosts
yes|ssh-keygen -q -N "" -t rsa -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo -e "Host *\n    AddressFamily inet\n    StrictHostKeyChecking no" >> ~/.ssh/config

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export ZEPPELIN_HOME=/usr/local/zeppelin
export ZEPPELIN_CONF_DIR=$ZEPPELIN_HOME/conf
export PATH=$PATH:$HADOOP_HOME/bin:HADOOP_HOME/sbin:$ZEPPELIN_HOME/bin

hdfs namenode -format
start-dfs.sh
hdfs dfs -mkdir /user
hdfs dfs -mkdir /user/root
hdfs dfs -mkdir /user/zeppelin
zeppelin.sh

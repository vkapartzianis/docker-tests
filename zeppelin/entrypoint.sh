# reset ssh configuration on every boot -- should be used inside containers ONLY
service ssh start
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keyscan -H -t rsa 127.0.0.1  > ~/.ssh/known_hosts
ssh-keyscan -H -t rsa localhost  >> ~/.ssh/known_hosts
ssh-keyscan -H -t rsa $(hostname)  >> ~/.ssh/known_hosts
yes|ssh-keygen -q -N "" -t rsa -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
/bin/echo -e "Host *\n    AddressFamily inet\n    StrictHostKeyChecking no" > ~/.ssh/config

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export ZEPPELIN_HOME=/usr/local/zeppelin
export ZEPPELIN_CONF_DIR=$ZEPPELIN_HOME/conf
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$ZEPPELIN_HOME/bin

yes n|hdfs namenode -format
start-dfs.sh
hdfs dfs -mkdir -p /user
hdfs dfs -mkdir -p /user/root
hdfs dfs -mkdir -p /user/zeppelin

[ -d /zeppelin ] || mkdir /zeppelin
[ -f /etc/zeppelin/shiro.ini ] && ln -fs /etc/zeppelin/shiro.ini /usr/local/zeppelin/conf/shiro.ini
[ -f /etc/zeppelin/notebook-authorization.json ] && ln -fs /etc/zeppelin/notebook-authorization.json /usr/local/zeppelin/conf/notebook-authorization.json
[ -f /usr/local/zeppelin/conf/shiro.ini ] && export ZEPPELIN_NOTEBOOK_PUBLIC="false"
cd /zeppelin && zeppelin.sh

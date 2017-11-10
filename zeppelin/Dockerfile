# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM ubuntu:16.04
MAINTAINER Vaggelis Kapartzianis <vkapartzianis@gmail.com>

# `Z_VERSION` will be updated by `dev/change_zeppelin_version.sh`
ENV Z_VERSION="0.7.3"
ENV LOG_TAG="[ZEPPELIN_${Z_VERSION}]:" \
    Z_HOME="/zeppelin" \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN echo "$LOG_TAG update and install basic packages" && \
    apt-get -y update && \
    apt-get install -y locales && \
    locale-gen $LANG && \
    apt-get install -y software-properties-common && \
    apt -y autoclean && \
    apt -y dist-upgrade && \
    apt-get install -y build-essential

RUN echo "$LOG_TAG install tini related packages" && \
    apt-get install -y wget curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
RUN echo "$LOG_TAG Install java8" && \
    apt-get -y update && \
    apt-get install -y openjdk-8-jdk && \
    rm -rf /var/lib/apt/lists/*

# should install conda first before numpy, matploylib since pip and python will be installed by conda
RUN echo "$LOG_TAG Install miniconda2 related packages" && \
    apt-get -y update && \
    apt-get install -y bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion && \
    echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda2-4.3.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh
ENV PATH /opt/conda/bin:$PATH

RUN echo "$LOG_TAG Install python related packages" && \
    apt-get -y update && \
    apt-get install -y python-dev python-pip && \
    apt-get install -y gfortran && \
    # numerical/algebra packages
    apt-get install -y libblas-dev libatlas-dev liblapack-dev && \
    # font, image for matplotlib
    apt-get install -y libpng-dev libfreetype6-dev libxft-dev && \
    # for tkinter
    apt-get install -y python-tk libxml2-dev libxslt-dev zlib1g-dev && \
    pip install numpy && \
    pip install matplotlib

RUN echo "$LOG_TAG Install R related packages" && \

echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" | tee -a /etc/apt/sources.list && \
    gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9 && \
    gpg -a --export E084DAB9 | apt-key add - && \
    apt-get -y update && \
    apt-get -y install r-base r-base-dev && \
    R -e "install.packages('knitr', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('ggplot2', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('googleVis', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('data.table', repos='http://cran.us.r-project.org')" && \
    # for devtools, Rcpp
    apt-get -y install libcurl4-gnutls-dev libssl-dev && \
    R -e "install.packages('devtools', repos='http://cran.us.r-project.org')" && \
    R -e "install.packages('Rcpp', repos='http://cran.us.r-project.org')" && \
    Rscript -e "library('devtools'); library('Rcpp'); install_github('ramnathv/rCharts')"

RUN echo "$LOG_TAG Set up Hadoop" && \
    cd ~ && \
    wget http://archive.apache.org/dist/hadoop/core/hadoop-2.8.2/hadoop-2.8.2.tar.gz && \
    tar -zxvf hadoop-2.8.2.tar.gz && \
    mv hadoop-2.8.2 /usr/local && \
    ln -s hadoop-2.8.2 /usr/local/hadoop && \
    rm hadoop-2.8.2.tar.gz && \
    # see https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/SingleCluster.html
    echo "JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64" >> /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    apt install xmlstarlet && \
    # TODO: handle xml updates better
    xmlstarlet ed -P -L -s "/configuration" -t elem -n "property" /usr/local/hadoop/etc/hadoop/core-site.xml &&\
    xmlstarlet ed -P -L -s "/configuration/property" -t elem -n "name" -v "fs.defaultFS" /usr/local/hadoop/etc/hadoop/core-site.xml && \
    xmlstarlet ed -P -L -s "/configuration/property" -t elem -n "value" -v "hdfs://127.0.0.1:8020" /usr/local/hadoop/etc/hadoop/core-site.xml && \
    xmlstarlet ed -P -L -s "/configuration" -t elem -n "property" /usr/local/hadoop/etc/hadoop/hdfs-site.xml && \
    xmlstarlet ed -P -L -s "/configuration/property" -t elem -n "name" -v "dfs.replication" /usr/local/hadoop/etc/hadoop/hdfs-site.xml && \
    xmlstarlet ed -P -L -s "/configuration/property" -t elem -n "value" -v "1" /usr/local/hadoop/etc/hadoop/hdfs-site.xml && \
    # TODO: check if authorization needed
    ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys && \
    # disable strict host key checking
    echo "StrictHostKeyChecking no" >> .ssh/config

ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin
RUN echo "$LOG_TAG Start Hadoop" && \
    # try and disable ipv6 first -- this is needed in docker containers only
    sysctl -w net.ipv6.conf.all.disable_ipv6=1
    hdfs namenode -format && \
    start-dfs.sh && \
    hdfs dfs -mkdir /user && \
    # TODO: retrieve user name from environment
    hdfs dfs -mkdir /user/root

RUN echo "$LOG_TAG Set up Zeppelin" && \
    cd ~ && \
    wget http://archive.apache.org/dist/zeppelin/zeppelin-${Z_VERSION}/zeppelin-${Z_VERSION}-bin-netinst.tgz && \
    tar -zxvf zeppelin-${Z_VERSION}-bin-netinst.tgz && \
    # set up interpreters used in examples
    zeppelin-${Z_VERSION}-bin-netinst/bin/install-interpreter.sh --name flink,md,pig,python,shell && \
    mv zeppelin-${Z_VERSION}-bin-netinst /usr/local/zeppelin-${Z_VERSION} && \
    ln -s zeppelin-${Z_VERSION} /usr/local/zeppelin && \
    rm zeppelin-${Z_VERSION}-bin-netinst.tgz && \
    # install for plain python (were installed for conda)
    /usr/bin/pip install numpy && \
    /usr/bin/pip install matplotlib && \
    # needed for "Using Mahout" tutorial TODO: remove this tutorial as the script's missing
    apt-get install r-cran-scatterplot3d && \
    # needed for pig interpreter
    export HADOOP_HOME=/usr/local/hadoop && \
    # fix py4j problems
    /usr/bin/pip install py4j && \
    /opt/conda/bin/pip install py4j && \
    # update environment for Zeppelin, in case it's needed
    export PATH=$PATH:/usr/local/zeppelin/bin && \
    export ZEPPELIN_HOME=/usr/local/zeppelin

RUN echo "$LOG_TAG Cleanup" && \
    apt-get autoclean && \
    apt-get clean

EXPOSE 8080

ENTRYPOINT [ "/usr/bin/tini", "--" ]
WORKDIR ${Z_HOME}
CMD ["/usr/local/zeppelin/bin/zeppelin.sh"]

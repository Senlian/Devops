# ELK安装

  |     系统版本     |      JDK版本    |ElasticSearch版本|  Logstash版本   |  Kibana版本    |
 |:----------------:|:---------------:|:---------------:|:---------------:|:--------------:|
|  CentOS 6.8      | OpenJDK-12.0.1  |        7.1.1    |      7.1.1      |      7.1.1     |


## JDK安装
    > Elasticsearch源码包自带"OpenJDK-12.0.1",见《ElasticSearch安装》
    
    
## ElasticSearch安装
### 源码安装
- 下载
    ```DownLoad
        // 下载目录准备
        mkdir -p /usr/local/src/elk
        export ELK_HOME="/usr/local/src/elk"
        cd $ELK_HOME
        // 源码包下载
        wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.1.1-linux-x86_64.tar.gz
        // 解压
        tar -zxvf elasticsearch-7.1.1-linux-x86_64.tar.gz
        mkdir -p /usr/local/elk
        export ELK_HOME=/usr/local/elk/
        // 生产环境搭建
        cp -rf elasticsearch-7.1.1 $ELK_HOME
        cd $ELK_HOME
        ln -s elasticsearch-7.1.1  elasticsearch
    ```


- JDK配置
    ```/etc/profile
        // 添加环境变量
        sed -i '$a\export ELK_HOME=/usr/local/elk\nexport JAVA_HOME=$ELK_HOME/elasticsearch/jdk\nexport PATH=$PATH:$JAVA_HOME/bin' /etc/profile
        // 设置立即生效
        source /etc/profile
        // 查看版本
        java --version
        // 查看可执行文件路径
        which java
    ```
    
- 配置

## Logstash安装
## Kibana安装

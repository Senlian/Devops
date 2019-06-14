# ELK日志系统搭建
> `Elasticsearch 是一个开源的分布式 RESTful 搜索和分析引擎。`

[参考文档：https://www.ibm.com/developerworks/cn/opensource/os-cn-elk/](<https://www.ibm.com/developerworks/cn/opensource/os-cn-elk/>)

[下载链接：https://www.elastic.co/cn/downloads/](<https://www.elastic.co/cn/downloads/>)

## Elasticsearch安装
[中文文档：https://es.xiaoleilu.com/](<https://es.xiaoleilu.com/>)

操作系统|Elasticsearch版本|JDK版本|            
:------:|:------:|:------:|    
CentOS 6.8|7.1.1|12.0.1

- 下载elasticsearch-7.1.1-linux-x86_64.tar.gz
    > `wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.1.1-linux-x86_64.tar.gz`


- 解压elasticsearch-7.1.1-linux-x86_64.tar.gz
    > `tar -zxvf elasticsearch-7.1.1-linux-x86_64.tar.gz`    


- 下载JDK-12.0.1
    > elasticsearch-7.1.1目录中自带JDK 
    - 设置JDK环境变量
        > `ES_HOME`为elasticsearch的解压目录
        - 临时设置
            ``` ENV
                export JAVA_HOME="$ES_HOME/jdk"
                export PATH="$JAVA_HOME/bin:$PATH""
            ```
        - 永久生效
            ```/etc/profile
                vim /etc/profile
                # 最后添加两行
                export JAVA_HOME="$ES_HOME/jdk"
                export PATH="$JAVA_HOME/bin:$PATH"
            ```
            
            
- 启动
    ```start
        cd $ES_HOME
        ./bin/elasticsearch
    ```    
   
        
- 验证
    
    `curl http://localhost:9200/`
    
    得到如下响应结果:
    ```stdout
        {
          "name" : "node-1",
          "cluster_name" : "elasticsearch",
          "cluster_uuid" : "H9gHlGxoQ5qGh--CRid2hg",
          "version" : {
            "number" : "7.1.1",
            "build_flavor" : "default",
            "build_type" : "tar",
            "build_hash" : "7a013de",
            "build_date" : "2019-05-23T14:04:00.380842Z",
            "build_snapshot" : false,
            "lucene_version" : "8.0.0",
            "minimum_wire_compatibility_version" : "6.8.0",
            "minimum_index_compatibility_version" : "6.0.0-beta1"
          },
          "tagline" : "You Know, for Search"
        }
    ```


- 配置

- 文档
    ```demo
        创建文档
        curl -l -H "Content-Type:application/json" -H "Accept:application/json" -X POST -d '{"title":"senlian","body":"sdfdsf"}' http://39.106.44.84:9200/website/blog/123?pretty
        获取文档
        curl -v http://39.106.44.84:9200/website/blog/123?pretty
    ```
- 索引
- API



# ELK日志系统搭建
[参考文档：https://www.ibm.com/developerworks/cn/opensource/os-cn-elk/](<https://www.ibm.com/developerworks/cn/opensource/os-cn-elk/>)

[下载链接：https://www.elastic.co/cn/downloads/](<https://www.elastic.co/cn/downloads/>)

操作系统|JDK版本|Elasticsearch版本|Kibana版本|            
:------:|:------:|:------:|:------:|    
CentOS 6.8|7.1.1|12.0.1|7.1.1|

## Elasticsearch
> `Elasticsearch 是一个开源的分布式 RESTful 搜索和分析引擎。`
### Elasticsearch安装
[中文文档：https://es.xiaoleilu.com/](<https://es.xiaoleilu.com/>)

- 下载elasticsearch-7.1.1-linux-x86_64.tar.gz
    ```download
        cd /usr/local/src
        wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.1.1-linux-x86_64.tar.gz
    ```


- 解压elasticsearch-7.1.1-linux-x86_64.tar.gz
    > `tar -zxvf elasticsearch-7.1.1-linux-x86_64.tar.gz`    


- 下载JDK-12.0.1
    > elasticsearch-7.1.1目录中自带JDK 
    - 设置JDK环境变量
        - 临时设置
            ``` ENV
                export $ES_HOME="/usr/local/src/elasticsearch-7.1.1"
                export JAVA_HOME="$ES_HOME/jdk"
                export PATH="$JAVA_HOME/bin:$PATH""
            ```
        - 永久生效
            ```/etc/profile
                vim /etc/profile
                # 最后添加
                export $ES_HOME="/usr/local/src/elasticsearch-7.1.1"
                export JAVA_HOME="$ES_HOME/jdk"
                export PATH="$JAVA_HOME/bin:$PATH"
            ```
            
- 创建ELK用户
    ```env
        groupadd elk //创建用户组
        useradd -g elk elk //创建归属于elk组的用户elk
        chown -R elk:elk $ES_HOME  //指定文件拥有者为elk用户
    ```    
    
- 启动
    ```start
        su elk //切换到非root用户，否则会运行报错
        cd $ES_HOME
        ./bin/elasticsearch //可以用-d指定为守护进出
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

### 配置
    > `/usr/local/src/elasticsearch-7.1.1/config/elasticsearch.yml`
    ```elasticsearch.yml
        # ======================== Elasticsearch Configuration =========================
        #
        # NOTE: Elasticsearch comes with reasonable defaults for most settings.
        #       Before you set out to tweak and tune the configuration, make sure you
        #       understand what are you trying to accomplish and the consequences.
        #
        # The primary way of configuring a node is via this file. This template lists
        # the most important settings you may want to configure for a production cluster.
        #
        # Please consult the documentation for further information on configuration options:
        # https://www.elastic.co/guide/en/elasticsearch/reference/index.html
        #
        # ---------------------------------- Cluster -----------------------------------
        #
        # Use a descriptive name for your cluster:
        #
        #cluster.name: my-application
        #
        # ------------------------------------ Node ------------------------------------
        #
        # Use a descriptive name for the node:
        #
        node.name: node-1
        #
        # Add custom attributes to the node:
        #
        #node.attr.rack: r1
        #
        # ----------------------------------- Paths ------------------------------------
        #
        # Path to directory where to store the data (separate multiple locations by comma):
        #
        #path.data: /path/to/data
        #
        # Path to log files:
        #
        #path.logs: /path/to/logs
        #
        # ----------------------------------- Memory -----------------------------------
        #
        # Lock the memory on startup:
        #
        bootstrap.memory_lock: false
        bootstrap.system_call_filter: false
        #
        # Make sure that the heap size is set to about half the memory available
        # on the system and that the owner of the process is allowed to use this
        # limit.
        #
        # Elasticsearch performs poorly when the system is swapping the memory.
        #
        # ---------------------------------- Network -----------------------------------
        #
        # Set the bind address to a specific IP (IPv4 or IPv6):
        #
        network.host: 0.0.0.0
        #
        # Set a custom port for HTTP:
        #
        http.port: 9200
        #
        # For more information, consult the network module documentation.
        #
        # --------------------------------- Discovery ----------------------------------
        #
        # Pass an initial list of hosts to perform discovery when this node is started:
        # The default list of hosts is ["127.0.0.1", "[::1]"]
        #
        #discovery.seed_hosts: ["host1", "host2"]
        #
        # Bootstrap the cluster using an initial set of master-eligible nodes:
        #
        cluster.initial_master_nodes: ["node-1"]
        #
        # For more information, consult the discovery and cluster formation module documentation.
        #
        # ---------------------------------- Gateway -----------------------------------
        #
        # Block initial recovery after a full cluster restart until N nodes are started:
        #
        #gateway.recover_after_nodes: 3
        #
        # For more information, consult the gateway module documentation.
        #
        # ---------------------------------- Various -----------------------------------
        #
        # Require explicit names when deleting indices:
        #
        #action.destructive_requires_name: true
        http.cors.enabled: true
        http.cors.allow-origin: "*"
    ```
    
    
       
### 基本知识
#### 与传统数据库对比
|传统数据库|Databases(数据库) |Tables(表) |Rows(行) |Columns(列)|
|:---:|:---:|:---:|:---|:---:|
|Elasticsearch|Indices(索引)  | Types(类型) | Documents(文档)| Fields(字段)|

#### 文档
> Elasticsearch是一个分布式的文档(document)存储引擎。它可以实时存储并检索复杂数据结构——序列化的JSON文档
- 文档元数据
    > 每个文档都包含三个元数据
    
    |字段名|用途|
    |:---|:---|
    |_index	|`数据库`，文档存储的地方|
    |_type|`表`,文档代表的对象的类|
    |_id|文档的唯一标识|
    
    - index
        > 索引，实际上文档存储在分片`shards`中，`index`是将分片组在一起的逻辑空间。必须是全部小写，不能以下划线开头，不能包含逗号
    - type
        > 类型, 定义一类数据文档。
    - id 
        > 字符串，与index和type一起唯一标识一个文档，id可以指定，也可以由elasticsearch自动生成。
    - version
        > 文档版本号，文档每次修改，版本号都会变化
       
        

#### REST API
- 文档操作接口
    > `/{index}/{type}/{id}`
- 创建文档
    - POST
        > `create`防止已存在文档被覆盖
        ```POST1
            curl -i -H "Content-Type:application/JSON" -XPOST  39.106.44.84:9200/website/blog/?pretty -d '{
            "title":"scsdn",
            "text":"test",
            "date":"20190426"
            }'
        ```
        ```POST2 URL后加/_create做为端点：
            curl -i -H "Content-Type:application/JSON" -XPOST  39.106.44.84:9200/website/blog/{$id}/_create?pretty -d '{
            "title":"scsdn",
            "text":"test",
            "date":"20190426"
            }'
        ```        
        ```POST3 使用op_type查询参数
            curl -i -H "Content-Type:application/JSON" -XPOST  39.106.44.84:9200/website/blog/{$id}?op_type=create -d '{
            "title":"scsdn",
            "text":"test",
            "date":"20190426"
            }'
        ```          
        响应结果：
        ```response
            HTTP/1.1 201 Created
            Location: /website/blog/AAkOZGsBUz3jfyOTG0-V
            Warning: 299 Elasticsearch-7.1.1-7a013de "[types removal] Specifying types in document index requests is deprecated, use the typeless endpoints instead (/{index}/_doc/{id}, /{index}/_doc, or /{index}/_create/{id})."
            content-type: application/json; charset=UTF-8
            content-length: 241
            
            {
              "_index" : "website",  //索引名称
              "_type" : "blog",     // 类型
              "_id" : "AAkOZGsBUz3jfyOTG0-V", //id标识
              "_version" : 1,    //文档版本
              "result" : "created", //API类型
              "_shards" : {         //分片信息
                "total" : 2,
                "successful" : 1,
                "failed" : 0
              },
              "_seq_no" : 12,
              "_primary_term" : 3
            }
            ```

    - PUT
        > `create`防止已存在文档被覆盖
        ```PUT1
            curl -i -H "Content-Type:application/JSON" -XPUT 39.106.44.84:9200/website/blog/2/_create?pretty -d '{
            "title":"scsdn",
            "text":"test",
            "date":"20190426"
            }'
        ```    
        ```PUT2
            curl -i -H "Content-Type:application/JSON" -XPUT 39.106.44.84:9200/website/blog/3?op_type=create -d '{
            "title":"scsdn",
            "text":"test",
            "date":"20190426"
            }'
        ```


- 更新
    - POST指定ID
    - PUT不带`_create`或`op_type=create`
    响应结果：
        ```response
                HTTP/1.1 200 OK
                Warning: 299 Elasticsearch-7.1.1-7a013de "[types removal] Specifying types in document index requests is deprecated, use the typeless endpoints instead (/{index}/_doc/{id}, /{index}/_doc, or /{index}/_create/{id})."
                content-type: application/json; charset=UTF-8
                content-length: 222
                
                {
                  "_index" : "website",
                  "_type" : "blog",
                  "_id" : "1",
                  "_version" : 8, // 文档版本刷新
                  "result" : "updated",  //返回状态为updated
                  "_shards" : {
                    "total" : 2,
                    "successful" : 1,
                    "failed" : 0
                  },
                  "_seq_no" : 23,
                  "_primary_term" : 3
                }
        ```
 

- 局部更新
    ```demo
        POST /website/blog/1/_update
        {
           "doc" : {
              "tags" : [ "testing" ],
              "views": 0
           }
        }
    ```
    
- 获取
    - 获取整个文档。\
        `curl -XGET {url}/{index}/{type}/{id}?pretty&v`
    - 获取文档部分字段,`source=`指定字段，多个以`,`分割。\
        `curl -XGET {url}/{index}/{type}/{id}?pretty&_source=field1,field2`
    - 获取原始文档
        `curl -XGET {url}/{index}/{type}/{id}?pretty&_source`
    - 判断文档是否存在
        `curl -XHEAD` {url}/{index}/{type}/{id}        
    - 示例：
        `curl -i -XGET  39.106.44.84:9200/website/blog/1?pretty`
        响应结果：
        ```response
            HTTP/1.1 200 OK
            Warning: 299 Elasticsearch-7.1.1-7a013de "[types removal] Specifying types in document get requests is deprecated, use the /{index}/_doc/{id} endpoint instead."
            content-type: application/json; charset=UTF-8
            content-length: 228
            
            {
              "_index" : "website",
              "_type" : "blog",
              "_id" : "1",
              "_version" : 9,
              "_seq_no" : 24,
              "_primary_term" : 3,
              "found" : true,  //请求状态
              "_source" : {  //原始文档
                "title" : "scsdn",
                "text" : "test",
                "date" : "20190426"
              }
            }
        ```


- 删除
    `curl -i -XDELETE  39.106.44.84:9200/website/blog/1?pretty`
    响应结果：
    ```response
        HTTP/1.1 200 OK //未找到为`404 Not Found`
        Warning: 299 Elasticsearch-7.1.1-7a013de "[types removal] Specifying types in document index requests is deprecated, use the /{index}/_doc/{id} endpoint instead."
        content-type: application/json; charset=UTF-8
        content-length: 223
        
        {
          "_index" : "website",
          "_type" : "blog",
          "_id" : "1",
          "_version" : 10, //不管是否找到都增加1，为了保证多节点间操作正确性
          "result" : "deleted", //没找到则为`not_found`
          "_sha         rds" : {
            "total" : 2,
            "successful" : 1,
            "failed" : 0
          },
          "_seq_no" : 25,
          "_primary_term" : 3
        }
    ```




- 版本控制
   > API接口可以通过`if_seq_no`和`if_primary_term`参数防止版本冲突，必须与当前`_seq_no`和`_primary_term`一致，否则报409错误
   ```
        curl -i -H "Content-Type:application/JSON" -XPUT "39.106.44.84:9200/website/blog/1?if_seq_no=37&if_primary_term=3" -d '{
            "title":"scsdn",
            "text":"test",
            "date":"20190426"
            }'
   ```
       
- 文档搜索 `_search`

- 结构化查询语句（DSL）



## Kibana
### Kibana 安装
```install
    //下载
    cd /usr/local/src
    wget https://artifacts.elastic.co/downloads/kibana/kibana-7.1.1-linux-x86_64.tar.gz
    //解压
    tar -zxvf kibana-7.1.1-linux-x86_64.tar.gz
    //配置
    vim ./config/kibana.yml
    elasticsearch.hosts: ["http://localhost:9200","http://xxxxxxx:9200"]
    //启动
    ./bin/kibana
```
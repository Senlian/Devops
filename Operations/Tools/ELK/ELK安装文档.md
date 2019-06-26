# ELK安装
[TOC]

  |     系统版本     |      JDK版本    |     Nodejs版本  |ElasticSearch版本|  Logstash版本   |  Kibana版本    |
 |:----------------:|:---------------:|:---------------:|:---------------:|:---------------:|:--------------:|
|  CentOS 6.8      | OpenJDK-12.0.1  |    v10.15.2     |        7.1.1    |      7.1.1      |      7.1.1     |

## 文档链接
[ ElasticSearch官方文档](<https://www.elastic.co/cn/products/elasticsearch>)

[ Logstash官方文档](<https://www.elastic.co/cn/products/logstash>)

[ Kibana官方文档](<https://www.elastic.co/cn/products/kibana>)

## ELK基本架构
    beats(收集数据) -> logstash(收集和处理数据，并将数据写入ES、Kafaka等服务) -> elasticsearch(存储数据，提供搜索) -> kibana(数据展示)


## JDK安装
> Elasticsearch源码包自带"OpenJDK-12.0.1",见[ElasticSearch.JDK配置](#jdk)   
    


## ElasticSearch
###简介
    Elasticsearch是一个高度可扩展的开源全文搜索和分析引擎。它允许您快速，近实时地存储，搜索和分析大量数据。它通常用作底层引擎/技术，为具有复杂搜索功能和要求的应用程序提供支持

### 源码安装
- 下载
    ```bash
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


- <span id="jdk">JDK配置</span>
    ```bash
        // 添加环境变量
        sed -i '$a\export ELK_HOME=/usr/local/elk\nexport JAVA_HOME=$ELK_HOME/elasticsearch/jdk\nexport PATH=$PATH:$JAVA_HOME/bin' /etc/profile
        // 设置立即生效
        source /etc/profile
        // 查看版本
        java --version
        // 查看可执行文件路径
        which java
    ```
    
    
- ElasticSearch配置
    
    [官方文档](<https://www.elastic.co/guide/en/elasticsearch/reference/current/getting-started.html>)
    ```yaml
        #elasticsearch.yml
        #集群名称
        cluster.name: elk_cluster_test
        #节点名称
        node.name: master-node-1
        #数据目录
        path.data: ${ELK_HOME}/elasticsearch/data
        #日志目录
        path.logs: ${ELK_HOME}/elasticsearch/logs
        #Memory项设置禁用swap
        bootstrap.memory_lock: false 
        bootstrap.system_call_filter: false

        #绑定地址
        network.host: localhost
        #端口
        http.port: 9200
        #可发现的集群节点
        discovery.seed_hosts: ["localhost:9200"]
        #定义主节点
        cluster.initial_master_nodes: ["master-node-1"]
        #启用xpack监控
        xpack.monitoring.enabled: true
        #是否收集监控数据
        xpack.monitoring.collection.enabled: false
        #启用跨站资源共享
        http.cors.enabled: true
        #允许哪个来源获取资源，/https?:\/\/localhost(:[0-9]+)?/，*表示所有
        http.cors.allow-origin: "*"

    ```


- 系统配置
    ```bash
      #虚拟内存限制
      sed -i '$a\vm.max_map_count = 262144' /etc/sysctl.conf
      #查看，生效
      sysctl -a|grep vm.max_map_count
      sysctl -p
      
      # 设置打开文件最大数量为65535
      sed -i '$a\elk - nofile 65535' /etc/security/limits.conf
      #设置最大进程数
      sed -i '$a\elk - nproc 4096' /etc/security/limits.conf
    ```

### 服务脚本
> 编写服务器脚本`elasticsearch.sh`    
```bash
    #!/usr/bin/env bash
    # elasticsearch
    #
    # chkconfig: -57 75
    # description: elasticsearch service
    # processname: elasticsearch
    source /etc/profile > /dev/null 2>&1
    
    ES_HOME=
    ES_BIN_DIR=
    ES_DATA_DIR=
    
    readonly ES_PID_DIR="/var/run/elasticsearch"
    # 单引号内不能使用变量和转义字符
    readonly ES_PID_FILE="${ES_PID_DIR}/elasticsearch.pid"
    
    # 根据参数设置数据目录
    if [ $# -gt 2 ]; then
        ES_DATA_DIR=$2
    fi
    
    # 工作目录设定
    if [ -z ${ES_HOME} ]; then
        ES_HOME="/usr/local/elk/elasticsearch"
    fi
    while [ -h ${ES_HOME} ]; do
        REAL_PATH="$(ls -ld ${ES_HOME}|awk '{print $NF}')"
        DIR_PATH=`dirname "${ES_HOME}"`
        ES_HOME=${DIR_PATH}/${REAL_PATH}
    done
    # 工作目录不存在退出程序
    if [ ! -d ${ES_HOME} ]; then
        exit -1
    fi
    # 数据目录设置
    if [ -z ${ES_DATA_DIR} ]; then
        ES_DATA_DIR="${ES_HOME}/data"
    fi
    
    # 可执行文件目录设置
    ES_BIN_DIR="${ES_HOME}/bin"
    # 日志目录设置
    ES_LOG="${ES_HOME}/logs/elasticsearch.log"
    ES_GROUP="elk"
    ES_USER="elk"
    
    egrep "^${ES_GROUP}" /etc/group >& /dev/null
    if [ $? -ne 0 ];then
      groupadd  ${ES_GROUP}
    fi
    
    egrep "^${ES_USER}" /etc/passwd >& /dev/null
    if [ $? -ne 0 ];then
      useradd -g ${ES_GROUP}  ${ES_USER}
    fi
    chown -R ${ES_USER}:${ES_GROUP} ${ES_HOME}
    chown -R ${ES_USER}:${ES_GROUP} ${ES_DATA_DIR}
    
    function start(){
        echo -e "\033[1;34mStarting elasticsearch\033[0m\c"
    
        if [ ! -d ${ES_PID_DIR} ]; then
            mkdir -p "${ES_PID_DIR}"
        fi
        chown -R ${ES_USER}:${ES_GROUP} ${ES_PID_DIR}
    
        # 判断服务是否已经启动
        if test -s "${ES_PID_FILE}"
        then
            local ES_PID="$(cat ${ES_PID_FILE})" > /dev/null 2>&1
            ES_PID=${ES_PID:-"$(ps ax|grep 'java'|grep 'elasticsearch'|awk '{print $1}')"}
            if kill -0 ${ES_PID} > /dev/null 2> /dev/null
            then
                if ps wwwp ${ES_PID} > /dev/null
                then    # The pid contains a mysqld process
                      echo ${ES_PID} > "${ES_PID_FILE}"
                      echo -e "\n\033[33mA elasticsearch process already exists\033[0m,\033[1mpid=${ES_PID}\033[0m"
                      exit 1
                fi
            else
                local ES_PID="$(ps ax|grep 'java'|grep 'elasticsearch'|awk '{print $1}')"
                if kill -0 ${ES_PID} > /dev/null 2> /dev/null
                then
                    if ps wwwp ${ES_PID} > /dev/null
                    then    # The pid contains a mysqld process
                          echo ${ES_PID} > "${ES_PID_FILE}"
                          echo -e "\n\033[33mA elasticsearch process already exists\033[0m,\033[1mpid=${ES_PID}\033[0m"
                          exit 1
                    fi
                fi
            fi
    
            rm -f ${ES_PID_FILE}
            if test -f "${ES_PID_FILE}"
            then
                echo -e "\nFatal error: Can't remove the pid file:
                    ${ES_PID_FILE}
                    Please remove it manually and start $0 again;
                    elasticsearch daemon not started"
                    exit 1
            fi
        fi
    
        # 判断脚本是否存在
        ES_BIN_SCRIPT="${ES_HOME}/bin/elasticsearch"
        if test ! -x "${ES_BIN_SCRIPT}"
        then
            echo "\n\033[31;1mCouldn't find ElasticSearch server ${ES_BIN_SCRIPT}\033[0m"
            exit 1
        fi
    
         # 目录切换到${ES_HOME},再次调用pushd会回到切换前目录，可循环调用
        pushd ${ES_HOME} > /dev/null 2>&1
        ES_OPTS="-d -p ${ES_PID_FILE}"
        ES_START_COMMAND="/usr/bin/env ${ES_BIN_SCRIPT} ${ES_OPTS} > ${ES_LOG} 2>&1"
        # 使用$ES_USER启动elasticsearch
        su ${ES_USER} -c "${ES_START_COMMAND}" > /dev/null 2>&1
        # 获取执行结果
        local RETURN_CODE=$?
    
        if test -s ${ES_PID_FILE}
        then
            local ES_PID="$(cat ${ES_PID_FILE})" > /dev/null 2>&1
        else
            local ES_PID="$(ps ax|grep 'java'|grep 'elasticsearch'|awk '{print $1}')" > /dev/null 2>&1
        fi
    
        # 记录PID
        # echo "${ES_PID}" > "${ES_PID_FILE}"
    
        # 删除pushd压入栈的目录
        popd > /dev/null 2>&1
        if test -z ${START_WAIT}
        then
            START_WAIT=10
        fi
        while test ! -s ${ES_PID_FILE} -a ${START_WAIT} -ge 0
        do
            sleep 1
            echo -e "\033[1;34m.\033[0m\c"
            START_WAIT=`expr ${START_WAIT} - 1`
        done
        if test "${RETURN_CODE}" -ne 0 -o "${#ES_PID}" -eq 0 -o ! -s "${ES_PID_FILE}"; then
            echo -e "\nStarting ElasticSearch \t\t\t\t \033[31;1m[failure]\033[0m"
            exit 1
        else
            echo -e "\nStarting ElasticSearch  \t\t\t\t \033[32m[ OK ]\033[0m\t\033[1mpid=${ES_PID}\033[0m"
        fi
    }
    
    
    
    function stop(){
        echo -n -e "\033[1;34mStopping elasticsearch...\033[0m\n"
        if [ -z "${SHUTDOWN_WAIT}" ]
        then
            SHUTDOWN_WAIT=5
        fi
    
        if test ! -s ${ES_PID_FILE}
        then
            echo -e "\033[1;31m\$ES_PID_FILE as set (${ES_PID_FILE}) but the specified file does not exist.Is elasticsearch running? Assuming it has stopped and proceeding.\033[0m"
            if test -f ${ES_PID_FILE}
            then
                rm -rf ${ES_PID_FILE}
            fi
            return 0
        else
            local ES_PID="$(cat ${ES_PID_FILE})"
            # `kill -0` 判断进程是否存在，0存在，1不存
            if ! kill -0 ${ES_PID} > /dev/null 2>&1
            then
                echo -e "\033[1;31mPID file ($PIDFILE) found but no matching process was found. Nothing to do.\033[0m"
                if test -f ${ES_PID_FILE}
                then
                    rm -rf ${ES_PID_FILE}
                fi
                return 0
            fi
            # 信号15，正常退出程序
            kill ${ES_PID} > /dev/null 2>&1
            while [ ${SHUTDOWN_WAIT} -ge 0 ]; do
                # 判断是否已经杀死进程
                if kill -0 ${ES_PID} > /dev/null 2>&1
                then
                    rm -rf ${ES_PID_FILE}
                    break
                fi
                # 没杀死，延迟1秒后再次判断
                if [ ${SHUTDOWN_WAIT} -gt 0 ]
                then
                  sleep 1
                fi
                SHUTDOWN_WAIT=`expr ${SHUTDOWN_WAIT} - 1`
            done
    
            if test -s "${ES_PID_FILE}"
            then
                # 再次判断
                if kill -0 ${ES_PID} > /dev/null 2>&1
                then
                    echo -e "\033[33mApplication still alive, sleeping for 20 seconds before sending SIGKILL.\033[0m"
                    sleep 20
                    # 再次判断
                    if kill -0 `cat ${ES_PID_FILE}` >/dev/null 2>&1
                    then
                        # 强制杀进程
                        kill -9 ${ES_PID} >/dev/null 2>&1
                        echo -e "\033[33mKilled with extreme prejudice\033[0m"
                    else
                        echo "Application stopped, no need to use SIGKILL"
                    fi
                fi
            fi
        fi
        echo -e "Stoping ElasticSearch  \t\t\t\t \033[31m[ OK ]\033[0m"
        if test -f ${ES_PID_FILE}
        then
            # 移除PID文件
            rm -rf ${ES_PID_FILE}
        fi
    }
    
    function status(){
        # GET PIDFILE?
        [ -s ${ES_PID_FILE} ] && ES_PID=$(cat ${ES_PID_FILE})
        # RUNNING
        if [[ ${ES_PID} && -d "/proc/${ES_PID}" ]]; then
            echo -e "Elasticsearch is running with pid \033[32m${ES_PID}\033[0m"
        fi
    
        # NOT RUNNING
        if [[ ! ${ES_PID} || ! -d "/proc/${ES_PID}" ]]; then
            echo "Elasticsearch not running"
        fi
    
        # STALE PID FOUND
        if [[ ! -d "/proc/${ES_PID}" && -f ${ES_PID_FILE} ]]; then
            echo -e "\033[1;31;40m[!] Stale PID found in ${ES_PID_FILE}\033[0m"
        fi
    }
    
    case $1 in
        start):
            start
            ;;
        stop):
            stop
            ;;
        restart):
            echo "Restart elasticsearch service"
            stop
            start
            ;;
        status):
            status
            ;;
        *):
            echo $"Usage: $0 {start|stop|restart|status [-v]|}"
            exit 1
            ;;
    esac
```

### 启动
    ```bash
        cp -f elasticsearch.sh /etc/init.d/elasticsearch
        chkconfig elasticsearch on
        // 启动服务
        service elasticsearch start
        // 关闭服务
        service elasticsearch stop
        // 重启服务
        service elasticsearch restart
    ```

### 验证
    ```bash
      curl -i -XGET localhost:9200   
      jps | grep Elasticsearch
    ```


## Kibana安装
### 简介
    Kibana是通向 Elastic产品集的窗口。它可以在 Elasticsearch中对数据进行视觉探索和实时分析       
  

### 源码安装
- 下载
    ```bash
        cd /usr/local/src/elk
        # 源码包下载
        wget https://artifacts.elastic.co/downloads/kibana/kibana-7.1.1-linux-x86_64.tar.gz
        # 解压
        tar -zxvf kibana-7.1.1-linux-x86_64.tar.gz   
        # 生产环境搭建
        cp -rf kibana-7.1.1 $ELK_HOME
        cd $ELK_HOME
        ln -s kibana-7.1.1  kibana    
    ```


- 升级node和npm版本至最新
    > 安装前确认node和npm为最新版本,否则运行报错    
    ```bash
        # 查看版本
        node -v
        npm -v
        # 卸载旧版本
        yum remove nodejs npm -y
        # nvm安装
        curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
        # 环境变量
        sed -i '$a\export NVM_NODEJS_ORG_MIRROR=http://npm.taobao.org/mirrors/node' /etc/profile
        sed -i 'export NVM_DIR="$HOME/.nvm"' /etc/profile
        sed -i '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' /etc/profile
        sed -i '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' /etc/profile
        source /etc/profile
        # 升级node至v10.15.2
        nvm install v10.15.2
        # 版本查看
        nvm current
        node -v
        npm -v
    ``` 


- Kibana配置

    [官方文档](<https://www.elastic.co/guide/en/kibana/current/introduction.html>)
    ```yaml
        #kibana.yml
        #端口
        server.port: 5601
        #绑定地址
        server.host: 0.0.0.0
        #es服务发现
        elasticsearch.hosts: ["http://localhost:9200","http://39.96.43.209:9200"]
        #中文支持
        i18n.locale: "zh-CN"
    ```

### 启动
```bash
    # 前台运行
    ./bin/kibana
    # 后台运行
    nohup ./bin/kibana &
```

### 验证
```bash
    # 方法一
    jobs
    # 方法二，kibana进程名node
    ps ax |grep node
    # 方法三，通过服务端口确定pid
    netstat -antp | grep 5601 | awk '{print $NF}'|awk -F/ '{print $1}'
    # 方法四, 状态码200
    curl -i -XHEAD http://localhost:5601/app/kibana
    # 方法五，浏览器访问 http://localhost:5601
```


## Logstash安装
### 简介
    Logstash是一个具有实时管道功能的开源数据收集引擎。Logstash可以将数据处理后写入目标服务，如ElasticSearch。

### 源码安装
- 下载
    ```bash
        cd /usr/local/src/elk
        # 源码包下载
        wget https://artifacts.elastic.co/downloads/logstash/logstash-7.1.1.tar.gz
        # 解压
        tar -zxvf logstash-7.1.1.tar.gz  
        # 生产环境搭建
        cp -rf logstash-7.1.1 $ELK_HOME
        cd $ELK_HOME
        ln -s logstash-7.1.1  logstash    
    ```
 
   
- Logstash配置

    [官方文档](<https://www.elastic.co/guide/en/logstash/current/introduction.html>)
    - logstash.yml   
    ```yaml
      #logstash.yml
    ```
    
    


### Logstash插件配置
> Input(生成事件) -> Filter(事件处理)  -> Output(输出事件)
#### [Input](<https://www.elastic.co/guide/en/logstash/current/transformation.html>)
#### [Filter](<https://www.elastic.co/guide/en/logstash/current/filter-plugins.html>)
#### [Output](<https://www.elastic.co/guide/en/logstash/current/output-plugins.html>)
#### [Codec](<https://www.elastic.co/guide/en/logstash/current/codec-plugins.html>)


### 启动
    ```bash
        # 命令调试
        logstash -e 'input {} filter {} output {}'
        # 验证配置文件，验证后退出， -t = --config.test_and_exit
        logstash -f logstash.conf -t
        # 制定配置文件启动并自动重载配置文件, -r = --config.reload.automatic
        logstash -f logstash.conf -r
        # 使用管道
        不加参数启动，则读取pipelines.yml中内容，实例化文件中设定的所有管道
    ```

### 验证
```bash
    jps | grep logstash
    ps ax | grep logstash
```

    
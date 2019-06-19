# ELK安装

  |     系统版本     |      JDK版本    |ElasticSearch版本|  Logstash版本   |  Kibana版本    |
 |:----------------:|:---------------:|:---------------:|:---------------:|:--------------:|
|  CentOS 6.8      | OpenJDK-12.0.1  |        7.1.1    |      7.1.1      |      7.1.1     |

## 文档链接
[ ElasticSearch官网](<https://www.elastic.co/cn/products/elasticsearch>)
[ Logstash官网](<https://www.elastic.co/cn/products/logstash>)
[ Kibana官网](<https://www.elastic.co/cn/products/kibana>)


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


- 启动

    编写服务器脚本`elasticsearch.sh`
    ```elasticsearch.sh
        #!/usr/bin/env bash
        # 
        # chkconfig -57 75
        # description: elasticsearch service
        # processname: elasticsearch
        # version: elasticsearch-7.1.1
        
        ES_HOME=
        ES_BIN_DIR=
        ES_DATA_DIR=
        ES_LOG_DIR=
        
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
        ES_OPTS="-d"
        
        egrep "^${ES_GROUP}" /etc/group >& /dev/null
        if [ $? -ne 0 ];then
          groupadd  ${ES_GROUP}
        fi
        
        egrep "^${ES_USER}" /etc/passwd >& /dev/null
        if [ $? -ne 0 ];then
          useradd -g ${ES_GROUP}  ${ES_USER}
        fi
        chown -R ${ES_USER}:${ES_GROUP} ${ES_HOME}
        
        function start(){
            echo -e "\033[1;34mStarting elasticsearch...\033[0m"
        
            if [ ! -d ${ES_PID_DIR} ]; then
                mkdir -p "${ES_PID_DIR}"
            fi
            chown -R ${ES_USER}:${ES_GROUP} ${ES_PID_DIR}
        
            # 判断服务是否已经启动
            if test -s "${ES_PID_FILE}"
            then
                local ES_PID="$(cat ${ES_PID_FILE})"
                ES_PID=${ES_PID:-"$(ps ax|grep 'java'|grep 'elasticsearch'|awk '{print $1}')"}
                if kill -0 ${ES_PID} > /dev/null 2> /dev/null
                then
                    if ps wwwp ${ES_PID} > /dev/null
                    then    # The pid contains a mysqld process
                          echo ${ES_PID} > "${ES_PID_FILE}"
                          echo -e "\033[33mA elasticsearch process already exists\033[0m,\033[1mpid=${ES_PID}\033[0m"
                          exit 1
                    fi
                else
                    local ES_PID="$(ps ax|grep 'java'|grep 'elasticsearch'|awk '{print $1}')"
                    if kill -0 ${ES_PID} > /dev/null 2> /dev/null
                    then
                        if ps wwwp ${ES_PID} > /dev/null
                        then    # The pid contains a mysqld process
                              echo ${ES_PID} > "${ES_PID_FILE}"
                              echo -e "\033[33mA elasticsearch process already exists\033[0m,\033[1mpid=${ES_PID}\033[0m"
                              exit 1
                        fi
                    fi
                fi
        
                rm -f ${ES_PID_FILE}
                if test -f "${ES_PID_FILE}"
                then
                    echo "Fatal error: Can't remove the pid file:
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
                echo "\033[31;1mCouldn't find ElasticSearch server ${ES_BIN_SCRIPT}\033[0m"
                exit 1
            fi
        
             # 目录切换到${ES_HOME},再次调用pushd会回到切换前目录，可循环调用
            pushd ${ES_HOME} > /dev/null 2>&1
        
            ES_START_COMMAND="/usr/bin/env ${ES_BIN_SCRIPT} ${ES_OPTS} > ${ES_LOG} 2>&1"
            # 使用$ES_USER启动elasticsearch
            su ${ES_USER} -c "${ES_START_COMMAND}" > /dev/null 2>&1
            # 获取执行结果
            local RETURN_CODE=$?
            local ES_PID="$(ps ax|grep 'java'|grep 'elasticsearch'|awk '{print $1}')"
            # 记录PID
            echo "${ES_PID}" > "${ES_PID_FILE}"
        
            # 删除pushd压入栈的目录
            popd > /dev/null 2>&1
        
            # sleep 5
            if test ${RETURN_CODE} -ne 0 -o ${#ES_PID} -eq 0; then
                echo -e "Starting ElasticSearch \t\t\t\t \033[31;1m[failure]\033[0m"
                exit 1
            else
                echo -e "Starting ElasticSearch  \t\t\t\t \033[32m[ OK ]\033[0m\t\033[1mpid=${ES_PID}\033[0m"
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
            [ -f ${ES_PID_FILE} ] && ES_PID=$(cat ${ES_PID_FILE})
            # RUNNING
            if [[ ${ES_PID} && -d "/proc/${ES_PID}" ]]; then
                success
                echo -e "Elasticsearch is running with pid ${ES_PID}"
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


## Logstash安装
## Kibana安装

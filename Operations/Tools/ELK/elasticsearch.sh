#!/usr/bin/env bash
#
# chkconfig -57 75
# description: elasticsearch service
# processname: elasticsearch

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
echo ${ES_HOME}
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
ES_LOG="${ES_HOME}/log/elasticsearch.log"
ES_GROUP="elk"
ES_USER="elk"
ES_OPTS="-d"
ES_BIN_SCRIPT="/usr/bin/env ${ES_HOME}/bin/elasticsearch ${ES_OPTS} > ${ES_LOG} 2>&1 &  echo \$! > ${ES_PID_FILE}"
egrep "^${ES_GROUP}" /etc/group >& /dev/null
if [ $? -ne 0 ];then
  groupadd  ${ES_GROUP}
fi

egrep "^${ES_USER}" /etc/passwd >& /dev/null
if [ $? -ne 0 ];then
  useradd -g ${ES_GROUP}  ${ES_USER}
fi
chown -R ${ES_USER}:${ES_GROUP} {ES_HOME}

function start(){
    echo -e "\033[1mStarting elasticsearch...\033[0m"

    if [ -z ${ES_PID_DIR} ]; then
        mkdir -p "${ES_PID_DIR}"
    fi

    if [ -f ${ES_PID_FILE} ]; then
        echo -e "\033[31;1mPID file found in ${ES_PID_FILE}, elasticsearch already running?\033[0m"
        local ES_PID="$(cat ${ES_PID_FILE})"
        local ES_RUNNING_INFO="$( ps ax | grep 'java' | grep ${ES_PID} )"

        if [ ! -z "${ES_RUNNING_INFO}" ] ; then
          echo -e "\033[31;1mPID ${ES_PID} still alive, elasticsearch is already running. Doing nothing\033[0m"
          return 1
        fi
    fi

    # 目录切换到${ES_HOME},再次调用pushd会回到切换前目录，可循环调用
    pushd ${ES_HOME} > /dev/null 2>&1
    # 使用$ES_USER启动elasticsearch
    echo "${ES_BIN_SCRIPT}"
    su ${ES_USER} -c "${ES_BIN_SCRIPT}" > /dev/null 2>&1
    # 获取进程PID
    local ES_PID=$!
    # 获取执行结果
    local RETURN_CODE=$?
    # 删除pushd压入栈的目录
    popd > /dev/null 2>&1

    if [ ${RETURN_CODE} -ne 0 ] ; then
        failure
        echo -e "Elasticsearch start failure"
        exit 1
    else
        success
        echo -e "Elasticsearch started successfully,${ES_PID}"
    fi
}



function stop(){
    echo -n -e "\033[1mStopping elasticsearch...\033[0m"
    if [ -z "${SHUTDOWN_WAIT}" ]; then
        SHUTDOWN_WAIT=5
    fi

    if [ -z "${ES_PID_FILE}" -o ! -f "${ES_PID_FILE}" ]; then
        echo "\$ES_PID_FILE as set (${ES_PID_FILE}) but the specified file does not exist. Is elasticsearch running? Assuming it has stopped and pro\
        ceeding."
        return 0
    else
        local ES_PID="$(cat ${ES_PID_FILE})"
        # `kill -0` 判断进程是否存在，0存在，1不存
        kill -0 ${ES_PID} >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "PID file ($PIDFILE) found but no matching process was found. Nothing to do."
            return 0
        fi
        # 信号15，正常退出程序
        kill ${ES_PID} > /dev/null 2>&1
        while [ ${SHUTDOWN_WAIT} -ge 0 ]; do
            # 判断是否已经杀死进程
            kill -0 ${ES_PID} >/dev/null 2>&1
            if [ $? -ne 0 ]; then
                rm ${ES_PID_FILE}
                break
            fi
            # 没杀死，延迟1秒后再次判断
            if [ ${SHUTDOWN_WAIT} -gt 0 ]; then
              sleep 1
            fi
            SHUTDOWN_WAIT=`expr ${SHUTDOWN_WAIT} - 1`
        done

        if [ -f "${ES_PID_FILE}" ]; then
            # 再次判断
            kill -0 ${ES_PID} > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo "Application still alive, sleeping for 20 seconds before sending SIGKILL"
                sleep 20
                # 再次判断
                kill -0 `cat ${ES_PID_FILE}` >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    # 强制杀进程
                    kill -9 ${ES_PID} >/dev/null 2>&1
                    echo "Killed with extreme prejudice"
                else
                    echo "Application stopped, no need to use SIGKILL"
                fi
                # 移除PID文件
                rm ${ES_PID_FILE}
            fi
        fi
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

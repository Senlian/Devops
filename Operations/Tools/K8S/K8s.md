# K8S环境搭建
## 相关文档
[K8S中文文档](<https://www.kubernetes.org.cn/k8s>)

[K8S官方文档](<https://kubernetes.io/zh/docs/concepts/architectu re/nodes/>)

[K8S部署](<https://blog.51cto.com/lizhenliang/2325770>)

[K8S证书](<https://www.jianshu.com/p/944f2003c829>)

[k8s下载地址](<https://v1-14.docs.kubernetes.io/docs/setup/release/notes/>)

[TCP/IP协议](<https://www.cnblogs.com/imyalost/p/6086808.html>)

[Etcd文档](<https://etcd.io/docs/v3.3.12/>)


## 系统环境

Node|IP|CentOS|kernel|cpu|memory
|:---|:---|:---|:---|:---|:---|
master|192.168.159.3|CentOS Linux release 7.4.1708 (Core)|3.10.0-693.el7.x86_64|Intel(R) Core(TM) i5-7500 CPU @ 3.40GHz * 1|2G
node1|192.168.159.4|CentOS Linux release 7.4.1708 (Core)|3.10.0-693.el7.x86_64|Intel(R) Core(TM) i5-7500 CPU @ 3.40GHz * 1|2G
node2|192.168.159.5|CentOS Linux release 7.4.1708 (Core)|3.10.0-693.el7.x86_64|Intel(R) Core(TM) i5-7500 CPU @ 3.40GHz * 1|2G
node3|192.168.159.6|CentOS Linux release 7.4.1708 (Core)|3.10.0-693.el7.x86_64|Intel(R) Core(TM) i5-7500 CPU @ 3.40GHz * 1|2G

## 软件环境

Node|IP|etcd|kube-apiserver|kube-controller-manager|kube-scheduler|docker|kubelet|kube-proxy
|:---|:---|:---|:---|:---|:---|:---|:---|:---|
master|192.168.159.3|3.3.13|
node1|192.168.159.4|3.3.13|
node2|192.168.159.5|3.3.13|
node3|192.168.159.5|3.3.13|

## Master服务安装
Node|IP|etcd|kube-apiserver|kube-controller-manager|kube-scheduler
|:---|:---|:---|:---|:---|:---|
master|192.168.159.3|3.3.13|v1.15.2|v1.15.2|v1.15.2


### etcd安装
[ETCD官方文档](<https://etcd.io/docs/v3.3.12/op-guide/configuration/>):https://etcd.io/docs/v3.3.12/op-guide/configuration/

#### 生成CA证书        
##### PKI工具 
[github地址](< https://github.com/cloudflare/cfssl>): https://github.com/cloudflare/cfssl     
    
[下载地址](<https://pkg.cfssl.org/>):https://pkg.cfssl.org/        
    
[参考地址1](<https://blog.51cto.com/liuzhengwei521/2120535?utm_source=oschina-app>):https://blog.51cto.com/liuzhengwei521/2120535?utm_source=oschina-app
            
[参考地址2](<https://segmentfault.com/a/1190000017408573?utm_source=tag-newest>):https://segmentfault.com/a/1190000017408573?utm_source=tag-newest

[参考地址3](<https://www.cnblogs.com/effortsing/p/10332492.html>):https://www.cnblogs.com/effortsing/p/10332492.html
    
    
##### 工具安装    
```bash
  wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
  wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
  wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
  chmod +x cfssl*
  mv cfssl* /usr/local/bin
```
    
    
##### 创建CA认证中心        
+ CA证书生成策略文件
    ```bash
      cfssl print-defaults config > ca-config.json # 生成证书策略模板文件
      cat > ca-config.json << EOF
        {
            "signing": {
                "default": {
                    "expiry": "8760h"
                },
                "profiles": {
                    "server": {
                        "expiry": "8760h",
                        "usages": [
                            "signing",
                            "key encipherment",
                            "server auth"
                        ]
                    },
                    "client": {
                        "expiry": "8760h",
                        "usages": [
                            "signing",
                            "key encipherment",
                            "client auth"
                        ]
                    },
                   "peer": {
                        "expiry": "8760h",
                        "usages": [
                            "signing",
                            "key encipherment",
                            "server auth",
                            "client auth"
                        ]
                    }
                }
            }
        }
  EOF
  ```
    
  * 名词解释：
    ```text
        默认策略（default），指定了证书的有效期是一年(8760h)；
        expiry，证书的有效期；
        signing, 表示该证书可用于签名其它证书；生成的 ca.pem 证书中 CA=TRUE；
        server auth，表示 client 可以用该 CA 对 server 提供的证书进行验证；
        client auth，表示 server 可以用该 CA 对 client 提供的证书进行验证；
        profiles，定义具体证书生成策略，名称可以自定义，建议与功能相关；
        服务端证书，profiles用途包含"server auth"；
        客户端证书，profiles用途包含"client auth"；
        对等证书或双向证书，profiles用途包含"server auth"和"client auth"。
    ```
   
- CA证书申请文件
  ```bash
    cfssl print-defaults csr > ca-csr.json # 生成签名申请模板文件
    cat > ca-csr.json << EOF
    {
        "CN": "CA",
        "key": {
            "algo": "ecdsa",
            "size": 256
        },
        "names": [
            {
                "C": "CN",
                "L": "ChengDu",
                "ST": "SiChuan"
            }
        ]
    }
  EOF
  ```
  * 名词解释
    ```text
       CN,通用名称，kube-apiserver提取作为请求的用户名，浏览器用于验证网站是否合法；
       hosts,主机，如果不为空则指定授权使用该证书的IP或域名列表，必须包含服务器的本地主机名，`127.0.0.1`，主机私有IP地址。
       C,国家
       L,城市
       O,单位，kube-apiserver 从证书中提取该字段作为请求用户所属的组 (Group)
       OU,部门
       ST,省份或州，
    ```

+ 生成CA证书和私钥  
    ```bash
      cfssl gencert --initca ca-csr.json | cfssljson -bare ca
      ls
      >> ca-config.json  ca.csr  ca-csr.json  ca-key.pem  ca.pem
    ``` 
    * 名词解释
        ```text
          ca-config.json, 证书生成策略，生成新证书时用-profile指定策略名
          ca-csr.json，证书申请文件
          ca.csr， 证书签名请求，用于交叉签名或重新签名
          ca-key.pem， 私钥
          ca.pem， 证书
        ```     

- 证书验证
    
    [openssl x509命令介绍](<https://blog.csdn.net/abccheng/article/details/82697237>)
    ```text
        # 方法一
        openssl x509 -in ca.pem -text -noout
        # 方法二
        cfssl-certinfo -cert ca.pem
    ```            
  
    
##### 生成ETCD服务证书
+ ETCD证书申请文件  
    ```bash 
        # cat > peer-csr.json << EOF
        cat > etcd-csr.json << EOF
            {
                "CN": "etcd",
                "hosts": [
                    192.168.159.3，
                    192.168.159.4，
                    192.168.159.5，
                    127.0.0.1，
                    localhost，
                    localhost.localdomain
                ], 
                "key": {
                    "algo": "ecdsa",
                    "size": 256
                },
                "names": [
                    {
                        "C": "CN",
                        "L": "ChengDu",
                        "O": "JSQ",
                        "OU": "devops",
                        "ST": "SiChuan"
                    }
                ]
            }
        EOF  
          
        cat > etcdctl-csr.json << EOF
            {
                "CN": "etcdctl",
                "key": {
                    "algo": "ecdsa",
                    "size": 256
                },
                "names": [
                    {
                        "C": "CN",
                        "L": "ChengDu",
                        "O": "JSQ",
                        "OU": "devops",
                        "ST": "SiChuan"
                    }
                ]
            }
        EOF 
    ```

- 利用CA证书和私钥生成ETCD的对等证书和私钥
    ```bash
      cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer peer-csr.json | cfssljson -bare peer
      ls peer*
      >> peer.csr  peer-csr.json  peer-key.pem  peer.pem
    ``` 
 
+ 利用CA证书和私钥生成ETCD的服务端证书和私钥
    ```bash
      cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server etcd-csr.json | cfssljson -bare etcd
      ls etcd*
      >> etcd.csr  etcd-csr.json etcd-key.pem  etcd.pem
    ``` 

- 利用CA证书和私钥生成ETCD的客户端证书和私钥
    ```bash
      cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client etcdctl-csr.json | cfssljson -bare etcdctl
      ls etcdctl*
      >> etcdctl.csr  etcdctl-csr.json  etcdctl-key.pem  etcdctl.pem
    ```                        

          
- 证书验证

    [openssl x509命令介绍](<https://blog.csdn.net/abccheng/article/details/82697237>)
    ```text
        # 方法一
        openssl x509 -text -noout -in etcd-peer.pem
        # 方法二
        cfssl-certinfo -cert etcd-peer.pem
    ```  
    

#### 启动非安全集群
##### 在master启动etcd01节点
######  ETCD下载

[下载地址:](<https://github.com/etcd-io/etcd/releases>)
https://github.com/etcd-io/etcd/releases
```bash
  mkdir /home/k8s
  cd /home/k8s
  wget https://github.com/etcd-io/etcd/releases/download/v3.3.13/etcd-v3.3.13-linux-amd64.tar.gz
  tar -zxvf etcd-v3.3.13-linux-amd64.tar.gz
  mv etcd-v3.3.13-linux-amd64 etcd
  chmod -R +x etcd/
  cp -f ./{etcd,etcdctl} /usr/bin/
  cp -f ./{etcd,etcdctl} /usr/local/bin/
```
    
###### ETCD配置文件
```bash
mkdir -p /opt/etcd/{data,etc}
cat > /opt/etcd/etc/etcd.conf << EOF
#[Member]
ETCD_NAME="etcd-1"
ETCD_DATA_DIR="/opt/etcd/data"
ETCD_LISTEN_PEER_URLS="http://192.168.159.3:2380"
ETCD_LISTEN_CLIENT_URLS="http://192.168.159.3:2379,http://127.0.0.1:2379"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.159.3:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.159.3:2379"
ETCD_INITIAL_CLUSTER="etcd-1=http://192.168.159.3:2380,etcd-2=http://192.168.159.4:2380,etcd-3=http://192.168.159.5:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new" # 此处注意为new，意为创建新集群；existing意为加入已有集群
EOF
```

###### ETCD服务启动文件
[systemd中文手册](<http://www.jinbuguo.com/systemd/systemd.exec.html>):
http://www.jinbuguo.com/systemd/systemd.exec.html

```bash
cat >  vim /usr/lib/systemd/system/etcd.service << EOF    
    [Unit]
    Description=Etcd Server
    After=network.target
    After=network-online.target
    Wants=network-online.target
    
    [Service]
    Type=notify
    EnvironmentFile=-/opt/etcd/etc/etcd.conf
    ExecStart=/home/k8s/etcd/etcd \
    --name=${ETCD_NAME} \
    --data-dir=${ETCD_DATA_DIR} \
    --listen-peer-urls=${ETCD_LISTEN_PEER_URLS} \
    --listen-client-urls=${ETCD_LISTEN_CLIENT_URLS} \
    --initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
    --advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} \
    --initial-cluster=${ETCD_INITIAL_CLUSTER} \
    --initial-cluster-token=${ETCD_INITIAL_CLUSTER_TOKEN} \
    --initial-cluster-state=${ETCD_INITIAL_CLUSTER_STATE} 
    Restart=on-failure
    LimitNOFILE=65536
    
    [Install]
    WantedBy=multi-user.target
EOF
```

##### 在node1启动etcd02节点
######  ETCD下载
    如master操作
    
###### ETCD配置文件
```bash
mkdir -p /opt/etcd/{data,etc}
cat > /opt/etcd/etc/etcd.conf << EOF
    #[Member]
    ETCD_NAME="etcd-2"
    ETCD_DATA_DIR="/opt/etcd/data"
    ETCD_LISTEN_PEER_URLS="http://192.168.159.4:2380"
    ETCD_LISTEN_CLIENT_URLS="http://192.168.159.4:2379,http://127.0.0.1:2379"
    
    #[Clustering]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.159.4:2380"
    ETCD_ADVERTISE_CLIENT_URLS="http://192.168.159.4:2379"
    ETCD_INITIAL_CLUSTER="etcd-1=http://192.168.159.3:2380,etcd-2=http://192.168.159.4:2380,etcd-3=http://192.168.159.5:2380"
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
    ETCD_INITIAL_CLUSTER_STATE="new" # 此处注意为new，意为创建新集群；existing意为加入已有集群
EOF
```
###### ETCD服务启动文件
    如master操作

##### 在node2启动etcd03节点
######  ETCD下载
    如master操作   
    
###### ETCD配置文件
```bash
mkdir -p /opt/etcd/{data,etc}
cat > /opt/etcd/etc/etcd.conf << EOF
    #[Member]
    ETCD_NAME="etcd-2"
    ETCD_DATA_DIR="/opt/etcd/data"
    ETCD_LISTEN_PEER_URLS="http://192.168.159.4:2380"
    ETCD_LISTEN_CLIENT_URLS="http://192.168.159.4:2379,http://127.0.0.1:2379"
    
    #[Clustering]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.159.4:2380"
    ETCD_ADVERTISE_CLIENT_URLS="http://192.168.159.4:2379"
    ETCD_INITIAL_CLUSTER="etcd-1=http://192.168.159.3:2380,etcd-2=http://192.168.159.4:2380,etcd-3=http://192.168.159.5:2380"
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
    ETCD_INITIAL_CLUSTER_STATE="new" # 此处注意为new，意为创建新集群；existing意为加入已有集群
EOF
```
###### ETCD服务启动文件
    如master操作
    

##### 网络准备
```bash
cat >>/etc/hosts<< EOF
    192.168.159.3 master
    192.168.159.4 node1
    192.168.159.5 node2
EOF
# 防火墙设置，开放2379和2380端口,如果启动防火墙但未放开端口则集群状态为“degraded”，
# 开启防火墙的节点状态为“are all unreachable”
# 2379端口提供给客户端访问集群，客户端如：etcdctl
# 2380端口提供给集群节点间通信
systemctl start firewalld
firewall-cmd --zone=public --add-port=2379/tcp --permanent
firewall-cmd --zone=public --add-port=2380/tcp --permanent
firewall-cmd --reload
firewall-cmd --list-all
```

##### 启动集群
```bash
systemctl start etcd
```
> 注意: 集群节点需要同时启动才能成功，否则会报错某个节点无法找到；如果是重新创建集群，则需要删除旧的数据目录。

##### 集群健康检查
`etcdctl cluster-health`
```text
    member 8ada33a16cb8b5f9 is healthy: got healthy result from http://192.168.159.4:2379
    member df5c33b8666738a6 is healthy: got healthy result from http://192.168.159.3:2379
    member e689a191b9fab04f is healthy: got healthy result from http://192.168.159.5:2379
    cluster is healthy # cluster is degraded表示集群至少有一个节点不可达
```
`etcdctl member list`
```text
    8ada33a16cb8b5f9: name=etcd-2 peerURLs=http://192.168.159.4:2380 clientURLs=http://192.168.159.4:2379 isLeader=true # 主节点
    df5c33b8666738a6: name=etcd-1 peerURLs=http://192.168.159.3:2380 clientURLs=http://192.168.159.3:2379 isLeader=false
    e689a191b9fab04f: name=etcd-3 peerURLs=http://192.168.159.5:2380 clientURLs=http://192.168.159.5:2379 isLeader=false
```

#### 升级为安全集群
    相对于删除后重建安全集群，逐步升级为安全集群可避免旧数据丢失，以下采取逐步升级的方式
##### 证书拷贝
```bash
    scp -P 22 /opt/etcd/pki/*.pem root@192.168.159.4:/opt/etcd/pki/
    scp -P 22 /opt/etcd/pki/*.pem root@192.168.159.5:/opt/etcd/pki/
```

##### 开启集群外部pki安全认证--服务端证书使用
    注意：外部的意思在本篇就是使用 etcdtl来访问，etcdctl 就是外部客户端。如果k8s的apiserver访问etcd，那么apiserver就是客户端
###### 修改master节点配置
```bash
cat > /opt/etcd/etc/etcd.conf << EOF
    #[Member]
    ETCD_NAME="etcd-1"
    ETCD_DATA_DIR="/opt/etcd/data"
    ETCD_LISTEN_PEER_URLS="http://192.168.159.3:2380"
    ETCD_LISTEN_CLIENT_URLS="https://192.168.159.3:2379,http://127.0.0.1:2379"
    
    #[Clustering]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.159.3:2380"
    ETCD_ADVERTISE_CLIENT_URLS="https://192.168.159.3:2379"
    ETCD_INITIAL_CLUSTER="etcd-1=http://192.168.159.3:2380,etcd-2=http://192.168.159.4:2380,etcd-3=http://192.168.159.5:2380"
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
    ETCD_INITIAL_CLUSTER_STATE="new" # 此处注意为new，意为创建新集群；existing意为加入已有集群
    #[Security]
    #开启集群外部服务端认证
    ETCD_CERT_FILE="/opt/etcd/pki/etcd.pem" #服务器证书，可以使用对等证书
    ETCD_KEY_FILE="/opt/etcd/pki/etcd-key.pem" #服务器证书私钥，可以使用对等证书私钥
EOF
```
###### 修改master节点服务文件
```bash
cat >  vim /usr/lib/systemd/system/etcd.service << EOF    
    [Unit]
    Description=Etcd Server
    After=network.target
    After=network-online.target
    Wants=network-online.target
    
    [Service]
    Type=notify
    EnvironmentFile=-/opt/etcd/etc/etcd.conf
    ExecStart=/home/k8s/etcd/etcd \
    --name=${ETCD_NAME} \
    --data-dir=${ETCD_DATA_DIR} \
    --listen-peer-urls=${ETCD_LISTEN_PEER_URLS} \
    --listen-client-urls=${ETCD_LISTEN_CLIENT_URLS} \
    --initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
    --advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} \
    --initial-cluster=${ETCD_INITIAL_CLUSTER} \
    --initial-cluster-token=${ETCD_INITIAL_CLUSTER_TOKEN} \
    --initial-cluster-state=${ETCD_INITIAL_CLUSTER_STATE} \
    --cert-file=${ETCD_CERT_FILE} \ #新增证书
    --key-file=${ETCD_KEY_FILE} #新增证书私钥
    Restart=on-failure
    LimitNOFILE=65536
    
    [Install]
    WantedBy=multi-user.target
EOF
```
###### 重启master节点并验证
```bash
    systemctl daemon-reload && systemctl restart etcd
    etcdctl cluster-health # 此时没加CA根证书，提示master节点不可达
    etcdctl -ca-file /opt/etcd/pki/ca.pem cluster-health # 加上CA根证书，集群验证通过,节点链接变为https模式
```
```text
    member 8ada33a16cb8b5f9 is healthy: got healthy result from http://192.168.159.4:2379
    member df5c33b8666738a6 is healthy: got healthy result from https://192.168.159.3:2379
    member e689a191b9fab04f is healthy: got healthy result from http://192.168.159.5:2379
    cluster is healthy
```

###### 修改node1节点配置
```bash
cat > /opt/etcd/etc/etcd.conf << EOF
    #[Member]
    ETCD_NAME="etcd-2"
    ETCD_DATA_DIR="/opt/etcd/data"
    ETCD_LISTEN_PEER_URLS="http://192.168.159.4:2380"
    ETCD_LISTEN_CLIENT_URLS="https://192.168.159.4:2379,http://127.0.0.1:2379"
    
    #[Clustering]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.159.4:2380"
    ETCD_ADVERTISE_CLIENT_URLS="https://192.168.159.4:2379"
    ETCD_INITIAL_CLUSTER="etcd-1=http://192.168.159.3:2380,etcd-2=http://192.168.159.4:2380,etcd-3=http://192.168.159.5:2380"
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
    ETCD_INITIAL_CLUSTER_STATE="new" # 此处注意为new，意为创建新集群；existing意为加入已有集群
    #[Security]
    #开启集群外部服务端认证
    ETCD_CERT_FILE="/opt/etcd/pki/etcd.pem" #新增证书
    ETCD_KEY_FILE="/opt/etcd/pki/etcd-key.pem" #新增证书私钥
EOF
```
###### 修改node1节点服务文件
    同master设置
###### 重启node1节点并验证
```bash
    systemctl daemon-reload && systemctl restart etcd
    etcdctl cluster-health # 此时没加CA根证书，提示master节点不可达
    etcdctl -ca-file /opt/etcd/pki/ca.pem cluster-health # 加上CA根证书，集群验证通过,节点链接变为https模式
```
```text
    member 8ada33a16cb8b5f9 is healthy: got healthy result from https://192.168.159.4:2379
    member df5c33b8666738a6 is healthy: got healthy result from https://192.168.159.3:2379
    member e689a191b9fab04f is healthy: got healthy result from http://192.168.159.5:2379
    cluster is healthy
```


###### 修改node2节点配置
```bash
cat > /opt/etcd/etc/etcd.conf << EOF
    #[Member]
    ETCD_NAME="etcd-3"
    ETCD_DATA_DIR="/opt/etcd/data"
    ETCD_LISTEN_PEER_URLS="http://192.168.159.5:2380"
    ETCD_LISTEN_CLIENT_URLS="https://192.168.159.5:2379,http://127.0.0.1:2379"
    
    #[Clustering]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.159.5:2380"
    ETCD_ADVERTISE_CLIENT_URLS="https://192.168.159.5:2379"
    ETCD_INITIAL_CLUSTER="etcd-1=http://192.168.159.3:2380,etcd-2=http://192.168.159.4:2380,etcd-3=http://192.168.159.5:2380"
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
    ETCD_INITIAL_CLUSTER_STATE="new" # 此处注意为new，意为创建新集群；existing意为加入已有集群
    #[Security]
    #开启集群外部服务端认证
    ETCD_CERT_FILE="/opt/etcd/pki/etcd.pem" #新增证书
    ETCD_KEY_FILE="/opt/etcd/pki/etcd-key.pem" #新增证书私钥
EOF
```
###### 修改node2节点服务文件
    同master设置
###### 重启node2节点并验证
```bash
    systemctl daemon-reload && systemctl restart etcd
    etcdctl cluster-health # 此时没加CA根证书，提示master节点不可达
    etcdctl -ca-file /opt/etcd/pki/ca.pem cluster-health # 加上CA根证书，集群验证通过,节点链接变为https模式
```
```text
    member 8ada33a16cb8b5f9 is healthy: got healthy result from https://192.168.159.4:2379
    member df5c33b8666738a6 is healthy: got healthy result from https://192.168.159.3:2379
    member e689a191b9fab04f is healthy: got healthy result from https://192.168.159.5:2379
    cluster is healthy
```


##### 开启客户端验证--客户端证书使用
    即开启服务端对客户端的验证
###### 启动master客户端验证
```bash
cat > /opt/etcd/etc/etcd.conf << EOF
    #[Member]
    ETCD_NAME="etcd-1"
    ETCD_DATA_DIR="/opt/etcd/data"
    ETCD_LISTEN_PEER_URLS="http://192.168.159.3:2380"
    ETCD_LISTEN_CLIENT_URLS="https://192.168.159.3:2379,http://127.0.0.1:2379"
    
    #[Clustering]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.159.3:2380"
    ETCD_ADVERTISE_CLIENT_URLS="https://192.168.159.3:2379"
    ETCD_INITIAL_CLUSTER="etcd-1=http://192.168.159.3:2380,etcd-2=http://192.168.159.4:2380,etcd-3=http://192.168.159.5:2380"
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
    ETCD_INITIAL_CLUSTER_STATE="new" # 此处注意为new，意为创建新集群；existing意为加入已有集群
    #[Security]
    #开启集群外部服务端认证
    ETCD_CERT_FILE="/opt/etcd/pki/etcd.pem" #新增证书
    ETCD_KEY_FILE="/opt/etcd/pki/etcd-key.pem" #新增证书私钥
    #开启客户端验证
    ETCD_CLIENT_CERT_AUTH="true"
    ETCD_TRUSTED_CA_FILE="/opt/etcd/pki/ca.pem"
EOF
```
###### 修改master服务配置
```bash
cat > /usr/lib/systemd/system/etcd.service << EOF
    [Unit]
    Description=Etcd Server
    After=network.target
    After=network-online.target
    Wants=network-online.target
    
    [Service]
    Type=notify
    EnvironmentFile=-/opt/etcd/etc/etcd.conf
    ExecStart=/home/k8s/etcd/etcd \
    --name=${ETCD_NAME} \
    --data-dir=${ETCD_DATA_DIR} \
    --listen-peer-urls=${ETCD_LISTEN_PEER_URLS} \
    --listen-client-urls=${ETCD_LISTEN_CLIENT_URLS} \
    --advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} \
    --initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
    --initial-cluster=${ETCD_INITIAL_CLUSTER} \
    --initial-cluster-token=${ETCD_INITIAL_CLUSTER_TOKEN} \
    --initial-cluster-state=${ETCD_INITIAL_CLUSTER_STATE} \
    --cert-file=${ETCD_CERT_FILE} \
    --key-file=${ETCD_KEY_FILE} \
    --client-cert-auth=${ETCD_CLIENT_CERT_AUTH} \ # 开启客户端验证
    --trusted-ca-file=${ETCD_TRUSTED_CA_FILE}     # 生成客户端证书的CA证书
    Restart=on-failure
    LimitNOFILE=65536
    
    [Install]
    WantedBy=multi-user.target
EOF
```
###### 重启master并验证
```bash
    systemctl daemon-reload && systemctl restart etcd
    etcdctl cluster-health # 此时没加CA根证书，提示master节点不可达
    etcdctl -ca-file /opt/etcd/pki/ca.pem cluster-health # 加上CA根证书，master不可访问，因为没有配置客户端证书
    etcdctl --ca-file=/opt/etcd/pki/ca.pem --cert-file=etcdctl.pem --key-file=etcdctl-key.pem cluster-health # 加上CA根证书，集群正常,也可以使用对等证书及其私钥进行验证
```
```text
    member 8ada33a16cb8b5f9 is healthy: got healthy result from https://192.168.159.4:2379
    member df5c33b8666738a6 is healthy: got healthy result from https://192.168.159.3:2379
    member e689a191b9fab04f is healthy: got healthy result from https://192.168.159.5:2379
    cluster is healthy
```


###### 启动node1客户端验证
```bash
cat > /opt/etcd/etc/etcd.conf << EOF
    #[Member]
    ETCD_NAME="etcd-2"
    ETCD_DATA_DIR="/opt/etcd/data"
    ETCD_LISTEN_PEER_URLS="http://192.168.159.4:2380"
    ETCD_LISTEN_CLIENT_URLS="https://192.168.159.4:2379,http://127.0.0.1:2379"
    
    #[Clustering]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.159.4:2380"
    ETCD_ADVERTISE_CLIENT_URLS="https://192.168.159.4:2379"
    ETCD_INITIAL_CLUSTER="etcd-1=http://192.168.159.3:2380,etcd-2=http://192.168.159.4:2380,etcd-3=http://192.168.159.5:2380"
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
    ETCD_INITIAL_CLUSTER_STATE="new" # 此处注意为new，意为创建新集群；existing意为加入已有集群
    #[Security]
    #开启集群外部服务端认证
    ETCD_CERT_FILE="/opt/etcd/pki/etcd.pem" #新增证书
    ETCD_KEY_FILE="/opt/etcd/pki/etcd-key.pem" #新增证书私钥
    #开启客户端验证
    ETCD_CLIENT_CERT_AUTH="true"
    ETCD_TRUSTED_CA_FILE="/opt/etcd/pki/ca.pem"
EOF
```
###### 修改node1服务配置
```bash
cat > /usr/lib/systemd/system/etcd.service << EOF
    [Unit]
    Description=Etcd Server
    After=network.target
    After=network-online.target
    Wants=network-online.target
    
    [Service]
    Type=notify
    EnvironmentFile=-/opt/etcd/etc/etcd.conf
    ExecStart=/home/k8s/etcd/etcd \
    --name=${ETCD_NAME} \
    --data-dir=${ETCD_DATA_DIR} \
    --listen-peer-urls=${ETCD_LISTEN_PEER_URLS} \
    --listen-client-urls=${ETCD_LISTEN_CLIENT_URLS} \
    --advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} \
    --initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
    --initial-cluster=${ETCD_INITIAL_CLUSTER} \
    --initial-cluster-token=${ETCD_INITIAL_CLUSTER_TOKEN} \
    --initial-cluster-state=${ETCD_INITIAL_CLUSTER_STATE} \
    --cert-file=${ETCD_CERT_FILE} \
    --key-file=${ETCD_KEY_FILE} \
    --client-cert-auth=${ETCD_CLIENT_CERT_AUTH} \ # 开启客户端验证
    --trusted-ca-file=${ETCD_TRUSTED_CA_FILE}     # 生成客户端证书的CA证书
    Restart=on-failure
    LimitNOFILE=65536
    
    [Install]
    WantedBy=multi-user.target
EOF
```
###### 重启node1并验证
```bash
    systemctl daemon-reload && systemctl restart etcd
    etcdctl cluster-health # 此时没加CA根证书，提示master节点不可达
    etcdctl -ca-file /opt/etcd/pki/ca.pem cluster-health # 加上CA根证书，master不可访问，因为没有配置客户端证书
    etcdctl --ca-file=/opt/etcd/pki/ca.pem --cert-file=etcdctl.pem --key-file=etcdctl-key.pem cluster-health # 加上CA根证书，集群正常,也可以使用对等证书及其私钥进行验证
```
```text
    member 8ada33a16cb8b5f9 is healthy: got healthy result from https://192.168.159.4:2379
    member df5c33b8666738a6 is healthy: got healthy result from https://192.168.159.3:2379
    member e689a191b9fab04f is healthy: got healthy result from https://192.168.159.5:2379
    cluster is healthy
```

###### 启动node2客户端验证
```bash
cat > /opt/etcd/etc/etcd.conf << EOF
    #[Member]
    ETCD_NAME="etcd-3"
    ETCD_DATA_DIR="/opt/etcd/data"
    ETCD_LISTEN_PEER_URLS="http://192.168.159.5:2380"
    ETCD_LISTEN_CLIENT_URLS="https://192.168.159.5:2379,http://127.0.0.1:2379"
    
    #[Clustering]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.159.5:2380"
    ETCD_ADVERTISE_CLIENT_URLS="https://192.168.159.5:2379"
    ETCD_INITIAL_CLUSTER="etcd-1=http://192.168.159.3:2380,etcd-2=http://192.168.159.4:2380,etcd-3=http://192.168.159.5:2380"
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
    ETCD_INITIAL_CLUSTER_STATE="new" # 此处注意为new，意为创建新集群；existing意为加入已有集群
    #[Security]
    #开启集群外部服务端认证
    ETCD_CERT_FILE="/opt/etcd/pki/etcd.pem" #新增证书
    ETCD_KEY_FILE="/opt/etcd/pki/etcd-key.pem" #新增证书私钥
    #开启客户端验证
    ETCD_CLIENT_CERT_AUTH="true"
    ETCD_TRUSTED_CA_FILE="/opt/etcd/pki/ca.pem"
EOF
```
###### 修改node2服务配置
```bash
cat > /usr/lib/systemd/system/etcd.service << EOF
    [Unit]
    Description=Etcd Server
    After=network.target
    After=network-online.target
    Wants=network-online.target
    
    [Service]
    Type=notify
    EnvironmentFile=-/opt/etcd/etc/etcd.conf
    ExecStart=/home/k8s/etcd/etcd \
    --name=${ETCD_NAME} \
    --data-dir=${ETCD_DATA_DIR} \
    --listen-peer-urls=${ETCD_LISTEN_PEER_URLS} \
    --listen-client-urls=${ETCD_LISTEN_CLIENT_URLS} \
    --advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} \
    --initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
    --initial-cluster=${ETCD_INITIAL_CLUSTER} \
    --initial-cluster-token=${ETCD_INITIAL_CLUSTER_TOKEN} \
    --initial-cluster-state=${ETCD_INITIAL_CLUSTER_STATE} \
    --cert-file=${ETCD_CERT_FILE} \
    --key-file=${ETCD_KEY_FILE} \
    --client-cert-auth=${ETCD_CLIENT_CERT_AUTH} \ # 开启客户端验证
    --trusted-ca-file=${ETCD_TRUSTED_CA_FILE}     # 生成客户端证书的CA证书
    Restart=on-failure
    LimitNOFILE=65536
    
    [Install]
    WantedBy=multi-user.target
EOF
```
###### 重启node2并验证
```bash
    systemctl daemon-reload && systemctl restart etcd
    etcdctl cluster-health # 此时没加CA根证书，提示master节点不可达
    etcdctl --ca-file /opt/etcd/pki/ca.pem cluster-health # 加上CA根证书，master不可访问，因为没有配置客户端证书
    etcdctl --ca-file=/opt/etcd/pki/ca.pem --cert-file=etcdctl.pem --key-file=etcdctl-key.pem cluster-health # 加上CA根证书，集群正常,也可以使用对等证书及其私钥进行验证
```
```text
    member 8ada33a16cb8b5f9 is healthy: got healthy result from https://192.168.159.4:2379
    member df5c33b8666738a6 is healthy: got healthy result from https://192.168.159.3:2379
    member e689a191b9fab04f is healthy: got healthy result from https://192.168.159.5:2379
    cluster is healthy
```


##### 集群内部开启pki安全认证
    开启集群节点服务器间的内部通信pki安全认证
###### 查看集群节点标识
```bash
    etcdctl -ca-file=/opt/etcd/pki/ca.pem -cert-file=etcdctl.pem -key-file=etcdctl-key.pem member list
```
可以看到此时peerURLs任然是http的方式
```text
    8ada33a16cb8b5f9: name=etcd-2 peerURLs=http://192.168.159.4:2380 clientURLs=https://192.168.159.4:2379 isLeader=false
    df5c33b8666738a6: name=etcd-1 peerURLs=http://192.168.159.3:2380 clientURLs=https://192.168.159.3:2379 isLeader=true
    e689a191b9fab04f: name=etcd-3 peerURLs=http://192.168.159.5:2380 clientURLs=https://192.168.159.5:2379 isLeader=false
```    

###### 更新节点peerURLs链接为https方式
`etcdctl member update <memberID> <peerURLs>`

```bash
    etcdctl -ca-file=/opt/etcd/pki/ca.pem -cert-file=etcdctl.pem -key-file=etcdctl-key.pem member update df5c33b8666738a6 https://192.168.159.3:2380
    etcdctl -ca-file=/opt/etcd/pki/ca.pem -cert-file=etcdctl.pem -key-file=etcdctl-key.pem member update 8ada33a16cb8b5f9 https://192.168.159.4:2380
    etcdctl -ca-file=/opt/etcd/pki/ca.pem -cert-file=etcdctl.pem -key-file=etcdctl-key.pem member update e689a191b9fab04f https://192.168.159.5:2380
```  
再次查看标识,peerURLs链接全部为https方式
```bash
    etcdctl -ca-file=/opt/etcd/pki/ca.pem -cert-file=etcdctl.pem -key-file=etcdctl-key.pem member list
```
```text
    8ada33a16cb8b5f9: name=etcd-2 peerURLs=https://192.168.159.4:2380 clientURLs=https://192.168.159.4:2379 isLeader=false
    df5c33b8666738a6: name=etcd-1 peerURLs=http://192.168.159.3:2380 clientURLs=https://192.168.159.3:2379 isLeader=true
    e689a191b9fab04f: name=etcd-3 peerURLs=http://192.168.159.5:2380 clientURLs=https://192.168.159.5:2379 isLeader=false
```
```bash
    [root@master pki]# etcdctl -ca-file=/opt/etcd/pki/ca.pem -cert-file=etcdctl.pem -key-file=etcdctl-key.pem cluster-health
    member 8ada33a16cb8b5f9 is healthy: got healthy result from https://192.168.159.4:2379
    member df5c33b8666738a6 is healthy: got healthy result from https://192.168.159.3:2379
    member e689a191b9fab04f is healthy: got healthy result from https://192.168.159.5:2379
    cluster is healthy
```

###### 修改PEER_URLS链接为https
    注意：通过上述操作https通信并没有建立，因为PEER_URLS的侦听地址和相关证书还没有配置；
    如果单个节点的PEER_URLS开启https，则其余节点都需要配置证书和集群客户端侦听地址ETCD_INITIAL_CLUSTER，才能正确通信

```text
[root@master pki]# systemctl status etcd -l
● etcd.service - Etcd Server
   Loaded: loaded (/usr/lib/systemd/system/etcd.service; disabled; vendor preset: disabled)
   Active: active (running) since 四 2019-08-08 14:11:42 CST; 8min ago
 Main PID: 2720 (etcd)
   CGroup: /system.slice/etcd.service
           └─2720 /home/k8s/etcd/etcd --name=etcd-1 --data-dir=/opt/etcd/data --listen-peer-urls=https://192.168.159.3:2380 --listen-client-urls=https://192.168.159.3:2379,http://127.0.0.1:2379 --advertise-client-urls=https://192.168.159.3:2379 --initial-advertise-peer-urls=https://192.168.159.3:2380 --initial-cluster=etcd-1=https://192.168.159.3:2380,etcd-2=https://192.168.159.4:2380,etcd-3=https://192.168.159.5:2380 --initial-cluster-token=etcd-cluster --initial-cluster-state=new --cert-file=/opt/etcd/pki/etcd.pem --key-file=/opt/etcd/pki/etcd-key.pem --client-cert-auth=true --trusted-ca-file=/opt/etcd/pki/ca.pem

8月 08 14:11:42 master etcd[2720]: ready to serve client requests
8月 08 14:11:42 master etcd[2720]: serving insecure client requests on 127.0.0.1:2379, this is strongly discouraged!
8月 08 14:11:42 master systemd[1]: Started Etcd Server.
8月 08 14:11:42 master etcd[2720]: rejected connection from "192.168.159.3:46646" (error "tls: failed to verify client's certificate: x509: certificate specifies an incompatible key usage", ServerName "")
8月 08 14:11:42 master etcd[2720]: WARNING: 2019/08/08 14:11:42 Failed to dial 192.168.159.3:2379: connection error: desc = "transport: authentication handshake failed: remote error: tls: bad certificate"; please retry.
8月 08 14:11:42 master etcd[2720]: peer e689a191b9fab04f became active
8月 08 14:11:42 master etcd[2720]: established a TCP streaming connection with peer e689a191b9fab04f (stream MsgApp v2 writer)
8月 08 14:11:42 master etcd[2720]: established a TCP streaming connection with peer e689a191b9fab04f (stream MsgApp v2 reader)
8月 08 14:11:42 master etcd[2720]: established a TCP streaming connection with peer e689a191b9fab04f (stream Message reader)
8月 08 14:11:42 master etcd[2720]: established a TCP streaming connection with peer e689a191b9fab04f (stream Message writer)
```   

- 修改master节点配置
```bash
cat > /opt/etcd/etc/etcd.conf << EOF
    #[Member]
    ETCD_NAME="etcd-1"
    ETCD_DATA_DIR="/opt/etcd/data"
    ETCD_LISTEN_PEER_URLS="https://192.168.159.3:2380" # 修改PEER_URLS的侦听地址
    ETCD_LISTEN_CLIENT_URLS="https://192.168.159.3:2379,http://127.0.0.1:2379"
    
    #[Clustering]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.159.3:2380" # 修改PEER_URLS的侦听地址
    ETCD_ADVERTISE_CLIENT_URLS="https://192.168.159.3:2379"
    ETCD_INITIAL_CLUSTER="etcd-1=https://192.168.159.3:2380,etcd-2=https://192.168.159.4:2380,etcd-3=https://192.168.159.5:2380" # 修改PEER_URLS的侦听地址
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
    ETCD_INITIAL_CLUSTER_STATE="new" # 此处注意为new，意为创建新集群；existing意为加入已有集群
    #[Security]
    #开启集群外部服务端认证
    ETCD_CERT_FILE="/opt/etcd/pki/etcd.pem" #新增证书
    ETCD_KEY_FILE="/opt/etcd/pki/etcd-key.pem" #新增证书私钥
    #开启客户端验证
    ETCD_CLIENT_CERT_AUTH="true"
    ETCD_TRUSTED_CA_FILE="/opt/etcd/pki/ca.pem"
    #开启集群内部服务端认证并配置客户端证书
    ETCD_PEER_CERT_FILE="/opt/etcd/pki/peer.pem"    
    ETCD_PEER_KEY_FILE="/opt/etcd/pki/peer-key.pem"   
    ETCD_PEER_CLIENT_CERT_AUTH="true" # 开启内部对等证书验证
    ETCD_PEER_TRUSTED_CA_FILE="/opt/etcd/pki/ca.pem" 
EOF
```  
- 修改node1节点配置
```bash
cat > /opt/etcd/etc/etcd.conf << EOF
    #[Member]
    ETCD_NAME="etcd-2"
    ETCD_DATA_DIR="/opt/etcd/data"
    ETCD_LISTEN_PEER_URLS="https://192.168.159.4:2380" # 修改PEER_URLS的侦听地址
    ETCD_LISTEN_CLIENT_URLS="https://192.168.159.4:2379,http://127.0.0.1:2379"
    
    #[Clustering]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.159.4:2380" # 修改PEER_URLS的侦听地址
    ETCD_ADVERTISE_CLIENT_URLS="https://192.168.159.4:2379"
    ETCD_INITIAL_CLUSTER="etcd-1=https://192.168.159.3:2380,etcd-2=https://192.168.159.4:2380,etcd-3=https://192.168.159.5:2380" # 修改PEER_URLS的侦听地址
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
    ETCD_INITIAL_CLUSTER_STATE="new" # 此处注意为new，意为创建新集群；existing意为加入已有集群
    #[Security]
    #开启集群外部服务端认证
    ETCD_CERT_FILE="/opt/etcd/pki/etcd.pem" #新增证书
    ETCD_KEY_FILE="/opt/etcd/pki/etcd-key.pem" #新增证书私钥
    #开启客户端验证
    ETCD_CLIENT_CERT_AUTH="true"
    ETCD_TRUSTED_CA_FILE="/opt/etcd/pki/ca.pem"
    #开启集群内部服务端认证并配置客户端证书
    ETCD_PEER_CERT_FILE="/opt/etcd/pki/peer.pem"    
    ETCD_PEER_KEY_FILE="/opt/etcd/pki/peer-key.pem"   
    ETCD_PEER_CLIENT_CERT_AUTH="true"
    ETCD_PEER_TRUSTED_CA_FILE="/opt/etcd/pki/ca.pem" 
EOF
``` 
- 修改node2节点配置
```bash
cat > /opt/etcd/etc/etcd.conf << EOF
    #[Member]
    ETCD_NAME="etcd-1"
    ETCD_DATA_DIR="/opt/etcd/data"
    ETCD_LISTEN_PEER_URLS="https://192.168.159.5:2380" # 修改PEER_URLS的侦听地址
    ETCD_LISTEN_CLIENT_URLS="https://192.168.159.5:2379,http://127.0.0.1:2379"
    
    #[Clustering]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.159.5:2380" # 修改PEER_URLS的侦听地址
    ETCD_ADVERTISE_CLIENT_URLS="https://192.168.159.5:2379"
    ETCD_INITIAL_CLUSTER="etcd-1=https://192.168.159.3:2380,etcd-2=https://192.168.159.4:2380,etcd-3=https://192.168.159.5:2380" # 修改PEER_URLS的侦听地址
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
    ETCD_INITIAL_CLUSTER_STATE="new" # 此处注意为new，意为创建新集群；existing意为加入已有集群
    #[Security]
    #开启集群内部服务端认证并配置客户端证书
    ETCD_CERT_FILE="/opt/etcd/pki/etcd.pem" #新增证书
    ETCD_KEY_FILE="/opt/etcd/pki/etcd-key.pem" #新增证书私钥
    #开启客户端验证
    ETCD_CLIENT_CERT_AUTH="true"
    ETCD_TRUSTED_CA_FILE="/opt/etcd/pki/ca.pem"
    #开启集群内部pki认证
    ETCD_PEER_CERT_FILE="/opt/etcd/pki/peer.pem"    
    ETCD_PEER_KEY_FILE="/opt/etcd/pki/peer-key.pem"   
    ETCD_PEER_CLIENT_CERT_AUTH="true"
    ETCD_PEER_TRUSTED_CA_FILE="/opt/etcd/pki/ca.pem" 
EOF
``` 

###### 修改服务配置
```bash
cat > /usr/lib/systemd/system/etcd.service << EOF
    [Unit]
    Description=Etcd Server
    After=network.target
    After=network-online.target
    Wants=network-online.target
    
    [Service]
    Type=notify
    EnvironmentFile=-/opt/etcd/etc/etcd.conf
    ExecStart=/home/k8s/etcd/etcd \
    --name=${ETCD_NAME} \
    --data-dir=${ETCD_DATA_DIR} \
    --listen-peer-urls=${ETCD_LISTEN_PEER_URLS} \
    --listen-client-urls=${ETCD_LISTEN_CLIENT_URLS} \
    --advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} \
    --initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
    --initial-cluster=${ETCD_INITIAL_CLUSTER} \
    --initial-cluster-token=${ETCD_INITIAL_CLUSTER_TOKEN} \
    --initial-cluster-state=${ETCD_INITIAL_CLUSTER_STATE} \
    --cert-file=${ETCD_CERT_FILE} \
    --key-file=${ETCD_KEY_FILE} \
    --client-cert-auth=${ETCD_CLIENT_CERT_AUTH} \ # 开启客户端验证
    --trusted-ca-file=${ETCD_TRUSTED_CA_FILE} \     # 生成客户端证书的CA证书
    --peer-cert-file=${ETCD_PEER_CERT_FILE} \
    --peer-key-file=${ETCD_PEER_KEY_FILE} \
    --peer-client-cert-auth=${ETCD_PEER_CLIENT_CERT_AUTH} \
    --peer-trusted-ca-file=${ETCD_PEER_TRUSTED_CA_FILE}
    Restart=on-failure
    LimitNOFILE=65536
    
    [Install]
    WantedBy=multi-user.target
EOF
```

###### 重启并验证
```bash
systemctl daemon-reload && systemctl restart etcd
```

```text
[root@master pki]# systemctl status etcd.service -l
● etcd.service - Etcd Server
   Loaded: loaded (/usr/lib/systemd/system/etcd.service; disabled; vendor preset: disabled)
   Active: active (running) since 四 2019-08-08 14:28:19 CST; 20s ago
 Main PID: 2812 (etcd)
   CGroup: /system.slice/etcd.service
           └─2812 /home/k8s/etcd/etcd --name=etcd-1 --data-dir=/opt/etcd/data --listen-peer-urls=https://192.168.159.3:2380 --listen-client-urls=https://192.168.159.3:2379,http://127.0.0.1:2379 --advertise-client-urls=https://192.168.159.3:2379 --initial-advertise-peer-urls=https://192.168.159.3:2380 --initial-cluster=etcd-1=https://192.168.159.3:2380,etcd-2=https://192.168.159.4:2380,etcd-3=https://192.168.159.5:2380 --initial-cluster-token=etcd-cluster --initial-cluster-state=new --cert-file=/opt/etcd/pki/etcd.pem --key-file=/opt/etcd/pki/etcd-key.pem --client-cert-auth=true --trusted-ca-file=/opt/etcd/pki/ca.pem --peer-cert-file=/opt/etcd/pki/peer.pem --peer-key-file=/opt/etcd/pki/peer-key.pem --peer-client-cert-auth=true --peer-trusted-ca-file=/opt/etcd/pki/ca.pem

8月 08 14:28:21 master etcd[2812]: df5c33b8666738a6 is starting a new election at term 167
8月 08 14:28:21 master etcd[2812]: df5c33b8666738a6 became candidate at term 168
8月 08 14:28:21 master etcd[2812]: df5c33b8666738a6 received MsgVoteResp from df5c33b8666738a6 at term 168
8月 08 14:28:21 master etcd[2812]: df5c33b8666738a6 [logterm: 167, index: 104] sent MsgVote request to e689a191b9fab04f at term 168
8月 08 14:28:21 master etcd[2812]: df5c33b8666738a6 [logterm: 167, index: 104] sent MsgVote request to 8ada33a16cb8b5f9 at term 168
8月 08 14:28:21 master etcd[2812]: raft.node: df5c33b8666738a6 lost leader 8ada33a16cb8b5f9 at term 168
8月 08 14:28:22 master etcd[2812]: df5c33b8666738a6 [term: 168] received a MsgVote message with higher term from 8ada33a16cb8b5f9 [term: 170]
8月 08 14:28:22 master etcd[2812]: df5c33b8666738a6 became follower at term 170
8月 08 14:28:22 master etcd[2812]: df5c33b8666738a6 [logterm: 167, index: 104, vote: 0] cast MsgVote for 8ada33a16cb8b5f9 [logterm: 167, index: 104] at term 170
8月 08 14:28:22 master etcd[2812]: raft.node: df5c33b8666738a6 elected leader 8ada33a16cb8b5f9 at term 170
```

> 注意：为了避免报错，先执行更新节点peerURLs链接为https方式是必要的   

#### 向集群添加非安全新节点node3
###### 下载安装包并初始环境
```bash
  mkdir /home/k8s
  cd /home/k8s
  wget https://github.com/etcd-io/etcd/releases/download/v3.3.13/etcd-v3.3.13-linux-amd64.tar.gz
  tar -zxvf etcd-v3.3.13-linux-amd64.tar.gz
  mv etcd-v3.3.13-linux-amd64 etcd
  chmod -R +x etcd/
  cp -f ./{etcd,etcdctl} /usr/bin/
  cp -f ./{etcd,etcdctl} /usr/local/bin/
  mkdir -p /opt/etcd/{etc,data,pki}
```

###### 生成node3对等证书
    由于旧的证书的hosts列表不包含node3节点，因此需要重新生成node3节点的peer证书
```bash
cat > /home/k8s/cfssl/ssl/etcd4-peer-csr.json << EOF 
{
    "CN": "etcd4-peer",
    "hosts": [
        "192.168.159.6"
    ],
    "key": {
        "algo": "ecdsa",
        "size": 256
    },
    "names": [
        {
            "C": "CN",
            "L": "ChengDu",
            "O": "JSQ",
            "OU": "k8s",
            "ST": "SiChuan"
        }
    ]
}
EOF

cfssl gencert --ca=ca.pem --ca-key=ca-key.pem --config=ca-config.json --profile=peer etcd4-peer-csr.json  | cfssljson -bare etcd4-peer
scp etcd4-* root@192.168.159.6:/opt/etcd/pki/
```

###### ETCD配置文件
```bash
mkdir -p /opt/etcd/{data,etc}
cat > /opt/etcd/etc/etcd.conf << EOF
#[Member]
ETCD_NAME="etcd-4"
ETCD_DATA_DIR="/opt/etcd/data"
ETCD_LISTEN_PEER_URLS="http://192.168.159.6:2380"
ETCD_LISTEN_CLIENT_URLS="http://192.168.159.6:2379,http://127.0.0.1:2379"

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.159.6:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.159.6:2379"
ETCD_INITIAL_CLUSTER="etcd-1=https://192.168.159.3:2380,etcd-2=https://192.168.159.4:2380,etcd-3=https://192.168.159.5:2380,etcd-4=http://192.168.159.6:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="existing" # 此处注意为new，意为创建新集群；existing意为加入已有集群

#[Security]
#开启集群内部pki认证,由于已有集群为安全集群，以下配置必须要有
ETCD_PEER_CERT_FILE="/opt/etcd/pki/etcd4-peer.pem"    
ETCD_PEER_KEY_FILE="/opt/etcd/pki/etcd4-peer-key.pem"   
ETCD_PEER_CLIENT_CERT_AUTH="false"
ETCD_PEER_TRUSTED_CA_FILE="/opt/etcd/pki/ca.pem" 
EOF
```

###### ETCD服务启动文件
[systemd中文手册](<http://www.jinbuguo.com/systemd/systemd.exec.html>):
http://www.jinbuguo.com/systemd/systemd.exec.html

```bash
cat >  /usr/lib/systemd/system/etcd.service << EOF    
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=-/opt/etcd/etc/etcd.conf
ExecStart=/home/k8s/etcd/etcd \
--name=${ETCD_NAME} \
--data-dir=${ETCD_DATA_DIR} \
--listen-peer-urls=${ETCD_LISTEN_PEER_URLS} \
--listen-client-urls=${ETCD_LISTEN_CLIENT_URLS} \
--initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
--advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} \
--initial-cluster=${ETCD_INITIAL_CLUSTER} \
--initial-cluster-token=${ETCD_INITIAL_CLUSTER_TOKEN} \
--initial-cluster-state=${ETCD_INITIAL_CLUSTER_STATE} \
--peer-cert-file=${ETCD_PEER_CERT_FILE} \
--peer-key-file=${ETCD_PEER_KEY_FILE} \
--peer-client-cert-auth=${ETCD_PEER_CLIENT_CERT_AUTH} \
--peer-trusted-ca-file=${ETCD_PEER_TRUSTED_CA_FILE}
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

###### 向已有集群添加新节点
- 添加新节点
    ```bash
    # 任意集群节点执行，注意端口为2380
    etcdctl --ca-file=ca.pem  --cert-file=etcdctl.pem --key-file=etcdctl-key.pem member add etcd-4 http://192.168.159.6:2380
    ```


- 集群状态查看
    ```text
    [root@master pki]# etcdctl --ca-file=ca.pem  --cert-file=etcdctl.pem --key-file=etcdctl-key.pem member list
    46899d42c87d524e: name=etcd-2 peerURLs=https://192.168.159.4:2380 clientURLs=https://192.168.159.4:2379 isLeader=true
    6bdd9302771bc9c5: name=etcd-3 peerURLs=https://192.168.159.5:2380 clientURLs=https://192.168.159.5:2379 isLeader=false
    a3ec213779ea2c81: name=etcd-1 peerURLs=https://192.168.159.3:2380 clientURLs=https://192.168.159.3:2379 isLeader=false
    e1b7f9d6e4ff0f36[unstarted]: peerURLs=https://192.168.159.6:2380
    ```
    ```text
    [root@master pki]# etcdctl --ca-file=ca.pem  --cert-file=etcdctl.pem --key-file=etcdctl-key.pem cluster-health
    member 46899d42c87d524e is healthy: got healthy result from https://192.168.159.4:2379
    member 6bdd9302771bc9c5 is healthy: got healthy result from https://192.168.159.5:2379
    member a3ec213779ea2c81 is healthy: got healthy result from https://192.168.159.3:2379
    member e1b7f9d6e4ff0f36 is unreachable: no available published client urls
    cluster is healthy
    ```

###### 启动新节点
- 启动
    ```bash
     systemctl daemon-reload && systemctl start etcd
    ```


- 集群状态查看
    ```text
    [root@master pki]# etcdctl --ca-file=ca.pem  --cert-file=etcdctl.pem --key-file=etcdctl-key.pem member list
    46899d42c87d524e: name=etcd-2 peerURLs=https://192.168.159.4:2380 clientURLs=https://192.168.159.4:2379 isLeader=true
    6bdd9302771bc9c5: name=etcd-3 peerURLs=https://192.168.159.5:2380 clientURLs=https://192.168.159.5:2379 isLeader=false
    a3ec213779ea2c81: name=etcd-1 peerURLs=https://192.168.159.3:2380 clientURLs=https://192.168.159.3:2379 isLeader=false
    e1b7f9d6e4ff0f36: name=etcd-4 peerURLs=http://192.168.159.6:2380 clientURLs=http://192.168.159.6:2379 isLeader=false
    ```
    ```text
    [root@master pki]# etcdctl --ca-file=ca.pem  --cert-file=etcdctl.pem --key-file=etcdctl-key.pem cluster-health
    member 46899d42c87d524e is healthy: got healthy result from https://192.168.159.4:2379
    member 6bdd9302771bc9c5 is healthy: got healthy result from https://192.168.159.5:2379
    member a3ec213779ea2c81 is healthy: got healthy result from https://192.168.159.3:2379
    member e1b7f9d6e4ff0f36 is healthy: got healthy result from http://192.168.159.6:2379
    cluster is healthy
    ```

#### 移除集群节点node3
- 集群节点查看
```text
[root@master pki]# etcdctl --ca-file=ca.pem  --cert-file=etcdctl.pem --key-file=etcdctl-key.pem member list
46899d42c87d524e: name=etcd-2 peerURLs=https://192.168.159.4:2380 clientURLs=https://192.168.159.4:2379 isLeader=true
6bdd9302771bc9c5: name=etcd-3 peerURLs=https://192.168.159.5:2380 clientURLs=https://192.168.159.5:2379 isLeader=false
a3ec213779ea2c81: name=etcd-1 peerURLs=https://192.168.159.3:2380 clientURLs=https://192.168.159.3:2379 isLeader=false
e1b7f9d6e4ff0f36: name=etcd-4 peerURLs=http://192.168.159.6:2380 clientURLs=http://192.168.159.6:2379 isLeader=false
```

- 移除节点
```text
[root@master pki]# etcdctl --ca-file=ca.pem  --cert-file=etcdctl.pem --key-file=etcdctl-key.pem member remove e1b7f9d6e4ff0f36
Removed member e1b7f9d6e4ff0f36 from cluster
```

#### 向集群添加安全节点node3
##### 生成node3节点的服务端证书
    同上，由于旧服务端证书的hosts列表不包含node3节点，因此需要重新生成node3节点的server证书
```bash
cat > etcd4-csr.json << EOF 
{
    "CN": "etcd4",
    "hosts": [
        "192.168.159.6"
    ],
    "key": {
        "algo": "ecdsa",
        "size": 256
    },
    "names": [
        {
            "C": "CN",
            "L": "ChengDu",
            "O": "JSQ",
            "OU": "k8s",
            "ST": "SiChuan"
        }
    ]
}
EOF

cfssl gencert --ca=ca.pem --ca-key=ca-key.pem --config=ca-config.json --profile=server etcd4-csr.json  | cfssljson -bare etcd4
scp etcd4* root@192.168.159.6:/opt/etcd/pki/
```
```text
[root@localhost pki]# ls etcd4*
etcd4.csr  etcd4-csr.json  etcd4-key.pem  etcd4-peer.csr  etcd4-peer-csr.json  etcd4-peer-key.pem  etcd4-peer.pem  etcd4.pem
```

##### node3逐步升级为安全节点
    参照【升级为安全集群】章节

##### 添加安全节点node3
###### 集群添加node3节点    
```text
[root@master pki]# etcdctl --ca-file=ca.pem  --cert-file=etcdctl.pem --key-file=etcdctl-key.pem member add etcd-4 https://192.168.159.6:2380
Added member named etcd-4 with ID 1e7da56305348d0d to cluster

ETCD_NAME="etcd-4"
ETCD_INITIAL_CLUSTER="etcd-4=https://192.168.159.6:2380,etcd-2=https://192.168.159.4:2380,etcd-3=https://192.168.159.5:2380,etcd-1=https://192.168.159.3:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"

[root@master pki]# etcdctl --ca-file=ca.pem  --cert-file=etcdctl.pem --key-file=etcdctl-key.pem member list
1e7da56305348d0d[unstarted]: peerURLs=https://192.168.159.6:2380
46899d42c87d524e: name=etcd-2 peerURLs=https://192.168.159.4:2380 clientURLs=https://192.168.159.4:2379 isLeader=true
6bdd9302771bc9c5: name=etcd-3 peerURLs=https://192.168.159.5:2380 clientURLs=https://192.168.159.5:2379 isLeader=false
a3ec213779ea2c81: name=etcd-1 peerURLs=https://192.168.159.3:2380 clientURLs=https://192.168.159.3:2379 isLeader=false

[root@master pki]# etcdctl --ca-file=ca.pem  --cert-file=etcdctl.pem --key-file=etcdctl-key.pem cluster-health
member 1e7da56305348d0d is unreachable: no available published client urls
member 46899d42c87d524e is healthy: got healthy result from https://192.168.159.4:2379
member 6bdd9302771bc9c5 is healthy: got healthy result from https://192.168.159.5:2379
member a3ec213779ea2c81 is healthy: got healthy result from https://192.168.159.3:2379
cluster is degraded
```

###### 安全启动node3的配置方式
```bash
cat > /opt/etcd/etc/etcd.conf << EOF
#[Member]
ETCD_NAME="etcd-4"
ETCD_DATA_DIR="/opt/etcd/data"
ETCD_LISTEN_PEER_URLS="https://192.168.159.6:2380" # 修改PEER_URLS的侦听地址
ETCD_LISTEN_CLIENT_URLS="https://192.168.159.6:2379,http://127.0.0.1:2379" #注意端口不要忘记

#[Clustering]
ETCD_INITIAL_ADVERTISE_PEER_URLS="https://192.168.159.6:2380" # 修改PEER_URLS的侦听地址
ETCD_ADVERTISE_CLIENT_URLS="https://192.168.159.6:2379"
ETCD_INITIAL_CLUSTER="etcd-1=https://192.168.159.3:2380,etcd-2=https://192.168.159.4:2380,etcd-3=https://192.168.159.5:2380,etcd-4=https://192.168.159.6:2380" # 修改PEER_URLS的侦听地址
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="existing" # 此处必须为existing
#[Security]
#开启集群内部服务端认证并配置客户端证书
ETCD_CERT_FILE="/opt/etcd/pki/etcd4.pem" #新增证书
ETCD_KEY_FILE="/opt/etcd/pki/etcd4-key.pem" #新增证书私钥
#开启客户端验证
ETCD_CLIENT_CERT_AUTH="true"
ETCD_TRUSTED_CA_FILE="/opt/etcd/pki/ca.pem"
#开启集群内部pki认证
ETCD_PEER_CERT_FILE="/opt/etcd/pki/etcd4-peer.pem"    
ETCD_PEER_KEY_FILE="/opt/etcd/pki/etcd4-peer-key.pem"   
ETCD_PEER_CLIENT_CERT_AUTH="true"
ETCD_PEER_TRUSTED_CA_FILE="/opt/etcd/pki/ca.pem" 
EOF
``` 

###### 安全启动node3的服务文件
```bash
cat > /usr/lib/systemd/system/etcd.service << EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
EnvironmentFile=-/opt/etcd/etc/etcd.conf
ExecStart=/home/k8s/etcd/etcd \
--name=${ETCD_NAME} \
--data-dir=${ETCD_DATA_DIR} \
--listen-peer-urls=${ETCD_LISTEN_PEER_URLS} \
--listen-client-urls=${ETCD_LISTEN_CLIENT_URLS} \
--advertise-client-urls=${ETCD_ADVERTISE_CLIENT_URLS} \
--initial-advertise-peer-urls=${ETCD_INITIAL_ADVERTISE_PEER_URLS} \
--initial-cluster=${ETCD_INITIAL_CLUSTER} \
--initial-cluster-token=${ETCD_INITIAL_CLUSTER_TOKEN} \
--initial-cluster-state=${ETCD_INITIAL_CLUSTER_STATE} \
--cert-file=${ETCD_CERT_FILE} \
--key-file=${ETCD_KEY_FILE} \
--client-cert-auth=${ETCD_CLIENT_CERT_AUTH} \ # 开启客户端验证
--trusted-ca-file=${ETCD_TRUSTED_CA_FILE} \     # 生成客户端证书的CA证书
--peer-cert-file=${ETCD_PEER_CERT_FILE} \
--peer-key-file=${ETCD_PEER_KEY_FILE} \
--peer-client-cert-auth=${ETCD_PEER_CLIENT_CERT_AUTH} \
--peer-trusted-ca-file=${ETCD_PEER_TRUSTED_CA_FILE}
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

###### 启动新节点
```bash
systemctl daemon-reload && systemctl start etcd
```
```text
[root@master pki]# etcdctl --ca-file=ca.pem  --cert-file=etcdctl.pem --key-file=etcdctl-key.pem member list
1e7da56305348d0d: name=etcd-4 peerURLs=https://192.168.159.6:2380 clientURLs=https://192.168.159.6:2379 isLeader=false
46899d42c87d524e: name=etcd-2 peerURLs=https://192.168.159.4:2380 clientURLs=https://192.168.159.4:2379 isLeader=true
6bdd9302771bc9c5: name=etcd-3 peerURLs=https://192.168.159.5:2380 clientURLs=https://192.168.159.5:2379 isLeader=false
a3ec213779ea2c81: name=etcd-1 peerURLs=https://192.168.159.3:2380 clientURLs=https://192.168.159.3:2379 isLeader=false

[root@master pki]# etcdctl --ca-file=ca.pem  --cert-file=etcdctl.pem --key-file=etcdctl-key.pem cluster-health
member 1e7da56305348d0d is healthy: got healthy result from https://192.168.159.6:2379
member 46899d42c87d524e is healthy: got healthy result from https://192.168.159.4:2379
member 6bdd9302771bc9c5 is healthy: got healthy result from https://192.168.159.5:2379
member a3ec213779ea2c81 is healthy: got healthy result from https://192.168.159.3:2379
cluster is healthy
```

### K8S下载安装
[官方下载地址](<https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.15.md#downloads-for-v1152>)

[国内下载](<https://mirrors.ustc.edu.cn/kubernetes/apt/pool/>)
```bash
# 需要VPN加速，可搬瓦工VPS搭建VPN下载
wget https://dl.k8s.io/v1.15.2/kubernetes-server-linux-amd64.tar.gz
tar -zxvf kubernetes-server-linux-amd64.tar.gz
cd /home/k8s/kubernetes/server/bin
cp -f kube-apiserver kube-scheduler kube-controller-manager kubectl /usr/local/bin/
```

### kube-apiserver普通安装
[中文文档](<https://kubernetes.io/zh/docs/reference/command-line-tools-reference/kube-apiserver/>)
#### kube-apiserver配置文件
```bash
cat > /opt/k8s/master/etc/kube-apiserver.conf << EOF
KUBE_APISERVER_INSECURE_OPTS="--etcd-servers=https://192.168.159.3:2379,https://192.168.159.4:2379 \
--etcd-cafile=/opt/etcd/pki/ca.pem \
--etcd-certfile=/opt/etcd/pki/etcdctl.pem \
--etcd-keyfile=/opt/etcd/pki/etcdctl-key.pem \
--insecure-bind-address=0.0.0.0 \
--insecure-port=8080 \
--service-cluster-ip-range=10.0.0.0/24 \
--service-node-port-range=30000-50000 \
--enable-admission-plugins=NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota,NodeRestriction \
--logtostderr=false \
--log-dir=/opt/k8s/master/log/kube-apiserver" \
--v=2 
EOF
```
##### 参数说明
- etcd-servers: 指定ETCD服务的URL；
- etcd-cafile: 由于之前搭建的ETCD服务是TLS认证模式，需要提供CA证书；
- etcd-certfile: 由于之前搭建的ETCD服务是TLS认证模式，需要提供etcdctl客户端证书；
- etcd-keyfile: 由于之前搭建的ETCD服务是TLS认证模式，需要提供etcdctl客户端证书的私钥；
- insecure-bind-address：kube-apiserver绑定的非安全地址，0.0.0.0表示绑定所有，kubectl默认通过localhost:8080访问kube-apiserver；
- insecure-port: kube-apiserver绑定的非安全端口，默认8080；
- service-cluster-ip-range：分配给`Service`的`Cluster IP`的范围，避免与分配给`Node`和`Pod`的IP地址重叠；
- service-node-port-range：`Service`可映射到物理机的端口`NodePort`的范围；
- enable-admission-plugins: 集群准入控件，依次生效；
- logtostderr: 关闭日志标准输出，日志输入到文件；
- log-dir: 日志目录；
- v 日志等级,1-4

#### kube-apiserver服务文件
```bash
cat > /usr/lib/systemd/system/kube-apiserver.service << EOF
[Unit]
Description=k8s apiserver
Documentation=https://github.com/kubernetes/kubernetes
After=etcd.service
Wants=etcd.service

[Service]
Type=notify
EnvironmentFile=-/opt/k8s/master/etc/kube-apiserver.conf
ExecStart=/usr/local/bin/kube-apiserver $KUBE_APISERVER_INSECURE_OPTS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

#### kube-apiserver服务启动
##### 启动
```bash
systemctl daemon-reload && systemctl start kube-apiserver
```
##### 验证
- 验证方式一
    ```text
    [root@master etc]# ps -aux | grep kube-apiserver
    root       5042  1.6 12.8 402208 239956 ?       Ssl  14:38   0:16 /usr/local/bin/kube-apiserver --etcd-servers=https://192.168.159.3:2379,https://192.168.159.4:2379 --etcd-cafile=/opt/etcd/pki/ca.pem --etcd-certfile=/opt/etcd/pki/etcdctl.pem --etcd-keyfile=/opt/etcd/pki/etcdctl-key.pem --insecure-bind-address=0.0.0.0 --insecure-port=8080 --service-cluster-ip-range=10.0.0.0/24 --service-node-port-range=30000-50000 --enable-admission-plugins=NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota,NodeRestriction --logtostderr=false --v=2 --log-dir=/opt/k8s/master/log/kube-apiserver
    root       5074  0.0  0.0 112724  1000 pts/0    S+   14:54   0:00 grep --color=auto kube-apiserve
    ```


- 验证方式二
    ```text
    [root@master etc]# curl localhost:8080
    {
      "paths": [
        "/api",
        "/api/v1",
        "/apis",
        "/apis/",
        "/apis/admissionregistration.k8s.io",
        "/apis/admissionregistration.k8s.io/v1beta1",
        "/apis/apiextensions.k8s.io",
        "/apis/apiextensions.k8s.io/v1beta1",
        "/apis/apiregistration.k8s.io",
        "/apis/apiregistration.k8s.io/v1",
        "/apis/apiregistration.k8s.io/v1beta1",
        "/apis/apps",
        "/apis/apps/v1",
        "/apis/apps/v1beta1",
        "/apis/apps/v1beta2",
        "/apis/authentication.k8s.io",
        "/apis/authentication.k8s.io/v1",
        "/apis/authentication.k8s.io/v1beta1",
        "/apis/authorization.k8s.io",
        "/apis/authorization.k8s.io/v1",
        "/apis/authorization.k8s.io/v1beta1",
        "/apis/autoscaling",
        "/apis/autoscaling/v1",
        "/apis/autoscaling/v2beta1",
        "/apis/autoscaling/v2beta2",
        "/apis/batch",
        "/apis/batch/v1",
        "/apis/batch/v1beta1",
        "/apis/certificates.k8s.io",
        "/apis/certificates.k8s.io/v1beta1",
        "/apis/coordination.k8s.io",
        "/apis/coordination.k8s.io/v1",
        "/apis/coordination.k8s.io/v1beta1",
        "/apis/events.k8s.io",
        "/apis/events.k8s.io/v1beta1",
        "/apis/extensions",
        "/apis/extensions/v1beta1",
        "/apis/networking.k8s.io",
        "/apis/networking.k8s.io/v1",
        "/apis/networking.k8s.io/v1beta1",
        "/apis/node.k8s.io",
        "/apis/node.k8s.io/v1beta1",
        "/apis/policy",
        "/apis/policy/v1beta1",
        "/apis/rbac.authorization.k8s.io",
        "/apis/rbac.authorization.k8s.io/v1",
        "/apis/rbac.authorization.k8s.io/v1beta1",
        "/apis/scheduling.k8s.io",
        "/apis/scheduling.k8s.io/v1",
        "/apis/scheduling.k8s.io/v1beta1",
        "/apis/storage.k8s.io",
        "/apis/storage.k8s.io/v1",
        "/apis/storage.k8s.io/v1beta1",
        "/healthz",
        "/healthz/autoregister-completion",
        "/healthz/etcd",
        "/healthz/log",
        "/healthz/ping",
        "/healthz/poststarthook/apiservice-openapi-controller",
        "/healthz/poststarthook/apiservice-registration-controller",
        "/healthz/poststarthook/apiservice-status-available-controller",
        "/healthz/poststarthook/bootstrap-controller",
        "/healthz/poststarthook/ca-registration",
        "/healthz/poststarthook/crd-informer-synced",
        "/healthz/poststarthook/generic-apiserver-start-informers",
        "/healthz/poststarthook/kube-apiserver-autoregistration",
        "/healthz/poststarthook/scheduling/bootstrap-system-priority-classes",
        "/healthz/poststarthook/start-apiextensions-controllers",
        "/healthz/poststarthook/start-apiextensions-informers",
        "/healthz/poststarthook/start-kube-aggregator-informers",
        "/healthz/poststarthook/start-kube-apiserver-admission-initializer",
        "/logs",
        "/metrics",
        "/openapi/v2",
        "/version"
      ]
    }
    ```


- 验证方式三
    ```text
    [root@master etc]# systemctl status kube-apiserver
    ● kube-apiserver.service - k8s apiserver
       Loaded: loaded (/usr/lib/systemd/system/kube-apiserver.service; disabled; vendor preset: disabled)
       Active: active (running) since 三 2019-08-21 14:38:16 CST; 17min ago
         Docs: https://github.com/kubernetes/kubernetes
     Main PID: 5042 (kube-apiserver)
       CGroup: /system.slice/kube-apiserver.service
               └─5042 /usr/local/bin/kube-apiserver --etcd-servers=https://192.168.159.3:2379,https://192.168.159.4:2379 --etcd-cafile=/opt/etcd/pki/ca.pem --etcd-certfile=/opt/etcd/pki/etcdctl.pem --etcd-k...
    ```


- 验证方式四
    ```text
    [root@master etc]# kubectl get cs
    NAME                 STATUS      MESSAGE                                                                                     ERROR
    scheduler            Unhealthy   Get http://127.0.0.1:10251/healthz: dial tcp 127.0.0.1:10251: connect: connection refused   
    controller-manager   Unhealthy   Get http://127.0.0.1:10252/healthz: dial tcp 127.0.0.1:10252: connect: connection refused   
    etcd-0               Healthy     {"health":"true"}                                                                           
    etcd-1               Healthy     {"health":"true"}
    ```
    ```text
    [root@master etc]# kubectl get svc
    NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
    kubernetes   ClusterIP   10.0.0.1     <none>        443/TCP   25h
    ```


### kube-controller-manager普通安装
[官方文档](<https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/>)

#### kube-controller-manager配置文件
```bash
cat > /opt/k8s/master/etc/kube-controller-manager.conf << EOF
KUBE_CONTROLLER_MANAGER_INSECURE_OPTS="--master=192.168.159.3:8080 \
--leader-elect=true \
--address=0.0.0.0 \
--port=10252 \
--service-cluster-ip-range=10.0.0.0/24 \
--logtostderr=false \
--log-dir=/opt/k8s/master/log/kube-controller-manager \
--v=2"
EOF
```
##### 参数说明
- master: 指定`kube-apiserver`服务的URL；
- leader-elect: 集群模式开启自动选举；
- address：kube-controller-manager绑定的非安全地址，0.0.0.0表示绑定所有；
- port: kube-controller-manager绑定的非安全端口，默认10252；
- service-cluster-ip-range：分配给`Service`的`Cluster IP`的范围，避免与分配给`Node`和`Pod`的IP地址重叠；
- logtostderr: 关闭日志标准输出，日志输入到文件；
- log-dir: 日志目录；
- v 日志等级,1-4

#### kube-controller-manager服务文件
```bash
cat /usr/lib/systemd/system/kube-controller-manager.service << EOF
[Unit]
Description=k8s controller manager
Documentation=https://github.com/kubernetes/kubernetes
After=kube-apisever.service
Requires=kube-apiserver.service

[Service]
EnvironmentFile=-/opt/k8s/master/etc/kube-controller-manager.conf
ExecStart=/usr/local/bin/kube-controller-manager $KUBE_CONTROLLER_MANAGER_INSECURE_OPTS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

#### kube-controller-manager服务启动
##### 启动
```bash
systemctl daemon-reload && systemctl start kube-controller-manager
```
##### 验证
- 验证方式一
    ```text
    [root@master etc]# systemctl status kube-controller-manager
    ● kube-controller-manager.service - k8s controller manager
       Loaded: loaded (/usr/lib/systemd/system/kube-controller-manager.service; disabled; vendor preset: disabled)
       Active: active (running) since 三 2019-08-21 15:35:17 CST; 3min 50s ago
         Docs: https://github.com/kubernetes/kubernetes
     Main PID: 5325 (kube-controller)
       CGroup: /system.slice/kube-controller-manager.service
               └─5325 /usr/local/bin/kube-controller-manager --master=192.168.159.3:8080 --leader-elect=true --address=0.0.0.0 --port=10252 --service-cluster-ip-range=10.0.0.0/24 --logtostderr=false --log-d...
    ```


- 验证方式二
    ```text
    [root@master etc]# kubectl get cs
    NAME                 STATUS      MESSAGE                                                                                     ERROR
    scheduler            Unhealthy   Get http://127.0.0.1:10251/healthz: dial tcp 127.0.0.1:10251: connect: connection refused   
    controller-manager   Healthy     ok                                                                                          
    etcd-0               Healthy     {"health":"true"}                                                                           
    etcd-1               Healthy     {"health":"true"} 
    ```


### kube-scheduler普通安装
[官方文档](<https://kubernetes.io/zh/docs/reference/command-line-tools-reference/kube-scheduler/>)
#### kube-scheduler配置文件
```bash
cat > /opt/k8s/master/etc/kube-scheduler.conf << EOF
KUBE_SCHEDULER_INSECURE_OPTS="--master=192.168.159.3:8080 \
--address=0.0.0.0 \
--port=10251 \
--leader-elect=true \
--logtostderr=false
--log-dir=/opt/k8s/master/log/kube-scheduler \
--v=2"
EOF
```

#### kube-scheduler服务文件
```bash
cat > /usr/lib/systemd/system/kube-scheduler.service << EOF 
[Unit]
Description=k8s scheduler
Documentation=https://github.com/kubernetes/kubernetes
After=kube-apisever.service
Requires=kube-apiserver.service

[Service]
EnvironmentFile=-/opt/k8s/master/etc/kube-scheduler.conf
ExecStart=/usr/local/bin/kube-scheduler $KUBE_SCHEDULER_INSECURE_OPTS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```

#### kube-scheduler服务启动
##### 启动
```bash
systemctl daemon-reload && systemctl start kube-scheduler
```
##### 验证
- 验证方式一
    ```text
    [root@master etc]# systemctl status kube-scheduler
    ● kube-scheduler.service - k8s scheduler
       Loaded: loaded (/usr/lib/systemd/system/kube-scheduler.service; disabled; vendor preset: disabled)
       Active: active (running) since 三 2019-08-21 16:05:11 CST; 2min 40s ago
         Docs: https://github.com/kubernetes/kubernetes
     Main PID: 5710 (kube-scheduler)
       CGroup: /system.slice/kube-scheduler.service
               └─5710 /usr/local/bin/kube-scheduler --master=192.168.159.3:8080 --leader-elect=true --logtostderr=false --log-dir=/opt/k8s/master/log/kube-scheduler --v=2
    
    8月 21 16:05:11 master systemd[1]: Started k8s scheduler.
    ```

- 验证方式二
    ```text
    [root@master etc]# kubectl get cs
    NAME                 STATUS    MESSAGE             ERROR
    scheduler            Healthy   ok                  
    controller-manager   Healthy   ok                  
    etcd-0               Healthy   {"health":"true"}   
    etcd-1               Healthy   {"health":"true"} 
    ```



### kube-apiserver安装
#### 创建TLS证书
##### 生成Master的CA认证中心
+ CA证书生成策略文件
    ```bash
      cfssl print-defaults config > ca-config.json # 生成证书策略模板文件
      cat > ca-config.json << EOF
        {
            "signing": {
                "default": {
                    "expiry": "8760h"
                },
                "profiles": {
                    "server": {
                        "expiry": "8760h",
                        "usages": [
                            "signing",
                            "key encipherment",
                            "server auth"
                        ]
                    },
                    "client": {
                        "expiry": "8760h",
                        "usages": [
                            "signing",
                            "key encipherment",
                            "client auth"
                        ]
                    },
                   "peer": {
                        "expiry": "8760h",
                        "usages": [
                            "signing",
                            "key encipherment",
                            "server auth",
                            "client auth"
                        ]
                    }
                }
            }
        }
  EOF
  ```
  
- CA证书申请文件
  ```bash
    cfssl print-defaults csr > ca-csr.json # 生成签名申请模板文件
    cat > ca-csr.json << EOF
    {
        "CN": "k8s",
        "key": {
            "algo": "ecdsa",
            "size": 256
        },
        "names": [
            {
                "C": "CN",
                "L": "ChengDu",
                "ST": "SiChuan"
            }
        ]
    }
  EOF
  ```  

+ 生成CA证书和私钥  
    ```bash
      cfssl gencert --initca ca-csr.json | cfssljson -bare ca
      ls
      >> ca-config.json  ca.csr  ca-csr.json  ca-key.pem  ca.pem
      cp -f ca.csr ca*.pem /opt/k8s/master/pki
    ``` 

##### 生成kube-apiserver的对等证书
- 证书申请文件
    > [root@master ssl]# cat kube-apiserver-csr.json 
    ```json
    {
        "CN": "kube-apiserver",
        "hosts": [
            "192.168.159.3",
            "10.0.0.1",
            "127.0.0.1",
            "localhost",
            "localhost.localdomain",
            "kubernetes",
            "kubernetes.default",
            "kubernetes.default.svc",
            "kubernetes.default.svc.cluster",
            "kubernetes.default.svc.cluster.local"
        ],
        "key": {
            "algo": "ecdsa",
            "size": 256
        },
        "names": [
            {
                "C": "CN",
                "L": "ChengDu",
                "O": "JSQ",
                "OU": "k8s",
                "ST": "SiChuan"
            }
        ]
    }
    ```


+ 生成证书和私钥
    ```bash
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer kube-apiserver-csr.json | cfssljson -bare kube-apiserver
    ls kube-apiserver*
    >> kube-apiserver.csr  kube-apiserver-key.pem  kube-apiserver.pem
    ```

##### 生成kube-proxy的对等证书
- 证书申请文件
    > cat kube-proxy-csr.json 
    ```json
    {
        "CN": "kube-proxy",
        "key": {
            "algo": "ecdsa",
            "size": 256
        },
        "names": [
            {
                "C": "CN",
                "L": "ChengDu",
                "O": "JSQ",
                "OU": "k8s",
                "ST": "SiChuan"
            }
        ]
    }
    ``` 

+ 生成证书和私钥
    ```bash
    cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer kube-proxy-csr.json | cfssljson -bare kube-proxy
    ls kube-proxy*
    >> kube-proxy.csr  kube-proxy-key.pem  kube-proxy.pem
    ```  
         

#### kube-apiserver配置文件
> cat apiserver.conf 
```yaml
#[Generic]
KUBE_APISERVER_ADVERTISE_ADDRESS="192.168.159.3"

#[Etcd]
KUBE_APISERVER_ETCD_SERVERS="https://192.168.159.3:2379,https://192.168.159.4:2379"
KUBE_APISERVER_ETCD_CA="/opt/etcd/pki/ca.pem"
KUBE_APISERVER_ETCD_CERT="/opt/etcd/pki/etcdctl.pem"
KUBE_APISERVER_ETCD_KEY="/opt/etcd/pki/etcdctl-key.pem"

#[Secure]
KUBE_APISERVER_BIND_ADDRESS="192.168.159.3"
KUBE_APISERVER_SECURE_PORT=6443
KUBE_APISERVER_CERT_DIR="/opt/k8s/master/pki/"
KUBE_APISERVER_TLS_CERT="/opt/k8s/master/pki/kube-apiserver.pem"
KUBE_APISERVER_TLS_PRIVATE_KEY="/opt/k8s/master/pki/kube-apiserver-key.pem"

#[Authentication]
KUBE_APISERVER_ANONYMOUS_AUTH=true
KUBE_APISERVER_CLIENT_CA="/opt/k8s/master/pki/ca.pem"
KUBE_APISERVER_SERVICE_ACCOUNT_KEY="/opt/k8s/master/pki/ca-key.pem"
KUBE_APISERVER_ENABLE_BOOTSTRAP_TOKEN_AUTH="--enable-bootstrap-token-auth"
KUBE_APISERVER_TOKEN_AUTH_FILE="/opt/k8s/master/etc/token.csv"

#[Authorization]
KUBE_APISERVER_AUTHORIZATION_MODE="RBAC,Node"

#[Admission]
KUBE_APISERVER_ENABLE_ADMISSION_PLUGINS="NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota,NodeRestriction"

#[Misc]
KUBE_APISERVER_ALLOW_PRIVILEGED=true
KUBE_APISERVER_APISERVER_COUNT=1
KUBE_APISERVER_SERVICE_CLUSTER_IP_RANGE="10.0.0.0/24"
KUBE_APISERVER_SERVICE_NODE_PORT_RANGE="30000-50000"

#[Global]
KUBE_APISERVER_LOGTOSTDERR=true
KUBE_APISERVER_LOG_LEVEL=4
```
#### kube-apiserver服务文件
```bash
cat > /usr/lib/systemd/system/kube-apiserver.service << EOF 
[Unit]
Description=k8s apiserver
Documentation=https://github.com/kubernetes/kubernetes
After=etcd.service
Wants=etcd.service

[Service]
Type=notify
EnvironmentFile=-/opt/k8s/master/etc/apiserver.conf
ExecStart=/usr/local/bin/kube-apiserver \
--advertise-address=${KUBE_APISERVER_ADVERTISE_ADDRESS} \
--bind-address=${KUBE_APISERVER_BIND_ADDRESS} \
--secure-port=${KUBE_APISERVER_SECURE_PORT} \
--service-cluster-ip-range=${KUBE_APISERVER_SERVICE_CLUSTER_IP_RANGE} \
--service-node-port-range=${KUBE_APISERVER_SERVICE_NODE_PORT_RANGE} \
--etcd-servers=${KUBE_APISERVER_ETCD_SERVERS} \
--etcd-cafile=${KUBE_APISERVER_ETCD_CA} \
--etcd-certfile=${KUBE_APISERVER_ETCD_CERT} \
--etcd-keyfile=${KUBE_APISERVER_ETCD_KEY} \
--allow-privileged=${KUBE_APISERVER_ALLOW_PRIVILEGED} \
--enable-admission-plugins=${KUBE_APISERVER_ENABLE_ADMISSION_PLUGINS} \
--authorization-mode=${KUBE_APISERVER_AUTHORIZATION_MODE}
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
```
#### kube-apiserver服务启动
```bash
systemctl daemon-reload && systemctl start kube-apiserver
```
```text
[root@master etc]# ps -aux | grep kube-apiserver
root       2014  1.6 13.4 470180 250744 ?       Ssl  13:47   0:34 /usr/local/bin/kube-apiserver --advertise-address=192.168.159.3 --bind-address=192.168.159.3 --secure-port=6443 --service-cluster-ip-range=10.0.0.0/24 --service-node-port-range=30000-50000 --etcd-servers=https://192.168.159.3:2379,https://192.168.159.4:2379 --etcd-cafile=/opt/etcd/pki/ca.pem --etcd-certfile=/opt/etcd/pki/etcdctl.pem --etcd-keyfile=/opt/etcd/pki/etcdctl-key.pem --allow-privileged=true --enable-admission-plugins=NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota,NodeRestriction --authorization-mode=RBAC,Node
root       2068  0.0  0.0 112724   996 pts/0    R+   14:22   0:00 grep --color=auto kube-apiserver
```
```text
# kube-apiserver本地http端口8080，可以用--insecure-port指定别的端口
[root@master etc]#curl 127.0.0.1:8080
{
  "paths": [
    "/api",
    "/api/v1",
    "/apis",
    "/apis/",
    "/apis/admissionregistration.k8s.io",
    "/apis/admissionregistration.k8s.io/v1beta1",
    "/apis/apiextensions.k8s.io",
    "/apis/apiextensions.k8s.io/v1beta1",
    "/apis/apiregistration.k8s.io",
    "/apis/apiregistration.k8s.io/v1",
    "/apis/apiregistration.k8s.io/v1beta1",
    "/apis/apps",
    "/apis/apps/v1",
    "/apis/apps/v1beta1",
    "/apis/apps/v1beta2",
    "/apis/authentication.k8s.io",
    "/apis/authentication.k8s.io/v1",
    "/apis/authentication.k8s.io/v1beta1",
    "/apis/authorization.k8s.io",
    "/apis/authorization.k8s.io/v1",
    "/apis/authorization.k8s.io/v1beta1",
    "/apis/autoscaling",
    "/apis/autoscaling/v1",
    "/apis/autoscaling/v2beta1",
    "/apis/autoscaling/v2beta2",
    "/apis/batch",
    "/apis/batch/v1",
    "/apis/batch/v1beta1",
    "/apis/certificates.k8s.io",
    "/apis/certificates.k8s.io/v1beta1",
    "/apis/coordination.k8s.io",
    "/apis/coordination.k8s.io/v1",
    "/apis/coordination.k8s.io/v1beta1",
    "/apis/events.k8s.io",
    "/apis/events.k8s.io/v1beta1",
    "/apis/extensions",
    "/apis/extensions/v1beta1",
    "/apis/networking.k8s.io",
    "/apis/networking.k8s.io/v1",
    "/apis/networking.k8s.io/v1beta1",
    "/apis/node.k8s.io",
    "/apis/node.k8s.io/v1beta1",
    "/apis/policy",
    "/apis/policy/v1beta1",
    "/apis/rbac.authorization.k8s.io",
    "/apis/rbac.authorization.k8s.io/v1",
    "/apis/rbac.authorization.k8s.io/v1beta1",
    "/apis/scheduling.k8s.io",
    "/apis/scheduling.k8s.io/v1",
    "/apis/scheduling.k8s.io/v1beta1",
    "/apis/storage.k8s.io",
    "/apis/storage.k8s.io/v1",
    "/apis/storage.k8s.io/v1beta1",
    "/healthz",
    "/healthz/autoregister-completion",
    "/healthz/etcd",
    "/healthz/log",
    "/healthz/ping",
    "/healthz/poststarthook/apiservice-openapi-controller",
    "/healthz/poststarthook/apiservice-registration-controller",
    "/healthz/poststarthook/apiservice-status-available-controller",
    "/healthz/poststarthook/bootstrap-controller",
    "/healthz/poststarthook/ca-registration",
    "/healthz/poststarthook/crd-informer-synced",
    "/healthz/poststarthook/generic-apiserver-start-informers",
    "/healthz/poststarthook/kube-apiserver-autoregistration",
    "/healthz/poststarthook/rbac/bootstrap-roles",
    "/healthz/poststarthook/scheduling/bootstrap-system-priority-classes",
    "/healthz/poststarthook/start-apiextensions-controllers",
    "/healthz/poststarthook/start-apiextensions-informers",
    "/healthz/poststarthook/start-kube-aggregator-informers",
    "/healthz/poststarthook/start-kube-apiserver-admission-initializer",
    "/logs",
    "/metrics",
    "/openapi/v2",
    "/version"
  ]
}
```
```text
[root@master etc]# kubectl get cs
NAME                 STATUS      MESSAGE                                                                                     ERROR
scheduler            Unhealthy   Get http://127.0.0.1:10251/healthz: dial tcp 127.0.0.1:10251: connect: connection refused   
controller-manager   Unhealthy   Get http://127.0.0.1:10252/healthz: dial tcp 127.0.0.1:10252: connect: connection refused   
etcd-1               Healthy     {"health":"true"}                                                                           
etcd-0               Healthy     {"health":"true"}
```


### kube-controller-manager安装
#### 文档



#### kube-controller-manager配置文件
#### kube-controller-manager服务文件
#### kube-controller-manager服务启动


### kube-scheduler安装 ###



## Node服务安装
```bash
cd /home/k8s/kubernetes/server/bin
cp -f kubelet kube-proxy /usr/local/bin/
```
### etcd安装 ###


### fannel ###
#### fannel 下载 ####
[官方下载地址](<https://github.com/coreos/flannel/releases>)

### docker安装 ###
[官方文档](<https://docs.docker.com/install/linux/docker-ce/binaries/>)
#### docker 下载 ####
[官方下载地址](<https://download.docker.com/linux/static/stable/x86_64/>)
```bash
wget https://download.docker.com/linux/static/stable/x86_64/docker-19.03.1.tgz
tar -zxvf  docker-19.03.1.tgz
cp -f docker/* /usr/local/bin/
```

#### docker 配置文件
```bash
cat > /opt/k8s/node/etc/docker.conf << "EOF"
DOCKER_NETWORK_OPTIONS="-H unix:///var/run/docker.sock \
-H 0.0.0.0:2375"
"EOF"
```

#### docker 服务文件
```bash
cat > /usr/lib/systemd/system/docker.service << EOF
[Unit]
Description=Docker Engine Service
Documentation=https://docs.docker.com
After=network-online.target
Wants=network-online.target

[Service]
Type=notify
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin"
EnvironmentFile=-/opt/k8s/node/etc/docker.conf
ExecStart=/usr/local/bin/dockerd $DOCKER_NETWORK_OPTIONS 
ExecReload=/bin/kill -s HUP $MAINPID
Restart=on-failure
RestartSec=5
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
Delegate=yes
KillMode=process

[Install]
WantedBy=multi-user.target
EOF
```


#### docker 服务启动
###### 启动
```bash
systemctl daemon-reload && systemctl start docker
```

###### 验证
```text
[root@node1 k8s]# docker version
Client: Docker Engine - Community
 Version:           19.03.1
 API version:       1.40
 Go version:        go1.12.5
 Git commit:        74b1e89e8a
 Built:             Thu Jul 25 21:17:37 2019
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.1
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.5
  Git commit:       74b1e89e8a
  Built:            Thu Jul 25 21:27:55 2019
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          v1.2.6
  GitCommit:        894b81a4b802e4eb2a91d1ce216b8817763c29fb
 runc:
  Version:          1.0.0-rc8
  GitCommit:        425e105d5a03fabd737a126ad93d62a9eeede87f
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```


### kubelet

### kube-proxy


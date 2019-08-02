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

## 软件环境

Node|IP|etcd|kube-apiserver|kube-controller-manager|kube-scheduler|docker|kubelet|kube-proxy
|:---|:---|:---|:---|:---|:---|:---|:---|:---|
master|192.168.159.3|3.3.13|
node1|192.168.159.4|\|
node2|192.168.159.5|\|

## Master安装
### etcd安装
[ETCD官方文档](<https://etcd.io/docs/v3.3.12/op-guide/configuration/>):https://etcd.io/docs/v3.3.12/op-guide/configuration/

#### 生成CA证书        
##### PKI工具 
[github地址](< https://github.com/cloudflare/cfssl>): https://github.com/cloudflare/cfssl         
[下载地址](<https://pkg.cfssl.org/>):https://pkg.cfssl.org/            
[参考地址1](<https://blog.51cto.com/liuzhengwei521/2120535?utm_source=oschina-app>):
https://blog.51cto.com/liuzhengwei521/2120535?utm_source=oschina-app            
[参考地址2](<https://segmentfault.com/a/1190000017408573?utm_source=tag-newest>):
https://segmentfault.com/a/1190000017408573?utm_source=tag-newest
[参考地址3](<https://www.cnblogs.com/effortsing/p/10332492.html>):
https://www.cnblogs.com/effortsing/p/10332492.html
    
    
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
        默认策略，指定了证书的有效期是一年(8760h); 
        expiry，证书的有效期;
        signing, 表示该证书可用于签名其它证书；生成的 ca.pem 证书中 CA=TRUE;
        server auth：表示 client 可以用该 CA 对 server 提供的证书进行验证;
        client auth：表示 server 可以用该 CA 对 client 提供的证书进行验证;
        服务端证书，profiles用途包含"server auth";
        客户端证书，profiles用途包含"client auth";
        对等证书或双向证书，profiles用途包含"server auth"和"client auth".
    ```
   
- CA证书申请文件
  ```bash
    cfssl print-defaults csr > ca-csr.json # 生成签名申请模板文件
    cat > ca-csr.json << EOF
        {
            "CN": "etcd CA",
            "hosts": [], 
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
  ```

- 利用CA证书和私钥生成ETCD的对等证书和私钥
    ```bash
      cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer etcd-csr.json | cfssljson -bare etcd-peer
      ls *.pem
      >> ca-key.pem  ca.pem  etcd-peer-key.pem  etcd-peer.pem
    ``` 
 
+ 利用CA证书和私钥生成ETCD的服务端证书和私钥
    ```bash
      cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server etcd-csr.json | cfssljson -bare etcd-server
      ls *.pem
      >> ca-key.pem  ca.pem etcd-peer-key.pem  etcd-peer.pem  etcd-server-key.pem  etcd-server.pem
    ``` 

- 利用CA证书和私钥生成ETCD的客户端证书和私钥
    ```bash
      cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client etcd-csr.json | cfssljson -bare etcd-client
      ls *.pem
      >> ca-key.pem  ca.pem  etcd-client-key.pem  etcd-client.pem etcd-peer-key.pem  etcd-peer.pem  etcd-server-key.pem  etcd-server.pem
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
    ETCD_LISTEN_CLIENT_URLS="http://192.168.159.3:2379,http://127.0.0.1"
    
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
    ETCD_LISTEN_CLIENT_URLS="http://192.168.159.4:2379,http://127.0.0.1"
    
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
    ETCD_LISTEN_CLIENT_URLS="http://192.168.159.4:2379,http://127.0.0.1"
    
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

#### 启动安全集群
##### 证书拷贝
```bash
    scp -P 22 /opt/etcd/pki/*.pem root@192.168.159.4:/opt/etcd/pki/
    scp -P 22 /opt/etcd/pki/*.pem root@192.168.159.5:/opt/etcd/pki/
```

##### 集群外部开启pki安全认证
    注意：外部的意思在本篇就是使用 etcdtl来访问，etcdctl 就是外部客户端。如果k8s的apiserver访问etcd，那么apiserver就是客户端
###### 修改master节点配置
```bash
cat > /opt/etcd/etc/etcd.conf << EOF
    #[Member]
    ETCD_NAME="etcd-1"
    ETCD_DATA_DIR="/opt/etcd/data"
    ETCD_LISTEN_PEER_URLS="http://192.168.159.3:2380"
    ETCD_LISTEN_CLIENT_URLS="https://192.168.159.3:2379,http://127.0.0.1"
    
    #[Clustering]
    ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.159.3:2380"
    ETCD_ADVERTISE_CLIENT_URLS="https://192.168.159.3:2379"
    ETCD_INITIAL_CLUSTER="etcd-1=http://192.168.159.3:2380,etcd-2=http://192.168.159.4:2380,etcd-3=http://192.168.159.5:2380"
    ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
    ETCD_INITIAL_CLUSTER_STATE="new" # 此处注意为new，意为创建新集群；existing意为加入已有集群
    #[Security]
    ETCD_CERT_FILE="/opt/etcd/pki/etcd-server.pem" #新增证书
    ETCD_KEY_FILE="/opt/etcd/pki/etcd-server-key.pem" #新增证书私钥
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
##### 集群内部开启pki安全认证
##### 客户端验证


### 安装k8s的master服务   
- kube-apiserver
- kube-controller-manager
- kube-scheduler

## Node安装
- etcd
- docker
- kubelet
- kube-proxy



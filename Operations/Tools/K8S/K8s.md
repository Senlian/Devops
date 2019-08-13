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
node1|192.168.159.4|\|
node2|192.168.159.5|\|

## Master安装
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
                "CN": "etcd",
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
    "CN": "etcd",
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
    "CN": "etcd",
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


### 安装k8s的master服务   
- kube-apiserver
- kube-controller-manager
- kube-scheduler

## Node安装
- etcd
- docker
- kubelet
- kube-proxy


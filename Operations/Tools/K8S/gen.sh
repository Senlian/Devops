#!/bin/bash
# etcd集群证书生成
# 证书生成策略文件
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

# CA证书申请文件
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

# CA证书申请文件
cat > etcd-csr.json << EOF
    {
        "CN": "etcd",
        "hosts": [
            "192.168.1.3",
            "192.168.1.4",
            "192.168.1.5",
            "127.0.0.1",
            "localhost",
            "localhost.localdomain"
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

# 生成CA认证中心
cfssl gencert --initca ca-csr.json | cfssljson -bare ca



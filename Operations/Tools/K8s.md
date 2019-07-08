# K8S环境搭建
## 相关文档
[K8S中文文档](<https://www.kubernetes.org.cn/k8s>)

[K8S官方文档](<https://kubernetes.io/zh/docs/concepts/architectu re/nodes/>)

[K8S部署](<https://blog.51cto.com/lizhenliang/2325770>)

## 系统准备

Name|IP|CentOS|kernel|cpu|memory
|:---|:---|:---|:---|:---|:---|
master|192.168.159.3|CentOS Linux release 7.4.1708 (Core)|3.10.0-693.el7.x86_64|Intel(R) Core(TM) i5-7500 CPU @ 3.40GHz * 1|2G
node1|192.168.159.4|CentOS Linux release 7.4.1708 (Core)|3.10.0-693.el7.x86_64|Intel(R) Core(TM) i5-7500 CPU @ 3.40GHz * 1|2G
node2|192.168.159.5|CentOS Linux release 7.4.1708 (Core)|3.10.0-693.el7.x86_64|Intel(R) Core(TM) i5-7500 CPU @ 3.40GHz * 1|2G


## Master安装
- etcd
- kube-apiserver
- kube-controller-manager
- kube-scheduler

## Node安装
- etcd
- docker
- kubelet
- kube-proxy



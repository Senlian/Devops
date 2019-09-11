# [KUBELET 参数说明](<https://k8smeetup.github.io/docs/admin/kubelet/>)
|参数名|类型&默认值|参数说明|
|:---|:---|:---|
|`--address`|strings, `0.0.0.0`|Kubelet要使用的IP地址, \ 对于所有IPv4接口设置为`0.0.0.0`，对于所有IPv6接口设置为`::`,默认值`0.0.0.0`。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息|
|`--allowed-unsafe-sysctls`|strings, `enabled`|不安全的sysctl或不安全的sysctl模式(以*结尾)，用逗号分隔。\ 风险自担。默认开启Sysctls功能。|
|`--alsologtostderr`|boolean, `false`|记录标准错误和文件|
|`--anonymous-auth`|boolean, `true`|启用对Kubelet服务器的匿名请求(未被其他身份验证方法拒绝的请求被视为匿名请求)，默认true。\  匿名请求拥有用户名`system:anonymous`和组`system:unauthenticated`。\ 不推荐:这个参数应该通过Kubelet的`--config`标志指定的配置文件来设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--application-metrics-count-limit`|int, `100`|每个容器的最大应用指标容量。不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表|
|`--authentication-token-webhook`|boolean, `true`|使用TokenReview API来确定承载令牌的身份验证。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--authentication-token-webhook-cache-ttl`|duration, `2m0s`|缓存来自webhook令牌验证器的响应的持续时间,默认2m0s。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--authorization-mode`|string, `AlwaysAllow`|Kubelet服务器的授权模式。`AlwaysAllow`或者`Webhook`,默认`AlwaysAllow`。Webhook模式使用SubjectAccessReview API来确定授权。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--authorization-webhook-cache-authorized-ttl`|duration, `5m0s`|缓存来自webhook授权器的“已授权”响应的持续时间,默认5m0s。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--authorization-webhook-cache-unauthorized-ttl`|duration, `30s`|缓存来自webhook授权器的“未授权”响应的持续时间,默认30s。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--azure-container-registry-config`|string, -|包含Azure容器注册表配置信息的文件的路径。|
|`--boot-id-file`|string, `/proc/sys/kernel/random/boot_id`|逗号分隔的文件列表，用于检查引导id。使用现有的第一个。\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--bootstrap-checkpoint-path`|string, -|<警告:Alpha特性>检查点存储路径
|`--bootstrap-kubeconfig`|string, -|用于为kubelet获取客户端证书的kubeconfig文件的路径。\ 如果`--kubeconfig`指定的文件不存在，则使用`bootstrap kubeconfig`从kube-apiserver申请客户端证书。\ 申请成功则将证书申请文件写到到`--bootstrap-kubeconfig`指定的路径，证书和私钥存储到`--cert-dir`指定的路径。|
|`--cert-dir`|string, `/var/lib/kubelet/pki`|TLS证书的存放路径，如果设置了`--tls-cert-file` 和 `--tls-private-key-file`则忽略该设置。|
|`--cgroup-driver`|string, `cgroupfs`|kubelet操控主机上的`cgroups`的驱动程序，`cgroupfs`或者`systemd`，默认`cgroupfs`。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--cgroup-root`|string, -|用于pod的可选根`cgroup`,基于容器最佳运行状态设定。默认为空，表示使用容器运行时的默认值。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--cgroups-per-qos`|boolean, `true`|启用QOS层次的`cgroup`创建，如果为`true`则创建最高级`Qos cgroup`和`pod cgroup`，默认`true`。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--chaos-chance`|float, -|用于测试，如果大于0.0,则引入客户机错误和延迟|
|`--client-ca-file`|string, -|用于客户端证书验证的根证书\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--cloud-config`|string, -|云服务商配置文件路径，为空表示没有。|
|`--cloud-provider`|string, -|云服务商名称，为空表示没有供应商。设置了将作为节点名称使用，请参考云提供商文档，以确定是否以及如何使用主机名|
|`--cluster-dns`|string, -|逗号分隔的DNS服务器IP地址列表。如果POD设置了`dnsPolicy=ClusterFirst`，则容器使用该值作为DNS服务。\ 注意:列表中出现的所有DNS服务器必须提供相同的一组记录，否则集群中的名称解析可能无法正常工作。无法保证可以联系哪个DNS服务器进行名称解析。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--cluster-domain`|string, -|集群域名，如果设置kubelet将配置所有容器除搜索主机域外还搜索该域。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--cni-bin-dir`|string, `/opt/cni/bin`|<警告:Alpha特性>逗号分隔的路径，CNI插件的二进制文件搜索路径，仅在`--container-runtime`设定改为docker时有效。|
|`--cni-conf-dir`|string, `/etc/cni/net.d`|<警告:Alpha特性>逗号分隔的路径，CNI插件的配置文件搜索路径，仅在`--container-runtime`设定改为docker时有效。|
|`--config`|string, -|Kubelet将从该文件加载其初始配置。可以是相对路径也可以是绝对路径，相对路径相对于kubelet的工作目录。\ 没有设置表示使用内置默认值，命令行参数将覆盖其中配置。|
|`--container-hints`|string, `/etc/cadvisor/container_hints.json`|容器提示文件的位置。\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--container-log-max-files`|int32, `5`|<警告:Beta特性>设置可以为容器显示的容器日志文件的最大数量。这个数字必须是>= 2，默认5。\ 此标志只能与`--container-runtime=remote`一起使用。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--container-log-max-size`|string, `10Mi`|<警告:Beta特性>设置日志文件最大大小，例如10Mi，默认10Mi。\ 此标志只能与`--container-runtime=remote`一起使用。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--container-runtime`|string, `docker`|容器类型，`docker`, `remote`, `rkt`,不推荐`rkt`，默认`docker`。|
|`--container-runtime-endpoint`|string, `unix:///var/run/dockershim.sock`|远程容器服务地址，linux支持socket方式，windows支持tcp和npipe方式，例如`unix:///var/run/dockershim.sock`, `npipe:////./pipe/dockershim`。|
|`--containerd`|string, `/run/containerd/containerd.sock`|容器地址(默认为`/run/containerd/containerd.sock`)\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--containerized`|-|在容器中运行kubelet。不推荐:该特性将在稍后的版本中删除。|
|`--contention-profiling`|string, `enabled`|启用锁争用分析。不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--cpu-cfs-quota`|boolean, `true`|为指定CPU限制的容器启用CPU CFS配额强制。不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--cpu-cfs-quota-period`|duration, `100ms`|设置CPU CFS配额周期值，`cpu.cfs_period_us`，默认为Linux内核默认值(默认为100ms)。 \ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--cpu-manager-policy`|string, `none`|使用CPU管理器策略，`none`或者`static`，默认值为`none`。 \ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--cpu-manager-reconcile-period`|NodeStatusUpdateFrequency, `10s`|<警告:Alpha特性> CPU管理器调节周期。例如:“10s”或“1m”。如果没有提供，则默认为NodeStatusUpdateFrequency(默认为10s) \ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--docker`|string, `unix:///var/run/docker.sock`|docker地址，默认`unix:///var/run/docker.sock`。\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--docker-endpoint`|string, `unix:///var/run/docker.sock`|docker通信地址，仅在`--container-runtime`设定改为docker时有效|
|`--docker-env-metadata-whitelist`|string, -|需要为docker容器收集的以逗号分隔的环境变量键列表。\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--docker-only`|-|除基本统计信息外，只产生docker的报告。\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--docker-root`|string, `/var/lib/docker`|从docker信息读取跟信息。不推荐：这是一个回退功能。|
|`--docker-tls`|-|使用TLS连接到docker。不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--docker-tls-ca`|string, `ca.pem`|docker的CA证书路径。不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--docker-tls-cert`|string, `cert.pem`|docker客户端证书。不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--docker-tls-key`|string, `key.pem`|docker客户端证书私钥。不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--dynamic-config-dir`|string, -|Kubelet将使用此目录检查下载的配置并跟踪配置健康状况。如果这个目录不存在，Kubelet将创建它。路径可以是绝对的，也可以是相对的;相对路径从Kubelet的当前工作目录开始。\ 该特性可以启用kubelet动态配置，但必须在`--feature-gates`中设置`DynamicKubeletConfig=true`，在beta版本中默认为true|
|`--enable-cadvisor-json-endpoints`|boolean, true|启用cAdvisor的json /spec 和 /stats/* 端点，默认true。|
|`--enable-controller-attach-detach`|boolean, true|启用附加/分离管理器管理分配到该节点的卷的附加/分离，并禁止kubelet执行任何附加/分离操作，默认true。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--enable-debugging-handlers`|string, -|提供服务地址，用于日志收集以及本地运行容器和命令，默认true。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--enable-load-reader`|boolean, -|是否启用cpu加载读取器。不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--enable-server`|boolean, `true`|启用Kubelet的服务(默认为true)|
|`--enforce-node-allocatable`|string, `pods`|有kubelet分配的节点执行级别，可选'none', 'pods', 'system-reserved', 和 'kube-reserved',\ 如果包含后两项则必须设定'--system-reserved-cgroup'和'--kube-reserved-cgroup'，如果设定`none`则不应该包含其他项。详见https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--event-burst`|int32, `10`|突发事件记录大小，暂时允许事件记录突破到该数字，但不超过`--event-qps`，仅当`--event-qps>0`时有效，默认10。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--event-qps`|int32, `5`|如果等于0，没有限制。如果大于0，限定每秒创建事件为该值,默认5。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--event-storage-age-limit`|string, `default=0`|存储每种事件类型的最长时间，逗号分隔的键值对列表，键是事件类型（包括`creation`, `oom`和 `default`），值是`duration`类型的时间，Default应用于所有非指定的事件类型(默认值“default=0”)。\ \ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--event-storage-event-limit`|string, `default=0`|存储每种事件类型的最大数量，逗号分隔的键值对列表，键是事件类型（包括`creation`, `oom`和 `default`），值是整数，Default应用于所有非指定的事件类型(默认值“default=0”)。\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--eviction-hard`|mapStringString, `imagefs.available<15%,\ memory.available<100Mi,\ nodefs.available<10%,\ nodefs.inodesFree<5%`|一组pod迁出阈值，如`memory.available<1Gi`。满足条件则触发pod迁出。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--eviction-max-pod-grace-period`|int32, -|满足迁出阈值后的最大宽限期（单位秒），如果为负值，则按照pod指定值执行。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--eviction-minimum-reclaim`|mapStringString, -|如果某类资源不足时，kubelet执行pod回收的最小回收量，例`imagefs.available=2Gi`。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--eviction-pressure-transition-period`|duration, `5m0s`|kubelet必须等待一段时间才能从迁出压力状态过渡出来。(默认5m0s)\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--eviction-soft`|mapStringString, -|一组迁出阈值(例如memory.available<1.5Gi)，如果在相应的宽限期内达到该阈值，就会触发pod迁出。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--eviction-soft-grace-period`|mapStringString, -|一组迁出宽限期(例如memory.available=1m30s)，对应于在触发pod迁出之前，阈值条件必须保持多长时间。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--exit-on-lock-contention`|boolean, -|在发生锁文件争用时kubelet是否退出。|
|`--experimental-allocatable-ignore-eviction`|boolean, false|计算可分配节点时是否忽略硬迁出阈值,默认false，详见https://kubernetes.io/docs/tasks/administer-cluster/reserve-compute-resources/。|
|`--experimental-bootstrap-kubeconfig`|string, -|弃用，使用`--bootstrap-kubeconfig`替代。|
|`--experimental-check-node-capabilities-before-mount`|boolean, -|<实验>如果为true，kubete在执行挂在前将检查底层节点是否有必须的组件（二进制文件，配置文件等）
|`--experimental-kernel-memcg-notification`|-|如果启用，kubelet将于内核memcg通知管理器一起确定是否交叉清除内存阈值而不是轮询。|
|`--experimental-mounter-path`|string, -|<实验>贴片机二进制路径。保持为空以使用默认挂载。|
|`--fail-swap-on`|boolean, `true`|如果主机节点启用了`swap`则kubelet启用失败。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--feature-gates`|mapStringBool, -|一组键值对，用于描述alpha/实验性特性的特性。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。包括以下选项：|
|-|-|APIListChunking=true\false (BETA - default=true)|
|-|-|APIResponseCompression=true\false (ALPHA - default=false)|
|-|-|AllAlpha=true\false (ALPHA - default=false)|
|-|-|AppArmor=true\false (BETA - default=true)|
|-|-|AttachVolumeLimit=true\false (BETA - default=true)|
|-|-|BalanceAttachedNodeVolumes=true\false (ALPHA - default=false)|
|-|-|BlockVolume=true\false (BETA - default=true)|
|-|-|BoundServiceAccountTokenVolume=true\false (ALPHA - default=false)|
|-|-|CPUManager=true\false (BETA - default=true)|
|-|-|CRIContainerLogRotation=true\false (BETA - default=true)|
|-|-|CSIBlockVolume=true\false (BETA - default=true)|
|-|-|CSIDriverRegistry=true\false (BETA - default=true)|
|-|-|CSIInlineVolume=true\false (ALPHA - default=false)|
|-|-|CSIMigration=true\false (ALPHA - default=false)|
|-|-|CSIMigrationAWS=true\false (ALPHA - default=false)|
|-|-|CSIMigrationAzureDisk=true\false (ALPHA - default=false)|
|-|-|CSIMigrationAzureFile=true\false (ALPHA - default=false)|
|-|-|CSIMigrationGCE=true\false (ALPHA - default=false)|
|-|-|CSIMigrationOpenStack=true\false (ALPHA - default=false)|
|-|-|CSINodeInfo=true\false (BETA - default=true)|
|-|-|CustomCPUCFSQuotaPeriod=true\false (ALPHA - default=false)|
|-|-|CustomResourceDefaulting=true\false (ALPHA - default=false)|
|-|-|CustomResourcePublishOpenAPI=true\false (BETA - default=true)|
|-|-|CustomResourceSubresources=true\false (BETA - default=true)|
|-|-|CustomResourceValidation=true\false (BETA - default=true)|
|-|-|CustomResourceWebhookConversion=true\false (BETA - default=true)|
|-|-|DebugContainers=true\false (ALPHA - default=false)|
|-|-|DevicePlugins=true\false (BETA - default=true)|
|-|-|DryRun=true\false (BETA - default=true)|
|-|-|DynamicAuditing=true\false (ALPHA - default=false)|
|-|-|DynamicKubeletConfig=true\false (BETA - default=true)|
|-|-|ExpandCSIVolumes=true\false (ALPHA - default=false)|
|-|-|ExpandInUsePersistentVolumes=true\false (BETA - default=true)|
|-|-|ExpandPersistentVolumes=true\false (BETA - default=true)|
|-|-|ExperimentalCriticalPodAnnotation=true\false (ALPHA - default=false)|
|-|-|ExperimentalHostUserNamespaceDefaulting=true\false (BETA - default=false)|
|-|-|HyperVContainer=true\false (ALPHA - default=false)|
|-|-|KubeletPodResources=true\false (BETA - default=true)|
|-|-|LocalStorageCapacityIsolation=true\false (BETA - default=true)|
|-|-|LocalStorageCapacityIsolationFSQuotaMonitoring=true\false (ALPHA - default=false)|
|-|-|MountContainers=true\false (ALPHA - default=false)|
|-|-|NodeLease=true\false (BETA - default=true)|
|-|-|NonPreemptingPriority=true\false (ALPHA - default=false)|
|-|-|PodShareProcessNamespace=true\false (BETA - default=true)|
|-|-|ProcMountType=true\false (ALPHA - default=false)|
|-|-|QOSReserved=true\false (ALPHA - default=false)|
|-|-|RemainingItemCount=true\false (ALPHA - default=false)|
|-|-|RequestManagement=true\false (ALPHA - default=false)|
|-|-|ResourceLimitsPriorityFunction=true\false (ALPHA - default=false)|
|-|-|ResourceQuotaScopeSelectors=true\false (BETA - default=true)|
|-|-|RotateKubeletClientCertificate=true\false (BETA - default=true)|
|-|-|RotateKubeletServerCertificate=true\false (BETA - default=true)|
|-|-|RunAsGroup=true\false (BETA - default=true)|
|-|-|RuntimeClass=true\false (BETA - default=true)|
|-|-|SCTPSupport=true\false (ALPHA - default=false)|
|-|-|ScheduleDaemonSetPods=true\false (BETA - default=true)|
|-|-|ServerSideApply=true\false (ALPHA - default=false)|
|-|-|ServiceLoadBalancerFinalizer=true\false (ALPHA - default=false)|
|-|-|ServiceNodeExclusion=true\false (ALPHA - default=false)|
|-|-|StorageVersionHash=true\false (BETA - default=true)|
|-|-|StreamingProxyRedirects=true\false (BETA - default=true)|
|-|-|SupportNodePidsLimit=true\false (BETA - default=true)|
|-|-|SupportPodPidsLimit=true\false (BETA - default=true)|
|-|-|Sysctls=true\false (BETA - default=true)|
|-|-|TTLAfterFinished=true\false (ALPHA - default=false)|
|-|-|TaintBasedEvictions=true\false (BETA - default=true)|
|-|-|TaintNodesByCondition=true\false (BETA - default=true)|
|-|-|TokenRequest=true\false (BETA - default=true)|
|-|-|TokenRequestProjection=true\false (BETA - default=true)|
|-|-|ValidateProxyRedirects=true\false (BETA - default=true)|
|-|-|VolumePVCDataSource=true\false (ALPHA - default=false)|
|-|-|VolumeSnapshotDataSource=true\false (ALPHA - default=false)|
|-|-|VolumeSubpathEnvExpansion=true\false (BETA - default=true)|
|-|-|WatchBookmark=true\false (ALPHA - default=false)|
|-|-|WinDSR=true\false (ALPHA - default=false)|
|-|-|WinOverlay=true\false (ALPHA - default=false)|
|-|-|WindowsGMSA=true\false (ALPHA - default=false)|
|`--file-check-frequency`|duration, `20s`|检查配置修改的时间间隔，默认20s。不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--global-housekeeping-interval`|duration, `1m0s`|全球管理间隔，默认1m0s。不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--hairpin-mode`|string, `promiscuous-bridge`|指定kubelet如何设置NAT回环(端口回流)，允许服务访问自身服务。有效值`promiscuous-bridge`, `hairpin-veth`和`none`，默认`promiscuous-bridge`。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--healthz-bind-address`|string, `127.0.0.1`|服务监听地址，`0.0.0.0`监听所有，默认`127.0.0.1`。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--healthz-port`|int32, `10248`|服务监听端口，0表示禁用，默认10248。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--help`|-|kubelet帮助信息，`kubelet --help`|
|`--hostname-override`|string, -|node节点主机名，如果设置`--cloud-provider`则以`--cloud-provider`确定主机名，请参考cloud provider文档，以确定是否以及如何使用主机名。|
|`--housekeeping-interval`|duration, `10s`|容器内务处理时间间隔(默认为10秒)。|
|`--http-check-frequency`|duration, `20s`|http接收数据的时间间隔，默认20秒。不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--image-gc-high-threshold`|int32, `85`|磁盘使用量在该百分比内始终进行镜像垃圾回收，范围0-100，设置为100则禁用镜像垃圾回收，默认85。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--image-gc-low-threshold`|int32, `80`|磁盘使用量低于该值则禁用镜像垃圾回收，范围0-100且小于`--image-gc-high-threshold`的值，默认80。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--image-pull-progress-deadline`|duration, `1m0s`|镜像拉取超时时间，超过则取消镜像拉取。仅当`--container-runtime=docker`时有效，默认`1m0s`。|
|`--image-service-endpoint`|string, `unix:///var/run/dockershim.sock`|<实验>远程镜像服务地址，为空则与`--container-runtime-endpoint`设定相同。linux支持socket方式，windows支持tcp和npipe方式，例如`unix:///var/run/dockershim.sock`, `npipe:////./pipe/dockershim`。|
|`--iptables-drop-bit`|int32, `15`|fwmark空间bit大小，用来标记要丢弃的包。必须在[0,31]范围内。(默认15)。不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--iptables-masquerade-bit`|int32, `14`|fwmark空间的位，用于为SNAT标记包。必须在[0,31]范围内。请将此参数与kube-proxy中的相应参数匹配。(默认14)。不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--keep-terminated-pod-volumes`|-|pod终止后卷保持挂载在节点，可用于调试卷相关问题。(不推荐:将在未来版本中删除)|
|`--kube-api-burst`|int32, `10`|发送到`kube-apiserver`每秒请求量 ，默认10。不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`---kube-api-content-type`|string, `application/vnd.kubernetes.protobuf`|发送给kube-apiserver的请求内容类型。不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--kube-api-qps`|int32, `5`|与kube-apiserver对话时的QPS(默认5)。不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--kube-reserved`|mapStringString, `default=none`|设置预留给k8s组件的资源，例如：cpu=200m,memory=500Mi,ephemeral-storage=1Gi。目前支持根文件系统的cpu、内存和本地临时存储。详见http://kubernetes.io/docs/user-guide/compute-resources。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--kube-reserved-cgroup`|string, `''`|用于管理计算资源通过`--kube-reserved`标记保留的k8s组件的顶级`cgroup`的绝对名称。如`/kube-reserved`。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--kubeconfig`|string, -|设置`kubeconfig`文件路径，定义如何连接`kube-apiserver`，提供则启用API Server模式，弃用`--kubeconfig`则启动独立模式。|
|`--kubelet-cgroups`|string, -|用于创建和运行kubelet的`cgroup`可选绝对名称。|
|`--lock-file`|string, -|kubelet锁文件的路径。|
|`--log-backtrace-at`|traceLocation, `0`|当日志记录命中几行文件内容时，发出堆栈跟踪。|
|`--log-cadvisor-usage`|-|是否记录cAdvisor容器的使用情况。不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--log-dir`|string, -|如果非空，则在此目录中写入日志文件。|
|`--log-file`|string, -|如果非空，则使用此日志文件。|
|`--log-file-max-size`|uint, `1800`|定义日志文件可以增长到的最大大小。单位是字节。如果值为0，则最大文件大小是无限制的。1800(默认)。|
|`--log-flush-frequency`|duration, `5s`|日志刷新之间的最大秒数(默认为5秒)。|
|`--logtostderr`|boolean, `true`|日志到标准错误而不是文件(默认为true)。|
|`--machine-id-file`|string, `/etc/machine-id,/var/lib/dbus/machine-id`|逗号分隔的文件列表，用于检查机器id。使用现有的第一个。\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--make-iptables-util-chains`|boolean, `true`|如果为真，kubelet将确保主机上存在iptables实用程序规则。不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--manifest-url`|string, -|用于访问要运行的其他POD规范的URL。不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--manifest-url-header`|string, -|使用逗号分隔，访问`--manifest-url`地址时提供的http头列表。具有相同名称的多个头将按提供的顺序添加，可以重复调用此标志，如：`--manifest-url-header 'a:hello,b:again,c:world' --manifest-url-header 'b:beautiful'`。 \ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--master-service-namespace`|string, `default`|kubernetes主服务注入到pods中的命名空间(默认值为“default”)(不推荐使用:在将来的版本中，这个标志将被删除)。|
|`--max-open-files`|int, `1000000`|kubelet进程可以打开的文件数量。不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--max-pods`|int32, `110`|单个kubelet进程可以运行的Pod数量。不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--maximum-dead-containers`|int32, `-1`|要全局保留的容器旧实例的最大数量。每个容器都占用一些磁盘空间。若要禁用，请设置为负数。(默认:-1)(不推荐:使用`--eviction-hard`或`--eviction-soft`替代。将在未来的版本中删除。)|
|`--maximum-dead-containers-per-container`|int32, `1`|每个容器要保留的旧实例的最大数量。每个容器都占用一些磁盘空间。(默认值1)(不推荐:使用`--eviction-hard`或`--eviction-soft`替代。将在未来的版本中删除。)|
|`--minimum-container-ttl-duration`|duration, -|使用结束的容器在回收前最小存活时间。例如:“300ms”、“10s”或“2h45m”(不推荐:使用`--eviction-hard`或`--eviction-soft`替代。将在未来的版本中删除。)|
|`--minimum-image-ttl-duration`|duration, -|没有使用的镜像在被垃圾回收前的保留最小时间。例如:“300ms”、“10s”或“2h45m”。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--network-plugin`|string, -|<警告:Alpha特性>要为kubelet/pod生命周期中的各种事件调用的网络插件的名称。仅在`container-runtime=docker`时有效。|
|`--network-plugin-mtu`|int32, -|<警告:Alpha特性>要传递给网络插件的MTU，以覆盖默认值。设置为0以使用默认的1460 MTU。仅在`container-runtime=docker`时有效。|
|`--node-ip`|string, -|节点的IP地址。如果设置好，kubelet将为节点使用这个IP地址。|
|`--node-labels`|mapStringString, -|<警告:Alpha特性>节点向集群注册时附带的标签，必须是逗号分隔的键值对。`kubernetes.io`命名空间类的标签必须以一个被允许的前缀开头，例如：kubelet.kubernetes.io, node.kubernetes.io；\或者在特定的标签集合中,包括(beta.kubernetes.io/arch, beta.kubernetes.io/instance-type, beta.kubernetes.io/os, failure-domain.beta.kubernetes.io/region, failure-domain.beta.kubernetes.io/zone, failure-domain.kubernetes.io/region, failure-domain.kubernetes.io/zone, kubernetes.io/arch, kubernetes.io/hostname, kubernetes.io/instance-type, kubernetes.io/os)
|`--node-status-max-images`|int32, `50`|<警告:Alpha特性>在`Node.Status.Images`中报告的最大图像数量，-1表示没有限制，默认50。|
|`--node-status-update-frequency`|duration, `10s`|kubelet多久向Master报告一次节点状态，修改时要小心，它必须与nodecontroller中的nodeMonitorGracePeriod搭配使用，默认10s。|
|`--non-masquerade-cidr`|string, -|超出此范围的IP流量将使用IP伪装。设置为'0.0.0.0/0'，用不伪装。(默认值“10.0.0.0/8”)(弃用:将在未来版本中删除)。|
|`--oom-score-adj`|int32, `-999`|kubelet的`--oom-score-adj`值，值必须在[-1000,1000]范围内(默认值-999)。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--pod-cidr`|string, -|独立模式下用于pod IP地址的CIDR。在集群模式下，从主节点获得。对于IPv6，分配的最大IP数是65536。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--pod-infra-container-image`|string, `k8s.gcr.io/pause:3.1`|每个pod中的`network/ipc`命名空间容器将使用的映像，用于管理容器网络。仅在`container-runtime=docker`时有效，默认`k8s.gcr.io/pause:3.1`。|
|`--pod-manifest-path`|string, -|存放静态pod文件的目录或者单个静态pod文件，忽略以`.`开头的文件。 \ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--pod-max-pids`|int, `-1`| 设置每个pod的最大进程数。如果-1,kubelet默认为节点可分配pid容量。(默认为-1)。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--pods-per-core`|int32, -| 单个kubelet中每个核心可以运行的pod数量，总数不能超过`max-pods`，如果超过则使用`max-pods`，0表示取消限制。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--port`|int32, `10250`|kubelet的端口，默认10250。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--protect-kernel-defaults`|-|内核调优的默认kubelet行为，如果设置了且内核可调项与kubelet默认值不同，kubelet会报错。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--provider-id`|string, -|节点在机器库中的唯一标识符。|
|`--qos-reserved`|mapStringString, -|<警告:Alpha特性>需要启用`QOSReserved`特性，用于描述如何在QoS级别上保留pod资源请求的一组键值对，目前只支持内存，如：memory=50%。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--read-only-port`|int32, `10255`|Kubelet在没有身份验证/授权的情况下运行的只读端口(设置为0以禁用)(默认为10255)\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--really-crash-for-testing`|boolean, -|用于测试，应急状态下崩溃。|
|`--redirect-container-streaming`|boolean, -|启用容器流重定向。如果为false, kubelet将代理apiserver和容器之间的容器流数据;如果为真，kubelet将返回一个http重定向到apiserver，而apiserver将直接访问容器。代理方法更安全，但是会带来一些开销。重定向方法的性能更高，但安全性更差，因为apiserver和容器之间的连接可能没有经过身份验证。
|`--register-node`|boolean, `true`|是否向kube-apiserver注册节点，如果`--kubeconfig`没有设定，则该项无效，因为不知道向谁注册。|
|`--register-schedulable`|boolean, `false`|将节点注册为可调度的。如果`--register-node=false`，则不会产生任何效果。(默认为true)(弃用:将在未来版本中删除)。|
|`--register-with-taints`|[]api.Taint, -|用给定的`taints`列表注册节点，用逗号分隔，格式："<key>=<value>:<effect>"，如果`--register-node=false`，则不会产生任何操作。|
|`--registry-burst`|int32, `10`| 拉取镜像的最大并发数，允许同时拉取的镜像数，不能超过 registry-qps ，仅当 --registry-qps 大于 0 时使用。 (默认 10)\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--registry-qps`|int32, `5`|如果> 0，将限制每秒拉去镜像个数为这个值。如果为0，无限制。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--resolv-conf`|string, `/etc/resolv.conf`|用作容器 DNS 解析配置的解析器配置文件\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--root-dir`|string, `/var/lib/kubelet`|管理kubelet文件的路径(volume mounts等)。|
|`--rotate-certificates`|string, -|<警告:Beta特性>当客户端证书到期时自动向`kube-apiserver`申请新证书。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--rotate-server-certificates`|string, -|在证书过期时，通过从kube-apiserver自动请求轮换服务端证书。需要启用RotateKubeletServerCertificate功能门，并批准提交 CertificateSigningRequest 对象。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--runonce`|boolean, -|如果为true，则在从静态pod文件或远程url生成pod后退出。仅限`--enable-server=true`。|
|`--runtime-cgroups`|string, -|用于创建和运行运行时的cgroup的可选绝对名称。|
|`--runtime-request-timeout`|duration, `2m0s`|容器运行时除了长时间请求操作如（pull,logs,exec,attach）外的操作超时时间，超时后将抛出错误并重试，默认2m0s。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--seccomp-profile-root`|string, `/var/lib/kubelet/seccomp`|<警告:Alpha特性>seccomp配置文件的目录路径。|
|`--serialize-image-pulls`|boolean, `true`|一次拉取一个镜像，建议在docker版本低于1.9或者使用Aufs存储后端的节点上不改个默认值，默认true。|
|`--skip-headers`|boolean, `true`|如果为真，请在日志消息中避免头前缀。|
|`--skip-log-headers`|boolean, `true`|如果为真，则在打开日志文件时避免头文件。|
|`--stderrthreshold`|severity, `2`|在此阈值或以上的日志发到stderr(默认2)。|
|`--storage-driver-buffer-duration`|duration, `1m0s`|此期间写入存储驱动程序中的内容将被缓存，并作为单个事务提交到非内存后端(默认为1m0s)。\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--storage-driver-db`|string, `cadvisor`|数据库名称(默认为“cadvisor”)。\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--storage-driver-host`|string, `localhost:8086`|数据库地址(默认为“localhost:8086”)。\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--storage-driver-password`|string, `root`|数据库密码(默认为“root”)。\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--storage-driver-secure`|boolean, -|使用与数据库的安全连接。\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--storage-driver-table`|string, `stats`|表名(默认为“stats”)。\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--storage-driver-user`|string, `root`|数据库用户名(默认为“cadvisor”)。\ 不推荐:这是一个cadvisor标志，错误地注册了Kubelet。\ 由于遗留问题，在删除之前，它将遵循标准的CLI弃用时间表。|
|`--streaming-connection-idle-timeout`|duration, `4h0m0s`|连接保持时间，默认4h0m0s。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--sync-frequency`|duration, `1m0s`|同步运行容器和配置之间的最大周期(默认为1m0s)。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--system-cgroups`|string, -|可选的 cgroups 的绝对名称，用于将未包含在 cgroup 内的所有非内核进程放置在根目录 / 中，回滚这个标识需要重启。|
|`--system-reserved`|mapStringString, -|一组ResourceName=ResourceQuantity对（例如，cpu = 200m，memory = 500Mi，ephemeral-storage = 1Gi，pid = 1000），描述为非kubernetes组件保留的资源。目前仅支持cpu，内存和pid,[default=none]。详见http://kubernetes.io/docs/user-guide/compute-resources。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--system-reserved-cgroup`|string, `''`|顶级cgroup的绝对名称，用于管理计算资源通过“--system-reserved”标志保留的非kubernetes组件,除了'/system-reserved',默认''。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--tls-cert-file`|string, -|用于HTTPS的x509证书，如果`--tls-cert-file` 和 `--tls-private-key-file`没有提供，则为公共地址生成自签名证书和密钥并保存到`--cert-dir`目录中。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--tls-cipher-suites`|string, -|服务器密码套件的逗号分隔列表。如果省略，将使用默认的Go密码套件。可能的值:TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA、TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256 TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256、TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384, TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305, TLS_ECDHE_ECDSA_WITH_RC4_128_SHA, TLS_ECDHE_RSA_WITH_3DES_EDE_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256, TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256, TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA, TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384 TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305, TLS_ECDHE_RSA_WITH_RC4_128_SHA、TLS_RSA_WITH_3DES_EDE_CBC_SHA TLS_RSA_WITH_AES_128_CBC_SHA、TLS_RSA_WITH_AES_128_CBC_SHA256 TLS_RSA_WITH_AES_128_GCM_SHA256, TLS_RSA_WITH_AES_256_CBC_SHA, TLS_RSA_WITH_AES_256_GCM_SHA384 TLS_RSA_WITH_RC4_128_SHA。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--tls-min-version`|string, -|支持最小TLS版本。可能的值:VersionTLS10、VersionTLS11、VersionTLS12、VersionTLS13。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--tls-private-key-file`|string, -|包含x509私钥匹配的文件`--tls-cert-file`。\ 不推荐:该参数应该通过Kubelet的`--config`标志指定的配置文件设置。\ 见https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/获取更多信息。|
|`--v`|Level, -|日志等级。|
|`--version`|version[=true], -|打印版本信息并退出。|
|`--vmodule`|moduleSpec, -|逗号分隔的模式列表，用于过滤筛选日志。|
|`--volume-plugin-dir`|string, `/usr/libexec/kubernetes/kubelet-plugins/volume/exec/`|搜索第三方卷插件的完整路径。|
|`--volume-stats-agg-period`|duration, `1m0s`|指定kubelet计算和缓存所有pod和卷的卷磁盘使用量的间隔。0禁用卷计算。||日志等级。|
|`--version`|version[=true], -|打印版本信息并退出。|
|`--vmodule`|moduleSpec, -|逗号分隔的模式列表，用于过滤筛选日志。|
|`--volume-plugin-dir`|string, `/usr/libexec/kubernetes/kubelet-plugins/volume/exec/`|搜索第三方卷插件的完整路径。|
|`--volume-stats-agg-period`|duration, `1m0s`|指定kubelet计算和缓存所有pod和卷的卷磁盘使用量的间隔。0禁用卷计算。|
# Logstash使用文档
## 多管道配置
[文档](<https://www.elastic.co/guide/en/logstash/current/pipeline-to-pipeline.html>)
```yaml
    # pipline.yml
    - pipeline.id: my-pipeline_1
      path.config: "/etc/path/to/p1.config"
      pipeline.workers: 3
    - pipeline.id: my-other-pipeline
      path.config: "/etc/different/path/p2.cfg"
      queue.type: persisted
    - pipeline.id: my-other-pipeline
      config.string: 'input{stdin{}} output {stdout {}}'  
```


## 配置文件结构
```editorconfig
    input {
        stdin {
        }
        file {
            path => [xxx]
            type => "xxx"
        }
    }
    
    filter {
        grok {
        }
    }
    
    output {
        stdout {
        }
        elasticsearch {
        }
    }
```


## 配置文件语法
#### 字段语法
示例：
```metadata json
    {
      "agent": "Mozilla/5.0 (compatible; MSIE 9.0)",
      "ip": "192.168.24.44",
      "request": "/index.html"
      "response": {
        "status": 200,
        "bytes": 52353
      },
      "ua": {
        "os": "Windows 7"
      }
    }
```
- 顶级字段
    ```text
      顶级字段语法:[filedname] 或 filedname
      示例中顶级字段包括：agent、ip、request、response、ua
      引用顶级字段agent，可以用[agent]，也可以直接用agent
    ```
    
    
- 嵌套字段
    ```text
      嵌套字段语法：[top-level field][nested field]
      指定[ua][os]引用os字段
    ```


- sprintf 格式
    ```text
      利用sprintf格式在字符串中嵌套引用字段或其他格式
      引用字段：%{[filed name]} 或 %{filed name} 或%{[top-level field][nested field]}
      引用格式：%{+FORMAT}，其中FORMAT是时间格式，如%{+yyyy.MM.dd.HH}
    ```  
    
    
- 条件判断
    ```bash
        if EXPRESSION {
          ...
        } else if EXPRESSION {
          ...
        } else {
          ...
        }
    ```
    - EXPRESSION
        - 判断等式成立` ==, !=, <, >, <=, >= `
        - 模式检查` [fieldname] =~ pattern, [fieldname]  !~ pattern`
        - 包含关系` in, not in `
        - 布尔运算` and, or, nand, xor `
        - 一元运算符 `!`
        - 条件分组 `(EXPRESSION)`
       
       
        
- @metadata
    ```text
      语法：[@metadata][fieldname]
      可以在filter和output中引用，但不在输出内容中显示
      引用元数据
      [@metadata][_index]      
      [@metadata][_type]      
      [@metadata][_id]      
      [@metadata][timestamp]      
    ```
    

#### 环境变量的配置和使用
- 环境变量配置
    - 临时环境变量
        > 脚本或者命令行中运行`export VAR_NAME="value""`
    - 永久环境变量        
        > 在/etc/profile中定义
        
    
- 环境变量使用
    > 环境变量必须在logstash启动前定义，修改环境变量需要重启logstash才能生效
    - 使用方法
        ```bash
            ${VAR_NAME} #没有设置会报错
            ${VAR_NAME: default} #没有设置用default作为默认值
        ```
        

#### glob模式支持
- \*
    ```text
      # 以conf开头
      conf*  
      # 以conf结尾
      *conf
      # 包含conf
      *conf*
      # 点开头文件匹配
      {*,.*}.
      例，匹配.log结尾的文件
      "/var/log/*.log"
    ```
    
- \*\*    
    `目录递归匹配`
    ```text
      目录递归匹配
      例，匹配log的子目录中以.log结尾的文件
      "/var/log/**/*.log
    ```
    
- ?
    `匹配任意一个字符`    
    
- []
    `匹配括号内任意一个字符`  
      
- {str1,str}
    ```text
      类似正则(foo|bar)，匹配字符串str1或者str2
      例，匹配app1或app2或app3路径下的data.log文件
      "/path/to/logs/{app1,app2,app3}/data.log"
    ```
    
- \
    `转义字符`
        


## 插件
[github地址](<https://github.com/logstash-plugins>)
#### Input插件
- codec => multiline 
    
    [跨行文本处理](<https://www.elastic.co/guide/en/logstash/current/multiline.html>)
     ```yaml
        input {
          file {
            path => "/var/log/someapp.log"
            codec => multiline {
              pattern => "^%{TIMESTAMP_ISO8601} " # 正则表达式
              negate => true # true or false
              what => previous # previous or next
            }
          }
        }
    ```

#### Filter插件
[patterns](<https://github.com/logstash-plugins/logstash-patterns-core/tree/master/patterns>)
#### Output插件
#### CODEC插件
                
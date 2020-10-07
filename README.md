# <center>使用Docker 部署 LNMP+Redis 环境 </center>
[![GitHub issues](https://img.shields.io/github/issues/voocel/docker-lnmp.svg)](https://github.com/voocel/docker-lnmp/issues)
[![GitHub stars](https://img.shields.io/github/stars/voocel/docker-lnmp.svg)](https://github.com/voocel/docker-lnmp/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/voocel/docker-lnmp.svg)](https://github.com/voocel/docker-lnmp/network)

### <font face="黑体">Docker 简介</font>
  Docker 是一个开源的应用容器引擎，让开发者可以打包他们的应用以及依赖包到一个可移植的容器中，然后发布到任何流行的 Linux 机器上，也可以实现虚拟化。容器是完全使用沙箱机制，相互之间不会有任何接口。推荐内核版本3.8及以上

### 为什么使用Docker

1. 加速本地的开发和构建流程，容器可以在开发环境构建，然后轻松地提交到测试环境，并最终进入生产环境
2. 能够在让独立的服务或应用程序在不同的环境中得到相同的运行结果  
3. 创建隔离的环境来进行测试  
4. 高性能、超大规划的宿主机部署  
5. 从头编译或者扩展现有的OpenShift或Cloud Foundry平台来搭建自己的PaaS环境


## 目录
* [安装Docker](#安装Docker)
* [目录结构](#目录结构)
* [快速使用](#创建镜像与安装)
* [进入容器内部](#进入容器内部)
* [PHP扩展安装](#PHP扩展安装)
* [Composer安装](#Composer安装)
* [常见问题处理](#常见问题处理)
* [常用命令](#常用命令)
* [Dockerfile语法](#Dockerfile语法)
* [docker-compose语法说明](#docker-compose语法说明)

### 安装Docker
**windows 安装**

[参考](http://www.iganlei.cn/environment-configuration/798.html)

**mac**
 
[docker toolbox参考](https://github.com/widuu/chinese_docker/blob/master/installation/mac.md) 

**linux**

```
# 下载安装
curl -sSL https://get.docker.com/ | sh

# 设置开机自启
sudo systemctl enable docker.service

sudo service docker start|restart|stop

# 安装docker-compose
curl -L https://github.com/docker/compose/releases/download/1.23.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

### 目录结构

```
docker_lnmp
├── v2
├── mysql
│   └── Dockerfile
│	└── my.cnf
├── nginx
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── log
│   │   └── error.log
│   └── www
│       ├── index.html
│       ├── index.php
│       ├── db.php
│       └── redis.php
├── php
│   ├── Dockerfile
│   ├── www.conf
│   ├── php-fpm.conf
│   ├── php.ini
│   └── log
│       └── php-fpm.log
└── redis
    └── Dockerfile
    └── redis.conf
```

### 创建镜像与安装
> 直接使用docker-compose一键制作镜像并启动容器

**版本一(v1)**

```
git clone https://github.com/voocel/docker-lnmp.git
cd docker-lnmp/v1
docker-compose up -d
```

*该版本是通过拉取纯净的CentOS镜像，通过Dockerfile相关命令进行源码编译安装各个服务。所以该方式很方便定制自己需要的镜像，但是占用空间大且构建慢。*


**当前版本(推荐)**
```
git clone https://github.com/voocel/docker-lnmp.git
cd docker-lnmp
chmod 777 ./redis/redis.log
chmod -R 777 ./redis/data
docker-compose up -d
```
*站点根目录为 docker-lnmp/www*

*该版本是通过拉取官方已经制作好的各个服务的镜像，再通过Dockerfile相关命令根据自身需求做相应的调整。所以该方式构建迅速使用方便，因为是基于Alpine Linux所以占用空间很小。*

**ELK(+filebeat)**

Elasticsearch、Logstash、Kibana、Filebeat一键搭建日志收集系统
```
cd docker-lnmp/elk
chmod +x elk.sh
./elk.sh
```
### 测试
使用docker ps查看容器启动状态,若全部正常启动了则
通过访问127.0.0.1、127.0.0.1/index.php、127.0.0.1/db.php、127.0.0.1/redis.php 即可完成测试
(若想使用https则请修改nginx下的dockerfile，和nginx.conf按提示去掉注释即可，灵需要在ssl文件夹中加入自己的证书文件，本项目自带的是空的，需要自己替换，保持文件名一致)


### 进入容器内部
1. 使用 docker exec
```
docker exec -it ngixn /bin/sh
```
2. 使用nsenter命令
```
# cd /tmp; curl https://www.kernel.org/pub/linux/utils/util-linux/v2.24/util-linux-2.24.tar.gz | tar -zxf-; cd util-linux-2.24;
# ./configure --without-ncurses
# make nsenter && sudo cp nsenter /usr/local/bin
``` 
为了连接到容器，你还需要找到容器的第一个进程的 PID，可以通过下面的命令获取再执行。
```
PID=$(docker inspect --format "{{ .State.Pid }}" container_id)
# nsenter --target $PID --mount --uts --ipc --net --pid
```

### PHP扩展安装
1. 安装PHP官方源码包里的扩展(如：同时安装pdo_mysql mysqli pcntl gd四个个扩展)

*在php的Dockerfile中加入以下命令*
```
RUN apk add libpng-dev \
    && docker-php-ext-install pdo_mysql mysqli pcntl gd \
```
*注:因为该镜像缺少gd库所需的libpng-dev包，所以需要先下载这个包*

2. PECL 扩展安装
```
# 安装扩展
RUN pecl install memcached-2.2.0 \
    # 启用扩展
    && docker-php-ext-enable memcached \
```

3. 通过下载扩展源码，编译安装的方式安装
```
# 安装Redis和swoole扩展
RUN cd ~ \
    && wget https://github.com/phpredis/phpredis/archive/5.0.2.tar.gz \
    && tar -zxvf 5.0.2.tar.gz \
    && mkdir -p /usr/src/php/ext \
    && mv phpredis-5.0.2 /usr/src/php/ext/redis \
    && docker-php-ext-install redis \

    && apk add libstdc++\
    && cd ~ \
    && wget https://github.com/swoole/swoole-src/archive/v4.4.2.tar.gz \
    && tar -zxvf v4.4.2.tar.gz \
    && mkdir -p /usr/src/php/ext \
    && mv swoole-src-4.4.2 /usr/src/php/ext/swoole \
    && docker-php-ext-install swoole \
```
*注:因为该镜像需要先安装swoole依赖的libstdc++，否则安装成功后无法正常加载swoole扩展*

### Composer安装
在Dockerfile中加入
```bash
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
```

## 常见问题处理
* redis启动失败问题
在v2版本中redis的启动用户为redis不是root,所以在宿主机中挂载的./redis/redis.log和./redis/data需要有写入权限。

	```
	   chmod 777 ./redis/redis.log
	   chmod 777 ./redis/data
	```
* MYSQL连接失败问题
在v2版本中是最新的MySQL8,而该版本的密码认证方式为Caching_sha2_password,而低版本的php和mysql可视化工具可能不支持,可通过phpinfo里的mysqlnd的Loaded plugins查看是否支持该认证方式,否则需要修改为原来的认证方式mysql_native_password:
select user,host,plugin,authentication_string from mysql.user;
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
FLUSH PRIVILEGES;

* 注意挂载目录的权限问题，不然容器成功启动几秒后立刻关闭，例：以下/data/run/mysql 目录没权限的情况下就会出现刚才那种情况
		```
		docker run --name mysql57 -d -p 3306:3306 -v /data/mysql:/var/lib/mysql -v /data/logs/mysql:/var/log/mysql -v /data/run/mysql:/var/run/mysqld -e MYSQL_ROOT_PASSWORD=123456 -it centos/mysql:v5.7
		```

* 需要注意php.ini 中的目录对应  mysql 的配置的目录需要挂载才能获取文件内容，不然php连接mysql失败

		```
		# php.ini
		mysql.default_socket = /data/run/mysql/mysqld.sock
		mysqli.default_socket = /data/run/mysql/mysqld.sock
		pdo_mysql.default_socket = /data/run/mysql/mysqld.sock
		
		# mysqld.cnf
		pid-file       = /var/run/mysqld/mysqld.pid
		socket         = /var/run/mysqld/mysqld.sock
		
		```

* 使用php连接不上redis 
	```
	# 错误的
	$redis = new Redis;
	$rs = $redis->connect('127.0.0.1', 6379);
	
	```
	
	php连接不上，查看错误日志
	```
	PHP Fatal error:  Uncaught RedisException: Redis server went away in /www/index.php:7
	```
	考虑到docker 之间的通信应该不可以用127.0.0.1 应该使用容器里面的ip，所以查看redis 容器的ip
	```
    [root@localhost docker]# docker ps
    CONTAINER ID        IMAGE                                COMMAND                  CREATED             STATUS              PORTS                                      NAMES
    b5f7dcecff4c        docker_nginx                         "/usr/sbin/nginx -..."   4 seconds ago       Up 3 seconds        0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   nginx
    60fd2df36d0e        docker_php                           "/usr/local/php/sb..."   7 seconds ago       Up 5 seconds        9000/tcp                                   php
    7c7df6f8eb91        hub.c.163.com/library/mysql:latest   "docker-entrypoint..."   12 seconds ago      Up 11 seconds       3306/tcp                                   mysql
    a0ebd39f0f64        docker_redis                         "usr/local/redis/s..."   13 seconds ago      Up 12 seconds       6379/tcp                                   redis
	```
	注意测试的时候连接地址需要容器的ip或者容器名names，比如redis、mysql.
	例如nginx配置php文件解析 fastcgi_pass   php:9000;
	例如php连接redis $redis = new Redis;$res = $redis->connect('redis', 6379);
	
	*因为容器ip是动态的，重启之后就会变化，所以可以创建静态ip*

	第一步：创建自定义网络
	```
	#备注：这里选取了172.172.0.0网段，也可以指定其他任意空闲的网段
	docker network create --subnet=172.171.0.0/16 docker-at
	docker run --name redis326 --net docker-at --ip 172.171.0.20 -d -p 6379:6379  -v /data:/data -it centos/redis:v3.2.6
	```
	
	连接redis 就可以配置对应的ip地址了，连接成功
	```
	$redis = new Redis;
	$rs = $redis->connect('172.171.0.20', 6379);
	```
	另外还有种可能phpredis连接不上redis，需要把redis.conf配置略作修改。
	```
	bind 127.0.0.1
	改为：
	bind 0.0.0.0
	```
* 启动docker web服务时 虚拟机端口转发 外部无法访问 一般出现在yum update的时候（WARNING: IPv4 forwarding is disabled. Networking will not work.）或者宿主机可以访问，但外部无法访问
```
vi /etc/sysctl.conf
或者
vi /usr/lib/sysctl.d/00-system.conf
添加如下代码：
    net.ipv4.ip_forward=1

重启network服务
systemctl restart network

查看是否修改成功
sysctl net.ipv4.ip_forward

如果返回为"net.ipv4.ip_forward = 1"则表示成功了
```
* 如果使用最新的MySQL8无法正常连接，由于最新版本的密码加密方式改变，导致无法远程连接。
```
# 修改密码加密方式
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
```


### 常用命令
* `docker start` 容器名（容器ID也可以）
* `docker stop` 容器名（容器ID也可以）
* `docker run` 命令加 -d 参数，docker 会将容器放到后台运行
* `docker ps` 正在运行的容器
* `docker logs` --tail 10 -tf 容器名    查看容器的日志文件,加-t是加上时间戳，f是跟踪某个容器的最新日志而不必读整个日志文件
* `docker top` 容器名 查看容器内部运行的进程
* `docker exec -d` 容器名 touch /etc/new_config_file  通过后台命令创建一个空文件
* `docker run --restart=always --name` 容器名 -d ubuntu /bin/sh -c "while true;do echo hello world; sleep 1; done" 无论退出代码是什么，docker都会自动重启容器，可以设置 --restart=on-failure:5 自动重启的次数
* `docker inspect` 容器名   对容器进行详细的检查，可以加 --format='{(.State.Running)}' 来获取指定的信息
* `docker rm` 容器ID  删除容器，注，运行中的容器无法删除
* `docker rm $(docker ps -aq)` 删除所有容器
* `docker rmi $(docker images -aq)` 删除所有镜像
* `docker rmi $(docker images -f "dangling=true" -q)` 删除`<none>:<none>`空悬镜像
* `docker images` 列出镜像
* `docker pull` 镜像名:标签 拉镜像
* `docker search`  查找docker Hub 上公共的可用镜像 
* `docker build -t='AT/web_server:v1'`  命令后面可以直接加上github仓库的要目录下存在的Dockerfile文件。 命令是编写Dockerfile 之后使用的。-t选项为新镜像设置了仓库和名称:标签
* `docker login`  登陆到Docker Hub，个人认证信息将会保存到$HOME/.dockercfg, 
* `docker commit -m="comment " --author="AT" ` 容器ID 镜像的用户名/仓库名:标签 不推荐这种方法，推荐dockerfile
* `docker history` 镜像ID 深入探求镜像是如何构建出来的
* `docker port` 镜像ID 端口    查看映射情况的容器的ID和容器的端口号，假设查询80端口对应的映射的端口
* `run` 运行一个容器，  -p 8080:80  将容器内的80端口映射到docker宿主机的某一特定端口，将容器的80端口绑定到宿主机的8080端口，另 127.0.0.1:80:80 是将容器的80端口绑定到宿主机这个IP的80端口上，-P 是将容器内的80端口对本地的宿主机公开
* http://docs.docker.com/reference/builder/ 查看更多的命令
* `docker push` 镜像名 将镜像推送到 Docker Hub
* `docker rmi` 镜像名  删除镜像
* `docker attach` 容器ID   进入容器
* ############################################################
* `docker network create --subnet=172.171.0.0/16 docker-at` 选取172.172.0.0网段
* `docker build` 就可以加 -ip指定容器ip 172.171.0.10 了

**删除所有容器和镜像的命令**

```
docker rm `docker ps -a |awk '{print $1}' | grep [0-9a-z]` 删除停止的容器
docker rmi $(docker images | awk '/^<none>/ { print $3 }')
```


### Dockerfile语法

* `MAINTAINER`  标识镜像的作者和联系方式
* `EXPOSE` 可以指定多个EXPOSE向外部公开多个端口，可以帮助多个容器链接
* `FROM`  指令指定一个已经存在的镜像
* `\#`号代表注释
* `RUN` 运行命令,会在shell 里使用命令包装器 /bin/sh -c 来执行。如果是在一个不支持shell 的平台上运行或者不希望在shell 中运行，也可以 使用exec 格式 的RUN指令
* `ENV REFRESHED_AT` 环境变量 这个环境亦是用来表明镜像模板最后的更新时间
* `VOLUME` 容器添加卷。一个卷是可以 存在于一个或多个容器内的特定的目录，对卷的修改是立刻生效的，对卷的修改不会对更新镜像产品影响，例:VOLUME["/opt/project","/data"]
* `ADD` 将构建环境 下的文件 和目录复制到镜像 中。例 ADD nginx.conf /conf/nginx.conf 也可以是取url 的地址文件，如果是压缩包，ADD命令会自动解压、
* `USER` 指定镜像用那个USER 去运行
* `COPY` 是复制本地文件，而不会去做文件提取（解压包不会自动解压） 例：COPY conf.d/ /etc/apache2/  将本地conf.d目录中的文件复制到/etc/apache2/目录中

### docker-compose.yml 语法说明
* `image` 指定为镜像名称或镜像ID。如果镜像不存在，Compose将尝试从互联网拉取这个镜像
* `build` 指定Dockerfile所在文件夹的路径。Compose将会利用他自动构建这个镜像，然后使用这个镜像
* `command` 覆盖容器启动后默认执行的命令
* `links` 链接到其他服务容器，使用服务名称(同时作为别名)或服务别名（SERVICE:ALIAS）都可以
* `external_links` 链接到docker-compose.yml外部的容器，甚至并非是Compose管理的容器。参数格式和links类似
* `ports` 暴露端口信息。宿主机器端口：容器端口（HOST:CONTAINER）格式或者仅仅指定容器的端口（宿主机器将会随机分配端口）都可以(注意：当使用 HOST:CONTAINER 格式来映射端口时，如果你使用的容器端口小于 60 你可能会得到错误得结果，因为 YAML 将会解析 xx:yy 这种数字格式为 60 进制。所以建议采用字符串格式。)
* `expose` 暴露端口，与posts不同的是expose只可以暴露端口而不能映射到主机，只供外部服务连接使用；仅可以指定内部端口为参数
* `volumes` 设置卷挂载的路径。可以设置宿主机路径:容器路径（host:container）或加上访问模式（host:container:ro）ro就是readonly的意思，只读模式
* `volunes_from` 挂载另一个服务或容器的所有数据卷
* `environment` 设置环境变量。可以属于数组或字典两种格式。如果只给定变量的名称则会自动加载它在Compose主机上的值，可以用来防止泄露不必要的数据
* `env_file`  从文件中获取环境变量，可以为单独的文件路径或列表。如果通过docker-compose -f FILE指定了模板文件，则env_file中路径会基于模板文件路径。如果有变量名称与environment指令冲突，则以后者为准(环境变量文件中每一行都必须有注释，支持#开头的注释行)
* `extends` 基于已有的服务进行服务扩展。例如我们已经有了一个webapp服务，模板文件为common.yml。编写一个新的 development.yml 文件，使用 common.yml 中的 webapp 服务进行扩展。后者会自动继承common.yml中的webapp服务及相关的环境变量
* `net` 设置网络模式。使用和docker client 的 --net 参数一样的值
* `pid` 和宿主机系统共享进程命名空间，打开该选项的容器可以相互通过进程id来访问和操作
* `dns` 配置DNS服务器。可以是一个值，也可以是一个列表
* `cap_add，cap_drop` 添加或放弃容器的Linux能力（Capability）
* `dns_search` 配置DNS搜索域。可以是一个值也可以是一个列表
* 注意：使用compose对Docker容器进行编排管理时，需要编写docker-compose.yml文件，初次编写时，容易遇到一些比较低级的问题，导致执行docker-compose up时先解析yml文件的错误。比较常见的是yml对缩进的严格要求。yml文件还行后的缩进，不允许使用tab键字符，只能使用空格，而空格的数量也有要求，一般两个空格。

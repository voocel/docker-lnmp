# <center>使用Dockerfile 部署 Lnmp+Redis 环境 </center>
[![GitHub issues](https://img.shields.io/github/issues/voocel/docker-lnmp.svg)](https://github.com/voocel/docker-lnmp/issues)
[![GitHub forks](https://img.shields.io/github/forks/voocel/docker-lnmp.svg)](https://github.com/voocel/docker-lnmp/network)
[![GitHub stars](https://img.shields.io/github/stars/voocel/docker-lnmp.svg)](https://github.com/voocel/docker-lnmp/stargazers)

### <font face="黑体">Docker 简介</font>
  Docker 是一个开源的应用容器引擎，让开发者可以打包他们的应用以及依赖包到一个可移植的容器中，然后发布到任何流行的 Linux 机器上，也可以实现虚拟化。容器是完全使用沙箱机制，相互之间不会有任何接口。推荐内核版本3.8及以上

### 为什么使用Docker

1. 加速本地的开发和构建流程，容器可以在开发环境构建，然后轻松地提交到测试环境，并最终进入生产环境
2. 能够在让独立的服务或应用程序在不同的环境中得到相同的运行结果  
3. 创建隔离的环境来进行测试  
4. 高性能、超大规划的宿主机部署  
5. 从头编译或者扩展现有的OpenShift或Cloud Foundry平台来搭建自己的PaaS环境


### 各环境安装Docker
**windows 安装**

[参考](http://www.iganlei.cn/environment-configuration/798.html)

**mac**
 
[docker toolbox参考](https://github.com/widuu/chinese_docker/blob/master/installation/mac.md) 

**linux**

```
sudo yum update
sudo yum -y install docker(下载的版本过低，在Ubuntu下可能会出现问题，不推荐)
或者 curl -sSL https://get.docker.com/ | sh  通过官方脚本获取安装最新版本(推荐)
#安装程序将docker程序安装到/usr/bin⺫⽬目录下，配置⽂文件安装在/etc/sysconfig/docker。安装好docker之后，可以 将docker加⼊入到启动服务组中 
sudo systemctl enable docker.service
#手动启动docker服务器，使⽤用命令 sudo systemctl start docker.service

curl -L https://github.com/docker/compose/releases/download/1.15.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
#安装docker-compose
```

目录结构 

```
docker_lnmp
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
**方法一、 直接使用docker-compose一键制作镜像并运行容器（推荐）**

    ```
	git clone https://github.com/voocel/docker-lnmp.git
	cd docker-lnmp
	docker-compose up -d
    ```
	然后就可以通过访问127.0.0.1、127.0.0.1/index.php、127.0.0.1/db.php、127.0.0.1/redis.php 测试了
	(若想使用https则请修改nginx下的dockerfile，和nginx.conf按提示去掉注释即可，灵需要在ssl文件夹中加入自己的证书文件，本项目自带的是空的，需要自己替换，保持文件名一致)
**方法二、 逐步build并run**

    ```
    # build
    docker build -t centos/nginx:v1.11.5 -v /www:/www -v /data:/data  ./nginx
    docker build -t centos/mysql:v5.7 -v /data/mysql:/var/lib/mysql -v /data/logs/mysql:/var/log/mysql  ./mysql
    docker build -t centos/php:v7.0.12 -v /www:/www -v /data:/data  ./php
    docker build -t centos/redis:v3.2.6 -v /data:/data  ./redis

    #备注：这里选取了172.172.0.0网段，也可以指定其他任意空闲的网段
    docker network create --subnet=172.171.0.0/16 docker-at

    # run
    docker run --name mysql57 --net docker-at --ip 172.171.0.9 -d -p 3306:3306 -v /data/mysql:/var/lib/mysql -v /data/logs/mysql:/var/log/mysql -v /data/run/mysqlmysqld:/var/run/mysqld  -e MYSQL_ROOT_PASSWORD=123456 -it centos/mysql:v5.7
    docker run --name redis326 --net docker-at --ip 172.171.0.10 -d -p 6379:6379  -v /data:/data -it centos/redis:v3.2.6
    docker run --name php7 --net docker-at --ip 172.171.0.8 -d -p 9000:9000 -v /www:/www -v /data:/data --link mysql57:mysql57 --link redis326:redis326 -it centos/php:v7.0.12 
    docker run --name nginx11 --net docker-at --ip 172.171.0.7 -p 80:80 -d -v /www:/www -v /data:/data --link php7:php7 -it centos/nginx:v1.11.5 
    ```


### 常用命令
* docker start 容器名（容器ID也可以）
* docker stop 容器名（容器ID也可以）
* docker run 命令加 -d 参数，docker 会将容器放到后台运行
* docker ps 正在运行的容器
* docker logs --tail 10 -tf 容器名    查看容器的日志文件,加-t是加上时间戳，f是跟踪某个容器的最新日志而不必读整个日志文件
* docker top 容器名 查看容器内部运行的进程
* docker exec -d 容器名 touch /etc/new_config_file  通过后台命令创建一个空文件
* docker run --restart=always --name 容器名 -d ubuntu /bin/sh -c "while true;do echo hello world; sleep 1; done" 无论退出代码是什么，docker都会自动重启容器，可以设置 --restart=on-failure:5 自动重启的次数
* docker inspect 容器名   对容器进行详细的检查，可以加 --format='{(.State.Running)}' 来获取指定的信息
* docker rm 容器ID  删除容器，注，运行中的容器无法删除
* docker rm `docker ps -a -q` 这样可以删除所有的容器
* docker images 列出镜像
* docker pull 镜像名:标签 拉镜像
* docker search  查找docker Hub 上公共的可用镜像 
* docker build -t='AT/web_server:v1'  命令后面可以直接加上github仓库的要目录下存在的Dockerfile文件。 命令是编写Dockerfile 之后使用的。-t选项为新镜像设置了仓库和名称:标签
* docker login  登陆到Docker Hub，个人认证信息将会保存到$HOME/.dockercfg, 
* docker commit -m="comment " --author="AT"  容器ID 镜像的用户名/仓库名:标签 不推荐这种方法，推荐dockerfile
* docker history 镜像ID 深入探求镜像是如何构建出来的
* docker port 镜像ID 端口    查看映射情况的容器的ID和容器的端口号，假设查询80端口对应的映射的端口
* run 运行一个容器，  -p 8080:80  将容器内的80端口映射到docker宿主机的某一特定端口，将容器的80端口绑定到宿主机的8080端口，另 127.0.0.1:80:80 是将容器的80端口绑定到宿主机这个IP的80端口上，-P 是将容器内的80端口对本地的宿主机公开
* http://docs.docker.com/reference/builder/ 查看更多的命令
* docker push 镜像名 将镜像推送到 Docker Hub
* docker rmi 镜像名  删除镜像
* docker attach 容器ID   进入容器
* ############################################################
* docker network create --subnet=172.171.0.0/16 docker-at 选取172.172.0.0网段
* docker build 就可以加 -ip指定容器ip 172.171.0.10 了
**删除所有容器和镜像的命令**

```
docker rm `docker ps -a |awk '{print $1}' | grep [0-9a-z]` 删除停止的容器
docker rmi $(docker images | awk '/^<none>/ { print $3 }')
```

**进入容器的命令**

1. nsenter 命令需要安装
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

### dockerfile 语法

* MAINTAINER  标识镜像的作者和联系方式
* EXPOSE 可以指定多个EXPOSE向外部公开多个端口，可以帮助多个容器链接
* FROM   指令指定一个已经存在的镜像
* \#号代表注释
* RUN 运行命令,会在shell 里使用命令包装器 /bin/sh -c 来执行。如果是在一个不支持shell 的平台上运行或者不希望在shell 中运行，也可以 使用exec 格式 的RUN指令
* ENV REFRESHED_AT 环境变量 这个环境亦是用来表明镜像模板最后的更新时间
* VOLUME 容器添加卷。一个卷是可以 存在于一个或多个容器内的特定的目录，对卷的修改是立刻生效的，对卷的修改不会对更新镜像产品影响，例:VOLUME["/opt/project","/data"]
* ADD 将构建环境 下的文件 和目录复制到镜像 中。例 ADD nginx.conf /conf/nginx.conf 也可以是取url 的地址文件，如果是压缩包，ADD命令会自动解压、
* USER 指定镜像用那个USER 去运行
* COPY 是复制本地文件，而不会去做文件提取（解压包不会自动解压） 例：COPY conf.d/ /etc/apache2/  将本地conf.d目录中的文件复制到/etc/apache2/目录中

### docker-compose.yml 语法说明
* image 指定为镜像名称或镜像ID。如果镜像不存在，Compose将尝试从互联网拉取这个镜像
* build 指定Dockerfile所在文件夹的路径。Compose将会利用他自动构建这个镜像，然后使用这个镜像
* command 覆盖容器启动后默认执行的命令
* links 链接到其他服务容器，使用服务名称(同时作为别名)或服务别名（SERVICE:ALIAS）都可以
* external_links 链接到docker-compose.yml外部的容器，甚至并非是Compose管理的容器。参数格式和links类似
* ports 暴露端口信息。宿主机器端口：容器端口（HOST:CONTAINER）格式或者仅仅指定容器的端口（宿主机器将会随机分配端口）都可以(注意：当使用 HOST:CONTAINER 格式来映射端口时，如果你使用的容器端口小于 60 你可能会得到错误得结果，因为 YAML 将会解析 xx:yy 这种数字格式为 60 进制。所以建议采用字符串格式。)
* expose 暴露端口，与posts不同的是expose只可以暴露端口而不能映射到主机，只供外部服务连接使用；仅可以指定内部端口为参数
* volumes 设置卷挂载的路径。可以设置宿主机路径:容器路径（host:container）或加上访问模式（host:container:ro）ro就是readonly的意思，只读模式
* volunes_from 挂载另一个服务或容器的所有数据卷
* environment 设置环境变量。可以属于数组或字典两种格式。如果只给定变量的名称则会自动加载它在Compose主机上的值，可以用来防止泄露不必要的数据
* env_file  从文件中获取环境变量，可以为单独的文件路径或列表。如果通过docker-compose -f FILE指定了模板文件，则env_file中路径会基于模板文件路径。如果有变量名称与environment指令冲突，则以后者为准(环境变量文件中每一行都必须有注释，支持#开头的注释行)
* extends 基于已有的服务进行服务扩展。例如我们已经有了一个webapp服务，模板文件为common.yml。编写一个新的 development.yml 文件，使用 common.yml 中的 webapp 服务进行扩展。后者会自动继承common.yml中的webapp服务及相关的环境变量
* net 设置网络模式。使用和docker client 的 --net 参数一样的值
* pid 和宿主机系统共享进程命名空间，打开该选项的容器可以相互通过进程id来访问和操作
* dns 配置DNS服务器。可以是一个值，也可以是一个列表
* cap_add，cap_drop 添加或放弃容器的Linux能力（Capability）
* dns_search 配置DNS搜索域。可以是一个值也可以是一个列表
* 注意：使用compose对Docker容器进行编排管理时，需要编写docker-compose.yml文件，初次编写时，容易遇到一些比较低级的问题，导致执行docker-compose up时先解析yml文件的错误。比较常见的是yml对缩进的严格要求。yml文件还行后的缩进，不允许使用tab键字符，只能使用空格，而空格的数量也有要求，一般两个空格。

## 常见问题处理
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
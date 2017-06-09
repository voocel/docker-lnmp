# 拉取 CentOS
FROM daocloud.io/centos:latest

# 维护者
MAINTAINER leepin <admin@cxsir.com>

# 设置 Redis 版本
ENV REDIS_VERSION 3.2.5

# 下载并编译
RUN set -x \
  && yum update -y \
  && yum install -y wget gcc gcc-c++ make perl tar \
  && cd /opt \
  && wget http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz \
  && tar -zxvf redis-$REDIS_VERSION.tar.gz \
  && rm -f redis-$REDIS_VERSION.tar.gz \
  && mv redis-$REDIS_VERSION redis \
  && cd redis \
  && make

CMD ["/opt/redis/src/redis-server","/usr/share/nginx/html/redis.conf"]

EXPOSE 6379

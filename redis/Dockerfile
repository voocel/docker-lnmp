# 拉取 CentOS
FROM hub.c.163.com/library/centos:latest

# 维护者
MAINTAINER voocel <voocel@gmail.com>

# 设置 Redis 版本
ENV REDIS_VERSION 3.2.9

# 下载并编译
RUN set -x \
  && yum update -y \
  && yum install -y wget gcc gcc-c++ make perl tar \
  && cd /opt \
  && wget http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz \

  && tar -zxf redis-$REDIS_VERSION.tar.gz -C /usr/local \
  && rm -f redis-$REDIS_VERSION.tar.gz \
  && cd /usr/local \
  && mv redis-$REDIS_VERSION redis \

  && cd /usr/local/redis \
  && make \
  && make -C /usr/local/redis/src install \
  && mkdir /usr/local/redis/data \

  && yum clean all

CMD ["usr/local/redis/src/redis-server","/usr/local/redis/redis.conf"]

EXPOSE 6379

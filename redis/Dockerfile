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
  && tar -zxvf redis-$REDIS_VERSION.tar.gz \
  && rm -f redis-$REDIS_VERSION.tar.gz \
  && mv redis-$REDIS_VERSION redis \
  && cd redis \
  && make \
  && make install \
  && mkdir /usr/local/redis \
  && cp -rf ./src/redis-cli ./src/redis-server ./redis.conf /usr/local/redis \
  && yum clean all

CMD ["usr/local/redis/redis-server","/usr/local/redis/redis.conf"]

EXPOSE 6379

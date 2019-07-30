# 拉取 CentOS
FROM hub.c.163.com/library/centos:latest

# 维护者
MAINTAINER voocel <voocel@gmail.com>

# 设置 openssl 和 nginx 版本
ENV NGINX_VERSION 1.17.2

# 安装依赖
RUN set -x \
  && yum update -y \
  && yum install -y wget gcc gcc-c++ make automake autoconf libtool libxml2-devel libxslt-devel perl-devel perl-ExtUtils-Embed pcre-devel perl file tar bzip2-devel bzip2 openssl openssl-devel zlib zlib-devel \

  # 创建下载目录
  && mkdir ~/download \
  
  # 下载 openssl
  && cd ~/download \

  # 下载 nginx
  && wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
  && tar -zxvf nginx-$NGINX_VERSION.tar.gz \
  && cd nginx-$NGINX_VERSION \
  && mkdir -p /var/cache/nginx \
  && groupadd nginx \
  && useradd -r -g nginx nginx \
  && ./configure \
    --prefix=/usr/local/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --sbin-path=/usr/sbin/nginx \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-pcre \
    --with-http_v2_module \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-http_v2_module \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
  && make \
  && make install \
  && rm -rf ~/download \
  && yum clean all

# 若要使用https，请将以下三个注释去掉,并在ssl文件夹中添加你自己申请的两个证书文件
#  && mkdir -p /etc/nginx/cert
#COPY ssl/nginx.pem /etc/nginx/cert/nginx.pem
#COPY ssl/nginx.key /etc/nginx/cert/nginx.key

CMD ["/usr/sbin/nginx","-g","daemon off;"]

EXPOSE 80 443

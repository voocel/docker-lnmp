当前默认的xpack配置为Trial版30天使用,密码在docker-compose的es主节点配置的
若想要开启集群内部安全通信ssl CA认证则将es的几个yml文件的xpack注释打开,同时将trial版配置注释掉
然后进入master节点

创建证书: bin/elasticsearch-certutil cert -out config/elastic-certificates.p12 -pass ""

创建证书目录: mkdir config/certs

mv config/elastic-*.p12 config/certs/

chown -R elasticsearch:root config/certs/

再把证书文件 certs 复制到其他节点并赋予权限。

重启 elasticsearch

重置密码: bin/elasticsearch-setup-passwords interactive

注意: filebeat.yml权限

重置密码: `docker-compose exec -T elasticsearch bin/elasticsearch-setup-passwords auto --batch`
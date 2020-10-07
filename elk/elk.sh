#./bin/bash
# 定义颜色
BLUE_COLOR="\033[36m"
RED_COLOR="\033[31m"
GREEN_COLOR="\033[32m"
VIOLET_COLOR="\033[35m"
RES="\033[0m"

echo -e "${BLUE_COLOR}# ######################################################################${RES}"
echo -e "${BLUE_COLOR}#                       Docker ELK Shell Script                        #${RES}"
echo -e "${BLUE_COLOR}#                       Blog: www.voocel.com                           #${RES}"
echo -e "${BLUE_COLOR}#                       Email: voocel@gmail.com                        #${RES}"
echo -e "${BLUE_COLOR}# ######################################################################${RES}"

if [ "$(free -g|awk '/^Mem/{print $2-$3}')" -le 4 ];then
   echo "可用内存小于4g，退出！"
   exit
fi

#优化系统
#if [ -z "$(grep vm.max_map_count /etc/sysctl.conf)" ];then
#    echo 'vm.max_map_count=655360' >>/etc/sysctl.conf
#else
#    sed -i 's/vm.max_map_count.*/vm.max_map_count=655360/g' /etc/sysctl.conf
#fi
#sysctl -p

# 创建目录
echo -e "${BLUE_COLOR}---> create [elasticsearch]directory start.${RES}"
if [ ! -d "./elasticsearch/" ]; then
mkdir -p ./elasticsearch/master/conf ./elasticsearch/master/data ./elasticsearch/master/logs \
    ./elasticsearch/slave1/conf ./elasticsearch/slave1/data ./elasticsearch/slave1/logs \
    ./elasticsearch/slave2/conf ./elasticsearch/slave2/data ./elasticsearch/slave2/logs
fi
if [ ! -d "./escerts/" ]; then
mkdir ./escerts
fi
if [ ! -d "./logs/" ]; then
mkdir ./logs
fi

echo -e "${RED_COLOR}---> create [kibana]directory start.${RES}"
if [ ! -d "./kibana/" ]; then
mkdir -p ./kibana/conf ./kibana/logs
fi

 echo -e "${GREEN_COLOR}---> create [logstash]directory start.${RES}"
 if [ ! -d "./logstash/" ]; then
 mkdir -p ./logstash/conf ./logstash/logs
 fi

echo -e "${GREEN_COLOR}---> create [filebeat]directory start.${RES}"
if [ ! -d "./filebeat/" ]; then
mkdir -p ./filebeat/conf ./filebeat/logs ./filebeat/data
fi

echo -e "${VIOLET_COLOR}---> create [nginx]directory start.${RES}"
if [ ! -d "./nginx/" ]; then
mkdir -p ./nginx/conf ./nginx/logs ./nginx/www
fi
echo -e "${BLUE_COLOR}===> create directory success.${RES}"

# 目录授权(data/logs 都要授读/写权限)
echo -e "${BLUE_COLOR}---> directory authorize start.${RES}"
if [ -d "./elasticsearch/" ]; then
chmod 777 ./elasticsearch/master/data/ ./elasticsearch/master/logs/ \
    ./elasticsearch/slave1/data/ ./elasticsearch/slave1/logs/ \
    ./elasticsearch/slave2/data/ ./elasticsearch/slave2/logs
fi
if [ -d "./escerts/" ]; then
chmod 777 ./escerts
fi

if [ -d "./filebeat/" ]; then
chmod 777 ./filebeat/data/ ./filebeat/logs/
fi
echo -e "${BLUE_COLOR}===> directory authorize success.${RES}"

# 移动配置文件
echo -e "${BLUE_COLOR}---> move [elasticsearch]config file start.${RES}"
if [ -f "./es-master.yml" ] && [ -f "./es-slave1.yml" ] && [ -f "./es-slave2.yml" ]; then
mv ./es-master.yml ./elasticsearch/master/conf
mv ./es-slave1.yml ./elasticsearch/slave1/conf
mv ./es-slave2.yml ./elasticsearch/slave2/conf
fi

echo -e "${RED_COLOR}---> move [kibana]config file start.${RES}"
if [ -f "./kibana.yml" ]; then
mv ./kibana.yml ./kibana/conf
fi

 echo -e "${GREEN_COLOR}---> move [logstash]config file start.${RES}"
 if [ -f "./logstash-filebeat.conf" ]; then
 mv ./logstash-filebeat.conf ./logstash/conf
 fi
 if [ -f "./logstash.yml" ]; then
 mv ./logstash.yml ./logstash/conf
 chmod 777 ./logstash/conf/logstash.yml ./logstash/logs
 fi

echo -e "${GREEN_COLOR}---> move [filebeat]config file start.${RES}"
if [ -f "./filebeat.yml" ]; then
mv ./filebeat.yml ./filebeat/conf
chown root:root filebeat.yml
chmod 644 ./filebeat/filebeat.yml
fi

echo -e "${VIOLET_COLOR}---> move [nginx]config file start.${RES}"
if [ -f "./nginx.conf" ]; then
mv ./nginx.conf ./nginx/conf
fi
echo -e "${BLUE_COLOR}===> move config files success.${RES}"
echo -e "${GREEN_COLOR}>>>>>>>>>>>>>>>>>> The End <<<<<<<<<<<<<<<<<<${RES}"

# 部署项目
echo -e "${BLUE_COLOR}==================> Docker deploy Start <==================${RES}"
docker-compose up --build -d
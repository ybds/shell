#!/bin/bash
# author:LiZhenHua
# Date:2019-11-20

set -x
Host=zabbix-agent
ServerActive=10.0.1.200
USER=zabbix
ZABBIX=/usr/local/src/zabbix-4.0.3.tar.gz

yum install -y gcc gcc-c++ make pcre-devel

egrep "^$USER" /etc/group >& /dev/null

if [ $? -gt 0 ];then
	useradd -s /sbin/nologin zabbix
fi

if [ ! -f "$ZABBIX" ];then
	echo "文件$ZABBIX不存在，等待下载... ..."
	sleep 3
	cd /usr/local/src/
	wget 'https://nchc.dl.sourceforge.net/project/zabbix/ZABBIX%20Latest%20Stable/4.0.3/zabbix-4.0.3.tar.gz'
else
	sleep 5
	cd /usr/local/src/
	tar -zxvf zabbix-4.0.3.tar.gz
	cd zabbix-4.0.3
	./configure --prefix=/usr/local/zabbix --enable-agent
	make && make install
	echo "$ZABBIX已经安装成功！"
	sleep 3
	chown zabbix:zabbix -R /usr/local/zabbix/
fi

echo "PATH=\$PATH:/usr/local/zabbix/sbin/:/usr/local/zabbix/bin/">>/etc/profile;`source /etc/profile`
sed -i "s/^# PidFile=.*/PidFile=\/usr\/local\/zabbix\/zabbix_agentd.pid/g" /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i "s/^LogFile=.*/LogFile=\/usr\/local\/zabbix\/zabbix_agentd.log/g" /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i "s/^Hostname=.*/Hostname=$Host/g" /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i "s/^Server=.*/Server=$ServerActive/g" /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i "s/^ServerActive=.*/ServerActive=$ServerActive/g" /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i "s/^# StartAgents=.*/StartAgents=0/g" /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i "s/^# HostMetadata=/HostMetadata=JD_Linux/g" /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i "s/^# UnsafeUserParameters=.*/UnsafeUserParameters=1/g" /usr/local/zabbix/etc/zabbix_agentd.conf
sed -i "267i Include=/usr/local/zabbix/etc/zabbix_agentd.conf.d/*.conf" /usr/local/zabbix/etc/zabbix_agentd.conf
# /usr/local/zabbix/sbin/zabbix_agentd
cp /usr/local/src/zabbix-4.0.3/misc/init.d/fedora/core/* /etc/rc.d/init.d/
sed -i "s/BASEDIR=.*/&\/zabbix/g" /etc/init.d/zabbix_agentd

touch /usr/local/zabbix/etc/zabbix_agentd.conf.d/UserParameter.conf
cat>/usr/local/zabbix/etc/zabbix_agentd.conf.d/UserParameter.conf<<EOF
UserParameter=Mem_pre,free -m|awk '/^Mem/{print \$3*100/\$2}'
EOF

/etc/init.d/zabbix_agentd start
chkconfig zabbix_agentd on

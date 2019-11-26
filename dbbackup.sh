#!/bin/bash
# author:LiZhenHua
# date:2019-11-26

date=`date +%Y%m%d%H%M%S`
/usr/bin/mysqldump  -uroot web1>/backup/web1$date.data.sql
/usr/bin/mysqldump  -uroot web2>/backup/web2$date.data.sql
/usr/bin/mysqldump  -uroot web3>/backup/web3$date.data.sql

zip -q -m web_$date.zip web1$date.data.sql web2$date.data.sql web3$date.data.sql

find /backup/ -mtime 3 -name "*.zip" -exec rm -rf {} \;

scp /backup/web_$date.zip backup@192.168.0.100:/dbbackup/web/

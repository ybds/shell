#!/bin/bash
#author:LiZhenHua
#date:2019-09-29

find /var/logs/ -mtime 1 -name "*.log" -exec rm -rf {} \;

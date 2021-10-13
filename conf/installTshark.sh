#!/bin/bash

# 引入函数
. ./yum/software.sh

# Check if user is root 
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

DIR=`pwd`

printf "开始安装tshark分析工具，请耐心等待。\n"

Yum_Start

# 安装编译前环境
Yum_list='wireshark lrzsz'
for Install_yum in $Yum_list; do
	yum install -y $Install_yum 1>/dev/null
	[ $? == 1 ] && printf "\n$Install_yum Installation dependency failed.\n$Install_yum 安装失败，请寻求技术支持。\n已退出安装\n" && exit 1 
done

Yum_End

printf "tshark分析工具已完成安装。\n"


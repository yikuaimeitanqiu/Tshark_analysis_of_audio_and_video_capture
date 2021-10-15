#!/bin/bash

# 引入函数
. ./yum/software.sh

# Check if user is root 
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

DIR=`pwd`

printf "初次使用，需要安装wireshark分析工具。\n开始安装wireshark分析工具，请耐心等待。\n"

Yum_Start

# 安装编译环境
Yum_list='cmake3 glib2-devel libpcap libpcap-devel libgcrypt-devel qt-devel qt5-qtbase-devel qt5-linguist qt5-qtmultimedia-devel qt5-qtsvg-devel libcap-ng-devel gnutls-devel krb5-devel libxml2-devel lua-devel lz4-devel snappy-devel spandsp-devel libssh2-devel bcg729-devel libmaxminddb-devel sbc-devel libsmi-devel libnl3-devel libnghttp2-devel libssh-devel c-ares-devel redhat-rpm-config rpm-build gtk+-devel gtk3-devel desktop-file-utils portaudio-devel rubygem-asciidoctor docbook5-style-xsl docbook-style-xsl systemd-devel python34 git gcc gcc-c++ flex bison doxygen gettext-devel libxslt cmake'
for Install_yum in $Yum_list; do
#	yum install -y $Install_yum
#	printf "\n$Install_yum Installation dependency success.\n"
	yum install -y $Install_yum 1>/dev/null
	[ $? == 1 ] && printf "\n$Install_yum Installation dependency failed.\n$Install_yum 安装失败，请寻求技术支持。\n已退出安装\n" && exit 1 
done

# 安装辅助软件
Yum_list='lrzsz'
for Install_yum in $Yum_list; do
	yum install -y $Install_yum 1>/dev/null
	[ $? == 1 ] && printf "\n$Install_yum Installation dependency failed.\n$Install_yum 安装失败，请寻求技术支持。\n已退出安装\n" && exit 1 
done

printf "开始编译wireshark\n"

#编译wireshark
#wireshark源码压缩包文件名
WiresharkName=`ls -l $DIR/yum/wireshark | grep wireshark*.tar* | awk '{print $9}'` 
#进入目录，解压目录，进入目录
pushd $DIR/yum/wireshark ;tar -xvf $WiresharkName -C ./ 1>/dev/null; pushd ${WiresharkName%%.tar*} 
#编译，安装完成后，删除编译文件夹
make 1>/dev/null; make install 1>/dev/null; popd; /usr/bin/rm -rf ${WiresharkName%%.tar*};
#添加tshark环境变量
[ -e /usr/local/bin/tshark ] && ln -s /usr/local/bin/tshark /usr/sbin/tshark

Yum_End

printf "wireshark分析工具已完成安装。\n"


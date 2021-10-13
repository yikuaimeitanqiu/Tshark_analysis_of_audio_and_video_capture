#!/bin/bash

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }


Yum_Start () {
#在yum下创建backup文件夹,并将当前yum源移动至backup目录下
if [ -d /etc/yum.repos.d/backup ]; then
         mv /etc/yum.repos.d/* /etc/yum.repos.d/backup &>/dev/null
else
        mkdir /etc/yum.repos.d/backup && mv /etc/yum.repos.d/* /etc/yum.repos.d/backup &>/dev/null
fi

#获取路径,以前面脚本执行路径为准
DIR=$(pwd)

#创建临时本地源路径
echo "
[local_centos]
name=local_centos
enable=1
gpgcheck=0
baseurl=file://$DIR/yum/software
" > $DIR/yum/repo/local_centos.repo


#检测Linux系统是否为Centos 7，正确则设置临时本地源
release_centos=$(cat /etc/redhat-release | grep "CentOS Linux release 7.")
if [ "$release_centos" != "" ]; then
	if [ ! -e /etc/yum.repos.d/local_centos.repo ]; then 
		/usr/bin/cp -rf ${DIR}/yum/repo/local_centos.repo /etc/yum.repos.d
  		yum clean all &>/dev/null && yum makecache &>/dev/null
	fi
fi

#安装createrepo,更新自建的yum本地仓库
yum -y install createrepo &>/dev/null
createrepoyum=$(rpm -qa | grep "createrepo")
if [ "$createrepoyum" != "" ]; then
        createrepo -pdo $DIR/yum/software $DIR/yum/software/packages &>/dev/null
	createrepo -g $DIR/yum/software/gen/groups.xml $DIR/yum/software &>/dev/null
  	yum clean all &>/dev/null && yum makecache &>/dev/null
fi

}


Yum_End () {
#移除临时本地源
/usr/bin/rm -rf /etc/yum.repos.d/local_centos.repo 

#恢复原来安装源
/usr/bin/mv /etc/yum.repos.d/backup/* /etc/yum.repos.d/ 
/usr/bin/rmdir /etc/yum.repos.d/backup 
yum clean all &>/dev/null && yum makecache &>/dev/null
}



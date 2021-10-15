#!/bin/bash

# Check if user is root 
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

DIR=`pwd`

#判断无tshark分析工具则安装
[ ! -e /usr/local/bin/tshark ] && $DIR/yum/installSoftware.sh

#菜单
MENU () {
printf "请输入需要分析协议类型:
1. SIP
2. GB28181
3. 退出
"
}


#根据选项执行对应协议分析
MENU
read -e -p "请输入数字选择：" Number
case $Number in
	"1")
	bash $DIR/conf/sip/sipAnalyse.sh
	bash $DIR/conf/sip/sipDeriveAll.sh
	bash $DIR/conf/sip/sipReport.sh
	bash $DIR/conf/sip/sipInvite.sh
	#[ $? == 126 ] && printf "已完成分析处理，请查看 $DIR/report 下输出文件。\n" || printf "未能开始分析，已退出。\n"
	/usr/bin/rm -rf $DIR/report/sip.txt
	;;
	"2")
	bash $DIR/conf/gb28181/gb28181Analyse.sh
	GB28181REPORT_OLD=`ls -l $DIR/report | grep gb28181report_old.txt `
	[ -z "$GB28181REPORT_OLD" ] && printf "请检查 $DIR/pcap 下的文件，未能执行脚本,已退出。\n\n" && exit 126
	bash $DIR/conf/gb28181/gb28181DeriveAll.sh
	bash $DIR/conf/gb28181/gb28181Report.sh
	bash $DIR/conf/gb28181/gb28181Invite.sh
	[[ `ls -l $DIR/report/ | grep init_test.txt` ]] && printf "已完成分析处理，请查看 $DIR/report 下输出文件。\n\n" && /usr/bin/rm -rf $DIR/report/init_test.txt
	#/usr/bin/rm -rf $DIR/report/gb28181.txt
	;;
	"3")
	exit 1
	;;
	*)
	printf "请正确输入选项：1/2/3  \n"
        ;;
esac




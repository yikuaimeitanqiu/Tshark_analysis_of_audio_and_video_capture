#!/bin/bash

# Check if user is root 
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

DIR=`pwd`

#创建输出报告文件
touch $DIR/file/gb28181report.txt
cat /dev/null > $DIR/file/gb28181report.txt


#打印输入的参数
cat $DIR/file/gb28181report_old.txt > $DIR/file/gb28181report.txt
/usr/bin/rm -rf $DIR/file/gb28181report_old.txt


#打印二次分析的显示过滤器信息
Filter=`awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}' $DIR/file/Call_ID_filter.txt $DIR/file/rtp_filter.txt $DIR/file/rtcp_filter.txt`

printf "\n通过显示过滤器规则：
$Filter
过滤出 gb28181deriveall.pcap 数据报文
" >> $DIR/file/gb28181report.txt
/usr/bin/rm -rf $DIR/file/Call_ID_filter.txt
/usr/bin/rm -rf $DIR/file/rtp_filter.txt
/usr/bin/rm -rf $DIR/file/rtcp_filter.txt


#打印会话产生的Call-ID
CALL_ID_LINE=`awk 'END{print NR}' $DIR/file/Call_ID.txt`
printf "\n根据 gb28181deriveall.pcap 数据报文中分析出总共生成 $CALL_ID_LINE 次 Call-ID\n" >> $DIR/file/gb28181report.txt
cat $DIR/file/Call_ID.txt >> $DIR/file/gb28181report.txt
/usr/bin/rm -rf $DIR/file/Call_ID.txt

#打印会话产生的RTP端口
printf "\n\n根据 gb28181deriveall.pcap 数据报文中分析出RTP媒体端口信息： \n" >> $DIR/file/gb28181report.txt
cat $DIR/file/rtp.txt >> $DIR/file/gb28181report.txt
/usr/bin/rm -rf $DIR/file/rtp.txt

#打印会话产生的RTCP端口
printf "\n\n根据 gb28181deriveall.pcap 数据报文中分析出RTCP媒体端口信息： \n" >> $DIR/file/gb28181report.txt
cat $DIR/file/rtcp.txt >> $DIR/file/gb28181report.txt
/usr/bin/rm -rf $DIR/file/rtcp.txt




#!/bin/bash

# Check if user is root 
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

DIR=`pwd`

#创建输出报告文件
touch $DIR/report/sipreport.txt
cat /dev/null > $DIR/report/sipreport.txt


#打印输入的参数
cat $DIR/report/sipreport_old.txt > $DIR/report/sipreport.txt
/usr/bin/rm -rf $DIR/report/sipreport_old.txt


#打印二次分析的显示过滤器信息
Filter=`awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}' $DIR/report/Call_ID_filter.txt $DIR/report/rtp_filter.txt $DIR/report/rtcp_filter.txt`

printf "\n通过显示过滤器规则：
$Filter
过滤出 sipderiveall.pcap 数据报文
" >> $DIR/report/sipreport.txt
/usr/bin/rm -rf $DIR/report/Call_ID_filter.txt
/usr/bin/rm -rf $DIR/report/rtp_filter.txt
/usr/bin/rm -rf $DIR/report/rtcp_filter.txt


#打印会话产生的Call-ID
CALL_ID_LINE=`awk 'END{print NR}' $DIR/report/Call_ID.txt`
printf "\n根据 sipderiveall.pcap 数据报文中分析出总共生成 $CALL_ID_LINE 次 Call-ID\n" >> $DIR/report/sipreport.txt
cat $DIR/report/Call_ID.txt >> $DIR/report/sipreport.txt
/usr/bin/rm -rf $DIR/report/Call_ID.txt

#打印会话产生的RTP端口
printf "\n\n根据 sipderiveall.pcap 数据报文中分析出RTP媒体端口信息： \n" >> $DIR/report/sipreport.txt
cat $DIR/report/rtp.txt >> $DIR/report/sipreport.txt
/usr/bin/rm -rf $DIR/report/rtp.txt

#打印会话产生的RTCP端口
printf "\n\n根据 sipderiveall.pcap 数据报文中分析出RTCP媒体端口信息： \n" >> $DIR/report/sipreport.txt
cat $DIR/report/rtcp.txt >> $DIR/report/sipreport.txt
/usr/bin/rm -rf $DIR/report/rtcp.txt




#!/bin/bash

# Check if user is root 
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

DIR=`pwd`
SIPDIR=$DIR/report/sip.txt

#查看相同Call-ID下SIP会话全流程
CALLID_2=`awk -F , '{if(!a[$7,$10]++) print NR,$7,",",$10}' $SIPDIR`
printf "$CALLID_2" > $DIR/report/sip_invite_callid.txt

#相看相同Call-ID下SIP会话全流程携带SDP信息
CALLID_3=`awk -F , '{if(!a[$7,$10,$12,$13]++) print NR,$7,",",$10,",",$11,",",$12,",",$13}' $SIPDIR`
printf "$CALLID_3" > $DIR/report/sip_invite_sdp.txt


#统计数据报文中产生多少次invite请求
INVITE_NUM=$(cat $DIR/report/sip_invite_callid.txt | grep INVITE | wc -l)
printf "\n根据 sipderiveall.pcap 数据报文中统计分析总共发起 $INVITE_NUM 次INVITE请求.\n " >> $DIR/report/sipreport.txt

printf "INVITE 详细信息如下：\n"  >> $DIR/report/sipreport.txt

#将所有为invite会话中的信息取出并打印，能过Call-ID来匹配 
INVITE_ID=$(cat $DIR/report/sip_invite_callid.txt | grep INVITE | awk -F , '{print $2}')
for INVITE_ID_2 in $INVITE_ID; do
	UP_GBID=`cat $DIR/report/sip.txt | grep $INVITE_ID_2 | grep sdp | grep INVITE | awk -F , '{print $8}' | awk -F @ '{print $1}' | awk -F : '{print $2}' | awk '{if(!a[$1]++) print $1}'`
	SIGNAL_UP_ADDR=`cat $DIR/report/sip.txt | grep $INVITE_ID_2 | grep sdp | grep INVITE | awk -F , '{print $8}' | awk -F @ '{print $2}' | awk -F : '{print $1}' | awk '{if(!a[$1]++) print $1}'`	
	SIGNAL_UP_PORT=`cat $DIR/report/sip.txt | grep $INVITE_ID_2 | grep sdp | grep INVITE | awk -F , '{print $8}' | awk -F @ '{print $2}' | awk -F : '{print $2}' | awk '{if(!a[$1]++) print $1}'`
	DOWN_GBID=`cat $DIR/report/sip.txt | grep $INVITE_ID_2 | grep sdp | grep INVITE | awk -F , '{print $9}' | awk -F @ '{print $1}' | awk -F : '{print $2}' | awk '{if(!a[$1]++) print $1}'`
	SIGNAL_DOWN_ADDR=`cat $DIR/report/sip.txt | grep $INVITE_ID_2 | grep sdp | grep INVITE | awk -F , '{print $9}' | awk -F @ '{print $2}' | awk -F : '{print $1}' | awk '{if(!a[$1]++) print $1}'`	
	SIGNAL_DOWN_PORT=`cat $DIR/report/sip.txt | grep $INVITE_ID_2 | grep sdp | grep INVITE | awk -F , '{print $9}' | awk -F @ '{print $2}' | awk -F : '{print $2}' | awk '{if(!a[$1]++) print $1}'`
	INVITE_FLOW=`cat $DIR/report/sip.txt | grep $INVITE_ID_2 | awk -F , '{print $7}' | awk -F Protocol '{print $2}' | awk BEGIN{RS=EOF}'{gsub(/\n/," ==>");print}' | awk '{if(!a[$1]++) print $1}'`
	INVITE_NUM=`cat $DIR/report/sip.txt | grep $INVITE_ID_2 | awk -F , '{print $7}' | awk -F Protocol '{print $2}' | awk BEGIN{RS=EOF}'{gsub(/\n/," ==>");print}' | wc -l`
	printf "Call-ID = $INVITE_ID_2  发起Invite请求 $INVITE_NUM 次 \n" >> $DIR/report/sipreport.txt
	printf "Invite流程概要：$INVITE_FLOW  \n" >> $DIR/report/sipreport.txt
	printf "主叫信令地址：$SIGNAL_UP_ADDR  信令端口：$SIGNAL_UP_PORT  主叫号码：$UP_GBID \n" >> $DIR/report/sipreport.txt
	#上级媒体接收媒体详细
	MEDIUM_UP_ADDR=`cat $DIR/report/sip_invite_sdp.txt | grep $INVITE_ID_2 | grep INVITE | grep sdp | awk -F , '{print $4}' | awk -F " " '{print $3}' | awk '{if(!a[$1]++) print $1}'`
	MEDIUM_UP_PORT=`cat $DIR/report/sip_invite_sdp.txt | grep $INVITE_ID_2 | grep INVITE | grep sdp | awk -F , '{print $5}'`
	printf "媒体协商接收地址：$MEDIUM_UP_ADDR  媒体协商接收端口及能力集：$MEDIUM_UP_PORT \n" >> $DIR/report/sipreport.txt
	#下级媒体发送媒体详细
	MEDIUM_DOWN_ADDR=`cat $DIR/report/sip_invite_sdp.txt | grep $INVITE_ID_2 | grep sdp | grep -v INVITE | awk -F , '{print $4}' | awk -F " " '{print $3}' | awk '{if(!a[$1]++) print $1}'`
	MEDIUM_DOWN_PORT=`cat $DIR/report/sip_invite_sdp.txt | grep $INVITE_ID_2 | grep sdp | grep -v INVITE | awk -F , '{print $5}'`	
	printf "被叫信令地址：$SIGNAL_DOWN_ADDR  信令端口：$SIGNAL_DOWN_PORT  被叫号码：$DOWN_GBID \n" >> $DIR/report/sipreport.txt
	printf "媒体协商发送地址：$MEDIUM_DOWN_ADDR  媒体协商发送端口及能力集：$MEDIUM_DOWN_PORT \n\n" >> $DIR/report/sipreport.txt
done

#删除格式化数据的输出文件
/usr/bin/rm -rf $DIR/report/sip_invite_callid.txt
/usr/bin/rm -rf $DIR/report/sip_invite_sdp.txt




exit 126







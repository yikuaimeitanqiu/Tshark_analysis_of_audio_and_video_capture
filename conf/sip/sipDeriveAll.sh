#!/bin/bash

# Check if user is root 
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

DIR=`pwd`
SIPDIR=$DIR/report/sip.txt

#查看报文中出现了多少个不同的Call-ID
CALLID=`awk -F , '{if(!a[$10]++) print $10}' $SIPDIR`

#查看相同Call-ID下SIP会话全流程
CALLID_2=`awk -F , '{if(!a[$7,$10]++) print NR,$7,$10}' $SIPDIR`

#相看相同Call-ID下SIP会话全流程携带SDP信息
CALLID_3=`awk -F , '{if(!a[$7,$10,$12,$13]++) print NR,$7,$10,$11,$12,$13}' $SIPDIR`

#查看相同Call-ID下SIP会话使用的RTP媒体端口
CALLID_4=`awk -F , '{if(!a[$7,$10,$12,$13]++) print NR,$7,$10,$11,$12,",",$13}' $SIPDIR | grep "audio" | awk -F , '{print $2}' | awk -F " " '{print $2}' | awk '{if(!a[$1]++) print $1}'`



#Call-ID的显示过滤器，
touch $DIR/report/Call_ID1.txt
cat /dev/null > $DIR/report/Call_ID1.txt
for CALL_ID_2 in $CALLID; do 
	echo "(sip.Call-ID == \"$CALL_ID_2\")" >> $DIR/report/Call_ID1.txt
done
#多行字符串合成一行
awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}' $DIR/report/Call_ID1.txt > $DIR/report/Call_ID_filter.txt
#用于适配一个数据报文中多个call-id场景，用于最终的显示过滤器
sed -i 's#) (#) or (#g' $DIR/report/Call_ID_filter.txt
/usr/bin/rm -rf $DIR/report/Call_ID1.txt

CALL_ID_3=`cat $DIR/report/Call_ID_filter.txt`
printf "$CALLID" > $DIR/report/Call_ID.txt


#RTP媒体的显示过滤器
touch $DIR/report/rtp1.txt
cat /dev/null > $DIR/report/rtp1.txt
for RTP_PORT in $CALLID_4; do 
	echo " or (udp.port == $RTP_PORT)" >> $DIR/report/rtp1.txt
done
#多行字符串合成一行
awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}' $DIR/report/rtp1.txt > $DIR/report/rtp_filter.txt
/usr/bin/rm -rf $DIR/report/rtp1.txt

RTP_NUM_2=`cat $DIR/report/rtp_filter.txt`
printf "$CALLID_4" > $DIR/report/rtp.txt


#RTCP媒体的显示过滤器
touch $DIR/report/rtcp.txt
cat /dev/null > $DIR/report/rtcp.txt
for RTCP_PORT in $CALLID_4; do 
	RTCP_PORT_1=$(expr $RTCP_PORT + 1)
	echo "$RTCP_PORT_1" >> $DIR/report/rtcp.txt
done

touch $DIR/report/rtcp1.txt
cat /dev/null > $DIR/report/rtcp1.txt
RTCP_PORT_2=$(cat $DIR/report/rtcp.txt)
for RTCP_PORT_3 in $RTCP_PORT_2; do
        echo " or (udp.port == $RTCP_PORT_3)" >> $DIR/report/rtcp1.txt
done
#多行字符串合成一行
awk BEGIN{RS=EOF}'{gsub(/\n/," ");print}' $DIR/report/rtcp1.txt > $DIR/report/rtcp_filter.txt
/usr/bin/rm -rf $DIR/report/rtcp1.txt

RTCP_NUM_2=`cat $DIR/report/rtcp_filter.txt`



#通过Call-ID\RTP\RTCP 导出SIP信令及媒体报文
tshark -r $DIR/pcap/* \
-Y "$CALL_ID_3 $RTP_NUM_2 $RTCP_NUM_2" \
-w $DIR/report/sipderiveall.pcap \
&>/dev/null 





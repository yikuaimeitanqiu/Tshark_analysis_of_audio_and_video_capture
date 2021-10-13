#!/bin/bash

# Check if user is root 
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

DIR=`pwd`

#清理输出文件夹
/usr/bin/rm -rf $DIR/report/*.pcap
/usr/bin/rm -rf $DIR/report/*.txt


#输入其中一侧的信令交互地址
read -e -p "请输入信令交互的网络地址:  " ADDR
if [ -n "$ADDR" ]; then
	if [[ ! "$ADDR" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		printf "网络地址格式有误，请输入合法网络地址。\n"
		exit 1
	fi
fi

#输入信令交互端口号
read -e -p "请输入信令交互的端口号： " PORT
PORT_NUM_1=`grep -E '^[[:digit:]]*$' <<< "$PORT"`
if [ -n "$PORT_NUM_1" ]; then
	if [ "$PORT_NUM_1" -lt "1" -o "$PORT_NUM_1" -gt "65535" ]; then
		printf "请正常输入端口号范围： 1-65535 \n"
        	exit 1
	fi
fi

#输入主叫号码
read -e -p "请输入主叫号码： "  MASTERNUM
if [ -n "$MASTERNUM" ]; then
	MASTERNUM_NULL=`grep -E '^[[:digit:]]*$' <<< "$MASTERNUM"`
	if [ -z "$MASTERNUM_NULL" ]; then
		printf "请输入纯罗马数字号码。\n"
		exit 1
	fi 
fi

#输入被叫号码
read -e -p "请输入被叫号码： "  SALVENUM
if [ -n "$SALVENUM" ]; then
	SALVENUM_NULL=`grep -E '^[[:digit:]]*$' <<< "$SALVENUM"`
	if [ -z "$SALVENUM_NULL" ]; then
		printf "请输入纯罗马数字号码。\n"
		exit 1
	fi 
fi

#打印输入信息为分析文件提供参考
printf "######### SIP #########
数据报文过滤信息如下：
信令地址： $ADDR
信令端口： $PORT
主叫号码： $MASTERNUM
被叫号码： $SALVENUM
" > $DIR/report/sipreport_old.txt


#通过信令交互地址和端口进行分析
ADDR_PORT () {
if [ -n "$ADDR" -a -n "$PORT" -a -z "$MASTERNUM" -a -z "$SALVENUM" ]; then 
tshark -r $DIR/pcap/* \
-Y "(ip.addr==$ADDR and udp.port==$PORT)" \
-n -t a \
-T fields -E separator=, \
-e frame.time_epoch -e ip.src -e udp.srcport -e ip.dst  -e udp.dstport -e frame.len \
-e sip -e sip.from.addr -e sip.to.addr -e sip.Call-ID \
-e sdp -e sdp.connection_info -e sdp.media -e sdp.media_attr \
-w $DIR/report/sipInitial.pcap \
1> $DIR/report/sip.txt 


printf "\n通过显示过滤器规则：
(ip.addr==$ADDR and udp.port==$PORT)
过滤出的sipInitial.pcap数据报文
" >> $DIR/report/sipreport_old.txt

fi
}

#通过信令交互地址进行分析
ADDR_Filter () {
if [ -n "$ADDR" -a -z "$PORT" -a -z "$MASTERNUM" -a -z "$SALVENUM" ]; then
tshark -r $DIR/pcap/* \
-Y "(ip.addr==$ADDR)" \
-n -t a \
-T fields -E separator=, \
-e frame.time_epoch -e ip.src -e udp.srcport -e ip.dst  -e udp.dstport -e frame.len \
-e sip -e sip.from.addr -e sip.to.addr -e sip.Call-ID \
-e sdp -e sdp.connection_info -e sdp.media -e sdp.media_attr \
-w $DIR/report/sipInitial.pcap \
1> $DIR/report/sip.txt


printf "\n通过显示过滤器规则：
(ip.addr==$ADDR)
过滤出的sipInitial.pcap数据报文
" >> $DIR/report/sipreport_old.txt

fi
}

#通过信令交互端口进行分析
PORT_Filter () {
if [ -z "$ADDR" -a -n "$PORT" -a -z "$MASTERNUM" -a -z "$SALVENUM" ]; then
tshark -r $DIR/pcap/* \
-Y "(udp.port==$PORT)" \
-n -t a \
-T fields -E separator=, \
-e frame.time_epoch -e ip.src -e udp.srcport -e ip.dst  -e udp.dstport -e frame.len \
-e sip -e sip.from.addr -e sip.to.addr -e sip.Call-ID \
-e sdp -e sdp.connection_info -e sdp.media -e sdp.media_attr \
-w $DIR/report/sipInitial.pcap \
1> $DIR/report/sip.txt


printf "\n通过显示过滤器规则：
(udp.port==$PORT)
过滤出的sipInitial.pcap数据报文
" >> $DIR/report/sipreport_old.txt

fi
}


#通过主被叫号码进行分析
MASTERNUM_SALVENUM () {
if [ -n "$MASTERNUM" -a -n "$SALVENUM" -a -z "$ADDR" -a -z "$PORT" ]; then 
tshark -r $DIR/pcap/* \
-Y "(sip.from.user == $MASTERNUM) and (sip.to.user == $SALVENUM) " \
-n -t a \
-T fields -E separator=, \
-e frame.time_epoch -e ip.src -e udp.srcport -e ip.dst  -e udp.dstport -e frame.len \
-e sip -e sip.from.addr -e sip.to.addr -e sip.Call-ID \
-e sdp -e sdp.connection_info -e sdp.media -e sdp.media_attr \
-w $DIR/report/sipInitial.pcap \
1> $DIR/report/sip.txt 


printf "\n通过显示过滤器规则：
(sip.from.user == $MASTERNUM) and (sip.to.user == $SALVENUM)
过滤出的sipInitial.pcap数据报文
" >> $DIR/report/sipreport_old.txt

fi
}

#通过主叫号码进行分析
MASTERNUM_Filter () {
if [ -n "$MASTERNUM" -a -z "$SALVENUM" -a -z "$ADDR" -a -z "$PORT" ]; then
tshark -r $DIR/pcap/* \
-Y "(sip.from.user == $MASTERNUM)" \
-n -t a \
-T fields -E separator=, \
-e frame.time_epoch -e ip.src -e udp.srcport -e ip.dst  -e udp.dstport -e frame.len \
-e sip -e sip.from.addr -e sip.to.addr -e sip.Call-ID \
-e sdp -e sdp.connection_info -e sdp.media -e sdp.media_attr \
-w $DIR/report/sipInitial.pcap \
1> $DIR/report/sip.txt


printf "\n通过显示过滤器规则：
(sip.from.user == $MASTERNUM)
过滤出的sipInitial.pcap数据报文
" >> $DIR/report/sipreport_old.txt

fi
}

#通过被叫号码进行分析
SALVENUM_Filter () {
if [ -z "$MASTERNUM" -a -n "$SALVENUM" -a -z "$ADDR" -a -z "$PORT" ]; then
tshark -r $DIR/pcap/* \
-Y "(sip.to.user == $SALVENUM) " \
-n -t a \
-T fields -E separator=, \
-e frame.time_epoch -e ip.src -e udp.srcport -e ip.dst  -e udp.dstport -e frame.len \
-e sip -e sip.from.addr -e sip.to.addr -e sip.Call-ID \
-e sdp -e sdp.connection_info -e sdp.media -e sdp.media_attr \
-w $DIR/report/sipInitial.pcap \
1> $DIR/report/sip.txt


printf "\n通过显示过滤器规则：
(sip.to.user == $SALVENUM)
过滤出的sipInitial.pcap数据报文
" >> $DIR/report/sipreport_old.txt

fi
}


#通过主被叫号码查找在指定信令交互的地址及端口上进行分析
ADDR_PORT_MASTERNUM_SALVENUM () {
if [ -n "$MASTERNUM" -a -n "$SALVENUM" -a -n "$ADDR" -a -n "$PORT" ]; then 
tshark -r $DIR/pcap/* \
-Y "(ip.addr==$ADDR and udp.port==$PORT) and (sip.from.user == $MASTERNUM) and (sip.to.user == $SALVENUM)" \
-n -t a \
-T fields -E separator=, \
-e frame.time_epoch -e ip.src -e udp.srcport -e ip.dst  -e udp.dstport -e frame.len \
-e sip -e sip.from.addr -e sip.to.addr -e sip.Call-ID \
-e sdp -e sdp.connection_info -e sdp.media -e sdp.media_attr \
-w $DIR/report/sipInitial.pcap \
1> $DIR/report/sip.txt 


printf "\n通过显示过滤器规则：
(ip.addr==$ADDR and udp.port==$PORT) and (sip.from.user == $MASTERNUM) and (sip.to.user == $SALVENUM)
过滤出的sipInitial.pcap数据报文
" >> $DIR/report/sipreport_old.txt

fi

}

#通过主叫号码来查找在指定信令交互的地址及端口上进行分析
ADDR_PORT_MASTERNUM () {
if [ -n "$MASTERNUM" -a -z "$SALVENUM" -a -n "$ADDR" -a -n "$PORT" ]; then
tshark -r $DIR/pcap/* \
-Y "(ip.addr==$ADDR and udp.port==$PORT) and (sip.from.user == $MASTERNUM)" \
-n -t a \
-T fields -E separator=, \
-e frame.time_epoch -e ip.src -e udp.srcport -e ip.dst  -e udp.dstport -e frame.len \
-e sip -e sip.from.addr -e sip.to.addr -e sip.Call-ID \
-e sdp -e sdp.connection_info -e sdp.media -e sdp.media_attr \
-w $DIR/report/sipInitial.pcap \
1> $DIR/report/sip.txt


printf "\n通过显示过滤器规则：
(ip.addr==$ADDR and udp.port==$PORT) and (sip.from.user == $MASTERNUM)
过滤出的sipInitial.pcap数据报文
" >> $DIR/report/sipreport_old.txt

fi
}


#通过被叫号码来查找在指定信令交互的地址及端口上进行分析
ADDR_PORT_SALVENUM () {
if [ -z "$MASTERNUM" -a -n "$SALVENUM" -a -n "$ADDR" -a -n "$PORT" ]; then
tshark -r $DIR/pcap/* \
-Y "(ip.addr==$ADDR and udp.port==$PORT) and (sip.to.user == $SALVENUM)" \
-n -t a \
-T fields -E separator=, \
-e frame.time_epoch -e ip.src -e udp.srcport -e ip.dst  -e udp.dstport -e frame.len \
-e sip -e sip.from.addr -e sip.to.addr -e sip.Call-ID \
-e sdp -e sdp.connection_info -e sdp.media -e sdp.media_attr \
-w $DIR/report/sipInitial.pcap \
1> $DIR/report/sip.txt


printf "\n通过显示过滤器规则：
(ip.addr==$ADDR and udp.port==$PORT) and (sip.to.user == $SALVENUM)
过滤出的sipInitial.pcap数据报文
" >> $DIR/report/sipreport_old.txt

fi
}


#未指定任何参数直接通过sip进行分析
ADDR_PORT_MASTERNUM_SALVENUM_NULL () {
if [ -z "$MASTERNUM" -a -z "$SALVENUM" -a -z "$ADDR" -a -z "$PORT" ]; then
tshark -r $DIR/pcap/* \
-Y "sip" \
-n -t a \
-T fields -E separator=, \
-e frame.time_epoch -e ip.src -e udp.srcport -e ip.dst  -e udp.dstport -e frame.len \
-e sip -e sip.from.addr -e sip.to.addr -e sip.Call-ID \
-e sdp -e sdp.connection_info -e sdp.media -e sdp.media_attr \
-w $DIR/report/sipInitial.pcap \
1> $DIR/report/sip.txt


printf "\n通过显示过滤器规则：
sip
过滤出的sipInitial.pcap数据报文
" >> $DIR/report/sipreport_old.txt

fi
}


#创建空文件等输出
touch $DIR/report/sip.txt
cat /dev/null > $DIR/report/sip.txt

#判断上传文件格式后缀是相符,并判断是否为一个文件，是则执行。
CAP=`ls -l $DIR/pcap | grep -E '*.cap$' | wc -l`
PCAP=`ls -l $DIR/pcap | grep -E '*.pcap$' | wc -l`
PCAPNG=`ls -l $DIR/pcap | grep -E '*.pcapng$' | wc -l`
if [ "$PCAP" == 1 ]; then
	printf "正在处理中，请耐心等待。\n"
        ADDR_PORT
        ADDR_Filter
        PORT_Filter
        MASTERNUM_SALVENUM
        MASTERNUM_Filter
        SALVENUM_Filter
        ADDR_PORT_MASTERNUM_SALVENUM
        ADDR_PORT_MASTERNUM
        ADDR_PORT_SALVENUM
        ADDR_PORT_MASTERNUM_SALVENUM_NULL
else
        printf "请上传一个 pcap 或 pcapng 格式文件，不支持多文件同时处理。\n"
fi


if [ "$PCAPNG" == 1  ]; then
	printf "正在处理中，请耐心等待。\n"
        ADDR_PORT
        ADDR_Filter
        PORT_Filter
        MASTERNUM_SALVENUM
        MASTERNUM_Filter
        SALVENUM_Filter
        ADDR_PORT_MASTERNUM_SALVENUM
        ADDR_PORT_MASTERNUM
        ADDR_PORT_SALVENUM
        ADDR_PORT_MASTERNUM_SALVENUM_NULL
else
        printf "请上传一个 pcap 或 pcapng 格式文件，不支持多文件同时处理。\n"
fi


if [ "$CAP" == 1  ]; then
	printf "正在处理中，请耐心等待。\n"
        ADDR_PORT
        ADDR_Filter
        PORT_Filter
        MASTERNUM_SALVENUM
        MASTERNUM_Filter
        SALVENUM_Filter
        ADDR_PORT_MASTERNUM_SALVENUM
        ADDR_PORT_MASTERNUM
        ADDR_PORT_SALVENUM
        ADDR_PORT_MASTERNUM_SALVENUM_NULL
else
        printf "请上传一个 pcap 或 pcapng 格式文件，不支持多文件同时处理。\n"
fi



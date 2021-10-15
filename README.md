# Tshark_analysis_of_audio_and_video_capture
通过tshark 再结合linux shell 完成对 sip gb28181 抓包分析 
当前只运行在linux下  



tshark 分析参考  

tshark  
-r pcap/*  #指定数据抓包  
-Y "sip"  #显示过滤器  
-n  #不进行dns解析  
-t a  #设置时间格式  
-T fields  #输出为文本格式  
-E separator=,  #分隔符 ,  
  
#物理层  
-e frame.time_epoch  # 抓包日期和时间  
-e frame.time_delta_displayed  # 使用显示过滤器后，此包与第一帧的时间间隔  
-e frame.time_delta  # 此包与前一包的时间间隔  
-e frame.number  # 帧序号  
-e frame.len    # 帧长度  
-e frame.protocols  # 帧内封装的协议层次结构    
  
#链路层  
-e eth.src  # 源MAC地址  
-e eth.dst  # 目标MAC地址  
-e eth.type  # 链路直接封装的协议类型   
  
#网络层  
-e ip.dsfield # 差分服务字段  
-e ip.id   #标志字段  
-e ip.flags #标记字段  
-e ip.frag_offset #分的偏移量  
-e ip.ttl # 生存期TTL  
-e ip.proto # 此包内封装的上层协议  
-e ip.checksum #头部数据的校验和  
-e ip.src   # 源IP地址  
-e ip.dst  # 目标IP地址  
  
#传输层      
-e udp.srcport   #UDP源端口号  
-e udp.dstport   #UDP目标端口号  
  
#应用层  
-e sip #表示SIP协议  
  
#起始行  
-e sip.Status-Line #起始行，请求的区分  
#消息头  
-e sip.Call-ID  #消息的唯一标识符  
-e sip.from.addr  #发起者  
        -e sip.from.user #发起者用户  
        -e sip.from.host #发起者地址  
        -e sip.from.port #发起者端口  
-e sip.to.addr    #接收者  
	-e sip.to.user  #接收者用户  
	-e sip.to.host  #接收者地址  
	-e sip.to.port  #接收者端口  
-e sip.CSeq.method  #请求方法类型   
-e sip.User-Agent #用户信息   
-e sip.Contact #用于为随后请求联系的具体实例，此 URI 都必须是有效的  
	-e sip.contact.user #实际连接用户    
	-e sip.contact.host #实际连接地址  
	-e sip.contact.port #实际连接端口  
-e sip.Content-Type #消息体的媒体类型   
#消息体   
-e sdp  #sdp协议     
-e sdp.version  #SDP版本，默认为0   
-e sdp.session_name # 会话名字  
-e sdp.connection_info # 媒体连接地址 <网络类型><地址类型><链接地址>    
	-e sdp.connection_info.address # 媒体连接地址   
-e sdp.time  #表示会话起始时间与结束时间，常见为 0 0  不受限制   
-e sdp.media #媒体描述 <媒体类型><端口><协议><格式类型>  
	-e sdp.media.media #媒体描述 <媒体类型>  
	-e sdp.media.port  #媒体描述 <端口>  
	-e sdp.media.proto #媒体描述 <协议>   
	-e sdp.media.format #媒体描述 <格式类型>  
-e sdp.media_attr  #媒体属性  
  


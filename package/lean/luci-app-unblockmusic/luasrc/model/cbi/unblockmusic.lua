
mp = Map("unblockmusic", translate("解除网易云音乐播放限制"))
mp.description = translate("原理：采用 [网易云旧链/QQ/虾米/百度/酷狗/酷我/咕咪/JOOX] 等音源，替换网易云音乐 无版权/收费 歌曲链接<br/>具体使用方法参见：https://github.com/project-openwrt/UnblockNeteaseMusic")

mp:section(SimpleSection).template  = "unblockmusic/unblockmusic_status"

s = mp:section(TypedSection, "unblockmusic")
s.anonymous=true
s.addremove=false

enabled = s:option(Flag, "enabled", translate("启用本插件"))
enabled.description = translate("启用本插件以解除网易云音乐播放限制")
enabled.default = 0
enabled.rmempty = false

http_port = s:option(Value, "http_port", translate("[HTTP] 监听端口"))
http_port.description = translate("本插件监听的HTTP端口，不可与其他程序/HTTPS共用一个端口")
http_port.placeholder = "5200"
http_port.default = "5200"
http_port.datatype = "port"
http_port:depends("enabled", 1)

https_port = s:option(Value, "https_port", translate("[HTTPS] 监听端口"))
https_port.description = translate("[如HTTP端口设置为80，请将HTTPS端口设置为443] 本插件监听的HTTPS端口，不可与其他程序/HTTP共用一个端口")
https_port.placeholder = "5201"
https_port.default = "5201"
https_port.datatype = "port"
https_port:depends("enabled", 1)

musicapptype = s:option(ListValue, "musicapptype", translate("音源接口"))
musicapptype:value("default", translate("默认"))
musicapptype:value("netease", translate("网易云音乐"))
musicapptype:value("qq", translate("QQ音乐"))
musicapptype:value("xiami", translate("虾米音乐"))
musicapptype:value("baidu", translate("百度音乐"))
musicapptype:value("kugou", translate("酷狗音乐"))
musicapptype:value("kuwo", translate("酷我音乐"))
musicapptype:value("migu", translate("咕咪音乐"))
musicapptype:value("joox", translate("JOOX音乐"))
musicapptype:value("all", translate("所有平台"))
musicapptype.description = translate("音源调用接口")
musicapptype.default = "default"
musicapptype:depends("enabled", 1)

enable_hijack = s:option(Flag, "enable_hijack", translate("启用劫持"))
enable_hijack.description = translate("开启后，网易云音乐相关请求会被强制劫持到本插件进行处理")
enable_hijack.default = 0
enable_hijack.rmempty = false
enable_hijack:depends("enabled", 1)

hijack_ways = s:option(ListValue, "hijack_ways", translate("劫持方法"))
hijack_ways:value("use_ipset", translate("使用IPSet劫持"))
hijack_ways:value("use_hosts", translate("使用Hosts劫持"))
hijack_ways.description = translate("如果使用Hosts劫持，请将HTTP/HTTPS端口设置为80/443")
hijack_ways.default = "use_ipset"
hijack_ways:depends("enable_hijack", 1)

advanced_mode = s:option(Flag, "advanced_mode", translate("启用进阶设置"))
advanced_mode.description = translate("仅推荐高级玩家使用")
advanced_mode.default = 0
advanced_mode.rmempty = false
advanced_mode:depends("enabled", 1)

pub_access = s:option(Flag, "pub_access", translate("部署到公网"))
pub_access.description = translate("默认仅监听局域网，如需提供公开访问请勾选此选项；与此同时，建议勾选“启用严格模式”")
pub_access.default = 0
pub_access.rmempty = false
pub_access:depends("advanced_mode", 1)

strict_mode = s:option(Flag, "strict_mode", translate("启用严格模式"))
strict_mode.description = translate("若将服务部署到公网，则强烈建议使用严格模式，此模式下仅放行网易云音乐所属域名的请求")
strict_mode.default = 0
strict_mode.rmempty = false
strict_mode:depends("advanced_mode", 1)

ipset_forward_nohttps = s:option(Flag, "ipset_forward_nohttps", translate("[IPSet] 不劫持HTTPS请求"))
ipset_forward_nohttps.description = translate("默认同时劫持HTTP&HTTPS两种请求，如无相关需求，可勾选此选项")
ipset_forward_nohttps.default = 0
ipset_forward_nohttps.rmempty = false
ipset_forward_nohttps:depends("advanced_mode", 1)

set_netease_server_ip = s:option(Flag, "set_netease_server_ip", translate("自定义网易云服务器IP"))
set_netease_server_ip.description = translate("如手动更改了Hosts文件则必选，否则将会导致连接死循环")
set_netease_server_ip.default = 0
set_netease_server_ip.rmempty = false
set_netease_server_ip:depends("advanced_mode", 1)

netease_server_ip = s:option(Value, "netease_server_ip", translate("网易云服务器IP"))
netease_server_ip.description = translate("通过 ping music.163.com 即可获得IP地址，仅限填写一个")
netease_server_ip.default = "59.111.181.38"
netease_server_ip.placeholder = "59.111.181.38"
netease_server_ip.datatype = "ipaddr"
netease_server_ip:depends("set_netease_server_ip", 1)

enable_proxy = s:option(Flag, "enable_proxy", translate("使用代理服务器"))
enable_proxy.description = translate("如您的OpenWRT/LEDE系统部署在海外，则此选项必选，否则可能无法正常使用")
enable_proxy.default = 0
enable_proxy.rmempty = false
enable_proxy:depends("advanced_mode", 1)

proxy_server_ip = s:option(Value, "proxy_server_ip", translate("代理服务器IP"))
proxy_server_ip.description = translate("具体格式请参考：https://github.com/nondanee/UnblockNeteaseMusic")
proxy_server_ip.datatype = "string"
proxy_server_ip:depends("enable_proxy", 1)

return mp

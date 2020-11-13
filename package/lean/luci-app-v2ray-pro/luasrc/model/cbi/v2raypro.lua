
local fs = require "nixio.fs"
local NXFS = require "nixio.fs"
local WLFS = require "nixio.fs"
local SYS  = require "luci.sys"
local ND = SYS.exec("cat /etc/gfwlist/china-banned | wc -l")
local conf = "/etc/v2ray/base-gfwlist.txt"
local watch = "/tmp/v2ray_watchdog.log"
local dog = "/tmp/v2raypro.log"
local http = luci.http
local ucursor = require "luci.model.uci".cursor()

m = Map("v2raypro")
m.title	= translate("V2Ray Transparent Proxy")
m.description = translate("A fast secure tunnel proxy that help you get through firewalls on your router")

m:section(SimpleSection).template  = "v2raypro/v2raypro_status"

s = m:section(TypedSection, "v2raypro")
s.anonymous = true

-- ---------------------------------------------------

s:tab("basic",  translate("Base Setting"))


switch = s:taboption("basic",Flag, "enabled", translate("Enable"))
switch.rmempty = false

proxy_mode = s:taboption("basic",ListValue, "proxy_mode", translate("Proxy Mode"))
proxy_mode:value("M", translate("Base on GFW-List Auto Proxy Mode(Recommend)"))
proxy_mode:value("S", translate("Bypassing China Manland IP Mode(Be caution when using P2P download！)"))
proxy_mode:value("G", translate("Global Mode"))
proxy_mode:value("V", translate("Overseas users watch China video website Mode"))

cronup = s:taboption("basic", Flag, "cron_mode", translate("Auto Update GFW-List"),
	translate(string.format("GFW-List Lines： <strong><font color=\"blue\">%s</font></strong> Lines", ND)))
cronup.default = 0
cronup.rmempty = false

updatead = s:taboption("basic", Button, "updatead", translate("Manually force update GFW-List"), translate("Note: It needs to download and convert the rules. The background process may takes 60-120 seconds to run. <br / > After completed it would automatically refresh, please do not duplicate click!"))
updatead.inputtitle = translate("Manually force update GFW-List")
updatead.inputstyle = "apply"
updatead.write = function()
	SYS.call("nohup sh /etc/v2ray/up-gfwlist.sh > /tmp/gfwupdate.log 2>&1 &")
end

safe_dns_tcp = s:taboption("basic",Flag, "safe_dns_tcp", translate("DNS uses TCP"),
	translate("Through the server transfer mode inquires DNS pollution prevention (Safer and recommended)"))
safe_dns_tcp.rmempty = false
-- safe_dns_tcp:depends("more", "1")

-- timeout = s:taboption("basic",Value, "timeout", translate("Timeout"))
-- timeout.datatype = "range(0,10000)"
-- timeout.placeholder = "60"
-- timeout.optional = false
-- timeout:depends("more", "1")

-- safe_dns = s:taboption("basic",Value, "safe_dns", translate("Safe DNS"),
-- 	translate("8.8.8.8 or 8.8.4.4 is recommended"))
-- safe_dns.datatype = "ip4addr"
-- safe_dns.optional = false
-- safe_dns:depends("more", "1")

-- safe_dns_port = s:taboption("basic",Value, "safe_dns_port", translate("Safe DNS Port"),
-- 	translate("Foreign DNS on UDP port 53 might be polluted"))
-- safe_dns_port.datatype = "range(1,65535)"
-- safe_dns_port.placeholder = "53"
-- safe_dns_port.optional = false
-- safe_dns_port:depends("more", "1")

safe_dns_dnscrypt = s:taboption("basic",Flag, "safe_dns_dnscrypt", translate("Use dnscrypt-proxy"),
	translate("Use dnscrypt-proxy to forward DNS requests, instead of pdnsd"))
safe_dns_dnscrypt:depends("safe_dns_tcp", "1")

alternative_proxy = s:taboption("basic",Flag, "alternative_proxy", translate("Alternative Proxies"),
	translate("Listen to port 1080 (SOCKS5 proxy) and port 3128 (HTTP proxy)"))
alternative_proxy.rmempty = false

fast_open =s:taboption("basic",Flag, "fast_open", translate("TCP Fast Open"),
	translate("Enable TCP fast open, only available on kernel > 3.7.0"))

s:tab("main",  translate("Server Setting"))

server = s:taboption("main",Value, "address", translate("Server Address"))
server.datatype = "host"
server.rmempty = false

server_port = s:taboption("main",Value, "port", translate("Server Port"))
server_port.datatype = "range(0,65535)"
server_port.rmempty = false

protocol = s:taboption("main",ListValue, "protocol", translate("Protocol"))
protocol:value("vmess")
protocol:value("vless")

id = s:taboption("main",Value, "id", translate("ID"))
id.password = true

alterId = s:taboption("main",Value, "alterId", translate("Alter ID"))
alterId:depends("protocol", "vmess")
alterId.datatype = "range(1,65535)"
alterId.rmempty = false

security = s:taboption("main",ListValue, "security", translate("Security"))
security:depends("protocol", "vmess")
security:value("none")
security:value("auto")
security:value("aes-128-gcm")
security:value("chacha20-poly1305")

network_type = s:taboption("main",ListValue, "network_type", translate("Network Type"))
network_type:value("tcp")
network_type:value("kcp")
network_type:value("ws")
network_type:value("h2")
network_type:value("quic")

-- tcp settings
tcp_obfs = s:taboption("main",ListValue, "tcp_obfs", translate("TCP Obfs"))
tcp_obfs:value("none")
tcp_obfs:value("http")
tcp_obfs:depends("network_type", "tcp")

tcp_path = s:taboption("main",DynamicList, "tcp_path", translate("TCP Obfs Path"))
tcp_path:depends("tcp_obfs", "http")

tcp_host = s:taboption("main",DynamicList, "tcp_host", translate("TCP Obfs Header"))
tcp_host:depends("tcp_obfs", "http")
tcp_host.datatype = "host"

-- kcp settings
kcp_obfs = s:taboption("main",ListValue, "kcp_obfs", translate("KCP Obfs"))
kcp_obfs:value("none")
kcp_obfs:value("srtp")
kcp_obfs:value("utp")
kcp_obfs:value("wechat-video")
kcp_obfs:value("dtls")
kcp_obfs:value("wireguard")
kcp_obfs:depends("network_type", "kcp")

kcp_mtu = s:taboption("main",Value, "kcp_mtu", translate("KCP MTU"))
kcp_mtu.datatype = "range(576,1460)"
kcp_mtu:depends("network_type", "kcp")

kcp_tti = s:taboption("main",Value, "kcp_tti", translate("KCP TTI"))
kcp_tti.datatype = "range(10,100)"
kcp_tti:depends("network_type", "kcp")

kcp_uplink = s:taboption("main",Value, "kcp_uplink", translate("KCP uplinkCapacity"))
kcp_uplink.datatype = "range(0,1000)"
kcp_uplink:depends("network_type", "kcp")

kcp_downlink = s:taboption("main",Value, "kcp_downlink", translate("KCP downlinkCapacity"))
kcp_downlink.datatype = "range(0,1000)"
kcp_downlink:depends("network_type", "kcp")

kcp_readbuf = s:taboption("main",Value, "kcp_readbuf", translate("KCP readBufferSize"))
kcp_readbuf.datatype = "range(0,100)"
kcp_readbuf:depends("network_type", "kcp")

kcp_writebuf = s:taboption("main",Value, "kcp_writebuf", translate("KCP writeBufferSize"))
kcp_writebuf.datatype = "range(0,100)"
kcp_writebuf:depends("network_type", "kcp")

kcp_congestion = s:taboption("main",Flag, "kcp_congestion", translate("KCP Congestion"))
kcp_congestion:depends("network_type", "kcp")

kcp_seed = s:taboption("main",Value, "kcp_seed", translate("KCP Seed"))
kcp_seed:depends("network_type", "kcp")
kcp_seed.password = true

-- websocket settings
ws_path = s:taboption("main",Value, "ws_path", translate("WebSocket Path"))
ws_path:depends("network_type", "ws")

ws_headers = s:taboption("main",Value, "ws_headers", translate("WebSocket Header"))
ws_headers:depends("network_type", "ws")
ws_headers.datatype = "host"

-- http/2 settings
h2_path = s:taboption("main",Value, "h2_path", translate("HTTP Path"))
h2_path:depends("network_type", "h2")

h2_domain = s:taboption("main",DynamicList, "h2_domain", translate("HTTP Domain"))
h2_domain:depends("network_type", "h2")
h2_domain.datatype = "host"

-- quic settings
quic_security = s:taboption("main",ListValue, "quic_security", translate("QUIC Security"))
quic_security:value("none")
quic_security:value("aes-128-gcm")
quic_security:value("chacha20-poly1305")
quic_security:depends("network_type", "quic")

quic_key = s:taboption("main",Value, "quic_key", translate("QUIC Key"))
quic_key:depends("quic_security", "aes-128-gcm")
quic_key:depends("quic_security", "chacha20-poly1305")
quic_key.password = true

quic_obfs = s:taboption("main",ListValue, "quic_obfs", translate("QUIC Obfs"))
quic_obfs:value("none")
quic_obfs:value("srtp")
quic_obfs:value("utp")
quic_obfs:value("wechat-video")
quic_obfs:value("dtls")
quic_obfs:value("wireguard")
quic_obfs:depends("network_type", "quic")

-- others
tls = s:taboption("main",Flag, "tls", translate("TLS"))
tls.rmempty = false

servername = s:taboption("main",Value, "servername", translate("Server Name"))
servername.datatype = "host"
servername:depends("tls", "1")

xtls = s:taboption("main",Flag, "xtls", translate("Using XTLS"))
xtls:depends({protocol="vless", tls="1"})

mux = s:taboption("main",Flag, "mux", translate("Mux"))
mux.rmempty = false

------------------------------------------------
s:tab("reverse",  translate("Reverse Setting"))
renabled = s:taboption("reverse",Flag, "renabled", translate("Enable"))
renabled.rmempty = false

rserver_domain = s:taboption("reverse",Value, "rserver_domain", translate("Server domain"))
rserver_domain.datatype = "host"
rserver_domain.placeholder = "www.myowndomain.com"
rserver_domain:depends("renabled", "1")

rdiffsvr = s:taboption("reverse",Flag, "rdiffsvr", translate("Use different server from transparent proxy"))
rdiffsvr:depends("renabled", "1")
rdiffsvr.rmempty = false

rserver = s:taboption("reverse",Value, "raddress", translate("Server Address"))
rserver.datatype = "host"
rserver:depends("rdiffsvr", "1")

rserver_port = s:taboption("reverse",Value, "rport", translate("Server Port"))
rserver_port.datatype = "range(0,65535)"
rserver_port:depends("rdiffsvr", "1")

rprotocol = s:taboption("reverse",ListValue, "rprotocol", translate("Protocol"))
rprotocol:value("vmess")
rprotocol:value("vless")
rprotocol:value("shadowsocks")
rprotocol:value("socks")
rprotocol:depends("rdiffsvr", "1")

rid = s:taboption("reverse",Value, "rid", translate("ID"))
rid:depends("rprotocol", "vmess")
rid:depends("rprotocol", "vless")
rid.password = true

ralterId = s:taboption("reverse",Value, "ralterId", translate("Alter ID"))
ralterId.datatype = "range(1,65535)"
ralterId:depends("rprotocol", "vmess")

rsecurity = s:taboption("reverse",ListValue, "rsecurity", translate("Security"))
rsecurity:value("none")
rsecurity:value("auto")
rsecurity:value("aes-128-cfb")
rsecurity:value("aes-128-gcm")
rsecurity:value("chacha20-poly1305")
rsecurity:depends("rprotocol", "vmess")

rsocksuser = s:taboption("reverse",Value, "rsocksuser", translate("Username(for authentication)"))
rsocksuser:depends("rprotocol", "socks")

rpassword = s:taboption("reverse",Value, "rpassword", translate("Password"))
rpassword.password = true
rpassword:depends("rprotocol", "shadowsocks")
rpassword:depends("rprotocol", "socks")

rssmethod = s:taboption("reverse",ListValue, "rssmethod", translate("Method"))
rssmethod:value("aes-128-gcm")
rssmethod:value("aes-256-gcm")
rssmethod:value("chacha20-poly1305")
rssmethod:value("aes-128-cfb")
rssmethod:value("aes-256-cfb")
rssmethod:value("chacha20")
rssmethod:value("chacha20-ietf")
rssmethod:depends("rprotocol", "shadowsocks")

rssota = s:taboption("reverse",Flag, "rssota", translate("OTA"))
rssota:depends("rssmethod", "aes-128-cfb")
rssota:depends("rssmethod", "aes-256-cfb")
rssota:depends("rssmethod", "chacha20")
rssota:depends("rssmethod", "chacha20-ietf")

rnetwork_type = s:taboption("reverse",ListValue, "rnetwork_type", translate("Network Type"))
rnetwork_type:value("tcp")
rnetwork_type:value("kcp")
rnetwork_type:value("ws")
rnetwork_type:value("h2")
rnetwork_type:value("quic")
rnetwork_type:depends("rdiffsvr", "1")

-- tcp settings
rtcp_obfs = s:taboption("reverse",ListValue, "rtcp_obfs", translate("TCP Obfs"))
rtcp_obfs:value("none")
rtcp_obfs:value("http")
rtcp_obfs:depends("rnetwork_type", "tcp")

rtcp_path = s:taboption("reverse",DynamicList, "rtcp_path", translate("TCP Obfs Path"))
rtcp_path:depends("rtcp_obfs", "http")

rtcp_host = s:taboption("reverse",DynamicList, "rtcp_host", translate("TCP Obfs Header"))
rtcp_host:depends("rtcp_obfs", "http")
rtcp_host.datatype = "host"

-- kcp settings
rkcp_obfs = s:taboption("reverse",ListValue, "rkcp_obfs", translate("KCP Obfs"))
rkcp_obfs:value("none")
rkcp_obfs:value("srtp")
rkcp_obfs:value("utp")
rkcp_obfs:value("wechat-video")
rkcp_obfs:value("dtls")
rkcp_obfs:value("wireguard")
rkcp_obfs:depends("rnetwork_type", "kcp")

rkcp_mtu = s:taboption("reverse",Value, "rkcp_mtu", translate("KCP MTU"))
rkcp_mtu.datatype = "range(576,1460)"
rkcp_mtu:depends("rnetwork_type", "kcp")

rkcp_tti = s:taboption("reverse",Value, "rkcp_tti", translate("KCP TTI"))
rkcp_tti.datatype = "range(10,100)"
rkcp_tti:depends("rnetwork_type", "kcp")

rkcp_uplink = s:taboption("reverse",Value, "rkcp_uplink", translate("KCP uplinkCapacity"))
rkcp_uplink.datatype = "range(0,1000)"
rkcp_uplink:depends("rnetwork_type", "kcp")

rkcp_downlink = s:taboption("reverse",Value, "rkcp_downlink", translate("KCP downlinkCapacity"))
rkcp_downlink.datatype = "range(0,1000)"
rkcp_downlink:depends("rnetwork_type", "kcp")

rkcp_readbuf = s:taboption("reverse",Value, "rkcp_readbuf", translate("KCP readBufferSize"))
rkcp_readbuf.datatype = "range(0,100)"
rkcp_readbuf:depends("rnetwork_type", "kcp")

rkcp_writebuf = s:taboption("reverse",Value, "rkcp_writebuf", translate("KCP writeBufferSize"))
rkcp_writebuf.datatype = "range(0,100)"
rkcp_writebuf:depends("rnetwork_type", "kcp")

rkcp_congestion = s:taboption("reverse",Flag, "rkcp_congestion", translate("KCP Congestion"))
rkcp_congestion:depends("rnetwork_type", "kcp")

rkcp_seed = s:taboption("reverse",Value, "rkcp_seed", translate("KCP Seed"))
rkcp_seed:depends("rnetwork_type", "kcp")
rkcp_seed.password = true

-- websocket settings
rws_path = s:taboption("reverse",Value, "rws_path", translate("WebSocket Path"))
rws_path:depends("rnetwork_type", "ws")

rws_headers = s:taboption("reverse",Value, "rws_headers", translate("WebSocket Header"))
rws_headers:depends("rnetwork_type", "ws")
rws_headers.datatype = "host"

-- http/2 settings
rh2_path = s:taboption("reverse",Value, "rh2_path", translate("HTTP Path"))
rh2_path:depends("rnetwork_type", "h2")

rh2_domain = s:taboption("reverse",DynamicList, "rh2_domain", translate("HTTP Domain"))
rh2_domain:depends("rnetwork_type", "h2")
rh2_domain.datatype = "host"

-- quic settings
rquic_security = s:taboption("reverse",ListValue, "rquic_security", translate("QUIC Security"))
rquic_security:value("none")
rquic_security:value("aes-128-gcm")
rquic_security:value("chacha20-poly1305")
rquic_security:depends("rnetwork_type", "quic")

rquic_key = s:taboption("reverse",Value, "rquic_key", translate("QUIC Key"))
rquic_key:depends("rquic_security", "aes-128-gcm")
rquic_key:depends("rquic_security", "chacha20-poly1305")
rquic_key.password = true

rquic_obfs = s:taboption("reverse",ListValue, "rquic_obfs", translate("QUIC Obfs"))
rquic_obfs:value("none")
rquic_obfs:value("srtp")
rquic_obfs:value("utp")
rquic_obfs:value("wechat-video")
rquic_obfs:value("dtls")
rquic_obfs:value("wireguard")
rquic_obfs:depends("rnetwork_type", "quic")

-- others
rtls = s:taboption("reverse",Flag, "rtls", translate("TLS"))
rtls:depends("rdiffsvr", "1")

rservername = s:taboption("reverse",Value, "rservername", translate("Server Name"))
rservername.datatype = "host"
rservername:depends("rtls", "1")

--------------------------------------------------
s:tab("list",  translate("User-defined GFW-List"))
gfwlist = s:taboption("list", TextValue, "conf")
gfwlist.description = translate("<br />（!）Note: When the domain name is entered and will automatically merge with the online GFW-List. Please manually update the GFW-List list after applying.")
gfwlist.rows = 13
gfwlist.wrap = "off"
gfwlist.cfgvalue = function(self, section)
	return NXFS.readfile(conf) or ""
end
gfwlist.write = function(self, section, value)
	NXFS.writefile(conf, value:gsub("\r\n", "\n"))
end

local addipconf = "/etc/v2ray/addinip.txt"

s:tab("addip",  translate("GFW-List Add-in IP"))
gfwaddin = s:taboption("addip", TextValue, "addipconf")
gfwaddin.description = translate("<br />（!）Note: IP add-in to GFW-List. Such as Telegram Messenger")
gfwaddin.rows = 13
gfwaddin.wrap = "off"
gfwaddin.cfgvalue = function(self, section)
	return NXFS.readfile(addipconf) or ""
end
gfwaddin.write = function(self, section, value)
	NXFS.writefile(addipconf, value:gsub("\r\n", "\n"))
end

s:tab("status",  translate("Status and Tools"))
s:taboption("status", DummyValue,"opennewwindow" , 
	translate("<input type=\"button\" class=\"cbi-button cbi-button-apply\" value=\"IP111.CN\" onclick=\"window.open('http://www.ip111.cn/')\" />"))


s:tab("watchdog",  translate("Watchdog Log"))
log = s:taboption("watchdog", TextValue, "sylogtext")
log.template = "cbi/tvalue"
log.rows = 13
log.wrap = "off"
log.readonly="readonly"

function log.cfgvalue(self, section)
  SYS.exec("[ -f /tmp/v2ray_watchdog.log ] && sed '1!G;h;$!d' /tmp/v2ray_watchdog.log > /tmp/v2raypro.log")
	return nixio.fs.readfile(dog)
end

function log.write(self, section, value)
	value = value:gsub("\r\n?", "\n")
	nixio.fs.writefile(dog, value)
end



t=m:section(TypedSection,"acl_rule",translate("<strong>Client Proxy Mode Settings</strong>"),
translate("Proxy mode settings can be set to specific LAN clients ( <font color=blue> No Proxy, Global Proxy, Game Mode</font>) . Does not need to be set by default."))
t.template="cbi/tblsection"
t.sortable=true
t.anonymous=true
t.addremove=true
e=t:option(Value,"ipaddr",translate("IP Address"))
e.width="40%"
e.datatype="ip4addr"
e.placeholder="0.0.0.0/0"
luci.ip.neighbors({ family = 4 }, function(entry)
	if entry.reachable then
		e:value(entry.dest:string())
	end
end)

e=t:option(ListValue,"filter_mode",translate("Proxy Mode"))
e.width="40%"
e.default="disable"
e.rmempty=false
e:value("disable",translate("No Proxy"))
e:value("global",translate("Global Proxy"))
e:value("game",translate("Game Mode"))

return m

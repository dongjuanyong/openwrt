
mp = Map("dnscrypt-proxy_2", translate("dnscrypt-proxy 2"))
mp.description = translate("A flexible DNS proxy, with support for modern encrypted DNS protocols such as DNSCrypt v2 and DNS-over-HTTPS.")

mp:section(SimpleSection).template  = "dnscrypt-proxy_2/dnscrypt-proxy_2_status"

s = mp:section(NamedSection, "dnscrypt", "service")
s.anonymouse = true

enabled = s:option(Flag, "enabled", translate("Enable"))
enabled.default = 0
enabled.rmempty = false

public_resolvers = s:option(Flag, "public_resolvers", translate("Use public-resolvers source"))
public_resolvers.default = 1
public_resolvers.rmempty = false

server_names = s:option(DynamicList, "server_names", translate("Servers to use"))
server_names.rmempty = false

listen_addresses = s:option(DynamicList, "listen_addresses", translate("Listen addresses (ip:port)"))
listen_addresses.rmempty = false

max_clients = s:option(Value, "max_clients", translate("Maximum client connections"))
max_clients.datatype = "uinteger"
max_clients.placeholder = 250

ipv4_servers = s:option(Flag, "ipv4_servers", translate("Use IPv4 servers"))
ipv4_servers.default = 1
ipv4_servers.rmempty = false

ipv6_servers = s:option(Flag, "ipv6_servers", translate("Use IPv6 servers"))
ipv6_servers.default = 0
ipv6_servers.rmempty = false

dnscrypt_servers = s:option(Flag, "dnscrypt_servers", translate("Use DNSCrypt servers"))
dnscrypt_servers.default = 1
dnscrypt_servers.rmempty = false

doh_servers = s:option(Flag, "doh_servers", translate("Use DNS-over-HTTPS servers"))
doh_servers.default = 1
doh_servers.rmempty = false

require_dnssec = s:option(Flag, "require_dnssec", translate("Only servers with DNSSEC support"))
require_dnssec.default = 0
require_dnssec.rmempty = false

require_nolog = s:option(Flag, "require_nolog", translate("Only servers without logging"))
require_nolog.default = 1
require_nolog.rmempty = false

require_nofilter = s:option(Flag, "require_nofilter", translate("Only servers without filter"))
require_nofilter.default = 1
require_nofilter.rmempty = false

force_tcp = s:option(Flag, "force_tcp", translate("Always use TCP to connect"))
force_tcp.default = 0
force_tcp.rmempty = false

timeout = s:option(Value, "timeout", translate("Query timeout"))
timeout.datatype = "uinteger"
timeout.placeholder = 2500

keepalive = s:option(Value, "keepalive", translate("Query keepalive"))
keepalive.datatype = "uinteger"
keepalive.placeholder = 30

cert_refresh_delay = s:option(Value, "cert_refresh_delay", translate("Certificate refresh delay"))
cert_refresh_delay.datatype = "uinteger"
cert_refresh_delay.placeholder = 240

fallback_resolver = s:option(Value, "fallback_resolver", translate("Fallback resolver"))
fallback_resolver.default = "114.114.114.114:53"
fallback_resolver.rmempty = false

ignore_system_dns = s:option(Flag, "ignore_system_dns", translate("Ignore system DNS"))
ignore_system_dns.default = 0
ignore_system_dns.rmempty = false

netprobe_timeout = s:option(Value, "netprobe_timeout", translate("Time to wait for network"))
netprobe_timeout.datatype = "uinteger"
netprobe_timeout.placeholder = 60

block_ipv6 = s:option(Flag, "block_ipv6", translate("Block IPV6 records"))
block_ipv6.default = 0
block_ipv6.rmempty = false

cache = s:option(Flag, "cache", translate("Enable DNS cache"))
cache.default = 1
cache.rmempty = false

local addconf = "/etc/dnscrypt-proxy/addconf"

addin = s:option(TextValue, "addinconf", translate(""), translate("Put additional configurations here."))
addin.rows = 5
addin.wrap = "off"
addin.cfgvalue = function(self, section)
	return nixio.fs.readfile(addconf) or ""
end
addin.write = function(self, section, value)
	nixio.fs.writefile(addconf, value:gsub("\r\n", "\n"))
end

return mp

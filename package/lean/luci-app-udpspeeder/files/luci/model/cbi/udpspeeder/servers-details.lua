local m, s, o
local sid = arg[1]

local modes = {
	"0",
	"1",
}

m = Map("udpspeeder", "%s - %s" %{translate("UDPspeeder"), translate("Edit Server")})
m.redirect = luci.dispatcher.build_url("admin/services/udpspeeder/servers")
m.sid = sid

if m.uci:get("udpspeeder", sid) ~= "servers" then
	luci.http.redirect(m.redirect)
	return
end

s = m:section(NamedSection, sid, "servers")
s.anonymous = true
s.addremove = false

o = s:option(Value, "alias", translate("Alias(optional)"))

o = s:option(Value, "server_addr", translate("Server"))
o.datatype = "host"
o.rmempty = false

o = s:option(Value, "server_port", translate("Server Port"))
o.datatype = "port"
o.placeholder = "8080"

o = s:option(Value, "listen_addr", translate("Local Listen Host"))
o.datatype = "ipaddr"
o.placeholder = "127.0.0.1"

o = s:option(Value, "listen_port", translate("Local Listen Port"))
o.datatype = "port"
o.placeholder = "2080"

o = s:option(Value, "key", translate("Password"))
o.password = true

o = s:option(Value, "fec", translate("FEC Parameters"), translate("x1:y1,x2:y2,.."))
o.placeholder = "20:10"

o = s:option(Value, "timeout", translate("Timeout"), translate("Unit: ms, default: 8ms"))

o = s:option(ListValue, "mode", translate("FEC Mode"), translate("Default: mode 0"))
for _, v in ipairs(modes) do o:value(v, v:lower()) end
o.default = "0"

o = s:option(Value, "mtu", translate("MTU"), translate("Default value: 1250"))

o = s:option(Value, "queue_len", translate("Queue Length"), translate("Default value: 200"))
o:depends("mode", "0")

o = s:option(Value, "jitter", translate("Jitter"), translate("Unit: ms, default value: 0"))

o = s:option(Value, "interval", translate("Interval"), translate("Unit: ms, default value: 0"))

o = s:option(Value, "random_drop", translate("Random Drop Packets"), translate("Unit: 0.01%, default value: 0"))

o = s:option(Flag, "disable_obscure", translate("Disable Obscure"), translate("Save a bit bandwidth and cpu"))

o = s:option(Value, "log_level", translate("Log Level"))
o.datatype = "range(0,6)"
o.placeholder = "4"

return m

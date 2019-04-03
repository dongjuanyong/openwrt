local m, s, o

m = Map("udpspeeder", "%s - %s" %{translate("UDPspeeder"), translate("Servers Manage")})

s = m:section(TypedSection, "servers")
s.anonymous = true
s.addremove = true
s.sortable = true
s.template = "cbi/tblsection"
s.extedit = luci.dispatcher.build_url("admin/services/udpspeeder/servers/%s")
function s.create(...)
	local sid = TypedSection.create(...)
	if sid then
		luci.http.redirect(s.extedit % sid)
		return
	end
end

o = s:option(DummyValue, "alias", translate("Alias"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or translate("None")
end

o = s:option(DummyValue, "_server_address", translate("Server Address"))
function o.cfgvalue(self, section)
	local server_addr = m.uci:get("udpspeeder", section, "server_addr") or "?"
	local server_port = m.uci:get("udpspeeder", section, "server_port") or "8080"
	return "%s:%s" %{server_addr, server_port}
end

o = s:option(DummyValue, "_listen_address", translate("Listen Address"))
function o.cfgvalue(self, section)
	local listen_addr = m.uci:get("udpspeeder", section, "listen_addr") or "127.0.0.1"
	local listen_port = m.uci:get("udpspeeder", section, "listen_port") or "2080"
	return "%s:%s" %{listen_addr, listen_port}
end

o = s:option(DummyValue, "fec", translate("FEC Parameters"))
function o.cfgvalue(...)
	local v = Value.cfgvalue(...)
	return v and v:lower() or ""
end

o = s:option(DummyValue, "mode", translate("FEC Mode"))
function o.cfgvalue(...)
	local v = Value.cfgvalue(...)
	return v and v:lower() or "0"
end

return m

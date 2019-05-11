
module("luci.controller.dnscrypt-proxy2", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/dnscrypt-proxy2") then
		return
	end
	
	entry({"admin", "services", "dnscrypt-proxy2"}, cbi("dnscrypt-proxy2/dnscrypt-proxy2"), _("dnscrypt-proxy 2"), 80).dependent=false
	entry({"admin", "services", "dnscrypt-proxy2","status"},call("act_status")).leaf=true
end

function act_status()
  local e={}
  e.running=luci.sys.call("pgrep dnscrypt-proxy >/dev/null")==0
  luci.http.prepare_content("application/json")
  luci.http.write_json(e)
end

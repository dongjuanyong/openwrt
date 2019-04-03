
module("luci.controller.dnscrypt-proxy_2", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/dnscrypt-proxy_2") then
		return
	end
	
	entry({"admin", "services", "dnscrypt-proxy_2"}, cbi("dnscrypt-proxy_2/dnscrypt-proxy_2"), _("dnscrypt-proxy 2"), 80).dependent=false
	entry({"admin", "services", "dnscrypt-proxy_2","status"},call("act_status")).leaf=true
end

function act_status()
  local e={}
  e.running=luci.sys.call("pgrep dnscrypt-proxy >/dev/null")==0
  luci.http.prepare_content("application/json")
  luci.http.write_json(e)
end

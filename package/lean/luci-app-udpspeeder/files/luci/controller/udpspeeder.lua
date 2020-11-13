module("luci.controller.udpspeeder", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/udpspeeder") then
		return
	end

	entry({"admin", "services", "udpspeeder"},
		firstchild(), _("UDPspeeder")).dependent = false

	entry({"admin", "services", "udpspeeder", "general"},
		cbi("udpspeeder/general"), _("Settings"), 1)

	entry({"admin", "services", "udpspeeder", "servers"},
		arcombine(cbi("udpspeeder/servers"), cbi("udpspeeder/servers-details")),
		_("Servers Manage"), 2).leaf = true

	entry({"admin", "services", "udpspeeder", "status"}, call("action_status"))
end

local function is_running(name)
	return luci.sys.call("pidof %s >/dev/null" %{name}) == 0
end

function action_status()
	luci.http.prepare_content("application/json")
	luci.http.write_json({
		running = is_running("udpspeeder")
	})
end

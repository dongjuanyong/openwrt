module("luci.controller.advanced",package.seeall)

function index()
	entry({"admin","status","advanced"}, template("advanced/index"), _("Advanced"), 99)
end

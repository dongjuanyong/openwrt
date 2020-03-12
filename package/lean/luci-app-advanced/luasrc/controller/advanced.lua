module("luci.controller.advanced",package.seeall)

function index()
	entry({"admin","status","advanced"}, template("advanced/index.htm"), _("Adanced"), 99)
end

#!/bin/sh
/etc/v2ray/gen-gfwlist.sh >/dev/null 2>&1

if [ -s "/tmp/ol_banned.txt" ];then
	sort -u /etc/v2ray/base-gfwlist.txt /tmp/ol_banned.txt > /tmp/china-banned
	if ( ! cmp -s /tmp/china-banned /etc/gfwlist/china-banned );then
		if [ -s "/tmp/china-banned" ];then
			mv /tmp/china-banned /etc/gfwlist/china-banned
			echo "Update GFW-List Done!"
		fi
	else
		echo "GFW-List No Change!"
	fi
fi

if [ -s "/tmp/ol_whitelist.txt" ];then
	if ( ! cmp -s /tmp/ol_whitelist.txt /etc/gfwlist/whitelist );then
		mv /tmp/ol_whitelist.txt /etc/gfwlist/whitelist
		echo "Update GFW-List Done!"
	else
		echo "GFW-List No Change!"
	fi
fi

rm -f /tmp/gfwlist.txt
rm -f /tmp/ol_banned.txt
rm -f /tmp/ol_whitelist.txt
rm -f /tmp/china-banned

/etc/init.d/v2raypro restart

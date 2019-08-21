#!/bin/sh
adbyby_enable=$(uci get adbyby.@adbyby[0].enable 2>/dev/null)

if [ $adbyby_enable -eq 1 ]; then
	sleep 40 && /etc/init.d/adbyby restart
fi


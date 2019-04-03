--[[
 Auto generate config for Project V
 Author: @libc0607
]]--

local conf_path, json_path = ...
conf_path = conf_path or "v2raypro"
json_path = json_path or "/tmp/config.json"

local local_listen_port = 7070
local local_socks_port = 1080
local local_http_port = 3128

local cjson = require "cjson.safe"
local ucursor = require "luci.model.uci".cursor()
local lip = require "luci.ip"

local v2ray_alternative_proxy = ucursor:get(conf_path, "v2raypro", "alternative_proxy")
local v2ray_stream_mode = ucursor:get(conf_path, "v2raypro", "network_type")	-- tcp/kcp/ws
local v2ray_reverse_enabled = ucursor:get(conf_path, "v2raypro", "renabled")
local v2ray_reverse_domain = (ucursor:get(conf_path, "v2raypro", "rserver_domain") ~= nil) and ucursor:get(conf_path, "v2raypro", "rserver_domain") or "www.myowndomain.com"
local v2ray_reverse_diffserver = ucursor:get(conf_path, "v2raypro", "rdiffsvr")
local v2ray_reverse_protocol = ucursor:get(conf_path, "v2raypro", "rprotocol")
local v2ray_reverse_streammode = ucursor:get(conf_path, "v2raypro", "rnetwork_type")

function v2ray_get_conf_list(op)
	local t = {}
	for k, v in pairs(ucursor:get_list(conf_path, 'v2ray', op)) do
		table.insert(t, v)
	end
	return t
end

function check_addr_type(addr)
	local ip = luci.ip.new(addr, 32)
	if ip == nil then
		return "domain"
	elseif ip:is4() then
		return "ipv4"
	elseif ip:is6() then
		return "ipv6"
	end
end

function get_ip_list_by_domain(domain)
	local domain_list = {}
	local cmd = io.popen("nslookup " .. domain .. " |grep Address | awk {'print $3'}")
	for cmd_line in cmd:lines() do
		if check_addr_type(cmd_line) == "ipv4" then
			table.insert(domain_list, cmd_line)
		elseif check_addr_type(cmd_line) == "ipv6" then
			table.insert(domain_list, cmd_line)
		end
	end
	return domain_list
end

local v2ray	= {
	log = {
		access = "",
		error = "",
		loglevel = "none"
	},
	reverse = (v2ray_reverse_enabled == "1") and {
		bridges = {
		  [1] = {
			tag = "bridge",
			domain = v2ray_reverse_domain
		  }
		}
	} or nil,
	inbounds = {
	  [1] = {
		protocol = "dokodemo-door",
		port = local_listen_port,
		sniffing = (ucursor:get(conf_path, "v2raypro", "safe_dns_tcp") == "0") and {
			enable = true,
			destOverride = {
				[1] = "http",
				[2] = "tls"
			}
		} or nil,
		settings = {
			network = "tcp,udp",
			timeout = 30,
			followRedirect = true
		}
	  },
	  [2] = (v2ray_alternative_proxy == "1") and {
		protocol = "socks",
		port = local_socks_port,
		sniffing = {
			enable = true,
			destOverride = {
				[1] = "http",
				[2] = "tls"
			}
		},
		settings = {
			udp = true
		}
	  } or nil,
	  [3] = (v2ray_alternative_proxy == "1") and {
		protocol = "http",
		port = local_http_port,
		settings = {
			timeout = 30
		}
	  } or nil
	},
	outbounds = {
	  [1] = {
		tag = "default",
		protocol = "vmess",
		settings = {
			vnext = {
			  [1] = {
				address = ucursor:get(conf_path, "v2raypro", "address"),
				port = tonumber(ucursor:get(conf_path, "v2raypro", "port")),
				users = {
				  [1] = {
				    id = ucursor:get(conf_path, "v2raypro", "id"),
					alterId = tonumber(ucursor:get(conf_path, "v2raypro", "alterId")),
					security = ucursor:get(conf_path, "v2raypro", "security")
				  }
				}
			  }
			}
		},
		streamSettings = {
			network = ucursor:get(conf_path, "v2raypro", "network_type"),
			security = (ucursor:get(conf_path, "v2raypro", "tls") == "1") and "tls" or "none",
			tcpSettings = (v2ray_stream_mode == "tcp" and ucursor:get(conf_path, "v2raypro", "tcp_obfs") == "http") and {
				header = {
					type = ucursor:get(conf_path, "v2raypro", "tcp_obfs"),
					request = {
						version = "1.1",
						method = "GET",
						path = v2ray_get_conf_list('tcp_path'),
						headers = {
							Host = v2ray_get_conf_list('tcp_host'),
							User_Agent = {
								"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.75 Safari/537.36",
								"Mozilla/5.0 (iPhone; CPU iPhone OS 10_0_2 like Mac OS X) AppleWebKit/601.1 (KHTML, like Gecko) CriOS/53.0.2785.109 Mobile/14A456 Safari/601.1.46"
							},
							Accept_Encoding = {"gzip, deflate"},
							Connection = {"keep-alive"},
							Pragma = "no-cache"
						}
					},
					response = {
						version = "1.1",
						status = "200",
						reason = "OK",
						headers = {
							Content_Type = {"application/octet-stream","video/mpeg"},
							Transfer_Encoding = {"chunked"},
							Connection= {"keep-alive"},
							Pragma = "no-cache"
						}
					}
				}
			} or nil,

			kcpSettings = (v2ray_stream_mode == "kcp") and {
				mtu = tonumber(ucursor:get(conf_path, "v2raypro", "kcp_mtu")),
				tti = tonumber(ucursor:get(conf_path, "v2raypro", "kcp_tti")),
				uplinkCapacity = tonumber(ucursor:get(conf_path, "v2raypro", "kcp_uplink")),
				downlinkCapacity = tonumber(ucursor:get(conf_path, "v2raypro", "kcp_downlink")),
				congestion = (ucursor:get(conf_path, "v2raypro", "kcp_congestion") == "1") and true or false,
				readBufferSize = tonumber(ucursor:get(conf_path, "v2raypro", "kcp_readbuf")),
				writeBufferSize = tonumber(ucursor:get(conf_path, "v2raypro", "kcp_writebuf")),
				header = {
					type = ucursor:get(conf_path, "v2raypro", "kcp_obfs")
				}
			} or nil,

			wsSettings = (v2ray_stream_mode == "ws") and {
				path = ucursor:get(conf_path, "v2raypro", "ws_path"),
				headers = (ucursor:get(conf_path, "v2raypro", "ws_headers") ~= nil) and {
					Host = ucursor:get(conf_path, "v2raypro", "ws_headers")
				} or nil
			} or nil,

			httpSettings = (v2ray_stream_mode == "h2") and {
				path = ucursor:get(conf_path, "v2raypro", "h2_path"),
				host = (ucursor:get(conf_path, "v2raypro", "h2_domain") ~= nil) and {
					ucursor:get(conf_path, "v2raypro", "h2_domain")
				} or nil
			} or nil,

			quicSettings = (v2ray_stream_mode == "quic") and {
				security = ucursor:get(conf_path, "v2raypro", "quic_security"),
				key = ucursor:get(conf_path, "v2raypro", "quic_key"),
				header = {
					type = ucursor:get(conf_path, "v2raypro", "quic_obfs")
				}
			} or nil
		},
		mux = {
			enabled = (ucursor:get(conf_path, "v2raypro", "mux") == "1") and true or false
		}
	  },
	  [2] = {
		tag = "direct",
		protocol = "freedom",
		settings = {
		}
	  },
	  [3] = (v2ray_reverse_enabled == "1" and v2ray_reverse_diffserver == "1") and {
		tag = "tunnel",
		protocol = ucursor:get(conf_path, "v2raypro", "rprotocol"),
		settings = {
			vnext = (v2ray_reverse_protocol == "vmess") and {
			  [1] = {
				address = ucursor:get(conf_path, "v2raypro", "raddress"),
				port = tonumber(ucursor:get(conf_path, "v2raypro", "rport")),
				users = {
				  [1] = {
				    id = ucursor:get(conf_path, "v2raypro", "rid"),
					alterId = tonumber(ucursor:get(conf_path, "v2raypro", "ralterId")),
					security = ucursor:get(conf_path, "v2raypro", "rsecurity")
				  }
				}
			  }
			} or nil,
			servers = (v2ray_reverse_protocol == "shadowsocks" or v2ray_reverse_protocol == "socks") and {
			  [1] = {
				address = ucursor:get(conf_path, "v2raypro", "raddress"),
				port = tonumber(ucursor:get(conf_path, "v2raypro", "rport")),
				users = (ucursor:get(conf_path, "v2raypro", "rsocksuser") ~= nil) and {
				  [1] = {
					user = ucursor:get(conf_path, "v2raypro", "rsocksuser"),
					pass = ucursor:get(conf_path, "v2raypro", "rpassword")
				  }
				} or nil,
				method = (v2ray_reverse_protocol == "shadowsocks") and ucursor:get(conf_path, "v2raypro", "rssmethod") or nil,
				password = (v2ray_reverse_protocol == "shadowsocks") and ucursor:get(conf_path, "v2raypro", "rpassword") or nil,
				ota = (ucursor:get(conf_path, "v2raypro", "rssota") == "1") and true or nil
			  }
			} or nil
		},
		streamSettings = {
			network = ucursor:get(conf_path, "v2raypro", "rnetwork_type"),
			security = (ucursor:get(conf_path, "v2raypro", "rtls") == "1") and "tls" or "none",
			tcpSettings = (v2ray_reverse_streammode == "tcp" and ucursor:get(conf_path, "v2raypro", "rtcp_obfs") == "http") and {
				header = {
					type = ucursor:get(conf_path, "v2raypro", "rtcp_obfs"),
					request = {
						version = "1.1",
						method = "GET",
						path = v2ray_get_conf_list('rtcp_path'),
						headers = {
							Host = v2ray_get_conf_list('rtcp_host'),
							User_Agent = {
								"Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.75 Safari/537.36",
								"Mozilla/5.0 (iPhone; CPU iPhone OS 10_0_2 like Mac OS X) AppleWebKit/601.1 (KHTML, like Gecko) CriOS/53.0.2785.109 Mobile/14A456 Safari/601.1.46"
							},
							Accept_Encoding = {"gzip, deflate"},
							Connection = {"keep-alive"},
							Pragma = "no-cache"
						}
					},
					response = {
						version = "1.1",
						status = "200",
						reason = "OK",
						headers = {
							Content_Type = {"application/octet-stream","video/mpeg"},
							Transfer_Encoding = {"chunked"},
							Connection= {"keep-alive"},
							Pragma = "no-cache"
						}
					}
				}
			} or nil,

			kcpSettings = (v2ray_reverse_streammode == "kcp") and {
				mtu = tonumber(ucursor:get(conf_path, "v2raypro", "rkcp_mtu")),
				tti = tonumber(ucursor:get(conf_path, "v2raypro", "rkcp_tti")),
				uplinkCapacity = tonumber(ucursor:get(conf_path, "v2raypro", "rkcp_uplink")),
				downlinkCapacity = tonumber(ucursor:get(conf_path, "v2raypro", "rkcp_downlink")),
				congestion = (ucursor:get(conf_path, "v2raypro", "rkcp_congestion") == "1") and true or false,
				readBufferSize = tonumber(ucursor:get(conf_path, "v2raypro", "rkcp_readbuf")),
				writeBufferSize = tonumber(ucursor:get(conf_path, "v2raypro", "rkcp_writebuf")),
				header = {
					type = ucursor:get(conf_path, "v2raypro", "rkcp_obfs")
				}
			} or nil,

			wsSettings = (v2ray_reverse_streammode == "ws") and {
				path = ucursor:get(conf_path, "v2raypro", "rws_path"),
				headers = (ucursor:get(conf_path, "v2raypro", "rws_headers") ~= nil) and {
					Host = ucursor:get(conf_path, "v2raypro", "rws_headers")
				} or nil
			} or nil,

			httpSettings = (v2ray_reverse_streammode == "h2") and {
				path = ucursor:get(conf_path, "v2raypro", "rh2_path"),
				host = (ucursor:get(conf_path, "v2raypro", "rh2_domain") ~= nil) and {
					ucursor:get(conf_path, "v2raypro", "rh2_domain")
				} or nil
			} or nil,

			quicSettings = (v2ray_reverse_streammode == "quic") and {
				security = ucursor:get(conf_path, "v2raypro", "rquic_security"),
				key = ucursor:get(conf_path, "v2raypro", "rquic_key"),
				header = {
					type = ucursor:get(conf_path, "v2raypro", "rquic_obfs")
				}
			} or nil
		},
		mux = {
			enabled = (ucursor:get(conf_path, "v2raypro", "rmux") == "1") and true or false
		}
	  } or nil
	},
	routing = (v2ray_reverse_enabled == '1') and {
		rules = {
		  [1] = {
			type = "field",
			inboundTag = {
			  [1] = "bridge"
			},
			domain = {
			  [1] = "full:" .. v2ray_reverse_domain
			},
			outboundTag = (v2ray_reverse_diffserver == '1') and "tunnel" or "default"
		  },
		  [2] = {
			type = "field",
			inboundTag = {
			  [1] = "bridge"
			},
			outboundTag = "direct"
		  }
		}
	} or nil,
	dns = {
		servers = {
		  [1] = "localhost"
		}
	}
}

-- Generate config json to <json_path>
local json_raw = cjson.encode(v2ray)
local json_file = io.open(json_path, "w+")
io.output(json_file)
io.write(json_raw)
io.close(json_file)

-- change '_' to '-'
local keys_including_minus = {"User_Agent", "Content_Type", "Accept_Encoding", "Transfer_Encoding"}
local keys_corrected = {"User-Agent", "Content-Type", "Accept-Encoding", "Transfer-Encoding"}
for k, v in pairs(keys_including_minus) do
	os.execute("sed -i 's/" ..v.. "/" ..keys_corrected[k].. "/g' " .. json_path)
end

-- change "\/" to "/"
os.execute("sed -i 's/\\\\\\//\\//g' ".. json_path)

print("V2ray config generated at " .. json_path)

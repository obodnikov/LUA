-- file: setup.lua
local module = {}

function module.start()
  print("Configuring Wifi ...")
  local station_cfg = {}
  station_cfg.ssid = ssid.SSID

  
  wifi.setmode(wifi.STATION)
  if (string.len(ssid.PASSWD) > 7) then
      station_cfg.pwd = ssid.PASSWD
      wifi.sta.config(station_cfg)
  else
      wifi.sta.config(station_cfg)
  end
  if (ssid.IP ~= nil ) then wifi.sta.setip(ssid.IP) end
  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,function()
    print("Connected to SSID: " .. ssid.SSID)
--    mdns.register("sqowe-" .. node.chipid(), {hardware='SqoweSensor'})
    app.start()
  end )
  wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED,function(T)
    print("Error connected to Wifi: Reason "..T.reason)
    if (T.reason > 199) then
            wifi.eventmon.unregister(wifi.eventmon.STA_DISCONNECTED)
            tmr.stop(liveControl)
            app = nil
            mqttConfig = nil
            button = nil
            collectgarbage()
            tmr.unregister(liveControl)
            tmr.alarm(liveControl,3600000, tmr.ALARM_SINGLE, function()
                print("Restart")
                node.restart()
            end)
            if file.exists("serverHTTP.lua") then dofile("serverHTTP.lua")
            else dofile("serverHTTP.lc") end
    end
  end )


  wifi.sta.connect()

--  wifi.sta.eventMonStart()

--  tmr.alarm(tmrWifiConnect, 500, 1, wifi_wait_ip)
--  wifi.sta.getap(wifi_start)
end

return module

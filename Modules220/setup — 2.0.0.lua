-- file: setup.lua
local module = {}

function module.start()
  print("Configuring Wifi ...")
  wifi.setmode(wifi.STATION)
  if (string.len(ssid.PASSWD) > 7) then
      wifi.sta.config(ssid.SSID,ssid.PASSWD)
  else
      wifi.sta.config(ssid.SSID)
  end
  if (ssid.IP ~= nil ) then wifi.sta.setip(ssid.IP) end
  wifi.sta.eventMonReg(wifi.STA_GOTIP,function()
    print("Connected to SSID: " .. ssid.SSID)
--    mdns.register("sqowe-" .. node.chipid(), {hardware='SqoweSensor'})
    app.start()
  end )
  wifi.sta.eventMonReg(wifi.STA_APNOTFOUND,function()
    print("Not found SSID")
    tmr.stop(liveControl)
    app = nil
    mqttConfig = nil
    collectgarbage()
    tmr.unregister(liveControl)
    tmr.alarm(liveControl,3600000, tmr.ALARM_SINGLE, function()
        print("Restart")
        node.restart()
    end)
    if file.exists("serverHTTP.lua") then dofile("serverHTTP.lua")
    else dofile("serverHTTP.lc") end
  end )
    wifi.sta.eventMonReg(wifi.STA_WRONGPWD,function()
    print("WRONGPWD")
    tmr.stop(liveControl)
    app = nil
    mqttConfig = nil
    collectgarbage()
    tmr.unregister(liveControl)
    tmr.alarm(liveControl,3600000, tmr.ALARM_SINGLE, function()
        print("Restart")
        node.restart()
    end)
    if file.exists("serverHTTP.lua") then dofile("serverHTTP.lua")
    else dofile("serverHTTP.lc") end
  end )

  wifi.sta.connect()

  wifi.sta.eventMonStart()

--  tmr.alarm(tmrWifiConnect, 500, 1, wifi_wait_ip)
--  wifi.sta.getap(wifi_start)
end

return module

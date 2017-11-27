-- file : application.lua
local module = {}
m = nil

-- local m = mqtt.Client(config.ID, 120, mqttConfig.LOGIN, mqttConfig.PASS)

local checkMQTT = 0
local MQTTfailCount = 0

local tmrMQTTCheck = tmr.create()
-- local tmrMQTTPublish = tmr.create()
local tmrTempPublish = tmr.create()
local tmrMQTTReconnect = tmr.create()

local function checkMQTTstatus()

    if ( checkMQTT == 0 ) then
        MQTTfailCount = MQTTfailCount + 1
        print("We lost MQTT " .. MQTTfailCount .. " times")
    else
      MQTTfailCount = 0
    end

    if (MQTTfailCount > 3) then
      print("Restart module")
      node.restart()
    end

end


local function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end




    local function publish_temp()

      local status, temp, humi, temp_dec, humi_dec = dht.read(config.DHT)
      local VCC = adc.read(0)
      tmr.delay(500000)
      status, temp, humi, temp_dec, humi_dec = dht.read(config.DHT)


      m:publish(config.ENDPOINT .. config.ID .. "/temp", temp .. "." .. temp_dec,0,0, function()
      m:publish(config.ENDPOINT .. config.ID .. "/humi" , humi .. "." .. humi_dec,0,0, function()
      m:publish(config.ENDPOINT .. config.ID .. "/lwt","ON",0,0, function()
        print("Publish has been completed")
        checkMQTT = 1
        MQTTfailCount = 0
            ds18b20.read(
              function(ind,rom,res,temp_ow,tdec_ow,par)
                m:publish(config.ENDPOINT .. config.ID .. "/" .. string.format("%02X%02X%02X%02X%02X%02X%02X%02X",string.match(rom,"(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)")), temp_ow .. "." .. tdec_ow,0,0, function()
                  print(ind,string.format("%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X",string.match(rom,"(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%d+)")),res,temp_ow,tdec,par)
                end)
              end,{});
      end )
    end )
  end )

  end

  function module.publish_topic(topic,data)
    checkMQTT = 0;
    m:publish(config.ENDPOINT .. config.ID .. "/" .. topic, data,0,0, function()
           m:publish(config.ENDPOINT .. config.ID .. "/lwt","ON",0,0, function()
             print("Publish has been completed")
             checkMQTT = 1
             MQTTfailCount = 0
           end )
         end )
  end


-- Sends my id to the broker for registration
local function register_myself()
    m:subscribe(config.ENDPOINT .. config.ID .. "/commands/#",0,function(conn)
        print("Successfully subscribed to data endpoint")
    end)
end


local function mqtt_connect()
  m:connect(mqttConfig.HOST, mqttConfig.PORT, 1, 0, function(con)

      print("Connected to MQTT Brocker " .. mqttConfig.HOST .. " at port " ..mqttConfig.PORT)
      register_myself()
      m:publish(config.ENDPOINT .. config.ID .. "/Structure",config.STRUCTURE,0,0)

      -- And then pings each 1000 milliseconds
      tmr.unregister(liveControl)
      tmr.unregister(tmrMQTTReconnect)
--      tmr.alarm(tmrMQTTPublish, config.publishTime, 1, publish_switches)
      tmr.alarm(tmrTempPublish, config.publishTime, 1, publish_temp)
      checkMQTT = 1
      tmr.alarm(tmrMQTTCheck,config.publishTime+1000,1,checkMQTTstatus)

end, function(con, reason)

      print("Error connection to MQTT server " .. mqttConfig.HOST .. " port " .. mqttConfig.PORT .. " with reason " .. reason)
      print("Stop all timers and try to check connection in 25 seconds")
--      tmr.stop(tmrMQTTPublish)
      tmr.stop(tmrTempPublish)
      tmr.stop(tmrMQTTCheck)
      tmr.alarm(tmrMQTTReconnect, 25000, tmr.ALARM_SINGLE, function()

          if wifi.sta.status() == wifi.STA_GOTIP then
              print ("Wifi exist. Lost MQTT try to reconnect now!!")
              mqtt_connect()        --body...
          else
              print ("Wifi lost. Error code is " .. wifi.sta.status() .. "\nWaiting for eventmon callback")
          end
      end )

end)

end

local function mqtt_start()
    m = mqtt.Client(config.ID, 120, mqttConfig.LOGIN, mqttConfig.PASS)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data)
      if data ~= nil then
        print(topic .. ": " .. data)

          if(topic == config.ENDPOINT .. config.ID .. "/commands/RCSwitch") then
              print(":RCSwitch:" .. data .. ":#")
            elseif(topic == config.ENDPOINT .. config.ID .. "/commands/Download") then
              collectgarbage()
              httpDL = require("httpDL")
              --               IP/Host        URL                                  Destination  Finished Callback
              httpDL.download(config.UPDATESITE, 80,
                            config.ENDPOINT .. config.ID .. "/" .. data, data, function (payload)
                  print("Download " .. data .. " complete")
                  m:publish(config.ENDPOINT .. config.ID .. "/Update","Download " .. data .. " complete",0,0)
                  package.loaded["httpDL"]=nil
                  httpDL = nil
              end)

--              httpDL = nil
--              package.loaded["httpDL"]=nil
              collectgarbage()
          elseif(topic == config.ENDPOINT .. config.ID .. "/commands/Compile") then
              node.compile(data)
              m:publish(config.ENDPOINT .. config.ID .. "/Update",data .. " compiled",0,0)
            elseif(topic == config.ENDPOINT .. config.ID .. "/commands/Remove") then
                file.remove(data)
                m:publish(config.ENDPOINT .. config.ID .. "/Update",data .. " removed",0,0)
              elseif(topic == config.ENDPOINT .. config.ID .. "/commands/Restart") then
                  if(data == "ON") then node.restart() end
            end
--            publish_switches()
      end
    end)
    -- Connect to broker



    m:lwt(config.ENDPOINT .. config.ID.."/lwt", "OFF", 0, 0)

    m:on("offline", function(con)
        print ("MQTT offline")
    end)


        mqtt_connect()

end

function module.start()
--  tmr.softwd(-1)
--  tmr.interval(tmrLED, 600)
  ds18b20.setup(config.SCL)
  wifi.eventmon.unregister(wifi.eventmon.STA_DISCONNECTED)
  mqtt_start()
end

return module

-- End of file

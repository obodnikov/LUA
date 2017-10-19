-- file : application.lua
local module = {}
m = nil

-- local m = mqtt.Client(config.ID, 120, mqttConfig.LOGIN, mqttConfig.PASS)

local checkMQTT = 0
local MQTTfailCount = 0



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
      m:publish(config.ENDPOINT .. config.ID .. "/temp", temp .. "." .. temp_dec,0,0, function()
      m:publish(config.ENDPOINT .. config.ID .. "/humi" , humi .. "." .. humi_dec,0,0, function()
      m:publish(config.ENDPOINT .. config.ID .. "/adc",string.format("%d", VCC),0,0, function()
      m:publish(config.ENDPOINT .. config.ID .. "/lwt","ON",0,0, function()
        print("Publish has been completed")
        checkMQTT = 1
        MQTTfailCount = 0
      end )
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
  m:connect(mqttConfig.HOST, mqttConfig.PORT, 0, 1, function(con)

      print("Connected to MQTT Brocker " .. mqttConfig.HOST .. " at port " ..mqttConfig.PORT)
      register_myself()
      m:publish(config.ENDPOINT .. config.ID .. "/Structure",config.STRUCTURE,0,0)

      -- And then pings each 1000 milliseconds
      tmr.unregister(2)
      tmr.unregister(3)
--      tmr.alarm(tmrMQTTPublish, config.publishTime, 1, publish_switches)
      tmr.alarm(4, config.publishTime, 1, publish_temp)
      checkMQTT = 1
      tmr.alarm(3,config.publishTime+1000,1,checkMQTTstatus)


      uart.on("data", "$", function(data)

         local t = {}  -- NOTE: use {n = 0} in Lua-5.0
         t = split(data,":")

         if (t[2] == "send2mqtt") then
--               locat strTopic = t[3] .. "/" .. t[4]
              m:publish(config.ENDPOINT .. config.ID .. "/" .. t[3] .. "/" .. t[4],t[5],0,0)
          end
      end, 0)
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
--            publish_switches()
          end
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
  wifi.eventmon.unregister(wifi.eventmon.STA_DISCONNECTED)
  mqtt_start()
end

return module

-- End of file

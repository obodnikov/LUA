-- file : application.lua
local module = {}
m = nil

local checkMQTT = 0
local MQTTfailCount = 0

local tmrMQTTCheck = tmr.create()
local tmrMQTTPublish = tmr.create()

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


local function publish_switches(data)

    checkMQTT = 0
    t = split(data,":")

    if t[2] ~= nil then
    m:publish(config.ENDPOINT .. config.ID .. "/"..t[0],t[1],0,0, function()
           m:publish(config.ENDPOINT .. config.ID .. "/lwt","ON",0,0, function()
             print("Publish has been completed")
             checkMQTT = 1
             MQTTfailCount = 0
           end )
    end )
  else
    m:publish(config.ENDPOINT .. config.ID .. "/lwt","ON",0,0, function()
      print("Publish has been completed")
      checkMQTT = 1
      MQTTfailCount = 0
    end )
  end

end


-- Sends my id to the broker for registration
local function register_myself()
    m:subscribe(config.ENDPOINT .. config.ID .. "/commands/#",0,function(conn)
        print("Successfully subscribed to data endpoint")
    end)
end

local function mqtt_start()
    m = mqtt.Client(config.ID, 120, mqttConfig.LOGIN, mqttConfig.PASS)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data)
      if data ~= nil then
        print(topic .. ": " .. data)

          if(topic == config.ENDPOINT .. config.ID .. "/commands/powerSW1") then
              if(data == "ON") then gpio.write(config.SSW1,gpio.HIGH)
              elseif(data == "OFF") then gpio.write(config.SSW1,gpio.LOW)
              end
              publish_switches()
          elseif(topic == config.ENDPOINT .. config.ID .. "/commands/Download") then
              collectgarbage()
              httpDL = require("httpDL")
              --               IP/Host        URL                                  Destination  Finished Callback
              httpDL.download(config.UPDATESITE, 80,
                            config.ENDPOINT .. config.ID .. "/" .. data, data, function (payload)
                  print("Download " .. data .. " complete")
                  m:publish(config.ENDPOINT .. config.ID .. "/Update","Download " .. data .. " complete",0,0)
              end)

              httpDL = nil
              package.loaded["httpDL"]=nil
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

      end
    end)
    -- Connect to broker
    m:connect(mqttConfig.HOST, mqttConfig.PORT, 1, 1, function(con)
        register_myself()
        m:publish(config.ENDPOINT .. config.ID .. "/Structure",config.STRUCTURE,0,0)

        -- And then pings each 1000 milliseconds
        tmr.unregister(liveControl)
        tmr.alarm(tmrMQTTPublish, 300000, 1, publish_switches)

        checkMQTT = 1
        tmr.alarm(tmrMQTTCheck,150000,1,checkMQTTstatus)
        uart.on("data", "$", publish_switches(data), 0)
    end)

    m:lwt(config.ENDPOINT .. config.ID.."/lwt", "OFF", 0, 0)

    m:on("offline", function(con)
        tmr.stop(tmrMQTTPublish)
        print ("MQTT offline")
    end)

end

function module.start()
--  tmr.softwd(-1)
  tmr.interval(tmrLED, 600)
  mqtt_start()
end

return module

-- End of file

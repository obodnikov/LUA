-- file : application.lua
local module = {}
m = nil

local Publish = true


-- Sends a simple ping to the broker
local function publish_sensors()
    local status, temp, humi, temp_dec, humi_dec = dht.read(config.DHT)
    local VCC = adc.read(0)
    if(Publish) then
    m:publish(config.ENDPOINT .. config.ID .. "/temp",string.format("%d.%03d", temp,temp_dec),0,0, function()
      m:publish(config.ENDPOINT .. config.ID .. "/humi",string.format("%d.%03d", humi,humi_dec),0,0, function()
        m:publish(config.ENDPOINT .. config.ID .. "/VCC",string.format("%d", VCC),0,0, function()
          m:publish(config.ENDPOINT .. config.ID .. "/Structure",config.STRUCTURE,0,0, function()
         m:publish(config.ENDPOINT .. config.ID .. "/lwt","ON",0,0, function()
            print(config.ENDPOINT .. config.ID .. "/temp\t" .. string.format("%d.%03d", temp,temp_dec))
            print("Time to send " .. string.format("%d", tmr.now()))
--            gpio.write(config.DHT_POWER,gpio.LOW)
            node.dsleep(config.publishTime*1000)
          end )
         end )
       end )
     end )
    end )
  end

end




-- Sends my id to the broker for registration
local function register_myself()
    m:subscribe(config.ENDPOINT .. config.ID,0,function(conn)
        print("Successfully subscribed to data endpoint")
    end)
end

local function mqtt_start()
    m = mqtt.Client(config.ID, config.publishTime/1000+60, mqttConfig.LOGIN, mqttConfig.PASS)
    -- register message callback beforehand
    m:on("message", function(conn, topic, data)

      if data ~= nil then
        Publish = false
      if(topic == config.ENDPOINT .. config.ID .. "/commands/Download") then
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
--        register_myself()
        -- And then pings each 1000 milliseconds
--        tmr.stop(6)
--        tmr.alarm(6, 2000, 1, publish_switches)
--        tmr.stop(5)
--        tmr.alarm(5,config.publishTime,1,publish_sensors)
--    tmr.stop(1)
    tmr.unregister(liveControl)
    publish_sensors()

    end,
    function(con,reason)
      if(reason < 0) then
        print("Connection lost\nWaiting for connection restore")
      else
        print("Wrong authentication!!! Halted!")
      end
      print("There are no MQTT server")
      node.dsleep(config.publishTime*1000)
    end)

    m:lwt(config.ENDPOINT .. config.ID.."/lwt", "OFF", 0, 0)

    m:on("offline", function(con)
        print ("MQTT offline")

    end)

end

function module.start()
  print("Starting MQTT Connection")
  mqtt_start()
end

return module

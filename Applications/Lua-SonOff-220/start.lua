app = require("app_1switch")
--button = require("button")
ssid = require("ssid")
mqttConfig = require("mqtt-config")
-- serverHTTP = require("serverHTTP")
config = require("config_1switch")
setup = require("setup")

--button.start()

collectgarbage()

liveControl = tmr.create()
tmr.alarm(liveControl,1200000, tmr.ALARM_SINGLE, function()
    print("WatchDog fight! Go to restart!")
    node.restart()
end)


tmrLED = tmr.create()
tmr.alarm(tmrLED, 200, 1, function()
  if (gpio.read(config.LED) == gpio.HIGH) then gpio.write(config.LED, gpio.LOW)
  else gpio.write(config.LED, gpio.HIGH)
  end
end)


setup.start()

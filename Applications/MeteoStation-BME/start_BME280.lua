app = require("application-BME280")
--button = require("button")
ssid = require("ssid")
mqttConfig = require("mqtt-config")
-- serverHTTP = require("serverHTTP")
config = require("config-BME280")
setup = require("setup")

--button.start()

--collectgarbage()

liveControl = tmr.create()
tmr.alarm(liveControl,20000, tmr.ALARM_SINGLE, function()
    print("WatchDog fight! Go to sleep!")
    node.dsleep(config.publishTime*1000)
end)

setup.start()

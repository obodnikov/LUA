app = require("application-motion")
--button = require("button")
ssid = require("ssid")
mqttConfig = require("mqtt-config")
-- serverHTTP = require("serverHTTP")
config = require("config-motion")
setup = require("setup")

--button.start()

collectgarbage()

liveControl = tmr.create()
tmr.alarm(liveControl,1200000, tmr.ALARM_SINGLE, function()
    print("WatchDog fight! Go to restart!")
    node.restart()
end)

setup.start()

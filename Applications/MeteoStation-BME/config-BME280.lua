-- file : config.lua
local module = {}

-- module.ID = node.chipid()
module.ID = node.chipid()

module.ENDPOINT = "/sqowe/Sensors/"
module.UPDATESITE = "iot-updates.sqowe.com"
module.STRUCTURE = "{\
  \"state\": {\
    \"temp\": \"Number [%.2f °C]\",\
    \"humi\": \"Number [%.2f %%]\",\
    \"pressure\": \"Number [%.2f mmHg]\",\
    \"adc\": \"Number [%d]\"\
  },\
  \"lwt\": \"lwt\"\
}"

module.DHT = 2            -- GPIO4
module.SDA = 2            -- GPIO4
module.SCL = 1        -- GPIO5
module.FLOWER_POWER = 5   -- GPIO14


gpio.mode(module.FLOWER_POWER, gpio.OUTPUT)

gpio.write(module.FLOWER_POWER,gpio.HIGH)



module.STATUS = {}
module.STATUS[0] = "OFF"
module.STATUS[1] = "ON"

module.publishTime = 1800000
module.serverWorkTime = 600000
module.sleepAfterError = 3600000

return module

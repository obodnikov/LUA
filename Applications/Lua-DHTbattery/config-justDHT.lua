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
    \"VCC\": \"Number [%d mV]\"\
  },\
  \"lwt\": \"lwt\"\
}"

module.DHT = 1            -- GPIO5
--module.DHT_POWER = 3      -- GPIO0
--module.DHT_GND = 2        -- GPIO4

--module.FLOWER_POWER = 5   -- GPIO14
--module.FLOWER_GND = 6     -- GPIO12

--module.FIRE1 = 8


--gpio.mode(module.DHT, gpio.INPUT)

--gpio.mode(module.DHT_POWER, gpio.OUTPUT)
--gpio.mode(module.DHT_GND, gpio.OUTPUT)
--gpio.mode(module.FLOWER_POWER, gpio.OUTPUT)
--gpio.mode(module.FLOWER_GND, gpio.OUTPUT)

--gpio.write(module.DHT_GND,gpio.LOW)
--gpio.write(module.DHT_POWER,gpio.HIGH)
--gpio.write(module.FLOWER_POWER,gpio.HIGH)
--gpio.write(module.FLOWER_GND,gpio.LOW)


module.STATUS = {}
module.STATUS[0] = "OFF"
module.STATUS[1] = "ON"

module.publishTime = 1800000
module.serverWorkTime = 600000
module.sleepAfterError = 3600000000

return module

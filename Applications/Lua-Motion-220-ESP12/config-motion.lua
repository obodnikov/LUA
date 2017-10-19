-- file : config.lua
local module = {}

-- module.ID = node.chipid()
module.ID = node.chipid()

module.ENDPOINT = "/sqowe/Sensors/"
module.UPDATESITE = "iot-updates.sqowe.com"


module.MOTION = 1            -- GPIO5

gpio.mode(module.MOTION, gpio.INT)



module.STATUS = {}
module.STATUS[0] = "OFF"
module.STATUS[1] = "ON"

module.publishTime = 300000

return module

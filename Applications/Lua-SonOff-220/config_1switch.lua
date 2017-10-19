-- file : config.lua
local module = {}



module.ID = node.chipid()
-- module.ID = "VerandaControl"

module.ENDPOINT = "/sqowe/Switches/"
module.UPDATESITE = "iot-updates.sqowe.com"
module.STRUCTURE = "{\
  \"state\": {\
    \"powerSW1\": \"Switch\"\
  },\
  \"commands\": {\
    \"powerSW1\": \"Switch\"\
  },\
  \"lwt\": \"lwt\"\
}"

module.SSW1 = 6   -- GPIO12
module.LED = 7    -- GPIO13



  print("Switch OFF all switches")

  gpio.mode(module.SSW1, gpio.OUTPUT)
  gpio.mode(module.LED, gpio.OUTPUT)


  gpio.write(module.SSW1, gpio.LOW)
  gpio.write(module.LED, gpio.LOW)

  module.STATUS = {}
  module.STATUS[0] = "OFF"
  module.STATUS[1] = "ON"

  module.publishTime = 30000

return module

-- file : config.lua

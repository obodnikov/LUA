-- file : config.lua
local module = {}



module.ID = node.chipid()
-- module.ID = "VerandaControl"

module.ENDPOINT = "/sqowe/UARTbrocker/"
module.UPDATESITE = "iot-updates.sqowe.com"
module.STRUCTURE = "{\
  \"lwt\": \"lwt\"\
}"


module.SSW1 = 8  -- GPIO 15
module.SSW2 = 0   -- GPIO 16
module.SW10A1 = 6 -- GPIO 12
module.SW10A2 = 7  -- GPIO 13

module.bSSW1 = 1    -- GPIO 5
module.bSSW2 = 3    -- GPIO 0
module.bSW10A1 = 4  -- GPIO 2
module.bSW10A2 = 5  -- GPIO 14
-- module.MOVE = 12
module.DHT = 2      -- GPIO 4


  print("Switch OFF all switches")

  gpio.mode(module.SSW1, gpio.OUTPUT)
  gpio.mode(module.SSW2, gpio.OUTPUT)
  gpio.mode(module.SW10A1, gpio.OUTPUT)
  gpio.mode(module.SW10A2, gpio.OUTPUT)
--  gpio.mode(module.MOVE, gpio.INPUT)


  gpio.write(module.SSW1, gpio.LOW)
  gpio.write(module.SSW2, gpio.LOW)
  gpio.write(module.SW10A1, gpio.LOW)
  gpio.write(module.SW10A2, gpio.LOW)


  print("STart listening buttons")
  gpio.mode(module.bSSW1,gpio.INT,gpio.PULLUP)
  gpio.mode(module.bSSW2,gpio.INT,gpio.PULLUP)
  gpio.mode(module.bSW10A1,gpio.INT,gpio.PULLUP)
  gpio.mode(module.bSW10A2,gpio.INT,gpio.PULLUP)



module.STATUS = {}
module.STATUS[0] = "OFF"
module.STATUS[1] = "ON"

module.STATUS10A = {}
module.STATUS10A[0] = "ON"
module.STATUS10A[1] = "OFF"

module.swMap = {}
module.swMap[1] = module.SSW1
module.swMap[2] = module.SSW2
module.swMap[3] = module.SW10A1
module.swMap[4] = module.SW10A2

module.bMap = {}
module.bMap[1] = module.bSSW1
module.bMap[2] = module.bSSW2

module.cMap = {}
module.cMap[1] = module.bSW10A1
module.cMap[2] = module.bSW10A2

module.strMap = {}
module.strMap[1] = "bSW10A1"
module.strMap[2] = "bSW10A2"

module.publishTime = 30000

return module

-- file : config.lua

-- file : config.lua
local module = {}



module.ID = node.chipid()
-- module.ID = "VerandaControl"

module.ENDPOINT = "/sqowe/UARTbrocker/"
module.UPDATESITE = "iot-updates.sqowe.com"
module.STRUCTURE = "{\
  \"lwt\": \"lwt\"\
}"


  module.STATUS = {}
  module.STATUS[0] = "OFF"
  module.STATUS[1] = "ON"

  module.publishTime = 300000

return module

-- file : config.lua

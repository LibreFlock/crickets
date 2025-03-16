local random = require("math").random
local os = require("os")
local io = require("io")
local unser = require("serialization").unserialize

local fh = io.open("addrs", "r")
local addrs = unser(fh:read(900000000000))
fh:close()

while true do
  for _, addr in pairs(addrs) do
    component.proxy(addr).setLampColor(random(0,0xffff))
  end
  os.sleep(1)
end
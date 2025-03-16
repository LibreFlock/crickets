local io = require("io")
local unser = require("serialization").unserialize
local component = require("component")
local os = require("os")

local fh = io.open("addrs")
local addrs = unser(fh:read(900000000000000000000))
fh:close()

for _, addr in pairs(addrs) do
  component.proxy(addr).setLampColor(0)
  os.sleep(1)
end

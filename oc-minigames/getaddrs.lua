local io = require("io")
local computer = require("computer")
local ser = require("serialization").serialize

local fh = io.open("addrs", "w")
local addrs = {}

while true do
  local type, addr, _ = computer.pullSignal()

  if type == "key_down" then break end
  if type == "component_added" then
    print(addr)
    addrs[#addrs+1] = addr
  end
end
print(ser(addrs))
fh:write(ser(addrs))
fh:close()
print("Registration has finished!")
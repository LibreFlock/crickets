local component = require("component")
local event = require("event")
local computer = require("computer")

local gpu = component.gpu

local palette = {
  red = 0xff0000,
  green = 0x00ff00,
  blue = 0x0000ff,
  magenta = 0xff00ff,
  yellow = 0xffff00,
  black = 0x000000,
  white = 0xffffff,
  cyan = 0x00ffff
}
local modes = {
  pencil = 1,
  erase = 2,
  fill = 3,
  pick = 4
}
local w, h = gpu.getViewport()
local toolbarSelected = modes.pencil
function toolbar()
  gpu.set(1, h, "[ Pencil ] [ Erase ] [ Fill ] [ Pick ]")
  gpu.set(w-6, 1, "Quit >")
  gpu.setBackground(palette.white)
  gpu.setForeground(palette.black)

  if toolbarSelected == modes.pencil then
    gpu.set(2, h, " Pencil ")
  end
  if toolbarSelected == modes.erase then
    gpu.set(13, h, " Erase ")
  end
  if toolbarSelected == modes.fill then
    gpu.set(23, h, " Fill ")
  end
  if toolbarSelected == modes.fill then
    gpu.set(32, h, " Pick ")
  end
  
  gpu.setBackground(palette.black)
  gpu.setForeground(palette.white)
  
end  
function main()
  -- local _, _, x, y = event.pull("touch")
  local ev, _, x, y = computer.pullSignal()
  if ev ~= "touch" and ev ~= "drag" then return main() end
  if y == 1 and x > (w - 7) then return end
  if y == h and x < 38 then -- toolbar momen
    if x > 0 and x < 11 then toolbarSelected = modes.pencil end
    if x > 11 and x < 21 then toolbarSelected = modes.erase end
    if x > 21 and x < 30 then toolbarSelected = modes.fill end
    if x > 30 and x < 38 then toolbarSelected = modes.pick end
    toolbar()
    return main()
  end
  if toolbarSelected == modes.pencil then
    gpu.set(x, y, "@")
  end
  if toolbarSelected == modes.erase then
    gpu.set(x, y, " ")
  end
  main()
end

toolbar()
main()
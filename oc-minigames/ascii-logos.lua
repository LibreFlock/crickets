local component = require("component")
local term = require("term")
local event = require("event")

local gpu = component.gpu

local t = {
  sleep_delay = 0.1
}

function t.crepsterRW()
  -- term.setCursor(0, 0)
  local colors = {
    light_green = 0x4ff095,
    green = 0x0cf06f,
    dark_green = 0x289959,
    black = 0x161716,
    light_black = 0x1e221f
  }
  gpu.setPaletteColor(9, colors.light_green) -- light green
  gpu.setPaletteColor(10, colors.green) -- green
  gpu.setPaletteColor(11, colors.dark_green) --- dark green
  gpu.setPaletteColor(12, colors.black) -- black
  gpu.setPaletteColor(13, colors.light_black)
  gpu.setBackground(colors.green)
  gpu.fill(1, 1, 10, 5, " ") -- head base
  os.sleep(t.sleep_delay)
  gpu.fill(2, 6, 8, 6, " ") -- middle
  os.sleep(t.sleep_delay)
  gpu.fill(1, 12, 4, 3, " ") -- feet 1
  os.sleep(t.sleep_delay)
  gpu.fill(7, 12, 4, 3, " ") -- feet 2
  os.sleep(t.sleep_delay)
  gpu.setBackground(colors.black)
  gpu.fill(2, 2, 2, 2, " ") -- eye 1
  os.sleep(t.sleep_delay)
  gpu.fill(8, 2, 2, 2, " ") -- eye 2
  os.sleep(t.sleep_delay)
  
  gpu.fill(5, 4, 2, 2, " ") -- mouth base
  os.sleep(t.sleep_delay)
  gpu.fill(4, 5, 4, 1, " ") -- mouth line
  
  -- le light
  gpu.setBackground(colors.light_green)
  os.sleep(t.sleep_delay)
  gpu.fill(1, 1, 1, 5, " ") -- head
  os.sleep(t.sleep_delay)
  gpu.fill(2, 5, 1, 7, " ") -- middle
  os.sleep(t.sleep_delay)
  gpu.fill(1, 12, 1, 3, " ") -- feet
  os.sleep(t.sleep_delay)
  gpu.setBackground(colors.green)
  gpu.setForeground(colors.light_green)  
  gpu.fill(1, 14, 4, 1, "▄") -- feet horizontal
  os.sleep(t.sleep_delay)
  gpu.fill(1, 1, 6, 1, "▀") -- head horizontal
  gpu.setBackground(colors.light_green)
  os.sleep(t.sleep_delay)
  gpu.set(1, 1, " ") -- head horizontal fix
  os.sleep(t.sleep_delay)
  gpu.set(1, 14, " ") -- feet horizontal fix
  
  -- shade
  gpu.setBackground(0x0000000)
  gpu.setForeground(colors.light_black)
  gpu.fill(1, 6, 1, 6, "▒")
  os.sleep(t.sleep_delay)
  gpu.fill(5, 12, 2, 3, "▒")
  os.sleep(t.sleep_delay)
  gpu.fill(10, 6, 1, 6, "▒")
  gpu.setForeground(0xfffffff)
  os.sleep(t.sleep_delay)
  gpu.set(16, 8, "Crepster re●written")
  -- draw le box
  os.sleep(t.sleep_delay)
  gpu.set(15, 7, "┌")
  os.sleep(t.sleep_delay)
  gpu.fill(16, 7, 19, 1, "─")
  os.sleep(t.sleep_delay)
  gpu.set(35, 7, "┐")
  os.sleep(t.sleep_delay)
  gpu.set(35, 8, "│")
  os.sleep(t.sleep_delay)
  gpu.set(35, 9, "┘")
  os.sleep(t.sleep_delay)
  gpu.set(15, 8, "│")
  os.sleep(t.sleep_delay)
  gpu.set(15, 9, "└")
  os.sleep(t.sleep_delay)
  gpu.fill(16, 9, 19, 1, "─")
  term.setCursor(1, 15)
end
function t.__tester()
t.crepsterRW()
while true do
local _, _, x, y = event.pull("touch")

if x == 1 and y == 1 then
  break
end
gpu.setForeground(0xffffff)
gpu.set(1, 1, "X] " .. x .. " " .. y)
end
-- os.sleep(1)
end
return t
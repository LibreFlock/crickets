local term = require("term")
local component = require("component")
local gpu = component.gpu

local t = {
  char = {
    down_right = "┌",
    down_left = "┐",
    up_right = "└",
    up_left = "┘",
    vertical = "│",
    horizontal = "─"
  }
}

function t.Box(x, y, width, height)
  gpu.set(x, y, t.char.down_right)
  gpu.fill(x+1, y, width-1, 1, t.char.horizontal)
  
  gpu.set(x+width, y, t.char.down_left)
  gpu.fill(x, y+1, 1, height-1, t.char.vertical)
  
  gpu.set(x, y+height, t.char.up_right)
  
  gpu.fill(x+1, y+height, width-1, 1, t.char.horizontal)
  gpu.set(x+width, y+height, t.char.up_left)
  
  gpu.fill(x+width, y+1, 1, height-1, t.char.vertical)
  
  return {
    x = x, y = y,
    width = width, height = height,
    set = function(self, x, y, text)
      gpu.set(self.x+x, self.y+y, text)
    end,
    fill = function(self, x, y, width, height, text)
      gpu.fill(self.x+x, self.y+y, width, height, text)
    end
  }
end

-- t.Box(1, 1, 10, 5)
-- term.setCursor(1, 7)
return t
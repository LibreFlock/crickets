local component = require("component")
local event     =     require("event")
local shell     =     require("shell")
local sides     =     require("sides")
local math      =      require("math")
-- ^ i never do this but it looks cool so im doing it now


local smallScreen = "6d6ec0f0-6166-462a-93b7-595e4ac20b8c"
local bigScreen = "4cbc1f33-edda-4961-816e-c359d0fecf77"

local splitter = component.net_splitter
local gpu = component.gpu
local debug = component.debug

games = {
  ["Crepster"]="crepsterRW",
  ["Test Minigame"] = "testmini"
}

mods = {
  ["Test Minigame"] = {
    "--some-mod",
    "--racialslurs"
  },
  ["Crepster"] = {
    "--shovel",
    "--bow",
    "--lava",
    "--cake",
    "--instant-health",
    "--slime",
    "--cock-rider",
    "--flint-and-steel"
  }
}

-- Connect to the screen

splitter.open(sides.front)
gpu.bind(bigScreen)

-- Run the dam thing

local w, h = gpu.getResolution()

function centertext(y, text)
  x = math.floor(w/2-#text/2)
  gpu.set(x, y, text)
end

function horizontal_single_choice(y, btncol, buttons)
  -- ########          ################
  -- ##Test##          ##Another Test##
  -- ########          ################
  local totalw = 0
  local btndim = {}

  for _, btn in ipairs(buttons) do
    totalw = totalw + #btn + 4 + 10
  end
  --totalw = totalw - 10
  local containedwidth = totalw/#buttons

  for i, btn in ipairs(buttons) do
    local btnwidth = #btn+4
    local startx = containedwidth/2 - btnwidth/2 + (containedwidth*(i-1))
    --local startx = 
    btndim[btn] = {
      {w/2-totalw/2+startx, y},
      {w/2-totalw/2+startx+#btn+4, y+3}
    }
  end

  for text, dim in pairs(btndim) do
    gpu.setBackground(btncol)
    gpu.fill(dim[1][1], dim[1][2], #text+4, 3, " ")
    gpu.set(dim[1][1]+2, dim[1][2]+1, text)
  end

  while true do
    local _, _, x, y, mbtn =  event.pull("touch")
    if mbtn ~= 0 then goto continue end

    for i, btn in ipairs(buttons) do
      local dim = btndim[btn]
      if dim[1][1] <= x and math.floor(dim[1][2]) <= y and dim[2][1] >= x and math.floor(dim[2][2]) >= y then
        return i
      end
    end
    ::continue::
  end
end

function center_single_button(y, btncol, text)
  local obj = {}
  obj.btnwidth = #text+4
  obj.x = w/2-obj.btnwidth/2
  obj.y = y
  obj.btncol = btncol
  obj.text = text
  
  gpu.setBackground(obj.btncol)
  gpu.fill(obj.x, obj.y, obj.btnwidth, 3, " ")
  gpu.set(obj.x+2, obj.y+1, obj.text)

  function obj.click(self, mx, my)
    if self.x <= mx and self.y <= my and self.x+self.btnwidth >= mx and self.y+3 >= my then return true end
    return false
  end
  return obj
end

function vertical_multi_choice(sx, sy, buttons)
  local obj = {}
  obj.btndims = {}
  obj.buttons = buttons
  obj.state = {}

  for i, button in ipairs(buttons) do
    obj.state[button] = false
    obj.btndims[button] = {
      { sx, sy+(i-1)*2 },
      { sx+#button, sy+(i-1)*2 }
    }

    gpu.setBackground(0x00ffff) -- 0x00ffff is the deactivated color
    gpu.set(obj.btndims[button][1][1], obj.btndims[button][1][2], button)
  end

  function obj.click(self, mx, my)
    for i, btn in ipairs(self.buttons) do
      local dim = self.btndims[btn]
      if dim[1][1] <= mx and math.floor(dim[1][2]) <= my and dim[2][1] >= mx and math.floor(dim[2][2]) >= my then
        if not self.state[btn] then
          self.state[btn] = true
          gpu.setBackground(0x0000ff)
        else
          self.state[btn] = false
          gpu.setBackground(0x00ffff)
        end
        gpu.set(dim[1][1], dim[1][2], btn)
        return true
      end
    end
    return false
  end

  function obj.getActive(self)
    local active = {}
    for name, state in pairs(self.state) do
      if state then active[#active+1] = name end
    end
    return active
  end

  return obj
end

function clear()
  gpu.setBackground(0x11aacc)
  gpu.fill(1,1,w,h," ")
end

function doohickey()
  clear()
  centertext(h/4-5, "Welcome to the Minigame Selector")
  
  local buttons = {}
  for game, _ in pairs(games) do
    buttons[#buttons+1] = game
  end

  local chosen_game = buttons[horizontal_single_choice(h/4, 0x00ffff, buttons)]
  
  clear()
  centertext(h/4-5, "Chosen game: " .. chosen_game)
  centertext(h/4-4, "Please choose with whom you want to play and what modifiers you would like to have")

  local playbtn = center_single_button(h/4*3, 0x00ffff, "Play")
  local modmenu = vertical_multi_choice(w/4*3, h/4+5, mods[chosen_game])
  local playermenu = vertical_multi_choice(w/4, h/4+5, debug.getPlayers())

  while true do
    local _, _, mx, my, mbtn = event.pull("touch")
    if mbtn ~= 0 then goto continue end
    if not modmenu:click(mx, my) then
      if not playermenu:click(mx, my) then
        if playbtn:click(mx, my) then break end
      end
    end
    ::continue::
  end
  
  gpu.setBackground(0)
  gpu.setForeground(0xffffff)
  gpu.fill(1,1,w,h," ")

  local command = games[chosen_game] .. " " .. table.concat(modmenu:getActive(), " ") .. " " .. table.concat(playermenu:getActive(), " ")
  shell.execute(command)
  
end

local status, err = pcall(doohickey)
-- Disconnect from the screen
gpu.bind(smallScreen)
splitter.close(sides.front)

-- Log any errors
if not status then
  error(err)
end
local component = require("component")
local debug = component.debug
local shell = require("shell")
local tape = component.tape_drive
local s = require("serialization")
local mg = require("minigamelib")
local io = require("io")
local math = require("math")
local transposer = component.transposer
local sides = require("sides")

local f = io.open("/etc/tapes")
local data = f:read()
f:close()
data = s.unserialize(data)

local args, opt = shell.parse(...)

local pp = mg.get_patched_print(component.chat_box, opt)

local print = pp.print

-- render the fishing rod

-- end
local slot = math.random(data.tapes)
transposer.transferItem(sides.top,sides.bottom,1,slot,1)
tape.play()
debug.runCommand('gamerule sendCommandFeedback false')
print("Loading map...")

-- debug.runCommand('clone 69384 89 69474 69352 71 69496 69351 71 69426')
local mappath = "./maps/fusis/" .. (opt.map or "1") .. ".map"
print(mappath)
mg.load_map(mappath)
os.sleep(1.5)
print("Clearing players inventories (and giving fishing rods)...")

for i=1,#args,1
do
  -- debug.runCommand('clear ' .. args[i])
  local player = debug.getPlayer(args[i])
  player.clearInventory()
  player.insertItem("minecraft:fishing_rod", 1, 0, "")
  -- player.setGameType is weird af
  debug.runCommand('gamemode 0 ' .. args[i])
  if opt['no-hit'] then
    debug.runCommand('effect ' .. args[i] .. ' minecraft:weakness 999 2 true')
  end
  if opt['rush'] then
    debug.runCommand('effect ' .. args[i] .. ' minecraft:speed 999 1 true')
  end
end

print("Spreading players...")

local alivePlayers = mg.shallow_copy(args)

-- debug.runCommand('spreadplayers 69364 69439 10 13 false ' .. mg.join(alivePlayers, " "))
mg.spread_players(alivePlayers)

function eliminatePlayer(name, tindex)
  debug.runCommand('tellraw @a {"text": '.. s.serialize(name) .. ', "color": "yellow", "extra": {"text": " was eliminated!", "color": "red"}}')
  table.remove(alivePlayers, tindex)
end

function includes(tab, s)
  for i=1,#tab,1
  do
    if tab[i] == s then return true end
  end
  return false
end

function findIndex(tab, t)
  for i=1,#tab,1
  do
    if tab[i] == t then return i end
  end
  return -1
end

function gameEnded()
  -- print(1, #alivePlayers)
  local toEliminate = {}
  for i=1,#alivePlayers,1
  do
    local player = debug.getPlayer(alivePlayers[i])
    local x, y, z = player.getPosition()
    if y < 72 then 
      if not includes(toEliminate, alivePlayers[i]) then table.insert(toEliminate, alivePlayers[i]) end
    end
  end
  -- print(2, #alivePlayers)
  for i=1,#toEliminate,1
  do
    local playerName = toEliminate[i]
    print("eliminating", playerName)
    mg.get_player(playerName):setGamemode("3")
    if findIndex(alivePlayers, playerName) ~= -1 then
      table.remove(alivePlayers, findIndex(alivePlayers, playerName))
    end
  end
  if #alivePlayers == 1 then return true, alivePlayers[1] end
  if #alivePlayers == 0 then return true, "No one" end
  return false, ""
end

local ended, winner = gameEnded()
while not ended
do
  ended, winner = gameEnded()
  os.sleep(opt['game-end-check-delay'] or 0.3)
end

debug.runCommand('title @a title ' .. s.serialize(winner .. ' won!'))

-- tp 'em back
mg.for_each(args, function (playerName)
  local player = mg.get_player(playerName)
  player.entity.setPosition(69390, 77, 69433)
  player:setGamemode(mg.gamemodes.creative)
  player:clearEffects()
  -- debug.runCommand('effect ' .. playerName .. ' clear')
  player.entity.clearInventory()
end)

mg.unload_map()
debug.runCommand('gamerule sendCommandFeedback true')
tape.stop()
tape.seek(-99999999999999999999999999999999999999999999999999999)
transposer.transferItem(sides.bottom,sides.top,1,1,slot)
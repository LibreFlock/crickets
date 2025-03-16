local shell = require("shell")
local args, opt = shell.parse(...)
local component = require("component")
local debug = component.debug
local chatbox = component.chat_box
local tape = component.tape_drive
local qol = require("minigamelib")
local math = require("math")
local transposer = component.transposer
local sides = require("sides")
local io = require("io")
local unser = require("serialization").unserialize

local ogprint = print

local f = io.open("/etc/tapes")
local data = f:read()
f:close()
data = unser(data)
print(data.tapes)

local function print(...)
  if opt.chatbox then
    chatbox.say(qol.join(table.pack(...), "    "))
  else
    ogprint(...)
  end
end

if opt.h or opt.help then
  print([[help:
crepster1v1 players... [--time=<time>] [--no-shovel] [--no-water] [--no-lava] [--flint-and-steel] [--food] [--eggs] [--no-spread-players] [--no-remove-arena] [--floor-block=<block>] [--no-hit] [--crystals] [--obsidian] [--fishingrod]
]])
  os.exit(0)
end

function table.copy(t)
  local u = {}  
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end
------------------------------------
local slot = math.random(data.tapes)
transposer.transferItem(sides.top,sides.bottom,1,slot,1)
tape.play()
------------------------------------
local players = table.copy(args)
local alivePlayers = table.copy(args)
chatbox.say("Loading crepster...")
debug.runCommand('gamerule sendCommandFeedback false')
debug.runCommand('scoreboard objectives add death deathCount "Death"')

debug.runCommand("fill 69385 76 69426 69351 76 69450 " .. (opt["floor-block"] or "dirt"))
debug.runCommand("fill 69385 77 69426 69351 83 69450 air")
debug.runCommand('time set ' .. (opt["time"] or "day"))

local tpbackCoords = {69389, 77, 69438}

for i = 1, #players, 1
do
  print(players[i])
  debug.runCommand("scoreboard players add " .. players[i] .. " death 0")
  debug.runCommand('title ' .. players[i] .. ' title "Crepster 1v1"')
  debug.runCommand('title ' .. players[i] .. ' subtitle "Players: ' .. table.concat(players, ', ') .. '"')
  local scoreboard = debug.getScoreboard()
  scoreboard.setPlayerScore(players[i], "death", 0)
  local player = debug.getPlayer(players[i])
  debug.runCommand('clear ' .. players[i])
  debug.runCommand('effect ' .. players[i] .. ' saturation 5 255 true')
  -- debug.runCommand('tp ' .. players[i] .. ' 69367 77 69438');
  debug.runCommand('give ' .. players[i] .. ' spawn_egg 64 0 {EntityTag: {id: "minecraft:creeper"}}')
  if not opt["no-shovel"] then
    -- debug.runCommand('give ' .. players[i] .. ' diamond_shovel')
    player.insertItem('golden_shovel', 1, 0, '')
  end
  if not opt["no-lava"] then
    -- debug.runCommand('give ' .. players[i] .. ' lava_bucket')
    player.insertItem('lava_bucket', 1, 0, '')
  end
  if opt["chicken-sandwich"] then
    player.insertItem("spawn_egg",1,0,'{EntityTag:{id:"minecraft:squid",CustomName:"ChickenSandwich"}}')
  end
  if not opt["no-water"] then
    -- debug.runCommand('give ' .. players[i] .. ' water_bucket')
    player.insertItem('water_bucket', 1, 0, '')
  end
  if opt["flint-and-steel"] then
    -- debug.runCommand('give ' .. players[i] .. ' flint_and_steel')
    player.insertItem('flint_and_steel', 1, 0, '')
  end
  if opt.food then
    -- debug.runCommand('give ' .. players[i] .. ' cooked_beef 64')
    player.insertItem('cooked_beef', 64, 0, '')
    -- player.insertItem('cake', 1, 0, '')
  end
  if opt.eggs then
    -- debug.runCommand('give ' .. players[i] .. ' egg 16')
    player.insertItem('egg', 16, 0, '')
  end
  -- debug.runCommand('gamemode 0 ' .. players[i])
  if opt['no-hit'] then
    debug.runCommand('effect ' .. players[i] .. ' minecraft:weakness 600 255 true')
  end
  if opt.crystals then
    debug.runCommand('give ' .. players[i] .. ' minecraft:end_crystal 64')
  end
  if opt.obsidian then
    debug.runCommand('give ' .. players[i] .. ' minecraft:obsidian 64')
  end
  if opt.fishingrod then
    debug.runCommand('give ' .. players[i] .. ' minecraft:fishing_rod')
  end
  if opt.bow then
    debug.runCommand('give ' .. players[i] .. ' minecraft:bow')
  end
  if opt.arrows then
    debug.runCommand('give ' .. players[i] .. ' minecraft:arrow ' .. opt.arrows)
  end
  player.setGameType('survival')
  player.setHealth(20)
end
if not opt["no-spread-players"] then
  debug.runCommand('spreadplayers 69367 69438 10 11 false ' .. players[1] .. ' ' .. players[2])
end
for i=1,#players,1
do
 -- debug.runCommand('clear ' .. players[i])
end
function hasEnded()
  local scoreboard = debug.getScoreboard()
  for ij = 1, #alivePlayers, 1
  do
    local player = alivePlayers[ij] or "unknown"
    --- print(scoreboard.getPlayerScore(players[i], "death"))
    --- print(alivePlayers[ij])
    local x, y, z = debug.getPlayer(alivePlayers[ij]).getPosition()
    if tonumber(y) < 75 then
      -- return true
      table.remove(alivePlayers, ij)
      if #alivePlayers == 1 then return true end
    end
    if scoreboard.getPlayerScore(player, "death") > 0 then
      print('he ded')
      scoreboard.setPlayerScore(player, "death", 0)
      -- return true
      table.remove(alivePlayers, ij)
      if #alivePlayers == 1 then return true else
        debug.runCommand('gamemode 3 ' .. player)
      end
    end
  end
  if #alivePlayers == 1 then
    return true
  end
  return false
end
while (not hasEnded())
do
os.sleep(0.5)
end
os.sleep(3)
debug.runCommand('kill @e[type=chicken]')
debug.runCommand('kill @e[type=creeper]')
for i = 1, #players, 1
do
  debug.runCommand('clear ' .. players[i])
  debug.runCommand('gamemode 1 ' .. players[i])
  debug.runCommand('effect ' .. players[i] .. ' clear')
  debug.runCommand('tp ' .. players[i] .. ' ' .. tpbackCoords[1] .. ' ' .. tpbackCoords[2] .. ' ' .. tpbackCoords[3])
end
if not opt["no-remove-arena"] then
  debug.runCommand('fill 69385 76 69426 69351 83 69450 air')
end
debug.runCommand('scoreboard objectives remove death')
debug.runCommand('title @a title "' .. alivePlayers[1] .. ' won!"')
tape.stop()
tape.seek(-99999999999999999999999999999999999999999999999999999)
transposer.transferItem(sides.bottom,sides.top,1,1,slot)
debug.runCommand('gamerule sendCommandFeedback true')
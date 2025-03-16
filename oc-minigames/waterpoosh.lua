local debug = require("component").debug
local args, opt = require('shell').parse(...)

function table.copy(t)
  local u = {}
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end
debug.runCommand('gamerule sendCommandFeedback false')
debug.runCommand('title @a title "Waterpoösh"')
debug.runCommand('title @a subtitle "Idea: bruhman745583; Written by: nicejsiscool"')

os.sleep(2)

local time = opt.time or 5

-- debug.runCommand('gamerule sendCommandFeedback false') -- prevent spam in chat

while time ~= 0
do
  debug.runCommand('title @a actionbar {"text": "Starting in ' .. time .. '...", "color": "black", "bold": true}')
  time = time - 1
  os.sleep(1)
end

debug.runCommand('gamerule sendCommandFeedback true') -- revert it bacc
-- debug.runCommand('title @a title "Get ready!"')


local players = table.copy(args)
local alivePlayers = table.copy(args)

local coords = {69368, 88, 69438}

for i=1, #players, 1
do
  local player = debug.getPlayer(players[i])
  player.setPosition(coords[1], coords[2], coords[3])
  player.setGameType('survival')
  player.setHealth(20)
  debug.runCommand("clear " .. players[i])
  if opt['no-punch'] then
    debug.runCommand('effect ' .. players[i] .. ' minecraft:weakness 600 255 true')
  end
  if opt['no-damage'] then
    debug.runCommand('effect ' .. players[i] .. ' minecraft:regeneration 600 20 true')
  end
end

function hasEnded ()
  for ij=1, #alivePlayers, 1
  do
    if not alivePlayers[ij] then return true end
    local player = debug.getPlayer(alivePlayers[ij])
    local x, y, z = player.getPosition()
    if y < 80 then
      table.remove(alivePlayers, ij)
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
for i=1, #players, 1
do
  local player = debug.getPlayer(players[i])
  debug.runCommand('gamemode 1 ' .. players[i])
  player.setPosition(69390, 77, 69435)
  debug.runCommand('effect ' .. players[i] .. ' clear')
end
debug.runCommand('title @a title "' .. alivePlayers[1] .. ' wins!"')
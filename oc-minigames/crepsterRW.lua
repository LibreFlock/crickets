local mg = require("minigamelib")
local shell = require("shell")
local component = require("component")
local debug = component.debug
local bgjl = require("bgjobs")
local s = require("serialization")
local coroutine = require("coroutine")
local term = require("term")
local logos = require("ascii-logos")
local cpsmods = require("crepster-mods")

term.clear()
logos.crepsterRW()

local bgj = bgjl.BackgroundJobsArray()
local args, opt = shell.parse(...)
local players = mg.Players(args)
local lprint = mg.get_patched_print(component.chat_box, opt)

mg.disable_command_feedback()

local deathtr = mg.create_death_tracker(players.alive)

function eliminate(player)
  players:eliminate(player)
  debug.runCommand('title @a actionbar ' .. s.serialize(player .. " has been eliminated"))
  local mgplayer = mg.get_player(player)
  mgplayer:setGamemode(mg.gamemodes.creative)
  bgj:push(function()
    bgjl.sleep(3) -- 2 seconds -- 15 ticks
    mgplayer:setGamemode(mg.gamemodes.creative) -- just to make sure
    mgplayer:teleport(mg.create_vector(79, 75, 634))
    mgplayer:clear()
  end)
end

local slot = mg.random_tape()

local arena = {
  -- mg.create_vector(69385, 76, 69450), mg.create_vector(69351, 76, 69426)
  mg.create_vector(78, 68, 643), mg.create_vector(110, 68, 666)
}
if opt.map then
  mg.load_map("./maps/crepster1v1/" .. opt.map .. ".map")
else
  debug.runCommand('fill ' .. tostring(arena[1]) .. ' ' .. tostring(arena[2]) .. ' dirt')
end

mg.for_each(players.alive, function (p)
  local player = mg.get_player(p)
  if not opt['no-clear'] then player:clear() end
  player:give("minecraft:spawn_egg", 64, 0, "{EntityTag:{id:\"minecraft:creeper\"}}")
  player:setGamemode(mg.gamemodes.survival)
end)

mg.spread_players(players.alive)

local endCheck = mg.game_end_check_builder(1, eliminate, function(p)
  -- print(p)
  if p == nil then return false end
  local player = mg.get_player(p)
  return player:getY() < 68 or deathtr:died(p)
end)

-- giving the additional items is now a background job lets fucking gooo
bgj:push(cpsmods(opt, players, mg))

mg.game_loop(
  endCheck, players,
  function ()
    -- print("tick")
    bgj:process()
    -- local _, _, x, y = event.pull(0.01, "touch")
    
  end, -- tick
  0.05, -- tick delay (50ms a.k.a. 20 ticks/s)
  function (winners)
    mg.unload_map()
    deathtr:delete()
    mg.for_each(players:all(), function(playerName)
      local player = mg.get_player(playerName)
      if not opt['no-clear'] then player:clear() end
      player:setGamemode(mg.gamemodes.creative)
      player:teleport(mg.create_vector(83, 75, 634))
    end)
    debug.runCommand('title @a title ' .. s.serialize(winners[1] .. " won!"))
    mg.enable_command_feedback()
    mg.return_tape(slot)
  end -- end func
)
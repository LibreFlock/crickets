-- Minigame Library (version 0.3.0 alpha)
-- Written by: nicejsiscool, bruhman745583 (e_ man)

local component = require("component")
local debug = component.debug
local s = require("serialization")
local io = require("io")
local sides = require("sides")
local transposer = component.transposer
local tape_drive = component.tape_drive
local event = require("event")
local t = {
  title={},
  gamemodes={
    creative="1",
    survival="0",
    adventure="2",
    spectator="3"
  },
  debug=debug
}

function t.shallow_copy(tab)
  local retval = {}
  for k,v in pairs(tab)
  do
    retval[k] = v
  end
  return retval
end

function t.for_each(tab, fc)
  for i=1,#tab,1
  do
    fc(tab[i], i, tab)
  end
end

function t.title.title(data)
  -- not implemented yet
end

function t.unload_map()
  -- local d, err = debug.runCommand('fill 69350 102 69451 69385 63 69426 minecraft:air')
  -- print(d, err)
  -- first, remove the top half
  debug.runCommand('fill 69351 102 69450 69385 76 69426 minecraft:air')
  -- then, we remove the bottom
  debug.runCommand('fill 69385 75 69426 69351 64 69450 minecraft:air')
end

function t.join(tabled, delimiter)
  local txt = ""
  local duc = #tabled-1
  for i=1,duc,1
  do
    txt = txt .. tostring(tabled[i]) .. delimiter
  end
  txt = txt .. tabled[#tabled]
  return txt
end

function t.game_end_check_builder(winners, eliminate, condition)
  return function (alivePlayers, deadPlayers)
    t.for_each(alivePlayers, function (player)
      if condition(player) then
        eliminate(player, deadPlayers)
      end
    end)
    if #alivePlayers <= winners then
      return true, t.shallow_copy(alivePlayers)
    end
    if #alivePlayers == 0 then
      return true, {}
    end
    return false, {}
  end
end

function t.game_loop(gameEndChkFunc, playersTable, tickFunc, tickDelay, gameEndFunc)
  local ended, winners = gameEndChkFunc(playersTable.alive, playersTable.dead)
  while not ended
  do
    ended, winners = gameEndChkFunc(playersTable.alive, playersTable.dead)
    local start = os.clock()
    tickFunc(playersTable)
    local tend = os.clock()
    -- its big brain time (calculate how much was wasted compared to the time left before the next tick and wait that time instead)
    local timeTaken = (tend-start)*100
    local waitTime = tickDelay-timeTaken
    -- print("[mgl] wait time: " .. (waitTime*1000))
    if waitTime > 0 then os.sleep(waitTime) end
  end
  gameEndFunc(winners)
end

function t.find_index(tab, val)
  for i = 1, #tab, 1
  do
    if tab[i] == val then return i end
  end
  return -1
end

function t.Players(p)
  return {
    alive=t.shallow_copy(p),
    dead={},
    eliminate=function(self, name)
      local index = t.find_index(self.alive, name)
      if index < 0 then error('cannot find player: ' .. name) end
      table.remove(self.alive, index)
      table.insert(self.dead, name)
    end,
    all=function(self)
      local ae = {}
      for k, v in pairs(self.alive) do table.insert(ae, v) end
      for k, v in pairs(self.dead) do table.insert(ae, v) end
      return ae
    end
  }
end

function t.Player(name, entity, runCommand)
  return {
    name=name,
    entity=entity,
    getX=function (self) local x = self.entity.getPosition(); return x end,
    getY=function (self) local x, y = self.entity.getPosition(); return y end,
    getZ=function (self) local x, y, z = self.entity.getPosition(); return z end,
    getHealth=function (self) return self.entity.getHealth() end,
    getHP = function (self) return self.entity.getHealth() end,
    setGamemode=function (self, g) return runCommand('gamemode ' .. g .. ' ' .. self.name) end,
    clearEffects=function(self) return runCommand('effect ' .. self.name .. ' clear') end,
    getPosition=function(self) return t.create_vector(self.entity.getPosition()) end,
    give=function(self, item, count, meta, nbt) return self.entity.insertItem(item, count or 1, meta or 0, nbt or "") end,
    clear=function(self) return self.entity.clearInventory() end,
    teleport=function(self, vec) return self.entity.setPosition(vec.x, vec.y, vec.z) end,
    regen=function(self) return self.entity.setHealth(20) end
  }
end

function t.get_player(name)
  return t.Player(name, debug.getPlayer(name), debug.runCommand)
end

function t.load_file(filepath)
  local h = io.open(filepath, "r")
  local data = h:read(h.bufferSize)
  h:close()
  return data
end

function t.load_table(filepath)
  return s.unserialize(t.load_file(filepath))
end

function t.load_map(filepath, type)
  type = type or "static"
  if type == "static" then
    local map = t.load_table(filepath)
    debug.runCommand('clone ' .. t.join(map.coordinates.start, " ") .. " " .. t.join(map.coordinates.endco, " ") .. " " .. t.join(map.cloneCoords, " "))
    
    return map.metadata
  end
end

function t.spread_players(players)
  debug.runCommand('spreadplayers 69367 69438 10 11 false ' .. t.join(players, " "))
end

function t.set_block(x, y, z, block)
  debug.runCommand('setblock ' .. x .. ' ' .. y .. ' ' .. z .. ' ' .. block)
end

function t.create_vector(x, y, z)
  checkArg(1, x, "number")
  checkArg(2, y, "number")
  checkArg(3, z, "number")
  local a = {type="vector", x=x, y=y, z=z}
  setmetatable(a, {
    __index = function (self, e)
      if e == 1 then return self.x end
      if e == 2 then return self.y end
      if e == 3 then return self.z end
    end,
    __newindex = function (self, key, value)
      error('creating a new index on a vector is not allowed!')
    end,
    __tostring = function (self)
      -- return "Vector3D{" .. self.x .. " " .. self.y .. " " .. self.z .. "}"
      return self.x .. " " .. self.y .. " " .. self.z
    end,
    __len = function (self) return 3 end,
    __eq = function (self, other)
      return (self.x == other.x and
             self.y == other.y and
             self.z == other.z)
    end
  })
  return a
end
function t.relative(xyz1, xyz2)
  local relativeCoords = {}
  relativeCoords.x = xyz1.x + xyz2.x
  relativeCoords.y = xyz1.y + xyz2.y
  relativeCoords.z = xyz1.z + xyz2.z
  return relativeCoords
end

function t.vector_to_array(vec)
  return {
    vec.x,
    vec.y,
    vec.z
  }
end

function t.vector_to_matvec(vec)
  return {
    {vec.x},
    {vec.y},
    {vec.z}
  }
end

function t.center(vec)
  return t.create_vector(
    math.floor(vec.x/2),
    math.floor(vec.y/2),
    math.floor(vec.z/2)
  )
end

function t.relative_center(vec1, vec2)
  return t.create_vector(
    vec1.x+vec2.x,
    vec1.y+vec2.y,
    vec1.z+vec2.z
  )
end

function t.includes(table, value)
  for k,v in pairs(table)
  do
    if v == value then return true, k end
  end
  return false, nil
end

function t.matvec_to_vector(mv)
  return t.create_vector(
    mv[1][1],
    mv[2][1],
    mv[3][1]
  )
end

function t.get_patched_print(chatbox, opt)
  local duc = {ogprint=print}
  function duc.print(...)
      if opt.chatbox then
        chatbox.say(t.join(table.pack(...), "    "))
      else
        duc.ogprint(...)
      end
  end
  return duc
end

function t.create_id(type)
  return type .. "_" .. math.random(1, 420690)
end

function t.create_death_tracker(players)
  local scoid = t.create_id("dthtrkr")
  debug.runCommand('scoreboard objectives add ' .. scoid .. ' deathCount ' .. s.serialize(scoid))
  for i = 1, #players, 1
  do
    debug.runCommand('scoreboard players add ' .. players[i] .. ' ' .. scoid .. ' 0')
  end
  return {
    scoid = scoid,
    players = players,
    get = function(self)
      local scoreboard = debug.getScoreboard()
      local res = {}
      for i = 1, #self.players, 1 do
        res[self.players[i]] = scoreboard.getPlayerScore(self.players[i], self.scoid)
      end
      return res
    end,
    died = function(self, name)
      local scoreboard = debug.getScoreboard()
      return scoreboard.getPlayerScore(name, self.scoid) > 0
    end,
    delete = function(self)
      debug.runCommand('scoreboard objectives remove ' .. self.scoid)
    end
  }
end

function t.disable_command_feedback()
  return debug.runCommand('gamerule sendCommandFeedback false')
end

function t.enable_command_feedback()
  return debug.runCommand('gamerule sendCommandFeedback true')
end

function t.random_tape()
  local tapes = t.load_table("/etc/tapes")
  local slot = math.random(tapes.tapes)
  transposer.transferItem(sides.top, sides.bottom, 1, slot, 1)
  tape_drive.play()
  return slot
end

function t.return_tape(slot)
  tape_drive.stop()
  tape_drive.seek(-tape_drive.getSize())
  transposer.transferItem(sides.bottom, sides.top, 1, 1, slot)
end

function t.time_ms()
  return os.clock()*100*1000
end

function t.always_positive(numb)
  if numb < 0 then return 0 end
  return numb
end

return t
local coroutine = require("coroutine")

return function (opt, players, mg)
  return function ()
    for k, v in pairs(players.alive)
    do
      local player = mg.get_player(v)
      player:regen()
      if opt.shovel then player:give('minecraft:golden_shovel') end
      -- coroutine.yield()
      if opt.bow then
        local arrows = tonumber(opt.arrows) or 3
        player:give('minecraft:bow', 1, 384-arrows+1)
        -- coroutine.yield()
        player:give('minecraft:arrow', arrows)
      end
      -- coroutine.yield()
      if opt.lava then player:give('minecraft:lava_bucket') end
      -- coroutine.yield()
      if opt.cake then player:give('minecraft:cake') end
      -- coroutine.yield()
      if opt['instant-health'] then player:give('minecraft:splash_potion', 1, 0, '{Potion:"minecraft:strong_healing"}') end
      -- coroutine.yield()
      if opt.slime then player:give('minecraft:slime', 64) end
      -- coroutine.yield()
      if opt['cock-rider'] then player:give('minecraft:spawn_egg', 8, 0, '{display:{Name:"cock"},EntityTag:{id:"minecraft:chicken"}}') end
      -- coroutine.yield()
      if opt['flint-and-steel'] then player:give('minecraft:flint_and_steel') end
    end
  end
end
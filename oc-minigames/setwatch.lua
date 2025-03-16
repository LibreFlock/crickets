local debug = require("component").debug
local args, opt = require("shell").parse(...)

local playerName = args[1]

local player = debug.getPlayer(playerName)
local positions = {{69364, 77, 69422}, {69389, 77, 69438}, {69371, 77, 69454}, {69346, 77, 69440}}
local pos = positions[math.random(#positions)]
player.setPosition(pos[1], pos[2], pos[3])

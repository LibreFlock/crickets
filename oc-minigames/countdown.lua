local component = require 'component'
local debug = component.debug

local shell = require 'shell'

local args, opt = shell.parse(...)

debug.runCommand('gamerule sendCommandFeedback false')

for i=tonumber(args[1]),0,-1
do
  if i == 1 then
    debug.runCommand('title @a actionbar "1 second left..."')
  else
    debug.runCommand('title @a actionbar "'..i..' seconds left..."')
  end
  os.sleep(1)
end

debug.runCommand('gamerule sendCommandFeedback true')
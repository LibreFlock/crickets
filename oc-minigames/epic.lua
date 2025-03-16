local shell = require("shell")
local event = require("event")
local component = require("component")

function thefunny()
  local _, _, username, message = event.pull("chat_message")
  component.chat_box.setName("Minigames")
  if message:sub(1,1) == "!" then
    -- component.chat_box.say("Executing command...")
    shell.execute(message:sub(2) .. " --chatbox")
  end
  thefunny()
end

thefunny()
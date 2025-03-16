local t = {}
local coroutine = require("coroutine")
local debugOutput = false
function dbglog(text)
  if debugOutput then
    print("[bgjobs] " .. text)
  end
end
function t.BackgroundJobsArray()
  return {
    jobs={},
    push=function (self, fc)
      dbglog("pushing new job: " .. tostring(fc))
      local thread = coroutine.create(fc)
      table.insert(self.jobs, thread)
      return index, thread
    end,
    on_signal = function () end,
    process=function(self)
      for k, v in pairs(self.jobs)
      do
        local stat = coroutine.status(v)
        if stat == "dead" then
          -- clean it up
          dbglog("cleaning up coroutine " .. tostring(v) .. " (#" .. k .. ")")
          table.remove(self.jobs, k)
        else
          dbglog("resuming coroutine " .. tostring(v) .. " (#" .. k .. ")")
          local begin = os.clock()
          local ret, ret2 = coroutine.resume(v)
          local le_end = os.clock()
          dbglog("coroutine took " .. tostring((le_end-begin)*100*1000) .. "ms")
          if ret == false and type(ret2) == "string" then
            error('error in coroutine #' .. k .. ': ' .. ret2)
          else
            self.on_signal(self, ret)
          end
        end
      end
    end
  }
end

function t.sleep(ticks)
  for i = 1, ticks, 1 do coroutine.yield() end
end

return t
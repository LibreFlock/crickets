local event = require("event")
local t = {
	_registered = {}
}
function t:create(name)
	self._registered[name] = {
		cb = nil,
	}
	return {
		name = name,
		_getq = function(_self) return self._registered[_self.name] end,
		register = function(self, cb)
			self:_getq().cb = cb
		end,
		unregister = function(self) self:_getq().cb = nil end,
		destroy = function(_self)
			self._registered[_self.name] = nil
		end
	}
end

function t:exists(name)
	if self[name] ~= nil then return true end
	return false
end

function t:get(name)
	return {
		name = name,
		_t = self,
		_r = self._registered[name],
		call = function(self, ...)
			return self._t._registered[self.name].cb(...)
		end,
		pcall = function(self, ...)
			if not self._t:exists(self.name) then return false, "ipc channel no longer exists" end
			return true, self:call(...)
		end,
	}
end

return t

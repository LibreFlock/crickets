local event = require("event")
local t = {
	_registered = {},
	_waiting_reg = {}
}
function t:create(name)
	self._registered[name] = {
		cb = nil,
	}
	return {
		name = name,
		_getq = function(_self) return self._registered[_self.name] end,
		_gett = function() return self end,
		register = function(self, cb)
			self:_getq().cb = cb
			local a = self._gett()._waiting_req
			if a[self.name] ~= nil then
				for k, v in ipairs(a[self.name])
				do
					v()
				end
				a[self.name] = nil
			end
		end,
		unregister = function(self) self:_getq().cb = nil end,
		destroy = function(_self)
			self._registered[_self.name] = nil
		end
	}
end

function t:exists(name)
	if self._registered[name] ~= nil then return true end
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

function t:wait_create(name, cb)
	if self._waiting_req[name] ~= nil then self._waiting_req[name] = {} end
	table.insert(self._waiting_req[name], cb)
end

return t

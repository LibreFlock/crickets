local t = {
	string = {},
	table = {},
	url = {},
	bytes = {},
	vec2 = {},
	vec3 = {},
	switch = {}
}
-- Split a string, using Lua patterns
---@param str string The string to split
---@param sp string Separator
---@return fun(): string iterator Iterator
function t.string.isplit(str, sp)
	if sp == nil then
		sp = "%s"
	end
	local mstr = "\0" .. str .. "\0" -- TODO: make sure a space gets added if the input *starts or ends* with the separator
	return string.gmatch(str, "([^" .. sp .. "]+)")
end
-- Safe version of string.isplit, doesn't use Lua patterns.
-- Use this if you can't trust the `sp` argument (if you are passing user input to it or something).
-- Arguments are the same as isplit, but behaves slightly differently (seems to behave the same as JS's .split())
---@param _str string The string to be split
---@param delim string Separator/delimiter
---@return fun(): string? iterator Iterator
function t.string.isplit_s(_str, delim)
	local currentPos = 1
	local str = _str .. delim -- replicate JS behavior
	return function ()
		-- if currentPos >= #str then return nil end
		local delimStart, delimEnd = string.find(str, delim, currentPos, true)
		-- print(currentPos, delimStart, delimEnd, #str)
		if delimStart == nil or delimEnd == nil then
			if currentPos <= #str then
				local tmp = string.sub(str, currentPos, #str)
				currentPos = currentPos + #delim
				return tmp
			else
				return nil
			end
		end
		local segment = string.sub(str, currentPos, delimStart-1)
		currentPos = delimEnd+1
		return segment
	end
end
-- Non-iterator version of isplit. Returns a table array
---@param str string The string to be split
---@param sp string Separator
---@returns string[]
function t.string.split(str, sp)
	return t.table.from_iterator(t.string.isplit(str, sp))
end
-- Non-iterator version of isplit_s. Returns a table array
---@param str string The string to be split
---@param sp string Separator
---@returns string[]
function t.string.split_s(str, sp)
	return t.table.from_iterator(t.string.isplit_s(str, sp))
end
-- Checks if a string (`str`) starts with another (`s`)
---@param str string
---@param s string
---@return boolean
function t.string.starts_with(str, s)
	return string.sub(str, 1, #s) == s
end
-- Checks if a string (`str`) ends with another (`s`)
---@param str string
---@param s string
---@return boolean
function t.string.ends_with(str, s)
	return string.sub(str, #str-#s+1, #str) == s
end
-- Creates an iterator going over every character on a string.
---@param str string
---@return fun(): string? iterator
function t.string.chars(str)
	local i = 1
	return function()
		local res = string.sub(str, i, i)
		if res == "" or i > #str then return nil end
		i = i + 1
		return res
	end
end
-- Checks if a table has a specified key.
---@return boolean
function t.table.has_key(tab, key)
	for k, v in pairs(tab)
	do
		if k == key then return true end
	end
	return false
end
-- Checks if a table has a specific value. (`val`)
---@return boolean
function t.table.has_value(tab, val)
	for k, value in pairs(tab)
	do
		if value == val then return true end
	end
	return false
end
-- Creates a iterator going over the values of a table.
---@return fun(): any
function t.table.itval(tab)
	local i = 1
	return function ()
		if i > #tab then return nil end
		i = i + 1
		return tab[i - 1]
	end
end
-- Creates a table from an iterator (`it`).
-- Returns a table array.
---@return any[]
function t.table.from_iterator(it)
	local tab = {}
	for value in it
	do
		table.insert(tab, value)
	end
	return tab
end
--- Gets a value from a table at `p`, accepts negative values
---@param tab any[]
---@param p integer
function t.table.at(tab, p)
	if p > 0 then
		return tab[p]
	else
		return tab[#tab + (p + 1)] -- i hate 1-based indexingi hate 1-based indexedi hate-
	end
end
-- yes this will overflow the stack if the tables are too nested
function t.table.deep_equal(s1, s2)
	for k, v in pairs(s1)
	do
		if type(s1[k]) ~= type(s2[k]) then
			return false
		end
		if type(s1[k]) == "table" then
			if not t.table.deep_equal(s1[k], s2[k]) then
				return false
			end
		elseif s1[k] ~= s2[k] then
			return false
		end
	end
	for k, v in pairs(s2)
	do
		if type(s1[k]) ~= type(s2[k]) then
			return false
		end
		if type(s2[k]) == "table" then
			if not t.table.deep_equal(s1[k], s2[k]) then
				return false
			end
		elseif s1[k] ~= s2[k] then
			return false
		end
	end
	
	return true
end
-- totally not taken from /bin/pastebin.lua
-- Encodes an URL to be used in a string. (like " " -> "%20")
---@param code string URL to be encoded
---@return string
function t.url.encode(code)
	if code then
		code = string.gsub(code, "([^%w ])", function(c)
			return string.format("%%%02X", string.byte(c))
		end)
		code = string.gsub(code, " ", "+")
	end
	return code
end
-- Decodes an URL. (like "%20" -> " ")
---@param code string The URL to be decoded
---@return string
function t.url.decode(code)
	if code then
		code = string.gsub(code, "(%%[A-Fa-f0-9][A-Fa-f0-9])", function(c)
			return string.char(tonumber(string.sub(c, 2), 16))
		end)
		code = string.gsub(code, "+", " ")
	end
	return code
end
-- Creates an iterator going over the bytes of a string. Each iteration has a number argument.
function t.bytes.string(str)
	local it = t.string.chars(str)
	return function ()
		local ch = it()
		if ch == nil then return nil end
		return string.byte(ch)
	end
end
-- TODO: rewrite these as iterators and replace the originals with t.table.from_iterator stuff
-- Converts a hex string back into a normal string.
function t.bytes.from_hex(str)
	local out = ""
	local last = ""
	for ch in t.string.chars(str)
	do
		if last == "" then
			last = ch
			goto cont
		end
		local hxb = last .. ch
		out = out .. string.char(tonumber(hxb, 16))
		last = ""
		::cont::
	end
	return out
end
-- Converts a string into a hex string.
function t.bytes.to_hex(str)
	local out = ""
	for ch in t.bytes.string(str)
	do
		out = out .. string.format("%x", ch)
	end
	return out
end
function t.vec2.new(px, py)
	local x, y = px, py
	if type(px) == "table" then
		x = px[1] or px.x
		y = px[2] or px.y
	end
	local v = {
		x = x,
		y = y
	}
	setmetatable(v, {
		__tostring = function(self)
			return "vec2(" .. tostring(self.x) .. ", " .. tostring(self.y) .. ")"
		end,
		__len = function(self) return 2 end,
		__unm = function(self)
			return t.vec2.new(-self.x, -self.y)
		end,
		__add = function(self, a) -- todo: add typechecking
			if type(a) == "number" then
				return t.vec2.new(self.x + a, self.y + a)
			end
			return t.vec2.new(self.x + a.x, self.y + a.y)
		end,
		__sub = function(self, a)
			if type(a) == "number" then
				return t.vec2.new(self.x - a, self.y - a)
			end
			return t.vec2.new(self.x - a.x, self.y - a.y)
		end,
		__mul = function(self, a)
			if type(a) == "number" then
				return t.vec2.new(self.x * a, self.y * a)
			end
			return t.vec2.new(self.x * a.x, self.y * a.y)
		end,
		__div = function(self, a)
			if type(a) == "number" then
				return t.vec2.new(self.x / a, self.y / a)
			end
			return t.vec2.new(self.x / a.x, self.y / a.y)
		end,
		__idiv = function(self, a)
			if type(a) == "number" then
				return t.vec2.new(self.x // a, self.y // a)
			end
			return t.vec2.new(self.x // a.x, self.y // a.y)
		end,
		__pow = function(self, a)
			if type(a) == "number" then
				return t.vec2.new(self.x ^ a, self.y ^ a)
			end
			return t.vec2.new(self.x ^ a.x, self.y ^ a.y)
		end, -- todo: bitwise operations
		__eq = function(self, a)
			if type(a) == "number" then
				return self.x == a and self.y == a
			end
			return self.x == a.x and self.y == a.y
		end,
		__lt = function(self, a)
			if type(a) == "number" then
				return self.x < a and self.y < a
			end
			return self.x < a.x and self.y < a.y
		end,
		__le = function(self, a)
			if type(a) == "number" then
				return self.x <= a and self.y <= a
			end
			return self.x <= a.x and self.y <= a.y
		end
	})
	return v
end
function t.vec3.new(px, py, pz)
	local x, y, z = px, py, pz
	if type(px) == "table" then
		x = px[1] or px.x
		y = px[2] or px.y
		z = px[3] or px.z
	end
	local v = {
		x = x,
		y = y,
		z = z
	}
	setmetatable(v, {
		__tostring = function(self)
			return "vec3(" .. tostring(self.x) .. ", " .. tostring(self.y) .. ", " .. tostring(self.z) .. ")"
		end,
		__len = function(self) return 3 end,
		__unm = function(self)
			return t.vec3.new(-self.x, -self.y, -self.z)
		end,
		__add = function(self, a) -- todo: add typechecking
			if type(a) == "number" then
				return t.vec3.new(self.x + a, self.y + a, self.z + a)
			end
			return t.vec3.new(self.x + a.x, self.y + a.y, self.z + a.z)
		end,
		__sub = function(self, a)
			if type(a) == "number" then
				return t.vec3.new(self.x - a, self.y - a, self.z - a)
			end
			return t.vec3.new(self.x - a.x, self.y - a.y, self.z - a.z)
		end,
		__mul = function(self, a)
			if type(a) == "number" then
				return t.vec3.new(self.x * a, self.y * a, self.z * a)
			end
			return t.vec3.new(self.x * a.x, self.y * a.y, self.z * a.z)
		end,
		__div = function(self, a)
			if type(a) == "number" then
				return t.vec3.new(self.x / a, self.y / a, self.z / a)
			end
			return t.vec3.new(self.x / a.x, self.y / a.y, self.z / a.z)
		end,
		__idiv = function(self, a)
			if type(a) == "number" then
				return t.vec3.new(self.x // a, self.y // a, self.z // a)
			end
			return t.vec3.new(self.x // a.x, self.y // a.y, self.z // a.z)
		end,
		__pow = function(self, a)
			if type(a) == "number" then
				return t.vec3.new(self.x ^ a, self.y ^ a, self.z ^ a)
			end
			return t.vec3.new(self.x ^ a.x, self.y ^ a.y, self.z ^ a.z)
		end, -- todo: bitwise operations
		__eq = function(self, a)
			if type(a) == "number" then
				return self.x == a and self.y == a and self.z == a
			end
			return self.x == a.x and self.y == a.y and self.z == a.z
		end,
		__lt = function(self, a)
			if type(a) == "number" then
				return self.x < a and self.y < a and self.z < a
			end
			return self.x < a.x and self.y < a.y and self.z < a.z
		end,
		__le = function(self, a)
			if type(a) == "number" then
				return self.x <= a and self.y <= a and self.z <= a
			end
			return self.x <= a.x and self.y <= a.y and self.z <= a.z
		end
	})
	return v
end
function t.enum(tab)
	local retv = {}
	for k, v in pairs(tab)
	do
		retv[k] = v
		retv[v] = k
	end
	return retv
end
function t.switch.create(var)
	return function (tab)
		local found = false -- to replicate the behavior of JS's switch()
		for k, v in ipairs(tab)
		do
			if var == v.match or found then
				local retv = v.func()
				local mt = getmetatable(retv)
				if mt ~= nil then
					if mt.__bstd_switch_case_action == "break" then
						-- break
						return retv
					end
				end
				found = true
			end
		end
	end
end
function t.switch.case(matcher)
	return function (fc)
		return { match = matcher, func = fc }
	end
end
function t.switch.stop(tab)
	local duck = {}
	if type(tab) == "table" then
		duck = tab
	end
	setmetatable(duck, {
		__bstd_switch_case_action = "break"
	})
	return duck
end
function t.case(...) -- shortcut
	return t.switch.case(...)
end
function t.stop(...) -- shortcut
	return t.switch.stop(...)
end
setmetatable(t.switch, {
	__call = function (self, ...)
		return self.create(...)
	end
})
function t.noop() -- does literally nothing
end
return t

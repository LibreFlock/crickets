local t = {
	littleEndian = "<",
	bigEndian = ">",
	nativeEndian = "=",
	byte = "b", i8 = "b"
	ubyte = "B", u8 = "B"
	short = "h", i16 = "h",
	ushort = "H", u16 = "H",
	int = "l", i32 = "l", -- i'm assuming this is a C long?
	uint = "L", u32 = "L",
	long = "i8", i64 = "i8",
	ulong = "I8", u64 = "I8",
	float = "f",
	double = "d",
	fstr = function(n) return "c" .. n end, -- fixed length string
	cstr = "z", -- C string
	str = function(n) return "s" .. n end, -- a string preceded by its length in bytes,
	padding = function(n) return string.rep("x", n) end
}

function t._ftospf(end, format) -- format to string.pack format
	local str = ""
	for key, value in pairs(format)
	do
		
	end
end
function t.Packet(format, props)
	return {
		format = format,
		props = props
	}
end

function t.Parser(self)
	local q = { packets = {}, endianness = "=", idSize = 4 }
	function q.setEndianness(self, t)
		self.endianness = t
	end
	function q.packet(_self, id, format)
		_self.packets[id] = self.Packet(self._ftospf(_self.endianness, format))
	end
	
	return j
end

return t

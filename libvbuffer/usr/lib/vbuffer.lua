local t = {}

function t.create(width, height)
	return {
		buffer = {},
		bg = "",
		fg = "",
		setBackground = function(self, color)
			self.bg = color
		end,
		setForeground = function(self, color)
			self.fg = color
		end,
		set = function(self, x, y, value, vertical)
			
		end,
		fill = function(self, x, y, width, height, char)
			
		end,

	}
end


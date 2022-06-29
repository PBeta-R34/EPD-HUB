local HTML = {}

local HTMLHeader = "<!DOCTYPE html>"



HTML.LoadDocument = function(Source, RootURL)
	local Document = {}
	
	Document.Source = Source or error("No Source Provided")
	Document.RootURL = RootURL or ""
	
	function Document:Parse()
		assert(string.find(self.Source, HTMLHeader) == 1, "Invalid HTML Header")
		-- Remove Header
		self.Source = self.Source:sub(#HTMLHeader + 1, #self.Source)
		
		local Todo = #self.Source
		local At = 1
		
		--[[
		0 = None
		1 = Comment
		2 = Items
		3 = Plain
		4 = Plain, Waiting For Tag Ending
		--]]
		local ParserMode = 0
		local Char = ""
		local Buffer = ""
		
		while At < Todo do
			Char = self.Source:sub(At, At)
			At += 1
			if Char == "<" then
				if self.Source:sub(At, At + 2) == "!--" then
					Buffer = ""
					At += 2
					ParserMode = 1
				end
			else
				if Char == "-" and self.Source:sub(At, At + 1) == "->" then
					At += 1
					ParserMode = 0
					continue
				end
				if ParserMode == 1 then
					Buffer ..= Char
				end
			end
			
		end
	end
	
	return Document
end


--return HTML
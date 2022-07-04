_G.EPD = _G.EPD or {}
_G.EPD.HttpGet =
	httpget or http_get
	or (syn 			and function(Link) return syn.request({Url = Link, Method = "GET"}).Body end)
	or (game.HttpGet 	and function(Link) return game:HttpGet(Link) end)
	or error("No HTTP Get Function.")

_G.EPD.DEBUG = true -- Enable For Debugging

local LoadedFunction = loadstring(_G.EPD.HttpGet("https://raw.githubusercontent.com/PBeta-R34/EPD-HUB/main/Source/Loader.lua"))
if type(LoadedFunction) == "function" then
	local Success, Returned = pcall(LoadedFunction)
	-- We Don't Wanna Print Unless Debug Is True
	if not Success then
		error("Loader Fatal Error: " .. tostring(Returned))
	end
end
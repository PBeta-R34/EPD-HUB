getgenv = getgenv or function() return _G end
HttpGet =
	httpget or http_get
	or (syn 			and function(Link) return syn.request({Url = Link, Method = "GET"}).Body end)
	or (game.HttpGet 	and function(Link) return game:HttpGet(Link) end)

getgenv().EPD_DEBUG = true

local LoadedFunction = loadstring(HttpGet("https://raw.githubusercontent.com/PBeta-R34/EPD-HUB/main/Source/Loader.lua"))
if LoadedFunction then
	local Success, Returned = pcall(LoadedFunction)
	
	-- We Don't Wanna Print Unless Debug Is True
	if not Success and getgenv().EPD_DEBUG == true then
		warn("Loader Fatal Error " .. tostring(Returned))
	end
end
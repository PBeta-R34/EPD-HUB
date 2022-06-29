local BaseLib = {
	-- Should Be Initialized By The Loader, But In Case It Isn't
	RootPath = "https://raw.githubusercontent.com/PBeta-R34/EPD-HUB/main/Source/",
	Exploit = {
		Name = "",
		Checksums = {}
	}
}

BaseLib.SafeLoad = function(Source)
	local LoadedFunction = loadstring(Source)
	if type(LoadedFunction) == "function" then
		local Success, Returned = pcall(LoadedFunction)
		if Success then
			return Returned
		end
	end

	return false
end

BaseLib.HttpGet =
	httpget or http_get
	or (syn 			and function(Link) return syn.request({Url = Link, Method = "GET"}).Body end)
	or (game.HttpGet	and function(Link) return game:HttpGet(Link) end)
	or error("No HTTP Get Function.")

BaseLib.ImportFile = function(FilePath)
	return BaseLib.HttpGet(BaseLib.RootPath .. FilePath)
end

BaseLib.Import = function(ModulePath)
	return BaseLib.SafeLoad(BaseLib.ImportFile(ModulePath .. ".lua"))
end



return BaseLib
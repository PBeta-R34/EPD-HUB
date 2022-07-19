local BaseLib = {
	-- Should Be Initialized By The Loader, But In Case It Isn't
	RootPath = "https://raw.githubusercontent.com/PBeta-R34/EPD-HUB/main/Source/",
	RelativePath = "",
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

----------------------------------
-- EXPLOIT API UNIVERSALIZATION --
----------------------------------

----------------
-- NETWORKING --
----------------

BaseLib.HttpGet =
	HttpGet or http_get
	or (syn 			and function(Link) return syn.request({Url = Link, Method = "GET"}).Body end)
	or (game.HttpGet	and function(Link) return game:HttpGet(Link) end)
	or error("No HTTP Get Function.")

BaseLib.HttpPost =
	HttpPost or http_post
	or (syn 			and function(Link, Body) return syn.request({Url = Link, Body = Body, Method = "POST"}).Body end)
	or (game.HttpPost	and function(Link, Body) return game:HttpPost(Link, Body) end)
	or error("No HTTP Post Function.")


BaseLib.HttpRequest =
	http_request
	or (Syn 			and function(Request) return syn.request(Request) end)
	

-----------------
-- FILE SYSTEM --
-----------------

BaseLib.ReadFile = 
	readfile

BaseLib.WriteFile = 
	writefile

BaseLib.AppendFile = 
	writefile
	or function(FileName, NewInfo) BaseLib.WriteFile(FileName, BaseLib.ReadFile(FileName) .. NewInfo) end

BaseLib.IsFile = 
	isfile


BaseLib.CreateFolder = 
	makefolder

BaseLib.DeleteFolder = 
	delfolder

BaseLib.IsFolder = 
	isfolder




BaseLib.SetRelativePath = function(Relative)
	if Relative:sub(#Relative, #Relative) ~= "//" then
		Relative ..= "//"
	end
	BaseLib.RelativePath = BaseLib.RootPath .. Relative
end

BaseLib.ImportFile = function(FilePath, UseRelative)
	return BaseLib.HttpGet(((UseRelative and BaseLib.RelativePath) or BaseLib.RootPath) .. FilePath)
end

BaseLib.Import = function(ModulePath, UseRelative)
	return BaseLib.SafeLoad(BaseLib.ImportFile(ModulePath .. ".lua", UseRelative))
end





return BaseLib
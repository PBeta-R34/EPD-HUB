
-- Constants
local c_RootPath = "https://raw.githubusercontent.com/PBeta-R34/EPD-HUB/main/Source/"
local c_Scripts = {
	{"Utils", "LABEL"},
	{"Explorer", "Scripts/Explorer.lua", "REL"},
	
	{"Other Utils", "LABEL"},
	{"Hydroxide", "local owner='Upbolt';local branch='revision';local function webImport(file)return loadstring(game:HttpGetAsync((\"https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua\"):format(owner,branch,file)),file..'.lua')()end;webImport(\"init\")webImport(\"ui/main\")", "SRC"},
	{"Infinite Yeild", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", "URL"},
	
	{"Cheats", "LABEL"},
	{"Universal ESP", "Scripts/UniversalESP.lua", "REL"}
	
}
local c_TransparencyTweening = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.InOut
)
local c_SelectorTweening = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Quart,
	Enum.EasingDirection.Out
)
local c_SelectorColorTweening = TweenInfo.new(
	0.5,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.InOut
)

local c_ColorScheme = {
	Borders = Color3.new(1, 1, 1),
	Background = Color3.fromRGB(30, 30, 30),
	Text = Color3.new(1, 1, 1),
	
	Selector = {
		Idle = Color3.fromRGB(100, 100, 100),
		Select = Color3.fromRGB(100, 255, 100),
		Delete = Color3.fromRGB(255, 100, 100),
		Loading = Color3.fromRGB(255, 255, 100)
	},
	Button = {
		Background = Color3.fromRGB(50, 50, 50),
		Text = Color3.new(1, 1, 1)
	}
}

local c_ButtonSize = UDim2.new(1, 0, 0, 18)
local c_Exploits = {
	{
		Name = "Synapse X",
		Checksums = {0xF83462F2}
	}
}


-- Services
local g_UserInputSerivce 	= game:GetService("UserInputService")
local g_TweenService 		= game:GetService("TweenService")
local g_RunService 			= game:GetService("RunService")
local g_CoreGui 			= game:GetService("CoreGui")


-- Uninitialized
local u_Connections = {}
local u_HostExploit = {
	Name = "Unknown",
	Checksums = {}
}

-- Others
local HttpGet =
	httpget or http_get
	or (syn 			and function(Link) return syn.request({Url = Link, Method = "GET"}).Body end)
	or (game.HttpGet 	and function(Link) return game:HttpGet(Link) end)


-- Functions
function LoadScript(ScriptSource)
	local LoadedFunction = loadstring(ScriptSource)
	if type(LoadedFunction) == "function" then
		local Success, Returned = pcall(LoadedFunction)
		return Success
	end
	
	return false
end

-----------------------
-- EXPLOIT DETECTION --
-----------------------
do
	local string_byte = string.byte
	local band = bit32.band
	local bxor = bit32.bxor
	local brsh = bit32.rshift
	local getgenv = getgenv or error("No Get Global Env Function")
	
	local CRCTable = {0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F, 0xE963A535, 0x9E6495A3, 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988, 0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91, 0x1DB71064, 0x6AB020F2, 0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7, 0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9, 0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172, 0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B, 0x35B5A8FA, 0x42B2986C, 0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59, 0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423, 0xCFBA9599, 0xB8BDA50F, 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924, 0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D, 0x76DC4190, 0x01DB7106, 0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433, 0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D, 0x91646C97, 0xE6635C01, 0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E, 0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457, 0x65B0D9C6, 0x12B7E950, 0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65, 0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7, 0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0, 0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9, 0x5005713C, 0x270241AA, 0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F, 0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81, 0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A, 0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683, 0xE3630B12, 0x94643B84, 0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1, 0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB, 0x196C3671, 0x6E6B06E7, 0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC, 0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5, 0xD6D6A3E8, 0xA1D1937E, 0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B, 0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55, 0x316E8EEF, 0x4669BE79, 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236, 0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F, 0xC5BA3BBE, 0xB2BD0B28, 0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D, 0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F, 0x72076785, 0x05005713, 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38, 0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21, 0x86D3D2D4, 0xF1D4E242, 0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777, 0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69, 0x616BFFD3, 0x166CCF45, 0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2, 0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB, 0xAED16A4A, 0xD9D65ADC, 0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9, 0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693, 0x54DE5729, 0x23D967BF, 0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94, 0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D}
	
	local function HashCRC32(Input)
		local CRC32 = 0xFFFFFFFF
		local LookupIndex = nil
		for Index=1, #Input do
			CRC32 = bxor(brsh(CRC32, 8), CRCTable[band(bxor(CRC32, string_byte(Input, Index)), 0xFF) + 1])
		end
		CRC32 = bxor(CRC32, 0xFFFFFFFF)
		return CRC32
	end
	
	local function MakeExploitEnvString(Env)
		local Result = ""
		local Queue = {Env}
		local ForbiddenItems = {"_G"}
		local AllowedTypes = {"function", "table"}
		
		local Table = nil
		local Type = nil
		while #Queue > 0 do
			Table = table.remove(Queue, 1)
			for Name, Item in next, Table do
				Type = type(Item)
				
				if table.find(ForbiddenItems, Item) then
					continue
				end
				
				if table.find(AllowedTypes, Type) then
					if Type == "table" then
						table.insert(Queue, Item)
					end
					Result = Result .. Name .. "<".. type(Item) .. ">"
				end
			end
		end
		
		return Result
	end
	
	
	local Checksum = HashCRC32(MakeExploitEnvString(getgenv()))
	--setclipboard(string.format("0x%X", Checksum))
	
	do
		for _, Exploit in pairs(c_Exploits) do
			if table.find(Exploit.Checksums, Checksum) then
				u_HostExploit = Exploit
			end
		end
	end
end


--------------
-- MAIN GUI --
--------------
do
	-- Uninitialized Locals
	local l_IsInsideScripts = false
	local l_ScriptsButtons = {}
	local l_ApplyTween = {}
	local l_LockSelector = false
	
	local l_SetSelectorTarget = nil
	local l_Target = {Button = nil, Execute = nil}
	
	-- Functions
	function RoundGui(GUI, Rounding: UDim)
		local RoundUI = Instance.new("UICorner", GUI)
		RoundUI.CornerRadius = Rounding
		return RoundUI
	end
	
	local function NewInstance(ClassName, Settings, Parent)
		local Created = Instance.new(ClassName)
		for Name, Value in pairs(Settings) do
			Created[Name] = Value
		end
		Created.Parent = Parent
		return Created
	end
	
	local function AddToApplyTweenList(Item)
		table.insert(l_ApplyTween, {Item, Item.Transparency})
	end
	
	local function SetTransparency(Value: number, UseTween: boolean)
		if not UseTween then
			for _, Item in pairs(l_ApplyTween) do
				Item[1].BackgroundTransparency = (Item[2] > Value and Item[2]) or Value
			end
		else
			for _, Item in pairs(l_ApplyTween) do
				g_TweenService:Create(Item[1], c_TransparencyTweening, {BackgroundTransparency = (Item[2] > Value and Item[2]) or Value}):Play()
			end
		end
	end
	
	-- Gui
	local Core = NewInstance("ScreenGui", {IgnoreGuiInset = true})
	
	local MainFrame = NewInstance("Frame", {
		Size = UDim2.new(0, 400, 0, 330),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = c_ColorScheme.Background,
		BorderColor3 = Color3.new(1, 1, 1),
		ClipsDescendants = true
	}, Core)
	AddToApplyTweenList(MainFrame)
	
	local InfoFrame = NewInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 29),
		Position = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundColor3 = c_ColorScheme.Background,
		BorderColor3 = Color3.new(1, 1, 1),
	}, MainFrame)
	AddToApplyTweenList(InfoFrame)
	
	local InfoFrameListLayout = NewInstance("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 2)
	}, InfoFrame)
	
	local ExploitLabel = NewInstance("TextLabel", {
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Font = Enum.Font.Ubuntu,
		TextColor3 = c_ColorScheme.Text,
		AutomaticSize = Enum.AutomaticSize.X,
		Text = "Exploit: " .. u_HostExploit.Name,
		TextSize = 15
	}, InfoFrame)
	
	local CloseButton = NewInstance("TextButton", {
		Size = UDim2.new(0, 80, 1, 0),
		Font = Enum.Font.Ubuntu,
		TextColor3 = c_ColorScheme.Text,
		BackgroundColor3 = c_ColorScheme.Background,
		BorderColor3 = c_ColorScheme.Borders,
		Text = "Close",
		TextScaled = true,
		Active = false
	}, InfoFrame)
	
	local ExecuteButton = NewInstance("TextButton", {
		Size = UDim2.new(0, 80, 1, 0),
		Font = Enum.Font.Ubuntu,
		TextColor3 = c_ColorScheme.Text,
		BackgroundColor3 = c_ColorScheme.Background,
		BorderColor3 = c_ColorScheme.Borders,
		Text = "Execute",
		TextScaled = true
	}, InfoFrame)
	
	local Scripts = NewInstance("ScrollingFrame", {
		Size = UDim2.new(0.3, 0, 1, -30),
		TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		CanvasSize = UDim2.new(0, 0, 0, 0),
		VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
		BackgroundColor3 = c_ColorScheme.Background,
		BorderColor3 = c_ColorScheme.Borders,
		ScrollBarThickness = 3
	}, MainFrame)
	AddToApplyTweenList(Scripts)
	
	local ScriptsListLayout = NewInstance("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.Name,
		Padding = UDim.new(0, 2)
	}, Scripts)
	
	local ScriptsSelectionFrame = NewInstance("Frame", {
		Size = UDim2.new(0.3, 0, 0, 18),
		Position = UDim2.new(-1, 0, 0, 0),
		BackgroundColor3 = c_ColorScheme.Selector.Idle,
		BorderSizePixel = 0,
		BackgroundTransparency = 0.6,
		ZIndex = 1
	}, MainFrame)
	AddToApplyTweenList(ScriptsSelectionFrame)
	
	-----------------------
	-- EVENTS MANAGEMENT --
	-----------------------
	do
		local l_YOffset = (ScriptsSelectionFrame.AbsoluteSize.Y - c_ButtonSize.Y.Offset) / 2
		local l_TargetCurrentTween = nil
		local l_LastTweenTarget = nil
		
		local l_RunnerConnection = nil
		
		
		l_SetSelectorTarget = function(Target)
			if l_LastTweenTarget == Target or l_LockSelector then return end
			if l_TargetCurrentTween then
				l_TargetCurrentTween:Cancel()
				l_TargetCurrentTween = nil
			end
			
			if Target then
				local NewPos = (Target.AbsolutePosition - MainFrame.AbsolutePosition) - Vector2.new(0, l_YOffset)
				if l_LastTweenTarget == nil then
					ScriptsSelectionFrame.Position = UDim2.new(-1, 0, 0, NewPos.Y)
				end
				
				
				l_TargetCurrentTween = g_TweenService:Create(
					ScriptsSelectionFrame,
					c_SelectorTweening,
					{Position = UDim2.new(0, NewPos.X, 0, NewPos.Y)}
				)
				l_TargetCurrentTween:Play()
			else
				l_TargetCurrentTween = g_TweenService:Create(
					ScriptsSelectionFrame,
					c_SelectorTweening,
					{Position = UDim2.new(-1, 0, 0, (l_LastTweenTarget.AbsolutePosition.Y - MainFrame.AbsolutePosition.Y) - l_YOffset)}
				)
				l_TargetCurrentTween:Play()
			end
			l_LastTweenTarget = Target
		end
		
		local function StartRunner()
			if l_RunnerConnection then return end
			local LastMousePos = 0
			local Debounce = false
			
			l_RunnerConnection = g_RunService.Heartbeat:Connect(function()
				if Debounce then return end
				Debounce = true
				if l_IsInsideScripts == false then
					l_RunnerConnection:Disconnect()
					l_RunnerConnection = nil
				end
				
				local MousePos = g_UserInputSerivce:GetMouseLocation().Y - 36
				if true or LastMousePos ~= MousePos then
					local Lower = {Button = nil, Score = math.huge}
					for _, Button in pairs(l_ScriptsButtons) do
						local Dist = MousePos - (Button.AbsolutePosition.Y + (Button.AbsoluteSize.Y / 2))
						if Dist < 0 then Dist = Dist*-1 end
						if Dist < Lower.Score then
							Lower.Button = Button
							Lower.Score = Dist
						end
						
						
					end
					
					if Lower.Score < 20 then
						l_SetSelectorTarget(Lower.Button)
					else
						l_SetSelectorTarget(nil)
					end
					
					
					LastMousePos = MousePos
				end
				Debounce = false
			end)
		end
		
		table.insert(u_Connections, Scripts.MouseEnter:Connect(function()
			l_IsInsideScripts = true
			StartRunner()
		end))
		
		table.insert(u_Connections, Scripts.MouseLeave:Connect(function()
			l_IsInsideScripts = false
			l_RunnerConnection:Disconnect()
			l_RunnerConnection = nil
			l_SetSelectorTarget(nil)
		end))
		
		table.insert(u_Connections, CloseButton.MouseButton1Click:Connect(function()
			for _, Conn in pairs(u_Connections) do
				Conn:Disconnect()
			end
			Core:Destroy()
		end))
		
		table.insert(u_Connections, ExecuteButton.MouseButton1Click:Connect(function()
			l_Target.Execute()
		end))
	end
	
	-------------------------
	-- LOAD & LINK SCRIPTS --
	------------------------
	do
		local function SetSelectedButton(Button, LoaderLambda)
			if Button == l_Target.Button then
				g_TweenService:Create(ScriptsSelectionFrame, c_SelectorColorTweening, {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
				l_Target.Button = nil
				l_Target.Execute = nil
				l_LockSelector = false
				return
			end
			
			l_LockSelector = false
			l_SetSelectorTarget(Button)
			l_LockSelector = true
			l_Target.Button = Button
			l_Target.Execute = LoaderLambda
			g_TweenService:Create(ScriptsSelectionFrame, c_SelectorColorTweening, {BackgroundColor3 = Color3.fromRGB(100, 200, 100)}):Play()
		end
		
		local function CreateLabel(Text, Iteration)
			local Label = Instance.new("TextLabel", Scripts)
			Label.Text = Text
			Label.TextScaled = true
			Label.Name = Iteration
			Label.Size = UDim2.new(1, 0, 0, 15)
			Label.TextColor3 = Color3.new(1, 1, 1)
			Label.Font = Enum.Font.Ubuntu
			Label.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			Label.BorderSizePixel = 0
			Label.ZIndex = 2
			AddToApplyTweenList(Label)
			return Label
		end
		
		local function CreateButton(ScriptInfo, Iteration)
			local Button = Instance.new("TextButton", Scripts)
			Button.Text = ScriptInfo[1] -- Name
			Button.TextScaled = true
			Button.Name = Iteration
			Button.Font = Enum.Font.Ubuntu
			Button.Size = c_ButtonSize
			Button.TextColor3 = c_ColorScheme.Button.Text
			Button.BackgroundTransparency = 0.5
			Button.BackgroundColor3 = c_ColorScheme.Button.Background
			Button.AnchorPoint = Vector2.new(0.5, 0.5)
			Button.BorderSizePixel = 0
			Button.ZIndex = 2
			Button.AutoButtonColor = false
			AddToApplyTweenList(Button)
			table.insert(l_ScriptsButtons, Button)
			
			local ExecuteLambda = function() error("Execute Lambda Not Registered") end
			
			if ScriptInfo[3] == "REL" then
				ExecuteLambda = function()
					return LoadScript(HttpGet(c_RootPath .. ScriptInfo[2]))
				end
			elseif ScriptInfo[3] == "URL" then
				ExecuteLambda = function()
					return LoadScript(HttpGet(ScriptInfo[2]))
				end
			elseif ScriptInfo[3] == "SRC" then
				ExecuteLambda = function()
					return LoadScript(ScriptInfo[2])
				end
			end
			
			Button.MouseButton1Click:Connect(function()
				SetSelectedButton(Button, ExecuteLambda)
			end)
			
			return Button
		end
		
		for Iteration, ItemVal in pairs(c_Scripts) do
			if ItemVal[2] == "LABEL" then
				CreateLabel(ItemVal[1], Iteration)
			else
				CreateButton(ItemVal, Iteration)
			end
		end
	end
	
	
	
	
	SetTransparency(1, false)
	Core.Parent = g_CoreGui
	
	SetTransparency(0, true)
end

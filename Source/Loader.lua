-- Constants
local c_RootPath = "https://raw.githubusercontent.com/PBeta-R34/EPD-HUB/main/Source/"
local c_BaseLib = "Libraries/BaseLibrary.lua"
local c_Scripts = {
	{"Utils", "LABEL"},
	{"Explorer", "Scripts/Explorer.lua", "REL"},
	
	{"Other Utils", "LABEL"},
	{"Hydroxide", "local owner='Upbolt';local branch='revision';local function webImport(file)return loadstring(game:HttpGetAsync((\"https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua\"):format(owner,branch,file)),file..'.lua')()end;webImport(\"init\")webImport(\"ui/main\")", "SRC"},
	{"Infinite Yeild", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", "URL"},
	
	{"Cheats", "LABEL"},
	{"Universal ESP", "Scripts/UniversalESP.lua", "REL"}
	
}
local c_Exploits = {
	{
		Name = "Synapse X",
		Checksums = {0x282CD0F6, 0x8C763513},
		IID = 1
	}
}

local c_GlobalEnv = _G
local c_ScriptButtonSize = UDim2.new(1, 0, 0, 18)


local c_ColorScheme = {
	Borders = Color3.new(1, 1, 1),
	Background = Color3.fromRGB(30, 30, 30),
	Text = Color3.new(1, 1, 1),
	Disabled = Color3.fromRGB(100, 100, 100),
	
	Selector = {
		Idle = Color3.fromRGB(100, 100, 100),
		Select = Color3.fromRGB(100, 255, 100),
		Delete = Color3.fromRGB(255, 100, 100),
		Loading = Color3.fromRGB(255, 255, 100)
	},
	ScriptList = {
		LabelBackground = Color3.fromRGB(60, 60, 60),
		ButtonBackground = Color3.fromRGB(50, 50, 50),
		
		Text = Color3.new(1, 1, 1),
		
		ToolbarButtons = {
			AddScript = Color3.fromRGB(100, 185, 255),
			RemoveScript = Color3.fromRGB(100, 185, 255), -- 255, 65, 65
			MoveUp = Color3.fromRGB(185, 255, 100),
			MoveDown = Color3.fromRGB(185, 255, 100),
			Configs = Color3.fromRGB(200,200,200),
			Execute = Color3.fromRGB(0, 255, 60)
		}
	}
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
local HttpGet = c_GlobalEnv.EPD.HttpGet

-- Functions
function LoadScript(ScriptSource)
	local LoadedFunction = loadstring(ScriptSource)
	if type(LoadedFunction) == "function" then
		local Success, Returned = pcall(LoadedFunction)
		if Success then
			return Returned
		end
	end
	
	return false
end

--------------------
-- BASE LIB SETUP --
--------------------
do
	c_GlobalEnv.EPD = c_GlobalEnv.EPD or {}
	local EPDTable = c_GlobalEnv.EPD
	EPDTable.BaseLib = EPDTable.BaseLib or LoadScript(HttpGet(c_RootPath .. c_BaseLib))

	EPDTable.BaseLib.RootPath = c_RootPath
	EPDTable.BaseLib.Exploit = u_HostExploit
end

local m_Hashing = c_GlobalEnv.EPD.BaseLib.LoadLibrary("Libraries/Data/Hashing")

-----------------------
-- EXPLOIT DETECTION --
-----------------------
do
	
	local getgenv = getgenv or error("No Get Global Env Function")
	
	
	local function MakeExploitEnvString(Env)
		local Result = ""
		local Queue = {Env}
		local ForbiddenItems = {"_G", "EPD"}
		local AllowedTypes = {"function", "table"}
		
		local Table = nil
		local Type = nil
		while #Queue > 0 do
			Table = table.remove(Queue, 1)
			for Name, Item in next, Table do
				if type(Name) ~= "string" then continue end
				Type = type(Item)
				
				if table.find(ForbiddenItems, Item) then
					continue
				end
				
				if table.find(AllowedTypes, Type) then
					if Type == "table" then
						table.insert(Queue, Item)
					end
					Result = Result .. Name .. "<"..Type .. ">"
				end
			end
		end
		
		return Result
	end
	
	local Env = getgenv()
	local PossibleExploits = {
		1, -- Synapse
	}
	
	-- Manual Checks
	do
		-- Synapse Check
		if not Env.syn then
			table.remove(PossibleExploits, table.find(PossibleExploits, 1))
		else
			Env = Env.syn -- Only Scan Env.syn Validity
		end
	end
	
	local Checksum = m_Hashing.CRC.CRC32(MakeExploitEnvString(Env))
	--setclipboard(string.format("0x%X", Checksum))
	
	-- Do The Detection
	do
		-- Save Checksum In Case The Exploit Is Unknown
		u_HostExploit.Checksums = {Checksum}
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
	local l_Selected = {Button = nil, Execute = nil}
	local l_ScriptToolbarButtons = {}
	
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
	
	------------------------
	-- GUI INITIALIZATION --
	------------------------
	local
	ScriptsSelectionFrame,
	ToolbarMenu,
	CloseButton,
	MainFrame,
	ScriptList,
	Core
	
	do
		Core = NewInstance("ScreenGui", {IgnoreGuiInset = true})

		MainFrame = NewInstance("Frame", {
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

		local InfoSubFrame = NewInstance("Frame", {
			Size = UDim2.new(1, -80, 1, 0),
			Position = UDim2.new(0, 0, 1, 0),
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = 1,
		}, InfoFrame)

		CloseButton = NewInstance("TextButton", {
			Size = UDim2.new(0, 80, 1, 0),
			Font = Enum.Font.Ubuntu,
			TextColor3 = c_ColorScheme.Text,
			BackgroundColor3 = c_ColorScheme.Background,
			BorderColor3 = c_ColorScheme.Borders,
			Text = "Close",
			TextScaled = true,
			Active = false
		}, InfoFrame)

		ScriptList = NewInstance("ScrollingFrame", {
			Size = UDim2.new(0.3, 0, 1, -50),
			TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
			BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
			CanvasSize = UDim2.new(0, 0, 0, 0),
			VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
			BackgroundColor3 = c_ColorScheme.Background,
			BorderColor3 = c_ColorScheme.Borders,
			ScrollBarThickness = 3
		}, MainFrame)
		AddToApplyTweenList(ScriptList)

		local ScriptsListLayout = NewInstance("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.Name,
			Padding = UDim.new(0, 2)
		}, ScriptList)

		ScriptsSelectionFrame = NewInstance("Frame", {
			Size = UDim2.new(0, ScriptList.AbsoluteSize.X, 0, 18),
			Position = UDim2.new(-1, 0, 0, 0),
			BackgroundColor3 = c_ColorScheme.Selector.Idle,
			BorderSizePixel = 0,
			BackgroundTransparency = 0.6,
			ZIndex = 1
		}, MainFrame)
		AddToApplyTweenList(ScriptsSelectionFrame)

		ToolbarMenu = NewInstance("Frame", {
			Size = UDim2.new(0, ScriptList.AbsoluteSize.X, 0, 20),
			BorderSizePixel = 1,
			BorderColor3 = c_ColorScheme.Borders,
			BackgroundColor3 = c_ColorScheme.Background,
			Position = UDim2.new(0, 0, 1, -30),
			AnchorPoint = Vector2.new(0, 1)
		}, MainFrame)

		local ScriptsEditMenuLayout = NewInstance("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 0)
		}, ToolbarMenu)
		
		local ExploitLabel = NewInstance("TextLabel", {
			Size = UDim2.new(0, ScriptList.AbsoluteSize.X, 1, 0),
			BackgroundTransparency = 1,
			Font = Enum.Font.Ubuntu,
			TextColor3 = c_ColorScheme.Text,
			AutomaticSize = Enum.AutomaticSize.X,
			Text = "Exploit: " .. u_HostExploit.Name,
			TextSize = 15
		}, InfoSubFrame)
	end
	
	
	---------------------
	-- TOOLBAR BUTTONS --
	---------------------
	do
		local c_ToolbarButtons = {
			{
				Image = "rbxassetid://3926307971",
				Buttons = {
					{"AddScript", Vector2.new(324, 364)},
					{"RemoveScript", Vector2.new(884, 284)},
					{"MoveUp", Vector2.new(164, 524)},
					{"MoveDown", Vector2.new(204, 484)},
				}
			},
			{
				Image = "rbxassetid://3926305904",
				Buttons = {
					{"Configs", Vector2.new(4, 124)},
					{"Execute", Vector2.new(644, 204)}
				}
			}
		}
		
		
		local Config = {
			Size = UDim2.new(1, 0, 1, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = 1,
			ImageRectSize = Vector2.new(36, 36)
		}
		
		
		for _, ButtonSet in pairs(c_ToolbarButtons) do
			Config.Image = ButtonSet.Image
			for _, Button in pairs(ButtonSet.Buttons) do
				Config.ImageRectOffset = Button[2]
				Config.ImageColor3 = c_ColorScheme.Disabled
				l_ScriptToolbarButtons[Button[1]] = NewInstance("ImageButton", Config, ToolbarMenu)
			end
		end
	end
	
	
	-----------------------
	-- EVENTS MANAGEMENT --
	-----------------------
	do
		local l_YOffset = (ScriptsSelectionFrame.AbsoluteSize.Y - c_ScriptButtonSize.Y.Offset) / 2
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
		
		table.insert(u_Connections, ScriptList.MouseEnter:Connect(function()
			l_IsInsideScripts = true
			StartRunner()
		end))
		
		table.insert(u_Connections, ScriptList.MouseLeave:Connect(function()
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
	end
	
	-------------------------
	-- LOAD & LINK SCRIPTS --
	------------------------
	do
		local function SetToolbarButton(State, Name)
			local Target = l_ScriptToolbarButtons[Name]
			if State then
				g_TweenService:Create(Target, c_SelectorColorTweening, {ImageColor3 = c_ColorScheme.ScriptList.ToolbarButtons[Name]}):Play()
			else
				g_TweenService:Create(Target, c_SelectorColorTweening, {ImageColor3 = c_ColorScheme.Disabled}):Play()
			end
			
		end
		
		local function SetSelectedButton(Button, LoaderLambda)
			if Button == l_Selected.Button then
				g_TweenService:Create(ScriptsSelectionFrame, c_SelectorColorTweening, {BackgroundColor3 = c_ColorScheme.Selector.Idle}):Play()
				l_Selected.Button = nil
				l_Selected.Execute = nil
				l_LockSelector = false
				SetToolbarButton(false, "Execute")
				SetToolbarButton(false, "Configs")
				return
			end
			
			l_LockSelector = false
			l_SetSelectorTarget(Button)
			SetToolbarButton(true, "Execute")
			SetToolbarButton(true, "Configs")
			l_LockSelector = true
			l_Selected.Button = Button
			l_Selected.Execute = LoaderLambda
			g_TweenService:Create(ScriptsSelectionFrame, c_SelectorColorTweening, {BackgroundColor3 = c_ColorScheme.Selector.Select}):Play()
		end
		
		
		-----------------------------
		-- CREATE BUTTONS & LABELS --
		-----------------------------
		do
			local function CreateLabel(Text, Iteration)
				local Label = Instance.new("TextLabel", ScriptList)
				Label.Text = Text
				Label.TextScaled = true
				Label.Name = Iteration
				Label.Size = UDim2.new(1, 0, 0, 15)
				Label.TextColor3 = Color3.new(1, 1, 1)
				Label.Font = Enum.Font.Ubuntu
				Label.BackgroundColor3 = c_ColorScheme.ScriptList.LabelBackground
				Label.BorderSizePixel = 0
				Label.ZIndex = 2
				AddToApplyTweenList(Label)
				return Label
			end

			local function CreateButton(ScriptInfo, Iteration)
				local Button = Instance.new("TextButton", ScriptList)
				Button.Text = ScriptInfo[1] -- Name
				Button.TextScaled = true
				Button.Name = Iteration
				Button.Font = Enum.Font.Ubuntu
				Button.Size = c_ScriptButtonSize
				Button.TextColor3 = c_ColorScheme.ScriptList.Text
				Button.BackgroundTransparency = 0.5
				Button.BackgroundColor3 = c_ColorScheme.ScriptList.ButtonBackground
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

				table.insert(u_Connections, Button.MouseButton1Click:Connect(function()
					SetSelectedButton(Button, ExecuteLambda)
				end))

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
		
		
		
		---------------------
		-- TOOLBAR BUTTONS --
		--------------------
		do
			local ExecutionDebounce = false
			table.insert(u_Connections, l_ScriptToolbarButtons["Execute"].MouseButton1Click:Connect(function()
				if ExecutionDebounce then return end
				ExecutionDebounce = true
				if l_LockSelector == true and l_Selected.Button then
					g_TweenService:Create(ScriptsSelectionFrame, c_SelectorColorTweening, {BackgroundColor3 = c_ColorScheme.Selector.Loading}):Play()
					SetToolbarButton(false, "Execute")
					pcall(l_Selected.Execute)
					SetToolbarButton(true, "Execute")
					g_TweenService:Create(ScriptsSelectionFrame, c_SelectorColorTweening, {BackgroundColor3 = c_ColorScheme.Selector.Select}):Play()
				end
				ExecutionDebounce = false
			end))
		end
		
	end
	
	
	
	
	SetTransparency(1, false)
	Core.Parent = g_CoreGui
	
	SetTransparency(0, true)
end

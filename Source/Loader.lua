
-- Constants
local c_RootPath = "https://raw.githubusercontent.com/PBeta-R34/EPD-HUB/main/Source/"
local c_Scripts = {
	{"Utils", "LABEL"},
	{"Explorer", "Scripts/Explorer.lua", "Relative"},
	
	{"Other Utils", "LABEL"},
	{"Hydroxide", "local owner='Upbolt';local branch='revision';local function webImport(file)return loadstring(game:HttpGetAsync((\"https://raw.githubusercontent.com/%s/Hydroxide/%s/%s.lua\"):format(owner,branch,file)),file..'.lua')()end;webImport(\"init\")webImport(\"ui/main\")", "Script"},
	{"Infinite Yeild", "https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", "FullPath"},
	
	{"Cheats", "LABEL"},
	{"Universal ESP", "Scripts/UniversalESP.lua", "Relative"}
	
}

-- Services
local g_TweenService 	= game:GetService("TweenService")
local g_CoreGui 		= game:GetService("CoreGui")



--------------
-- MAIN GUI --
--------------
do
	-- Functions
	function RoundGui(GUI: GuiBase, Rounding: UDim)
		local RoundUI = Instance.new("UICorner", GUI)
		RoundUI.CornerRadius = Rounding
		return RoundUI
	end
	
	function BulkApply(Roots, Settings: any, Filter: any)
		local function Apply(Index, Item)
			if Filter then
				if type(Filter) == "function" 	and not Filter(Item, Index)	then return end
				if type(Filter) == "string" 	and not Item:IsA(Filter) 	then return end
			end
			if type(Settings) == "function" then
				Settings(Item)
			elseif type(Settings) == "table" then
				for Name, Setting in pairs(Settings) do
					Item[Name] = Setting
				end
			end
		end
		
		for RootIndex, Root in pairs(Roots) do
			Apply(RootIndex, Root)
			for Index, Item in pairs(Root:GetDescendants()) do
				Apply(Index, Item)
			end
		end
	end
	
	local function NewInstance(ClassName, Settings, Parent)
		local Created = Instance.new(ClassName)
		for Name, Value in pairs(Settings) do
			Created[Name] = Value
		end
		Created.Parent = Parent
		return Created
	end
	
	-- Gui
	local Core = NewInstance("ScreenGui", {IgnoreGuiInset = true})
	
	local MainFrame = NewInstance("Frame", {
		Size = UDim2.new(0, 400, 0, 330),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Transparency = 1
	}, Core)
	RoundGui(MainFrame, UDim.new(0, 4))
	
	local InfoFrame = NewInstance("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0, 0, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		Transparency = 1
	}, MainFrame)
	
	local Scripts = NewInstance("ScrollingFrame", {
		Size = UDim2.new(0.3, 0, 1, -30),
		TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
		CanvasSize = UDim2.new(0, 0, 0, 0),
		VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Left,
		ScrollBarThickness = 3
	}, MainFrame)

	
	local ScriptsListLayout = NewInstance("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.Name,
		Padding = UDim.new(0, 2)
	}, Scripts)
	
	BulkApply({MainFrame, Scripts}, {BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ClipsDescendants = true}, "GuiObject")
	
	------------------
	-- LOAD SCRIPTS --
	------------------
	do
		local function CreateLabel(Text, Iteration)
			local Label = Instance.new("TextLabel", Scripts)
			Label.Text = Text
			Label.TextScaled = true
			Label.Name = Iteration
			Label.Size = UDim2.new(1, 0, 0, 15)
			Label.TextColor3 = Color3.new(1, 1, 1)
			Label.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			Label.BorderSizePixel = 0
			return Label
		end
		
		local function CreateButton(Text, Iteration)
			local Button = Instance.new("TextButton", Scripts)
			Button.Text = Text
			Button.TextScaled = true
			Button.Name = Iteration
			Button.Font = Enum.Font.Ubuntu
			Button.Size = UDim2.new(0.6, 0, 0, 18)
			Button.TextColor3 = Color3.new(1, 1, 1)
			Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			Button.BorderSizePixel = 0
			RoundGui(Button, UDim.new(0, 4))
			return Button
		end
		
		for Iteration, ItemVal in pairs(c_Scripts) do
			if ItemVal[2] == "LABEL" then
				CreateLabel(ItemVal[1], Iteration)
			else
				CreateButton(ItemVal[1], Iteration)
			end
		end
	end
	
	
	BulkApply({Core}, {Transparency = 1}, "GuiObject")
	Core.Parent = g_CoreGui
	
	local Info = TweenInfo.new(
		0.5,
		Enum.EasingStyle.Quint,
		Enum.EasingDirection.InOut
	)
	BulkApply(Core:GetChildren(), function(Item) g_TweenService:Create(Item, Info, {Transparency = 0}):Play() end, "GuiObject")
end

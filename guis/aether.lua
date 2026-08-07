-- AetherV3 interface
-- Built as an independent, asset-free interface for the Aether module API.
local license = ... or {
}

local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local HttpService = game:GetService('HttpService')
local RunService = game:GetService('RunService')
local TextService = game:GetService('TextService')
local player = Players.LocalPlayer

local function create(class,
	properties)
	local object = Instance.new(class)
	for property,
value in pairs(properties or {
	}
) do
		if property ~= 'Parent' then object[property] = value end
	end
	object.Parent = properties and properties.Parent
	return object
end

local theme = {

	Background = Color3.fromRGB(10,
		12,
		18),

	Surface = Color3.fromRGB(18,
		21,
		30),

	Raised = Color3.fromRGB(27,
		31,
		43),

	Text = Color3.fromRGB(239,
		242,
		250),

	Muted = Color3.fromRGB(142,
		150,
		170),

	Accent = Color3.fromRGB(119,
		92,
		255),

	Accent2 = Color3.fromRGB(64,
		204,
		255),

	Danger = Color3.fromRGB(255,
		91,
		118)
}


local function corner(parent,
	radius)
	return create('UICorner',
	{
		CornerRadius = UDim.new(0,
			radius or 8),
		Parent = parent
	}
)
end

local function stroke(parent,
	color,
	transparency)
	return create('UIStroke',
	{
		Color = color or theme.Raised,
		Transparency = transparency or 0,
		Thickness = 1,
		Parent = parent
	}
)
end

local function tween(object,
	goal,
	duration)
	local animation = TweenService:Create(object,
	TweenInfo.new(duration or 0.16,
		Enum.EasingStyle.Quart,
		Enum.EasingDirection.Out),
	goal)
	animation:Play()
	return animation
end

local parent = (gethui and gethui()) or game:GetService('CoreGui')
local screen = create('ScreenGui',
	{

		Name = 'AetherV3',
		ResetOnSpawn = false,
		IgnoreGuiInset = true,

		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = parent
	}
)
if syn and syn.protect_gui then pcall(syn.protect_gui,
	screen) end

-- Public standalone hierarchy. Older game modules only need a stable place to
-- parent overlays and a frame whose AbsoluteSize matches the viewport.
local guiRoot = create('Frame', {
	Name = 'Runtime',
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Parent = screen
})
local scaledGui = create('Frame', {
	Name = 'ScaledGui',
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Parent = guiRoot
})

local aether = {

	gui = guiRoot,

	Categories = {
	}
	,
	Modules = {
	}
	,
	Windows = {
	}
	,
	Components = {
	}
	,
	Libraries = {
	}
	,
	Legit = {},
	Kits = {},

	Connections = {
	}
	,
	Keybind = {
		'RightShift'
	}
	,
	Profile = 'default',
	Place = game.PlaceId,

	Loaded = false,
	Unloaded = false,
	ToggleNotifications = true,
	guiscale = 1
}


function aether:Clean(item)
	if item then table.insert(self.Connections,
	item) end
	return item
end

function aether:Remove(item)
	local position = table.find(self.Connections,
	item)
	if position then table.remove(self.Connections,
	position) end
	if typeof(item) == 'RBXScriptConnection' then item:Disconnect()
	elseif typeof(item) == 'Instance' then item:Destroy()
	elseif type(item) == 'function' then item() end
end

function aether:ThreadFix(callback)
	return function(...)
		local arguments = table.pack(...)
		task.spawn(function() callback(table.unpack(arguments,
			1,
			arguments.n)) end)
	end
end

local root = create('Frame',
	{

		Name = 'ClickGui',
		AnchorPoint = Vector2.new(0.5,
			0.5),
		Position = UDim2.fromScale(0.5,
			0.5),

		Size = UDim2.fromOffset(900,
			570),
		BackgroundColor3 = theme.Background,

		BorderSizePixel = 0,
		Parent = scaledGui
	}
)
corner(root,
	16)
stroke(root,
	Color3.fromRGB(52,
		58,
		76),
	0.2)
create('UISizeConstraint',
	{
		MinSize = Vector2.new(620,
			400),
		MaxSize = Vector2.new(1100,
			720),
		Parent = root
	}
)

local sidebar = create('Frame',
	{
		Size = UDim2.new(0,
			205,
			1,
			0),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Parent = root
	}
)
corner(sidebar,
	16)
create('Frame',
	{
		Position = UDim2.new(1,
			-16,
			0,
			0),
		Size = UDim2.new(0,
			16,
			1,
			0),
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Parent = sidebar
	}
)
create('Frame',
	{
		Position = UDim2.new(1,
			0,
			0,
			0),
		Size = UDim2.new(0,
			1,
			1,
			0),
		BackgroundColor3 = theme.Raised,
		BorderSizePixel = 0,
		Parent = sidebar
	}
)
local brand = create('TextLabel',
	{
		Position = UDim2.fromOffset(24,
			20),
		Size = UDim2.new(1,
			-48,
			0,
			34),
		BackgroundTransparency = 1,
		Text = 'AETHER',
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sidebar
	}
)
local brandAccent = create('TextLabel',
	{
		Position = UDim2.fromOffset(118,
			22),
		Size = UDim2.fromOffset(46,
			28),
		BackgroundTransparency = 1,
		Text = 'V3',
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = theme.Accent2,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sidebar
	}
)
local nav = create('ScrollingFrame',
	{
		Position = UDim2.fromOffset(12,
			76),
		Size = UDim2.new(1,
			-24,
			1,
			-140),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = sidebar
	}
)
create('UIListLayout',
	{
		Padding = UDim.new(0,
			5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = nav
	}
)
local footer = create('TextLabel',
	{
		Position = UDim2.new(0,
			24,
			1,
			-44),
		Size = UDim2.new(1,
			-48,
			0,
			24),
		BackgroundTransparency = 1,
		Text = 'RIGHT SHIFT  ·  TOGGLE',
		Font = Enum.Font.GothamMedium,
		TextSize = 10,
		TextColor3 = theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = sidebar
	}
)

local content = create('Frame',
	{
		Position = UDim2.fromOffset(205,
			0),
		Size = UDim2.new(1,
			-205,
			1,
			0),
		BackgroundTransparency = 1,
		Parent = root
	}
)
local heading = create('TextLabel',
	{
		Position = UDim2.fromOffset(28,
			20),
		Size = UDim2.new(1,
			-56,
			0,
			30),
		BackgroundTransparency = 1,
		Text = 'Combat',
		Font = Enum.Font.GothamBold,
		TextSize = 22,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = content
	}
)
local subheading = create('TextLabel',
	{
		Position = UDim2.fromOffset(28,
			49),
		Size = UDim2.new(1,
			-56,
			0,
			18),
		BackgroundTransparency = 1,
		Text = 'Configure your modules',
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = content
	}
)
local pages = create('Frame',
	{
		Position = UDim2.fromOffset(24,
			82),
		Size = UDim2.new(1,
			-48,
			1,
			-104),
		BackgroundTransparency = 1,
		Parent = content
	}
)

local dragging,
dragStart,
startPosition
aether:Clean(root.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y <= root.AbsolutePosition.Y + 72 then
		dragging,
		dragStart,
		startPosition = true,
		input.Position,
		root.Position
		end
		end))
aether:Clean(UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		root.Position = startPosition + UDim2.fromOffset(delta.X,
			delta.Y)
		end
		end))
aether:Clean(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
		end))

local selectedCategory
local function selectCategory(category)
	if selectedCategory == category then return end
	if selectedCategory then
		selectedCategory.Page.Visible = false
		tween(selectedCategory.Button,
	{
		BackgroundTransparency = 1
	}
)
		selectedCategory.Button.TextColor3 = theme.Muted
	end
	selectedCategory = category
	category.Page.Visible = true
	tween(category.Button,
	{
		BackgroundTransparency = 0
	}
)
	category.Button.TextColor3 = theme.Text
	heading.Text = category.Name
	subheading.Text = category.Name == 'Profiles' and 'Manage interface preferences' or 'Configure '..category.Name:lower()..' modules'
end

local function makeRow(parent,
	height)
	local row = create('Frame',
	{
		Size = UDim2.new(1,
			0,
			0,
			height or 42),
		BackgroundColor3 = theme.Raised,
		BackgroundTransparency = 0.32,
		BorderSizePixel = 0,
		Parent = parent
	}
)
	corner(row,
	7)
	return row
end

local optionMethods = {
}

local function changeOption(option,
	value,
	skipCallback)
	if option.Type == 'TwoSlider' then option.ValueMin,
option.ValueMax = value[1],
value[2]
	elseif option.Type == 'ColorSlider' then option.Hue,
option.Sat,
option.Value,
option.Opacity = value[1],
value[2],
value[3],
value[4] or 1
	elseif option.Type == 'Font' then
		local fontName = typeof(value) == 'Font' and option.FontName or tostring(value)
		if not Enum.Font[fontName] then fontName = 'Gotham' end
		option.FontName = fontName
		option.Value = Font.fromEnum(Enum.Font[fontName])
	else option.Value = value;
if option.Type == 'Toggle' then option.Enabled = value end end
	if option.Render then option:Render() end
	if not skipCallback and option.Function then
		if option.Type == 'ColorSlider' then task.spawn(option.Function,
	option.Hue,
	option.Sat,
	option.Value,
	option.Opacity)
		elseif option.Type == 'TwoSlider' then task.spawn(option.Function,
	option.ValueMin,
	option.ValueMax)
		else task.spawn(option.Function,
	option.Value) end
	end
end

function optionMethods:SetValue(value) changeOption(self,
	value) end
function optionMethods:Toggle(value) changeOption(self,
	value == nil and not self.Enabled or value) end
function optionMethods:SetVisible(value) self.Object.Visible = value end
function optionMethods:Change(value) changeOption(self,
	value) end
function optionMethods:Increment(value) changeOption(self,
	(self.Value or 0) + value) end

local function addOption(module,
	data,
	kind)
	data = data or {
}

	local option = setmetatable({
		Name = data.Name or kind,
		Type = kind,
		Function = data.Function,
		Object = nil
	}
	,
	{
		__index = optionMethods
	}
)
	local row = makeRow(module.Options,
	kind == 'TextList' and 70 or 40)
	option.Object = row
	local label = create('TextLabel',
	{
		Position = UDim2.fromOffset(12,
			0),
		Size = UDim2.new(0.48,
			-12,
			1,
			0),
		BackgroundTransparency = 1,
		Text = option.Name,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row
	}
)

	if kind == 'Toggle' then
		option.Enabled = data.Default == true;
option.Value = option.Enabled
		local track = create('TextButton',
	{
		AnchorPoint = Vector2.new(1,
			0.5),
		Position = UDim2.new(1,
			-12,
			0.5,
			0),
		Size = UDim2.fromOffset(36,
			20),
		BackgroundColor3 = theme.Surface,
		Text = '',
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = row
	}
)
		corner(track,
	10)
		local knob = create('Frame',
	{
		Position = UDim2.fromOffset(3,
			3),
		Size = UDim2.fromOffset(14,
			14),
		BackgroundColor3 = theme.Muted,
		BorderSizePixel = 0,
		Parent = track
	}
);
corner(knob,
	7)
		function option:Render() tween(track,
	{
		BackgroundColor3 = self.Enabled and theme.Accent or theme.Surface
	}
);
tween(knob,
	{
		Position = UDim2.fromOffset(self.Enabled and 19 or 3,
			3),
		BackgroundColor3 = self.Enabled and theme.Text or theme.Muted
	}
) end
		track.MouseButton1Click:Connect(function() option:Toggle() end)
	elseif kind == 'Slider' or kind == 'TwoSlider' then
		option.Min,
option.Max = data.Min or 0,
data.Max or 100
		option.Value = data.Default or data.DefaultValue or option.Min;
option.ValueMin = data.DefaultMin or data.DefaultValueMin or data.Min or option.Min;
option.ValueMax = data.DefaultMax or data.DefaultValueMax or data.Max or option.Max
		local valueLabel = create('TextLabel',
	{
		AnchorPoint = Vector2.new(1,
			0.5),
		Position = UDim2.new(1,
			-12,
			0.5,
			0),
		Size = UDim2.fromOffset(118,
			24),
		BackgroundColor3 = theme.Surface,
		TextColor3 = theme.Accent2,
		Font = Enum.Font.GothamMedium,
		TextSize = 11,
		Parent = row
	}
);
corner(valueLabel,
	6)
		function option:Render() valueLabel.Text = kind == 'TwoSlider' and (tostring(self.ValueMin)..'  —  '..tostring(self.ValueMax)) or tostring(self.Value) end
		local active = false
		valueLabel.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then active = true end end)
		UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then active = false end end)
		UserInputService.InputChanged:Connect(function(input)
			if active and input.UserInputType == Enum.UserInputType.MouseMovement then
				local alpha = math.clamp((input.Position.X - valueLabel.AbsolutePosition.X) / valueLabel.AbsoluteSize.X,
		0,
		1)
				local value = math.floor((option.Min + (option.Max - option.Min) * alpha) * 100) / 100
				if kind == 'TwoSlider' then changeOption(option,
		{
			math.min(value,
				option.ValueMax),
			option.ValueMax
		}
	) else changeOption(option,
		value) end
			end
		end)
	elseif kind == 'Dropdown' then
		option.List = data.List or {
}
;
option.Value = data.Default or data.DefaultValue or option.List[1] or ''
		local button = create('TextButton',
	{
		AnchorPoint = Vector2.new(1,
			0.5),
		Position = UDim2.new(1,
			-12,
			0.5,
			0),
		Size = UDim2.fromOffset(150,
			26),
		BackgroundColor3 = theme.Surface,
		TextColor3 = theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		AutoButtonColor = false,
		Parent = row
	}
);
corner(button,
	6)
		function option:Render() button.Text = tostring(self.Value)..'  ▾' end
		button.MouseButton1Click:Connect(function()
			local index = table.find(option.List,
		option.Value) or 0
			changeOption(option,
		option.List[index % math.max(#option.List,
				1) + 1] or '')
		end)
	elseif kind == 'TextBox' then
		option.Value = data.Default or data.DefaultValue or ''
		local box = create('TextBox',
	{
		AnchorPoint = Vector2.new(1,
			0.5),
		Position = UDim2.new(1,
			-12,
			0.5,
			0),
		Size = UDim2.fromOffset(170,
			26),
		BackgroundColor3 = theme.Surface,
		PlaceholderText = data.Placeholder or 'Enter value',
		Text = option.Value,
		TextColor3 = theme.Text,
		PlaceholderColor3 = theme.Muted,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		Parent = row
	}
);
corner(box,
	6)
		function option:Render() box.Text = tostring(self.Value) end
		box.FocusLost:Connect(function() changeOption(option,
		box.Text) end)
	elseif kind == 'ColorSlider' then
		option.Hue,
option.Sat,
option.Value,
option.Opacity = data.DefaultHue or data.Hue or 0.72,
data.DefaultSat or data.Sat or 1,
data.DefaultValue or data.Value or 1,
data.DefaultOpacity or data.Opacity or 1
		local swatch = create('TextButton',
	{
		AnchorPoint = Vector2.new(1,
			0.5),
		Position = UDim2.new(1,
			-12,
			0.5,
			0),
		Size = UDim2.fromOffset(62,
			24),
		Text = '',
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = row
	}
);
corner(swatch,
	6)
		function option:Render() swatch.BackgroundColor3 = Color3.fromHSV(self.Hue,
	self.Sat,
	self.Value) end
		swatch.MouseButton1Click:Connect(function() changeOption(option,
		{
			(option.Hue + 0.08) % 1,
			option.Sat,
			option.Value,
			option.Opacity
		}
	) end)
	elseif kind == 'TextList' then
		option.List,
option.ListEnabled = data.Default or {
}
,
data.DefaultEnabled or {
}

		local box = create('TextBox',
	{
		Position = UDim2.new(0.48,
			0,
			0,
			8),
		Size = UDim2.new(0.52,
			-54,
			0,
			25),
		BackgroundColor3 = theme.Surface,
		PlaceholderText = 'Add item',
		Text = '',
		TextColor3 = theme.Text,
		PlaceholderColor3 = theme.Muted,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		Parent = row
	}
);
corner(box,
	6)
		local add = create('TextButton',
	{
		AnchorPoint = Vector2.new(1,
			0),
		Position = UDim2.new(1,
			-12,
			0,
			8),
		Size = UDim2.fromOffset(34,
			25),
		BackgroundColor3 = theme.Accent,
		Text = '+',
		TextColor3 = theme.Text,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		Parent = row
	}
);
corner(add,
	6)
		local summary = create('TextLabel',
	{
		Position = UDim2.new(0.48,
			0,
			0,
			38),
		Size = UDim2.new(0.52,
			-12,
			0,
			22),
		BackgroundTransparency = 1,
		TextColor3 = theme.Muted,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row
	}
)
		function option:Render() summary.Text = #self.List == 0 and 'No entries' or table.concat(self.List,
	', ') end
		function option:Add(value) if value ~= '' and not table.find(self.List,
	value) then table.insert(self.List,
	value);
table.insert(self.ListEnabled,
	value);
self:Render();
if self.Function then task.spawn(self.Function,
	self.List) end end end
		function option:Remove(value) table.remove(self.List,
	table.find(self.List,
		value) or 0);
table.remove(self.ListEnabled,
	table.find(self.ListEnabled,
		value) or 0);
self:Render() end
		add.MouseButton1Click:Connect(function() option:Add(box.Text);
	box.Text = '' end)
	end
	option:Render()
	module.OptionsTable[option.Name] = option
	return option
end

local moduleMethods = {
}

function moduleMethods:Clean(item) table.insert(self.Connections,
	item);
return item end
function moduleMethods:SetVisible(value) self.Object.Visible = value end
function moduleMethods:Toggle(value)
	value = value == nil and not self.Enabled or value
	if self.Enabled == value then return end
	self.Enabled = value
	tween(self.Object,
	{
		BackgroundColor3 = value and theme.Accent or theme.Surface
	}
)
	self.Status.Text = value and 'ON' or 'OFF'
	self.Status.TextColor3 = value and theme.Text or theme.Muted
	if self.Function then task.spawn(self.Function,
	value) end
end
function moduleMethods:CreateToggle(data) return addOption(self,
	data,
	'Toggle') end
function moduleMethods:CreateSlider(data) return addOption(self,
	data,
	'Slider') end
function moduleMethods:CreateTwoSlider(data) return addOption(self,
	data,
	'TwoSlider') end
function moduleMethods:CreateDropdown(data) return addOption(self,
	data,
	'Dropdown') end
function moduleMethods:CreateColorSlider(data) return addOption(self,
	data,
	'ColorSlider') end
function moduleMethods:CreateTextBox(data) return addOption(self,
	data,
	'TextBox') end
function moduleMethods:CreateTextList(data) return addOption(self,
	data,
	'TextList') end
function moduleMethods:CreateFont(data)
	data = data or {
}
	local fontNames = {
		'Gotham',
		'Arial',
		'SourceSans',
		'RobotoMono'
	}
	local option = setmetatable({
		Name = data.Name or 'Font',
		Type = 'Font',
		Function = data.Function,
		FontName = data.Default or 'Gotham'
	}, {
		__index = optionMethods
	})
	option.Value = Font.fromEnum(Enum.Font[option.FontName] or Enum.Font.Gotham)
	local row = makeRow(self.Options, 40)
	option.Object = row
	create('TextLabel', {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(0.48, -12, 1, 0),
		BackgroundTransparency = 1,
		Text = option.Name,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = row
	})
	local button = create('TextButton', {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(150, 26),
		BackgroundColor3 = theme.Surface,
		TextColor3 = theme.Text,
		Font = Enum.Font.Gotham,
		TextSize = 11,
		AutoButtonColor = false,
		Parent = row
	})
	corner(button, 6)
	function option:Render()
		button.Text = self.FontName..'  ▾'
	end
	button.MouseButton1Click:Connect(function()
		local index = table.find(fontNames, option.FontName) or 1
		changeOption(option, fontNames[index % #fontNames + 1])
	end)
	option:Render()
	self.OptionsTable[option.Name] = option
	return option
end
function moduleMethods:CreateHotbarList(data)
	local option = addOption(self,
	{
		Name = (data and data.Name) or 'Hotbars'
	}
	,
	'TextList')
	option.Hotbars = {
	{
		Name = 'Default',
		Hotbar = {
		}
	}
}

	option.Selected = 1
	function option:AddHotbar(name)
		table.insert(self.Hotbars,
	{
		Name = name or ('Hotbar '..(#self.Hotbars + 1)),
		Hotbar = {
		}
	}
)
	end
	return option
end
function moduleMethods:CreateButton(data)
	local option = addOption(self,
	data,
	'TextBox')
	option.Object:ClearAllChildren()
	local button = create('TextButton',
	{
		Size = UDim2.fromScale(1,
			1),
		BackgroundTransparency = 1,
		Text = data.Name or 'Action',
		TextColor3 = theme.Accent2,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		Parent = option.Object
	}
)
	button.MouseButton1Click:Connect(data.Function or function() end)
	return option
end
function moduleMethods:CreateTargets(data)
	local target = {
	Players = data and data.Players ~= false or true,
	NPCs = data and data.NPCs or false,
	Invisible = false,
	Walls = false
}

	function target:Get(value) return self[value] end
	return target
end

local function createCategory(name,
	order)
	local category = {
	Name = name,
	Modules = {
	}
}

	category.Button = create('TextButton',
	{
		LayoutOrder = order,
		Size = UDim2.new(1,
			0,
			0,
			38),
		BackgroundColor3 = theme.Raised,
		BackgroundTransparency = 1,
		Text = '   '..name,
		TextColor3 = theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		AutoButtonColor = false,
		Parent = nav
	}
)
	corner(category.Button,
	8)
	category.Page = create('ScrollingFrame',
	{
		Size = UDim2.fromScale(1,
			1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = pages
	}
)
	create('UIListLayout',
	{
		Padding = UDim.new(0,
			9),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = category.Page
	}
)
	category.Button.MouseButton1Click:Connect(function() selectCategory(category) end)
	function category:CreateModule(data)
		data = data or {
}

		local module = setmetatable({
		Name = data.Name or 'Module',
		Function = data.Function,
		Tooltip = data.Tooltip or '',
		Enabled = false,
		Bind = data.Bind or {
		}
		,
		Connections = {
		}
		,
		OptionsTable = {
		}
		,
		Category = self.Name
	}
	,
	{
		__index = moduleMethods
	}
)
		module.Button = module
		local card = create('Frame',
	{
		Size = UDim2.new(1,
			-5,
			0,
			54),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = theme.Surface,
		BorderSizePixel = 0,
		Parent = self.Page
	}
)
		corner(card,
	10);
stroke(card,
	theme.Raised,
	0.25)
		module.Object = create('TextButton',
	{
		Size = UDim2.new(1,
			0,
			0,
			54),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 0.3,
		Text = '',
		AutoButtonColor = false,
		BorderSizePixel = 0,
		Parent = card
	}
);
corner(module.Object,
	10)
		create('TextLabel',
	{
		Position = UDim2.fromOffset(15,
			7),
		Size = UDim2.new(1,
			-90,
			0,
			21),
		BackgroundTransparency = 1,
		Text = module.Name,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = module.Object
	}
)
		create('TextLabel',
	{
		Position = UDim2.fromOffset(15,
			28),
		Size = UDim2.new(1,
			-90,
			0,
			16),
		BackgroundTransparency = 1,
		Text = module.Tooltip,
		Font = Enum.Font.Gotham,
		TextSize = 10,
		TextColor3 = theme.Muted,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = module.Object
	}
)
		module.Status = create('TextLabel',
	{
		AnchorPoint = Vector2.new(1,
			0.5),
		Position = UDim2.new(1,
			-15,
			0.5,
			0),
		Size = UDim2.fromOffset(42,
			22),
		BackgroundTransparency = 1,
		Text = 'OFF',
		Font = Enum.Font.GothamBold,
		TextSize = 10,
		TextColor3 = theme.Muted,
		Parent = module.Object
	}
)
		module.Options = create('Frame',
	{
		Position = UDim2.fromOffset(10,
			55),
		Size = UDim2.new(1,
			-20,
			0,
			0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = card
	}
)
		create('UIListLayout',
	{
		Padding = UDim.new(0,
			5),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = module.Options
	}
)
		create('UIPadding',
	{
		PaddingBottom = UDim.new(0,
			10),
		Parent = module.Options
	}
)
		module.Object.MouseButton1Click:Connect(function() module:Toggle() end)
		self.Modules[module.Name] = module;
aether.Modules[module.Name] = module
		return module
	end
	aether.Categories[name] = category
	return category
end

local categoryNames = {
	'Combat',
	'Blatant',
	'Legit',
	'Render',
	'Visuals',
	'Utility',
	'World',
	'Inventory',
	'Exploits',
	'Minigames',
	'Kits',
	'Main',
	'Friends',
	'Targets'
}

for index,
name in ipairs(categoryNames) do createCategory(name,
	index) end

local friendColorEvent = Instance.new('BindableEvent')
local friends = aether.Categories.Friends
friends.ListEnabled = {}
friends.Options = {
	['Use friends'] = {Enabled = true},
	['Recolor visuals'] = {Enabled = true},
	['Friends color'] = {Hue = 0.44, Sat = 1, Value = 1, Opacity = 1, Rainbow = false}
}
friends.ColorUpdate = friendColorEvent
function friends:Update()
	friendColorEvent:Fire(self.ListEnabled)
end

local targets = aether.Categories.Targets
targets.ListEnabled = {}
targets.Options = {}
function targets:Update()
	return self.ListEnabled
end

local mainCategory = aether.Categories.Main
mainCategory.Options = {
	['GUI bind indicator'] = {Enabled = false}
}

selectCategory(aether.Categories.Combat)

local notifications = create('Frame',
	{
		AnchorPoint = Vector2.new(1,
			1),
		Position = UDim2.new(1,
			-20,
			1,
			-20),
		Size = UDim2.fromOffset(320,
			500),
		BackgroundTransparency = 1,
		Parent = screen
	}
)
create('UIListLayout',
	{
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0,
			8),
		Parent = notifications
	}
)
function aether:CreateNotification(title,
	message,
	duration,
	kind)
	if not self.ToggleNotifications then return {
	Destroy = function() end
}
end
	local toast = create('Frame',
	{
		Size = UDim2.new(1,
			0,
			0,
			70),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		Parent = notifications
	}
);
corner(toast,
	10);
stroke(toast,
	kind == 'alert' and theme.Danger or theme.Accent,
	0.1)
	create('Frame',
	{
		Size = UDim2.fromOffset(4,
			70),
		BackgroundColor3 = kind == 'alert' and theme.Danger or theme.Accent,
		BorderSizePixel = 0,
		Parent = toast
	}
)
	create('TextLabel',
	{
		Position = UDim2.fromOffset(16,
			9),
		Size = UDim2.new(1,
			-28,
			0,
			20),
		BackgroundTransparency = 1,
		Text = title or 'AetherV3',
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = toast
	}
)
	create('TextLabel',
	{
		Position = UDim2.fromOffset(16,
			30),
		Size = UDim2.new(1,
			-28,
			0,
			31),
		BackgroundTransparency = 1,
		Text = tostring(message or ''),
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextWrapped = true,
		TextColor3 = theme.Muted,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Parent = toast
	}
)
	toast.Position = UDim2.fromOffset(340,
	0);
tween(toast,
	{
		Position = UDim2.new()
	}
	,
	0.25)
	task.delay(duration or 4,
	function() if toast.Parent then tween(toast,
		{
			Position = UDim2.fromOffset(340,
				0),
			BackgroundTransparency = 1
		}
		,
		0.25);
	task.wait(0.3);
	toast:Destroy() end end)
	return toast
end

function aether:CreateOverlay(data)
	data = data or {
}

	local overlay = create('Frame',
	{
		Position = data.Position or UDim2.fromOffset(20,
			100),
		Size = data.Size or UDim2.fromOffset(200,
			80),
		BackgroundColor3 = theme.Surface,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Parent = screen
	}
);
corner(overlay,
	9);
stroke(overlay,
	theme.Raised)
	return overlay
end

local configPath = 'aetherv3/profiles/'
function aether:Save()
	if not writefile then return end
	if makefolder and not isfolder('aetherv3') then makefolder('aetherv3') end
	if makefolder and not isfolder(configPath:sub(1,
		-2)) then makefolder(configPath:sub(1,
		-2)) end
	local data = {
	Modules = {
	}
	,
	Keybind = self.Keybind
}

	for name,
module in pairs(self.Modules) do
		local saved = {
	Enabled = module.Enabled,
	Options = {
	}
}

		for optionName,
option in pairs(module.OptionsTable) do
			saved.Options[optionName] = option.Type == 'Toggle' and option.Enabled or option.Type == 'TwoSlider' and {
	option.ValueMin,
	option.ValueMax
}
or option.Type == 'ColorSlider' and {
	option.Hue,
	option.Sat,
	option.Value,
	option.Opacity
}
			or option.Type == 'Font' and option.FontName
or option.Value
		end
		data.Modules[name] = saved
	end
	writefile(configPath..self.Profile..'.json',
	HttpService:JSONEncode(data))
end

function aether:Load()
	if not (isfile and isfile(configPath..self.Profile..'.json')) then return end
	local ok,
data = pcall(HttpService.JSONDecode,
	HttpService,
	readfile(configPath..self.Profile..'.json'))
	if not ok or type(data) ~= 'table' then return end
	for name,
saved in pairs(data.Modules or {
	}
) do
		local module = self.Modules[name]
		if module then
			for optionName,
value in pairs(saved.Options or {
	}
) do if module.OptionsTable[optionName] then changeOption(module.OptionsTable[optionName],
	value,
	true) end end
			if saved.Enabled then module:Toggle(true) end
		end
	end
end

function aether:Init() self.Loaded = true;
self:CreateNotification('AetherV3',
	'Interface ready',
	3) end
function aether:Uninject()
	if self.Unloaded then return end
	self.Unloaded = true
	pcall(function() self:Save() end)
	for _,
module in pairs(self.Modules) do if module.Enabled then pcall(function() module:Toggle(false) end) end;
for _,
connection in ipairs(module.Connections) do pcall(function() self:Remove(connection) end) end end
	for _,
connection in ipairs(self.Connections) do pcall(function() self:Remove(connection) end) end
	if screen then screen:Destroy() end
	shared.Aether = nil
end

aether:Clean(UserInputService.InputBegan:Connect(function(input,
			processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.RightShift then root.Visible = not root.Visible end
		for _,
		module in pairs(aether.Modules) do
		if module.Bind and table.find(module.Bind,
			input.KeyCode.Name) then module:Toggle() end
		end
		end))

aether.AetherButton = root
aether.Windows = aether.Categories
aether.Components = {
	Theme = theme,
	Root = root,
	Sidebar = sidebar,
	Content = content
}


-- Advanced interface services -------------------------------------------------
-- These services intentionally live with the interface. Game modules only need
-- the small public API above, while users get a complete desktop-style shell.
local interface = {

	Commands = {
	}
	,

	Themes = {
	}
	,

	Profiles = {
	}
	,

	SearchIndex = {
	}
	,

	FavouriteModules = {
	}
	,

	RecentModules = {
	}
	,

	Animations = true,

	Blur = false,

	Compact = false,

	ReducedMotion = false,

	NotificationDuration = 4,

	Scale = 1,

	Visible = true
}

aether.Interface = interface

local function safeCall(callback,
	...)
	if type(callback) ~= 'function' then return true end
	local ok,
result = pcall(callback,
	...)
	if not ok then
		warn('[AetherV3 Interface] '..tostring(result))
	end
	return ok,
result
end

local function bind(signal,
	callback,
	bucket)
	local connection = signal:Connect(callback)
	table.insert(bucket or aether.Connections,
	connection)
	return connection
end

local function newSignal()
	local event = Instance.new('BindableEvent')
	local signal = {
}

	function signal:Connect(callback) return event.Event:Connect(callback) end
	function signal:Once(callback) return event.Event:Once(callback) end
	function signal:Wait() return event.Event:Wait() end
	function signal:Fire(...) event:Fire(...) end
	function signal:Destroy() event:Destroy() end
	return signal
end

interface.CategoryChanged = newSignal()
interface.ModuleChanged = newSignal()
interface.ThemeChanged = newSignal()
interface.ScaleChanged = newSignal()
interface.ProfileChanged = newSignal()
interface.VisibilityChanged = newSignal()

local uiScale = create('UIScale',
	{
		Scale = 1,
		Parent = root
	}
)
function interface:SetScale(value)
	value = math.clamp(tonumber(value) or 1,
	0.65,
	1.35)
	self.Scale = value
	aether.guiscale = value
	uiScale.Scale = value
	self.ScaleChanged:Fire(value)
end

function interface:SetVisible(value)
	self.Visible = value == true
	root.Visible = self.Visible
	self.VisibilityChanged:Fire(self.Visible)
end

function interface:Toggle()
	self:SetVisible(not self.Visible)
end

local dimmer = create('Frame',
	{

		Name = 'Dimmer',

		Size = UDim2.fromScale(1,
			1),

		BackgroundColor3 = Color3.new(),

		BackgroundTransparency = 0.45,

		BorderSizePixel = 0,

		Visible = false,

		ZIndex = 80,

		Parent = screen
	}
)

local modalLayer = create('Frame',
	{

		Name = 'Modals',

		Size = UDim2.fromScale(1,
			1),

		BackgroundTransparency = 1,

		ZIndex = 81,

		Parent = screen
	}
)

function interface:Confirm(titleText,
	bodyText,
	acceptText,
	cancelText)
	dimmer.Visible = true
	local result = newSignal()
	local card = create('Frame',
	{

		AnchorPoint = Vector2.new(0.5,
			0.5),

		Position = UDim2.fromScale(0.5,
			0.5),

		Size = UDim2.fromOffset(390,
			210),

		BackgroundColor3 = theme.Surface,

		BorderSizePixel = 0,

		ZIndex = 82,

		Parent = modalLayer

	}
)
	corner(card,
	14)
	stroke(card,
	theme.Raised)
	create('TextLabel',
	{

		Position = UDim2.fromOffset(24,
			20),

		Size = UDim2.new(1,
			-48,
			0,
			30),

		BackgroundTransparency = 1,

		Text = titleText or 'Are you sure?',

		TextColor3 = theme.Text,

		Font = Enum.Font.GothamBold,

		TextSize = 18,

		TextXAlignment = Enum.TextXAlignment.Left,

		ZIndex = 83,

		Parent = card

	}
)
	create('TextLabel',
	{

		Position = UDim2.fromOffset(24,
			58),

		Size = UDim2.new(1,
			-48,
			0,
			70),

		BackgroundTransparency = 1,

		Text = bodyText or 'This action cannot be undone.',

		TextColor3 = theme.Muted,

		Font = Enum.Font.Gotham,

		TextSize = 12,

		TextWrapped = true,

		TextXAlignment = Enum.TextXAlignment.Left,

		TextYAlignment = Enum.TextYAlignment.Top,

		ZIndex = 83,

		Parent = card

	}
)
	local function finish(value)
		if not card.Parent then return end
		card:Destroy()
		dimmer.Visible = false
		result:Fire(value)
		task.defer(function() result:Destroy() end)
	end
	local cancel = create('TextButton',
	{

		Position = UDim2.new(0,
			24,
			1,
			-58),

		Size = UDim2.new(0.5,
			-30,
			0,
			36),

		BackgroundColor3 = theme.Raised,

		Text = cancelText or 'Cancel',

		TextColor3 = theme.Text,

		Font = Enum.Font.GothamMedium,

		TextSize = 12,

		ZIndex = 83,

		Parent = card

	}
)
	corner(cancel,
	8)
	local accept = create('TextButton',
	{

		Position = UDim2.new(0.5,
			6,
			1,
			-58),

		Size = UDim2.new(0.5,
			-30,
			0,
			36),

		BackgroundColor3 = theme.Accent,

		Text = acceptText or 'Confirm',

		TextColor3 = theme.Text,

		Font = Enum.Font.GothamBold,

		TextSize = 12,

		ZIndex = 83,

		Parent = card

	}
)
	corner(accept,
	8)
	bind(cancel.MouseButton1Click,
	function() finish(false) end)
	bind(accept.MouseButton1Click,
	function() finish(true) end)
	return result
end

local tooltip = create('Frame',
	{

		Name = 'Tooltip',

		Size = UDim2.fromOffset(220,
			48),

		BackgroundColor3 = theme.Raised,

		BorderSizePixel = 0,

		Visible = false,

		ZIndex = 70,

		Parent = screen
	}
)
corner(tooltip,
	7)
stroke(tooltip,
	theme.Accent,
	0.55)
local tooltipText = create('TextLabel',
	{

		Position = UDim2.fromOffset(10,
			7),

		Size = UDim2.new(1,
			-20,
			1,
			-14),

		BackgroundTransparency = 1,

		Text = '',

		TextColor3 = theme.Text,

		TextWrapped = true,

		Font = Enum.Font.Gotham,

		TextSize = 10,

		TextXAlignment = Enum.TextXAlignment.Left,

		TextYAlignment = Enum.TextYAlignment.Top,

		ZIndex = 71,

		Parent = tooltip
	}
)

function interface:ShowTooltip(textValue)
	if textValue == nil or textValue == '' then return end
	tooltipText.Text = tostring(textValue)
	local bounds = TextService:GetTextSize(tooltipText.Text,
	10,
	Enum.Font.Gotham,
	Vector2.new(200,
		1000))
	tooltip.Size = UDim2.fromOffset(220,
	math.max(36,
		bounds.Y + 16))
	tooltip.Visible = true
end

function interface:HideTooltip()
	tooltip.Visible = false
end

bind(UserInputService.InputChanged,
	function(input)
	if tooltip.Visible and input.UserInputType == Enum.UserInputType.MouseMovement then
		tooltip.Position = UDim2.fromOffset(input.Position.X + 14,
		input.Position.Y + 18)
	end
	end)

local searchBox = create('TextBox',
	{

		Name = 'Search',

		AnchorPoint = Vector2.new(1,
			0),

		Position = UDim2.new(1,
			-28,
			0,
			20),

		Size = UDim2.fromOffset(220,
			36),

		BackgroundColor3 = theme.Surface,

		PlaceholderText = 'Search modules  /',

		PlaceholderColor3 = theme.Muted,

		Text = '',

		TextColor3 = theme.Text,

		ClearTextOnFocus = false,

		Font = Enum.Font.Gotham,

		TextSize = 11,

		BorderSizePixel = 0,

		Parent = content
	}
)
corner(searchBox,
	8)
stroke(searchBox,
	theme.Raised,
	0.25)

local searchResults = create('ScrollingFrame',
	{

		Name = 'SearchResults',

		Position = UDim2.fromOffset(24,
			82),

		Size = UDim2.new(1,
			-48,
			1,
			-104),

		BackgroundTransparency = 1,

		BorderSizePixel = 0,

		ScrollBarThickness = 3,

		ScrollBarImageColor3 = theme.Accent,

		AutomaticCanvasSize = Enum.AutomaticSize.Y,

		CanvasSize = UDim2.new(),

		Visible = false,

		Parent = content
	}
)
create('UIListLayout',
	{

		Padding = UDim.new(0,
			7),

		SortOrder = Enum.SortOrder.LayoutOrder,

		Parent = searchResults
	}
)

local function normalized(value)
	return tostring(value or ''):lower():gsub('[^%w%s]',
	'')
end

local function clearSearchResults()
	for _,
child in ipairs(searchResults:GetChildren()) do
		if not child:IsA('UIListLayout') then child:Destroy() end
	end
end

function interface:RebuildSearchIndex()
	table.clear(self.SearchIndex)
	for name,
module in pairs(aether.Modules) do
		table.insert(self.SearchIndex,
	{

			Name = name,

			Category = module.Category,

			Tooltip = module.Tooltip,

			Module = module,

			Terms = normalized(name..' '..module.Category..' '..module.Tooltip)

	}
)
	end
	table.sort(self.SearchIndex,
	function(a,
		b) return a.Name:lower() < b.Name:lower() end)
end

function interface:Search(query)
	query = normalized(query)
	clearSearchResults()
	if query == '' then
		searchResults.Visible = false
		pages.Visible = true
		return
	end
	self:RebuildSearchIndex()
	pages.Visible = false
	searchResults.Visible = true
	heading.Text = 'Search'
	subheading.Text = 'Results for “'..query..'”'
	local found = 0
	for _,
entry in ipairs(self.SearchIndex) do
		if entry.Terms:find(query,
	1,
	true) then
			found += 1
			local result = create('TextButton',
	{

				Size = UDim2.new(1,
			-5,
			0,
			54),

				BackgroundColor3 = theme.Surface,

				Text = '',

				AutoButtonColor = false,

				BorderSizePixel = 0,

				Parent = searchResults

	}
)
			corner(result,
	9)
			create('TextLabel',
	{

				Position = UDim2.fromOffset(14,
			6),

				Size = UDim2.new(1,
			-100,
			0,
			22),

				BackgroundTransparency = 1,

				Text = entry.Name,

				TextColor3 = theme.Text,

				Font = Enum.Font.GothamMedium,

				TextSize = 12,

				TextXAlignment = Enum.TextXAlignment.Left,

				Parent = result

	}
)
			create('TextLabel',
	{

				Position = UDim2.fromOffset(14,
			29),

				Size = UDim2.new(1,
			-100,
			0,
			16),

				BackgroundTransparency = 1,

				Text = entry.Category..'  ·  '..entry.Tooltip,

				TextColor3 = theme.Muted,

				Font = Enum.Font.Gotham,

				TextSize = 10,

				TextXAlignment = Enum.TextXAlignment.Left,

				TextTruncate = Enum.TextTruncate.AtEnd,

				Parent = result

	}
)
			local state = create('TextLabel',
	{

				AnchorPoint = Vector2.new(1,
			0.5),

				Position = UDim2.new(1,
			-14,
			0.5,
			0),

				Size = UDim2.fromOffset(50,
			22),

				BackgroundTransparency = 1,

				Text = entry.Module.Enabled and 'ON' or 'OFF',

				TextColor3 = entry.Module.Enabled and theme.Accent2 or theme.Muted,

				Font = Enum.Font.GothamBold,

				TextSize = 10,

				Parent = result

	}
)
			bind(result.MouseButton1Click,
	function()
				entry.Module:Toggle()
				state.Text = entry.Module.Enabled and 'ON' or 'OFF'
				state.TextColor3 = entry.Module.Enabled and theme.Accent2 or theme.Muted
			end)
		end
	end
	if found == 0 then
		create('TextLabel',
	{

			Size = UDim2.new(1,
			0,
			0,
			80),

			BackgroundTransparency = 1,

			Text = 'No modules matched your search.',

			TextColor3 = theme.Muted,

			Font = Enum.Font.Gotham,

			TextSize = 12,

			Parent = searchResults

	}
)
	end
end

bind(searchBox:GetPropertyChangedSignal('Text'),
	function()
	interface:Search(searchBox.Text)
	end)

local palette = create('Frame',
	{

		Name = 'CommandPalette',

		AnchorPoint = Vector2.new(0.5,
			0),

		Position = UDim2.new(0.5,
			0,
			0,
			80),

		Size = UDim2.fromOffset(540,
			390),

		BackgroundColor3 = theme.Background,

		BorderSizePixel = 0,

		Visible = false,

		ZIndex = 90,

		Parent = screen
	}
)
corner(palette,
	14)
stroke(palette,
	theme.Accent,
	0.35)
local paletteInput = create('TextBox',
	{

		Position = UDim2.fromOffset(16,
			14),

		Size = UDim2.new(1,
			-32,
			0,
			42),

		BackgroundColor3 = theme.Surface,

		PlaceholderText = 'Type a command…',

		PlaceholderColor3 = theme.Muted,

		Text = '',

		TextColor3 = theme.Text,

		ClearTextOnFocus = false,

		Font = Enum.Font.GothamMedium,

		TextSize = 13,

		ZIndex = 91,

		Parent = palette
	}
)
corner(paletteInput,
	8)
local paletteList = create('ScrollingFrame',
	{

		Position = UDim2.fromOffset(16,
			68),

		Size = UDim2.new(1,
			-32,
			1,
			-84),

		BackgroundTransparency = 1,

		BorderSizePixel = 0,

		ScrollBarThickness = 2,

		AutomaticCanvasSize = Enum.AutomaticSize.Y,

		CanvasSize = UDim2.new(),

		ZIndex = 91,

		Parent = palette
	}
)
create('UIListLayout',
	{

		Padding = UDim.new(0,
			5),

		SortOrder = Enum.SortOrder.LayoutOrder,

		Parent = paletteList
	}
)

function interface:RegisterCommand(command)
	assert(type(command) == 'table',
	'command must be a table')
	assert(type(command.Name) == 'string',
	'command.Name must be a string')
	command.Description = command.Description or ''
	command.Keywords = command.Keywords or ''
	command.Action = command.Action or function() end
	self.Commands[command.Name] = command
	return command
end

function interface:RenderCommands(filter)
	for _,
child in ipairs(paletteList:GetChildren()) do
		if not child:IsA('UIListLayout') then child:Destroy() end
	end
	filter = normalized(filter)
	local commands = {
}

	for _,
command in pairs(self.Commands) do
		local terms = normalized(command.Name..' '..command.Description..' '..command.Keywords)
		if filter == '' or terms:find(filter,
	1,
	true) then table.insert(commands,
	command) end
	end
	table.sort(commands,
	function(a,
		b) return a.Name < b.Name end)
	for _,
command in ipairs(commands) do
		local button = create('TextButton',
	{

			Size = UDim2.new(1,
			0,
			0,
			48),

			BackgroundColor3 = theme.Surface,

			Text = '',

			AutoButtonColor = false,

			ZIndex = 92,

			Parent = paletteList

	}
)
		corner(button,
	7)
		create('TextLabel',
	{

			Position = UDim2.fromOffset(12,
			4),

			Size = UDim2.new(1,
			-24,
			0,
			20),

			BackgroundTransparency = 1,

			Text = command.Name,

			TextColor3 = theme.Text,

			TextXAlignment = Enum.TextXAlignment.Left,

			Font = Enum.Font.GothamMedium,

			TextSize = 11,

			ZIndex = 93,

			Parent = button

	}
)
		create('TextLabel',
	{

			Position = UDim2.fromOffset(12,
			24),

			Size = UDim2.new(1,
			-24,
			0,
			16),

			BackgroundTransparency = 1,

			Text = command.Description,

			TextColor3 = theme.Muted,

			TextXAlignment = Enum.TextXAlignment.Left,

			Font = Enum.Font.Gotham,

			TextSize = 9,

			ZIndex = 93,

			Parent = button

	}
)
		bind(button.MouseButton1Click,
	function()
			palette.Visible = false
			dimmer.Visible = false
			safeCall(command.Action)
		end)
	end
end

function interface:OpenCommandPalette()
	dimmer.Visible = true
	palette.Visible = true
	paletteInput.Text = ''
	self:RenderCommands('')
	paletteInput:CaptureFocus()
end

function interface:CloseCommandPalette()
	palette.Visible = false
	dimmer.Visible = false
	paletteInput:ReleaseFocus()
end

bind(paletteInput:GetPropertyChangedSignal('Text'),
	function()
	interface:RenderCommands(paletteInput.Text)
	end)

local themePresets = {

	Aether = {
		Background = Color3.fromRGB(10,
			12,
			18),
		Surface = Color3.fromRGB(18,
			21,
			30),
		Raised = Color3.fromRGB(27,
			31,
			43),
		Text = Color3.fromRGB(239,
			242,
			250),
		Muted = Color3.fromRGB(142,
			150,
			170),
		Accent = Color3.fromRGB(119,
			92,
			255),
		Accent2 = Color3.fromRGB(64,
			204,
			255),
		Danger = Color3.fromRGB(255,
			91,
			118)
	}
	,

	Midnight = {
		Background = Color3.fromRGB(5,
			9,
			20),
		Surface = Color3.fromRGB(10,
			18,
			36),
		Raised = Color3.fromRGB(19,
			31,
			57),
		Text = Color3.fromRGB(231,
			239,
			255),
		Muted = Color3.fromRGB(124,
			143,
			177),
		Accent = Color3.fromRGB(67,
			111,
			255),
		Accent2 = Color3.fromRGB(69,
			221,
			255),
		Danger = Color3.fromRGB(255,
			84,
			112)
	}
	,

	Ember = {
		Background = Color3.fromRGB(19,
			10,
			10),
		Surface = Color3.fromRGB(31,
			17,
			15),
		Raised = Color3.fromRGB(49,
			27,
			22),
		Text = Color3.fromRGB(255,
			241,
			231),
		Muted = Color3.fromRGB(181,
			145,
			126),
		Accent = Color3.fromRGB(255,
			100,
			62),
		Accent2 = Color3.fromRGB(255,
			187,
			89),
		Danger = Color3.fromRGB(255,
			66,
			91)
	}
	,

	Forest = {
		Background = Color3.fromRGB(8,
			16,
			13),
		Surface = Color3.fromRGB(14,
			28,
			22),
		Raised = Color3.fromRGB(23,
			43,
			34),
		Text = Color3.fromRGB(233,
			250,
			241),
		Muted = Color3.fromRGB(128,
			165,
			146),
		Accent = Color3.fromRGB(52,
			193,
			118),
		Accent2 = Color3.fromRGB(80,
			222,
			193),
		Danger = Color3.fromRGB(255,
			91,
			105)
	}
	,

	Rose = {
		Background = Color3.fromRGB(19,
			10,
			17),
		Surface = Color3.fromRGB(32,
			18,
			29),
		Raised = Color3.fromRGB(49,
			27,
			44),
		Text = Color3.fromRGB(255,
			238,
			250),
		Muted = Color3.fromRGB(183,
			137,
			169),
		Accent = Color3.fromRGB(234,
			78,
			173),
		Accent2 = Color3.fromRGB(255,
			135,
			205),
		Danger = Color3.fromRGB(255,
			77,
			103)
	}
	,

	Monochrome = {
		Background = Color3.fromRGB(12,
			12,
			12),
		Surface = Color3.fromRGB(22,
			22,
			22),
		Raised = Color3.fromRGB(36,
			36,
			36),
		Text = Color3.fromRGB(245,
			245,
			245),
		Muted = Color3.fromRGB(155,
			155,
			155),
		Accent = Color3.fromRGB(218,
			218,
			218),
		Accent2 = Color3.fromRGB(255,
			255,
			255),
		Danger = Color3.fromRGB(255,
			89,
			89)
	}

}

interface.Themes = themePresets

function interface:ApplyTheme(name)
	local preset = self.Themes[name]
	if not preset then return false end
	for key,
value in pairs(preset) do theme[key] = value end
	root.BackgroundColor3 = theme.Background
	sidebar.BackgroundColor3 = theme.Surface
	searchBox.BackgroundColor3 = theme.Surface
	palette.BackgroundColor3 = theme.Background
	tooltip.BackgroundColor3 = theme.Raised
	brand.TextColor3 = theme.Text
	brandAccent.TextColor3 = theme.Accent2
	heading.TextColor3 = theme.Text
	subheading.TextColor3 = theme.Muted
	footer.TextColor3 = theme.Muted
	for _,
category in pairs(aether.Categories) do
		category.Button.BackgroundColor3 = theme.Raised
		category.Button.TextColor3 = category == selectedCategory and theme.Text or theme.Muted
		for _,
module in pairs(category.Modules) do
			module.Object.BackgroundColor3 = module.Enabled and theme.Accent or theme.Surface
			module.Status.TextColor3 = module.Enabled and theme.Text or theme.Muted
		end
	end
	self.ThemeChanged:Fire(name,
	preset)
	return true
end

local watermark = create('Frame',
	{

		Name = 'Watermark',

		Position = UDim2.fromOffset(18,
			18),

		Size = UDim2.fromOffset(190,
			34),

		BackgroundColor3 = theme.Surface,

		BackgroundTransparency = 0.12,

		BorderSizePixel = 0,

		Parent = screen
	}
)
corner(watermark,
	8)
stroke(watermark,
	theme.Accent,
	0.35)
local watermarkText = create('TextLabel',
	{

		Size = UDim2.fromScale(1,
			1),

		BackgroundTransparency = 1,

		Text = 'AETHER V3  ·  0 FPS',

		TextColor3 = theme.Text,

		Font = Enum.Font.GothamBold,

		TextSize = 10,

		Parent = watermark
	}
)

local arrayList = create('Frame',
	{

		Name = 'ArrayList',

		AnchorPoint = Vector2.new(1,
			0),

		Position = UDim2.new(1,
			-18,
			0,
			18),

		Size = UDim2.fromOffset(230,
			500),

		BackgroundTransparency = 1,

		Parent = screen
	}
)
create('UIListLayout',
	{

		HorizontalAlignment = Enum.HorizontalAlignment.Right,

		Padding = UDim.new(0,
			3),

		SortOrder = Enum.SortOrder.LayoutOrder,

		Parent = arrayList
	}
)

function interface:RefreshArrayList()
	for _,
child in ipairs(arrayList:GetChildren()) do
		if not child:IsA('UIListLayout') then child:Destroy() end
	end
	local enabled = {
}

	for _,
module in pairs(aether.Modules) do
		if module.Enabled then table.insert(enabled,
	module) end
	end
	table.sort(enabled,
	function(a,
		b) return #a.Name > #b.Name end)
	for index,
module in ipairs(enabled) do
		local width = TextService:GetTextSize(module.Name,
	11,
	Enum.Font.GothamMedium,
	Vector2.new(500,
		20)).X + 22
		local item = create('TextLabel',
	{

			LayoutOrder = index,

			Size = UDim2.fromOffset(width,
			24),

			BackgroundColor3 = theme.Surface,

			BackgroundTransparency = 0.16,

			Text = module.Name,

			TextColor3 = theme.Text,

			Font = Enum.Font.GothamMedium,

			TextSize = 11,

			Parent = arrayList

	}
)
		corner(item,
	6)
		create('Frame',
	{

			AnchorPoint = Vector2.new(1,
			0),

			Position = UDim2.new(1,
			0,
			0,
			0),

			Size = UDim2.fromOffset(3,
			24),

			BackgroundColor3 = index % 2 == 0 and theme.Accent2 or theme.Accent,

			BorderSizePixel = 0,

			Parent = item

	}
)
	end
end

local frames,
lastSecond = 0,
os.clock()
bind(RunService.RenderStepped,
	function()
	frames += 1
	local now = os.clock()
	if now - lastSecond >= 1 then
		watermarkText.Text = 'AETHER V3  ·  '..frames..' FPS  ·  '..math.floor(player:GetNetworkPing() * 1000)..' MS'
		frames = 0
		lastSecond = now
		interface:RefreshArrayList()
	end
	end)

local resizeHandle = create('TextButton',
	{

		Name = 'Resize',

		AnchorPoint = Vector2.new(1,
			1),

		Position = UDim2.fromScale(1,
			1),

		Size = UDim2.fromOffset(24,
			24),

		BackgroundTransparency = 1,

		Text = '◢',

		TextColor3 = theme.Muted,

		Font = Enum.Font.GothamBold,

		TextSize = 12,

		Parent = root
	}
)
local resizing,
resizeStart,
startSize = false,
nil,
nil
bind(resizeHandle.InputBegan,
	function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		resizing = true
		resizeStart = input.Position
		startSize = root.AbsoluteSize
	end
	end)
bind(UserInputService.InputChanged,
	function(input)
	if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - resizeStart
		root.Size = UDim2.fromOffset(math.clamp(startSize.X + delta.X,
			620,
			1100),
		math.clamp(startSize.Y + delta.Y,
			400,
			720))
	end
	end)
bind(UserInputService.InputEnded,
	function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
	end)

local mobileButton = create('TextButton',
	{

		Name = 'MobileToggle',

		AnchorPoint = Vector2.new(1,
			0.5),

		Position = UDim2.new(1,
			-16,
			0.5,
			0),

		Size = UDim2.fromOffset(48,
			48),

		BackgroundColor3 = theme.Accent,

		Text = 'A3',

		TextColor3 = theme.Text,

		Font = Enum.Font.GothamBold,

		TextSize = 13,

		Visible = UserInputService.TouchEnabled,

		Parent = screen
	}
)
corner(mobileButton,
	24)
stroke(mobileButton,
	theme.Accent2,
	0.2)
bind(mobileButton.MouseButton1Click,
	function() interface:Toggle() end)

local function profileFile(name)
	name = tostring(name or 'default'):gsub('[^%w%-_]',
	'')
	if name == '' then name = 'default' end
	return configPath..name..'.json',
name
end

function interface:ListProfiles()
	local result = {
	'default'
}

	if listfiles and isfolder and isfolder(configPath:sub(1,
		-2)) then
		for _,
path in ipairs(listfiles(configPath:sub(1,
			-2))) do
			local name = path:match('([^/\\]+)%.json$')
			if name and not table.find(result,
	name) then table.insert(result,
	name) end
		end
	end
	table.sort(result)
	self.Profiles = result
	return result
end

function interface:SwitchProfile(name)
	local _,
cleanName = profileFile(name)
	pcall(function() aether:Save() end)
	for _,
module in pairs(aether.Modules) do
		if module.Enabled then module:Toggle(false) end
	end
	aether.Profile = cleanName
	aether:Load()
	self.ProfileChanged:Fire(cleanName)
	aether:CreateNotification('Profile changed',
	'Now using '..cleanName,
	3)
end

function interface:CreateProfile(name)
	local _,
cleanName = profileFile(name)
	aether.Profile = cleanName
	aether:Save()
	self:ListProfiles()
	self.ProfileChanged:Fire(cleanName)
	return cleanName
end

function interface:DeleteProfile(name)
	local path,
cleanName = profileFile(name)
	if cleanName == 'default' then return false end
	if delfile and isfile and isfile(path) then delfile(path) end
	if aether.Profile == cleanName then self:SwitchProfile('default') end
	self:ListProfiles()
	return true
end

function interface:ExportProfile()
	local path = profileFile(aether.Profile)
	if isfile and isfile(path) then return readfile(path) end
	aether:Save()
	return isfile and isfile(path) and readfile(path) or '{}'
end

function interface:ImportProfile(name,
	payload)
	local path,
cleanName = profileFile(name)
	local ok = pcall(HttpService.JSONDecode,
	HttpService,
	payload)
	if not ok then return false,
'Invalid JSON' end
	if writefile then writefile(path,
	payload) end
	self:SwitchProfile(cleanName)
	return true
end

interface:RegisterCommand({
		Name = 'Toggle interface',
		Description = 'Show or hide AetherV3',
		Keywords = 'gui menu',
		Action = function() interface:Toggle() end
	}
)
interface:RegisterCommand({
		Name = 'Save profile',
		Description = 'Save all current module settings',
		Keywords = 'config',
		Action = function() aether:Save();
		aether:CreateNotification('Profile saved',
			aether.Profile,
			2) end
	}
)
interface:RegisterCommand({
		Name = 'Reload profile',
		Description = 'Reload settings from disk',
		Keywords = 'config load',
		Action = function() aether:Load() end
	}
)
interface:RegisterCommand({
		Name = 'Disable all modules',
		Description = 'Turn every enabled module off',
		Keywords = 'panic reset',
		Action = function() for _,
		module in pairs(aether.Modules) do if module.Enabled then module:Toggle(false) end end end
	}
)
interface:RegisterCommand({
		Name = 'Theme: Aether',
		Description = 'Use the default violet theme',
		Keywords = 'appearance',
		Action = function() interface:ApplyTheme('Aether') end
	}
)
interface:RegisterCommand({
		Name = 'Theme: Midnight',
		Description = 'Use a deep blue theme',
		Keywords = 'appearance',
		Action = function() interface:ApplyTheme('Midnight') end
	}
)
interface:RegisterCommand({
		Name = 'Theme: Ember',
		Description = 'Use a warm orange theme',
		Keywords = 'appearance',
		Action = function() interface:ApplyTheme('Ember') end
	}
)
interface:RegisterCommand({
		Name = 'Theme: Forest',
		Description = 'Use a green theme',
		Keywords = 'appearance',
		Action = function() interface:ApplyTheme('Forest') end
	}
)
interface:RegisterCommand({
		Name = 'Theme: Rose',
		Description = 'Use a pink theme',
		Keywords = 'appearance',
		Action = function() interface:ApplyTheme('Rose') end
	}
)
interface:RegisterCommand({
		Name = 'Theme: Monochrome',
		Description = 'Use a neutral grayscale theme',
		Keywords = 'appearance',
		Action = function() interface:ApplyTheme('Monochrome') end
	}
)
interface:RegisterCommand({
		Name = 'Scale: Small',
		Description = 'Set interface scale to 80%',
		Keywords = 'size',
		Action = function() interface:SetScale(0.8) end
	}
)
interface:RegisterCommand({
		Name = 'Scale: Normal',
		Description = 'Set interface scale to 100%',
		Keywords = 'size',
		Action = function() interface:SetScale(1) end
	}
)
interface:RegisterCommand({
		Name = 'Scale: Large',
		Description = 'Set interface scale to 120%',
		Keywords = 'size',
		Action = function() interface:SetScale(1.2) end
	}
)

bind(UserInputService.InputBegan,
	function(input,
		processed)
	if processed and not palette.Visible then return end
	if input.KeyCode == Enum.KeyCode.Slash and not UserInputService:GetFocusedTextBox() then
		searchBox:CaptureFocus()
	elseif input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		interface:OpenCommandPalette()
	elseif input.KeyCode == Enum.KeyCode.Escape and palette.Visible then
		interface:CloseCommandPalette()
	end
	end)

aether.Components.Interface = interface
aether.Components.Search = searchBox
aether.Components.CommandPalette = palette
aether.Components.Watermark = watermark
aether.Components.ArrayList = arrayList
aether.Components.MobileButton = mobileButton
shared.Aether = aether
return aether

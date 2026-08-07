-- AetherV3 interface
-- Built as an independent, asset-free interface for the Aether module API.
local license = ... or {}
local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local HttpService = game:GetService('HttpService')
local RunService = game:GetService('RunService')
local TextService = game:GetService('TextService')
local player = Players.LocalPlayer

local function create(class, properties)
	local object = Instance.new(class)
	for property, value in pairs(properties or {}) do
		if property ~= 'Parent' then object[property] = value end
	end
	object.Parent = properties and properties.Parent
	return object
end

local theme = {
	Background = Color3.fromRGB(10, 12, 18),
	Surface = Color3.fromRGB(18, 21, 30),
	Raised = Color3.fromRGB(27, 31, 43),
	Text = Color3.fromRGB(239, 242, 250),
	Muted = Color3.fromRGB(142, 150, 170),
	Accent = Color3.fromRGB(119, 92, 255),
	Accent2 = Color3.fromRGB(64, 204, 255),
	Danger = Color3.fromRGB(255, 91, 118)
}

local function corner(parent, radius)
	return create('UICorner', {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
end

local function stroke(parent, color, transparency)
	return create('UIStroke', {Color = color or theme.Raised, Transparency = transparency or 0, Thickness = 1, Parent = parent})
end

local function tween(object, goal, duration)
	local animation = TweenService:Create(object, TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal)
	animation:Play()
	return animation
end

local parent = (gethui and gethui()) or game:GetService('CoreGui')
local screen = create('ScreenGui', {
	Name = 'AetherV3', ResetOnSpawn = false, IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = parent
})
if syn and syn.protect_gui then pcall(syn.protect_gui, screen) end

local vape = {
	gui = screen,
	Categories = {}, Modules = {}, Windows = {}, Components = {}, Libraries = {},
	Connections = {}, Keybind = {'RightShift'}, Profile = 'default', Place = game.PlaceId,
	Loaded = false, Unloaded = false, ToggleNotifications = true, guiscale = 1
}

function vape:Clean(item)
	if item then table.insert(self.Connections, item) end
	return item
end

function vape:Remove(item)
	local position = table.find(self.Connections, item)
	if position then table.remove(self.Connections, position) end
	if typeof(item) == 'RBXScriptConnection' then item:Disconnect()
	elseif typeof(item) == 'Instance' then item:Destroy()
	elseif type(item) == 'function' then item() end
end

function vape:ThreadFix(callback)
	return function(...)
		local arguments = table.pack(...)
		task.spawn(function() callback(table.unpack(arguments, 1, arguments.n)) end)
	end
end

local root = create('Frame', {
	Name = 'Aether', AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(900, 570), BackgroundColor3 = theme.Background,
	BorderSizePixel = 0, Parent = screen
})
corner(root, 16)
stroke(root, Color3.fromRGB(52, 58, 76), 0.2)
create('UISizeConstraint', {MinSize = Vector2.new(620, 400), MaxSize = Vector2.new(1100, 720), Parent = root})

local sidebar = create('Frame', {Size = UDim2.new(0, 205, 1, 0), BackgroundColor3 = theme.Surface, BorderSizePixel = 0, Parent = root})
corner(sidebar, 16)
create('Frame', {Position = UDim2.new(1, -16, 0, 0), Size = UDim2.new(0, 16, 1, 0), BackgroundColor3 = theme.Surface, BorderSizePixel = 0, Parent = sidebar})
create('Frame', {Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = theme.Raised, BorderSizePixel = 0, Parent = sidebar})
local brand = create('TextLabel', {Position = UDim2.fromOffset(24, 20), Size = UDim2.new(1, -48, 0, 34), BackgroundTransparency = 1, Text = 'AETHER', Font = Enum.Font.GothamBold, TextSize = 24, TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = sidebar})
local brandAccent = create('TextLabel', {Position = UDim2.fromOffset(118, 22), Size = UDim2.fromOffset(46, 28), BackgroundTransparency = 1, Text = 'V3', Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = theme.Accent2, TextXAlignment = Enum.TextXAlignment.Left, Parent = sidebar})
local nav = create('ScrollingFrame', {Position = UDim2.fromOffset(12, 76), Size = UDim2.new(1, -24, 1, -140), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = sidebar})
create('UIListLayout', {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = nav})
local footer = create('TextLabel', {Position = UDim2.new(0, 24, 1, -44), Size = UDim2.new(1, -48, 0, 24), BackgroundTransparency = 1, Text = 'RIGHT SHIFT  ·  TOGGLE', Font = Enum.Font.GothamMedium, TextSize = 10, TextColor3 = theme.Muted, TextXAlignment = Enum.TextXAlignment.Left, Parent = sidebar})

local content = create('Frame', {Position = UDim2.fromOffset(205, 0), Size = UDim2.new(1, -205, 1, 0), BackgroundTransparency = 1, Parent = root})
local heading = create('TextLabel', {Position = UDim2.fromOffset(28, 20), Size = UDim2.new(1, -56, 0, 30), BackgroundTransparency = 1, Text = 'Combat', Font = Enum.Font.GothamBold, TextSize = 22, TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = content})
local subheading = create('TextLabel', {Position = UDim2.fromOffset(28, 49), Size = UDim2.new(1, -56, 0, 18), BackgroundTransparency = 1, Text = 'Configure your modules', Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = theme.Muted, TextXAlignment = Enum.TextXAlignment.Left, Parent = content})
local pages = create('Frame', {Position = UDim2.fromOffset(24, 82), Size = UDim2.new(1, -48, 1, -104), BackgroundTransparency = 1, Parent = content})

local dragging, dragStart, startPosition
vape:Clean(root.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 and input.Position.Y <= root.AbsolutePosition.Y + 72 then
		dragging, dragStart, startPosition = true, input.Position, root.Position
	end
end))
vape:Clean(UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		root.Position = startPosition + UDim2.fromOffset(delta.X, delta.Y)
	end
end))
vape:Clean(UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end))

local selectedCategory
local function selectCategory(category)
	if selectedCategory == category then return end
	if selectedCategory then
		selectedCategory.Page.Visible = false
		tween(selectedCategory.Button, {BackgroundTransparency = 1})
		selectedCategory.Button.TextColor3 = theme.Muted
	end
	selectedCategory = category
	category.Page.Visible = true
	tween(category.Button, {BackgroundTransparency = 0})
	category.Button.TextColor3 = theme.Text
	heading.Text = category.Name
	subheading.Text = category.Name == 'Profiles' and 'Manage interface preferences' or 'Configure '..category.Name:lower()..' modules'
end

local function makeRow(parent, height)
	local row = create('Frame', {Size = UDim2.new(1, 0, 0, height or 42), BackgroundColor3 = theme.Raised, BackgroundTransparency = 0.32, BorderSizePixel = 0, Parent = parent})
	corner(row, 7)
	return row
end

local optionMethods = {}
local function changeOption(option, value, skipCallback)
	if option.Type == 'TwoSlider' then option.ValueMin, option.ValueMax = value[1], value[2]
	elseif option.Type == 'ColorSlider' then option.Hue, option.Sat, option.Value, option.Opacity = value[1], value[2], value[3], value[4] or 1
	else option.Value = value; if option.Type == 'Toggle' then option.Enabled = value end end
	if option.Render then option:Render() end
	if not skipCallback and option.Function then
		if option.Type == 'ColorSlider' then task.spawn(option.Function, option.Hue, option.Sat, option.Value, option.Opacity)
		elseif option.Type == 'TwoSlider' then task.spawn(option.Function, option.ValueMin, option.ValueMax)
		else task.spawn(option.Function, option.Value) end
	end
end

function optionMethods:SetValue(value) changeOption(self, value) end
function optionMethods:Toggle(value) changeOption(self, value == nil and not self.Enabled or value) end
function optionMethods:SetVisible(value) self.Object.Visible = value end
function optionMethods:Change(value) changeOption(self, value) end
function optionMethods:Increment(value) changeOption(self, (self.Value or 0) + value) end

local function addOption(module, data, kind)
	data = data or {}
	local option = setmetatable({Name = data.Name or kind, Type = kind, Function = data.Function, Object = nil}, {__index = optionMethods})
	local row = makeRow(module.Options, kind == 'TextList' and 70 or 40)
	option.Object = row
	local label = create('TextLabel', {Position = UDim2.fromOffset(12, 0), Size = UDim2.new(0.48, -12, 1, 0), BackgroundTransparency = 1, Text = option.Name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = row})

	if kind == 'Toggle' then
		option.Enabled = data.Default == true; option.Value = option.Enabled
		local track = create('TextButton', {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(36, 20), BackgroundColor3 = theme.Surface, Text = '', AutoButtonColor = false, BorderSizePixel = 0, Parent = row})
		corner(track, 10)
		local knob = create('Frame', {Position = UDim2.fromOffset(3, 3), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = theme.Muted, BorderSizePixel = 0, Parent = track}); corner(knob, 7)
		function option:Render() tween(track, {BackgroundColor3 = self.Enabled and theme.Accent or theme.Surface}); tween(knob, {Position = UDim2.fromOffset(self.Enabled and 19 or 3, 3), BackgroundColor3 = self.Enabled and theme.Text or theme.Muted}) end
		track.MouseButton1Click:Connect(function() option:Toggle() end)
	elseif kind == 'Slider' or kind == 'TwoSlider' then
		option.Min, option.Max = data.Min or 0, data.Max or 100
		option.Value = data.Default or data.DefaultValue or option.Min; option.ValueMin = data.DefaultMin or data.DefaultValueMin or data.Min or option.Min; option.ValueMax = data.DefaultMax or data.DefaultValueMax or data.Max or option.Max
		local valueLabel = create('TextLabel', {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(118, 24), BackgroundColor3 = theme.Surface, TextColor3 = theme.Accent2, Font = Enum.Font.GothamMedium, TextSize = 11, Parent = row}); corner(valueLabel, 6)
		function option:Render() valueLabel.Text = kind == 'TwoSlider' and (tostring(self.ValueMin)..'  —  '..tostring(self.ValueMax)) or tostring(self.Value) end
		local active = false
		valueLabel.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then active = true end end)
		UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then active = false end end)
		UserInputService.InputChanged:Connect(function(input)
			if active and input.UserInputType == Enum.UserInputType.MouseMovement then
				local alpha = math.clamp((input.Position.X - valueLabel.AbsolutePosition.X) / valueLabel.AbsoluteSize.X, 0, 1)
				local value = math.floor((option.Min + (option.Max - option.Min) * alpha) * 100) / 100
				if kind == 'TwoSlider' then changeOption(option, {math.min(value, option.ValueMax), option.ValueMax}) else changeOption(option, value) end
			end
		end)
	elseif kind == 'Dropdown' then
		option.List = data.List or {}; option.Value = data.Default or data.DefaultValue or option.List[1] or ''
		local button = create('TextButton', {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(150, 26), BackgroundColor3 = theme.Surface, TextColor3 = theme.Text, Font = Enum.Font.Gotham, TextSize = 11, AutoButtonColor = false, Parent = row}); corner(button, 6)
		function option:Render() button.Text = tostring(self.Value)..'  ▾' end
		button.MouseButton1Click:Connect(function()
			local index = table.find(option.List, option.Value) or 0
			changeOption(option, option.List[index % math.max(#option.List, 1) + 1] or '')
		end)
	elseif kind == 'TextBox' then
		option.Value = data.Default or data.DefaultValue or ''
		local box = create('TextBox', {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(170, 26), BackgroundColor3 = theme.Surface, PlaceholderText = data.Placeholder or 'Enter value', Text = option.Value, TextColor3 = theme.Text, PlaceholderColor3 = theme.Muted, ClearTextOnFocus = false, Font = Enum.Font.Gotham, TextSize = 11, Parent = row}); corner(box, 6)
		function option:Render() box.Text = tostring(self.Value) end
		box.FocusLost:Connect(function() changeOption(option, box.Text) end)
	elseif kind == 'ColorSlider' then
		option.Hue, option.Sat, option.Value, option.Opacity = data.DefaultHue or data.Hue or 0.72, data.DefaultSat or data.Sat or 1, data.DefaultValue or data.Value or 1, data.DefaultOpacity or data.Opacity or 1
		local swatch = create('TextButton', {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), Size = UDim2.fromOffset(62, 24), Text = '', AutoButtonColor = false, BorderSizePixel = 0, Parent = row}); corner(swatch, 6)
		function option:Render() swatch.BackgroundColor3 = Color3.fromHSV(self.Hue, self.Sat, self.Value) end
		swatch.MouseButton1Click:Connect(function() changeOption(option, {(option.Hue + 0.08) % 1, option.Sat, option.Value, option.Opacity}) end)
	elseif kind == 'TextList' then
		option.List, option.ListEnabled = data.Default or {}, data.DefaultEnabled or {}
		local box = create('TextBox', {Position = UDim2.new(0.48, 0, 0, 8), Size = UDim2.new(0.52, -54, 0, 25), BackgroundColor3 = theme.Surface, PlaceholderText = 'Add item', Text = '', TextColor3 = theme.Text, PlaceholderColor3 = theme.Muted, Font = Enum.Font.Gotham, TextSize = 11, Parent = row}); corner(box, 6)
		local add = create('TextButton', {AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 8), Size = UDim2.fromOffset(34, 25), BackgroundColor3 = theme.Accent, Text = '+', TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 16, Parent = row}); corner(add, 6)
		local summary = create('TextLabel', {Position = UDim2.new(0.48, 0, 0, 38), Size = UDim2.new(0.52, -12, 0, 22), BackgroundTransparency = 1, TextColor3 = theme.Muted, Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, Parent = row})
		function option:Render() summary.Text = #self.List == 0 and 'No entries' or table.concat(self.List, ', ') end
		function option:Add(value) if value ~= '' and not table.find(self.List, value) then table.insert(self.List, value); table.insert(self.ListEnabled, value); self:Render(); if self.Function then task.spawn(self.Function, self.List) end end end
		function option:Remove(value) table.remove(self.List, table.find(self.List, value) or 0); table.remove(self.ListEnabled, table.find(self.ListEnabled, value) or 0); self:Render() end
		add.MouseButton1Click:Connect(function() option:Add(box.Text); box.Text = '' end)
	end
	option:Render()
	module.OptionsTable[option.Name] = option
	return option
end

local moduleMethods = {}
function moduleMethods:Clean(item) table.insert(self.Connections, item); return item end
function moduleMethods:SetVisible(value) self.Object.Visible = value end
function moduleMethods:Toggle(value)
	value = value == nil and not self.Enabled or value
	if self.Enabled == value then return end
	self.Enabled = value
	tween(self.Object, {BackgroundColor3 = value and theme.Accent or theme.Surface})
	self.Status.Text = value and 'ON' or 'OFF'
	self.Status.TextColor3 = value and theme.Text or theme.Muted
	if self.Function then task.spawn(self.Function, value) end
end
function moduleMethods:CreateToggle(data) return addOption(self, data, 'Toggle') end
function moduleMethods:CreateSlider(data) return addOption(self, data, 'Slider') end
function moduleMethods:CreateTwoSlider(data) return addOption(self, data, 'TwoSlider') end
function moduleMethods:CreateDropdown(data) return addOption(self, data, 'Dropdown') end
function moduleMethods:CreateColorSlider(data) return addOption(self, data, 'ColorSlider') end
function moduleMethods:CreateTextBox(data) return addOption(self, data, 'TextBox') end
function moduleMethods:CreateTextList(data) return addOption(self, data, 'TextList') end
function moduleMethods:CreateFont(data)
	data = data or {}
	data.List = {'Gotham', 'Arial', 'SourceSans', 'RobotoMono'}
	data.Default = data.Default or 'Gotham'
	local option = addOption(self, data, 'Dropdown')
	local render = option.Render
	function option:Render()
		local name = tostring(self.Value)
		self.Value = Font.fromEnum(Enum.Font[name] or Enum.Font.Gotham)
		render(self)
	end
	option.Value = Font.fromEnum(Enum.Font.Gotham)
	return option
end
function moduleMethods:CreateHotbarList(data)
	local option = addOption(self, {Name = (data and data.Name) or 'Hotbars'}, 'TextList')
	option.Hotbars = {{Name = 'Default', Hotbar = {}}}
	option.Selected = 1
	function option:AddHotbar(name)
		table.insert(self.Hotbars, {Name = name or ('Hotbar '..(#self.Hotbars + 1)), Hotbar = {}})
	end
	return option
end
function moduleMethods:CreateButton(data)
	local option = addOption(self, data, 'TextBox')
	option.Object:ClearAllChildren()
	local button = create('TextButton', {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = data.Name or 'Action', TextColor3 = theme.Accent2, Font = Enum.Font.GothamMedium, TextSize = 12, Parent = option.Object})
	button.MouseButton1Click:Connect(data.Function or function() end)
	return option
end
function moduleMethods:CreateTargets(data)
	local target = {Players = data and data.Players ~= false or true, NPCs = data and data.NPCs or false, Invisible = false, Walls = false}
	function target:Get(value) return self[value] end
	return target
end

local function createCategory(name, order)
	local category = {Name = name, Modules = {}}
	category.Button = create('TextButton', {LayoutOrder = order, Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = theme.Raised, BackgroundTransparency = 1, Text = '   '..name, TextColor3 = theme.Muted, TextXAlignment = Enum.TextXAlignment.Left, Font = Enum.Font.GothamMedium, TextSize = 12, AutoButtonColor = false, Parent = nav})
	corner(category.Button, 8)
	category.Page = create('ScrollingFrame', {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = theme.Accent, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, Parent = pages})
	create('UIListLayout', {Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder, Parent = category.Page})
	category.Button.MouseButton1Click:Connect(function() selectCategory(category) end)
	function category:CreateModule(data)
		data = data or {}
		local module = setmetatable({Name = data.Name or 'Module', Function = data.Function, Tooltip = data.Tooltip or '', Enabled = false, Bind = data.Bind or {}, Connections = {}, OptionsTable = {}, Category = self.Name}, {__index = moduleMethods})
		module.Button = module
		local card = create('Frame', {Size = UDim2.new(1, -5, 0, 54), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = theme.Surface, BorderSizePixel = 0, Parent = self.Page})
		corner(card, 10); stroke(card, theme.Raised, 0.25)
		module.Object = create('TextButton', {Size = UDim2.new(1, 0, 0, 54), BackgroundColor3 = theme.Surface, BackgroundTransparency = 0.3, Text = '', AutoButtonColor = false, BorderSizePixel = 0, Parent = card}); corner(module.Object, 10)
		create('TextLabel', {Position = UDim2.fromOffset(15, 7), Size = UDim2.new(1, -90, 0, 21), BackgroundTransparency = 1, Text = module.Name, Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = module.Object})
		create('TextLabel', {Position = UDim2.fromOffset(15, 28), Size = UDim2.new(1, -90, 0, 16), BackgroundTransparency = 1, Text = module.Tooltip, Font = Enum.Font.Gotham, TextSize = 10, TextColor3 = theme.Muted, TextTruncate = Enum.TextTruncate.AtEnd, TextXAlignment = Enum.TextXAlignment.Left, Parent = module.Object})
		module.Status = create('TextLabel', {AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -15, 0.5, 0), Size = UDim2.fromOffset(42, 22), BackgroundTransparency = 1, Text = 'OFF', Font = Enum.Font.GothamBold, TextSize = 10, TextColor3 = theme.Muted, Parent = module.Object})
		module.Options = create('Frame', {Position = UDim2.fromOffset(10, 55), Size = UDim2.new(1, -20, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = card})
		create('UIListLayout', {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = module.Options})
		create('UIPadding', {PaddingBottom = UDim.new(0, 10), Parent = module.Options})
		module.Object.MouseButton1Click:Connect(function() module:Toggle() end)
		self.Modules[module.Name] = module; vape.Modules[module.Name] = module
		return module
	end
	vape.Categories[name] = category
	return category
end

local categoryNames = {'Combat', 'Blatant', 'Legit', 'Render', 'Visuals', 'Utility', 'World', 'Inventory', 'Exploits', 'Minigames', 'Kits', 'Main', 'Friends', 'Targets'}
for index, name in ipairs(categoryNames) do createCategory(name, index) end
selectCategory(vape.Categories.Combat)

local notifications = create('Frame', {AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -20, 1, -20), Size = UDim2.fromOffset(320, 500), BackgroundTransparency = 1, Parent = screen})
create('UIListLayout', {VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 8), Parent = notifications})
function vape:CreateNotification(title, message, duration, kind)
	if not self.ToggleNotifications then return {Destroy = function() end} end
	local toast = create('Frame', {Size = UDim2.new(1, 0, 0, 70), BackgroundColor3 = theme.Surface, BackgroundTransparency = 0.04, BorderSizePixel = 0, Parent = notifications}); corner(toast, 10); stroke(toast, kind == 'alert' and theme.Danger or theme.Accent, 0.1)
	create('Frame', {Size = UDim2.fromOffset(4, 70), BackgroundColor3 = kind == 'alert' and theme.Danger or theme.Accent, BorderSizePixel = 0, Parent = toast})
	create('TextLabel', {Position = UDim2.fromOffset(16, 9), Size = UDim2.new(1, -28, 0, 20), BackgroundTransparency = 1, Text = title or 'AetherV3', Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left, Parent = toast})
	create('TextLabel', {Position = UDim2.fromOffset(16, 30), Size = UDim2.new(1, -28, 0, 31), BackgroundTransparency = 1, Text = tostring(message or ''), Font = Enum.Font.Gotham, TextSize = 11, TextWrapped = true, TextColor3 = theme.Muted, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = toast})
	toast.Position = UDim2.fromOffset(340, 0); tween(toast, {Position = UDim2.new()}, 0.25)
	task.delay(duration or 4, function() if toast.Parent then tween(toast, {Position = UDim2.fromOffset(340, 0), BackgroundTransparency = 1}, 0.25); task.wait(0.3); toast:Destroy() end end)
	return toast
end

function vape:CreateOverlay(data)
	data = data or {}
	local overlay = create('Frame', {Position = data.Position or UDim2.fromOffset(20, 100), Size = data.Size or UDim2.fromOffset(200, 80), BackgroundColor3 = theme.Surface, BackgroundTransparency = 0.15, BorderSizePixel = 0, Parent = screen}); corner(overlay, 9); stroke(overlay, theme.Raised)
	return overlay
end

local configPath = 'aetherv3/profiles/'
function vape:Save()
	if not writefile then return end
	if makefolder and not isfolder('aetherv3') then makefolder('aetherv3') end
	if makefolder and not isfolder(configPath:sub(1, -2)) then makefolder(configPath:sub(1, -2)) end
	local data = {Modules = {}, Keybind = self.Keybind}
	for name, module in pairs(self.Modules) do
		local saved = {Enabled = module.Enabled, Options = {}}
		for optionName, option in pairs(module.OptionsTable) do
			saved.Options[optionName] = option.Type == 'Toggle' and option.Enabled or option.Type == 'TwoSlider' and {option.ValueMin, option.ValueMax} or option.Type == 'ColorSlider' and {option.Hue, option.Sat, option.Value, option.Opacity} or option.Value
		end
		data.Modules[name] = saved
	end
	writefile(configPath..self.Profile..'.json', HttpService:JSONEncode(data))
end

function vape:Load()
	if not (isfile and isfile(configPath..self.Profile..'.json')) then return end
	local ok, data = pcall(HttpService.JSONDecode, HttpService, readfile(configPath..self.Profile..'.json'))
	if not ok or type(data) ~= 'table' then return end
	for name, saved in pairs(data.Modules or {}) do
		local module = self.Modules[name]
		if module then
			for optionName, value in pairs(saved.Options or {}) do if module.OptionsTable[optionName] then changeOption(module.OptionsTable[optionName], value, true) end end
			if saved.Enabled then module:Toggle(true) end
		end
	end
end

function vape:Init() self.Loaded = true; self:CreateNotification('AetherV3', 'Interface ready', 3) end
function vape:Uninject()
	if self.Unloaded then return end
	self.Unloaded = true
	pcall(function() self:Save() end)
	for _, module in pairs(self.Modules) do if module.Enabled then pcall(function() module:Toggle(false) end) end; for _, connection in ipairs(module.Connections) do pcall(function() self:Remove(connection) end) end end
	for _, connection in ipairs(self.Connections) do pcall(function() self:Remove(connection) end) end
	if screen then screen:Destroy() end
	shared.vape = nil
end

vape:Clean(UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then root.Visible = not root.Visible end
	for _, module in pairs(vape.Modules) do
		if module.Bind and table.find(module.Bind, input.KeyCode.Name) then module:Toggle() end
	end
end))

vape.VapeButton = root
vape.Windows = vape.Categories
vape.Components = {Theme = theme, Root = root, Sidebar = sidebar, Content = content}
shared.vape = vape
return vape

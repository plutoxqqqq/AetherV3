--!nocheck
-- Aether Standalone runtime
-- A clean-room module host and GUI. It intentionally does not load or emulate
-- the legacy GUI/framework; game modules register against this runtime directly.

local Runtime = {}

local Players = game:GetService('Players')
local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local TextService = game:GetService('TextService')
local HttpService = game:GetService('HttpService')
local CoreGui = game:GetService('CoreGui')

local localPlayer = Players.LocalPlayer
local ACCENT = Color3.fromRGB(174, 112, 255)
local ACCENT_2 = Color3.fromRGB(96, 181, 255)
local BACKGROUND = Color3.fromRGB(10, 12, 18)
local SURFACE = Color3.fromRGB(17, 20, 29)
local SURFACE_2 = Color3.fromRGB(23, 27, 39)
local SURFACE_3 = Color3.fromRGB(30, 35, 49)
local TEXT = Color3.fromRGB(239, 241, 248)
local MUTED = Color3.fromRGB(143, 151, 174)
local DANGER = Color3.fromRGB(255, 92, 112)

local function protectCall(callback, ...)
	local arguments = table.pack(...)
	return xpcall(function()
		return callback(table.unpack(arguments, 1, arguments.n))
	end, debug and debug.traceback or tostring)
end

local function addCorner(object, radius)
	local corner = Instance.new('UICorner')
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = object
	return corner
end

local function addStroke(object, color, transparency, thickness)
	local stroke = Instance.new('UIStroke')
	stroke.Color = color or Color3.new(1, 1, 1)
	stroke.Transparency = transparency == nil and 0.9 or transparency
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = object
	return stroke
end

local function addPadding(object, left, right, top, bottom)
	local padding = Instance.new('UIPadding')
	padding.PaddingLeft = UDim.new(0, left or 0)
	padding.PaddingRight = UDim.new(0, right or left or 0)
	padding.PaddingTop = UDim.new(0, top or left or 0)
	padding.PaddingBottom = UDim.new(0, bottom or top or left or 0)
	padding.Parent = object
	return padding
end

local function makeLabel(parent, text, size, color, bold)
	local label = Instance.new('TextLabel')
	label.BackgroundTransparency = 1
	label.Text = text or ''
	label.TextColor3 = color or TEXT
	label.TextSize = size or 14
	label.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = parent
	return label
end

local function newSignal()
	local bindable = Instance.new('BindableEvent')
	return {
		Event = bindable.Event,
		Fire = function(_, ...)
			bindable:Fire(...)
		end,
		Connect = function(_, callback)
			return bindable.Event:Connect(callback)
		end,
		Destroy = function()
			bindable:Destroy()
		end
	}
end

local function destroyResource(resource)
	if resource == nil then return end
	local kind = typeof(resource)
	if kind == 'RBXScriptConnection' then
		if resource.Connected then resource:Disconnect() end
	elseif kind == 'Instance' then
		resource:Destroy()
	elseif kind == 'thread' then
		pcall(task.cancel, resource)
	elseif type(resource) == 'function' then
		pcall(resource)
	elseif type(resource) == 'table' then
		if type(resource.Disconnect) == 'function' then
			pcall(resource.Disconnect, resource)
		elseif type(resource.Destroy) == 'function' then
			pcall(resource.Destroy, resource)
		elseif type(resource.DoCleaning) == 'function' then
			pcall(resource.DoCleaning, resource)
		end
	end
end

local function attachMaid(api)
	api.Connections = api.Connections or {}
	function api:Clean(resource)
		if resource == nil then
			for index = #self.Connections, 1, -1 do
				destroyResource(self.Connections[index])
				self.Connections[index] = nil
			end
			return
		end
		table.insert(self.Connections, resource)
		return resource
	end
	return api
end

local function colorLight(color, amount)
	return color:Lerp(Color3.new(1, 1, 1), math.clamp(amount or 0, 0, 1))
end

local function colorDark(color, amount)
	return color:Lerp(Color3.new(0, 0, 0), math.clamp(amount or 0, 0, 1))
end

local function shallowCopy(value)
	return type(value) == 'table' and table.clone(value) or value
end

local function formatNumber(value)
	if type(value) ~= 'number' then return tostring(value) end
	if math.abs(value - math.round(value)) < 0.000001 then
		return tostring(math.round(value))
	end
	return string.format('%.4f', value):gsub('0+$', ''):gsub('%.$', '')
end

local function getGuiParent()
	if gethui then
		local ok, result = pcall(gethui)
		if ok and result then return result end
	end
	local ok, result = pcall(function() return CoreGui end)
	if ok and result then return result end
	return localPlayer:WaitForChild('PlayerGui')
end

local function makeDraggable(handle, target, clean)
	local dragging = false
	local dragStart
	local startPosition
	clean(handle.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
		dragging = true
		dragStart = input.Position
		startPosition = target.Position
	end))
	clean(UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
		local delta = input.Position - dragStart
		target.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
	end))
	clean(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end))
end

local function safeFont()
	local ok, font = pcall(Font.fromEnum, Enum.Font.Gotham)
	return ok and font or Font.new('rbxasset://fonts/families/GothamSSm.json')
end

function Runtime.new(config)
	config = config or {}

	local aether = attachMaid({
		Categories = {},
		Components = {},
		Libraries = {},
		Modules = {},
		Windows = {},
		Loaded = false,
		Profile = 'default',
		Place = game.PlaceId,
		ThreadFix = setthreadidentity ~= nil,
		Version = config.Version or 'Standalone 1.0.0',
		Keybind = {'RightShift'},
		HeldKeybinds = {},
		GUIColor = {Hue = 0.7559, Sat = 0.56, Value = 1},
		RainbowSpeed = {Value = 1},
		RainbowUpdateSpeed = {Value = 60},
		RainbowTable = {},
		ToggleMode = {Value = 'Toggle'},
		ToggleNotifications = {Enabled = true},
		Scale = {Value = 1},
		SourceRoot = config.SourceRoot or 'aetherv2',
		RawBase = config.RawBase or 'https://raw.githubusercontent.com/plutoxqqqq/AetherV2/main/'
	})

	local alive = true
	local selectedCategory = 'Combat'
	local selectedModule
	local refreshQueued = false
	local loadingProfile = false
	local saveQueued = false
	local categoryOrder = {}
	local categoryButtons = {}
	local moduleRows = {}
	local assetFunction = getcustomasset
	local isFile = isfile or function(path)
		local ok, result = pcall(readfile, path)
		return ok and type(result) == 'string' and result ~= ''
	end

	local screen = Instance.new('ScreenGui')
	screen.Name = 'AetherStandalone'
	screen.ResetOnSpawn = false
	screen.IgnoreGuiInset = true
	screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	if syn and syn.protect_gui then pcall(syn.protect_gui, screen) end
	screen.Parent = getGuiParent()
	aether.ScreenGui = screen

	local guiRoot = Instance.new('Frame')
	guiRoot.Name = 'Root'
	guiRoot.Size = UDim2.fromScale(1, 1)
	guiRoot.BackgroundTransparency = 1
	guiRoot.Parent = screen
	aether.gui = guiRoot

	local scaledGui = Instance.new('Frame')
	scaledGui.Name = 'ScaledGui'
	scaledGui.Size = UDim2.fromScale(1, 1)
	scaledGui.BackgroundTransparency = 1
	scaledGui.Parent = guiRoot
	local guiScale = Instance.new('UIScale')
	guiScale.Scale = 1
	guiScale.Parent = scaledGui
	aether.guiscale = guiScale

	local clickGui = Instance.new('Frame')
	clickGui.Name = 'ClickGui'
	clickGui.AnchorPoint = Vector2.new(0.5, 0.5)
	clickGui.Position = UDim2.fromScale(0.5, 0.5)
	clickGui.Size = UDim2.fromOffset(920, 580)
	clickGui.BackgroundColor3 = BACKGROUND
	clickGui.BorderSizePixel = 0
	clickGui.ClipsDescendants = true
	clickGui.Parent = scaledGui
	addCorner(clickGui, 16)
	addStroke(clickGui, Color3.new(1, 1, 1), 0.88, 1)
	aether.Windows[1] = clickGui

	local topbar = Instance.new('Frame')
	topbar.Name = 'Topbar'
	topbar.Size = UDim2.new(1, 0, 0, 58)
	topbar.BackgroundColor3 = SURFACE
	topbar.BorderSizePixel = 0
	topbar.Parent = clickGui
	local title = makeLabel(topbar, 'AETHER', 18, TEXT, true)
	title.Position = UDim2.fromOffset(22, 7)
	title.Size = UDim2.fromOffset(150, 24)
	local subtitle = makeLabel(topbar, 'STANDALONE / BEDWARS', 10, MUTED, true)
	subtitle.Position = UDim2.fromOffset(22, 31)
	subtitle.Size = UDim2.fromOffset(230, 16)
	local topGradient = Instance.new('UIGradient')
	topGradient.Color = ColorSequence.new(ACCENT, ACCENT_2)
	topGradient.Parent = title

	local search = Instance.new('TextBox')
	search.Name = 'Search'
	search.AnchorPoint = Vector2.new(0.5, 0.5)
	search.Position = UDim2.new(0.5, 55, 0.5, 0)
	search.Size = UDim2.fromOffset(300, 34)
	search.BackgroundColor3 = SURFACE_2
	search.BorderSizePixel = 0
	search.PlaceholderText = 'Search all modules...'
	search.PlaceholderColor3 = MUTED
	search.Text = ''
	search.TextColor3 = TEXT
	search.TextSize = 13
	search.Font = Enum.Font.Gotham
	search.ClearTextOnFocus = false
	search.TextXAlignment = Enum.TextXAlignment.Left
	addPadding(search, 14, 14, 0, 0)
	addCorner(search, 9)
	addStroke(search, Color3.new(1, 1, 1), 0.92, 1)
	search.Parent = topbar

	local closeButton = Instance.new('TextButton')
	closeButton.Name = 'Close'
	closeButton.Position = UDim2.new(1, -47, 0, 13)
	closeButton.Size = UDim2.fromOffset(32, 32)
	closeButton.BackgroundColor3 = SURFACE_2
	closeButton.AutoButtonColor = false
	closeButton.Text = '×'
	closeButton.TextColor3 = MUTED
	closeButton.TextSize = 22
	closeButton.Font = Enum.Font.Gotham
	closeButton.Parent = topbar
	addCorner(closeButton, 9)

	local minimizeButton = closeButton:Clone()
	minimizeButton.Name = 'Minimize'
	minimizeButton.Position = UDim2.new(1, -85, 0, 13)
	minimizeButton.Text = '–'
	minimizeButton.TextSize = 20
	minimizeButton.Parent = topbar

	local sidebar = Instance.new('Frame')
	sidebar.Name = 'Sidebar'
	sidebar.Position = UDim2.fromOffset(0, 58)
	sidebar.Size = UDim2.new(0, 170, 1, -58)
	sidebar.BackgroundColor3 = Color3.fromRGB(13, 15, 22)
	sidebar.BorderSizePixel = 0
	sidebar.Parent = clickGui

	local categoryList = Instance.new('ScrollingFrame')
	categoryList.Name = 'Categories'
	categoryList.Position = UDim2.fromOffset(10, 13)
	categoryList.Size = UDim2.new(1, -20, 1, -70)
	categoryList.BackgroundTransparency = 1
	categoryList.BorderSizePixel = 0
	categoryList.ScrollBarThickness = 0
	categoryList.CanvasSize = UDim2.new()
	categoryList.Parent = sidebar
	local categoryLayout = Instance.new('UIListLayout')
	categoryLayout.Padding = UDim.new(0, 5)
	categoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
	categoryLayout.Parent = categoryList

	local footer = makeLabel(sidebar, 'RightShift  •  toggle UI', 10, MUTED)
	footer.Position = UDim2.new(0, 15, 1, -42)
	footer.Size = UDim2.new(1, -30, 0, 24)

	local modulePane = Instance.new('Frame')
	modulePane.Name = 'ModulePane'
	modulePane.Position = UDim2.fromOffset(170, 58)
	modulePane.Size = UDim2.new(0, 350, 1, -58)
	modulePane.BackgroundColor3 = SURFACE
	modulePane.BorderSizePixel = 0
	modulePane.Parent = clickGui

	local categoryTitle = makeLabel(modulePane, 'COMBAT', 12, MUTED, true)
	categoryTitle.Position = UDim2.fromOffset(18, 10)
	categoryTitle.Size = UDim2.new(1, -36, 0, 30)

	local moduleList = Instance.new('ScrollingFrame')
	moduleList.Name = 'Modules'
	moduleList.Position = UDim2.fromOffset(12, 45)
	moduleList.Size = UDim2.new(1, -24, 1, -57)
	moduleList.BackgroundTransparency = 1
	moduleList.BorderSizePixel = 0
	moduleList.ScrollBarThickness = 2
	moduleList.ScrollBarImageColor3 = ACCENT
	moduleList.CanvasSize = UDim2.new()
	moduleList.Parent = modulePane
	local moduleLayout = Instance.new('UIListLayout')
	moduleLayout.Padding = UDim.new(0, 7)
	moduleLayout.SortOrder = Enum.SortOrder.LayoutOrder
	moduleLayout.Parent = moduleList

	local detailsPane = Instance.new('Frame')
	detailsPane.Name = 'Details'
	detailsPane.Position = UDim2.fromOffset(520, 58)
	detailsPane.Size = UDim2.new(1, -520, 1, -58)
	detailsPane.BackgroundColor3 = Color3.fromRGB(12, 14, 21)
	detailsPane.BorderSizePixel = 0
	detailsPane.Parent = clickGui

	local detailTitle = makeLabel(detailsPane, 'Select a module', 20, TEXT, true)
	detailTitle.Position = UDim2.fromOffset(22, 18)
	detailTitle.Size = UDim2.new(1, -44, 0, 28)
	local detailCategory = makeLabel(detailsPane, 'MODULE SETTINGS', 10, MUTED, true)
	detailCategory.Position = UDim2.fromOffset(22, 47)
	detailCategory.Size = UDim2.new(1, -44, 0, 18)
	local detailDescription = makeLabel(detailsPane, 'Choose a module to configure it.', 12, MUTED)
	detailDescription.Position = UDim2.fromOffset(22, 72)
	detailDescription.Size = UDim2.new(1, -44, 0, 42)
	detailDescription.TextWrapped = true
	detailDescription.TextYAlignment = Enum.TextYAlignment.Top

	local detailToggle = Instance.new('TextButton')
	detailToggle.Name = 'ModuleToggle'
	detailToggle.Position = UDim2.fromOffset(22, 120)
	detailToggle.Size = UDim2.new(1, -44, 0, 38)
	detailToggle.BackgroundColor3 = SURFACE_2
	detailToggle.BorderSizePixel = 0
	detailToggle.AutoButtonColor = false
	detailToggle.Text = 'DISABLED'
	detailToggle.TextColor3 = MUTED
	detailToggle.TextSize = 12
	detailToggle.Font = Enum.Font.GothamBold
	detailToggle.Visible = false
	detailToggle.Parent = detailsPane
	addCorner(detailToggle, 9)

	local optionsHolder = Instance.new('ScrollingFrame')
	optionsHolder.Name = 'Options'
	optionsHolder.Position = UDim2.fromOffset(16, 171)
	optionsHolder.Size = UDim2.new(1, -32, 1, -183)
	optionsHolder.BackgroundTransparency = 1
	optionsHolder.BorderSizePixel = 0
	optionsHolder.ScrollBarThickness = 2
	optionsHolder.ScrollBarImageColor3 = ACCENT
	optionsHolder.CanvasSize = UDim2.new()
	optionsHolder.Parent = detailsPane

	local notifications = Instance.new('Frame')
	notifications.Name = 'Notifications'
	notifications.AnchorPoint = Vector2.new(1, 1)
	notifications.Position = UDim2.new(1, -18, 1, -18)
	notifications.Size = UDim2.fromOffset(340, 500)
	notifications.BackgroundTransparency = 1
	notifications.Parent = guiRoot
	local notificationLayout = Instance.new('UIListLayout')
	notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	notificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	notificationLayout.Padding = UDim.new(0, 8)
	notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
	notificationLayout.Parent = notifications

	local function clean(resource)
		return aether:Clean(resource)
	end

	makeDraggable(topbar, clickGui, clean)

	clean(categoryLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		categoryList.CanvasSize = UDim2.fromOffset(0, categoryLayout.AbsoluteContentSize.Y + 10)
	end))
	clean(moduleLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
		moduleList.CanvasSize = UDim2.fromOffset(0, moduleLayout.AbsoluteContentSize.Y + 10)
	end))

	function aether:CreateNotification(notificationTitle, message, duration, kind)
		if not alive then return end
		local card = Instance.new('Frame')
		card.Size = UDim2.fromOffset(320, 68)
		card.BackgroundColor3 = SURFACE
		card.BorderSizePixel = 0
		card.Parent = notifications
		addCorner(card, 11)
		addStroke(card, (kind == 'alert' or kind == 'warning') and DANGER or ACCENT, 0.35, 1)
		local stripe = Instance.new('Frame')
		stripe.Size = UDim2.fromOffset(4, 44)
		stripe.Position = UDim2.fromOffset(8, 12)
		stripe.BackgroundColor3 = (kind == 'alert' or kind == 'warning') and DANGER or ACCENT
		stripe.BorderSizePixel = 0
		stripe.Parent = card
		addCorner(stripe, 3)
		local heading = makeLabel(card, tostring(notificationTitle or 'Aether'), 13, TEXT, true)
		heading.Position = UDim2.fromOffset(22, 9)
		heading.Size = UDim2.new(1, -32, 0, 20)
		local body = makeLabel(card, tostring(message or ''), 11, MUTED)
		body.Position = UDim2.fromOffset(22, 29)
		body.Size = UDim2.new(1, -32, 0, 31)
		body.TextWrapped = true
		body.RichText = true
		duration = tonumber(duration) or 3
		task.delay(math.max(duration, 0.25), function()
			if not card.Parent then return end
			local tween = TweenService:Create(card, TweenInfo.new(0.2), {BackgroundTransparency = 1})
			tween:Play()
			task.delay(0.22, function() if card.Parent then card:Destroy() end end)
		end)
		return card
	end

	local function reportError(scope, errorMessage)
		warn('[Aether Standalone] '..scope..': '..tostring(errorMessage))
		aether:CreateNotification(scope, tostring(errorMessage), 6, 'warning')
	end

	local function invokeOption(settings, ...)
		if type(settings.Function) ~= 'function' then return end
		local ok, err = protectCall(settings.Function, ...)
		if not ok then reportError(settings.Name or 'Option', err) end
	end

	local function scheduleSave()
		if loadingProfile or not aether.Loaded or saveQueued then return end
		saveQueued = true
		task.delay(0.35, function()
			saveQueued = false
			if alive and aether.Loaded and type(aether.Save) == 'function' then
				pcall(function() aether:Save() end)
			end
		end)
	end

	local function updateModuleVisual(module)
		local row = moduleRows[module]
		if row and row.Parent then
			row.BackgroundColor3 = module.Enabled and Color3.fromRGB(39, 32, 57) or SURFACE_2
			row.NameLabel.TextColor3 = module.Enabled and TEXT or Color3.fromRGB(211, 216, 231)
			row.State.Text = module.Enabled and 'ON' or 'OFF'
			row.State.TextColor3 = module.Enabled and ACCENT or MUTED
			row.Indicator.BackgroundColor3 = module.Enabled and ACCENT or SURFACE_3
		end
		if selectedModule == module then
			detailToggle.Text = module.Enabled and 'ENABLED' or 'DISABLED'
			detailToggle.TextColor3 = module.Enabled and TEXT or MUTED
			detailToggle.BackgroundColor3 = module.Enabled and Color3.fromRGB(80, 52, 115) or SURFACE_2
		end
	end

	local function createOptionContainer(module, name, height, visible)
		local row = Instance.new('Frame')
		row.Name = (name or 'Option'):gsub('[^%w]', '')..'Option'
		row.Size = UDim2.new(1, -4, 0, height or 42)
		row.BackgroundColor3 = SURFACE_2
		row.BorderSizePixel = 0
		row.Visible = visible == nil or visible
		row.Parent = module.Children
		addCorner(row, 8)
		addStroke(row, Color3.new(1, 1, 1), 0.94, 1)
		local label = makeLabel(row, name or 'Option', 12, Color3.fromRGB(213, 218, 233), false)
		label.Name = 'Title'
		label.Position = UDim2.fromOffset(12, 0)
		label.Size = UDim2.new(0.55, -12, 1, 0)
		return row, label
	end

	local function registerOption(module, settings, option)
		option.Name = settings.Name
		option.Settings = settings
		module.Options[settings.Name] = option
		return option
	end

	local function setToggleVisual(option)
		if not option.Object or not option.Object.Parent then return end
		local button = option.Object:FindFirstChild('Control')
		if button then
			button.Text = option.Enabled and 'ON' or 'OFF'
			button.TextColor3 = option.Enabled and TEXT or MUTED
			button.BackgroundColor3 = option.Enabled and Color3.fromRGB(83, 54, 118) or SURFACE_3
		end
	end

	local optionFactories = {}

	function optionFactories.Toggle(module, settings)
		local row = createOptionContainer(module, settings.Name, 42, settings.Visible)
		local button = Instance.new('TextButton')
		button.Name = 'Control'
		button.AnchorPoint = Vector2.new(1, 0.5)
		button.Position = UDim2.new(1, -10, 0.5, 0)
		button.Size = UDim2.fromOffset(50, 24)
		button.BackgroundColor3 = SURFACE_3
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.Text = 'OFF'
		button.TextColor3 = MUTED
		button.TextSize = 10
		button.Font = Enum.Font.GothamBold
		button.Parent = row
		addCorner(button, 7)
		local option = registerOption(module, settings, {Type = 'Toggle', Enabled = false, Object = row})
		function option:SetValue(value, silent)
			value = value and true or false
			if self.Enabled == value then
				setToggleVisual(self)
				return
			end
			self.Enabled = value
			setToggleVisual(self)
			if not silent then invokeOption(settings, value) end
			scheduleSave()
		end
		function option:Toggle(silent)
			self:SetValue(not self.Enabled, silent)
		end
		button.MouseButton1Click:Connect(function() option:Toggle() end)
		if settings.Default then option:SetValue(true, false) end
		return option
	end

	function optionFactories.Slider(module, settings)
		local row = createOptionContainer(module, settings.Name, 48, settings.Visible)
		local box = Instance.new('TextBox')
		box.Name = 'Control'
		box.AnchorPoint = Vector2.new(1, 0.5)
		box.Position = UDim2.new(1, -10, 0.5, 0)
		box.Size = UDim2.fromOffset(92, 27)
		box.BackgroundColor3 = SURFACE_3
		box.BorderSizePixel = 0
		box.ClearTextOnFocus = false
		box.TextColor3 = TEXT
		box.TextSize = 11
		box.Font = Enum.Font.GothamMedium
		box.Parent = row
		addCorner(box, 7)
		local option = registerOption(module, settings, {
			Type = 'Slider',
			Value = settings.Default == nil and (settings.Min or 0) or settings.Default,
			Min = settings.Min or 0,
			Max = settings.Max or 100,
			Object = row
		})
		local function render()
			local suffix = settings.Suffix and (' '..(type(settings.Suffix) == 'function' and settings.Suffix(option.Value) or settings.Suffix)) or ''
			box.Text = formatNumber(option.Value)..suffix
		end
		function option:SetValue(value, _, final)
			value = tonumber(value)
			if not value or value ~= value or value == math.huge or value == -math.huge then return end
			local decimal = tonumber(settings.Decimal) or 1
			value = math.clamp(value, self.Min, self.Max)
			value = math.round(value * decimal) / decimal
			local changed = self.Value ~= value
			self.Value = value
			render()
			if changed or final then invokeOption(settings, value, final) end
			scheduleSave()
		end
		box.Focused:Connect(function() box.Text = formatNumber(option.Value) end)
		box.FocusLost:Connect(function(enter)
			if enter then option:SetValue(box.Text, nil, true) else render() end
		end)
		render()
		return option
	end

	function optionFactories.TwoSlider(module, settings)
		local row, label = createOptionContainer(module, settings.Name, 58, settings.Visible)
		label.Size = UDim2.new(1, -24, 0, 24)
		local minBox = Instance.new('TextBox')
		minBox.Name = 'Min'
		minBox.Position = UDim2.fromOffset(12, 28)
		minBox.Size = UDim2.new(0.5, -17, 0, 23)
		minBox.BackgroundColor3 = SURFACE_3
		minBox.BorderSizePixel = 0
		minBox.ClearTextOnFocus = false
		minBox.TextColor3 = TEXT
		minBox.TextSize = 10
		minBox.Font = Enum.Font.Gotham
		minBox.Parent = row
		addCorner(minBox, 6)
		local maxBox = minBox:Clone()
		maxBox.Name = 'Max'
		maxBox.Position = UDim2.new(0.5, 5, 0, 28)
		maxBox.Parent = row
		local option = registerOption(module, settings, {
			Type = 'TwoSlider',
			ValueMin = settings.DefaultMin == nil and (settings.Min or 0) or settings.DefaultMin,
			ValueMax = settings.DefaultMax == nil and (settings.Max or 10) or settings.DefaultMax,
			Min = settings.Min or 0,
			Max = settings.Max or 10,
			Object = row
		})
		local function render()
			minBox.Text = formatNumber(option.ValueMin)
			maxBox.Text = formatNumber(option.ValueMax)
		end
		function option:SetValue(minimum, maximum, final)
			local decimal = tonumber(settings.Decimal) or 1
			minimum = tonumber(minimum) or self.ValueMin
			maximum = tonumber(maximum) or self.ValueMax
			minimum = math.round(math.clamp(minimum, self.Min, self.Max) * decimal) / decimal
			maximum = math.round(math.clamp(maximum, self.Min, self.Max) * decimal) / decimal
			if minimum > maximum then minimum, maximum = maximum, minimum end
			self.ValueMin, self.ValueMax = minimum, maximum
			render()
			invokeOption(settings, minimum, maximum, final)
			scheduleSave()
		end
		function option:GetRandomValue()
			return self.ValueMin + math.random() * (self.ValueMax - self.ValueMin)
		end
		minBox.FocusLost:Connect(function(enter)
			if enter then option:SetValue(minBox.Text, option.ValueMax, true) else render() end
		end)
		maxBox.FocusLost:Connect(function(enter)
			if enter then option:SetValue(option.ValueMin, maxBox.Text, true) else render() end
		end)
		render()
		return option
	end

	function optionFactories.Dropdown(module, settings)
		local row = createOptionContainer(module, settings.Name, 44, settings.Visible)
		local button = Instance.new('TextButton')
		button.Name = 'Control'
		button.AnchorPoint = Vector2.new(1, 0.5)
		button.Position = UDim2.new(1, -10, 0.5, 0)
		button.Size = UDim2.fromOffset(130, 27)
		button.BackgroundColor3 = SURFACE_3
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.TextColor3 = TEXT
		button.TextSize = 10
		button.Font = Enum.Font.GothamMedium
		button.TextTruncate = Enum.TextTruncate.AtEnd
		button.Parent = row
		addCorner(button, 7)
		local list = shallowCopy(settings.List or {})
		local option = registerOption(module, settings, {
			Type = 'Dropdown',
			List = list,
			Value = settings.Default or list[1],
			Object = row
		})
		local function render() button.Text = tostring(option.Value or 'None') end
		function option:SetValue(value, silent)
			self.Value = value
			render()
			if not silent then invokeOption(settings, value) end
			scheduleSave()
		end
		function option:SetList(newList)
			self.List = shallowCopy(newList or {})
			if not table.find(self.List, self.Value) then self:SetValue(self.List[1]) end
		end
		local function cycle(direction)
			if #option.List == 0 then return end
			local index = table.find(option.List, option.Value) or 1
			index = ((index - 1 + direction) % #option.List) + 1
			option:SetValue(option.List[index])
		end
		button.MouseButton1Click:Connect(function() cycle(1) end)
		button.MouseButton2Click:Connect(function() cycle(-1) end)
		render()
		return option
	end

	function optionFactories.TextBox(module, settings)
		local row = createOptionContainer(module, settings.Name, 46, settings.Visible)
		local box = Instance.new('TextBox')
		box.Name = 'Control'
		box.AnchorPoint = Vector2.new(1, 0.5)
		box.Position = UDim2.new(1, -10, 0.5, 0)
		box.Size = UDim2.fromOffset(148, 28)
		box.BackgroundColor3 = SURFACE_3
		box.BorderSizePixel = 0
		box.ClearTextOnFocus = false
		box.PlaceholderText = settings.Placeholder or ''
		box.PlaceholderColor3 = MUTED
		box.TextColor3 = TEXT
		box.TextSize = 10
		box.Font = Enum.Font.Gotham
		box.TextXAlignment = Enum.TextXAlignment.Left
		addPadding(box, 8, 8, 0, 0)
		box.Parent = row
		addCorner(box, 7)
		local option = registerOption(module, settings, {Type = 'TextBox', Value = tostring(settings.Default or ''), Object = row})
		function option:SetValue(value, silent)
			self.Value = tostring(value or '')
			box.Text = self.Value
			if not silent then invokeOption(settings, self.Value) end
			scheduleSave()
		end
		box.Text = option.Value
		box.FocusLost:Connect(function() option:SetValue(box.Text) end)
		return option
	end

	function optionFactories.TextList(module, settings)
		local row, label = createOptionContainer(module, settings.Name, 72, settings.Visible)
		label.Size = UDim2.new(1, -24, 0, 28)
		local box = Instance.new('TextBox')
		box.Name = 'Control'
		box.Position = UDim2.fromOffset(10, 32)
		box.Size = UDim2.new(1, -20, 0, 30)
		box.BackgroundColor3 = SURFACE_3
		box.BorderSizePixel = 0
		box.ClearTextOnFocus = false
		box.PlaceholderText = settings.Placeholder or 'Comma-separated entries'
		box.PlaceholderColor3 = MUTED
		box.TextColor3 = TEXT
		box.TextSize = 10
		box.Font = Enum.Font.Gotham
		box.TextXAlignment = Enum.TextXAlignment.Left
		addPadding(box, 8, 8, 0, 0)
		box.Parent = row
		addCorner(box, 7)
		local initial = shallowCopy(settings.Default or {})
		local option = registerOption(module, settings, {
			Type = 'TextList',
			List = shallowCopy(initial),
			ListEnabled = shallowCopy(initial),
			Objects = {},
			Window = {Visible = false},
			Object = row
		})
		local function render() box.Text = table.concat(option.List, ', ') end
		function option:ChangeValue(value)
			if value ~= nil and value ~= '' then
				local index = table.find(self.List, value)
				if index then
					table.remove(self.List, index)
					local enabledIndex = table.find(self.ListEnabled, value)
					if enabledIndex then table.remove(self.ListEnabled, enabledIndex) end
				else
					table.insert(self.List, value)
					table.insert(self.ListEnabled, value)
				end
			end
			render()
			invokeOption(settings, self.List)
			scheduleSave()
		end
		function option:SetValue(values, silent)
			self.List = shallowCopy(values or {})
			self.ListEnabled = shallowCopy(values or {})
			render()
			if not silent then invokeOption(settings, self.List) end
			scheduleSave()
		end
		box.FocusLost:Connect(function()
			local values = {}
			for entry in box.Text:gmatch('[^,]+') do
				entry = entry:match('^%s*(.-)%s*$')
				if entry ~= '' and not table.find(values, entry) then table.insert(values, entry) end
			end
			option:SetValue(values)
		end)
		render()
		if settings.Default then invokeOption(settings, option.List) end
		return option
	end

	function optionFactories.ColorSlider(module, settings)
		local row, label = createOptionContainer(module, settings.Name, 72, settings.Visible)
		label.Size = UDim2.new(1, -24, 0, 28)
		local preview = Instance.new('Frame')
		preview.Name = 'Preview'
		preview.Position = UDim2.new(1, -35, 0, 8)
		preview.Size = UDim2.fromOffset(22, 16)
		preview.BorderSizePixel = 0
		preview.Parent = row
		addCorner(preview, 5)
		local box = Instance.new('TextBox')
		box.Name = 'Control'
		box.Position = UDim2.fromOffset(10, 34)
		box.Size = UDim2.new(1, -20, 0, 28)
		box.BackgroundColor3 = SURFACE_3
		box.BorderSizePixel = 0
		box.ClearTextOnFocus = false
		box.TextColor3 = TEXT
		box.TextSize = 10
		box.Font = Enum.Font.Gotham
		box.Parent = row
		addCorner(box, 7)
		local option = registerOption(module, settings, {
			Type = 'ColorSlider',
			Hue = settings.DefaultHue or 0.756,
			Sat = settings.DefaultSat or 0.56,
			Value = settings.DefaultValue or 1,
			Opacity = settings.DefaultOpacity or 1,
			Rainbow = false,
			Object = row
		})
		local function render()
			local color = Color3.fromHSV(option.Hue, option.Sat, option.Value)
			preview.BackgroundColor3 = color
			preview.BackgroundTransparency = 1 - option.Opacity
			box.Text = string.format('%d, %d, %d', math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255))
		end
		function option:SetValue(hue, saturation, value, opacity, silent)
			self.Hue = tonumber(hue) or self.Hue
			self.Sat = tonumber(saturation) or self.Sat
			self.Value = tonumber(value) or self.Value
			self.Opacity = tonumber(opacity) or self.Opacity
			render()
			if not silent then invokeOption(settings, self.Hue, self.Sat, self.Value, self.Opacity) end
			scheduleSave()
		end
		function option:Toggle()
			self.Rainbow = not self.Rainbow
			if self.Rainbow then table.insert(aether.RainbowTable, self) else
				local index = table.find(aether.RainbowTable, self)
				if index then table.remove(aether.RainbowTable, index) end
			end
			scheduleSave()
		end
		function option:Color(hue, saturation, value)
			if self.Rainbow then self:SetValue(hue, saturation, value, nil, false) end
		end
		box.FocusLost:Connect(function(enter)
			if not enter then render() return end
			local parts = box.Text:split(',')
			local red, green, blue = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
			if red and green and blue then option:SetValue(Color3.fromRGB(red, green, blue):ToHSV()) else render() end
		end)
		render()
		return option
	end

	function optionFactories.Targets(module, settings)
		local row, label = createOptionContainer(module, settings.Name or 'Targets', 70, settings.Visible)
		label.Size = UDim2.new(1, -24, 0, 28)
		local option = registerOption(module, {Name = settings.Name or 'Targets', Function = settings.Function}, {Type = 'Targets', Object = row})
		local entries = {
			{'Players', settings.Players ~= false},
			{'NPCs', settings.NPCs == true},
			{'Walls', settings.Walls == true}
		}
		for index, entry in entries do
			local button = Instance.new('TextButton')
			button.Name = entry[1]
			button.Position = UDim2.new((index - 1) / 3, index == 1 and 10 or 4, 0, 34)
			button.Size = UDim2.new(1 / 3, -10, 0, 26)
			button.BackgroundColor3 = SURFACE_3
			button.BorderSizePixel = 0
			button.AutoButtonColor = false
			button.Text = entry[1]
			button.TextColor3 = MUTED
			button.TextSize = 9
			button.Font = Enum.Font.GothamBold
			button.Parent = row
			addCorner(button, 6)
			local child = {Enabled = entry[2], Object = button}
			local function render()
				button.BackgroundColor3 = child.Enabled and Color3.fromRGB(75, 51, 104) or SURFACE_3
				button.TextColor3 = child.Enabled and TEXT or MUTED
			end
			function child:SetValue(value, silent)
				self.Enabled = value and true or false
				render()
				if not silent then invokeOption(settings, self.Enabled) end
				scheduleSave()
			end
			function child:Toggle(silent) self:SetValue(not self.Enabled, silent) end
			button.MouseButton1Click:Connect(function() child:Toggle() end)
			option[entry[1]] = child
			render()
		end
		return option
	end

	function optionFactories.Button(module, settings)
		local row = createOptionContainer(module, settings.Name, 44, settings.Visible)
		local button = Instance.new('TextButton')
		button.Name = 'Control'
		button.AnchorPoint = Vector2.new(1, 0.5)
		button.Position = UDim2.new(1, -10, 0.5, 0)
		button.Size = UDim2.fromOffset(92, 27)
		button.BackgroundColor3 = Color3.fromRGB(68, 47, 92)
		button.BorderSizePixel = 0
		button.AutoButtonColor = false
		button.Text = settings.ButtonText or 'RUN'
		button.TextColor3 = TEXT
		button.TextSize = 10
		button.Font = Enum.Font.GothamBold
		button.Parent = row
		addCorner(button, 7)
		button.MouseButton1Click:Connect(function() invokeOption(settings) end)
		local option = {Type = 'Button', Name = settings.Name, Object = row, Label = button}
		module.Options[settings.Name] = option
		return option
	end

	function optionFactories.Font(module, settings)
		local fonts = {
			{name = 'Gotham', value = safeFont()},
			{name = 'Arial', value = Font.fromEnum(Enum.Font.Arial)},
			{name = 'Code', value = Font.fromEnum(Enum.Font.Code)},
			{name = 'Cartoon', value = Font.fromEnum(Enum.Font.Cartoon)}
		}
		local row = createOptionContainer(module, settings.Name, 44, settings.Visible)
		local button = Instance.new('TextButton')
		button.Name = 'Control'
		button.AnchorPoint = Vector2.new(1, 0.5)
		button.Position = UDim2.new(1, -10, 0.5, 0)
		button.Size = UDim2.fromOffset(130, 27)
		button.BackgroundColor3 = SURFACE_3
		button.BorderSizePixel = 0
		button.TextColor3 = TEXT
		button.TextSize = 10
		button.Font = Enum.Font.Gotham
		button.Parent = row
		addCorner(button, 7)
		local option = registerOption(module, settings, {Type = 'Font', Value = fonts[1].value, FontName = fonts[1].name, Object = row})
		local index = 1
		function option:SetValue(value, silent)
			if typeof(value) == 'Font' then
				self.Value = value
			else
				for i, item in fonts do
					if item.name == value then index = i; self.Value = item.value; self.FontName = item.name break end
				end
			end
			button.Text = self.FontName
			if not silent then invokeOption(settings, self.Value) end
			scheduleSave()
		end
		button.MouseButton1Click:Connect(function()
			index = index % #fonts + 1
			option.FontName = fonts[index].name
			option:SetValue(fonts[index].value)
		end)
		button.Text = option.FontName
		return option
	end

	local function makeFallbackHotbar(module, settings)
		local row = createOptionContainer(module, settings.Name or 'HotbarList', 44, settings.Visible)
		local option = registerOption(module, {Name = settings.Name or 'HotbarList'}, {
			Type = 'HotbarList',
			Hotbars = {},
			Selected = 1,
			Object = row
		})
		function option:AddHotbar(data)
			table.insert(self.Hotbars, {Hotbar = shallowCopy(data or {}), Object = Instance.new('Frame')})
		end
		option:AddHotbar()
		return option
	end

	local function createModule(category, settings)
		settings = settings or {}
		if aether.Modules[settings.Name] then aether:Remove(settings.Name) end
		local module = attachMaid({
			Type = 'Module',
			Name = settings.Name or 'Unnamed',
			Category = category.Name,
			Subcategory = settings.Category,
			Tooltip = settings.Tooltip or '',
			ExtraText = settings.ExtraText,
			Enabled = false,
			Options = {},
			Bind = {},
			Favourited = false,
			Settings = settings
		})
		local children = Instance.new('Frame')
		children.Name = module.Name..'Options'
		children.Size = UDim2.new(1, -4, 0, 0)
		children.BackgroundColor3 = SURFACE
		children.BackgroundTransparency = 1
		children.Parent = nil
		local layout = Instance.new('UIListLayout')
		layout.Padding = UDim.new(0, 7)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = children
		layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
			children.Size = UDim2.new(1, -4, 0, layout.AbsoluteContentSize.Y)
			if selectedModule == module then optionsHolder.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 8) end
		end)
		module.Children = children
		module.OptionsChildren = children

		function module:SetBind(value)
			if type(value) == 'string' then value = value == '' and {} or {value} end
			self.Bind = shallowCopy(value or {})
			scheduleSave()
		end
		function module:SetFavourite(value) self.Favourited = value and true or false end
		function module:Toggle(multiple)
			if not alive then return end
			self.Enabled = not self.Enabled
			if not self.Enabled then self:Clean() end
			updateModuleVisual(self)
			local expectedState = self.Enabled
			task.spawn(function()
				local ok, err = protectCall(settings.Function or function() end, expectedState)
				if not ok then
					reportError(self.Name, err)
					if expectedState and self.Enabled == expectedState then
						self.Enabled = false
						self:Clean()
						updateModuleVisual(self)
					end
				end
			end)
			if not multiple then scheduleSave() end
		end
		for name, factory in optionFactories do
			module['Create'..name] = function(_, optionSettings)
				return factory(module, optionSettings or {})
			end
		end
		function module:CreateHotbarList(optionSettings)
			local custom = aether.Components.HotbarList
			if type(custom) == 'function' then
				local ok, result = protectCall(custom, optionSettings or {}, self.Children, self)
				if ok then return result end
				reportError(self.Name..' HotbarList', result)
			end
			return makeFallbackHotbar(self, optionSettings or {})
		end

		category.Modules[module.Name] = module
		aether.Modules[module.Name] = module
		task.defer(function() if alive then aether:RefreshModules() end end)
		return module
	end

	function aether:CreateCategory(settings)
		settings = type(settings) == 'table' and settings or {Name = settings}
		local name = settings.Name
		if self.Categories[name] then return self.Categories[name] end
		local category = {Type = 'Category', Name = name, Modules = {}, Options = {}, Settings = settings}
		function category:CreateModule(moduleSettings)
			return createModule(self, moduleSettings)
		end
		self.Categories[name] = category
		table.insert(categoryOrder, name)
		return category
	end

	local function selectModule(module)
		if selectedModule and selectedModule.Children.Parent == optionsHolder then selectedModule.Children.Parent = nil end
		selectedModule = module
		if not module then
			detailTitle.Text = 'Select a module'
			detailCategory.Text = 'MODULE SETTINGS'
			detailDescription.Text = 'Choose a module to configure it.'
			detailToggle.Visible = false
			return
		end
		detailTitle.Text = module.Name
		detailCategory.Text = string.upper(module.Category..(module.Subcategory and (' / '..module.Subcategory) or ''))
		detailDescription.Text = module.Tooltip ~= '' and module.Tooltip or 'No description supplied.'
		detailToggle.Visible = true
		module.Children.Parent = optionsHolder
		module.Children.Position = UDim2.fromOffset(2, 0)
		optionsHolder.CanvasSize = UDim2.fromOffset(0, module.Children.AbsoluteSize.Y + 8)
		updateModuleVisual(module)
	end

	local function createModuleRow(module)
		local row = Instance.new('TextButton')
		row.Name = module.Name
		row.Size = UDim2.new(1, -4, 0, 56)
		row.BackgroundColor3 = SURFACE_2
		row.BorderSizePixel = 0
		row.AutoButtonColor = false
		row.Text = ''
		row.Parent = moduleList
		addCorner(row, 10)
		addStroke(row, Color3.new(1, 1, 1), 0.94, 1)
		local indicator = Instance.new('Frame')
		indicator.Name = 'Indicator'
		indicator.Position = UDim2.fromOffset(8, 10)
		indicator.Size = UDim2.fromOffset(4, 36)
		indicator.BackgroundColor3 = SURFACE_3
		indicator.BorderSizePixel = 0
		indicator.Parent = row
		addCorner(indicator, 3)
		local nameLabel = makeLabel(row, module.Name, 13, TEXT, true)
		nameLabel.Name = 'NameLabel'
		nameLabel.Position = UDim2.fromOffset(22, 7)
		nameLabel.Size = UDim2.new(1, -90, 0, 23)
		local description = makeLabel(row, module.Tooltip ~= '' and module.Tooltip:gsub('\n.*', '') or module.Category, 10, MUTED)
		description.Name = 'Description'
		description.Position = UDim2.fromOffset(22, 29)
		description.Size = UDim2.new(1, -90, 0, 18)
		description.TextTruncate = Enum.TextTruncate.AtEnd
		local state = makeLabel(row, 'OFF', 10, MUTED, true)
		state.Name = 'State'
		state.AnchorPoint = Vector2.new(1, 0.5)
		state.Position = UDim2.new(1, -14, 0.5, 0)
		state.Size = UDim2.fromOffset(42, 20)
		state.TextXAlignment = Enum.TextXAlignment.Right
		row.MouseButton1Click:Connect(function() module:Toggle() end)
		row.MouseButton2Click:Connect(function() selectModule(module) end)
		row.MouseEnter:Connect(function()
			if not module.Enabled then row.BackgroundColor3 = SURFACE_3 end
		end)
		row.MouseLeave:Connect(function() updateModuleVisual(module) end)
		moduleRows[module] = row
		module.Object = row
		updateModuleVisual(module)
		return row
	end

	function aether:RefreshModules()
		if refreshQueued then return end
		refreshQueued = true
		task.defer(function()
			refreshQueued = false
			if not alive then return end
			for _, row in moduleRows do if row.Parent then row:Destroy() end end
			table.clear(moduleRows)
			local query = search.Text:lower()
			local found = {}
			for _, module in self.Modules do
				local matchesCategory = query ~= '' or module.Category == selectedCategory
				local matchesSearch = query == '' or module.Name:lower():find(query, 1, true) or module.Category:lower():find(query, 1, true)
				if matchesCategory and matchesSearch then table.insert(found, module) end
			end
			table.sort(found, function(left, right)
				if left.Enabled ~= right.Enabled then return left.Enabled end
				return left.Name:lower() < right.Name:lower()
			end)
			for order, module in found do
				local row = createModuleRow(module)
				row.LayoutOrder = order
			end
			categoryTitle.Text = query ~= '' and ('SEARCH / '..#found..' RESULTS') or string.upper(selectedCategory)
		end)
	end

	local function refreshCategoryButtons()
		for _, button in categoryButtons do button:Destroy() end
		table.clear(categoryButtons)
		for order, name in categoryOrder do
			local category = aether.Categories[name]
			if category.Hidden then continue end
			local button = Instance.new('TextButton')
			button.Name = name
			button.Size = UDim2.new(1, 0, 0, 34)
			button.BackgroundColor3 = name == selectedCategory and Color3.fromRGB(46, 35, 64) or Color3.fromRGB(13, 15, 22)
			button.BorderSizePixel = 0
			button.AutoButtonColor = false
			button.Text = name
			button.TextColor3 = name == selectedCategory and TEXT or MUTED
			button.TextSize = 11
			button.Font = name == selectedCategory and Enum.Font.GothamBold or Enum.Font.Gotham
			button.TextXAlignment = Enum.TextXAlignment.Left
			addPadding(button, 12, 10, 0, 0)
			addCorner(button, 8)
			button.LayoutOrder = order
			button.Parent = categoryList
			button.MouseButton1Click:Connect(function()
				selectedCategory = name
				search.Text = ''
				refreshCategoryButtons()
				aether:RefreshModules()
			end)
			table.insert(categoryButtons, button)
		end
	end

	local standardCategories = {'Combat', 'Blatant', 'Exploits', 'Render', 'Visuals', 'World', 'Inventory', 'Utility', 'Minigames', 'Legit', 'Kits', 'Overlays'}
	for _, name in standardCategories do aether:CreateCategory({Name = name}) end
	aether.Legit = aether.Categories.Legit
	aether.Kits = aether.Categories.Kits

	local function simpleToggle(default)
		local toggle = {Enabled = default and true or false, Object = Instance.new('Frame')}
		function toggle:SetValue(value) self.Enabled = value and true or false end
		function toggle:Toggle() self.Enabled = not self.Enabled end
		return toggle
	end
	local function simpleColor()
		return {Hue = 0.7559, Sat = 0.56, Value = 1, Opacity = 1, Object = Instance.new('Frame')}
	end
	local mainCategory = {Type = 'Settings', Name = 'Main', Modules = {}, Options = {
		['Teams by server'] = simpleToggle(false),
		['Use team color'] = simpleToggle(true)
	}}
	local friends = {
		Type = 'List', Name = 'Friends', Modules = {}, List = {}, ListEnabled = {},
		Options = {
			['Use friends'] = simpleToggle(true),
			['Recolor visuals'] = simpleToggle(true),
			['Friends color'] = simpleColor()
		},
		Update = newSignal(), ColorUpdate = newSignal()
	}
	local targets = {Type = 'List', Name = 'Targets', Modules = {}, List = {}, ListEnabled = {}, Options = {}, Update = newSignal()}
	aether.Categories.Main = mainCategory
	aether.Categories.Friends = friends
	aether.Categories.Targets = targets

	function aether:CreateOverlay(settings)
		settings = settings or {}
		local overlay = attachMaid({Name = settings.Name or 'Overlay', Options = {}})
		local hud = Instance.new('Frame')
		hud.Name = overlay.Name:gsub('%s+', '')..'HUD'
		hud.Position = settings.Position or UDim2.fromOffset(210, 120)
		hud.Size = settings.CategorySize and UDim2.fromOffset(settings.CategorySize, settings.CategorySize) or UDim2.fromOffset(220, 220)
		hud.BackgroundTransparency = 1
		hud.Visible = false
		hud.Parent = scaledGui
		overlay.Children = hud
		local button = createModule(aether.Categories.Overlays, {
			Name = overlay.Name,
			Tooltip = settings.Tooltip or 'Heads-up display overlay',
			Function = function(enabled)
				hud.Visible = enabled
				if not enabled then overlay:Clean() end
				local ok, err = protectCall(settings.Function or function() end, enabled)
				if not ok then reportError(overlay.Name, err) end
			end
		})
		overlay.Button = button
		overlay.Options = button.Options
		for name, factory in optionFactories do
			overlay['Create'..name] = function(_, optionSettings)
				local result = factory(button, optionSettings or {})
				overlay.Options = button.Options
				return result
			end
		end
		makeDraggable(hud, hud, function(resource) return button:Clean(resource) end)
		return overlay
	end

	function aether:Remove(name)
		local module = self.Modules[name]
		if not module then return end
		if module.Enabled then module:Toggle(true) end
		module:Clean()
		if module.Children then module.Children:Destroy() end
		if module.Object then module.Object:Destroy() end
		local category = self.Categories[module.Category]
		if category and category.Modules then category.Modules[name] = nil end
		self.Modules[name] = nil
		if selectedModule == module then selectModule(nil) end
	end

	function aether:UpdateTextGUI() end
	function aether:BlurCheck() end
	function aether:SortModules() self:RefreshModules() end
	function aether:Color(hue) return hue, 1, 1 end
	function aether:TextColor() return Color3.new(1, 1, 1) end

	local colorLibrary = {Light = colorLight, Dark = colorDark}
	local tweenLibrary = {tweens = {}, tweenstwo = {}}
	function tweenLibrary:Tween(object, info, properties)
		if not object or not object.Parent then return end
		local tween = TweenService:Create(object, info or TweenInfo.new(0.16), properties)
		tween:Play()
		return tween
	end
	function tweenLibrary:Cancel() end

	local targetInfo = {Targets = {}}
	local sessionInfo = {Objects = {}}
	function sessionInfo:AddItem(name, startValue, formatter, saved)
		formatter = formatter or tostring
		self.Objects[name] = {Value = startValue or 0, Function = formatter, Saved = saved ~= false, Index = 1}
		return {
			Increment = function(_, amount) self.Objects[name].Value += amount or 1 end,
			Get = function() return self.Objects[name].Value end
		}
	end

	local function getTextSize(text, size, font, bounds)
		bounds = bounds or Vector2.new(100000, 100000)
		local ok, result = pcall(function()
			if typeof(font) == 'Font' then
				local params = Instance.new('GetTextBoundsParams')
				params.Text = tostring(text)
				params.Size = size or 14
				params.Font = font
				params.Width = bounds.X
				local measured = TextService:GetTextBoundsAsync(params)
				params:Destroy()
				return measured
			end
			return TextService:GetTextSize(tostring(text), size or 14, font or Enum.Font.Gotham, bounds)
		end)
		return ok and result or Vector2.new(#tostring(text) * (size or 14) * 0.55, size or 14)
	end

	local assetMap = {
		['aetherv2/assets/new/close.png'] = 'rbxassetid://14368309446',
		['aetherv2/assets/new/closemini.png'] = 'rbxassetid://14368310467',
		['aetherv2/assets/new/search.png'] = 'rbxassetid://14425646684',
		['aetherv2/assets/new/add.png'] = 'rbxassetid://14368300605',
		['aetherv2/assets/new/blur.png'] = 'rbxassetid://14898786664',
		['aetherv2/assets/new/range.png'] = 'rbxassetid://14368347435'
	}
	local function resolveAsset(path)
		if assetFunction and isFile(path) then
			local ok, result = pcall(assetFunction, path)
			if ok then return result end
		end
		return assetMap[path] or ''
	end

	aether.Libraries.uipallet = {
		Main = SURFACE,
		Text = TEXT,
		Font = safeFont(),
		FontSemiBold = Font.fromEnum(Enum.Font.GothamBold),
		Tween = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	}
	aether.Libraries.color = colorLibrary
	aether.Libraries.tween = tweenLibrary
	aether.Libraries.targetinfo = targetInfo
	aether.Libraries.sessioninfo = sessionInfo
	aether.Libraries.getfontsize = getTextSize
	aether.Libraries.getcustomasset = resolveAsset

	function aether:ReadResource(path)
		if type(config.Read) == 'function' then
			local ok, result = protectCall(config.Read, path)
			if ok and type(result) == 'string' then return result end
		end
		if isFile(path) then return readfile(path) end
		local relative = path:gsub('^aetherv2/', '')
		local localPath = self.SourceRoot:gsub('/$', '')..'/'..relative
		if isFile(localPath) then return readfile(localPath) end
		local source = game:HttpGet(self.RawBase..relative, true)
		if writefile then
			pcall(function()
				local directory = localPath:match('^(.*)/[^/]+$')
				if directory and makefolder then
					local current = ''
					for segment in directory:gmatch('[^/]+') do
						current = current == '' and segment or current..'/'..segment
						if not isfolder or not isfolder(current) then pcall(makefolder, current) end
					end
				end
				writefile(localPath, source)
			end)
		end
		return source
	end

	local profilePath = config.ProfilePath or 'aetherv2-standalone/profile.json'
	local function serializeOption(option)
		if option.Type == 'Toggle' then return {Enabled = option.Enabled} end
		if option.Type == 'Slider' or option.Type == 'Dropdown' or option.Type == 'TextBox' then return {Value = option.Value} end
		if option.Type == 'TwoSlider' then return {ValueMin = option.ValueMin, ValueMax = option.ValueMax} end
		if option.Type == 'TextList' then return {List = option.List, ListEnabled = option.ListEnabled} end
		if option.Type == 'ColorSlider' then return {Hue = option.Hue, Sat = option.Sat, Value = option.Value, Opacity = option.Opacity, Rainbow = option.Rainbow} end
		if option.Type == 'Targets' then return {Players = option.Players.Enabled, NPCs = option.NPCs.Enabled, Walls = option.Walls.Enabled} end
		if option.Type == 'Font' then return {Value = option.FontName} end
		if type(option.Save) == 'function' then
			local container = {}
			local ok = pcall(option.Save, option, container)
			if ok then return container[option.Name] or container[option.Type] or container.HotbarList or container end
		end
		return nil
	end

	local function applyOption(option, data)
		if type(data) ~= 'table' then return end
		if option.Type == 'Toggle' then option:SetValue(data.Enabled, false)
		elseif option.Type == 'Slider' or option.Type == 'Dropdown' or option.Type == 'TextBox' then option:SetValue(data.Value)
		elseif option.Type == 'TwoSlider' then option:SetValue(data.ValueMin, data.ValueMax, true)
		elseif option.Type == 'TextList' then
			option.List, option.ListEnabled = shallowCopy(data.List or {}), shallowCopy(data.ListEnabled or data.List or {})
			option:ChangeValue()
		elseif option.Type == 'ColorSlider' then
			option:SetValue(data.Hue, data.Sat, data.Value, data.Opacity)
			if data.Rainbow ~= option.Rainbow then option:Toggle() end
		elseif option.Type == 'Targets' then
			option.Players:SetValue(data.Players, true)
			option.NPCs:SetValue(data.NPCs, true)
			option.Walls:SetValue(data.Walls, true)
		elseif option.Type == 'Font' then option:SetValue(data.Value)
		elseif type(option.Load) == 'function' then pcall(option.Load, option, data) end
	end

	function aether:Save()
		if not writefile then return false end
		local data = {Version = self.Version, Profile = self.Profile, Modules = {}}
		for name, module in self.Modules do
			local moduleData = {Enabled = module.Enabled, Bind = module.Bind, Options = {}}
			for optionName, option in module.Options do
				local value = serializeOption(option)
				if value ~= nil then moduleData.Options[optionName] = value end
			end
			data.Modules[name] = moduleData
		end
		local ok, encoded = pcall(HttpService.JSONEncode, HttpService, data)
		if not ok then return false end
		pcall(function()
			if makefolder and (not isfolder or not isfolder('aetherv2-standalone')) then makefolder('aetherv2-standalone') end
			writefile(profilePath, encoded)
		end)
		return true
	end

	function aether:Load(_, profile)
		if profile then self.Profile = profile end
		if not isFile(profilePath) then return false end
		local ok, data = pcall(function() return HttpService:JSONDecode(readfile(profilePath)) end)
		if not ok or type(data) ~= 'table' then return false end
		loadingProfile = true
		for name, moduleData in data.Modules or {} do
			local module = self.Modules[name]
			if module then
				module:SetBind(moduleData.Bind or {})
				for optionName, optionData in moduleData.Options or {} do
					local option = module.Options[optionName]
					if option then pcall(applyOption, option, optionData) end
				end
			end
		end
		for name, moduleData in data.Modules or {} do
			local module = self.Modules[name]
			if module and module.Enabled ~= (moduleData.Enabled and true or false) then module:Toggle(true) end
		end
		loadingProfile = false
		self:RefreshModules()
		return true
	end

	function aether:FinishLoading()
		self.Loaded = true
		self:Load()
		refreshCategoryButtons()
		self:RefreshModules()
		self:CreateNotification('Aether Standalone', tostring(#categoryOrder)..' categories ready', 2)
	end

	function aether:Uninject()
		if not alive then return end
		pcall(function() self:Save() end)
		for _, module in self.Modules do
			if module.Enabled then pcall(module.Toggle, module, true) end
			module:Clean()
		end
		alive = false
		if self.Libraries.entity and self.Libraries.entity.kill then pcall(self.Libraries.entity.kill) end
		self:Clean()
		if screen.Parent then screen:Destroy() end
		shared.AetherStandalone = nil
		if getgenv then getgenv().AetherStandalone = nil end
		self.Loaded = nil
	end

	closeButton.MouseButton1Click:Connect(function() aether:Uninject() end)
	minimizeButton.MouseButton1Click:Connect(function() clickGui.Visible = false end)
	detailToggle.MouseButton1Click:Connect(function() if selectedModule then selectedModule:Toggle() end end)
	search:GetPropertyChangedSignal('Text'):Connect(function() aether:RefreshModules() end)

	clean(UserInputService.InputBegan:Connect(function(input, processed)
		if processed or UserInputService:GetFocusedTextBox() then return end
		if input.KeyCode == Enum.KeyCode.RightShift then
			clickGui.Visible = not clickGui.Visible
			return
		end
		local keyName = input.KeyCode.Name
		for _, module in aether.Modules do
			if table.find(module.Bind, keyName) then module:Toggle() end
		end
	end))

	clean(game:GetService('RunService').Heartbeat:Connect(function()
		if #aether.RainbowTable == 0 then return end
		local hue = (os.clock() * 0.12 * (aether.RainbowSpeed.Value or 1)) % 1
		for _, option in aether.RainbowTable do
			if option and option.Rainbow then option:SetValue(hue, option.Sat, option.Value, option.Opacity, false) end
		end
	end))

	refreshCategoryButtons()
	aether:RefreshModules()
	return aether
end

return Runtime

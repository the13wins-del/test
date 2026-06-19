--[[
	====================================================================
	  OP UI LIBRARY — Custom Roblox UI Framework
	====================================================================

	HOW TO INSTALL:
	  1. Create a ModuleScript in ReplicatedStorage, name it "OPUILibrary"
	  2. Paste this entire file into it
	  3. require() it from a LocalScript (see Example.lua)

	HOW TO USE (quick reference):
	  local UILibrary = require(ReplicatedStorage.OPUILibrary)
	  local Window = UILibrary:CreateWindow({ Title = "My Hub" })
	  local Tab = Window:CreateTab("Main")
	  Tab:CreateButton({ Text = "Click me", Callback = function() end })
	  Tab:CreateToggle({ Text = "Enable", Default = false, Callback = function(state) end })
	  Tab:CreateSlider({ Text = "Speed", Min = 0, Max = 100, Default = 16, Callback = function(v) end })
	  Tab:CreateDropdown({ Text = "Mode", Options = {"A","B"}, Default = "A", Callback = function(v) end })
	  Tab:CreateTextbox({ Text = "Name", Placeholder = "Type...", Callback = function(text) end })
	  Tab:CreateKeybind({ Text = "Fly Key", Default = Enum.KeyCode.F, Callback = function(key) end })
	  Window:Notify({ Title = "Hi", Content = "Loaded!", Duration = 3 })

	All default behavior is controlled by the Library.Config table right
	below — flip any value to true/false to enable or disable it.
	====================================================================
]]

local TweenService   = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players      = game:GetService("Players")
local Lighting      = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local PlayerGui  = LocalPlayer:WaitForChild("PlayerGui")
local Camera    = workspace.CurrentCamera

----------------------------------------------------------------------
-- LIBRARY TABLE + DEFAULT CONFIG  (toggle these true/false as you like)
----------------------------------------------------------------------
local Library = {}
Library.__index = Library

Library.Config = {
	Draggable      = true,                    -- [bool] window can be dragged by its top bar
	ToggleButton     = true,                    -- [bool] floating button that opens/closes the UI
	ToggleKeybind     = Enum.KeyCode.RightControl,    -- [KeyCode] PC keybind that opens/closes the UI
	Animations      = true,                    -- [bool] master switch for all tween animations
	AnimationSpeed    = 0.22,                    -- [number] seconds, default tween duration
	AutoDeviceSupport  = true,                    -- [bool] auto-detect mobile/PC and rescale UI
	BlurBackground    = false,                   -- [bool] blur the game behind the menu while open
	StartOpen       = true,                    -- [bool] window visible immediately on load

	Theme = {
		Main      = Color3.fromRGB(22, 22, 27),
		Secondary  = Color3.fromRGB(30, 30, 36),
		Elevated   = Color3.fromRGB(38, 38, 45),
		Accent     = Color3.fromRGB(99, 132, 255),
		Text      = Color3.fromRGB(235, 235, 240),
		SubText    = Color3.fromRGB(148, 148, 160),
		Stroke     = Color3.fromRGB(52, 52, 60),
	}
}

----------------------------------------------------------------------
-- INTERNAL HELPERS
----------------------------------------------------------------------
local function New(className, props)
	local inst = Instance.new(className)
	for prop, value in pairs(props) do
		if prop ~= "Parent" then
			inst[prop] = value
		end
	end
	if props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local function Tween(obj, info, props)
	if not Library.Config.Animations then
		for k, v in pairs(props) do obj[k] = v end
		return
	end
	local tw = TweenService:Create(obj, info, props)
	tw:Play()
	return tw
end

local function QuickTween(obj, props, time)
	return Tween(obj, TweenInfo.new(time or Library.Config.AnimationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
end

local function IsMobile()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function GetScale()
	local vp = Camera.ViewportSize
	return math.clamp(vp.X / 1280, 0.65, 1.05)
end

local function MakeDraggable(frame, handle)
	if not Library.Config.Draggable then return end
	handle = handle or frame
	local dragging, dragStart, startPos = false, nil, nil

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

----------------------------------------------------------------------
-- WINDOW CREATION
----------------------------------------------------------------------
function Library:CreateWindow(settings)
	settings = settings or {}
	for key, value in pairs(settings) do
		if Library.Config[key] ~= nil then
			Library.Config[key] = value
		end
	end

	local Theme = Library.Config.Theme
	local Title = settings.Title or "OP UI"
	local SubTitle = settings.SubTitle or ""
	local mobile = IsMobile()
	local scale = Library.Config.AutoDeviceSupport and GetScale() or 1
	local sidebarWidth = mobile and 90 or 130

	local ScreenGui = New("ScreenGui", {
		Name = "OPUILibrary",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = PlayerGui,
	})

	local WindowWidth = mobile and 380 or 560
	local WindowHeight = mobile and 460 or 380

	local Main = New("Frame", {
		Name = "Main",
		Size = UDim2.fromOffset(WindowWidth, WindowHeight),
		Position = UDim2.new(0.5, -WindowWidth / 2, 0.5, -WindowHeight / 2),
		BackgroundColor3 = Theme.Main,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = ScreenGui,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = Main })
	New("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = Main })
	local MainScale = New("UIScale", { Scale = scale, Parent = Main })

	-- Top bar
	local TopBar = New("Frame", {
		Name = "TopBar",
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		Parent = Main,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 12), Parent = TopBar })
	New("Frame", {
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.new(0, 0, 1, -12),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		Parent = TopBar,
	})

	New("TextLabel", {
		Text = Title,
		Font = Enum.Font.GothamBold,
		TextSize = 16,
		TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 4),
		Size = UDim2.new(1, -100, 0, 20),
		Parent = TopBar,
	})
	New("TextLabel", {
		Text = SubTitle,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = Theme.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(16, 22),
		Size = UDim2.new(1, -100, 0, 16),
		Parent = TopBar,
	})

	local CloseBtn = New("TextButton", {
		Text = "×",
		Font = Enum.Font.GothamBold,
		TextSize = 20,
		TextColor3 = Theme.SubText,
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(32, 32),
		Position = UDim2.new(1, -38, 0, 6),
		Parent = TopBar,
	})

	MakeDraggable(Main, TopBar)

	-- Sidebar (tab list)
	local Sidebar = New("Frame", {
		Name = "Sidebar",
		Size = UDim2.new(0, sidebarWidth, 1, -44),
		Position = UDim2.fromOffset(0, 44),
		BackgroundColor3 = Theme.Secondary,
		BorderSizePixel = 0,
		Parent = Main,
	})
	New("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = Sidebar })
	New("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), Parent = Sidebar })

	-- Content area (holds each tab's page)
	local Content = New("Frame", {
		Name = "Content",
		Size = UDim2.new(1, -sidebarWidth, 1, -44),
		Position = UDim2.new(0, sidebarWidth, 0, 44),
		BackgroundTransparency = 1,
		Parent = Main,
	})

	-- Notifications
	local NotifyHolder = New("Frame", {
		Name = "Notifications",
		Size = UDim2.fromOffset(280, 500),
		Position = UDim2.new(1, -296, 0, 16),
		BackgroundTransparency = 1,
		Parent = ScreenGui,
	})
	New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = NotifyHolder })

	-- Optional background blur
	local Blur
	if Library.Config.BlurBackground then
		Blur = New("BlurEffect", { Size = 0, Parent = Lighting })
		QuickTween(Blur, { Size = 18 }, 0.3)
	end

	-- Floating open/close toggle button
	local ToggleBtn
	if Library.Config.ToggleButton then
		ToggleBtn = New("TextButton", {
			Name = "ToggleButton",
			Text = "≡",
			Font = Enum.Font.GothamBold,
			TextSize = 22,
			TextColor3 = Theme.Text,
			BackgroundColor3 = Theme.Accent,
			Size = UDim2.fromOffset(46, 46),
			Position = UDim2.new(0, 16, 0, mobile and 90 or 16),
			Parent = ScreenGui,
		})
		New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = ToggleBtn })
		MakeDraggable(ToggleBtn)
	end

	local Window = setmetatable({
		ScreenGui = ScreenGui,
		Main = Main,
		Sidebar = Sidebar,
		Content = Content,
		NotifyHolder = NotifyHolder,
		Blur = Blur,
		Tabs = {},
		ActiveTab = nil,
		_open = true,
		_scale = scale,
	}, Library)

	CloseBtn.MouseButton1Click:Connect(function()
		Window:Close()
	end)

	if ToggleBtn then
		ToggleBtn.MouseButton1Click:Connect(function()
			Window:Toggle()
		end)
	end

	if not mobile then
		UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if input.KeyCode == Library.Config.ToggleKeybind then
				Window:Toggle()
			end
		end)
	end

	if Library.Config.AutoDeviceSupport then
		Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			local s = GetScale()
			Window._scale = s
			QuickTween(MainScale, { Scale = s }, 0.2)
		end)
	end

	if not Library.Config.StartOpen then
		Window._open = false
		Main.Visible = false
	end

	return Window
end

----------------------------------------------------------------------
-- WINDOW METHODS
----------------------------------------------------------------------
function Library:Toggle(force)
	local open = (force ~= nil) and force or not self._open
	self._open = open
	local uiScale = self.Main:FindFirstChildOfClass("UIScale")

	if open then
		self.Main.Visible = true
		if uiScale then
			uiScale.Scale = 0
			TweenService:Create(uiScale, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = self._scale }):Play()
		end
	else
		if uiScale and Library.Config.Animations then
			TweenService:Create(uiScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0 }):Play()
			task.delay(0.18, function()
				if not self._open then self.Main.Visible = false end
			end)
		else
			self.Main.Visible = false
		end
	end
end

function Library:Open() self:Toggle(true) end
function Library:Close() self:Toggle(false) end

function Library:Destroy()
	if self.Blur then self.Blur:Destroy() end
	self.ScreenGui:Destroy()
end

----------------------------------------------------------------------
-- TABS
----------------------------------------------------------------------
function Library:CreateTab(name, icon)
	local Theme = Library.Config.Theme
	local mobile = IsMobile()

	local TabButton = New("TextButton", {
		Name = name .. "_TabBtn",
		Text = (icon and (icon .. "  ") or "") .. name,
		Font = Enum.Font.GothamMedium,
		TextSize = mobile and 13 or 14,
		TextColor3 = Theme.SubText,
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 34),
		Parent = self.Sidebar,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = TabButton })

	local TabContent = New("ScrollingFrame", {
		Name = name .. "_Content",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Visible = false,
		Parent = self.Content,
	})
	New("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = TabContent })
	New("UIPadding", {
		PaddingTop = UDim.new(0, 12), PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12),
		Parent = TabContent,
	})
	local ContentScale = New("UIScale", { Scale = 1, Parent = TabContent })

	local Tab = setmetatable({
		Window = self,
		Button = TabButton,
		Content = TabContent,
		ContentScale = ContentScale,
	}, { __index = Library })

	table.insert(self.Tabs, Tab)

	TabButton.MouseButton1Click:Connect(function()
		self:SelectTab(Tab)
	end)
	TabButton.MouseEnter:Connect(function()
		if self.ActiveTab ~= Tab then QuickTween(TabButton, { BackgroundTransparency = 0.5 }, 0.15) end
	end)
	TabButton.MouseLeave:Connect(function()
		if self.ActiveTab ~= Tab then QuickTween(TabButton, { BackgroundTransparency = 1 }, 0.15) end
	end)

	if not self.ActiveTab then
		self:SelectTab(Tab)
	end

	return Tab
end

function Library:SelectTab(tab)
	for _, t in ipairs(self.Tabs) do
		t.Content.Visible = false
		QuickTween(t.Button, { BackgroundTransparency = 1 }, 0.15)
	end
	tab.Content.Visible = true
	QuickTween(tab.Button, { BackgroundTransparency = 0 }, 0.15)
	self.ActiveTab = tab

	tab.ContentScale.Scale = 0.96
	TweenService:Create(tab.ContentScale, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
end

----------------------------------------------------------------------
-- ELEMENTS  (call these on a Tab, e.g. MyTab:CreateButton{...})
----------------------------------------------------------------------
function Library:CreateSection(text)
	local Theme = Library.Config.Theme
	return New("TextLabel", {
		Text = text or "Section",
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextColor3 = Theme.Accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 22),
		Parent = self.Content,
	})
end

function Library:CreateLabel(text)
	local Theme = Library.Config.Theme
	return New("TextLabel", {
		Text = text or "",
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = Theme.SubText,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.new(1, 0, 0, 18),
		Parent = self.Content,
	})
end

function Library:CreateButton(opts)
	opts = opts or {}
	local Theme = Library.Config.Theme

	local Btn = New("TextButton", {
		Text = opts.Text or "Button",
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextColor3 = Theme.Text,
		BackgroundColor3 = Theme.Elevated,
		AutoButtonColor = false,
		Size = UDim2.new(1, 0, 0, 36),
		Parent = self.Content,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Btn })
	New("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = Btn })

	Btn.MouseEnter:Connect(function() QuickTween(Btn, { BackgroundColor3 = Theme.Accent }, 0.15) end)
	Btn.MouseLeave:Connect(function() QuickTween(Btn, { BackgroundColor3 = Theme.Elevated }, 0.15) end)
	Btn.MouseButton1Down:Connect(function() QuickTween(Btn, { Size = UDim2.new(1, -6, 0, 34) }, 0.08) end)
	Btn.MouseButton1Up:Connect(function() QuickTween(Btn, { Size = UDim2.new(1, 0, 0, 36) }, 0.08) end)
	Btn.MouseButton1Click:Connect(function()
		if opts.Callback then task.spawn(opts.Callback) end
	end)

	return { Instance = Btn }
end

function Library:CreateToggle(opts)
	opts = opts or {}
	local Theme = Library.Config.Theme
	local state = opts.Default or false

	local Holder = New("Frame", { BackgroundColor3 = Theme.Elevated, Size = UDim2.new(1, 0, 0, 36), Parent = self.Content })
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Holder })
	New("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = Holder })

	New("TextLabel", {
		Text = opts.Text or "Toggle", Font = Enum.Font.GothamMedium, TextSize = 14,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -70, 1, 0), Parent = Holder,
	})

	local Switch = New("Frame", {
		Size = UDim2.fromOffset(40, 22), Position = UDim2.new(1, -52, 0.5, -11),
		BackgroundColor3 = state and Theme.Accent or Theme.Stroke, Parent = Holder,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Switch })

	local Knob = New("Frame", {
		Size = UDim2.fromOffset(18, 18),
		Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
		BackgroundColor3 = Color3.new(1, 1, 1), Parent = Switch,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })

	local Click = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = Holder })

	local function setState(newState, fire)
		state = newState
		QuickTween(Switch, { BackgroundColor3 = state and Theme.Accent or Theme.Stroke }, 0.15)
		QuickTween(Knob, { Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9) }, 0.15)
		if fire and opts.Callback then task.spawn(opts.Callback, state) end
	end

	Click.MouseButton1Click:Connect(function() setState(not state, true) end)

	return {
		Set = function(_, v) setState(v, true) end,
		Get = function() return state end,
		Instance = Holder,
	}
end

function Library:CreateSlider(opts)
	opts = opts or {}
	local Theme = Library.Config.Theme
	local min, max = opts.Min or 0, opts.Max or 100
	local value = math.clamp(opts.Default or min, min, max)

	local Holder = New("Frame", { BackgroundColor3 = Theme.Elevated, Size = UDim2.new(1, 0, 0, 50), Parent = self.Content })
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Holder })
	New("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = Holder })

	New("TextLabel", {
		Text = opts.Text or "Slider", Font = Enum.Font.GothamMedium, TextSize = 14,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 6),
		Size = UDim2.new(1, -24, 0, 16), Parent = Holder,
	})

	local ValueLabel = New("TextLabel", {
		Text = tostring(value), Font = Enum.Font.GothamBold, TextSize = 13,
		TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 6),
		Size = UDim2.new(1, -24, 0, 16), Parent = Holder,
	})

	local Track = New("Frame", {
		Size = UDim2.new(1, -24, 0, 6), Position = UDim2.fromOffset(12, 32),
		BackgroundColor3 = Theme.Stroke, Parent = Holder,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Track })

	local Fill = New("Frame", { Size = UDim2.new((value - min) / (max - min), 0, 1, 0), BackgroundColor3 = Theme.Accent, Parent = Track })
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Fill })

	local Knob = New("Frame", {
		Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
		BackgroundColor3 = Color3.new(1, 1, 1), Parent = Track,
	})
	New("UICorner", { CornerRadius = UDim.new(1, 0), Parent = Knob })

	local dragging = false
	local function update(input)
		local relative = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
		value = math.floor(min + (max - min) * relative + 0.5)
		Fill.Size = UDim2.new(relative, 0, 1, 0)
		Knob.Position = UDim2.new(relative, 0, 0.5, 0)
		ValueLabel.Text = tostring(value)
		if opts.Callback then task.spawn(opts.Callback, value) end
	end

	Track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			update(input)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return {
		Set = function(_, v)
			value = math.clamp(v, min, max)
			local relative = (value - min) / (max - min)
			Fill.Size = UDim2.new(relative, 0, 1, 0)
			Knob.Position = UDim2.new(relative, 0, 0.5, 0)
			ValueLabel.Text = tostring(value)
		end,
		Get = function() return value end,
		Instance = Holder,
	}
end

function Library:CreateDropdown(opts)
	opts = opts or {}
	local Theme = Library.Config.Theme
	local options = opts.Options or {}
	local selected = opts.Default or options[1]
	local open = false

	local Holder = New("Frame", {
		BackgroundColor3 = Theme.Elevated, Size = UDim2.new(1, 0, 0, 36),
		ClipsDescendants = true, Parent = self.Content,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Holder })
	New("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = Holder })

	local Head = New("TextButton", { Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 36), Parent = Holder })

	local Label = New("TextLabel", {
		Text = (opts.Text or "Dropdown") .. ": " .. tostring(selected),
		Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Theme.Text,
		TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -36, 0, 36), Parent = Head,
	})

	local Arrow = New("TextLabel", {
		Text = "▾", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = Theme.SubText,
		BackgroundTransparency = 1, Position = UDim2.new(1, -28, 0, 0),
		Size = UDim2.fromOffset(20, 36), Parent = Head,
	})

	local List = New("Frame", {
		Position = UDim2.fromOffset(0, 36), Size = UDim2.new(1, 0, 0, #options * 30),
		BackgroundTransparency = 1, Parent = Holder,
	})
	New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = List })

	local function closeDropdown()
		open = false
		QuickTween(Holder, { Size = UDim2.new(1, 0, 0, 36) }, 0.18)
		QuickTween(Arrow, { Rotation = 0 }, 0.18)
	end

	for _, opt in ipairs(options) do
		local OptBtn = New("TextButton", {
			Text = tostring(opt), Font = Enum.Font.Gotham, TextSize = 13,
			TextColor3 = Theme.SubText, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30), Parent = List,
		})
		OptBtn.MouseButton1Click:Connect(function()
			selected = opt
			Label.Text = (opts.Text or "Dropdown") .. ": " .. tostring(selected)
			if opts.Callback then task.spawn(opts.Callback, selected) end
			closeDropdown()
		end)
		OptBtn.MouseEnter:Connect(function() QuickTween(OptBtn, { TextColor3 = Theme.Text }, 0.1) end)
		OptBtn.MouseLeave:Connect(function() QuickTween(OptBtn, { TextColor3 = Theme.SubText }, 0.1) end)
	end

	Head.MouseButton1Click:Connect(function()
		open = not open
		local targetH = open and (36 + #options * 30) or 36
		QuickTween(Holder, { Size = UDim2.new(1, 0, 0, targetH) }, 0.2)
		QuickTween(Arrow, { Rotation = open and 180 or 0 }, 0.2)
	end)

	return {
		Set = function(_, v) selected = v; Label.Text = (opts.Text or "Dropdown") .. ": " .. tostring(selected) end,
		Get = function() return selected end,
		Instance = Holder,
	}
end

function Library:CreateTextbox(opts)
	opts = opts or {}
	local Theme = Library.Config.Theme

	local Holder = New("Frame", { BackgroundColor3 = Theme.Elevated, Size = UDim2.new(1, 0, 0, 36), Parent = self.Content })
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Holder })
	New("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = Holder })

	local Box = New("TextBox", {
		Text = "", PlaceholderText = opts.Placeholder or opts.Text or "Enter text...",
		Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = Theme.Text,
		PlaceholderColor3 = Theme.SubText, ClearTextOnFocus = false,
		BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 1, 0), Parent = Holder,
	})

	Box.Focused:Connect(function() QuickTween(Holder, { BackgroundColor3 = Theme.Secondary }, 0.15) end)
	Box.FocusLost:Connect(function(enterPressed)
		QuickTween(Holder, { BackgroundColor3 = Theme.Elevated }, 0.15)
		if opts.Callback then task.spawn(opts.Callback, Box.Text, enterPressed) end
	end)

	return {
		Set = function(_, v) Box.Text = v end,
		Get = function() return Box.Text end,
		Instance = Holder,
	}
end

function Library:CreateKeybind(opts)
	opts = opts or {}
	local Theme = Library.Config.Theme
	local current = opts.Default or Enum.KeyCode.Unknown
	local listening = false

	local Holder = New("Frame", { BackgroundColor3 = Theme.Elevated, Size = UDim2.new(1, 0, 0, 36), Parent = self.Content })
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Holder })
	New("UIStroke", { Color = Theme.Stroke, Thickness = 1, Parent = Holder })

	New("TextLabel", {
		Text = opts.Text or "Keybind", Font = Enum.Font.GothamMedium, TextSize = 14,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1, Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -90, 1, 0), Parent = Holder,
	})

	local KeyBtn = New("TextButton", {
		Text = current.Name, Font = Enum.Font.GothamBold, TextSize = 13,
		TextColor3 = Theme.Accent, BackgroundColor3 = Theme.Secondary,
		Size = UDim2.fromOffset(70, 26), Position = UDim2.new(1, -82, 0.5, -13), Parent = Holder,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 6), Parent = KeyBtn })

	KeyBtn.MouseButton1Click:Connect(function()
		listening = true
		KeyBtn.Text = "..."
	end)

	UserInputService.InputBegan:Connect(function(input, gpe)
		if listening and input.UserInputType == Enum.UserInputType.Keyboard then
			current = input.KeyCode
			KeyBtn.Text = current.Name
			listening = false
			if opts.Callback then task.spawn(opts.Callback, current) end
		elseif not listening and not gpe and input.KeyCode == current then
			if opts.Pressed then task.spawn(opts.Pressed) end
		end
	end)

	return {
		Set = function(_, kc) current = kc; KeyBtn.Text = kc.Name end,
		Get = function() return current end,
		Instance = Holder,
	}
end

----------------------------------------------------------------------
-- NOTIFICATIONS
----------------------------------------------------------------------
function Library:Notify(opts)
	opts = opts or {}
	local Theme = Library.Config.Theme
	local duration = opts.Duration or 3

	local Notif = New("Frame", {
		BackgroundColor3 = Theme.Elevated, Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y, Position = UDim2.new(1.2, 0, 0, 0),
		Parent = self.NotifyHolder,
	})
	New("UICorner", { CornerRadius = UDim.new(0, 8), Parent = Notif })
	New("UIStroke", { Color = Theme.Accent, Thickness = 1, Parent = Notif })
	New("UIPadding", {
		PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12), Parent = Notif,
	})

	New("TextLabel", {
		Text = opts.Title or "Notification", Font = Enum.Font.GothamBold, TextSize = 14,
		TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 18), Parent = Notif,
	})
	New("TextLabel", {
		Text = opts.Content or "", Font = Enum.Font.Gotham, TextSize = 12,
		TextColor3 = Theme.SubText, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 20),
		AutomaticSize = Enum.AutomaticSize.Y, Size = UDim2.new(1, 0, 0, 0), Parent = Notif,
	})

	QuickTween(Notif, { Position = UDim2.new(0, 0, 0, 0) }, 0.25)
	task.delay(duration, function()
		QuickTween(Notif, { Position = UDim2.new(1.2, 0, 0, 0) }, 0.25)
		task.delay(0.3, function() Notif:Destroy() end)
	end)
end

return Library

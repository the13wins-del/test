local Library = {}
Library.__index = Library

local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local HTTP = game:GetService("HttpService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Themes = {
    Dark = {Bg = Color3.fromRGB(12, 12, 16),Card = Color3.fromRGB(18, 18, 24),Elevated = Color3.fromRGB(26, 26, 34),Border = Color3.fromRGB(38, 38, 48),Accent = Color3.fromRGB(88, 101, 242),AccentAlt = Color3.fromRGB(110, 123, 255),Text = Color3.fromRGB(255, 255, 255),TextSub = Color3.fromRGB(148, 155, 164),TextMuted = Color3.fromRGB(96, 100, 108),Green = Color3.fromRGB(59, 165, 93),Red = Color3.fromRGB(237, 66, 69),},
    Crimson = {Bg = Color3.fromRGB(14, 8, 8),Card = Color3.fromRGB(24, 12, 12),Elevated = Color3.fromRGB(36, 18, 18),Border = Color3.fromRGB(60, 28, 28),Accent = Color3.fromRGB(220, 50, 50),AccentAlt = Color3.fromRGB(255, 80, 80),Text = Color3.fromRGB(255, 240, 240),TextSub = Color3.fromRGB(180, 140, 140),TextMuted = Color3.fromRGB(120, 90, 90),Green = Color3.fromRGB(59, 165, 93),Red = Color3.fromRGB(237, 66, 69),},
    Emerald = {Bg = Color3.fromRGB(6, 14, 10),Card = Color3.fromRGB(10, 22, 16),Elevated = Color3.fromRGB(16, 34, 24),Border = Color3.fromRGB(26, 56, 38),Accent = Color3.fromRGB(52, 199, 120),AccentAlt = Color3.fromRGB(80, 230, 150),Text = Color3.fromRGB(240, 255, 245),TextSub = Color3.fromRGB(140, 180, 155),TextMuted = Color3.fromRGB(90, 130, 105),Green = Color3.fromRGB(59, 200, 93),Red = Color3.fromRGB(237, 66, 69),},
    Ocean = {Bg = Color3.fromRGB(6, 12, 20),Card = Color3.fromRGB(10, 20, 34),Elevated = Color3.fromRGB(14, 30, 50),Border = Color3.fromRGB(22, 50, 80),Accent = Color3.fromRGB(30, 140, 220),AccentAlt = Color3.fromRGB(60, 180, 255),Text = Color3.fromRGB(220, 240, 255),TextSub = Color3.fromRGB(120, 160, 200),TextMuted = Color3.fromRGB(70, 110, 150),Green = Color3.fromRGB(59, 165, 93),Red = Color3.fromRGB(237, 66, 69),},
    Violet = {Bg = Color3.fromRGB(10, 6, 18),Card = Color3.fromRGB(16, 10, 28),Elevated = Color3.fromRGB(26, 16, 44),Border = Color3.fromRGB(44, 28, 72),Accent = Color3.fromRGB(168, 85, 247),AccentAlt = Color3.fromRGB(200, 120, 255),Text = Color3.fromRGB(245, 235, 255),TextSub = Color3.fromRGB(170, 140, 200),TextMuted = Color3.fromRGB(110, 85, 145),Green = Color3.fromRGB(59, 165, 93),Red = Color3.fromRGB(237, 66, 69),},
    Rose = {Bg = Color3.fromRGB(18, 8, 12),Card = Color3.fromRGB(28, 12, 18),Elevated = Color3.fromRGB(40, 18, 26),Border = Color3.fromRGB(65, 28, 40),Accent = Color3.fromRGB(240, 80, 130),AccentAlt = Color3.fromRGB(255, 110, 160),Text = Color3.fromRGB(255, 235, 242),TextSub = Color3.fromRGB(200, 150, 170),TextMuted = Color3.fromRGB(140, 95, 115),Green = Color3.fromRGB(59, 165, 93),Red = Color3.fromRGB(237, 66, 69),},
    Amber = {Bg = Color3.fromRGB(16, 12, 4),Card = Color3.fromRGB(26, 20, 6),Elevated = Color3.fromRGB(38, 30, 8),Border = Color3.fromRGB(62, 48, 12),Accent = Color3.fromRGB(245, 175, 25),AccentAlt = Color3.fromRGB(255, 205, 60),Text = Color3.fromRGB(255, 248, 220),TextSub = Color3.fromRGB(200, 175, 120),TextMuted = Color3.fromRGB(140, 118, 72),Green = Color3.fromRGB(59, 165, 93),Red = Color3.fromRGB(237, 66, 69),},
    Ice = {Bg = Color3.fromRGB(8, 14, 20),Card = Color3.fromRGB(14, 22, 32),Elevated = Color3.fromRGB(20, 32, 46),Border = Color3.fromRGB(34, 54, 76),Accent = Color3.fromRGB(120, 210, 240),AccentAlt = Color3.fromRGB(160, 235, 255),Text = Color3.fromRGB(220, 240, 255),TextSub = Color3.fromRGB(130, 170, 200),TextMuted = Color3.fromRGB(80, 115, 145),Green = Color3.fromRGB(59, 165, 93),Red = Color3.fromRGB(237, 66, 69),},
}

local ThemeOrder = {"Dark","Crimson","Emerald","Ocean","Violet","Rose","Amber","Ice"}

local Config = {ToggleKey = Enum.KeyCode.K,AnimSpeed = 0.15,SaveFile = "NexusData.json",Colors = {},CurrentTheme = "Dark",}

local function ApplyTheme(name)
    local t = Themes[name]
    if not t then return end
    Config.CurrentTheme = name
    for k, v in pairs(t) do Config.Colors[k] = v end
end
ApplyTheme("Dark")

local function Make(class, props)
    local ok, obj = pcall(Instance.new, class)
    if not ok then return nil end
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then pcall(function() obj[k] = v end) end
    end
    if props and props.Parent then pcall(function() obj.Parent = props.Parent end) end
    return obj
end

local function Tween(obj, props, t, style)
    if not obj then return end
    local tw = TS:Create(obj, TweenInfo.new(t or Config.AnimSpeed, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function Round(parent, radius)
    return Make("UICorner", {CornerRadius = UDim.new(0, radius or 6), Parent = parent})
end

local function Stroke(parent, color, thickness)
    return Make("UIStroke", {Color = color or Config.Colors.Border, Thickness = thickness or 1, Transparency = 0.5, Parent = parent})
end

local function Padding(parent, amount)
    return Make("UIPadding", {PaddingTop = UDim.new(0, amount),PaddingBottom = UDim.new(0, amount),PaddingLeft = UDim.new(0, amount),PaddingRight = UDim.new(0, amount),Parent = parent,})
end

local function Gradient(parent, c1, c2, rotation)
    return Make("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c1 or Config.Colors.Accent),ColorSequenceKeypoint.new(1, c2 or Config.Colors.AccentAlt),}),Rotation = rotation or 90,Parent = parent,})
end

local function AnimateGradient(gradient)
    if not gradient then return end
    local rot = 0
    RS.RenderStepped:Connect(function(dt)
        if not gradient or not gradient.Parent then return end
        rot = (rot + dt * 15) % 360
        gradient.Rotation = rot
    end)
end

local function SaveData(filename, data)
    if not writefile then warn("[Nexus] writefile unavailable") return end
    pcall(function() writefile(filename, HTTP:JSONEncode(data or {})) end)
end

local function LoadData(filename)
    if not (readfile and isfile) then warn("[Nexus] Filesystem limited") return {} end
    if not isfile(filename) then return {} end
    local ok, data = pcall(function() return HTTP:JSONDecode(readfile(filename)) end)
    return ok and data or {}
end

local ThemedObjects = {}

local function TrackThemed(obj, colorKey, prop)
    if not obj then return end
    table.insert(ThemedObjects, {obj = obj, key = colorKey, prop = prop or "BackgroundColor3"})
end

local function FlushThemed()
    for i = #ThemedObjects, 1, -1 do
        if not ThemedObjects[i].obj or not ThemedObjects[i].obj.Parent then table.remove(ThemedObjects, i) end
    end
end

local function RecolorAll(speed)
    FlushThemed()
    speed = speed or 0.5
    for _, entry in ipairs(ThemedObjects) do
        local color = Config.Colors[entry.key]
        if color and entry.obj and entry.obj.Parent then Tween(entry.obj, {[entry.prop] = color}, speed, Enum.EasingStyle.Sine) end
    end
end

function Library.Init(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, Library)
    self.Title = cfg.Title or "Nexus"
    self.ToggleKey = cfg.Key or Config.ToggleKey
    self.SaveFile = cfg.File or Config.SaveFile
    self.Data = LoadData(self.SaveFile)
    self.Tabs = {}
    self.Open = true
    self.ThemeCallbacks = {}
    if cfg.Theme then ApplyTheme(cfg.Theme) end
    pcall(function()
        local old = game:GetService("CoreGui"):FindFirstChild("NexusUI")
        if old then old:Destroy() end
    end)
    self.Gui = Make("ScreenGui", {Name = "NexusUI",DisplayOrder = 999,ResetOnSpawn = false,ZIndexBehavior = Enum.ZIndexBehavior.Sibling,})
    pcall(function() self.Gui.Parent = game:GetService("CoreGui") end)
    if not self.Gui.Parent then pcall(function() self.Gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end) end
    self.Main = Make("Frame", {Name = "Main",AnchorPoint = Vector2.new(0.5, 0.5),Position = UDim2.new(0.5, 0, 0.5, 0),Size = UDim2.new(0, 480, 0, 340),BackgroundColor3 = Config.Colors.Bg,Parent = self.Gui,})
    Round(self.Main, 10)
    local MainStroke = Stroke(self.Main, Config.Colors.Border, 1)
    TrackThemed(self.Main, "Bg")
    TrackThemed(MainStroke, "Border", "Color")
    Make("ImageLabel", {AnchorPoint = Vector2.new(0.5, 0.5),Position = UDim2.new(0.5, 0, 0.5, 0),Size = UDim2.new(1, 60, 1, 60),BackgroundTransparency = 1,Image = "rbxassetid://5554236805",ImageColor3 = Color3.new(0, 0, 0),ImageTransparency = 0.6,ScaleType = Enum.ScaleType.Slice,SliceCenter = Rect.new(23, 23, 277, 277),ZIndex = -1,Parent = self.Main,})
    local Header = Make("Frame", {Size = UDim2.new(1, 0, 0, 44),BackgroundColor3 = Config.Colors.Card,Parent = self.Main,})
    Round(Header, 10)
    Make("Frame", {Size = UDim2.new(1, 0, 0, 12),Position = UDim2.new(0, 0, 1, -12),BackgroundColor3 = Config.Colors.Card,BorderSizePixel = 0,Parent = Header,})
    TrackThemed(Header, "Card")
    local AccentBar = Make("Frame", {Size = UDim2.new(1, 0, 0, 2),Position = UDim2.new(0, 0, 1, 0),BorderSizePixel = 0,BackgroundColor3 = Config.Colors.Accent,Parent = Header,})
    self._accentBarGrad = Gradient(AccentBar, Config.Colors.Accent, Config.Colors.AccentAlt, 0)
    AnimateGradient(self._accentBarGrad)
    local TitleLabel = Make("TextLabel", {Size = UDim2.new(1, -120, 1, 0),Position = UDim2.new(0, 12, 0, 0),BackgroundTransparency = 1,Text = self.Title,TextColor3 = Config.Colors.Text,TextSize = 15,Font = Enum.Font.GothamBold,TextXAlignment = Enum.TextXAlignment.Left,Parent = Header,})
    TrackThemed(TitleLabel, "Text", "TextColor3")
    self._themeBadge = Make("TextLabel", {Size = UDim2.new(0, 60, 0, 18),Position = UDim2.new(1, -168, 0.5, -9),BackgroundColor3 = Config.Colors.Elevated,Text = Config.CurrentTheme,TextColor3 = Config.Colors.Accent,TextSize = 9,Font = Enum.Font.GothamBold,Parent = Header,})
    Round(self._themeBadge, 4)
    TrackThemed(self._themeBadge, "Elevated")
    TrackThemed(self._themeBadge, "Accent", "TextColor3")
    local CloseBtn = Make("TextButton", {Size = UDim2.new(0, 28, 0, 28),Position = UDim2.new(1, -36, 0, 8),BackgroundColor3 = Config.Colors.Elevated,Text = "",Parent = Header,})
    Round(CloseBtn, 6)
    local CloseLbl = Make("TextLabel", {Size = UDim2.new(1, 0, 1, 0),BackgroundTransparency = 1,Text = "×",TextColor3 = Config.Colors.TextSub,TextSize = 18,Font = Enum.Font.GothamBold,Parent = CloseBtn,})
    TrackThemed(CloseBtn, "Elevated")
    TrackThemed(CloseLbl, "TextSub", "TextColor3")
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Config.Colors.Red}) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, {BackgroundColor3 = Config.Colors.Elevated}) end)
    CloseBtn.MouseButton1Click:Connect(function() self:Toggle(false) end)
    self.TabBar = Make("Frame", {Size = UDim2.new(0, 104, 1, -54),Position = UDim2.new(0, 6, 0, 50),BackgroundTransparency = 1,Parent = self.Main,})
    self.TabScroll = Make("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0),BackgroundTransparency = 1,ScrollBarThickness = 0,CanvasSize = UDim2.new(0, 0, 0, 0),Parent = self.TabBar,})
    Make("UIListLayout", {Padding = UDim.new(0, 3), Parent = self.TabScroll})
    self.Content = Make("Frame", {Size = UDim2.new(1, -120, 1, -56),Position = UDim2.new(0, 114, 0, 50),BackgroundColor3 = Config.Colors.Card,ClipsDescendants = true,Parent = self.Main,})
    Round(self.Content, 8)
    TrackThemed(self.Content, "Card")
    local dragging, dragStart, startPos = false, nil, nil
    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, i.Position, self.Main.Position
        end
    end)
    Header.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - dragStart
            self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputBegan:Connect(function(i, gameProcessed)
        if not gameProcessed and i.KeyCode == self.ToggleKey then self:Toggle() end
    end)
    return self
end

function Library:Toggle(state)
    self.Open = state == nil and not self.Open or state
    if self.Open then
        self.Main.Visible = true
        self.Main.Size = UDim2.new(0, 480, 0, 0)
        Tween(self.Main, {Size = UDim2.new(0, 480, 0, 340)}, 0.28, Enum.EasingStyle.Back)
    else
        local tw = Tween(self.Main, {Size = UDim2.new(0, 480, 0, 0)}, 0.22)
        if tw then tw.Completed:Connect(function() if self.Main then self.Main.Visible = false end end) end
    end
end

function Library:Save() SaveData(self.SaveFile, self.Data) end
function Library:Destroy() if self.Gui then self.Gui:Destroy() end end
function Library:SetKey(k) self.ToggleKey = k end

function Library:SetTheme(name, speed)
    if not Themes[name] then return end
    ApplyTheme(name)
    if self._themeBadge then self._themeBadge.Text = name end
    RecolorAll(speed or 0.5)
    for _, cb in ipairs(self.ThemeCallbacks) do pcall(function() cb(name, Config.Colors) end) end
    if self.Data then self.Data["__theme"] = name self:Save() end
end

function Library:OnThemeChanged(cb)
    table.insert(self.ThemeCallbacks, cb)
end

function Library:GetThemes()
    local names = {}
    for _, n in ipairs(ThemeOrder) do table.insert(names, n) end
    return names
end

function Library:StartAutoTheme(intervalSeconds)
    intervalSeconds = intervalSeconds or 30
    if self._autoThemeConn then self._autoThemeConn:Disconnect() end
    local idx = 1
    for i, name in ipairs(ThemeOrder) do if name == Config.CurrentTheme then idx = i break end end
    self._autoThemeEnabled = true
    self._autoThemeInterval = intervalSeconds
    self._autoThemeTimer = 0
    self._autoThemeIdx = idx
    self._autoThemeConn = RS.Heartbeat:Connect(function(dt)
        if not self._autoThemeEnabled then return end
        self._autoThemeTimer = self._autoThemeTimer + dt
        if self._autoThemeTimer >= self._autoThemeInterval then
            self._autoThemeTimer = 0
            self._autoThemeIdx = (self._autoThemeIdx % #ThemeOrder) + 1
            self:SetTheme(ThemeOrder[self._autoThemeIdx], 1.2)
            pcall(function() self:Notify({Title = "Theme Changed",Text = "→ " .. ThemeOrder[self._autoThemeIdx],Time = 2.5,}) end)
        end
    end)
end

function Library:StopAutoTheme()
    self._autoThemeEnabled = false
    if self._autoThemeConn then self._autoThemeConn:Disconnect() self._autoThemeConn = nil end
end

function Library:Notify(o)
    o = o or {}
    local accentColor = o.Type == "Success" and Config.Colors.Green or o.Type == "Error" and Config.Colors.Red or Config.Colors.Accent
    local n = Make("Frame", {AnchorPoint = Vector2.new(1, 1),Size = UDim2.new(0, 250, 0, 64),Position = UDim2.new(1, 280, 1, -16),BackgroundColor3 = Config.Colors.Card,Parent = self.Gui,})
    Round(n, 8)
    Stroke(n, accentColor, 1)
    local bar = Make("Frame", {Size = UDim2.new(0, 3, 1, -12),Position = UDim2.new(0, 0, 0, 6),BackgroundColor3 = accentColor,BorderSizePixel = 0,Parent = n,})
    Round(bar, 2)
    Make("TextLabel", {Size = UDim2.new(1, -20, 0, 22),Position = UDim2.new(0, 12, 0, 6),BackgroundTransparency = 1,Text = o.Title or "Notice",TextColor3 = Config.Colors.Text,TextSize = 12,Font = Enum.Font.GothamBold,TextXAlignment = Enum.TextXAlignment.Left,Parent = n,})
    Make("TextLabel", {Size = UDim2.new(1, -20, 0, 28),Position = UDim2.new(0, 12, 0, 28),BackgroundTransparency = 1,Text = o.Text or "",TextColor3 = Config.Colors.TextSub,TextSize = 11,Font = Enum.Font.Gotham,TextXAlignment = Enum.TextXAlignment.Left,TextWrapped = true,Parent = n,})
    Tween(n, {Position = UDim2.new(1, -16, 1, -16)}, 0.3)
    pcall(function()
        task.delay(o.Time or 3, function()
            local tw = Tween(n, {Position = UDim2.new(1, 280, 1, -16)}, 0.25)
            if tw then tw.Completed:Connect(function() if n then n:Destroy() end end) end
        end)
    end)
end

function Library:Tab(name)
    local lib = self
    local Tab = {Name = name}
    local Btn = Make("TextButton", {Size = UDim2.new(1, -4, 0, 30),BackgroundColor3 = Config.Colors.Elevated,BackgroundTransparency = 1,Text = "",AutoButtonColor = false,Parent = self.TabScroll,})
    Round(Btn, 5)
    local BtnLabel = Make("TextLabel", {Size = UDim2.new(1, -6, 1, 0),Position = UDim2.new(0, 8, 0, 0),BackgroundTransparency = 1,Text = name,TextColor3 = Config.Colors.TextSub,TextSize = 11,Font = Enum.Font.GothamSemibold,TextXAlignment = Enum.TextXAlignment.Left,Parent = Btn,})
    TrackThemed(BtnLabel, "TextSub", "TextColor3")
    local Indicator = Make("Frame", {Size = UDim2.new(0, 2, 0.5, 0),Position = UDim2.new(0, 0, 0.25, 0),BackgroundColor3 = Config.Colors.Accent,BackgroundTransparency = 1,Parent = Btn,})
    Round(Indicator, 1)
    TrackThemed(Indicator, "Accent")
    local Page = Make("ScrollingFrame", {Size = UDim2.new(1, -8, 1, -8),Position = UDim2.new(0, 4, 0, 4),BackgroundTransparency = 1,ScrollBarThickness = 2,ScrollBarImageColor3 = Config.Colors.Accent,CanvasSize = UDim2.new(0, 0, 0, 0),Visible = #lib.Tabs == 0,Parent = lib.Content,})
    local Layout = Make("UIListLayout", {Padding = UDim.new(0, 4), Parent = Page})
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 8) end)
    Tab.Page, Tab.Btn, Tab.Indicator = Page, Btn, Indicator
    local function SelectTab()
        for _, t in ipairs(lib.Tabs) do
            t.Page.Visible = false
            Tween(t.Btn, {BackgroundTransparency = 1})
            local lbl = t.Btn:FindFirstChildOfClass("TextLabel")
            if lbl then Tween(lbl, {TextColor3 = Config.Colors.TextSub}) end
            Tween(t.Indicator, {BackgroundTransparency = 1})
        end
        Page.Visible = true
        Tween(Btn, {BackgroundTransparency = 0.7})
        Tween(BtnLabel, {TextColor3 = Config.Colors.Text})
        Tween(Indicator, {BackgroundTransparency = 0})
        lib.Active = Tab
    end
    Btn.MouseButton1Click:Connect(SelectTab)
    Btn.MouseEnter:Connect(function() if lib.Active ~= Tab then Tween(Btn, {BackgroundTransparency = 0.85}) end end)
    Btn.MouseLeave:Connect(function() if lib.Active ~= Tab then Tween(Btn, {BackgroundTransparency = 1}) end end)
    if #lib.Tabs == 0 then SelectTab() end
    table.insert(lib.Tabs, Tab)
    function Tab:Section(text)
        local lbl = Make("TextLabel", {Size = UDim2.new(1, 0, 0, 20),BackgroundTransparency = 1,Text = "  " .. text:upper(),TextColor3 = Config.Colors.TextMuted,TextSize = 9,Font = Enum.Font.GothamBold,TextXAlignment = Enum.TextXAlignment.Left,Parent = Page,})
        TrackThemed(lbl, "TextMuted", "TextColor3")
    end
    function Tab:Button(o)
        o = o or {}
        local C = Make("Frame", {Size = UDim2.new(1, 0, 0, 32),BackgroundColor3 = Config.Colors.Elevated,ClipsDescendants = true,Parent = Page,})
        Round(C, 5)
        TrackThemed(C, "Elevated")
        local B = Make("TextButton", {Size = UDim2.new(1, 0, 1, 0),BackgroundTransparency = 1,Text = "",Parent = C})
        local Lbl = Make("TextLabel", {Size = UDim2.new(1, -20, 1, 0),Position = UDim2.new(0, 8, 0, 0),BackgroundTransparency = 1,Text = o.Name or "Button",TextColor3 = Config.Colors.Text,TextSize = 11,Font = Enum.Font.GothamSemibold,TextXAlignment = Enum.TextXAlignment.Left,Parent = C,})
        Make("TextLabel", {Size = UDim2.new(0, 12, 1, 0),Position = UDim2.new(1, -18, 0, 0),BackgroundTransparency = 1,Text = "→",TextColor3 = Config.Colors.TextMuted,TextSize = 11,Font = Enum.Font.GothamBold,Parent = C,})
        TrackThemed(Lbl, "Text", "TextColor3")
        B.MouseEnter:Connect(function() Tween(C, {BackgroundColor3 = Config.Colors.Accent}) end)
        B.MouseLeave:Connect(function() Tween(C, {BackgroundColor3 = Config.Colors.Elevated}) end)
        B.MouseButton1Click:Connect(function() if o.Callback then pcall(o.Callback) end end)
    end
    function Tab:Toggle(o)
        o = o or {}
        local on = lib.Data[o.Name] ~= nil and lib.Data[o.Name] or o.Default or false
        local C = Make("Frame", {Size = UDim2.new(1, 0, 0, 32),BackgroundColor3 = Config.Colors.Elevated,Parent = Page})
        Round(C, 5)
        TrackThemed(C, "Elevated")
        local Lbl = Make("TextLabel", {Size = UDim2.new(1, -52, 1, 0),Position = UDim2.new(0, 8, 0, 0),BackgroundTransparency = 1,Text = o.Name or "Toggle",TextColor3 = Config.Colors.Text,TextSize = 11,Font = Enum.Font.GothamSemibold,TextXAlignment = Enum.TextXAlignment.Left,Parent = C,})
        TrackThemed(Lbl, "Text", "TextColor3")
        local Track = Make("Frame", {Size = UDim2.new(0, 36, 0, 18),Position = UDim2.new(1, -44, 0.5, -9),BackgroundColor3 = on and Config.Colors.Accent or Config.Colors.Bg,Parent = C,})
        Round(Track, 9)
        local Knob = Make("Frame", {Size = UDim2.new(0, 14, 0, 14),Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),BackgroundColor3 = Config.Colors.Text,Parent = Track,})
        Round(Knob, 7)
        TrackThemed(Knob, "Text")
        local function Update()
            Tween(Track, {BackgroundColor3 = on and Config.Colors.Accent or Config.Colors.Bg})
            Tween(Knob, {Position = on and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
            lib.Data[o.Name] = on
            lib:Save()
            if o.Callback then pcall(function() o.Callback(on) end) end
        end
        Make("TextButton", {Size = UDim2.new(1, 0, 1, 0),BackgroundTransparency = 1,Text = "",Parent = C}).MouseButton1Click:Connect(function() on = not on Update() end)
        return {Set = function(_, v) on = v Update() end,Get = function() return on end,}
    end
    function Tab:Slider(o)
        o = o or {}
        local min, max = o.Min or 0, o.Max or 100
        local val = lib.Data[o.Name] ~= nil and lib.Data[o.Name] or o.Default or min
        val = math.clamp(val, min, max)
        local C = Make("Frame", {Size = UDim2.new(1, 0, 0, 46),BackgroundColor3 = Config.Colors.Elevated,Parent = Page})
        Round(C, 5)
        TrackThemed(C, "Elevated")
        local Lbl = Make("TextLabel", {Size = UDim2.new(1, -42, 0, 18), Position = UDim2.new(0, 8, 0, 4),BackgroundTransparency = 1, Text = o.Name or "Slider",TextColor3 = Config.Colors.Text, TextSize = 11,Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, Parent = C,})
        TrackThemed(Lbl, "Text", "TextColor3")
        local ValLabel = Make("TextLabel", {Size = UDim2.new(0, 34, 0, 18), Position = UDim2.new(1, -42, 0, 4),BackgroundTransparency = 1, Text = tostring(val),TextColor3 = Config.Colors.Accent, TextSize = 11,Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, Parent = C,})
        TrackThemed(ValLabel, "Accent", "TextColor3")
        local Track = Make("Frame", {Size = UDim2.new(1, -16, 0, 4), Position = UDim2.new(0, 8, 0, 32),BackgroundColor3 = Config.Colors.Bg, Parent = C,})
        Round(Track, 2)
        TrackThemed(Track, "Bg")
        local Fill = Make("Frame", {Size = UDim2.new((val - min) / (max - min), 0, 1, 0),BackgroundColor3 = Config.Colors.Accent, Parent = Track,})
        Round(Fill, 2)
        Gradient(Fill, Config.Colors.AccentAlt, Config.Colors.Accent)
        local Knob = Make("Frame", {Size = UDim2.new(0, 12, 0, 12),Position = UDim2.new((val - min) / (max - min), -6, 0.5, -6),BackgroundColor3 = Config.Colors.Text, Parent = Track,})
        Round(Knob, 6)
        TrackThemed(Knob, "Text")
        local function UpdateSlider(v)
            val = math.clamp(math.floor(v + 0.5), min, max)
            local pct = (val - min) / (max - min)
            Tween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.06)
            Tween(Knob, {Position = UDim2.new(pct, -6, 0.5, -6)}, 0.06)
            ValLabel.Text = tostring(val)
            lib.Data[o.Name] = val
            lib:Save()
            if o.Callback then pcall(function() o.Callback(val) end) end
        end
        local sliding = false
        local function GetVal(i) return min + math.clamp((i.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1) * (max - min) end
        Track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true UpdateSlider(GetVal(i)) end
        end)
        Track.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
        end)
        UIS.InputChanged:Connect(function(i)
            if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then UpdateSlider(GetVal(i)) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
        end)
        return {Set = function(_, v) UpdateSlider(v) end,Get = function() return val end,}
    end
    function Tab:Keybind(o)
        o = o or {}
        local key = lib.Data[o.Name] or o.Default or Enum.KeyCode.E
        if type(key) == "string" then key = Enum.KeyCode[key] or Enum.KeyCode.E end
        local C = Make("Frame", {Size = UDim2.new(1, 0, 0, 32),BackgroundColor3 = Config.Colors.Elevated,Parent = Page})
        Round(C, 5)
        TrackThemed(C, "Elevated")
        local Lbl = Make("TextLabel", {Size = UDim2.new(1, -62, 1, 0), Position = UDim2.new(0, 8, 0, 0),BackgroundTransparency = 1, Text = o.Name or "Keybind",TextColor3 = Config.Colors.Text, TextSize = 11,Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, Parent = C,})
        TrackThemed(Lbl, "Text", "TextColor3")
        local KeyBtn = Make("TextButton", {Size = UDim2.new(0, 52, 0, 20), Position = UDim2.new(1, -58, 0.5, -10),BackgroundColor3 = Config.Colors.Bg, Text = key.Name,TextColor3 = Config.Colors.Accent, TextSize = 10,Font = Enum.Font.GothamBold, Parent = C,})
        Round(KeyBtn, 4)
        Stroke(KeyBtn, Config.Colors.Accent, 1)
        TrackThemed(KeyBtn, "Bg")
        TrackThemed(KeyBtn, "Accent", "TextColor3")
        local listening = false
        KeyBtn.MouseButton1Click:Connect(function()
            listening = true
            KeyBtn.Text = "..."
            Tween(KeyBtn, {BackgroundColor3 = Config.Colors.Accent, TextColor3 = Config.Colors.Text})
        end)
        UIS.InputBegan:Connect(function(i, g)
            if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                key = i.KeyCode
                KeyBtn.Text = key.Name
                listening = false
                Tween(KeyBtn, {BackgroundColor3 = Config.Colors.Bg, TextColor3 = Config.Colors.Accent})
                lib.Data[o.Name] = key.Name
                lib:Save()
                if o.Callback then pcall(function() o.Callback(key) end) end
            elseif not g and i.KeyCode == key and o.OnPress then pcall(o.OnPress) end
        end)
        return {Set = function(_, k) key = k KeyBtn.Text = k.Name end,Get = function() return key end,}
    end
    function Tab:Dropdown(o)
        o = o or {}
        local selected = lib.Data[o.Name] or o.Default or (o.Options and o.Options[1]) or "None"
        local isOpen = false
        local C = Make("Frame", {Size = UDim2.new(1, 0, 0, 32),BackgroundColor3 = Config.Colors.Elevated,ClipsDescendants = true,Parent = Page,})
        Round(C, 5)
        TrackThemed(C, "Elevated")
        Make("TextLabel", {Size = UDim2.new(0.38, 0, 0, 32), Position = UDim2.new(0, 8, 0, 0),BackgroundTransparency = 1, Text = o.Name or "Dropdown",TextColor3 = Config.Colors.Text, TextSize = 11,Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, Parent = C,})
        local DropBtn = Make("TextButton", {Size = UDim2.new(0.58, -8, 0, 20), Position = UDim2.new(0.42, 0, 0, 6),BackgroundColor3 = Config.Colors.Bg, Text = selected .. " ▼",TextColor3 = Config.Colors.Accent, TextSize = 10,Font = Enum.Font.GothamSemibold, TextTruncate = Enum.TextTruncate.AtEnd, Parent = C,})
        Round(DropBtn, 4)
        TrackThemed(DropBtn, "Bg")
        TrackThemed(DropBtn, "Accent", "TextColor3")
        local OptionContainer = Make("Frame", {Size = UDim2.new(0.58, -8, 0, 0), Position = UDim2.new(0.42, 0, 0, 30),BackgroundColor3 = Config.Colors.Bg, ClipsDescendants = true, Visible = false, Parent = C,})
        Round(OptionContainer, 4)
        TrackThemed(OptionContainer, "Bg")
        local OptionList = Make("Frame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Parent = OptionContainer})
        Make("UIListLayout", {Padding = UDim.new(0, 1), Parent = OptionList})
        Padding(OptionList, 2)
        local count = o.Options and #o.Options or 0
        local expandedH = 32 + 4 + math.min(count, 4) * 22 + 4
        for _, opt in ipairs(o.Options or {}) do
            local OB = Make("TextButton", {Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = Config.Colors.Elevated,BackgroundTransparency = 1, Text = opt,TextColor3 = Config.Colors.TextSub, TextSize = 10,Font = Enum.Font.Gotham, Parent = OptionList,})
            Round(OB, 3)
            OB.MouseEnter:Connect(function() Tween(OB, {BackgroundTransparency = 0, TextColor3 = Config.Colors.Text}) end)
            OB.MouseLeave:Connect(function() Tween(OB, {BackgroundTransparency = 1, TextColor3 = Config.Colors.TextSub}) end)
            OB.MouseButton1Click:Connect(function()
                selected = opt
                DropBtn.Text = selected .. " ▼"
                isOpen = false
                OptionContainer.Visible = false
                Tween(C, {Size = UDim2.new(1, 0, 0, 32)})
                lib.Data[o.Name] = selected
                lib:Save()
                if o.Callback then pcall(function() o.Callback(selected) end) end
            end)
        end
        DropBtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                OptionContainer.Visible = true
                Tween(C, {Size = UDim2.new(1, 0, 0, expandedH)})
                Tween(OptionContainer, {Size = UDim2.new(0.58, -8, 0, math.min(count, 4) * 22 + 4)})
            else
                Tween(C, {Size = UDim2.new(1, 0, 0, 32)})
                Tween(OptionContainer, {Size = UDim2.new(0.58, -8, 0, 0)})
                task.delay(0.15, function() if not isOpen then OptionContainer.Visible = false end end)
            end
        end)
        return {Set = function(_, v) selected = v DropBtn.Text = selected .. " ▼" end,Get = function() return selected end,}
    end
    function Tab:TextBox(o)
        o = o or {}
        local txt = lib.Data[o.Name] or o.Default or ""
        local C = Make("Frame", {Size = UDim2.new(1, 0, 0, 32),BackgroundColor3 = Config.Colors.Elevated,Parent = Page})
        Round(C, 5)
        TrackThemed(C, "Elevated")
        local Lbl = Make("TextLabel", {Size = UDim2.new(0.32, 0, 1, 0), Position = UDim2.new(0, 8, 0, 0),BackgroundTransparency = 1, Text = o.Name or "Input",TextColor3 = Config.Colors.Text, TextSize = 11,Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, Parent = C,})
        TrackThemed(Lbl, "Text", "TextColor3")
        local Box = Make("TextBox", {Size = UDim2.new(0.64, -8, 0, 20), Position = UDim2.new(0.36, 0, 0.5, -10),BackgroundColor3 = Config.Colors.Bg, Text = txt,PlaceholderText = o.Placeholder or "...",TextColor3 = Config.Colors.Text, PlaceholderColor3 = Config.Colors.TextMuted,TextSize = 10, Font = Enum.Font.Gotham,ClearTextOnFocus = false, Parent = C,})
        Round(Box, 4)
        TrackThemed(Box, "Bg")
        TrackThemed(Box, "Text", "TextColor3")
        Box.FocusLost:Connect(function(entered)
            txt = Box.Text
            lib.Data[o.Name] = txt
            lib:Save()
            if o.Callback then pcall(function() o.Callback(txt, entered) end) end
        end)
        return {Set = function(_, v) txt = v Box.Text = v end,Get = function() return txt end,}
    end
    function Tab:Label(text)
        local L = Make("TextLabel", {Size = UDim2.new(1, 0, 0, 18),BackgroundTransparency = 1,Text = "  " .. text,TextColor3 = Config.Colors.TextSub,TextSize = 10,Font = Enum.Font.Gotham,TextXAlignment = Enum.TextXAlignment.Left,Parent = Page,})
        TrackThemed(L, "TextSub", "TextColor3")
        return {Set = function(_, v) L.Text = "  " .. v end}
    end
    function Tab:Divider()
        local D = Make("Frame", {Size = UDim2.new(1, -8, 0, 1),BackgroundColor3 = Config.Colors.Border,BackgroundTransparency = 0.5,Parent = Page,})
        TrackThemed(D, "Border")
        return D
    end
    function Tab:ColorDisplay(o)
        o = o or {}
        local color = o.Default or Color3.fromRGB(88, 101, 242)
        local C = Make("Frame", {Size = UDim2.new(1, 0, 0, 32),BackgroundColor3 = Config.Colors.Elevated,Parent = Page})
        Round(C, 5)
        TrackThemed(C, "Elevated")
        Make("TextLabel", {Size = UDim2.new(1, -52, 1, 0), Position = UDim2.new(0, 8, 0, 0),BackgroundTransparency = 1, Text = o.Name or "Color",TextColor3 = Config.Colors.Text, TextSize = 11,Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, Parent = C,})
        local Swatch = Make("Frame", {Size = UDim2.new(0, 36, 0, 18), Position = UDim2.new(1, -44, 0.5, -9),BackgroundColor3 = color, Parent = C,})
        Round(Swatch, 4)
        Stroke(Swatch, Config.Colors.Border, 1)
        return {Set = function(_, v) color = v Swatch.BackgroundColor3 = v if o.Callback then pcall(function() o.Callback(v) end) end end,Get = function() return color end,}
    end
    return Tab
end

function Library:AddVisuals()
    local T = self:Tab("Visuals")
    T:Section("Lighting")
    T:Slider({Name = "Brightness", Min = 0, Max = 10, Default = math.floor(Lighting.Brightness),Callback = function(v) pcall(function() Lighting.Brightness = v end) end})
    T:Slider({Name = "Time of Day", Min = 0, Max = 24, Default = math.floor(Lighting.ClockTime),Callback = function(v) pcall(function() Lighting.ClockTime = v end) end})
    T:Toggle({Name = "Fullbright", Default = false, Callback = function(v)
        pcall(function()
            if v then
                Lighting.Brightness = 3 Lighting.FogEnd = 1e9 Lighting.GlobalShadows = false Lighting.Ambient = Color3.new(1, 1, 1)
            else
                Lighting.Brightness = 2 Lighting.FogEnd = 1e5 Lighting.GlobalShadows = true Lighting.Ambient = Color3.fromRGB(127, 127, 127)
            end
        end)
    end})
    T:Toggle({Name = "No Fog", Default = false,Callback = function(v) pcall(function() Lighting.FogEnd = v and 1e9 or 1e5 end) end})
    T:Section("Shadows")
    T:Toggle({Name = "Global Shadows", Default = Lighting.GlobalShadows,Callback = function(v) pcall(function() Lighting.GlobalShadows = v end) end})
    return T
end

function Library:AddThemeTab()
    local T = self:Tab("Themes")
    local lib = self
    T:Section("Preset Themes")
    for _, themeName in ipairs(ThemeOrder) do
        T:Button({Name = themeName,Callback = function() lib:SetTheme(themeName) pcall(function() lib:Notify({Title = "Theme", Text = themeName .. " applied!", Time = 2}) end) end,})
    end
    T:Divider()
    T:Section("Auto Cycle")
    local autoEnabled = false
    local autoToggle = T:Toggle({Name = "Auto Theme Cycle", Default = false, Callback = function(v)
        autoEnabled = v
        if v then lib:StartAutoTheme(lib._autoInterval or 30) else lib:StopAutoTheme() end
    end})
    T:Slider({Name = "Interval (seconds)", Min = 5, Max = 120, Default = 30, Callback = function(v)
        lib._autoInterval = v
        if autoEnabled then lib:StopAutoTheme() lib:StartAutoTheme(v) end
    end})
    T:Label("Current: " .. Config.CurrentTheme)
    lib:OnThemeChanged(function(name) end)
    return T
end

return Library

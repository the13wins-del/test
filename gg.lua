local Fx = {}
Fx.__index = Fx

local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local HTTP    = game:GetService("HttpService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local Themes = {
    Dark    = { Bg = Color3.fromRGB(12,12,16),    Card = Color3.fromRGB(18,18,24),    Elevated = Color3.fromRGB(26,26,34),   Border = Color3.fromRGB(38,38,48),   Accent = Color3.fromRGB(88,101,242),  AccentAlt = Color3.fromRGB(110,123,255), Text = Color3.fromRGB(255,255,255), TextSub = Color3.fromRGB(148,155,164), TextMuted = Color3.fromRGB(96,100,108),  Green = Color3.fromRGB(59,165,93),  Red = Color3.fromRGB(237,66,69) },
    Crimson = { Bg = Color3.fromRGB(14,8,8),      Card = Color3.fromRGB(24,12,12),    Elevated = Color3.fromRGB(36,18,18),   Border = Color3.fromRGB(60,28,28),   Accent = Color3.fromRGB(220,50,50),   AccentAlt = Color3.fromRGB(255,80,80),   Text = Color3.fromRGB(255,240,240), TextSub = Color3.fromRGB(180,140,140), TextMuted = Color3.fromRGB(120,90,90),   Green = Color3.fromRGB(59,165,93),  Red = Color3.fromRGB(237,66,69) },
    Emerald = { Bg = Color3.fromRGB(6,14,10),     Card = Color3.fromRGB(10,22,16),    Elevated = Color3.fromRGB(16,34,24),   Border = Color3.fromRGB(26,56,38),   Accent = Color3.fromRGB(52,199,120),  AccentAlt = Color3.fromRGB(80,230,150),  Text = Color3.fromRGB(240,255,245), TextSub = Color3.fromRGB(140,180,155), TextMuted = Color3.fromRGB(90,130,105),  Green = Color3.fromRGB(59,200,93),  Red = Color3.fromRGB(237,66,69) },
    Ocean   = { Bg = Color3.fromRGB(6,12,20),     Card = Color3.fromRGB(10,20,34),    Elevated = Color3.fromRGB(14,30,50),   Border = Color3.fromRGB(22,50,80),   Accent = Color3.fromRGB(30,140,220),  AccentAlt = Color3.fromRGB(60,180,255),  Text = Color3.fromRGB(220,240,255), TextSub = Color3.fromRGB(120,160,200), TextMuted = Color3.fromRGB(70,110,150),  Green = Color3.fromRGB(59,165,93),  Red = Color3.fromRGB(237,66,69) },
    Violet  = { Bg = Color3.fromRGB(10,6,18),     Card = Color3.fromRGB(16,10,28),    Elevated = Color3.fromRGB(26,16,44),   Border = Color3.fromRGB(44,28,72),   Accent = Color3.fromRGB(168,85,247),  AccentAlt = Color3.fromRGB(200,120,255), Text = Color3.fromRGB(245,235,255), TextSub = Color3.fromRGB(170,140,200), TextMuted = Color3.fromRGB(110,85,145),  Green = Color3.fromRGB(59,165,93),  Red = Color3.fromRGB(237,66,69) },
    Rose    = { Bg = Color3.fromRGB(18,8,12),     Card = Color3.fromRGB(28,12,18),    Elevated = Color3.fromRGB(40,18,26),   Border = Color3.fromRGB(65,28,40),   Accent = Color3.fromRGB(240,80,130),  AccentAlt = Color3.fromRGB(255,110,160), Text = Color3.fromRGB(255,235,242), TextSub = Color3.fromRGB(200,150,170), TextMuted = Color3.fromRGB(140,95,115),  Green = Color3.fromRGB(59,165,93),  Red = Color3.fromRGB(237,66,69) },
    Amber   = { Bg = Color3.fromRGB(16,12,4),     Card = Color3.fromRGB(26,20,6),     Elevated = Color3.fromRGB(38,30,8),    Border = Color3.fromRGB(62,48,12),   Accent = Color3.fromRGB(245,175,25),  AccentAlt = Color3.fromRGB(255,205,60),  Text = Color3.fromRGB(255,248,220), TextSub = Color3.fromRGB(200,175,120), TextMuted = Color3.fromRGB(140,118,72),  Green = Color3.fromRGB(59,165,93),  Red = Color3.fromRGB(237,66,69) },
    Ice     = { Bg = Color3.fromRGB(8,14,20),     Card = Color3.fromRGB(14,22,32),    Elevated = Color3.fromRGB(20,32,46),   Border = Color3.fromRGB(34,54,76),   Accent = Color3.fromRGB(120,210,240), AccentAlt = Color3.fromRGB(160,235,255), Text = Color3.fromRGB(220,240,255), TextSub = Color3.fromRGB(130,170,200), TextMuted = Color3.fromRGB(80,115,145),  Green = Color3.fromRGB(59,165,93),  Red = Color3.fromRGB(237,66,69) },
}

local ThemeOrder = {"Dark","Crimson","Emerald","Ocean","Violet","Rose","Amber","Ice"}

local C = {
    ToggleKey    = Enum.KeyCode.K,
    AnimSpeed    = 0.15,
    SaveFile     = "FxScripts.json",
    CurrentTheme = "Dark",
    Colors       = {},
}

local function ApplyTheme(name)
    if not Themes[name] then return end
    C.CurrentTheme = name
    for k, v in pairs(Themes[name]) do C.Colors[k] = v end
end
ApplyTheme("Dark")

local Tracked = {}

local function Make(class, props)
    local ok, obj = pcall(Instance.new, class)
    if not ok then return nil end
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then pcall(function() obj[k] = v end) end
    end
    if props and props.Parent then pcall(function() obj.Parent = props.Parent end) end
    return obj
end

local function Tw(obj, props, t, style)
    if not obj then return end
    local tw = TS:Create(obj, TweenInfo.new(t or C.AnimSpeed, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function Corner(p, r)   return Make("UICorner",  {CornerRadius = UDim.new(0, r or 6), Parent = p}) end
local function Pad(p, v)      return Make("UIPadding", {PaddingTop = UDim.new(0,v), PaddingBottom = UDim.new(0,v), PaddingLeft = UDim.new(0,v), PaddingRight = UDim.new(0,v), Parent = p}) end

local function Border(p, color, thick)
    local s = Make("UIStroke", {Thickness = thick or 1, Transparency = 0.5, Parent = p})
    if s then s.Color = color or C.Colors.Border end
    return s
end

local function Grad(p, c1, c2, rot)
    return Make("UIGradient", {
        Color    = ColorSequence.new({ColorSequenceKeypoint.new(0, c1 or C.Colors.Accent), ColorSequenceKeypoint.new(1, c2 or C.Colors.AccentAlt)}),
        Rotation = rot or 90,
        Parent   = p,
    })
end

local function SpinGrad(g)
    if not g then return end
    local r = 0
    RS.RenderStepped:Connect(function(dt)
        if not g or not g.Parent then return end
        r = (r + dt * 15) % 360
        g.Rotation = r
    end)
end

local function Track(obj, key, prop)
    if not obj then return end
    table.insert(Tracked, {obj = obj, key = key, prop = prop or "BackgroundColor3"})
end

local function RecolorAll(speed)
    for i = #Tracked, 1, -1 do
        if not Tracked[i].obj or not Tracked[i].obj.Parent then
            table.remove(Tracked, i)
        end
    end
    speed = speed or 0.5
    for _, e in ipairs(Tracked) do
        local col = C.Colors[e.key]
        if col and e.obj and e.obj.Parent then
            Tw(e.obj, {[e.prop] = col}, speed, Enum.EasingStyle.Sine)
        end
    end
end

local function FxSave(file, data)
    if writefile then pcall(function() writefile(file, HTTP:JSONEncode(data)) end) end
end

local function FxLoad(file)
    if readfile and isfile and isfile(file) then
        local ok, d = pcall(function() return HTTP:JSONDecode(readfile(file)) end)
        return ok and d or {}
    end
    return {}
end

function Fx.new(cfg)
    cfg = cfg or {}
    local self = setmetatable({}, Fx)

    self.Title          = cfg.Title or "Fx Scripts"
    self.ToggleKey      = cfg.Key or C.ToggleKey
    self.SaveFile       = cfg.File or C.SaveFile
    self.Data           = FxLoad(self.SaveFile)
    self.Tabs           = {}
    self.Open           = true
    self.ThemeCallbacks = {}
    self._autoInterval  = 30

    if cfg.Theme and Themes[cfg.Theme] then ApplyTheme(cfg.Theme) end

    pcall(function()
        local old = game:GetService("CoreGui"):FindFirstChild("FxScriptsUI")
        if old then old:Destroy() end
    end)

    local gui = Make("ScreenGui", {Name = "FxScriptsUI", DisplayOrder = 999, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    if gui then
        local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
        if not ok then
            pcall(function() gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end)
        end
    end
    self.Gui = gui

    local main = Make("Frame", {
        Name             = "Main",
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 480, 0, 340),
        BackgroundColor3 = C.Colors.Bg,
        Parent           = self.Gui,
    })
    self.Main = main
    Corner(main, 10)
    local mainBorder = Border(main, C.Colors.Border, 1)
    Track(main, "Bg")
    if mainBorder then Track(mainBorder, "Border", "Color") end

    Make("ImageLabel", {
        AnchorPoint       = Vector2.new(0.5, 0.5),
        Position          = UDim2.new(0.5, 0, 0.5, 0),
        Size              = UDim2.new(1, 60, 1, 60),
        BackgroundTransparency = 1,
        Image             = "rbxassetid://5554236805",
        ImageColor3       = Color3.new(0, 0, 0),
        ImageTransparency = 0.6,
        ScaleType         = Enum.ScaleType.Slice,
        SliceCenter       = Rect.new(23, 23, 277, 277),
        ZIndex            = -1,
        Parent            = main,
    })

    local header = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = C.Colors.Card,
        Parent           = main,
    })
    Corner(header, 10)
    local headerBottom = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 12),
        Position         = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = C.Colors.Card,
        BorderSizePixel  = 0,
        Parent           = header,
    })
    Track(header,       "Card")
    Track(headerBottom, "Card")

    local accentBar = Make("Frame", {
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, 0),
        BorderSizePixel  = 0,
        BackgroundColor3 = C.Colors.Accent,
        Parent           = header,
    })
    SpinGrad(Grad(accentBar, C.Colors.Accent, C.Colors.AccentAlt, 0))

    local titleLbl = Make("TextLabel", {
        Size              = UDim2.new(1, -180, 1, 0),
        Position          = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text              = self.Title,
        TextColor3        = C.Colors.Text,
        TextSize          = 15,
        Font              = Enum.Font.GothamBold,
        TextXAlignment    = Enum.TextXAlignment.Left,
        Parent            = header,
    })
    Track(titleLbl, "Text", "TextColor3")

    local badge = Make("TextLabel", {
        Size             = UDim2.new(0, 64, 0, 18),
        Position         = UDim2.new(1, -108, 0.5, -9),
        BackgroundColor3 = C.Colors.Elevated,
        Text             = C.CurrentTheme,
        TextColor3       = C.Colors.Accent,
        TextSize         = 9,
        Font             = Enum.Font.GothamBold,
        Parent           = header,
    })
    Corner(badge, 4)
    Track(badge, "Elevated")
    Track(badge, "Accent", "TextColor3")
    self._badge = badge

    local closeBtn = Make("TextButton", {
        Size             = UDim2.new(0, 28, 0, 28),
        Position         = UDim2.new(1, -36, 0, 8),
        BackgroundColor3 = C.Colors.Elevated,
        Text             = "",
        Parent           = header,
    })
    Corner(closeBtn, 6)
    local closeLbl = Make("TextLabel", {
        Size              = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text              = "×",
        TextColor3        = C.Colors.TextSub,
        TextSize          = 18,
        Font              = Enum.Font.GothamBold,
        Parent            = closeBtn,
    })
    Track(closeBtn, "Elevated")
    Track(closeLbl, "TextSub", "TextColor3")
    closeBtn.MouseEnter:Connect(function()   Tw(closeBtn, {BackgroundColor3 = C.Colors.Red}) end)
    closeBtn.MouseLeave:Connect(function()   Tw(closeBtn, {BackgroundColor3 = C.Colors.Elevated}) end)
    closeBtn.MouseButton1Click:Connect(function() self:Toggle(false) end)

    local tabBar = Make("Frame", {
        Size                = UDim2.new(0, 104, 1, -54),
        Position            = UDim2.new(0, 6, 0, 50),
        BackgroundTransparency = 1,
        Parent              = main,
    })
    self.TabBar = tabBar

    local tabScroll = Make("ScrollingFrame", {
        Size                = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness  = 0,
        CanvasSize          = UDim2.new(0, 0, 0, 0),
        Parent              = tabBar,
    })
    self.TabScroll = tabScroll
    Make("UIListLayout", {Padding = UDim.new(0, 3), Parent = tabScroll})

    local content = Make("Frame", {
        Size             = UDim2.new(1, -120, 1, -56),
        Position         = UDim2.new(0, 114, 0, 50),
        BackgroundColor3 = C.Colors.Card,
        ClipsDescendants = true,
        Parent           = main,
    })
    self.Content = content
    Corner(content, 8)
    Track(content, "Card")

    local dragging, dragStart, startPos = false, nil, nil
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = i.Position
            startPos  = main.Position
        end
    end)
    header.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)

    UIS.InputBegan:Connect(function(i, gp)
        if not gp and i.KeyCode == self.ToggleKey then self:Toggle() end
    end)

    return self
end

function Fx:Toggle(state)
    self.Open = state == nil and not self.Open or state
    if self.Open then
        self.Main.Visible = true
        self.Main.Size = UDim2.new(0, 480, 0, 0)
        Tw(self.Main, {Size = UDim2.new(0, 480, 0, 340)}, 0.28, Enum.EasingStyle.Back)
    else
        local tw = Tw(self.Main, {Size = UDim2.new(0, 480, 0, 0)}, 0.22)
        if tw then tw.Completed:Connect(function() if self.Main then self.Main.Visible = false end end) end
    end
end

function Fx:Save()    FxSave(self.SaveFile, self.Data) end
function Fx:Destroy() if self.Gui then self.Gui:Destroy() end end
function Fx:SetKey(k) self.ToggleKey = k end

function Fx:SetTheme(name, speed)
    if not Themes[name] then return end
    ApplyTheme(name)
    if self._badge then self._badge.Text = name end
    RecolorAll(speed or 0.5)
    for _, cb in ipairs(self.ThemeCallbacks) do task.spawn(cb, name, C.Colors) end
    self.Data["__theme"] = name
    self:Save()
end

function Fx:OnThemeChanged(cb)
    table.insert(self.ThemeCallbacks, cb)
end

function Fx:StartAutoTheme(interval)
    interval = interval or self._autoInterval
    self._autoInterval = interval
    if self._autoConn then self._autoConn:Disconnect() end
    local idx = 1
    for i, n in ipairs(ThemeOrder) do if n == C.CurrentTheme then idx = i break end end
    local timer = 0
    self._autoConn = RS.Heartbeat:Connect(function(dt)
        timer = timer + dt
        if timer >= interval then
            timer = 0
            idx = (idx % #ThemeOrder) + 1
            self:SetTheme(ThemeOrder[idx], 1.2)
            self:Notify({Title = "Theme", Text = "→ " .. ThemeOrder[idx], Time = 2})
        end
    end)
end

function Fx:StopAutoTheme()
    if self._autoConn then
        self._autoConn:Disconnect()
        self._autoConn = nil
    end
end

function Fx:Notify(o)
    o = o or {}
    local col = o.Type == "Success" and C.Colors.Green or o.Type == "Error" and C.Colors.Red or C.Colors.Accent
    local n = Make("Frame", {
        AnchorPoint      = Vector2.new(1, 1),
        Size             = UDim2.new(0, 250, 0, 64),
        Position         = UDim2.new(1, 280, 1, -16),
        BackgroundColor3 = C.Colors.Card,
        Parent           = self.Gui,
    })
    if not n then return end
    Corner(n, 8)
    Border(n, col, 1)
    local bar = Make("Frame", {Size = UDim2.new(0,3,1,-12), Position = UDim2.new(0,0,0,6), BackgroundColor3 = col, BorderSizePixel = 0, Parent = n})
    Corner(bar, 2)
    Make("TextLabel", {Size = UDim2.new(1,-20,0,22), Position = UDim2.new(0,12,0,6),  BackgroundTransparency = 1, Text = o.Title or "Notice", TextColor3 = C.Colors.Text,    TextSize = 12, Font = Enum.Font.GothamBold,     TextXAlignment = Enum.TextXAlignment.Left, Parent = n})
    Make("TextLabel", {Size = UDim2.new(1,-20,0,28), Position = UDim2.new(0,12,0,28), BackgroundTransparency = 1, Text = o.Text  or "",       TextColor3 = C.Colors.TextSub, TextSize = 11, Font = Enum.Font.Gotham, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = n})
    Tw(n, {Position = UDim2.new(1,-16,1,-16)}, 0.3)
    task.delay(o.Time or 3, function()
        local tw = Tw(n, {Position = UDim2.new(1,280,1,-16)}, 0.25)
        if tw then tw.Completed:Connect(function() if n then n:Destroy() end) end end
    end)
end

function Fx:Tab(name)
    local lib = self
    local Tab = {Name = name}

    local btn = Make("TextButton", {
        Size                   = UDim2.new(1,-4,0,30),
        BackgroundColor3       = C.Colors.Elevated,
        BackgroundTransparency = 1,
        Text                   = "",
        AutoButtonColor        = false,
        Parent                 = self.TabScroll,
    })
    Corner(btn, 5)

    local btnLbl = Make("TextLabel", {
        Size              = UDim2.new(1,-6,1,0),
        Position          = UDim2.new(0,8,0,0),
        BackgroundTransparency = 1,
        Text              = name,
        TextColor3        = C.Colors.TextSub,
        TextSize          = 11,
        Font              = Enum.Font.GothamSemibold,
        TextXAlignment    = Enum.TextXAlignment.Left,
        Parent            = btn,
    })
    Track(btnLbl, "TextSub", "TextColor3")

    local ind = Make("Frame", {
        Size             = UDim2.new(0,2,0.5,0),
        Position         = UDim2.new(0,0,0.25,0),
        BackgroundColor3 = C.Colors.Accent,
        BackgroundTransparency = 1,
        Parent           = btn,
    })
    Corner(ind, 1)
    Track(ind, "Accent")

    local page = Make("ScrollingFrame", {
        Size                = UDim2.new(1,-8,1,-8),
        Position            = UDim2.new(0,4,0,4),
        BackgroundTransparency = 1,
        ScrollBarThickness  = 2,
        ScrollBarImageColor3 = C.Colors.Accent,
        CanvasSize          = UDim2.new(0,0,0,0),
        Visible             = #lib.Tabs == 0,
        Parent              = lib.Content,
    })
    local layout = Make("UIListLayout", {Padding = UDim.new(0,4), Parent = page})
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 8)
    end)

    Tab.Page = page

    local function SelectTab()
        for _, t in ipairs(lib.Tabs) do
            t.Page.Visible = false
            Tw(t.Page:FindFirstAncestorOfClass("Frame"), nil)
            local b = t._btn
            local l = t._btnLbl
            local i2 = t._ind
            if b  then Tw(b,  {BackgroundTransparency = 1}) end
            if l  then Tw(l,  {TextColor3 = C.Colors.TextSub}) end
            if i2 then Tw(i2, {BackgroundTransparency = 1}) end
        end
        page.Visible = true
        Tw(btn,    {BackgroundTransparency = 0.7})
        Tw(btnLbl, {TextColor3 = C.Colors.Text})
        Tw(ind,    {BackgroundTransparency = 0})
        lib.Active = Tab
    end

    Tab._btn    = btn
    Tab._btnLbl = btnLbl
    Tab._ind    = ind

    btn.MouseButton1Click:Connect(SelectTab)
    btn.MouseEnter:Connect(function()  if lib.Active ~= Tab then Tw(btn, {BackgroundTransparency = 0.85}) end end)
    btn.MouseLeave:Connect(function()  if lib.Active ~= Tab then Tw(btn, {BackgroundTransparency = 1})    end end)

    if #lib.Tabs == 0 then SelectTab() end
    table.insert(lib.Tabs, Tab)

    function Tab:Section(text)
        local lbl = Make("TextLabel", {
            Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1,
            Text = "  " .. text:upper(), TextColor3 = C.Colors.TextMuted,
            TextSize = 9, Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = page,
        })
        Track(lbl, "TextMuted", "TextColor3")
    end

    function Tab:Button(o)
        o = o or {}
        local row = Make("Frame", {Size = UDim2.new(1,0,0,32), BackgroundColor3 = C.Colors.Elevated, ClipsDescendants = true, Parent = page})
        Corner(row, 5)
        Track(row, "Elevated")
        local hit = Make("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = row})
        local lbl = Make("TextLabel", {Size = UDim2.new(1,-20,1,0), Position = UDim2.new(0,8,0,0), BackgroundTransparency = 1, Text = o.Name or "Button", TextColor3 = C.Colors.Text, TextSize = 11, Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, Parent = row})
        Make("TextLabel", {Size = UDim2.new(0,12,1,0), Position = UDim2.new(1,-18,0,0), BackgroundTransparency = 1, Text = "›", TextColor3 = C.Colors.TextMuted, TextSize = 14, Font = Enum.Font.GothamBold, Parent = row})
        Track(lbl, "Text", "TextColor3")
        hit.MouseEnter:Connect(function()  Tw(row, {BackgroundColor3 = C.Colors.Accent}) end)
        hit.MouseLeave:Connect(function()  Tw(row, {BackgroundColor3 = C.Colors.Elevated}) end)
        hit.MouseButton1Click:Connect(function() if o.Callback then task.spawn(o.Callback) end end)
    end

    function Tab:Toggle(o)
        o = o or {}
        local on = lib.Data[o.Name] ~= nil and lib.Data[o.Name] or (o.Default == true)
        local row = Make("Frame", {Size = UDim2.new(1,0,0,32), BackgroundColor3 = C.Colors.Elevated, Parent = page})
        Corner(row, 5)
        Track(row, "Elevated")
        local lbl = Make("TextLabel", {Size = UDim2.new(1,-52,1,0), Position = UDim2.new(0,8,0,0), BackgroundTransparency = 1, Text = o.Name or "Toggle", TextColor3 = C.Colors.Text, TextSize = 11, Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, Parent = row})
        Track(lbl, "Text", "TextColor3")
        local track = Make("Frame", {Size = UDim2.new(0,36,0,18), Position = UDim2.new(1,-44,0.5,-9), BackgroundColor3 = on and C.Colors.Accent or C.Colors.Bg, Parent = row})
        Corner(track, 9)
        local knob = Make("Frame", {Size = UDim2.new(0,14,0,14), Position = on and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7), BackgroundColor3 = C.Colors.Text, Parent = track})
        Corner(knob, 7)
        Track(knob, "Text")
        local function Upd()
            Tw(track, {BackgroundColor3 = on and C.Colors.Accent or C.Colors.Bg})
            Tw(knob,  {Position = on and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)})
            lib.Data[o.Name] = on
            lib:Save()
            if o.Callback then task.spawn(o.Callback, on) end
        end
        Make("TextButton", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = "", Parent = row}).MouseButton1Click:Connect(function() on = not on Upd() end)
        return {Set = function(_,v) on = v Upd() end, Get = function() return on end}
    end

    function Tab:Slider(o)
        o = o or {}
        local mn, mx = o.Min or 0, o.Max or 100
        local val = lib.Data[o.Name] ~= nil and lib.Data[o.Name] or (o.Default or mn)
        val = math.clamp(val, mn, mx)
        local row = Make("Frame", {Size = UDim2.new(1,0,0,46), BackgroundColor3 = C.Colors.Elevated, Parent = page})
        Corner(row, 5)
        Track(row, "Elevated")
        local lbl = Make("TextLabel", {Size = UDim2.new(1,-42,0,18), Position = UDim2.new(0,8,0,4), BackgroundTransparency = 1, Text = o.Name or "Slider", TextColor3 = C.Colors.Text, TextSize = 11, Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, Parent = row})
        Track(lbl, "Text", "TextColor3")
        local valLbl = Make("TextLabel", {Size = UDim2.new(0,34,0,18), Position = UDim2.new(1,-42,0,4), BackgroundTransparency = 1, Text = tostring(val), TextColor3 = C.Colors.Accent, TextSize = 11, Font = Enum.Font.GothamBold, TextXAlignment = Enum.TextXAlignment.Right, Parent = row})
        Track(valLbl, "Accent", "TextColor3")
        local rail = Make("Frame", {Size = UDim2.new(1,-16,0,4), Position = UDim2.new(0,8,0,32), BackgroundColor3 = C.Colors.Bg, Parent = row})
        Corner(rail, 2)
        Track(rail, "Bg")
        local pct0 = (val - mn) / (mx - mn)
        local fill = Make("Frame", {Size = UDim2.new(pct0,0,1,0), BackgroundColor3 = C.Colors.Accent, Parent = rail})
        Corner(fill, 2)
        Grad(fill, C.Colors.AccentAlt, C.Colors.Accent)
        local knob = Make("Frame", {Size = UDim2.new(0,12,0,12), Position = UDim2.new(pct0,-6,0.5,-6), BackgroundColor3 = C.Colors.Text, Parent = rail})
        Corner(knob, 6)
        Track(knob, "Text")
        local sliding = false
        local function Upd(v)
            val = math.clamp(math.floor(v + 0.5), mn, mx)
            local p = (val - mn) / (mx - mn)
            Tw(fill, {Size = UDim2.new(p,0,1,0)}, 0.06)
            Tw(knob, {Position = UDim2.new(p,-6,0.5,-6)}, 0.06)
            valLbl.Text = tostring(val)
            lib.Data[o.Name] = val
            lib:Save()
            if o.Callback then task.spawn(o.Callback, val) end
        end
        local function RailVal(i) return mn + math.clamp((i.Position.X - rail.AbsolutePosition.X) / rail.AbsoluteSize.X, 0, 1) * (mx - mn) end
        rail.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true Upd(RailVal(i)) end
        end)
        rail.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
        end)
        UIS.InputChanged:Connect(function(i)
            if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Upd(RailVal(i)) end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
        end)
        return {Set = function(_,v) Upd(v) end, Get = function() return val end}
    end

    function Tab:Dropdown(o)
        o = o or {}
        local opts   = o.Options or {}
        local sel    = lib.Data[o.Name] or o.Default or opts[1] or "None"
        local isOpen = false
        local cnt    = #opts
        local exH    = 32 + 4 + math.min(cnt, 4) * 22 + 4
        local row = Make("Frame", {Size = UDim2.new(1,0,0,32), BackgroundColor3 = C.Colors.Elevated, ClipsDescendants = true, Parent = page})
        Corner(row, 5)
        Track(row, "Elevated")
        local lbl = Make("TextLabel", {Size = UDim2.new(0.38,0,0,32), Position = UDim2.new(0,8,0,0), BackgroundTransparency = 1, Text = o.Name or "Dropdown", TextColor3 = C.Colors.Text, TextSize = 11, Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, Parent = row})
        Track(lbl, "Text", "TextColor3")
        local dbtn = Make("TextButton", {Size = UDim2.new(0.58,-8,0,20), Position = UDim2.new(0.42,0,0,6), BackgroundColor3 = C.Colors.Bg, Text = sel .. " ▼", TextColor3 = C.Colors.Accent, TextSize = 10, Font = Enum.Font.GothamSemibold, TextTruncate = Enum.TextTruncate.AtEnd, Parent = row})
        Corner(dbtn, 4)
        Track(dbtn, "Bg")
        Track(dbtn, "Accent", "TextColor3")
        local optBox = Make("Frame", {Size = UDim2.new(0.58,-8,0,0), Position = UDim2.new(0.42,0,0,30), BackgroundColor3 = C.Colors.Bg, ClipsDescendants = true, Visible = false, Parent = row})
        Corner(optBox, 4)
        Track(optBox, "Bg")
        local optList = Make("Frame", {Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Parent = optBox})
        Make("UIListLayout", {Padding = UDim.new(0,1), Parent = optList})
        Pad(optList, 2)
        for _, opt in ipairs(opts) do
            local ob = Make("TextButton", {Size = UDim2.new(1,0,0,20), BackgroundColor3 = C.Colors.Elevated, BackgroundTransparency = 1, Text = opt, TextColor3 = C.Colors.TextSub, TextSize = 10, Font = Enum.Font.Gotham, Parent = optList})
            Corner(ob, 3)
            ob.MouseEnter:Connect(function()  Tw(ob, {BackgroundTransparency = 0, TextColor3 = C.Colors.Text}) end)
            ob.MouseLeave:Connect(function()  Tw(ob, {BackgroundTransparency = 1, TextColor3 = C.Colors.TextSub}) end)
            ob.MouseButton1Click:Connect(function()
                sel = opt
                dbtn.Text = sel .. " ▼"
                isOpen = false
                optBox.Visible = false
                Tw(row, {Size = UDim2.new(1,0,0,32)})
                lib.Data[o.Name] = sel
                lib:Save()
                if o.Callback then task.spawn(o.Callback, sel) end
            end)
        end
        dbtn.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                optBox.Visible = true
                Tw(row,    {Size = UDim2.new(1,0,0,exH)})
                Tw(optBox, {Size = UDim2.new(0.58,-8,0,math.min(cnt,4)*22+4)})
            else
                Tw(row,    {Size = UDim2.new(1,0,0,32)})
                Tw(optBox, {Size = UDim2.new(0.58,-8,0,0)})
                task.delay(0.15, function() if not isOpen then optBox.Visible = false end end)
            end
        end)
        return {Set = function(_,v) sel = v dbtn.Text = sel .. " ▼" end, Get = function() return sel end}
    end

    function Tab:Keybind(o)
        o = o or {}
        local key = lib.Data[o.Name] or o.Default or Enum.KeyCode.E
        if type(key) == "string" then key = Enum.KeyCode[key] or Enum.KeyCode.E end
        local row = Make("Frame", {Size = UDim2.new(1,0,0,32), BackgroundColor3 = C.Colors.Elevated, Parent = page})
        Corner(row, 5)
        Track(row, "Elevated")
        local lbl = Make("TextLabel", {Size = UDim2.new(1,-62,1,0), Position = UDim2.new(0,8,0,0), BackgroundTransparency = 1, Text = o.Name or "Keybind", TextColor3 = C.Colors.Text, TextSize = 11, Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, Parent = row})
        Track(lbl, "Text", "TextColor3")
        local kbtn = Make("TextButton", {Size = UDim2.new(0,52,0,20), Position = UDim2.new(1,-58,0.5,-10), BackgroundColor3 = C.Colors.Bg, Text = key.Name, TextColor3 = C.Colors.Accent, TextSize = 10, Font = Enum.Font.GothamBold, Parent = row})
        Corner(kbtn, 4)
        Border(kbtn, C.Colors.Accent, 1)
        Track(kbtn, "Bg")
        Track(kbtn, "Accent", "TextColor3")
        local listening = false
        kbtn.MouseButton1Click:Connect(function()
            listening = true
            kbtn.Text = "..."
            Tw(kbtn, {BackgroundColor3 = C.Colors.Accent, TextColor3 = C.Colors.Text})
        end)
        UIS.InputBegan:Connect(function(i, gp)
            if listening and i.UserInputType == Enum.UserInputType.Keyboard then
                key = i.KeyCode
                kbtn.Text = key.Name
                listening = false
                Tw(kbtn, {BackgroundColor3 = C.Colors.Bg, TextColor3 = C.Colors.Accent})
                lib.Data[o.Name] = key.Name
                lib:Save()
                if o.Callback then task.spawn(o.Callback, key) end
            elseif not gp and i.KeyCode == key and o.OnPress then
                task.spawn(o.OnPress)
            end
        end)
        return {Set = function(_,k) key = k kbtn.Text = k.Name end, Get = function() return key end}
    end

    function Tab:TextBox(o)
        o = o or {}
        local txt = lib.Data[o.Name] or o.Default or ""
        local row = Make("Frame", {Size = UDim2.new(1,0,0,32), BackgroundColor3 = C.Colors.Elevated, Parent = page})
        Corner(row, 5)
        Track(row, "Elevated")
        local lbl = Make("TextLabel", {Size = UDim2.new(0.32,0,1,0), Position = UDim2.new(0,8,0,0), BackgroundTransparency = 1, Text = o.Name or "Input", TextColor3 = C.Colors.Text, TextSize = 11, Font = Enum.Font.GothamSemibold, TextXAlignment = Enum.TextXAlignment.Left, Parent = row})
        Track(lbl, "Text", "TextColor3")
        local box = Make("TextBox", {Size = UDim2.new(0.64,-8,0,20), Position = UDim2.new(0.36,0,0.5,-10), BackgroundColor3 = C.Colors.Bg, Text = txt, PlaceholderText = o.Placeholder or "...", TextColor3 = C.Colors.Text, PlaceholderColor3 = C.Colors.TextMuted, TextSize = 10, Font = Enum.Font.Gotham, ClearTextOnFocus = false, Parent = row})
        Corner(box, 4)
        Track(box, "Bg")
        Track(box, "Text", "TextColor3")
        box.FocusLost:Connect(function(entered)
            txt = box.Text
            lib.Data[o.Name] = txt
            lib:Save()
            if o.Callback then task.spawn(o.Callback, txt, entered) end
        end)
        return {Set = function(_,v) txt = v box.Text = v end, Get = function() return txt end}
    end

    function Tab:Label(text)
        local lbl = Make("TextLabel", {Size = UDim2.new(1,0,0,18), BackgroundTransparency = 1, Text = "  " .. tostring(text), TextColor3 = C.Colors.TextSub, TextSize = 10, Font = Enum.Font.Gotham, TextXAlignment = Enum.TextXAlignment.Left, Parent = page})
        Track(lbl, "TextSub", "TextColor3")
        return {Set = function(_,v) if lbl then lbl.Text = "  " .. tostring(v) end end}
    end

    function Tab:Divider()
        local d = Make("Frame", {Size = UDim2.new(1,-8,0,1), BackgroundColor3 = C.Colors.Border, BackgroundTransparency = 0.5, Parent = page})
        Track(d, "Border")
        return d
    end

    return Tab
end

function Fx:AddThemeTab()
    local T = self:Tab("Themes")
    local lib = self

    T:Section("Presets")
    for _, n in ipairs(ThemeOrder) do
        T:Button({Name = n, Callback = function()
            lib:SetTheme(n)
            lib:Notify({Title = "Theme", Text = n .. " applied!", Time = 2})
        end})
    end

    T:Divider()
    T:Section("Auto Cycle")

    local autoOn = false
    T:Toggle({Name = "Auto Cycle Themes", Default = false, Callback = function(v)
        autoOn = v
        if v then lib:StartAutoTheme(lib._autoInterval)
        else      lib:StopAutoTheme() end
    end})

    T:Slider({Name = "Interval (sec)", Min = 5, Max = 120, Default = 30, Callback = function(v)
        lib._autoInterval = v
        if autoOn then lib:StopAutoTheme() lib:StartAutoTheme(v) end
    end})

    return T
end

function Fx:AddVisuals()
    local T = self:Tab("Visuals")
    T:Section("Lighting")
    T:Slider({Name = "Brightness",   Min = 0, Max = 10, Default = math.floor(Lighting.Brightness),  Callback = function(v) Lighting.Brightness = v end})
    T:Slider({Name = "Time of Day",  Min = 0, Max = 24, Default = math.floor(Lighting.ClockTime),   Callback = function(v) Lighting.ClockTime   = v end})
    T:Toggle({Name = "Fullbright",   Default = false, Callback = function(v)
        Lighting.Brightness    = v and 3   or 2
        Lighting.FogEnd        = v and 1e9 or 1e5
        Lighting.GlobalShadows = not v
        Lighting.Ambient       = v and Color3.new(1,1,1) or Color3.fromRGB(127,127,127)
    end})
    T:Toggle({Name = "No Fog",       Default = false, Callback = function(v) Lighting.FogEnd = v and 1e9 or 1e5 end})
    T:Toggle({Name = "Global Shadows", Default = Lighting.GlobalShadows, Callback = function(v) Lighting.GlobalShadows = v end})
    return T
end

return Fx

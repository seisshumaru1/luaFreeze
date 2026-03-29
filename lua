--[[
  Unknown Hub - Steal a Brainrot
  Tabs: Home | Movement | Utilities | Server | Event
  Features: Auto Steal, Auto Lock, Auto Collect, Auto Duel,
            WalkSpeed, JumpPower, Noclip, Inf Jump,
            ESP, Anti-AFK, Teleport to Conveyor
  Style: Sidebar tabs + sliders (like ZZZ Hub v2.5)
--]]

local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenSvc  = game:GetService("TweenService")
local VUser     = game:GetService("VirtualUser")
local LP        = Players.LocalPlayer
local Char, Hum, Root

local function refreshChar()
    Char = LP.Character
    if not Char then return end
    Hum  = Char:FindFirstChildOfClass("Humanoid")
    Root = Char:FindFirstChild("HumanoidRootPart")
end
refreshChar()
LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    refreshChar()
end)

-- State
local S = {
    autoSteal     = false,
    autoLock      = false,
    autoCollect   = false,
    autoDuel      = false,
    autoRebirth   = false,
    noclip        = false,
    infJump       = false,
    jumpBypass    = false,
    antiAfk       = false,
    esp           = false,
    walkSpeed     = 16,
    maxSpeed      = 16,
    jumpPower     = 50,
}

------------------------------------------------------------
-- FEATURE LOOPS
------------------------------------------------------------

-- Noclip
RunService.Stepped:Connect(function()
    if S.noclip and Char then
        for _,p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- Inf Jump / Jump Bypass
UIS.JumpRequest:Connect(function()
    if (S.infJump or S.jumpBypass) and Hum then
        Hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti-AFK
LP.Idled:Connect(function()
    if S.antiAfk then
        VUser:CaptureController()
        VUser:ClickButton2(Vector2.new())
    end
end)

-- Auto Steal: walk to nearest Brainrot not owned by LP and steal it
RunService.Heartbeat:Connect(function()
    if not S.autoSteal or not Root then return end
    local workspace = game.Workspace
    local closest, closestDist = nil, math.huge
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Brainrot" or obj.Name == "BrainrotModel"
            or (obj:IsA("Model") and obj:FindFirstChild("Steal")) then
            local pos = obj:IsA("Model")
                and (obj.PrimaryPart and obj.PrimaryPart.Position)
                or obj.Position
            if pos then
                local dist = (Root.Position - pos).Magnitude
                if dist < closestDist then
                    closest, closestDist = obj, dist
                end
            end
        end
    end
    if closest then
        local pos = closest:IsA("Model")
            and closest.PrimaryPart.Position
            or closest.Position
        Root.CFrame = CFrame.new(pos + Vector3.new(0,3,0))
        -- Fire steal remote if present
        local stealRemote = closest:FindFirstChild("Steal")
            or game.ReplicatedStorage:FindFirstChild("StealBrainrot", true)
        if stealRemote and stealRemote:IsA("RemoteEvent") then
            stealRemote:FireServer(closest)
        elseif stealRemote and stealRemote:IsA("RemoteFunction") then
            stealRemote:InvokeServer(closest)
        end
    end
end)

-- Auto Collect: grab cash/items from conveyor area
RunService.Heartbeat:Connect(function()
    if not S.autoCollect or not Root then return end
    for _,obj in ipairs(game.Workspace:GetDescendants()) do
        if obj.Name == "Cash" or obj.Name == "Coin"
            or obj.Name == "Money" or obj.Name == "Collectible" then
            local p = obj:IsA("BasePart") and obj.Position
                or (obj.PrimaryPart and obj.PrimaryPart.Position)
            if p and (Root.Position - p).Magnitude < 60 then
                Root.CFrame = CFrame.new(p)
            end
        end
    end
end)

-- Auto Lock Base
RunService.Heartbeat:Connect(function()
    if not S.autoLock then return end
    local lockBtn = LP.PlayerGui:FindFirstChild("LockBase", true)
        or LP.PlayerGui:FindFirstChild("Lock", true)
    local lockRemote = game.ReplicatedStorage:FindFirstChild("LockBase", true)
        or game.ReplicatedStorage:FindFirstChild("Lock", true)
    if lockRemote and lockRemote:IsA("RemoteEvent") then
        lockRemote:FireServer(true)
    end
    if lockBtn and lockBtn:IsA("TextButton") and lockBtn.Visible then
        lockBtn:FireClickEvent()
    end
end)

-- Auto Duel
RunService.Heartbeat:Connect(function()
    if not S.autoDuel then return end
    local btn = LP.PlayerGui:FindFirstChild("AcceptDuel",true)
        or LP.PlayerGui:FindFirstChild("DuelAccept",true)
        or LP.PlayerGui:FindFirstChild("Duel",true)
    if btn and btn:IsA("TextButton") and btn.Visible then
        btn:FireClickEvent()
    end
end)

-- Auto Rebirth
RunService.Heartbeat:Connect(function()
    if not S.autoRebirth then return end
    local rb = game.ReplicatedStorage:FindFirstChild("Rebirth",true)
    if rb and rb:IsA("RemoteEvent") then
        rb:FireServer()
    end
end)

-- ESP
local espBoxes = {}
local function addESP(plr)
    if plr == LP then return end
    local function makeBox(c)
        if not c then return end
        if espBoxes[plr] then espBoxes[plr]:Destroy() end
        local b = Instance.new("SelectionBox")
        b.Adornee = c
        b.Color3 = Color3.fromRGB(0,170,255)
        b.LineThickness = 0.04
        b.SurfaceTransparency = 0.75
        b.SurfaceColor3 = Color3.fromRGB(0,170,255)
        b.Parent = game.CoreGui
        espBoxes[plr] = b
    end
    makeBox(plr.Character)
    plr.CharacterAdded:Connect(function(c)
        task.wait(1)
        if S.esp then makeBox(c) end
    end)
end
local function clearESP()
    for _,b in pairs(espBoxes) do b:Destroy() end
    espBoxes = {}
end

-- Teleport to Conveyor
local function tpToConveyor()
    local conveyor = game.Workspace:FindFirstChild("Conveyor", true)
        or game.Workspace:FindFirstChild("ConveyorBelt", true)
        or game.Workspace:FindFirstChild("BrainrotSpawner", true)
    if conveyor and Root then
        local p = conveyor:IsA("BasePart") and conveyor.Position
            or (conveyor.PrimaryPart and conveyor.PrimaryPart.Position)
        if p then Root.CFrame = CFrame.new(p + Vector3.new(0,5,0)) end
    end
end

-- Teleport to own base
local function tpToBase()
    local base = game.Workspace:FindFirstChild(LP.Name, true)
        or game.Workspace:FindFirstChild("Base", true)
    if base and Root then
        local p = base:IsA("BasePart") and base.Position
            or (base.PrimaryPart and base.PrimaryPart.Position)
        if p then Root.CFrame = CFrame.new(p + Vector3.new(0,5,0)) end
    end
end

------------------------------------------------------------
-- GUI SETUP
------------------------------------------------------------
if game:GetService("CoreGui"):FindFirstChild("UnknownHub") then
    game:GetService("CoreGui").UnknownHub:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name           = "UnknownHub"
Gui.ResetOnSpawn   = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent         = game:GetService("CoreGui")

-- Outer window
local Win = Instance.new("Frame")
Win.Name             = "Window"
Win.Size             = UDim2.new(0,720,0,480)
Win.Position         = UDim2.new(0.5,-360,0.5,-240)
Win.BackgroundColor3 = Color3.fromRGB(22,22,22)
Win.BorderSizePixel  = 0
Win.Active           = true
Win.ClipsDescendants = true
Win.Parent           = Gui
Instance.new("UICorner", Win).CornerRadius = UDim.new(0,10)

-- Title bar
local TBar = Instance.new("Frame")
TBar.Size             = UDim2.new(1,0,0,40)
TBar.BackgroundColor3 = Color3.fromRGB(18,18,18)
TBar.BorderSizePixel  = 0
TBar.Active           = true
TBar.ZIndex           = 5
TBar.Parent           = Win

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Text                  = "Unknown Hub  |  Steal a Brainrot"
TitleLbl.Size                  = UDim2.new(1,-80,1,0)
TitleLbl.Position              = UDim2.new(0,16,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3            = Color3.fromRGB(230,230,230)
TitleLbl.TextSize              = 16
TitleLbl.Font                  = Enum.Font.GothamBold
TitleLbl.TextXAlignment        = Enum.TextXAlignment.Left
TitleLbl.ZIndex                = 6
TitleLbl.Parent                = TBar

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size             = UDim2.new(0,28,0,28)
CloseBtn.Position         = UDim2.new(1,-34,0,6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(196,43,43)
CloseBtn.Text             = "✕"
CloseBtn.TextColor3       = Color3.fromRGB(255,255,255)
CloseBtn.TextSize         = 14
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.BorderSizePixel  = 0
CloseBtn.ZIndex           = 6
CloseBtn.Parent           = TBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,5)
CloseBtn.MouseButton1Click:Connect(function()
    clearESP(); Gui:Destroy()
end)

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Size             = UDim2.new(0,28,0,28)
MinBtn.Position         = UDim2.new(1,-66,0,6)
MinBtn.BackgroundColor3 = Color3.fromRGB(50,50,60)
MinBtn.Text             = "–"
MinBtn.TextColor3       = Color3.fromRGB(200,200,200)
MinBtn.TextSize         = 18
MinBtn.Font             = Enum.Font.GothamBold
MinBtn.BorderSizePixel  = 0
MinBtn.ZIndex           = 6
MinBtn.Parent           = TBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,5)
local mini = false
MinBtn.MouseButton1Click:Connect(function()
    mini = not mini
    Win.Size = mini
        and UDim2.new(0,720,0,40)
        or  UDim2.new(0,720,0,480)
end)

------------------------------------------------------------
-- DRAG
------------------------------------------------------------
local drag, dStart, dPos = false, nil, nil
TBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag  = true
        dStart = UIS:GetMouseLocation()
        dPos   = Win.Position
    end
end)
TBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        drag = false
    end
end)
RunService.RenderStepped:Connect(function()
    if drag and dStart then
        local d = UIS:GetMouseLocation() - dStart
        Win.Position = UDim2.new(
            dPos.X.Scale, dPos.X.Offset + d.X,
            dPos.Y.Scale, dPos.Y.Offset + d.Y
        )
    end
end)

------------------------------------------------------------
-- SIDEBAR
------------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Size             = UDim2.new(0,170,1,-40)
Sidebar.Position         = UDim2.new(0,0,0,40)
Sidebar.BackgroundColor3 = Color3.fromRGB(28,28,28)
Sidebar.BorderSizePixel  = 0
Sidebar.Parent           = Win

-- Player info card at bottom of sidebar
local PlayerCard = Instance.new("Frame")
PlayerCard.Size             = UDim2.new(1,0,0,50)
PlayerCard.Position         = UDim2.new(0,0,1,-50)
PlayerCard.BackgroundColor3 = Color3.fromRGB(20,20,20)
PlayerCard.BorderSizePixel  = 0
PlayerCard.Parent           = Sidebar

local PName = Instance.new("TextLabel")
PName.Text                  = LP.Name
PName.Size                  = UDim2.new(1,-10,0,20)
PName.Position              = UDim2.new(0,10,0,8)
PName.BackgroundTransparency = 1
PName.TextColor3            = Color3.fromRGB(200,200,200)
PName.TextSize              = 13
PName.Font                  = Enum.Font.GothamBold
PName.TextXAlignment        = Enum.TextXAlignment.Left
PName.Parent                = PlayerCard

local PSub = Instance.new("TextLabel")
PSub.Text                  = "Unknown Hub v1.0"
PSub.Size                  = UDim2.new(1,-10,0,14)
PSub.Position              = UDim2.new(0,10,0,28)
PSub.BackgroundTransparency = 1
PSub.TextColor3            = Color3.fromRGB(120,120,120)
PSub.TextSize              = 10
PSub.Font                  = Enum.Font.Gotham
PSub.TextXAlignment        = Enum.TextXAlignment.Left
PSub.Parent                = PlayerCard

-- Content area (right panel)
local Content = Instance.new("Frame")
Content.Size             = UDim2.new(1,-170,1,-40)
Content.Position         = UDim2.new(0,170,0,40)
Content.BackgroundColor3 = Color3.fromRGB(32,32,32)
Content.BorderSizePixel  = 0
Content.ClipsDescendants = true
Content.Parent           = Win

------------------------------------------------------------
-- TAB SYSTEM
------------------------------------------------------------
local tabPages   = {}
local tabButtons = {}
local activeTab  = nil
local tabY       = 10

local function switchTab(name)
    for n,pg in pairs(tabPages)   do pg.Visible = (n == name) end
    for n,btn in pairs(tabButtons) do
        btn.BackgroundColor3 = (n == name)
            and Color3.fromRGB(0,140,255)
            or  Color3.fromRGB(38,38,38)
        btn.TextColor3 = (n == name)
            and Color3.fromRGB(255,255,255)
            or  Color3.fromRGB(180,180,180)
    end
end

local function newTab(name)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,-16,0,40)
    btn.Position         = UDim2.new(0,8,0,tabY)
    btn.BackgroundColor3 = Color3.fromRGB(38,38,38)
    btn.Text             = name
    btn.TextColor3       = Color3.fromRGB(180,180,180)
    btn.TextSize         = 14
    btn.Font             = Enum.Font.GothamSemibold
    btn.BorderSizePixel  = 0
    btn.Parent           = Sidebar
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    local page = Instance.new("ScrollingFrame")
    page.Size             = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel  = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(0,140,255)
    page.Visible          = false
    page.CanvasSize       = UDim2.new(0,0,0,0)
    page.Parent           = Content
    Instance.new("UIPadding", page).PaddingTop = UDim.new(0,12)

    tabPages[name]   = page
    tabButtons[name] = btn
    tabY = tabY + 46

    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    return page
end

-- Create all tabs
local homeTab       = newTab("Home")
local movementTab   = newTab("Movement")
local utilitiesTab  = newTab("Utilities")
local serverTab     = newTab("Server")
local eventTab      = newTab("Event")

------------------------------------------------------------
-- WIDGET BUILDERS
------------------------------------------------------------
local function getPageY(page)
    local max = 0
    for _,c in ipairs(page:GetChildren()) do
        if c:IsA("GuiObject") then
            local b = c.Position.Y.Offset + c.Size.Y.Offset
            if b > max then max = b end
        end
    end
    return max + 8
end

local function sectionHeader(page, txt)
    local y = getPageY(page)
    local l = Instance.new("TextLabel")
    l.Text = txt
    l.Size = UDim2.new(1,-24,0,22)
    l.Position = UDim2.new(0,12,0,y)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(170,170,170)
    l.TextSize = 13
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = page
    page.CanvasSize = UDim2.new(0,0,0,y+30)
end

-- Toggle widget (pill-style like ZZZ Hub)
local function addToggle(page, label, onEn, onDis)
    local y = getPageY(page)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-24,0,38)
    row.Position = UDim2.new(0,12,0,y)
    row.BackgroundColor3 = Color3.fromRGB(42,42,42)
    row.BorderSizePixel = 0
    row.Parent = page
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,6)

    local lbl = Instance.new("TextLabel")
    lbl.Text = label
    lbl.Size = UDim2.new(1,-80,1,0)
    lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.TextSize = 14
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    -- Pill toggle
    local pill = Instance.new("Frame")
    pill.Size = UDim2.new(0,46,0,24)
    pill.Position = UDim2.new(1,-58,0.5,-12)
    pill.BackgroundColor3 = Color3.fromRGB(80,80,80)
    pill.BorderSizePixel = 0
    pill.Parent = row
    Instance.new("UICorner",pill).CornerRadius = UDim.new(0,12)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0,18,0,18)
    knob.Position = UDim2.new(0,3,0.5,-9)
    knob.BackgroundColor3 = Color3.fromRGB(200,200,200)
    knob.BorderSizePixel = 0
    knob.Parent = pill
    Instance.new("UICorner",knob).CornerRadius = UDim.new(1,0)

    local pillBtn = Instance.new("TextButton")
    pillBtn.Size = UDim2.new(1,0,1,0)
    pillBtn.BackgroundTransparency = 1
    pillBtn.Text = ""
    pillBtn.Parent = pill

    local on = false
    pillBtn.MouseButton1Click:Connect(function()
        on = not on
        if on then
            pill.BackgroundColor3 = Color3.fromRGB(0,140,255)
            TweenSvc:Create(knob, TweenInfo.new(0.15),
                {Position=UDim2.new(1,-21,0.5,-9)}
            ):Play()
            if onEn then onEn() end
        else
            pill.BackgroundColor3 = Color3.fromRGB(80,80,80)
            TweenSvc:Create(knob, TweenInfo.new(0.15),
                {Position=UDim2.new(0,3,0.5,-9)}
            ):Play()
            if onDis then onDis() end
        end
    end)
    page.CanvasSize = UDim2.new(0,0,0,y+46)
end

-- Slider widget
local function addSlider(page, label, min, max, def, cb)
    local y = getPageY(page)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,-24,0,58)
    row.Position = UDim2.new(0,12,0,y)
    row.BackgroundColor3 = Color3.fromRGB(42,42,42)
    row.BorderSizePixel = 0
    row.Parent = page
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,6)

    local topRow = Instance.new("Frame")
    topRow.Size = UDim2.new(1,0,0,24)
    topRow.BackgroundTransparency = 1
    topRow.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Text = label
    lbl.Size = UDim2.new(0.6,0,1,0)
    lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(220,220,220)
    lbl.TextSize = 13
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = topRow

    local valLbl = Instance.new("TextLabel")
    valLbl.Text = tostring(def)
    valLbl.Size = UDim2.new(0.3,0,1,0)
    valLbl.Position = UDim2.new(0.65,0,0,0)
    valLbl.BackgroundTransparency = 1
    valLbl.TextColor3 = Color3.fromRGB(255,255,255)
    valLbl.TextSize = 13
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = topRow

    -- Track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1,-24,0,6)
    track.Position = UDim2.new(0,12,0,32)
    track.BackgroundColor3 = Color3.fromRGB(65,65,65)
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,140,255)
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0,18,0,18)
    thumb.Position = UDim2.new((def-min)/(max-min),-9,0.5,-9)
    thumb.BackgroundColor3 = Color3.fromRGB(240,240,240)
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 2
    thumb.Parent = track
    Instance.new("UICorner",thumb).CornerRadius = UDim.new(1,0)

    -- Use button
    local useBtn = Instance.new("TextButton")
    useBtn.Size = UDim2.new(0,52,0,26)
    useBtn.Position = UDim2.new(1,-64,0,26)
    useBtn.BackgroundColor3 = Color3.fromRGB(0,140,255)
    useBtn.Text = "Use"
    useBtn.TextColor3 = Color3.fromRGB(255,255,255)
    useBtn.TextSize = 13
    useBtn.Font = Enum.Font.GothamBold
    useBtn.BorderSizePixel = 0
    useBtn.Parent = row
    Instance.new("UICorner",useBtn).CornerRadius = UDim.new(0,5)

    local curVal = def
    local sliding = false

    local function setVal(v)
        v = math.clamp(math.round(v*100)/100, min, max)
        curVal = v
        local t = (v-min)/(max-min)
        fill.Size = UDim2.new(t,0,1,0)
        thumb.Position = UDim2.new(t,-9,0.5,-9)
        valLbl.Text = tostring(math.round(v*100)/100)
    end

    thumb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if sliding then
            local mx = UIS:GetMouseLocation().X
            local abs = track.AbsolutePosition.X
            local sz  = track.AbsoluteSize.X
            local t   = math.clamp((mx-abs)/sz, 0, 1)
            setVal(min + (max-min)*t)
        end
    end)

    useBtn.MouseButton1Click:Connect(function()
        if cb then cb(curVal) end
    end)
    page.CanvasSize = UDim2.new(0,0,0,y+66)
end

-- Button widget
local function addButton(page, label, cb)
    local y = getPageY(page)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-24,0,36)
    btn.Position = UDim2.new(0,12,0,y)
    btn.BackgroundColor3 = Color3.fromRGB(0,140,255)
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 14
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = page
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
    btn.MouseButton1Click:Connect(function() if cb then cb() end end)
    page.CanvasSize = UDim2.new(0,0,0,y+44)
end

------------------------------------------------------------
-- HOME TAB
------------------------------------------------------------
sectionHeader(homeTab, "Brainrot")
addToggle(homeTab, "Auto Steal",
    function() S.autoSteal = true  end,
    function() S.autoSteal = false end)
addToggle(homeTab, "Auto Lock Base",
    function() S.autoLock = true  end,
    function() S.autoLock = false end)
addToggle(homeTab, "Auto Collect Cash",
    function() S.autoCollect = true  end,
    function() S.autoCollect = false end)
addToggle(homeTab, "Auto Duel",
    function() S.autoDuel = true  end,
    function() S.autoDuel = false end)
addToggle(homeTab, "Auto Rebirth",
    function() S.autoRebirth = true  end,
    function() S.autoRebirth = false end)

------------------------------------------------------------
-- MOVEMENT TAB
------------------------------------------------------------
sectionHeader(movementTab, "Speed & Jump")
addToggle(movementTab, "Jump Bypass",
    function() S.jumpBypass = true  end,
    function() S.jumpBypass = false end)
addToggle(movementTab, "Speed Boost",
    function() S.speedBoost = true;  if Hum then Hum.WalkSpeed = S.walkSpeed end end,
    function() S.speedBoost = false; if Hum then Hum.WalkSpeed = 16           end end)
addToggle(movementTab, "Jump Boost",
    function() S.infJump = true;  if Hum then Hum.JumpPower = S.jumpPower end end,
    function() S.infJump = false; if Hum then Hum.JumpPower = 50            end end)

addSlider(movementTab, "Walk Speed", 16, 100, 16, function(v)
    S.walkSpeed = v
    if Hum then Hum.WalkSpeed = v end
end)
addSlider(movementTab, "Max Speed", 16, 200, 16, function(v)
    S.maxSpeed = v
    if Hum then Hum.WalkSpeed = math.min(Hum.WalkSpeed, v) end
end)
addSlider(movementTab, "Jump Power", 50, 500, 50, function(v)
    S.jumpPower = v
    if Hum then Hum.JumpPower = v end
end)
addSlider(movementTab, "Jump Boost Power", 50, 500, 100, function(v)
    if Hum then Hum.JumpPower = v end
end)

sectionHeader(movementTab, "Player Movement")
addToggle(movementTab, "Noclip",
    function() S.noclip = true  end,
    function()
        S.noclip = false
        if Char then
            for _,p in ipairs(Char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end)
addToggle(movementTab, "Inf Jump",
    function() S.infJump = true  end,
    function() S.infJump = false end)

------------------------------------------------------------
-- UTILITIES TAB
------------------------------------------------------------
sectionHeader(utilitiesTab, "Visual")
addToggle(utilitiesTab, "ESP (Player Boxes)",
    function()
        S.esp = true
        for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
        Players.PlayerAdded:Connect(function(p) if S.esp then addESP(p) end end)
    end,
    function() S.esp = false; clearESP() end)
addToggle(utilitiesTab, "Anti-AFK",
    function() S.antiAfk = true  end,
    function() S.antiAfk = false end)

------------------------------------------------------------
-- SERVER TAB
------------------------------------------------------------
sectionHeader(serverTab, "Teleport")
addButton(serverTab, "Teleport to Conveyor", tpToConveyor)
addButton(serverTab, "Teleport to My Base",  tpToBase)
addButton(serverTab, "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)
addButton(serverTab, "Hop to New Server", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(
        game.PlaceId,
        game:GetService("HttpService"):GenerateGUID(false),
        LP
    )
end)

------------------------------------------------------------
-- EVENT TAB
------------------------------------------------------------
sectionHeader(eventTab, "Event Features")
addToggle(eventTab, "Auto Duel (Event)",
    function() S.autoDuel = true  end,
    function() S.autoDuel = false end)
addToggle(eventTab, "Auto Collect Event Items",
    function() S.autoCollect = true  end,
    function() S.autoCollect = false end)
addButton(eventTab, "Claim Event Reward", function()
    local r = game.ReplicatedStorage:FindFirstChild("ClaimReward",true)
        or game.ReplicatedStorage:FindFirstChild("EventReward",true)
    if r and r:IsA("RemoteEvent") then r:FireServer() end
end)

-- Start on Home tab
switchTab("Home")

------------------------------------------------------------
-- LOAD NOTIFICATION
------------------------------------------------------------
local nGui = Instance.new("ScreenGui")
nGui.ResetOnSpawn = false
nGui.Parent = game:GetService("CoreGui")
local nf = Instance.new("TextLabel", nGui)
nf.Size = UDim2.new(0,300,0,38)
nf.Position = UDim2.new(0.5,-150,0,14)
nf.BackgroundColor3 = Color3.fromRGB(0,140,255)
nf.Text = "Unknown Hub  |  Steal a Brainrot  ✓"
nf.TextColor3 = Color3.fromRGB(255,255,255)
nf.TextSize = 14
nf.Font = Enum.Font.GothamBold
nf.BorderSizePixel = 0
Instance.new("UICorner",nf).CornerRadius = UDim.new(0,8)
task.delay(3, function() nGui:Destroy() end)

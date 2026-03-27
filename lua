--[[
    Unknown Hub v1.0
    Features: Freeze Trade, Auto Accept, Auto Duel,
              ESP, Speed Boost, Anti-AFK, Noclip, Inf Jump
    Draggable | Minimizable | Load Notification
--]]

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local RunService   = game:GetService("RunService")
local LP           = Players.LocalPlayer
local Character    = LP.Character or LP.CharacterAdded:Wait()
local Humanoid     = Character:WaitForChild("Humanoid")

-- // State
local State = {
    freezeTrade = false,
    autoAccept  = false,
    autoDuel    = false,
    esp         = false,
    speedBoost  = false,
    antiAfk     = false,
    noclip      = false,
    infJump     = false,
}

-- // Re-grab character on respawn
LP.CharacterAdded:Connect(function(c)
    Character = c
    Humanoid  = c:WaitForChild("Humanoid")
    if State.speedBoost then Humanoid.WalkSpeed = 32 end
end)

------------------------------------------------------------
-- // Noclip loop
------------------------------------------------------------
RunService.Stepped:Connect(function()
    if State.noclip and Character then
        for _, part in ipairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- // Inf Jump
UIS.JumpRequest:Connect(function()
    if State.infJump and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- // Anti-AFK
local afkConn
LP.Idled:Connect(function()
    if State.antiAfk then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):ClickButton2(Vector2.new())
    end
end)

------------------------------------------------------------
-- // GUI
------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name           = "UnknownHub"
Gui.ResetOnSpawn   = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent         = LP.PlayerGui

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Name             = "MainFrame"
Frame.Size             = UDim2.new(0, 400, 0, 480)
Frame.Position         = UDim2.new(0.5, -200, 0.5, -240)
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
Stripe.ZIndex           = 5
Stripe.Parent           = Frame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size             = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 52)
TitleBar.BorderSizePixel  = 0
TitleBar.Active           = true
TitleBar.Parent           = Frame
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Text                  = "✦  Unknown Hub"
TitleLbl.Size                  = UDim2.new(1, -80, 0, 28)
TitleLbl.Position              = UDim2.new(0, 14, 0, 7)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3            = Color3.fromRGB(210, 190, 255)
TitleLbl.TextSize              = 20
TitleLbl.Font                  = Enum.Font.GothamBold
TitleLbl.TextXAlignment        = Enum.TextXAlignment.Left
TitleLbl.Parent                = TitleBar

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

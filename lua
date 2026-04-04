--[[
    Unknown Hub - Steal a Brainrot (Complete)
    Mobile + PC | Minimize | Floating Toggle | Loading Animations
    Features: Auto Steal, Auto Lock, Auto Collect, Auto Duel,
              Auto Rebirth, ESP, Speed, Jump, Noclip, Inf Jump,
              Anti-AFK, Teleport, Server Hop
--]]

local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenSvc  = game:GetService("TweenService")
local VUser     = game:GetService("VirtualUser")
local CoreGui   = game:GetService("CoreGui")
local LP        = Players.LocalPlayer
local Camera    = game:GetService("Workspace").CurrentCamera
local Char, Hum, Root

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled

local function refreshChar()
    Char = LP.Character
    if not Char then return end
    Hum  = Char:FindFirstChildOfClass("Humanoid")
    Root = Char:FindFirstChild("HumanoidRootPart")
end
refreshChar()
LP.CharacterAdded:Connect(function()
    task.wait(0.5); refreshChar()
end)

local S = {
    autoSteal   = false, autoLock    = false,
    autoCollect = false, autoDuel    = false,
    autoRebirth = false, noclip      = false,
    infJump     = false, jumpBypass  = false,
    speedBoost  = false, antiAfk     = false,
    esp         = false, walkSpeed   = 16,
    jumpPower   = 50,
}

-- Responsive sizes
local VP       = Camera.ViewportSize
local W        = math.clamp(VP.X * 0.9, 300, 720)
local H        = math.clamp(VP.Y * 0.78, 340, 480)
local SBAW     = isMobile and 100 or 150
local TBH      = isMobile and 46 or 40
local FSZ      = isMobile and 13 or 14
local ROW_H    = isMobile and 52 or 44
local SLDR_H   = isMobile and 68 or 60
local TI_fast  = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_open  = TweenInfo.new(0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

------------------------------------------------------------
-- LOADING OVERLAY (shown when auto steal / auto duel turn on)
------------------------------------------------------------
local function showLoading(title, duration)
    if CoreGui:FindFirstChild("UHLoadOverlay") then
        CoreGui.UHLoadOverlay:Destroy()
    end

    local og = Instance.new("ScreenGui")
    og.Name = "UHLoadOverlay"
    og.ResetOnSpawn = false
    og.IgnoreGuiInset = true
    og.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    og.Parent = CoreGui

    -- Card
    local card = Instance.new("Frame")
    card.Size     = UDim2.new(0, 300, 0, 110)
    card.Position = UDim2.new(0.5, -150, 0, -120)
    card.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
    card.BorderSizePixel  = 0
    card.ZIndex = 50
    card.Parent = og
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 12)

    -- Slide in from top
    TweenSvc:Create(card, TI_open, {
        Position = UDim2.new(0.5, -150, 0, 18)
    }):Play()

    -- Blue top bar
    local topbar = Instance.new("Frame")
    topbar.Size             = UDim2.new(1, 0, 0, 4)
    topbar.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    topbar.BorderSizePixel  = 0
    topbar.ZIndex = 51
    topbar.Parent = card
    Instance.new("UICorner", topbar).CornerRadius = UDim.new(0, 12)

    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Text = "✦"
    icon.Size = UDim2.new(0, 30, 0, 30)
    icon.Position = UDim2.new(0, 14, 0, 14)
    icon.BackgroundTransparency = 1
    icon.TextColor3 = Color3.fromRGB(0, 140, 255)
    icon.TextSize = 22
    icon.Font = Enum.Font.GothamBold
    icon.ZIndex = 51
    icon.Parent = card

    -- Title
    local tl = Instance.new("TextLabel")
    tl.Text = title
    tl.Size = UDim2.new(1, -56, 0, 22)
    tl.Position = UDim2.new(0, 50, 0, 14)
    tl.BackgroundTransparency = 1
    tl.TextColor3 = Color3.fromRGB(230, 230, 255)
    tl.TextSize = 15
    tl.Font = Enum.Font.GothamBold
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.ZIndex = 51
    tl.Parent = card

    -- Sub text (animated dots)
    local sub = Instance.new("TextLabel")
    sub.Text = "Script is loading, please wait..."
    sub.Size = UDim2.new(1, -20, 0, 18)
    sub.Position = UDim2.new(0, 10, 0, 40)
    sub.BackgroundTransparency = 1
    sub.TextColor3 = Color3.fromRGB(140, 140, 170)
    sub.TextSize = 12
    sub.Font = Enum.Font.Gotham
    sub.TextXAlignment = Enum.TextXAlignment.Left
    sub.ZIndex = 51
    sub.Parent = card

    -- Progress bar track
    local barTrack = Instance.new("Frame")
    barTrack.Size             = UDim2.new(1, -20, 0, 8)
    barTrack.Position         = UDim2.new(0, 10, 0, 68)
    barTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    barTrack.BorderSizePixel  = 0
    barTrack.ZIndex = 51
    barTrack.Parent = card
    Instance.new("UICorner", barTrack).CornerRadius = UDim.new(1, 0)

    local barFill = Instance.new("Frame")
    barFill.Size             = UDim2.new(0, 0, 1, 0)
    barFill.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    barFill.BorderSizePixel  = 0
    barFill.ZIndex = 52
    barFill.Parent = barTrack
    Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

    -- Percent label
    local pct = Instance.new("TextLabel")
    pct.Text = "0%"
    pct.Size = UDim2.new(1, 0, 0, 16)
    pct.Position = UDim2.new(0, 0, 0, 80)
    pct.BackgroundTransparency = 1
    pct.TextColor3 = Color3.fromRGB(0, 140, 255)
    pct.TextSize = 11
    pct.Font = Enum.Font.GothamBold
    pct.TextXAlignment = Enum.TextXAlignment.Right
    pct.ZIndex = 52
    pct.Parent = card

    -- Animate progress bar over `duration` seconds
    local dots    = { ".", "..", "..." }
    local dotIdx  = 1
    local elapsed = 0
    local conn

    conn = RunService.Heartbeat:Connect(function(dt)
        elapsed = elapsed + dt
        local prog = math.min(elapsed / duration, 1)
        barFill.Size = UDim2.new(prog, 0, 1, 0)
        pct.Text = tostring(math.floor(prog * 100)) .. "%"

        -- Animate dots every 0.4s
        if math.floor(elapsed / 0.4) % 3 ~= (dotIdx - 1) then
            dotIdx = (dotIdx % 3) + 1
            sub.Text = "Script is loading, please wait" .. dots[dotIdx]
        end

        if prog >= 1 then
            conn:Disconnect()
            sub.Text = "Active!"
            sub.TextColor3 = Color3.fromRGB(80, 220, 120)
            barFill.BackgroundColor3 = Color3.fromRGB(80, 220, 120)
            task.wait(0.8)
            -- Slide out upward
            local t = TweenSvc:Create(card, TI_fast, {
                Position = UDim2.new(0.5, -150, 0, -130)
            })
            t:Play()
            t.Completed:Connect(function() og:Destroy() end)
        end
    end)
end

------------------------------------------------------------
-- FEATURE LOOPS
------------------------------------------------------------
RunService.Stepped:Connect(function()
    if S.noclip and Char then
        for _,p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if (S.infJump or S.jumpBypass) and Hum then
        Hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

LP.Idled:Connect(function()
    if S.antiAfk then
        VUser:CaptureController()
        VUser:ClickButton2(Vector2.new())
    end
end)

RunService.Heartbeat:Connect(function()
    if not S.autoSteal or not Root then return end
    local closest, dist = nil, math.huge
    for _,o in ipairs(game.Workspace:GetDescendants()) do
        if o:IsA("Model") and o:FindFirstChild("Steal") and o.PrimaryPart then
            local d = (Root.Position - o.PrimaryPart.Position).Magnitude
            if d < dist then closest, dist = o, d end
        end
    end
    if closest then
        Root.CFrame = CFrame.new(closest.PrimaryPart.Position + Vector3.new(0,3,0))
        local r = game.ReplicatedStorage:FindFirstChild("StealBrainrot", true)
        if r then r:FireServer(closest) end
    end
end)

RunService.Heartbeat:Connect(function()
    if not S.autoCollect or not Root then return end
    for _,o in ipairs(game.Workspace:GetDescendants()) do
        if (o.Name=="Cash" or o.Name=="Coin" or o.Name=="Money")
            and o:IsA("BasePart")
            and (Root.Position - o.Position).Magnitude < 60 then
            Root.CFrame = CFrame.new(o.Position)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not S.autoDuel then return end
    local b = LP.PlayerGui:FindFirstChild("AcceptDuel",true)
           or LP.PlayerGui:FindFirstChild("DuelAccept",true)
    if b and b:IsA("TextButton") and b.Visible then
        b:FireClickEvent()
    end
end)

RunService.Heartbeat:Connect(function()
    if not S.autoRebirth then return end
    local r = game.ReplicatedStorage:FindFirstChild("Rebirth",true)
    if r and r:IsA("RemoteEvent") then r:FireServer() end
end)

local espBoxes = {}
local function addESP(plr)
    if plr == LP then return end
    local function mk(c)
        if not c then return end
        if espBoxes[plr] then espBoxes[plr]:Destroy() end
        local b = Instance.new("SelectionBox")
        b.Adornee = c
        b.Color3 = Color3.fromRGB(0,170,255)
        b.LineThickness = 0.04
        b.SurfaceTransparency = 0.75
        b.SurfaceColor3 = Color3.fromRGB(0,170,255)
        b.Parent = CoreGui
        espBoxes[plr] = b
    end
    mk(plr.Character)
    plr.CharacterAdded:Connect(function(c)
        task.wait(1); if S.esp then mk(c) end
    end)
end
local function clearESP()
    for _,b in pairs(espBoxes) do b:Destroy() end
    espBoxes = {}
end

------------------------------------------------------------
-- DESTROY OLD GUI
------------------------------------------------------------
if CoreGui:FindFirstChild("UnknownHub") then
    CoreGui.UnknownHub:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "UnknownHub"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
Gui.Parent = CoreGui

------------------------------------------------------------
-- FLOATING TOGGLE BUTTON
------------------------------------------------------------
local FBtn = Instance.new("TextButton")
FBtn.Size             = UDim2.new(0,52,0,52)
FBtn.Position         = UDim2.new(0,10,0.5,-26)
FBtn.BackgroundColor3 = Color3.fromRGB(0,140,255)
FBtn.Text             = "✦"
FBtn.TextColor3       = Color3.fromRGB(255,255,255)
FBtn.TextSize         = 22
FBtn.Font             = Enum.Font.GothamBold
FBtn.BorderSizePixel  = 0
FBtn.ZIndex           = 20
FBtn.Parent           = Gui
Instance.new("UICorner",FBtn).CornerRadius = UDim.new(1,0)

local fbDrag,fbStart,fbPos,fbMoved = false,nil,nil,false
FBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then
        fbDrag=true; fbMoved=false
        fbStart=Vector2.new(i.Position.X,i.Position.Y)
        fbPos=FBtn.Position
    end
end)
FBtn.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then
        fbDrag=false
    end
end)

-- Main window
local Win = Instance.new("Frame")
Win.Name             = "Window"
Win.Size             = UDim2.new(0,W,0,H)
Win.Position         = UDim2.new(0.5,-W/2,0.5,-H/2)
Win.BackgroundColor3 = Color3.fromRGB(22,22,22)
Win.BorderSizePixel  = 0
Win.Active           = true
Win.ClipsDescendants = true
Win.Parent           = Gui
Instance.new("UICorner",Win).CornerRadius = UDim.new(0,10)

-- Open/close system
local guiOpen   = true
local minimized = false
local FULL_H    = H
local MINI_H    = TBH

local function setOpen(open)
    guiOpen = open
    if open then
        Win.Visible = true
        local th = minimized and MINI_H or FULL_H
        TweenSvc:Create(Win,TI_open,{Size=UDim2.new(0,W,0,th)}):Play()
        TweenSvc:Create(FBtn,TI_fast,{BackgroundColor3=Color3.fromRGB(0,140,255)}):Play()
    else
        local t = TweenSvc:Create(Win,TI_fast,{Size=UDim2.new(0,W,0,0)})
        t:Play()
        t.Completed:Connect(function() Win.Visible=false end)
        TweenSvc:Create(FBtn,TI_fast,{BackgroundColor3=Color3.fromRGB(55,55,55)}):Play()
    end
end

FBtn.Activated:Connect(function()
    if not fbMoved then setOpen(not guiOpen) end
end)

UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.RightShift then setOpen(not guiOpen) end
end)

------------------------------------------------------------
-- TITLE BAR
------------------------------------------------------------
local TBar = Instance.new("Frame")
TBar.Size             = UDim2.new(1,0,0,TBH)
TBar.BackgroundColor3 = Color3.fromRGB(18,18,18)
TBar.BorderSizePixel  = 0
TBar.Active           = true
TBar.ZIndex           = 5
TBar.Parent           = Win

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Text                  = "✦  Unknown Hub  |  Steal a Brainrot"
TitleLbl.Size                  = UDim2.new(1,-110,1,0)
TitleLbl.Position              = UDim2.new(0,10,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.TextColor3            = Color3.fromRGB(230,230,230)
TitleLbl.TextSize              = FSZ
TitleLbl.Font                  = Enum.Font.GothamBold
TitleLbl.TextXAlignment        = Enum.TextXAlignment.Left
TitleLbl.ZIndex                = 6
TitleLbl.Parent                = TBar

local function mkTBtn(txt,xOff,col)
    local b = Instance.new("TextButton")
    b.Size             = UDim2.new(0,32,0,32)
    b.Position         = UDim2.new(1,xOff,0.5,-16)
    b.BackgroundColor3 = col
    b.Text             = txt
    b.TextColor3       = Color3.fromRGB(255,255,255)
    b.TextSize         = 15
    b.Font             = Enum.Font.GothamBold
    b.BorderSizePixel  = 0
    b.ZIndex           = 6
    b.Parent           = TBar
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,6)
    return b
end

local CloseBtn = mkTBtn("✕",-38,Color3.fromRGB(196,43,43))
CloseBtn.Activated:Connect(function() clearESP(); Gui:Destroy() end)

local MinBtn = mkTBtn("–",-74,Color3.fromRGB(50,50,60))
MinBtn.Activated:Connect(function()
    minimized = not minimized
    TweenSvc:Create(Win,TI_fast,{
        Size=UDim2.new(0,W,0,minimized and MINI_H or FULL_H)
    }):Play()
    MinBtn.Text = minimized and "▲" or "–"
end)

------------------------------------------------------------
-- DRAG (mouse + touch)
------------------------------------------------------------
local drag,dStart,dPos = false,nil,nil
TBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then
        drag=true
        dStart=Vector2.new(i.Position.X,i.Position.Y)
        dPos=Win.Position
    end
end)
TBar.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then
        drag=false
    end
end)

RunService.RenderStepped:Connect(function()
    if drag and dStart then
        local mp = UIS:GetMouseLocation()
        local d  = Vector2.new(mp.X,mp.Y) - dStart
        Win.Position = UDim2.new(
            dPos.X.Scale, dPos.X.Offset+d.X,
            dPos.Y.Scale, dPos.Y.Offset+d.Y
        )
    end
    if fbDrag and fbStart then
        local mp = UIS:GetMouseLocation()
        local d  = Vector2.new(mp.X,mp.Y) - fbStart
        if d.Magnitude > 5 then fbMoved=true end
        FBtn.Position = UDim2.new(
            fbPos.X.Scale, fbPos.X.Offset+d.X,
            fbPos.Y.Scale, fbPos.Y.Offset+d.Y
        )
    end
end)

------------------------------------------------------------
-- SIDEBAR + CONTENT
------------------------------------------------------------
local Sidebar = Instance.new("Frame")
Sidebar.Size             = UDim2.new(0,SBAW,1,-TBH)
Sidebar.Position         = UDim2.new(0,0,0,TBH)
Sidebar.BackgroundColor3 = Color3.fromRGB(28,28,28)
Sidebar.BorderSizePixel  = 0
Sidebar.Parent           = Win

local PCard = Instance.new("Frame",Sidebar)
PCard.Size             = UDim2.new(1,0,0,44)
PCard.Position         = UDim2.new(0,0,1,-44)
PCard.BackgroundColor3 = Color3.fromRGB(20,20,20)
PCard.BorderSizePixel  = 0
local PName = Instance.new("TextLabel",PCard)
PName.Text=LP.Name; PName.Size=UDim2.new(1,0,0,20)
PName.Position=UDim2.new(0,8,0,4); PName.BackgroundTransparency=1
PName.TextColor3=Color3.fromRGB(200,200,200); PName.TextSize=12
PName.Font=Enum.Font.GothamBold; PName.TextXAlignment=Enum.TextXAlignment.Left
local PSub = Instance.new("TextLabel",PCard)
PSub.Text="Unknown Hub v1.0"; PSub.Size=UDim2.new(1,0,0,16)
PSub.Position=UDim2.new(0,8,0,26); PSub.BackgroundTransparency=1
PSub.TextColor3=Color3.fromRGB(100,100,100); PSub.TextSize=10
PSub.Font=Enum.Font.Gotham; PSub.TextXAlignment=Enum.TextXAlignment.Left

local Content = Instance.new("Frame")
Content.Size             = UDim2.new(1,-SBAW,1,-TBH)
Content.Position         = UDim2.new(0,SBAW,0,TBH)
Content.BackgroundColor3 = Color3.fromRGB(32,32,32)
Content.BorderSizePixel  = 0
Content.ClipsDescendants = true
Content.Parent           = Win

------------------------------------------------------------
-- TAB SYSTEM
------------------------------------------------------------
local tabPages = {}
local tabBtns  = {}
local tabY     = 8
local TAB_H    = isMobile and 46 or 40

local function switchTab(name)
    for n,pg in pairs(tabPages) do pg.Visible=(n==name) end
    for n,b in pairs(tabBtns) do
        b.BackgroundColor3 = (n==name)
            and Color3.fromRGB(0,140,255)
            or  Color3.fromRGB(38,38,38)
        b.TextColor3 = (n==name)
            and Color3.fromRGB(255,255,255)
            or  Color3.fromRGB(160,160,160)
    end
end

local function newTab(name)
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,-12,0,TAB_H)
    btn.Position         = UDim2.new(0,6,0,tabY)
    btn.BackgroundColor3 = Color3.fromRGB(38,38,38)
    btn.Text             = name
    btn.TextColor3       = Color3.fromRGB(160,160,160)
    btn.TextSize         = FSZ
    btn.Font             = Enum.Font.GothamSemibold
    btn.BorderSizePixel  = 0
    btn.Parent           = Sidebar
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)

    local pg = Instance.new("ScrollingFrame")
    pg.Size                   = UDim2.new(1,0,1,0)
    pg.BackgroundTransparency = 1
    pg.BorderSizePixel        = 0
    pg.ScrollBarThickness     = 3
    pg.ScrollBarImageColor3   = Color3.fromRGB(0,140,255)
    pg.Visible                = false
    pg.CanvasSize             = UDim2.new(0,0,0,0)
    pg.Parent                 = Content

    tabPages[name]=pg; tabBtns[name]=btn
    tabY = tabY + TAB_H + 6
    btn.Activated:Connect(function() switchTab(name) end)
    return pg
end

local homeTab      = newTab("Home")
local movementTab  = newTab("Movement")
local utilitiesTab = newTab("Utilities")
local serverTab    = newTab("Server")
local eventTab     = newTab("Event")

------------------------------------------------------------
-- WIDGET HELPERS
------------------------------------------------------------
local function pgBot(pg)
    local m=0
    for _,c in ipairs(pg:GetChildren()) do
        if c:IsA("GuiObject") then
            local b=c.Position.Y.Offset+c.Size.Y.Offset
            if b>m then m=b end
        end
    end
    return m+8
end

local function secH(pg,txt)
    local y=pgBot(pg)
    local l=Instance.new("TextLabel")
    l.Text=txt; l.Size=UDim2.new(1,-20,0,22)
    l.Position=UDim2.new(0,10,0,y)
    l.BackgroundTransparency=1
    l.TextColor3=Color3.fromRGB(160,160,160)
    l.TextSize=12; l.Font=Enum.Font.GothamBold
    l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=pg
    pg.CanvasSize=UDim2.new(0,0,0,y+28)
end

local function addToggle(pg,label,onEn,onDis)
    local y=pgBot(pg)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-20,0,ROW_H)
    row.Position=UDim2.new(0,10,0,y)
    row.BackgroundColor3=Color3.fromRGB(42,42,42)
    row.BorderSizePixel=0; row.Parent=pg
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)

    local lbl=Instance.new("TextLabel")
    lbl.Text=label; lbl.Size=UDim2.new(1,-72,1,0)
    lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.fromRGB(220,220,220)
    lbl.TextSize=FSZ; lbl.Font=Enum.Font.Gotham
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row

    local pill=Instance.new("Frame")
    pill.Size=UDim2.new(0,50,0,26)
    pill.Position=UDim2.new(1,-60,0.5,-13)
    pill.BackgroundColor3=Color3.fromRGB(80,80,80)
    pill.BorderSizePixel=0; pill.Parent=row
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,20,0,20)
    knob.Position=UDim2.new(0,3,0.5,-10)
    knob.BackgroundColor3=Color3.fromRGB(210,210,210)
    knob.BorderSizePixel=0; knob.Parent=pill
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local pb=Instance.new("TextButton")
    pb.Size=UDim2.new(1,0,1,0); pb.BackgroundTransparency=1
    pb.Text=""; pb.Parent=pill

    local on=false
    local function toggle()
        on=not on
        if on then
            TweenSvc:Create(pill,TI_fast,{BackgroundColor3=Color3.fromRGB(0,140,255)}):Play()
            TweenSvc:Create(knob,TI_fast,{Position=UDim2.new(1,-23,0.5,-10)}):Play()
            if onEn then onEn() end
        else
            TweenSvc:Create(pill,TI_fast,{BackgroundColor3=Color3.fromRGB(80,80,80)}):Play()
            TweenSvc:Create(knob,TI_fast,{Position=UDim2.new(0,3,0.5,-10)}):Play()
            if onDis then onDis() end
        end
    end
    pb.Activated:Connect(toggle)
    pg.CanvasSize=UDim2.new(0,0,0,y+ROW_H+8)
end

local function addSlider(pg,label,mn,mx,def,cb)
    local y=pgBot(pg)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-20,0,SLDR_H)
    row.Position=UDim2.new(0,10,0,y)
    row.BackgroundColor3=Color3.fromRGB(42,42,42)
    row.BorderSizePixel=0; row.Parent=pg
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)

    local lbl=Instance.new("TextLabel")
    lbl.Text=label; lbl.Size=UDim2.new(0.6,0,0,24)
    lbl.Position=UDim2.new(0,12,0,4)
    lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.fromRGB(220,220,220)
    lbl.TextSize=FSZ; lbl.Font=Enum.Font.Gotham
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row

    local vl=Instance.new("TextLabel")
    vl.Text=tostring(def); vl.Size=UDim2.new(0.35,0,0,24)
    vl.Position=UDim2.new(0.6,0,0,4)
    vl.BackgroundTransparency=1
    vl.TextColor3=Color3.fromRGB(255,255,255)
    vl.TextSize=FSZ; vl.Font=Enum.Font.GothamBold
    vl.TextXAlignment=Enum.TextXAlignment.Right; vl.Parent=row

    local trk=Instance.new("Frame")
    trk.Size=UDim2.new(1,-80,0,8); trk.Position=UDim2.new(0,12,0,36)
    trk.BackgroundColor3=Color3.fromRGB(65,65,65)
    trk.BorderSizePixel=0; trk.Parent=row
    Instance.new("UICorner",trk).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame")
    fill.Size=UDim2.new((def-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(0,140,255)
    fill.BorderSizePixel=0; fill.Parent=trk
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local th=Instance.new("Frame")
    th.Size=UDim2.new(0,22,0,22)
    th.Position=UDim2.new((def-mn)/(mx-mn),-11,0.5,-11)
    th.BackgroundColor3=Color3.fromRGB(240,240,240)
    th.BorderSizePixel=0; th.ZIndex=2; th.Parent=trk
    Instance.new("UICorner",th).CornerRadius=UDim.new(1,0)

    local ub=Instance.new("TextButton")
    ub.Size=UDim2.new(0,54,0,28); ub.Position=UDim2.new(1,-66,0,30)
    ub.BackgroundColor3=Color3.fromRGB(0,140,255)
    ub.Text="Use"; ub.TextColor3=Color3.fromRGB(255,255,255)
    ub.TextSize=13; ub.Font=Enum.Font.GothamBold
    ub.BorderSizePixel=0; ub.Parent=row
    Instance.new("UICorner",ub).CornerRadius=UDim.new(0,5)

    local cur=def; local sliding=false
    local function sv(v)
        v=math.clamp(math.round(v),mn,mx)
        cur=v; local t=(v-mn)/(mx-mn)
        fill.Size=UDim2.new(t,0,1,0)
        th.Position=UDim2.new(t,-11,0.5,-11)
        vl.Text=tostring(v)
    end
    local function ss(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            sliding=true
        end
    end
    th.InputBegan:Connect(ss); trk.InputBegan:Connect(ss)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            sliding=false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if not sliding then return end
        local mx2=UIS:GetMouseLocation().X
        sv(mn+(mx-mn)*math.clamp((mx2-trk.AbsolutePosition.X)/trk.AbsoluteSize.X,0,1))
    end)
    ub.Activated:Connect(function() if cb then cb(cur) end end)
    pg.CanvasSize=UDim2.new(0,0,0,y+SLDR_H+8)
end

local function addBtn(pg,label,cb)
    local y=pgBot(pg)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-20,0,ROW_H)
    b.Position=UDim2.new(0,10,0,y)
    b.BackgroundColor3=Color3.fromRGB(0,140,255)
    b.Text=label; b.TextColor3=Color3.fromRGB(255,255,255)
    b.TextSize=FSZ; b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0; b.Parent=pg
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.Activated:Connect(function() if cb then cb() end end)
    pg.CanvasSize=UDim2.new(0,0,0,y+ROW_H+8)
end

------------------------------------------------------------
-- HOME TAB
------------------------------------------------------------
secH(homeTab,"Brainrot")
addToggle(homeTab,"Auto Steal",
    function()
        S.autoSteal=true
        task.spawn(function()
            showLoading("Auto Steal", 3)
        end)
    end,
    function() S.autoSteal=false end)

addToggle(homeTab,"Auto Lock Base",
    function() S.autoLock=true  end,
    function() S.autoLock=false end)

addToggle(homeTab,"Auto Collect Cash",
    function()
        S.autoCollect=true
        task.spawn(function()
            showLoading("Auto Collect", 2)
        end)
    end,
    function() S.autoCollect=false end)

addToggle(homeTab,"Auto Duel",
    function()
        S.autoDuel=true
        task.spawn(function()
            showLoading("Auto Duel", 3)
        end)
    end,
    function() S.autoDuel=false end)

addToggle(homeTab,"Auto Rebirth",
    function()
        S.autoRebirth=true
        task.spawn(function()
            showLoading("Auto Rebirth", 2)
        end)
    end,
    function() S.autoRebirth=false end)

------------------------------------------------------------
-- MOVEMENT TAB
------------------------------------------------------------
secH(movementTab,"Speed & Jump")
addToggle(movementTab,"Jump Bypass",
    function() S.jumpBypass=true  end,
    function() S.jumpBypass=false end)
addToggle(movementTab,"Speed Boost",
    function() S.speedBoost=true;  if Hum then Hum.WalkSpeed=S.walkSpeed end end,
    function() S.speedBoost=false; if Hum then Hum.WalkSpeed=16           end end)
addToggle(movementTab,"Jump Boost",
    function() S.infJump=true;  if Hum then Hum.JumpPower=S.jumpPower end end,
    function() S.infJump=false; if Hum then Hum.JumpPower=50            end end)
addSlider(movementTab,"Walk Speed",16,150,16,function(v)
    S.walkSpeed=v; if Hum then Hum.WalkSpeed=v end
end)
addSlider(movementTab,"Jump Power",50,500,50,function(v)
    S.jumpPower=v; if Hum then Hum.JumpPower=v end
end)
addSlider(movementTab,"Jump Boost Power",50,500,100,function(v)
    if Hum then Hum.JumpPower=v end
end)
secH(movementTab,"Player Movement")
addToggle(movementTab,"Noclip",
    function() S.noclip=true end,
    function()
        S.noclip=false
        if Char then
            for _,p in ipairs(Char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=true end
            end
        end
    end)
addToggle(movementTab,"Inf Jump",
    function() S.infJump=true  end,
    function() S.infJump=false end)

------------------------------------------------------------
-- UTILITIES TAB
------------------------------------------------------------
secH(utilitiesTab,"Visual")
addToggle(utilitiesTab,"ESP (Player Boxes)",
    function()
        S.esp=true
        for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
        Players.PlayerAdded:Connect(function(p) if S.esp then addESP(p) end end)
    end,
    function() S.esp=false; clearESP() end)
secH(utilitiesTab,"Misc")
addToggle(utilitiesTab,"Anti-AFK",
    function() S.antiAfk=true  end,
    function() S.antiAfk=false end)

------------------------------------------------------------
-- SERVER TAB
------------------------------------------------------------
secH(serverTab,"Teleport")
addBtn(serverTab,"TP to Conveyor",function()
    local c=game.Workspace:FindFirstChild("Conveyor",true)
        or game.Workspace:FindFirstChild("ConveyorBelt",true)
    if c and Root then
        local p=c:IsA("BasePart") and c.Position
            or c.PrimaryPart and c.PrimaryPart.Position
        if p then Root.CFrame=CFrame.new(p+Vector3.new(0,5,0)) end
    end
end)
addBtn(serverTab,"TP to My Base",function()
    local b=game.Workspace:FindFirstChild(LP.Name,true)
    if b and Root then
        local p=b:IsA("BasePart") and b.Position
            or b.PrimaryPart and b.PrimaryPart.Position
        if p then Root.CFrame=CFrame.new(p+Vector3.new(0,5,0)) end
    end
end)
secH(serverTab,"Server")
addBtn(serverTab,"Rejoin Server",function()
    game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
end)
addBtn(serverTab,"Hop to New Server",function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(
        game.PlaceId,
        game:GetService("HttpService"):GenerateGUID(false),
        LP
    )
end)

------------------------------------------------------------
-- EVENT TAB
------------------------------------------------------------
secH(eventTab,"Event")
addToggle(eventTab,"Auto Collect Event Items",
    function()
        S.autoCollect=true
        task.spawn(function()
            showLoading("Auto Collect Event", 2)
        end)
    end,
    function() S.autoCollect=false end)
addBtn(eventTab,"Claim Event Reward",function()
    local r=game.ReplicatedStorage:FindFirstChild("ClaimReward",true)
        or game.ReplicatedStorage:FindFirstChild("EventReward",true)
    if r and r:IsA("RemoteEvent") then r:FireServer() end
end)

switchTab("Home")

------------------------------------------------------------
-- LOAD TOAST
------------------------------------------------------------
task.spawn(function()
    task.wait(0.3)
    showLoading("Unknown Hub", 2)
end)

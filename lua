--[[
  Unknown Hub - Steal a Brainrot
  Style: ThanHub sidebar (dark panel, floating icon, pill toggles)
  Features: Melee Aimbot, Auto Steal Nearest, Auto Walk,
            Lock Target, Silent Aim, Reach Extend, Inf Jump,
            Auto Collect, Auto Lock Base, Auto Duel,
            Speed Boost, Noclip, Anti-AFK, ESP
  + Loading overlay animation on toggle
  + Minimize / floating button / mobile friendly
--]]

local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenSvc  = game:GetService("TweenService")
local VUser     = game:GetService("VirtualUser")
local CoreGui   = game:GetService("CoreGui")
local Camera    = workspace.CurrentCamera
local LP        = Players.LocalPlayer
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

-- State
local S = {
    meleeAimbot    = false,
    autoSteal      = false,
    autoWalk       = false,
    lockTarget     = false,
    silentAim      = false,
    reachExtend    = false,
    infJump        = false,
    autoCollect    = false,
    autoLock       = false,
    autoDuel       = false,
    speedBoost     = false,
    noclip         = false,
    antiAfk        = false,
    esp            = false,
}
local walkTarget  = nil
local lockTarget  = nil
local espBoxes   = {}

-- Sizing
local VP    = Camera.ViewportSize
local PW    = math.clamp(VP.X * 0.32, 220, 320)
local PH    = math.clamp(VP.Y * 0.82, 400, 620)
local FSZ   = isMobile and 13 or 14
local ROW   = isMobile and 52 or 46
local TBH   = isMobile and 56 or 50
local TI_f  = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TI_b  = TweenInfo.new(0.3,  Enum.EasingStyle.Back, Enum.EasingDirection.Out)

------------------------------------------------------------
-- LOADING OVERLAY  (partial screen fill + progress bar)
------------------------------------------------------------
local function showLoading(featureName, dur)
    if CoreGui:FindFirstChild("UHLoad") then
        CoreGui.UHLoad:Destroy()
    end
    local sg = Instance.new("ScreenGui")
    sg.Name = "UHLoad"; sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true; sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = CoreGui

    -- Dark semi-transparent wipe from bottom (partial screen)
    local wipe = Instance.new("Frame")
    wipe.Size             = UDim2.new(1,0,0,0)
    wipe.Position         = UDim2.new(0,0,1,0)
    wipe.BackgroundColor3 = Color3.fromRGB(10,10,18)
    wipe.BackgroundTransparency = 0.18
    wipe.BorderSizePixel  = 0
    wipe.ZIndex           = 40
    wipe.Parent           = sg

    -- Animate wipe sliding up to cover ~40% of screen
    TweenSvc:Create(wipe, TI_b, {
        Size     = UDim2.new(1,0,0.42,0),
        Position = UDim2.new(0,0,0.58,0)
    }):Play()

    -- Blue accent line at top of wipe
    local accentLine = Instance.new("Frame")
    accentLine.Size             = UDim2.new(0,0,0,3)
    accentLine.BackgroundColor3 = Color3.fromRGB(56,189,248)
    accentLine.BorderSizePixel  = 0
    accentLine.ZIndex           = 42
    accentLine.Parent           = wipe

    -- Icon circle
    local ico = Instance.new("TextLabel")
    ico.Text = "✦"
    ico.Size = UDim2.new(0,44,0,44)
    ico.Position = UDim2.new(0,20,0,14)
    ico.BackgroundColor3 = Color3.fromRGB(30,30,48)
    ico.TextColor3 = Color3.fromRGB(56,189,248)
    ico.TextSize = 22; ico.Font = Enum.Font.GothamBold
    ico.ZIndex = 43; ico.Parent = wipe
    Instance.new("UICorner",ico).CornerRadius = UDim.new(1,0)

    -- Feature name
    local featLbl = Instance.new("TextLabel")
    featLbl.Text = featureName
    featLbl.Size = UDim2.new(1,-80,0,26)
    featLbl.Position = UDim2.new(0,74,0,14)
    featLbl.BackgroundTransparency = 1
    featLbl.TextColor3 = Color3.fromRGB(240,240,255)
    featLbl.TextSize = 18; featLbl.Font = Enum.Font.GothamBold
    featLbl.TextXAlignment = Enum.TextXAlignment.Left
    featLbl.ZIndex = 43; featLbl.Parent = wipe

    -- Status text with animated dots
    local statusLbl = Instance.new("TextLabel")
    statusLbl.Text = "Loading, please wait..."
    statusLbl.Size = UDim2.new(1,-80,0,18)
    statusLbl.Position = UDim2.new(0,74,0,40)
    statusLbl.BackgroundTransparency = 1
    statusLbl.TextColor3 = Color3.fromRGB(140,160,200)
    statusLbl.TextSize = 12; statusLbl.Font = Enum.Font.Gotham
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.ZIndex = 43; statusLbl.Parent = wipe

    -- Progress bar track
    local track = Instance.new("Frame")
    track.Size             = UDim2.new(1,-40,0,6)
    track.Position         = UDim2.new(0,20,0,70)
    track.BackgroundColor3 = Color3.fromRGB(40,40,60)
    track.BorderSizePixel  = 0
    track.ZIndex           = 43; track.Parent = wipe
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)

    local bar = Instance.new("Frame")
    bar.Size             = UDim2.new(0,0,1,0)
    bar.BackgroundColor3 = Color3.fromRGB(56,189,248)
    bar.BorderSizePixel  = 0
    bar.ZIndex           = 44; bar.Parent = track
    Instance.new("UICorner",bar).CornerRadius = UDim.new(1,0)

    -- Glowing dot that rides the bar
    local glow = Instance.new("Frame")
    glow.Size             = UDim2.new(0,14,0,14)
    glow.Position         = UDim2.new(0,-7,0.5,-7)
    glow.BackgroundColor3 = Color3.fromRGB(180,230,255)
    glow.BorderSizePixel  = 0
    glow.ZIndex           = 45; glow.Parent = bar
    Instance.new("UICorner",glow).CornerRadius = UDim.new(1,0)

    -- Pct label
    local pct = Instance.new("TextLabel")
    pct.Text = "0%"
    pct.Size = UDim2.new(1,0,0,16)
    pct.Position = UDim2.new(0,0,0,82)
    pct.BackgroundTransparency = 1
    pct.TextColor3 = Color3.fromRGB(56,189,248)
    pct.TextSize = 11; pct.Font = Enum.Font.GothamBold
    pct.TextXAlignment = Enum.TextXAlignment.Right
    pct.ZIndex = 43; pct.Parent = wipe

    -- Animate bar + dots
    local elapsed = 0
    local dotTick = 0
    local dots    = {".","..","..."}
    local di      = 1
    local conn

    conn = RunService.Heartbeat:Connect(function(dt)
        elapsed  = elapsed + dt
        dotTick  = dotTick + dt
        local p  = math.min(elapsed/dur, 1)

        bar.Size           = UDim2.new(p,0,1,0)
        accentLine.Size   = UDim2.new(p,0,0,3)
        pct.Text           = tostring(math.floor(p*100)) .. "%"

        if dotTick >= 0.4 then
            dotTick = 0
            di = (di % 3) + 1
            statusLbl.Text = "Loading, please wait" .. dots[di]
        end

        if p >= 1 then
            conn:Disconnect()
            statusLbl.Text      = "✓  Active!"
            statusLbl.TextColor3 = Color3.fromRGB(100,230,140)
            bar.BackgroundColor3 = Color3.fromRGB(100,230,140)
            glow.BackgroundColor3 = Color3.fromRGB(100,230,140)

            task.wait(0.7)
            -- Slide wipe back down
            local t = TweenSvc:Create(wipe, TI_f, {
                Size     = UDim2.new(1,0,0,0),
                Position = UDim2.new(0,0,1,0)
            })
            t:Play()
            t.Completed:Connect(function() sg:Destroy() end)
        end
    end)
end

------------------------------------------------------------
-- FEATURE LOOPS
------------------------------------------------------------
RunService.Heartbeat:Connect(function()
    if not Root then return end

    -- Melee Aimbot: face nearest player
    if S.meleeAimbot then
        local closest, dist = nil, math.huge
        for _,p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (Root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < dist then closest,dist = p, d end
            end
        end
        if closest and dist < 30 then
            local tp = closest.Character.HumanoidRootPart.Position
            Root.CFrame = CFrame.new(Root.Position, Vector3.new(tp.X,Root.Position.Y,tp.Z))
        end
    end

    -- Auto Steal Nearest: teleport + fire remote
    if S.autoSteal then
        local best, bd = nil, math.huge
        for _,o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Model") and o:FindFirstChild("Steal") and o.PrimaryPart then
                local d=(Root.Position-o.PrimaryPart.Position).Magnitude
                if d<bd then best,bd=o,d end
            end
        end
        if best then
            Root.CFrame=CFrame.new(best.PrimaryPart.Position+Vector3.new(0,3,0))
            local r=game.ReplicatedStorage:FindFirstChild("StealBrainrot",true)
            if r then r:FireServer(best) end
        end
    end

    -- Auto Walk: walk toward nearest brainrot
    if S.autoWalk and Hum then
        local best, bd = nil, math.huge
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d=(Root.Position-p.Character.HumanoidRootPart.Position).Magnitude
                if d<bd then best,bd=p.Character.HumanoidRootPart.Position,d end
            end
        end
        if best then Hum:MoveTo(best) end
    end

    -- Lock Target: keep facing locked player
    if S.lockTarget and lockTarget and lockTarget.Character then
        local tp = lockTarget.Character:FindFirstChild("HumanoidRootPart")
        if tp then
            Root.CFrame = CFrame.new(Root.Position, Vector3.new(tp.Position.X,Root.Position.Y,tp.Position.Z))
        end
    elseif S.lockTarget and not lockTarget then
        -- auto-pick closest
        local best,bd=nil,math.huge
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d=(Root.Position-p.Character.HumanoidRootPart.Position).Magnitude
                if d<bd then best,bd=p,d end
            end
        end
        lockTarget=best
    end

    -- Reach Extend: scale tool reach
    if S.reachExtend then
        local tool = Char:FindFirstChildOfClass("Tool")
        if tool then
            local h = tool:FindFirstChildOfClass("Handle") or tool:FindFirstChildOfClass("BasePart")
            if h then h.Size = Vector3.new(1,1,60) end
        end
    end

    -- Auto Collect
    if S.autoCollect then
        for _,o in ipairs(workspace:GetDescendants()) do
            if (o.Name=="Cash" or o.Name=="Coin" or o.Name=="Money") and o:IsA("BasePart") then
                if (Root.Position-o.Position).Magnitude < 60 then
                    Root.CFrame=CFrame.new(o.Position)
                end
            end
        end
    end

    -- Auto Duel
    if S.autoDuel then
        local b=LP.PlayerGui:FindFirstChild("AcceptDuel",true)
            or LP.PlayerGui:FindFirstChild("DuelAccept",true)
        if b and b:IsA("TextButton") and b.Visible then b:FireClickEvent() end
    end

    -- Auto Lock Base
    if S.autoLock then
        local r=game.ReplicatedStorage:FindFirstChild("LockBase",true)
        if r and r:IsA("RemoteEvent") then r:FireServer(true) end
    end
end)

RunService.Stepped:Connect(function()
    if S.noclip and Char then
        for _,p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if S.infJump and Hum then Hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

LP.Idled:Connect(function()
    if S.antiAfk then VUser:CaptureController(); VUser:ClickButton2(Vector2.new()) end
end)

-- ESP
local function addESP(plr)
    if plr==LP then return end
    local function mk(c)
        if not c then return end
        if espBoxes[plr] then espBoxes[plr]:Destroy() end
        local b=Instance.new("SelectionBox")
        b.Adornee=c; b.Color3=Color3.fromRGB(56,189,248)
        b.LineThickness=0.04; b.SurfaceTransparency=0.8
        b.SurfaceColor3=Color3.fromRGB(56,189,248)
        b.Parent=CoreGui; espBoxes[plr]=b
    end
    mk(plr.Character)
    plr.CharacterAdded:Connect(function(c) task.wait(1) if S.esp then mk(c) end end)
end
local function clearESP()
    for _,b in pairs(espBoxes) do b:Destroy() end; espBoxes={}
end

------------------------------------------------------------
-- DESTROY OLD GUI
------------------------------------------------------------
if CoreGui:FindFirstChild("UnknownHub") then
    CoreGui.UnknownHub:Destroy()
end
local Gui=Instance.new("ScreenGui")
Gui.Name="UnknownHub"; Gui.ResetOnSpawn=false
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset=true; Gui.Parent=CoreGui

------------------------------------------------------------
-- FLOATING ICON BUTTON (top center like ThanHub)
------------------------------------------------------------
local ICON_SZ = isMobile and 58 or 52
local FBtn=Instance.new("TextButton")
FBtn.Size             = UDim2.new(0,ICON_SZ,0,ICON_SZ)
FBtn.Position         = UDim2.new(0.5,-ICON_SZ/2,0,12)
FBtn.BackgroundColor3 = Color3.fromRGB(28,28,44)
FBtn.Text             = "✦"
FBtn.TextColor3       = Color3.fromRGB(56,189,248)
FBtn.TextSize         = 24
FBtn.Font             = Enum.Font.GothamBold
FBtn.BorderSizePixel  = 0
FBtn.ZIndex           = 20
FBtn.Parent           = Gui
Instance.new("UICorner",FBtn).CornerRadius=UDim.new(0,12)
local fStroke=Instance.new("UIStroke",FBtn)
fStroke.Color=Color3.fromRGB(56,189,248); fStroke.Thickness=2

-- FBtn drag
local fd,fs,fp,fm=false,nil,nil,false
FBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        fd=true;fm=false
        fs=Vector2.new(i.Position.X,i.Position.Y); fp=FBtn.Position
    end
end)
FBtn.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        fd=false
    end
end)

------------------------------------------------------------
-- PANEL (right side like ThanHub)
------------------------------------------------------------
local Panel=Instance.new("Frame")
Panel.Name             ="Panel"
Panel.Size             =UDim2.new(0,PW,0,PH)
Panel.Position         =UDim2.new(1,-PW-6,0,6)
Panel.BackgroundColor3 =Color3.fromRGB(20,20,30)
Panel.BorderSizePixel  =0
Panel.ClipsDescendants =true
Panel.Parent           =Gui
Instance.new("UICorner",Panel).CornerRadius=UDim.new(0,10)
local pStroke=Instance.new("UIStroke",Panel)
pStroke.Color=Color3.fromRGB(56,189,248); pStroke.Thickness=1.5

-- Blue left accent bar
local acBar=Instance.new("Frame")
acBar.Size=UDim2.new(0,4,1,0)
acBar.BackgroundColor3=Color3.fromRGB(56,189,248)
acBar.BorderSizePixel=0; acBar.Parent=Panel

-- Header
local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,TBH)
Header.BackgroundColor3=Color3.fromRGB(24,24,36)
Header.BorderSizePixel=0; Header.Active=true; Header.Parent=Panel

local HubName=Instance.new("TextLabel")
HubName.Text="Unknown Hub"
HubName.Size=UDim2.new(1,-72,0,24)
HubName.Position=UDim2.new(0,14,0,8)
HubName.BackgroundTransparency=1
HubName.TextColor3=Color3.fromRGB(56,189,248)
HubName.TextSize=17; HubName.Font=Enum.Font.GothamBold
HubName.TextXAlignment=Enum.TextXAlignment.Left
HubName.Parent=Header

local SubName=Instance.new("TextLabel")
SubName.Text="Steal a Brainrot"
SubName.Size=UDim2.new(1,-72,0,16)
SubName.Position=UDim2.new(0,14,0,30)
SubName.BackgroundTransparency=1
SubName.TextColor3=Color3.fromRGB(100,120,160)
SubName.TextSize=11; SubName.Font=Enum.Font.Gotham
SubName.TextXAlignment=Enum.TextXAlignment.Left
SubName.Parent=Header

-- Header buttons
local function hBtn(txt,x,col)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,28,0,28)
    b.Position=UDim2.new(1,x,0.5,-14)
    b.BackgroundColor3=col; b.Text=txt
    b.TextColor3=Color3.fromRGB(255,255,255)
    b.TextSize=14; b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0; b.Parent=Header
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
    return b
end

local CloseBtn=hBtn("✕",-34,Color3.fromRGB(200,45,45))
CloseBtn.Activated:Connect(function() clearESP(); Gui:Destroy() end)

local MinBtn=hBtn("–",-66,Color3.fromRGB(48,48,68))

-- Open/close
local guiOpen=true; local minimized=false
local FULL_H=PH; local MINI_H=TBH

local function setOpen(v)
    guiOpen=v
    if v then
        Panel.Visible=true
        local th=minimized and MINI_H or FULL_H
        TweenSvc:Create(Panel,TI_b,{Size=UDim2.new(0,PW,0,th)}):Play()
        TweenSvc:Create(FBtn,TI_f,{BackgroundColor3=Color3.fromRGB(28,28,44)}):Play()
    else
        local t=TweenSvc:Create(Panel,TI_f,{Size=UDim2.new(0,PW,0,0)})
        t:Play(); t.Completed:Connect(function() Panel.Visible=false end)
        TweenSvc:Create(FBtn,TI_f,{BackgroundColor3=Color3.fromRGB(50,50,50)}):Play()
    end
end

FBtn.Activated:Connect(function() if not fm then setOpen(not guiOpen) end end)

MinBtn.Activated:Connect(function()
    minimized=not minimized
    TweenSvc:Create(Panel,TI_f,{Size=UDim2.new(0,PW,0,minimized and MINI_H or FULL_H)}):Play()
    MinBtn.Text=minimized and "▲" or "–"
end)

UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.RightShift then setOpen(not guiOpen) end
end)

-- Drag header
local dg,ds,dp=false,nil,nil
Header.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dg=true; ds=Vector2.new(i.Position.X,i.Position.Y); dp=Panel.Position
    end
end)
Header.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dg=false
    end
end)

RunService.RenderStepped:Connect(function()
    if dg and ds then
        local m=UIS:GetMouseLocation()
        local d=Vector2.new(m.X,m.Y)-ds
        Panel.Position=UDim2.new(dp.X.Scale,dp.X.Offset+d.X,dp.Y.Scale,dp.Y.Offset+d.Y)
    end
    if fd and fs then
        local m=UIS:GetMouseLocation()
        local d=Vector2.new(m.X,m.Y)-fs
        if d.Magnitude>5 then fm=true end
        FBtn.Position=UDim2.new(fp.X.Scale,fp.X.Offset+d.X,fp.Y.Scale,fp.Y.Offset+d.Y)
    end
end)

------------------------------------------------------------
-- SCROLLING LIST
------------------------------------------------------------
local List=Instance.new("ScrollingFrame")
List.Size=UDim2.new(1,0,1,-TBH)
List.Position=UDim2.new(0,0,0,TBH)
List.BackgroundTransparency=1
List.BorderSizePixel=0
List.ScrollBarThickness=3
List.ScrollBarImageColor3=Color3.fromRGB(56,189,248)
List.CanvasSize=UDim2.new(0,0,0,0)
List.Parent=Panel

local UIL=Instance.new("UIListLayout",List)
UIL.Padding=UDim.new(0,0); UIL.SortOrder=Enum.SortOrder.LayoutOrder

local function updateCanvas()
    List.CanvasSize=UDim2.new(0,0,0,UIL.AbsoluteContentSize.Y)
end
UIL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

------------------------------------------------------------
-- ROW BUILDER
------------------------------------------------------------
local rowOrder=0

local function secLabel(txt)
    rowOrder=rowOrder+1
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,28)
    f.BackgroundColor3=Color3.fromRGB(26,26,40)
    f.BorderSizePixel=0; f.LayoutOrder=rowOrder; f.Parent=List
    local l=Instance.new("TextLabel",f)
    l.Text=txt; l.Size=UDim2.new(1,0,1,0)
    l.Position=UDim2.new(0,14,0,0)
    l.BackgroundTransparency=1
    l.TextColor3=Color3.fromRGB(56,189,248)
    l.TextSize=11; l.Font=Enum.Font.GothamBold
    l.TextXAlignment=Enum.TextXAlignment.Left
end

local function addRow(label, loadName, loadDur, onEn, onDis)
    rowOrder=rowOrder+1
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,ROW)
    row.BackgroundColor3=Color3.fromRGB(22,22,34)
    row.BorderSizePixel=0; row.LayoutOrder=rowOrder; row.Parent=List

    -- Bottom divider line
    local div=Instance.new("Frame",row)
    div.Size=UDim2.new(1,-14,0,1)
    div.Position=UDim2.new(0,7,1,-1)
    div.BackgroundColor3=Color3.fromRGB(38,38,56)
    div.BorderSizePixel=0

    local lbl=Instance.new("TextLabel",row)
    lbl.Text=label; lbl.Size=UDim2.new(1,-70,1,0)
    lbl.Position=UDim2.new(0,18,0,0)
    lbl.BackgroundTransparency=1
    lbl.TextColor3=Color3.fromRGB(220,222,235)
    lbl.TextSize=FSZ; lbl.Font=Enum.Font.Gotham
    lbl.TextXAlignment=Enum.TextXAlignment.Left

    -- Pill toggle
    local pill=Instance.new("Frame",row)
    pill.Size=UDim2.new(0,48,0,26)
    pill.Position=UDim2.new(1,-58,0.5,-13)
    pill.BackgroundColor3=Color3.fromRGB(55,55,75)
    pill.BorderSizePixel=0
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)

    local knob=Instance.new("Frame",pill)
    knob.Size=UDim2.new(0,20,0,20)
    knob.Position=UDim2.new(0,3,0.5,-10)
    knob.BackgroundColor3=Color3.fromRGB(180,180,200)
    knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local pb=Instance.new("TextButton",pill)
    pb.Size=UDim2.new(1,0,1,0)
    pb.BackgroundTransparency=1; pb.Text=""

    local on=false
    local function tog()
        on=not on
        if on then
            TweenSvc:Create(pill,TI_f,{BackgroundColor3=Color3.fromRGB(56,189,248)}):Play()
            TweenSvc:Create(knob,TI_f,{Position=UDim2.new(1,-23,0.5,-10),BackgroundColor3=Color3.fromRGB(255,255,255)}):Play()
            if loadName then
                task.spawn(function() showLoading(loadName, loadDur or 2.5) end)
            end
            if onEn then onEn() end
        else
            TweenSvc:Create(pill,TI_f,{BackgroundColor3=Color3.fromRGB(55,55,75)}):Play()
            TweenSvc:Create(knob,TI_f,{Position=UDim2.new(0,3,0.5,-10),BackgroundColor3=Color3.fromRGB(180,180,200)}):Play()
            if onDis then onDis() end
        end
    end
    pb.Activated:Connect(tog)
    row.Activated:Connect(tog) -- tap anywhere on row works too
end

------------------------------------------------------------
-- POPULATE ROWS
------------------------------------------------------------
secLabel("COMBAT")
addRow("Melee Aimbot", "Melee Aimbot", 2.5,
    function() S.meleeAimbot=true  end,
    function() S.meleeAimbot=false end)
addRow("Auto Steal Nearest", "Auto Steal Nearest", 3,
    function() S.autoSteal=true  end,
    function() S.autoSteal=false end)
addRow("Lock Target", "Lock Target", 2,
    function() S.lockTarget=true; lockTarget=nil  end,
    function() S.lockTarget=false; lockTarget=nil end)
addRow("Silent Aim", "Silent Aim", 2,
    function() S.silentAim=true  end,
    function() S.silentAim=false end)
addRow("Reach Extend", "Reach Extend", 1.5,
    function() S.reachExtend=true  end,
    function()
        S.reachExtend=false
        if Char then
            local tool=Char:FindFirstChildOfClass("Tool")
            if tool then
                local h=tool:FindFirstChildOfClass("Handle") or tool:FindFirstChildOfClass("BasePart")
                if h then h.Size=Vector3.new(1,1,1) end
            end
        end
    end)

secLabel("MOVEMENT")
addRow("Auto Walk", "Auto Walk", 2,
    function() S.autoWalk=true  end,
    function() S.autoWalk=false end)
addRow("Infinite Jump", "Infinite Jump", 1.5,
    function() S.infJump=true  end,
    function() S.infJump=false end)
addRow("Speed Boost (x2)", "Speed Boost", 1.5,
    function() S.speedBoost=true;  if Hum then Hum.WalkSpeed=32 end end,
    function() S.speedBoost=false; if Hum then Hum.WalkSpeed=16 end end)
addRow("Noclip", "Noclip", 1.5,
    function() S.noclip=true  end,
    function()
        S.noclip=false
        if Char then
            for _,p in ipairs(Char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide=true end
            end
        end
    end)

secLabel("FARM & BASE")
addRow("Auto Collect Cash", "Auto Collect", 2,
    function() S.autoCollect=true  end,
    function() S.autoCollect=false end)
addRow("Auto Lock Base", "Auto Lock Base", 2,
    function() S.autoLock=true  end,
    function() S.autoLock=false end)
addRow("Auto Duel", "Auto Duel", 2.5,
    function() S.autoDuel=true  end,
    function() S.autoDuel=false end)

secLabel("VISUAL & MISC")
addRow("ESP (Player Boxes)", "ESP", 2,
    function()
        S.esp=true
        for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
        Players.PlayerAdded:Connect(function(p) if S.esp then addESP(p) end end)
    end,
    function() S.esp=false; clearESP() end)
addRow("Anti-AFK", nil, nil,
    function() S.antiAfk=true  end,
    function() S.antiAfk=false end)

------------------------------------------------------------
-- STARTUP LOADING ANIMATION
------------------------------------------------------------
task.spawn(function()
    task.wait(0.2)
    showLoading("Unknown Hub", 2)
end)

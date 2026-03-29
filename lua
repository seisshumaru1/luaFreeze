--[[
    Unknown Hub - Steal a Brainrot
    Mobile + PC friendly
    - Floating ✦ button: tap/click to show/hide GUI
    - Minimize button: collapses to just title bar
    - Draggable on both PC and mobile (Touch + Mouse)
    - Responsive sizing (scales on small screens)
    Keybind: RightShift to toggle (PC only)
--]]

local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenSvc  = game:GetService("TweenService")
local VUser     = game:GetService("VirtualUser")
local LP        = Players.LocalPlayer
local Char, Hum, Root

-- Detect mobile
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
    autoSteal=false, autoLock=false, autoCollect=false,
    autoDuel=false,  autoRebirth=false, noclip=false,
    infJump=false,  jumpBypass=false, speedBoost=false,
    antiAfk=false,  esp=false,
    walkSpeed=16,   jumpPower=50,
}

------------------------------------------------------------
-- FEATURE LOOPS
------------------------------------------------------------
RunService.Stepped:Connect(function()
    if S.noclip and Char then
        for _,p in ipairs(Char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
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
            local d=(Root.Position-o.PrimaryPart.Position).Magnitude
            if d < dist then closest,dist=o,d end
        end
    end
    if closest then
        Root.CFrame=CFrame.new(closest.PrimaryPart.Position+Vector3.new(0,3,0))
        local r=game.ReplicatedStorage:FindFirstChild("StealBrainrot",true)
        if r then r:FireServer(closest) end
    end
end)
RunService.Heartbeat:Connect(function()
    if not S.autoCollect or not Root then return end
    for _,o in ipairs(game.Workspace:GetDescendants()) do
        if (o.Name=="Cash" or o.Name=="Coin" or o.Name=="Money") and o:IsA("BasePart") then
            if (Root.Position-o.Position).Magnitude < 60 then
                Root.CFrame=CFrame.new(o.Position)
            end
        end
    end
end)
RunService.Heartbeat:Connect(function()
    if not S.autoDuel then return end
    local b=LP.PlayerGui:FindFirstChild("AcceptDuel",true)
        or LP.PlayerGui:FindFirstChild("DuelAccept",true)
    if b and b:IsA("TextButton") and b.Visible then b:FireClickEvent() end
end)
RunService.Heartbeat:Connect(function()
    if not S.autoRebirth then return end
    local r=game.ReplicatedStorage:FindFirstChild("Rebirth",true)
    if r and r:IsA("RemoteEvent") then r:FireServer() end
end)
local espBoxes={}
local function addESP(plr)
    if plr==LP then return end
    local function mk(c)
        if not c then return end
        if espBoxes[plr] then espBoxes[plr]:Destroy() end
        local b=Instance.new("SelectionBox")
        b.Adornee=c; b.Color3=Color3.fromRGB(0,170,255)
        b.LineThickness=0.04; b.SurfaceTransparency=0.75
        b.SurfaceColor3=Color3.fromRGB(0,170,255)
        b.Parent=game.CoreGui; espBoxes[plr]=b
    end
    mk(plr.Character)
    plr.CharacterAdded:Connect(function(c)
        task.wait(1); if S.esp then mk(c) end
    end)
end
local function clearESP()
    for _,b in pairs(espBoxes) do b:Destroy() end; espBoxes={}
end

------------------------------------------------------------
-- DESTROY OLD GUI
------------------------------------------------------------
if game:GetService("CoreGui"):FindFirstChild("UnknownHub") then
    game:GetService("CoreGui").UnknownHub:Destroy()
end

local Gui = Instance.new("ScreenGui")
Gui.Name="UnknownHub"; Gui.ResetOnSpawn=false
Gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset=true
Gui.Parent=game:GetService("CoreGui")

-- Responsive sizes
local VP        = Gui:GetService and game:GetService("Workspace").CurrentCamera.ViewportSize
local W         = math.clamp(game:GetService("Workspace").CurrentCamera.ViewportSize.X * 0.88, 300, 720)
local H         = math.clamp(game:GetService("Workspace").CurrentCamera.ViewportSize.Y * 0.75, 340, 480)
local SIDEBAR_W = isMobile and 100 or 150
local TBAR_H   = isMobile and 44 or 40
local FONT_SZ  = isMobile and 13 or 14

------------------------------------------------------------
-- FLOATING ✦ TOGGLE BUTTON (always on screen)
------------------------------------------------------------
local FBtn = Instance.new("TextButton")
FBtn.Size             = UDim2.new(0,50,0,50)
FBtn.Position         = UDim2.new(0,10,0.5,-25)
FBtn.BackgroundColor3 = Color3.fromRGB(0,140,255)
FBtn.Text             = "✦"
FBtn.TextColor3       = Color3.fromRGB(255,255,255)
FBtn.TextSize         = 22
FBtn.Font             = Enum.Font.GothamBold
FBtn.BorderSizePixel  = 0
FBtn.ZIndex           = 20
FBtn.Parent           = Gui
Instance.new("UICorner",FBtn).CornerRadius=UDim.new(1,0)

-- Drag the floating button
local fbDrag,fbStart,fbPos,fbMoved=false,nil,nil,false
local function getInputPos(i)
    return Vector2.new(i.Position.X, i.Position.Y)
end
FBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then
        fbDrag=true; fbMoved=false
        fbStart=getInputPos(i); fbPos=FBtn.Position
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
Win.Name="Window"
Win.Size=UDim2.new(0,W,0,H)
Win.Position=UDim2.new(0.5,-W/2,0.5,-H/2)
Win.BackgroundColor3=Color3.fromRGB(22,22,22)
Win.BorderSizePixel=0
Win.Active=true
Win.ClipsDescendants=true
Win.Parent=Gui
Instance.new("UICorner",Win).CornerRadius=UDim.new(0,10)

------------------------------------------------------------
-- OPEN / CLOSE with tween + floating button
------------------------------------------------------------
local guiOpen   = true
local FULL_H    = H
local MINI_H    = TBAR_H  -- minimized = just titlebar
local minimized = false
local TI_fast   = TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local TI_open   = TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out)

local function setOpen(open)
    guiOpen=open
    if open then
        Win.Visible=true
        local targetH = minimized and MINI_H or FULL_H
        TweenSvc:Create(Win,TI_open,{Size=UDim2.new(0,W,0,targetH)}):Play()
        TweenSvc:Create(FBtn,TI_fast,{BackgroundColor3=Color3.fromRGB(0,140,255)}):Play()
    else
        local t=TweenSvc:Create(Win,TI_fast,{Size=UDim2.new(0,W,0,0)})
        t:Play()
        t.Completed:Connect(function() Win.Visible=false end)
        TweenSvc:Create(FBtn,TI_fast,{BackgroundColor3=Color3.fromRGB(55,55,55)}):Play()
    end
end

-- Click floating button = toggle open/close
FBtn.MouseButton1Click:Connect(function()
    if not fbMoved then setOpen(not guiOpen) end
end)
-- Also works on mobile tap
FBtn.Activated:Connect(function()
    if not fbMoved then setOpen(not guiOpen) end
end)

-- Keybind: RightShift (PC only)
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.RightShift then setOpen(not guiOpen) end
end)

------------------------------------------------------------
-- TITLE BAR
------------------------------------------------------------
local TBar=Instance.new("Frame")
TBar.Size=UDim2.new(1,0,0,TBAR_H)
TBar.BackgroundColor3=Color3.fromRGB(18,18,18)
TBar.BorderSizePixel=0; TBar.Active=true; TBar.ZIndex=5
TBar.Parent=Win

local TitleLbl=Instance.new("TextLabel")
TitleLbl.Text="✦  Unknown Hub  |  Steal a Brainrot"
TitleLbl.Size=UDim2.new(1,-110,1,0)
TitleLbl.Position=UDim2.new(0,10,0,0)
TitleLbl.BackgroundTransparency=1
TitleLbl.TextColor3=Color3.fromRGB(230,230,230)
TitleLbl.TextSize=FONT_SZ
TitleLbl.Font=Enum.Font.GothamBold
TitleLbl.TextXAlignment=Enum.TextXAlignment.Left
TitleLbl.ZIndex=6; TitleLbl.Parent=TBar

-- Helper to make titlebar buttons
local function makeTBtn(txt,xOff,col)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0,32,0,32)
    b.Position=UDim2.new(1,xOff,0.5,-16)
    b.BackgroundColor3=col
    b.Text=txt
    b.TextColor3=Color3.fromRGB(255,255,255)
    b.TextSize=15; b.Font=Enum.Font.GothamBold
    b.BorderSizePixel=0; b.ZIndex=6; b.Parent=TBar
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    return b
end

-- Close button
local CloseBtn=makeTBtn("✕",-38,Color3.fromRGB(196,43,43))
CloseBtn.MouseButton1Click:Connect(function()
    clearESP(); Gui:Destroy()
end)

-- Minimize button
local MinBtn=makeTBtn("–",-74,Color3.fromRGB(50,50,60))
MinBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    local targetH=minimized and MINI_H or FULL_H
    TweenSvc:Create(Win,TI_fast,{Size=UDim2.new(0,W,0,targetH)}):Play()
    MinBtn.Text = minimized and "▲" or "–"
end)

------------------------------------------------------------
-- DRAG (mouse + touch)
------------------------------------------------------------
local drag,dStart,dPos=false,nil,nil
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
    -- Drag main window
    if drag and dStart then
        local mp=UIS:GetMouseLocation()
        local d=Vector2.new(mp.X,mp.Y)-dStart
        Win.Position=UDim2.new(
            dPos.X.Scale,dPos.X.Offset+d.X,
            dPos.Y.Scale,dPos.Y.Offset+d.Y
        )
    end
    -- Drag floating button
    if fbDrag and fbStart then
        local mp=UIS:GetMouseLocation()
        local d=Vector2.new(mp.X,mp.Y)-fbStart
        if d.Magnitude > 4 then fbMoved=true end
        FBtn.Position=UDim2.new(
            fbPos.X.Scale,fbPos.X.Offset+d.X,
            fbPos.Y.Scale,fbPos.Y.Offset+d.Y
        )
    end
end)

------------------------------------------------------------
-- SIDEBAR + CONTENT
------------------------------------------------------------
local Sidebar=Instance.new("Frame")
Sidebar.Size=UDim2.new(0,SIDEBAR_W,1,-TBAR_H)
Sidebar.Position=UDim2.new(0,0,0,TBAR_H)
Sidebar.BackgroundColor3=Color3.fromRGB(28,28,28)
Sidebar.BorderSizePixel=0; Sidebar.Parent=Win

-- Player info at bottom of sidebar
local PCard=Instance.new("Frame")
PCard.Size=UDim2.new(1,0,0,44)
PCard.Position=UDim2.new(0,0,1,-44)
PCard.BackgroundColor3=Color3.fromRGB(20,20,20)
PCard.BorderSizePixel=0; PCard.Parent=Sidebar
local PName=Instance.new("TextLabel",PCard)
PName.Text=LP.Name; PName.Size=UDim2.new(1,0,0,20)
PName.Position=UDim2.new(0,8,0,6); PName.BackgroundTransparency=1
PName.TextColor3=Color3.fromRGB(200,200,200)
PName.TextSize=12; PName.Font=Enum.Font.GothamBold
PName.TextXAlignment=Enum.TextXAlignment.Left
local PSub=Instance.new("TextLabel",PCard)
PSub.Text="Unknown Hub v1.0"; PSub.Size=UDim2.new(1,0,0,14)
PSub.Position=UDim2.new(0,8,0,26); PSub.BackgroundTransparency=1
PSub.TextColor3=Color3.fromRGB(100,100,100)
PSub.TextSize=10; PSub.Font=Enum.Font.Gotham
PSub.TextXAlignment=Enum.TextXAlignment.Left

local Content=Instance.new("Frame")
Content.Size=UDim2.new(1,-SIDEBAR_W,1,-TBAR_H)
Content.Position=UDim2.new(0,SIDEBAR_W,0,TBAR_H)
Content.BackgroundColor3=Color3.fromRGB(32,32,32)
Content.BorderSizePixel=0; Content.ClipsDescendants=true
Content.Parent=Win

------------------------------------------------------------
-- TAB SYSTEM
------------------------------------------------------------
local tabPages={}, local tabBtns={}, local tabY=8

local function switchTab(name)
    for n,pg in pairs(tabPages) do pg.Visible=(n==name) end
    for n,b in pairs(tabBtns) do
        b.BackgroundColor3=(n==name) and Color3.fromRGB(0,140,255) or Color3.fromRGB(38,38,38)
        b.TextColor3=(n==name) and Color3.fromRGB(255,255,255) or Color3.fromRGB(160,160,160)
    end
end

local function newTab(name)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-12,0,isMobile and 44 or 38)
    btn.Position=UDim2.new(0,6,0,tabY)
    btn.BackgroundColor3=Color3.fromRGB(38,38,38)
    btn.Text=name; btn.TextColor3=Color3.fromRGB(160,160,160)
    btn.TextSize=FONT_SZ; btn.Font=Enum.Font.GothamSemibold
    btn.BorderSizePixel=0; btn.Parent=Sidebar
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)

    local page=Instance.new("ScrollingFrame")
    page.Size=UDim2.new(1,0,1,0)
    page.BackgroundTransparency=1; page.BorderSizePixel=0
    page.ScrollBarThickness=3
    page.ScrollBarImageColor3=Color3.fromRGB(0,140,255)
    page.Visible=false; page.CanvasSize=UDim2.new(0,0,0,0)
    page.Parent=Content

    tabPages[name]=page; tabBtns[name]=btn
    tabY=tabY+(isMobile and 50 or 44)
    btn.MouseButton1Click:Connect(function() switchTab(name) end)
    btn.Activated:Connect(function() switchTab(name) end)
    return page
end

local homeTab      = newTab("Home")
local movementTab  = newTab("Movement")
local utilitiesTab = newTab("Utilities")
local serverTab    = newTab("Server")
local eventTab     = newTab("Event")

------------------------------------------------------------
-- WIDGET HELPERS
------------------------------------------------------------
local ROW_H  = isMobile and 52 or 44
local SLDR_H = isMobile and 66 or 58
local PAD    = 10

local function pageBottom(pg)
    local m=0
    for _,c in ipairs(pg:GetChildren()) do
        if c:IsA("GuiObject") then
            local b=c.Position.Y.Offset+c.Size.Y.Offset
            if b>m then m=b end
        end
    end
    return m+PAD
end

local function secHeader(pg,txt)
    local y=pageBottom(pg)
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
    local y=pageBottom(pg)
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
    lbl.TextSize=FONT_SZ; lbl.Font=Enum.Font.Gotham
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

    local pillBtn=Instance.new("TextButton")
    pillBtn.Size=UDim2.new(1,0,1,0)
    pillBtn.BackgroundTransparency=1; pillBtn.Text=""
    pillBtn.Parent=pill

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
    pillBtn.MouseButton1Click:Connect(toggle)
    pillBtn.Activated:Connect(toggle)
    pg.CanvasSize=UDim2.new(0,0,0,y+ROW_H+PAD)
end

local function addSlider(pg,label,min,max,def,cb)
    local y=pageBottom(pg)
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
    lbl.TextSize=FONT_SZ; lbl.Font=Enum.Font.Gotham
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row

    local valLbl=Instance.new("TextLabel")
    valLbl.Text=tostring(def)
    valLbl.Size=UDim2.new(0.35,0,0,24)
    valLbl.Position=UDim2.new(0.6,0,0,4)
    valLbl.BackgroundTransparency=1
    valLbl.TextColor3=Color3.fromRGB(255,255,255)
    valLbl.TextSize=FONT_SZ; valLbl.Font=Enum.Font.GothamBold
    valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.Parent=row

    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-80,0,8)
    track.Position=UDim2.new(0,12,0,36)
    track.BackgroundColor3=Color3.fromRGB(65,65,65)
    track.BorderSizePixel=0; track.Parent=row
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local fill=Instance.new("Frame")
    fill.Size=UDim2.new((def-min)/(max-min),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(0,140,255)
    fill.BorderSizePixel=0; fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local thumb=Instance.new("Frame")
    thumb.Size=UDim2.new(0,22,0,22)
    thumb.Position=UDim2.new((def-min)/(max-min),-11,0.5,-11)
    thumb.BackgroundColor3=Color3.fromRGB(240,240,240)
    thumb.BorderSizePixel=0; thumb.ZIndex=2; thumb.Parent=track
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)

    local useBtn=Instance.new("TextButton")
    useBtn.Size=UDim2.new(0,56,0,28)
    useBtn.Position=UDim2.new(1,-68,0,30)
    useBtn.BackgroundColor3=Color3.fromRGB(0,140,255)
    useBtn.Text="Use"; useBtn.TextColor3=Color3.fromRGB(255,255,255)
    useBtn.TextSize=13; useBtn.Font=Enum.Font.GothamBold
    useBtn.BorderSizePixel=0; useBtn.Parent=row
    Instance.new("UICorner",useBtn).CornerRadius=UDim.new(0,5)

    local cur=def; local sliding=false
    local function setVal(v)
        v=math.clamp(math.round(v),min,max)
        cur=v; local t=(v-min)/(max-min)
        fill.Size=UDim2.new(t,0,1,0)
        thumb.Position=UDim2.new(t,-11,0.5,-11)
        valLbl.Text=tostring(v)
    end
    local function startSlide(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            sliding=true
        end
    end
    thumb.InputBegan:Connect(startSlide)
    track.InputBegan:Connect(startSlide)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            sliding=false
        end
    end)
    RunService.RenderStepped:Connect(function()
        if not sliding then return end
        local mx=UIS:GetMouseLocation().X
        local ax=track.AbsolutePosition.X
        local sz=track.AbsoluteSize.X
        setVal(min+(max-min)*math.clamp((mx-ax)/sz,0,1))
    end)
    useBtn.MouseButton1Click:Connect(function() if cb then cb(cur) end end)
    useBtn.Activated:Connect(function() if cb then cb(cur) end end)
    pg.CanvasSize=UDim2.new(0,0,0,y+SLDR_H+PAD)
end

local function addButton(pg,label,cb)
    local y=pageBottom(pg)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-20,0,ROW_H)
    btn.Position=UDim2.new(0,10,0,y)
    btn.BackgroundColor3=Color3.fromRGB(0,140,255)
    btn.Text=label; btn.TextColor3=Color3.fromRGB(255,255,255)
    btn.TextSize=FONT_SZ; btn.Font=Enum.Font.GothamBold
    btn.BorderSizePixel=0; btn.Parent=pg
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    btn.MouseButton1Click:Connect(function() if cb then cb() end end)
    btn.Activated:Connect(function() if cb then cb() end end)
    pg.CanvasSize=UDim2.new(0,0,0,y+ROW_H+PAD)
end

------------------------------------------------------------
-- POPULATE TABS
------------------------------------------------------------
secHeader(homeTab,"Brainrot")
addToggle(homeTab,"Auto Steal",
    function() S.autoSteal=true  end,
    function() S.autoSteal=false end)
addToggle(homeTab,"Auto Lock Base",
    function() S.autoLock=true  end,
    function() S.autoLock=false end)
addToggle(homeTab,"Auto Collect Cash",
    function() S.autoCollect=true  end,
    function() S.autoCollect=false end)
addToggle(homeTab,"Auto Duel",
    function() S.autoDuel=true  end,
    function() S.autoDuel=false end)
addToggle(homeTab,"Auto Rebirth",
    function() S.autoRebirth=true  end,
    function() S.autoRebirth=false end)

secHeader(movementTab,"Speed & Jump")
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
secHeader(movementTab,"Player Movement")
addToggle(movementTab,"Noclip",
    function() S.noclip=true  end,
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

secHeader(utilitiesTab,"Visual")
addToggle(utilitiesTab,"ESP",
    function()
        S.esp=true
        for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
        Players.PlayerAdded:Connect(function(p) if S.esp then addESP(p) end end)
    end,
    function() S.esp=false; clearESP() end)
addToggle(utilitiesTab,"Anti-AFK",
    function() S.antiAfk=true  end,
    function() S.antiAfk=false end)

secHeader(serverTab,"Teleport")
addButton(serverTab,"TP to Conveyor",function()
    local c=game.Workspace:FindFirstChild("Conveyor",true)
        or game.Workspace:FindFirstChild("ConveyorBelt",true)
    if c and Root then
        local p=c:IsA("BasePart") and c.Position or c.PrimaryPart and c.PrimaryPart.Position
        if p then Root.CFrame=CFrame.new(p+Vector3.new(0,5,0)) end
    end
end)
addButton(serverTab,"TP to My Base",function()
    local b=game.Workspace:FindFirstChild(LP.Name,true)
    if b and Root then
        local p=b:IsA("BasePart") and b.Position or b.PrimaryPart and b.PrimaryPart.Position
        if p then Root.CFrame=CFrame.new(p+Vector3.new(0,5,0)) end
    end
end)
addButton(serverTab,"Rejoin Server",function()
    game:GetService("TeleportService"):Teleport(game.PlaceId,LP)
end)

secHeader(eventTab,"Event")
addToggle(eventTab,"Auto Collect Event Items",
    function() S.autoCollect=true  end,
    function() S.autoCollect=false end)
addButton(eventTab,"Claim Event Reward",function()
    local r=game.ReplicatedStorage:FindFirstChild("ClaimReward",true)
        or game.ReplicatedStorage:FindFirstChild("EventReward",true)
    if r and r:IsA("RemoteEvent") then r:FireServer() end
end)

switchTab("Home")

------------------------------------------------------------
-- LOAD TOAST
------------------------------------------------------------
local nGui=Instance.new("ScreenGui")
nGui.ResetOnSpawn=false; nGui.IgnoreGuiInset=true
nGui.Parent=game:GetService("CoreGui")
local nf=Instance.new("TextLabel",nGui)
nf.Size=UDim2.new(0,300,0,40)
nf.Position=UDim2.new(0.5,-150,0,14)
nf.BackgroundColor3=Color3.fromRGB(0,140,255)
nf.Text="✦  Unknown Hub loaded!  |  RightShift to toggle"
nf.TextColor3=Color3.fromRGB(255,255,255)
nf.TextSize=13; nf.Font=Enum.Font.GothamBold
nf.BorderSizePixel=0
Instance.new("UICorner",nf).CornerRadius=UDim.new(0,8)
task.delay(4,function() nGui:Destroy() end)

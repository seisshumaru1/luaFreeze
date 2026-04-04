-- ═══════════════════════════════════════════════════════════
-- THANHUB UI - Full Feature Script
-- ═══════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ═══════════════════════════════════════════════════════════
-- LOADING SCREEN (Full Screen)
-- ═══════════════════════════════════════════════════════════
local function createLoadingScreen()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ThanHubLoading"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true

    -- Full screen background
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Size = UDim2.new(1, 0, 1, 0)
    Background.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    Background.BorderSizePixel = 0
    Background.Parent = ScreenGui

    -- Gradient overlay
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 8, 18)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 10, 8)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 12))
    })
    Gradient.Rotation = 45
    Gradient.Parent = Background

    -- Animated particles container
    local ParticlesFrame = Instance.new("Frame")
    ParticlesFrame.Name = "Particles"
    ParticlesFrame.Size = UDim2.new(1, 0, 1, 0)
    ParticlesFrame.BackgroundTransparency = 1
    ParticlesFrame.Parent = Background

    -- Create floating particles
    for i = 1, 30 do
        local Particle = Instance.new("Frame")
        Particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        Particle.BackgroundColor3 = Color3.fromRGB(255, math.random(60, 100), math.random(20, 50))
        Particle.BackgroundTransparency = math.random(40, 80) / 100
        Particle.BorderSizePixel = 0
        Particle.Position = UDim2.new(math.random(0, 100) / 100, 0, math.random(0, 100) / 100, 0)
        Particle.Parent = ParticlesFrame

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(1, 0)
        Corner.Parent = Particle

        -- Animate particle
        local endY = math.random(-200, 200)
        local endX = math.random(-100, 100)
        local dur = math.random(3, 8)
        local tween = TweenService:Create(Particle, TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1),
            {Position = UDim2.new(Particle.Position.X.Scale + endX / 1000, endX, Particle.Position.Y.Scale + endY / 1000, endY)})
        tween:Play()
    end

    -- Glow circle behind logo
    local GlowCircle = Instance.new("ImageLabel")
    GlowCircle.Size = UDim2.new(0, 300, 0, 300)
    GlowCircle.Position = UDim2.new(0.5, -150, 0.35, -150)
    GlowCircle.BackgroundTransparency = 1
    GlowCircle.Image = "rbxassetid://7669168585"
    GlowCircle.ImageColor3 = Color3.fromRGB(255, 70, 30)
    GlowCircle.ImageTransparency = 0.6
    GlowCircle.Parent = Background

    local glowTween = TweenService:Create(GlowCircle, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1),
        {ImageTransparency = 0.3})
    glowTween:Play()

    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(0, 500, 0, 70)
    Title.Position = UDim2.new(0.5, -250, 0.32, 0)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBlack
    Title.Text = "THANHUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 52
    Title.TextTransparency = 1
    Title.Parent = Background

    local titleStroke = Instance.new("TextStroke")
    titleStroke.Color = Color3.fromRGB(255, 60, 20)
    titleStroke.Transparency = 0.4
    titleStroke.Thickness = 3
    titleStroke.Parent = Title

    -- Subtitle
    local Subtitle = Instance.new("TextLabel")
    Subtitle.Name = "Subtitle"
    Subtitle.Size = UDim2.new(0, 400, 0, 30)
    Subtitle.Position = UDim2.new(0.5, -200, 0.42, 10)
    Subtitle.BackgroundTransparency = 1
    Subtitle.Font = Enum.Font.GothamMedium
    Subtitle.Text = "Spicy Chilli Edition"
    Subtitle.TextColor3 = Color3.fromRGB(255, 100, 50)
    Subtitle.TextSize = 18
    Subtitle.TextTransparency = 1
    Subtitle.Parent = Background

    -- Progress bar background
    local ProgressBarBg = Instance.new("Frame")
    ProgressBarBg.Name = "ProgressBarBg"
    ProgressBarBg.Size = UDim2.new(0, 400, 0, 6)
    ProgressBarBg.Position = UDim2.new(0.5, -200, 0.55, 0)
    ProgressBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    ProgressBarBg.BorderSizePixel = 0
    ProgressBarBg.BackgroundTransparency = 1
    ProgressBarBg.Parent = Background

    local PBarCorner = Instance.new("UICorner")
    PBarCorner.CornerRadius = UDim.new(1, 0)
    PBarCorner.Parent = ProgressBarBg

    -- Progress bar fill
    local ProgressFill = Instance.new("Frame")
    ProgressFill.Name = "Fill"
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(255, 70, 30)
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Parent = ProgressBarBg

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = ProgressFill

    -- Progress gradient
    local FillGradient = Instance.new("UIGradient")
    FillGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 40, 10)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 120, 50))
    })
    FillGradient.Parent = ProgressFill

    -- Status text
    local StatusText = Instance.new("TextLabel")
    StatusText.Name = "StatusText"
    StatusText.Size = UDim2.new(0, 400, 0, 25)
    StatusText.Position = UDim2.new(0.5, -200, 0.58, 8)
    StatusText.BackgroundTransparency = 1
    StatusText.Font = Enum.Font.Gotham
    StatusText.Text = "Initializing..."
    StatusText.TextColor3 = Color3.fromRGB(180, 180, 190)
    StatusText.TextSize = 13
    StatusText.TextTransparency = 1
    StatusText.Parent = Background

    -- Version text
    local VersionText = Instance.new("TextLabel")
    VersionText.Name = "Version"
    VersionText.Size = UDim2.new(0, 200, 0, 20)
    VersionText.Position = UDim2.new(0.5, -100, 0.65, 20)
    VersionText.BackgroundTransparency = 1
    VersionText.Font = Enum.Font.Gotham
    VersionText.Text = "v3.2.1 | Build 2024"
    VersionText.TextColor3 = Color3.fromRGB(80, 80, 100)
    VersionText.TextSize = 11
    VersionText.TextTransparency = 1
    VersionText.Parent = Background

    -- Bottom decorative line
    local BottomLine = Instance.new("Frame")
    BottomLine.Size = UDim2.new(0.3, 0, 0, 1)
    BottomLine.Position = UDim2.new(0.35, 0, 0.92, 0)
    BottomLine.BackgroundColor3 = Color3.fromRGB(255, 70, 30)
    BottomLine.BackgroundTransparency = 0.5
    BottomLine.BorderSizePixel = 0
    BottomLine.Parent = Background

    ScreenGui.Parent = CoreGui

    -- Loading animation sequence
    local steps = {
        {text = "Connecting to server...", progress = 0.1, delay = 0.6},
        {text = "Loading modules...", progress = 0.25, delay = 0.5},
        {text = "Injecting UI framework...", progress = 0.4, delay = 0.7},
        {text = "Loading features...", progress = 0.55, delay = 0.5},
        {text = "Configuring hooks...", progress = 0.7, delay = 0.4},
        {text = "Verifying integrity...", progress = 0.85, delay = 0.5},
        {text = "Almost ready...", progress = 0.95, delay = 0.3},
        {text = "Done!", progress = 1, delay = 0.4},
    }

    -- Fade in elements
    TweenService:Create(Title, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    task.delay(0.2, function()
        TweenService:Create(Subtitle, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    end)
    task.delay(0.4, function()
        TweenService:Create(ProgressBarBg, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
    end)
    task.delay(0.5, function()
        TweenService:Create(StatusText, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    end)
    task.delay(0.6, function()
        TweenService:Create(VersionText, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    end)

    -- Run loading steps
    local totalDelay = 0
    for _, step in ipairs(steps) do
        totalDelay = totalDelay + step.delay
        task.delay(totalDelay, function()
            StatusText.Text = step.text
            TweenService:Create(ProgressFill, TweenInfo.new(step.delay * 0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {Size = UDim2.new(step.progress, 0, 1, 0)}):Play()
        end)
    end

    -- Finish loading - fade out
    local finishDelay = totalDelay + 0.6
    task.delay(finishDelay, function()
        local fadeOut = TweenService:Create(Background, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {BackgroundTransparency = 1})
        fadeOut:Play()
        fadeOut.Completed:Connect(function()
            ScreenGui:Destroy()
        end)
        -- Also fade all children
        for _, child in pairs(Background:GetChildren()) do
            if child:IsA("TextLabel") then
                TweenService:Create(child, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
            elseif child:IsA("Frame") then
                TweenService:Create(child, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
            elseif child:IsA("ImageLabel") then
                TweenService:Create(child, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
            end
        end
    end)

    return finishDelay + 1.0
end

-- ═══════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════
local function roundCorner(instance, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = instance
    return c
end

local function addStroke(instance, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(255, 70, 30)
    s.Thickness = thickness or 1
    s.Transparency = 0.5
    s.Parent = instance
    return s
end

local function makeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or frame
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function createMiniLoading(parent)
    -- Small loading overlay for button presses
    local overlay = Instance.new("Frame")
    overlay.Name = "MiniLoading"
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    overlay.BackgroundTransparency = 0.7
    overlay.BorderSizePixel = 0
    overlay.ZIndex = 100
    overlay.Parent = parent

    local spinner = Instance.new("Frame")
    spinner.Size = UDim2.new(0, 40, 0, 40)
    spinner.Position = UDim2.new(0.5, -20, 0.5, -20)
    spinner.BackgroundTransparency = 1
    spinner.ZIndex = 101
    spinner.Parent = overlay

    -- Spinner ring
    local ring = Instance.new("UIStroke")
    ring.Color = Color3.fromRGB(255, 70, 30)
    ring.Thickness = 3
    ring.Parent = spinner

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = spinner

    local spinTween = TweenService:Create(spinner, TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1),
        {Rotation = 360})
    spinTween:Play()

    return overlay, spinTween
end

-- ═══════════════════════════════════════════════════════════
-- MAIN UI CONSTRUCTION
-- ═══════════════════════════════════════════════════════════
local function buildMainUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ThanHubUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = CoreGui

    -- ═══════════════════════════════════════════════════════
    -- TOP BAR - Cash Multiplier Display
    -- ═══════════════════════════════════════════════════════
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    TopBar.BackgroundTransparency = 0.15
    TopBar.BorderSizePixel = 0
    TopBar.Parent = ScreenGui
    roundCorner(TopBar, 0)

    local topGradient = Instance.new("UIGradient")
    topGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 12, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 18))
    })
    topGradient.Parent = TopBar

    local topLine = Instance.new("Frame")
    topLine.Size = UDim2.new(1, 0, 0, 1)
    topLine.Position = UDim2.new(0, 0, 1, -1)
    topLine.BackgroundColor3 = Color3.fromRGB(255, 70, 30)
    topLine.BackgroundTransparency = 0.6
    topLine.BorderSizePixel = 0
    topLine.Parent = TopBar

    -- Cash Multi label
    local CashLabel = Instance.new("TextLabel")
    CashLabel.Size = UDim2.new(0, 160, 0, 45)
    CashLabel.Position = UDim2.new(0, 20, 0, 0)
    CashLabel.BackgroundTransparency = 1
    CashLabel.Font = Enum.Font.GothamBold
    CashLabel.Text = "CASH MULTI:"
    CashLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    CashLabel.TextSize = 16
    CashLabel.TextXAlignment = Enum.TextXAlignment.Left
    CashLabel.Parent = TopBar

    local CashValue = Instance.new("TextLabel")
    CashValue.Size = UDim2.new(0, 120, 0, 45)
    CashValue.Position = UDim2.new(0, 160, 0, 0)
    CashValue.BackgroundTransparency = 1
    CashValue.Font = Enum.Font.GothamBlack
    CashValue.Text = "x1.0"
    CashValue.TextColor3 = Color3.fromRGB(255, 70, 30)
    CashValue.TextSize = 18
    CashValue.TextXAlignment = Enum.TextXAlignment.Left
    CashValue.Parent = TopBar

    -- FPS Counter
    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.new(0, 100, 0, 45)
    FPSLabel.Position = UDim2.new(1, -120, 0, 0)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Font = Enum.Font.Gotham
    FPSLabel.Text = "FPS: 60"
    FPSLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
    FPSLabel.TextSize = 12
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Right
    FPSLabel.Parent = TopBar

    -- Game time
    local TimeLabel = Instance.new("TextLabel")
    TimeLabel.Size = UDim2.new(0, 120, 0, 45)
    TimeLabel.Position = UDim2.new(1, -240, 0, 0)
    TimeLabel.BackgroundTransparency = 1
    TimeLabel.Font = Enum.Font.Gotham
    TimeLabel.Text = "00:00:00"
    TimeLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
    TimeLabel.TextSize = 12
    TimeLabel.TextXAlignment = Enum.TextXAlignment.Right
    TimeLabel.Parent = TopLabel or TopBar

    -- Update FPS
    local lastTick = tick()
    local fpsFrames = 0
    RunService.RenderStepped:Connect(function()
        fpsFrames = fpsFrames + 1
        if tick() - lastTick >= 1 then
            FPSLabel.Text = "FPS: " .. fpsFrames
            fpsFrames = 0
            lastTick = tick()
        end
    end)

    -- Update time
    task.spawn(function()
        local startTime = tick()
        while task.wait(1) do
            if not ScreenGui.Parent then break end
            local elapsed = tick() - startTime
            local h = math.floor(elapsed / 3600)
            local m = math.floor((elapsed % 3600) / 60)
            local s = math.floor(elapsed % 60)
            TimeLabel.Text = string.format("%02d:%02d:%02d", h, m, s)
        end
    end)

    -- ═══════════════════════════════════════════════════════
    -- LEFT SIDE - Quick Action Buttons
    -- ═══════════════════════════════════════════════════════
    local LeftPanel = Instance.new("Frame")
    LeftPanel.Name = "LeftPanel"
    LeftPanel.Size = UDim2.new(0, 55, 0, 320)
    LeftPanel.Position = UDim2.new(0, 12, 0.5, -160)
    LeftPanel.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    LeftPanel.BackgroundTransparency = 0.08
    LeftPanel.BorderSizePixel = 0
    LeftPanel.Parent = ScreenGui
    roundCorner(LeftPanel, 12)
    addStroke(LeftPanel, Color3.fromRGB(40, 40, 55))

    local leftButtons = {
        {name = "Shop", icon = "S", callback = function()
            -- Teleport to shop area
            local char = Player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("Part") and (v.Name:lower():find("shop") or v.Name:lower():find("store")) then
                            hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                            return
                        end
                    end
                end
            end
        end},
        {name = "Zone", icon = "Z", callback = function()
            -- Teleport to collect zone
            local char = Player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("Part") and (v.Name:lower():find("collect") or v.Name:lower():find("zone")) then
                            hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                            return
                        end
                    end
                end
            end
        end},
        {name = "Sell", icon = "$", callback = function()
            -- Find and trigger sell
            local char = Player.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("Part") and (v.Name:lower():find("sell") or v.Name:lower():find("bank")) then
                            hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                            fireproximityprompt(v:FindFirstChildOfClass("ProximityPrompt") or v.Parent:FindFirstChildOfClass("ProximityPrompt"))
                            return
                        end
                    end
                end
            end
        end},
        {name = "Rebirth", icon = "R", callback = function()
            -- Find and trigger rebirth
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.Name:lower():find("rebirth") then
                    fireproximityprompt(v)
                    return
                end
            end
            -- Fallback: fire any rebirth remote
            for _, v in pairs(getgenv and {} or {}) do end
        end},
        {name = "TP", icon = "T", callback = function()
            -- Teleport to random player
            local players = Players:GetPlayers()
            if #players > 1 then
                local target = players[math.random(2, #players)]
                if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                    Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
                end
            end
        end},
        {name = "Reset", icon = "X", callback = function()
            local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.Health = 0 end
        end},
    }

    for i, btnData in ipairs(leftButtons) do
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 40, 0, 40)
        Btn.Position = UDim2.new(0, 7, 0, 8 + (i - 1) * 50)
        Btn.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
        Btn.BorderSizePixel = 0
        Btn.Font = Enum.Font.GothamBold
        Btn.Text = btnData.icon
        Btn.TextColor3 = Color3.fromRGB(200, 200, 210)
        Btn.TextSize = 16
        Btn.Parent = LeftPanel
        roundCorner(Btn, 8)

        local tooltip = Instance.new("TextLabel")
        tooltip.Size = UDim2.new(0, 80, 0, 22)
        tooltip.Position = UDim2.new(1, 8, 0.5, -11)
        tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
        tooltip.Font = Enum.Font.Gotham
        tooltip.Text = btnData.name
        tooltip.TextColor3 = Color3.fromRGB(220, 220, 230)
        tooltip.TextSize = 11
        tooltip.TextTransparency = 1
        tooltip.BorderSizePixel = 0
        tooltip.Parent = Btn
        roundCorner(tooltip, 5)

        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 70, 30)}):Play()
            TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(tooltip, TweenInfo.new(0.2), {TextTransparency = 0}):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 38)}):Play()
            TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 210)}):Play()
            TweenService:Create(tooltip, TweenInfo.new(0.15), {TextTransparency = 1}):Play()
        end)
        Btn.MouseButton1Click:Connect(function()
            -- Mini loading effect
            local overlay, spinTween = createMiniLoading(LeftPanel)
            task.delay(0.5, function()
                spinTween:Cancel()
                if overlay and overlay.Parent then overlay:Destroy() end
                btnData.callback()
            end)
        end)
    end

    -- ═══════════════════════════════════════════════════════
    -- RIGHT SIDE - Main Feature Panel
    -- ═══════════════════════════════════════════════════════
    local RightPanel = Instance.new("Frame")
    RightPanel.Name = "RightPanel"
    RightPanel.Size = UDim2.new(0, 280, 0, 520)
    RightPanel.Position = UDim2.new(1, -295, 0.5, -260)
    RightPanel.BackgroundColor3 = Color3.fromRGB(14, 14, 22)
    RightPanel.BackgroundTransparency = 0.05
    RightPanel.BorderSizePixel = 0
    RightPanel.Parent = ScreenGui
    roundCorner(RightPanel, 14)
    addStroke(RightPanel, Color3.fromRGB(40, 40, 55))
    makeDraggable(RightPanel)

    -- Panel header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundColor3 = Color3.fromRGB(18, 15, 25)
    Header.BorderSizePixel = 0
    Header.Parent = RightPanel
    roundCorner(Header, 14)

    -- Fix bottom corners of header
    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 14)
    headerFix.Position = UDim2.new(0, 0, 1, -14)
    headerFix.BackgroundColor3 = Color3.fromRGB(18, 15, 25)
    headerFix.BorderSizePixel = 0
    headerFix.Parent = Header

    local headerLine = Instance.new("Frame")
    headerLine.Size = UDim2.new(1, -20, 0, 1)
    headerLine.Position = UDim2.new(0, 10, 1, -1)
    headerLine.BackgroundColor3 = Color3.fromRGB(255, 70, 30)
    headerLine.BackgroundTransparency = 0.5
    headerLine.BorderSizePixel = 0
    headerLine.Parent = Header

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Size = UDim2.new(0, 180, 0, 50)
    HeaderTitle.Position = UDim2.new(0, 15, 0, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.GothamBlack
    HeaderTitle.Text = "THANHUB"
    HeaderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    HeaderTitle.TextSize = 20
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.Parent = Header

    local headerStroke = Instance.new("TextStroke")
    headerStroke.Color = Color3.fromRGB(255, 60, 20)
    headerStroke.Transparency = 0.7
    headerStroke.Thickness = 1.5
    headerStroke.Parent = HeaderTitle

    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -38, 0, 10)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseBtn.TextSize = 14
    CloseBtn.Parent = Header
    roundCorner(CloseBtn, 6)

    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(180, 40, 40)}):Play()
    end)
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 20, 20)}):Play()
    end)
    CloseBtn.MouseButton1Click:Connect(function()
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0)
        overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.85
        overlay.ZIndex = 50
        overlay.Parent = RightPanel
        task.delay(0.3, function()
            RightPanel:Destroy()
        end)
    end)

    -- Minimize button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -72, 0, 10)
    MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    MinBtn.BorderSizePixel = 0
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Text = "_"
    MinBtn.TextColor3 = Color3.fromRGB(160, 160, 180)
    MinBtn.TextSize = 16
    MinBtn.Parent = Header
    roundCorner(MinBtn, 6)

    local isMinimized = false
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, -16, 1, -58)
    ContentFrame.Position = UDim2.new(0, 8, 0, 54)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ClipsDescendants = true
    ContentFrame.Parent = RightPanel

    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            TweenService:Create(RightPanel, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {Size = UDim2.new(0, 280, 0, 50)}):Play()
            TweenService:Create(ContentFrame, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
        else
            TweenService:Create(RightPanel, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                {Size = UDim2.new(0, 280, 0, 520)}):Play()
        end
    end)

    -- Scroll frame for features
    local ScrollFrame = Instance.new("ScrollingFrame")
    ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
    ScrollFrame.BackgroundTransparency = 1
    ScrollFrame.ScrollBarThickness = 3
    ScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 70, 30)
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollFrame.BorderSizePixel = 0
    ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollFrame.Parent = ContentFrame

    local UIList = Instance.new("UIListLayout")
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 5)
    UIList.Parent = ScrollFrame

    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, 4)
    UIPadding.PaddingRight = UDim.new(0, 4)
    UIPadding.PaddingTop = UDim.new(0, 4)
    UIPadding.PaddingBottom = UDim.new(0, 4)
    UIPadding.Parent = ScrollFrame

    -- ═══════════════════════════════════════════════════════
    -- FEATURE TOGGLES
    -- ═══════════════════════════════════════════════════════
    local toggledFeatures = {}
    local featureConnections = {}

    local function createToggle(name, description, default, callback)
        local layoutOrder = #ScrollFrame:GetChildren()

        local ToggleFrame = Instance.new("Frame")
        ToggleFrame.Name = name
        ToggleFrame.Size = UDim2.new(1, 0, 0, 52)
        ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
        ToggleFrame.BorderSizePixel = 0
        ToggleFrame.LayoutOrder = layoutOrder
        ToggleFrame.Parent = ScrollFrame
        roundCorner(ToggleFrame, 10)

        -- Name label
        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(0, 170, 0, 20)
        NameLabel.Position = UDim2.new(0, 14, 0, 8)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.Text = name
        NameLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
        NameLabel.TextSize = 13
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = ToggleFrame

        -- Description
        local DescLabel = Instance.new("TextLabel")
        DescLabel.Size = UDim2.new(0, 200, 0, 16)
        DescLabel.Position = UDim2.new(0, 14, 0, 28)
        DescLabel.BackgroundTransparency = 1
        DescLabel.Font = Enum.Font.Gotham
        DescLabel.Text = description
        DescLabel.TextColor3 = Color3.fromRGB(110, 110, 130)
        DescLabel.TextSize = 10
        DescLabel.TextXAlignment = Enum.TextXAlignment.Left
        DescLabel.Parent = ToggleFrame

        -- Toggle switch background
        local ToggleBg = Instance.new("Frame")
        ToggleBg.Size = UDim2.new(0, 42, 0, 22)
        ToggleBg.Position = UDim2.new(1, -56, 0.5, -11)
        ToggleBg.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        ToggleBg.BorderSizePixel = 0
        ToggleBg.Parent = ToggleFrame
        roundCorner(ToggleBg, 11)

        -- Toggle switch circle
        local ToggleCircle = Instance.new("Frame")
        ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
        ToggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
        ToggleCircle.BackgroundColor3 = Color3.fromRGB(120, 120, 140)
        ToggleCircle.BorderSizePixel = 0
        ToggleCircle.Parent = ToggleBg
        roundCorner(ToggleCircle, 9)

        local isOn = default or false
        toggledFeatures[name] = isOn

        local function updateVisual(state)
            isOn = state
            toggledFeatures[name] = state
            if state then
                TweenService:Create(ToggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = Color3.fromRGB(255, 70, 30)}):Play()
                TweenService:Create(ToggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 22, 0.5, -9)}):Play()
                TweenService:Create(ToggleCircle, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 22, 35)}):Play()
            else
                TweenService:Create(ToggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}):Play()
                TweenService:Create(ToggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
                TweenService:Create(ToggleCircle, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(120, 120, 140)}):Play()
                TweenService:Create(ToggleFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 35)}):Play()
            end
        end

        if isOn then updateVisual(true) end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = ToggleFrame

        btn.MouseButton1Click:Connect(function()
            -- Mini loading feedback
            local overlay = Instance.new("Frame")
            overlay.Size = UDim2.new(1, 0, 1, 0)
            overlay.BackgroundColor3 = Color3.fromRGB(255, 70, 30)
            overlay.BackgroundTransparency = 0.85
            overlay.BorderSizePixel = 0
            overlay.ZIndex = 10
            overlay.Parent = ToggleFrame
            roundCorner(overlay, 10)

            task.delay(0.2, function()
                if overlay.Parent then overlay:Destroy() end
                updateVisual(not isOn)
                if callback then callback(isOn) end
            end)
        end)

        return toggledFeatures
    end

    local function createSlider(name, min, max, default, callback)
        local SliderFrame = Instance.new("Frame")
        SliderFrame.Name = name
        SliderFrame.Size = UDim2.new(1, 0, 0, 58)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
        SliderFrame.BorderSizePixel = 0
        SliderFrame.Parent = ScrollFrame
        roundCorner(SliderFrame, 10)

        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.new(0, 200, 0, 20)
        NameLabel.Position = UDim2.new(0, 14, 0, 6)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.Text = name
        NameLabel.TextColor3 = Color3.fromRGB(230, 230, 240)
        NameLabel.TextSize = 13
        NameLabel.TextXAlignment = Enum.TextXAlignment.Left
        NameLabel.Parent = SliderFrame

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 60, 0, 20)
        ValueLabel.Position = UDim2.new(1, -70, 0, 6)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Font = Enum.Font.GothamBold
        ValueLabel.Text = tostring(default)
        ValueLabel.TextColor3 = Color3.fromRGB(255, 70, 30)
        ValueLabel.TextSize = 13
        ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
        ValueLabel.Parent = SliderFrame

        -- Slider track
        local Track = Instance.new("Frame")
        Track.Size = UDim2.new(1, -28, 0, 6)
        Track.Position = UDim2.new(0, 14, 0, 34)
        Track.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
        Track.BorderSizePixel = 0
        Track.Parent = SliderFrame
        roundCorner(Track, 3)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(255, 70, 30)
        Fill.BorderSizePixel = 0
        Fill.Parent = Track
        roundCorner(Fill, 3)

        local SliderBtn = Instance.new("TextButton")
        SliderBtn.Size = UDim2.new(1, -28, 0, 24)
        SliderBtn.Position = UDim2.new(0, 14, 0, 25)
        SliderBtn.BackgroundTransparency = 1
        SliderBtn.Text = ""
        SliderBtn.Parent = SliderFrame

        local sliding = false
        SliderBtn.MouseButton1Down:Connect(function()
            sliding = true
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local relX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local val = min + (max - min) * relX
                val = math.floor(val * 10) / 10
                Fill.Size = UDim2.new(relX, 0, 1, 0)
                ValueLabel.Text = tostring(val)
                if callback then callback(val) end
            end
        end)

        if callback then callback(default) end
    end

    -- ═══════════════════════════════════════════════════════
    -- SECTION: COMBAT
    -- ═══════════════════════════════════════════════════════
    local sectionLabel1 = Instance.new("TextLabel")
    sectionLabel1.Size = UDim2.new(1, 0, 0, 26)
    sectionLabel1.BackgroundTransparency = 1
    sectionLabel1.Font = Enum.Font.GothamBold
    sectionLabel1.Text = "  COMBAT"
    sectionLabel1.TextColor3 = Color3.fromRGB(255, 70, 30)
    sectionLabel1.TextSize = 11
    sectionLabel1.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel1.Parent = ScrollFrame

    createToggle("Melee Aimbott", "Auto-aim at nearest player with melee", false, function(state)
        if state then
            featureConnections["MeleeAimbot"] = RunService.RenderStepped:Connect(function()
                if not toggledFeatures["Melee Aimbott"] then return end
                local char = Player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local hrp = char.HumanoidRootPart
                local closest, closestDist = nil, math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (hrp.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = p.Character.HumanoidRootPart
                        end
                    end
                end
                if closest and closestDist < 50 then
                    local newCF = CFrame.new(hrp.Position, closest.Position)
                    hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, newCF:ToEulerAnglesYXZ(), 0)
                end
            end)
        else
            if featureConnections["MeleeAimbot"] then
                featureConnections["MeleeAimbot"]:Disconnect()
                featureConnections["MeleeAimbot"] = nil
            end
        end
    end)

    createToggle("Auto Swing", "Automatically swing your melee weapon", false, function(state)
        if state then
            featureConnections["AutoSwing"] = RunService.RenderStepped:Connect(function()
                if not toggledFeatures["Auto Swing"] then return end
                local char = Player.Character
                if not char then return end
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    local activate = tool:FindFirstChildOfClass("RemoteEvent")
                    if activate then
                        activate:FireServer()
                    end
                    -- Also try AnimSaves
                    for _, v in pairs(tool:GetDescendants()) do
                        if v:IsA("RemoteEvent") then
                            v:FireServer()
                        end
                    end
                end
            end)
        else
            if featureConnections["AutoSwing"] then
                featureConnections["AutoSwing"]:Disconnect()
                featureConnections["AutoSwing"] = nil
            end
        end
    end)

    createToggle("Kill Aura", "Attack all players in range automatically", false, function(state)
        if state then
            featureConnections["KillAura"] = RunService.RenderStepped:Connect(function()
                if not toggledFeatures["Kill Aura"] then return end
                local char = Player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool then return end
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (char.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < 30 then
                            for _, v in pairs(tool:GetDescendants()) do
                                if v:IsA("RemoteEvent") then
                                    v:FireServer(p.Character.HumanoidRootPart)
                                end
                            end
                        end
                    end
                end
            end)
        else
            if featureConnections["KillAura"] then
                featureConnections["KillAura"]:Disconnect()
                featureConnections["KillAura"] = nil
            end
        end
    end)

    createToggle("Hitbox Expander", "Make enemy hitboxes bigger", false, function(state)
        if state then
            featureConnections["Hitbox"] = RunService.Heartbeat:Connect(function()
                if not toggledFeatures["Hitbox Expander"] then return end
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= Player and p.Character then
                        for _, part in pairs(p.Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.Name:find("Hitbox") or (part:IsA("BasePart") and part.Size.X < 10) then
                                part.Size = Vector3.new(10, 10, 10)
                                part.Transparency = 0.7
                            end
                        end
                    end
                end
            end)
        else
            if featureConnections["Hitbox"] then
                featureConnections["Hitbox"]:Disconnect()
                featureConnections["Hitbox"] = nil
            end
        end
    end)

    -- ═══════════════════════════════════════════════════════
    -- SECTION: FARMING
    -- ═══════════════════════════════════════════════════════
    local sectionLabel2 = Instance.new("TextLabel")
    sectionLabel2.Size = UDim2.new(1, 0, 0, 26)
    sectionLabel2.BackgroundTransparency = 1
    sectionLabel2.Font = Enum.Font.GothamBold
    sectionLabel2.Text = "  FARMING"
    sectionLabel2.TextColor3 = Color3.fromRGB(255, 70, 30)
    sectionLabel2.TextSize = 11
    sectionLabel2.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel2.Parent = ScrollFrame

    createToggle("Auto Collect", "Automatically collect items in zone", false, function(state)
        if state then
            featureConnections["AutoCollect"] = RunService.Heartbeat:Connect(function()
                if not toggledFeatures["Auto Collect"] then return end
                local char = Player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") or v:IsA("Model") then
                        local pos = v:IsA("Model") and (v.PrimaryPart and v.PrimaryPart.Position) or v.Position
                        if pos and (char.HumanoidRootPart.Position - pos).Magnitude < 80 then
                            if v:IsA("BasePart") then
                                firetouchinterest(char.HumanoidRootPart, v, 0)
                                firetouchinterest(char.HumanoidRootPart, v, 1)
                            end
                        end
                    end
                end
            end)
        else
            if featureConnections["AutoCollect"] then
                featureConnections["AutoCollect"]:Disconnect()
                featureConnections["AutoCollect"] = nil
            end
        end
    end)

    createToggle("Auto Farm", "Auto farm loop: collect & sell", false, function(state)
        if state then
            featureConnections["AutoFarm"] = task.spawn(function()
                while toggledFeatures["Auto Farm"] do
                    -- Find collect zone
                    local char = Player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        -- Go to collect zone
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("Part") and v.Name:lower():find("collect") then
                                hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                                task.wait(3)
                                break
                            end
                        end
                        -- Collect
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("BasePart") and (hrp.Position - v.Position).Magnitude < 60 then
                                firetouchinterest(hrp, v, 0)
                                firetouchinterest(hrp, v, 1)
                            end
                        end
                        task.wait(1)
                        -- Go to sell
                        for _, v in pairs(workspace:GetDescendants()) do
                            if v:IsA("Part") and v.Name:lower():find("sell") then
                                hrp.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                                local prompt = v:FindFirstChildOfClass("ProximityPrompt") or v.Parent:FindFirstChildOfClass("ProximityPrompt")
                                if prompt then fireproximityprompt(prompt) end
                                task.wait(2)
                                break
                            end
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            toggledFeatures["Auto Farm"] = false
        end
    end)

    createToggle("Auto Rebirth", "Automatically rebirth when possible", false, function(state)
        if state then
            featureConnections["AutoRebirth"] = task.spawn(function()
                while toggledFeatures["Auto Rebirth"] do
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("ProximityPrompt") and v.Name:lower():find("rebirth") then
                            if v.Enabled then
                                fireproximityprompt(v)
                                task.wait(2)
                            end
                        end
                    end
                    -- Also check GUI buttons
                    for _, v in pairs(Player.PlayerGui:GetDescendants()) do
                        if v:IsA("TextButton") and v.Name:lower():find("rebirth") and v.Visible then
                            task.spawn(function()
                                if v.AbsoluteSize.X > 0 then
                                    local events = {"MouseButton1Click", "Activated"}
                                    for _, e in pairs(events) do
                                        local conn = v[e]
                                        if conn then
                                            -- Simulate click position
                                            local pos = Vector2.new(v.AbsolutePosition.X + v.AbsoluteSize.X / 2, v.AbsolutePosition.Y + v.AbsoluteSize.Y / 2)
                                            game:GetService("VirtualInputManager"):SendMouseButtonEvent(pos.X, pos.Y, 0, true, game)
                                            task.wait(0.05)
                                            game:GetService("VirtualInputManager"):SendMouseButtonEvent(pos.X, pos.Y, 0, false, game)
                                        end
                                    end
                                end
                            end)
                            task.wait(3)
                        end
                    end
                    task.wait(1)
                end
            end)
        end
    end)

    createToggle("Auto Sell", "Automatically sell when at sell area", false, function(state)
        if state then
            featureConnections["AutoSell"] = RunService.Heartbeat:Connect(function()
                if not toggledFeatures["Auto Sell"] then return end
                local char = Player.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then return end
                local hrp = char.HumanoidRootPart
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and v.Name:lower():find("sell") then
                        if (hrp.Position - v.Parent.Position).Magnitude < 20 and v.Enabled then
                            fireproximityprompt(v)
                        end
                    end
                end
            end)
        else
            if featureConnections["AutoSell"] then
                featureConnections["AutoSell"]:Disconnect()
                featureConnections["AutoSell"] = nil
            end
        end
    end)

    -- Cash Multi slider
    createSlider("Cash Multiplier", 1, 100, 1, function(val)
        CashValue.Text = "x" .. tostring(val)
    end)

    -- ═══════════════════════════════════════════════════════
    -- SECTION: MOVEMENT
    -- ═══════════════════════════════════════════════════════
    local sectionLabel3 = Instance.new("TextLabel")
    sectionLabel3.Size = UDim2.new(1, 0, 0, 26)
    sectionLabel3.BackgroundTransparency = 1
    sectionLabel3.Font = Enum.Font.GothamBold
    sectionLabel3.Text = "  MOVEMENT"
    sectionLabel3.TextColor3 = Color3.fromRGB(255, 70, 30)
    sectionLabel3.TextSize = 11
    sectionLabel3.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel3.Parent = ScrollFrame

    createToggle("Speed Hack", "Increase walk speed", false, function(state)
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = state and 50 or 16
        end
    end)

    createToggle("Jump Boost", "Increase jump power", false, function(state)
        local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = state and 100 or 50
        end
    end)

    createToggle("Infinite Jump", "Jump mid-air unlimited times", false, function(state)
        if state then
            featureConnections["InfJump"] = UserInputService.JumpRequest:Connect(function()
                if not toggledFeatures["Infinite Jump"] then return end
                local hum = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        else
            if featureConnections["InfJump"] then
                featureConnections["InfJump"]:Disconnect()
                featureConnections["InfJump"] = nil
            end
        end
    end)

    createToggle("No Clip", "Walk through walls", false, function(state)
        if state then
            featureConnections["NoClip"] = RunService.Stepped:Connect(function()
                if not toggledFeatures["No Clip"] then return end
                local char = Player.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if featureConnections["NoClip"] then
                featureConnections["NoClip"]:Disconnect()
                featureConnections["NoClip"] = nil
            end
            -- Re-enable collision
            if Player.Character then
                for _, part in pairs(Player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end)

    createToggle("Fly", "Noclip fly mode (E to toggle up/down)", false, function(state)
        if state then
            local flyBody = nil
            local flying = true
            local speed = 60
            featureConnections["Fly"] = RunService.RenderStepped:Connect(function()
                if not toggledFeatures["Fly"] or not Player.Character then return end
                local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                if not flyBody then
                    flyBody = Instance.new("BodyVelocity")
                    flyBody.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    flyBody.Velocity = Vector3.new(0, 0, 0)
                    flyBody.Parent = hrp
                    local gyro = Instance.new("BodyGyro")
                    gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    gyro.P = 9000
                    gyro.Parent = hrp
                    featureConnections["FlyGyro"] = gyro
                end
                local camCF = Camera.CFrame
                local direction = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - camCF.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + camCF.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then direction = direction - Vector3.new(0, 1, 0) end
                flyBody.Velocity = direction * speed
                if featureConnections["FlyGyro"] then
                    featureConnections["FlyGyro"].CFrame = camCF
                end
            end)
        else
            if featureConnections["Fly"] then
                featureConnections["Fly"]:Disconnect()
                featureConnections["Fly"] = nil
            end
            if featureConnections["FlyGyro"] then
                featureConnections["FlyGyro"]:Destroy()
                featureConnections["FlyGyro"] = nil
            end
            if Player.Character then
                local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    for _, v in pairs(hrp:GetChildren()) do
                        if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then
                            v:Destroy()
                        end
                    end
                end
            end
        end
    end)

    -- ═══════════════════════════════════════════════════════
    -- SECTION: VISUAL
    -- ═══════════════════════════════════════════════════════
    local sectionLabel4 = Instance.new("TextLabel")
    sectionLabel4.Size = UDim2.new(1, 0, 0, 26)
    sectionLabel4.BackgroundTransparency = 1
    sectionLabel4.Font = Enum.Font.GothamBold
    sectionLabel4.Text = "  VISUAL"
    sectionLabel4.TextColor3 = Color3.fromRGB(255, 70, 30)
    sectionLabel4.TextSize = 11
    sectionLabel4.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel4.Parent = ScrollFrame

    createToggle("ESP Players", "Highlight all players through walls", false, function(state)
        if state then
            featureConnections["ESP"] = {}
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ThanHubESP"
                    highlight.FillColor = Color3.fromRGB(255, 70, 30)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.6
                    highlight.OutlineTransparency = 0.2
                    highlight.Parent = p.Character
                    table.insert(featureConnections["ESP"], highlight)
                end
            end
            featureConnections["ESPConn"] = Players.PlayerAdded:Connect(function(p)
                if not toggledFeatures["ESP Players"] then return end
                p.CharacterAdded:Connect(function(char)
                    task.wait(1)
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "ThanHubESP"
                    highlight.FillColor = Color3.fromRGB(255, 70, 30)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.6
                    highlight.OutlineTransparency = 0.2
                    highlight.Parent = char
                    table.insert(featureConnections["ESP"], highlight)
                end)
            end)
        else
            if featureConnections["ESP"] then
                for _, h in pairs(featureConnections["ESP"]) do
                    if h and h.Parent then h:Destroy() end
                end
                featureConnections["ESP"] = nil
            end
            if featureConnections["ESPConn"] then
                featureConnections["ESPConn"]:Disconnect()
                featureConnections["ESPConn"] = nil
            end
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character then
                    local esp = p.Character:FindFirstChild("ThanHubESP")
                    if esp then esp:Destroy() end
                end
            end
        end
    end)

    createToggle("ESP Items", "Highlight collectible items", false, function(state)
        if state then
            featureConnections["ESPItems"] = RunService.Heartbeat:Connect(function()
                if not toggledFeatures["ESP Items"] then return end
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("BasePart") and not v:FindFirstChild("ThanHubItemESP") then
                        if v.Name:lower():find("coin") or v.Name:lower():find("gem") or v.Name:lower():find("cash")
                            or v.Name:lower():find("money") or v.Name:lower():find("collect") or v.Name:lower():find("drop") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "ThanHubItemESP"
                            highlight.FillColor = Color3.fromRGB(255, 200, 50)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 100)
                            highlight.FillTransparency = 0.4
                            highlight.Parent = v
                        end
                    end
                end
            end)
        else
            if featureConnections["ESPItems"] then
                featureConnections["ESPItems"]:Disconnect()
                featureConnections["ESPItems"] = nil
            end
            for _, v in pairs(workspace:GetDescendants()) do
                local esp = v:FindFirstChild("ThanHubItemESP")
                if esp then esp:Destroy() end
            end
        end
    end)

    createToggle("Fullbright", "Remove all darkness from the game", false, function(state)
        if state then
            featureConnections["Fullbright"] = {}
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
            Lighting.Ambient = Color3.fromRGB(0, 0, 0)
        end
    end)

    -- ═══════════════════════════════════════════════════════
    -- SECTION: MISC
    -- ═══════════════════════════════════════════════════════
    local sectionLabel5 = Instance.new("TextLabel")
    sectionLabel5.Size = UDim2.new(1, 0, 0, 26)
    sectionLabel5.BackgroundTransparency = 1
    sectionLabel5.Font = Enum.Font.GothamBold
    sectionLabel5.Text = "  MISC"
    sectionLabel5.TextColor3 = Color3.fromRGB(255, 70, 30)
    sectionLabel5.TextSize = 11
    sectionLabel5.TextXAlignment = Enum.TextXAlignment.Left
    sectionLabel5.Parent = ScrollFrame

    createToggle("Anti AFK", "Prevent getting kicked for being idle", false, function(state)
        if state then
            featureConnections["AntiAFK"] = task.spawn(function()
                while toggledFeatures["Anti AFK"] do
                    local VirtualUser = game:GetService("VirtualUser")
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                    task.wait(60)
                end
            end)
        end
    end)

    createToggle("Auto Rejoin", "Auto rejoin when kicked or died", false, function(state)
        if state then
            featureConnections["AutoRejoin"] = Player.OnTeleport:Connect(function(state2)
                if state2 == Enum.TeleportState.Failed then
                    task.wait(2)
                    game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
                end
            end)
        else
            if featureConnections["AutoRejoin"] then
                featureConnections["AutoRejoin"]:Disconnect()
                featureConnections["AutoRejoin"] = nil
            end
        end
    end)

    createToggle("Server Hop", "Hop to a different server", false, function(state)
        if state then
            task.delay(0.5, function()
                toggledFeatures["Server Hop"] = false
                -- Update visual
                local toggleFrame = ScrollFrame:FindFirstChild("Server Hop")
                if toggleFrame then
                    -- Find the toggle circle and reset it
                    for _, child in pairs(toggleFrame:GetDescendants()) do
                        if child:IsA("Frame") and child.Size == UDim2.new(0, 18, 0, 18) then
                            TweenService:Create(child.Parent, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}):Play()
                            TweenService:Create(child, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
                            TweenService:Create(child, TweenInfo.new(0.25), {BackgroundColor3 = Color3.fromRGB(120, 120, 140)}):Play()
                        end
                    end
                end
                -- Get server ID
                local servers = {}
                local req = (syn and syn.request) or (http and http.request) or request
                if req then
                    pcall(function()
                        local id = game.PlaceId
                        local response = req({
                            Url = "https://games.roblox.com/v1/games/" .. id .. "/servers/Public?limit=100"
                        })
                        local data = game:GetService("HttpService"):JSONDecode(response.Body)
                        if data and data.data then
                            for _, server in pairs(data.data) do
                                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                                    table.insert(servers, server.id)
                                end
                            end
                        end
                    end)
                end
                if #servers > 0 then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Player)
                end
            end)
        end
    end)

    createToggle("Chat Spammer", "Spam chat with custom message", false, function(state)
        if state then
            featureConnections["ChatSpam"] = task.spawn(function()
                while toggledFeatures["Chat Spammer"] do
                    pcall(function()
                        game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents"):FindFirstChild("SayMessageRequest"):FireServer("ThanHub on top!", "All")
                    end)
                    task.wait(3)
                end
            end)
        else
            toggledFeatures["Chat Spammer"] = false
        end
    end)

    -- ═══════════════════════════════════════════════════════
    -- BOTTOM: Toggle Key
    -- ═══════════════════════════════════════════════════════
    local KeyLabel = Instance.new("TextLabel")
    KeyLabel.Size = UDim2.new(1, 0, 0, 30)
    KeyLabel.Position = UDim2.new(0, 0, 1, -30)
    KeyLabel.BackgroundColor3 = Color3.fromRGB(18, 15, 25)
    KeyLabel.BorderSizePixel = 0
    KeyLabel.Font = Enum.Font.Gotham
    KeyLabel.Text = "Right Ctrl to toggle UI"
    KeyLabel.TextColor3 = Color3.fromRGB(80, 80, 100)
    KeyLabel.TextSize = 10
    KeyLabel.Parent = RightPanel

    local keyLine = Instance.new("Frame")
    keyLine.Size = UDim2.new(1, 0, 0, 1)
    keyLine.Position = UDim2.new(0, 0, 0, 0)
    keyLine.BackgroundColor3 = Color3.fromRGB(255, 70, 30)
    keyLine.BackgroundTransparency = 0.7
    keyLine.BorderSizePixel = 0
    keyLine.Parent = KeyLabel

    -- Toggle UI with RightCtrl
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightControl then
            RightPanel.Visible = not RightPanel.Visible
            LeftPanel.Visible = RightPanel.Visible
            TopBar.Visible = RightPanel.Visible
        end
    end)

    return ScreenGui
end

-- ═══════════════════════════════════════════════════════════
-- MAIN EXECUTION
-- ═══════════════════════════════════════════════════════════

-- Remove any existing UI
if CoreGui:FindFirstChild("ThanHubLoading") then
    CoreGui:FindFirstChild("ThanHubLoading"):Destroy()
end
if CoreGui:FindFirstChild("ThanHubUI") then
    CoreGui:FindFirstChild("ThanHubUI"):Destroy()
end

-- Show loading screen, then build UI
local loadTime = createLoadingScreen()
task.delay(loadTime, function()
    buildMainUI()
end)

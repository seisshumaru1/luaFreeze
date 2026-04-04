-- ═══════════════════════════════════════════════════════════════
-- UNKNOWN HUB - Full Featured Script Hub
-- ═══════════════════════════════════════════════════════════════

-- Services
local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local HttpService   = game:GetService("HttpService")
local CoreGui       = game:GetService("CoreGui")
local RunService    = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer   = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════
-- COLOR SCHEME - Dark/Cyan Theme
-- ═══════════════════════════════════════════════════════════════
local Colors = {
    BG_DARK       = Color3.fromRGB(10, 12, 18),
    BG_CARD       = Color3.fromRGB(16, 20, 28),
    BG_CARD_2     = Color3.fromRGB(22, 27, 38),
    BG_HOVER      = Color3.fromRGB(28, 35, 50),
    BG_INPUT      = Color3.fromRGB(18, 22, 32),
    ACCENT        = Color3.fromRGB(0, 200, 255),
    ACCENT_DARK   = Color3.fromRGB(0, 150, 200),
    ACCENT_GLOW   = Color3.fromRGB(0, 200, 255),
    SUCCESS       = Color3.fromRGB(0, 255, 136),
    WARNING       = Color3.fromRGB(255, 200, 0),
    DANGER        = Color3.fromRGB(255, 60, 60),
    TEXT_PRIMARY   = Color3.fromRGB(240, 245, 255),
    TEXT_SECONDARY = Color3.fromRGB(140, 160, 190),
    TEXT_MUTED     = Color3.fromRGB(80, 95, 120),
    STROKE        = Color3.fromRGB(40, 50, 70),
    STROKE_ACCENT = Color3.fromRGB(0, 200, 255),
    TOGGLE_ON     = Color3.fromRGB(0, 200, 255),
    TOGGLE_OFF    = Color3.fromRGB(60, 70, 90),
    SHADOW        = Color3.fromRGB(0, 0, 0),
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════
local function GetSafeGui()
    if gethui then return gethui() end
    if CoreGui then return CoreGui end
    return LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui")
end

local playerGui = GetSafeGui()

local function Create(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            pcall(function() inst[k] = v end)
        end
    end
    if parent then inst.Parent = parent end
    return inst
end

local function AddCorner(inst, radius)
    return Create("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, inst)
end

local function AddStroke(inst, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Colors.STROKE,
        Thickness = thickness or 1,
        Transparency = transparency or 0
    }, inst)
end

local function AddGradient(inst, rotation, colors)
    local grad = Create("UIGradient", { Rotation = rotation or 0 }, inst)
    if colors then
        local keypoints = {}
        for i, c in ipairs(colors) do
            table.insert(keypoints, ColorSequenceKeypoint.new((i-1)/(#colors-1), c))
        end
        grad.Color = ColorSequence.new(keypoints)
    end
    return grad
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

-- ═══════════════════════════════════════════════════════════════
-- CONFIG SYSTEM
-- ═══════════════════════════════════════════════════════════════
local CONFIG_PATH = "unknown_hub_config.json"
local FIRST_RUN_PATH = "unknown_hub_firstrun.json"

local config = {}
local settings = {}

local function FileExists(path)
    return (isfile and pcall(isfile, path) and isfile(path)) or false
end

local function ReadFile(path)
    if not isfile then return nil end
    local ok, data = pcall(readfile, path)
    return ok and data or nil
end

local function WriteFile(path, text)
    if not writefile then return false end
    return pcall(writefile, path, text)
end

local function LoadConfig()
    if FileExists(CONFIG_PATH) then
        local raw = ReadFile(CONFIG_PATH)
        if raw then
            local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok and type(decoded) == "table" then
                config = decoded
            end
        end
    end
    -- Load settings
    if config.settings and type(config.settings) == "table" then
        settings = config.settings
    end
end

local function SaveConfig()
    config.settings = settings
    local ok, json = pcall(function() return HttpService:JSONEncode(config) end)
    if ok then WriteFile(CONFIG_PATH, json) end
end

local function CheckFirstRun()
    if FileExists(FIRST_RUN_PATH) then
        local raw = ReadFile(FIRST_RUN_PATH)
        if raw then
            local ok, data = pcall(function() return HttpService:JSONDecode(raw) end)
            if ok and type(data) == "table" and data.done == true then
                return true
            end
        end
    end
    return false
end

local function MarkFirstRun()
    pcall(function()
        local json = HttpService:JSONEncode({ done = true })
        WriteFile(FIRST_RUN_PATH, json)
    end)
end

LoadConfig()

-- ═══════════════════════════════════════════════════════════════
-- EXECUTOR CHECK
-- ═══════════════════════════════════════════════════════════════
local function GetExecutorName()
    if identifyexecutor then return tostring(identifyexecutor()) end
    if getexecutorname then return tostring(getexecutorname()) end
    return "Unknown"
end

local executorName = GetExecutorName()

-- ═══════════════════════════════════════════════════════════════
-- LOADING SCREEN
-- ═══════════════════════════════════════════════════════════════
local LoadingScreen = {}
LoadingScreen.__index = LoadingScreen

function LoadingScreen.new()
    local self = setmetatable({}, LoadingScreen)
    
    self.gui = Create("ScreenGui", {
        Name = "UnknownHubLoading",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999
    }, playerGui)
    
    -- Main overlay
    self.overlay = Create("Frame", {
        Name = "Overlay",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Colors.BG_DARK,
        BorderSizePixel = 0
    }, self.gui)
    
    -- Animated background particles
    self.particles = {}
    for i = 1, 30 do
        local particle = Create("Frame", {
            Size = UDim2.fromOffset(math.random(2, 6), math.random(2, 6)),
            BackgroundColor3 = Colors.ACCENT,
            BackgroundTransparency = math.random(60, 90) / 100,
            Position = UDim2.fromScale(math.random(100)/100, math.random(100)/100),
            Rotation = math.random(0, 360)
        }, self.overlay)
        AddCorner(particle, 2)
        table.insert(self.particles, {
            instance = particle,
            speedX = math.random(-100, 100) / 1000,
            speedY = math.random(-100, 100) / 1000,
            rotSpeed = math.random(-200, 200) / 100
        })
    end
    
    -- Center content
    self.content = Create("Frame", {
        Size = UDim2.fromOffset(400, 280),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1
    }, self.overlay)
    
    -- Logo circle
    self.logoCircle = Create("Frame", {
        Size = UDim2.fromOffset(100, 100),
        Position = UDim2.new(0.5, 0, 0.1, 0),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = Colors.BG_CARD,
        BorderSizePixel = 0
    }, self.content)
    AddCorner(self.logoCircle, 50)
    AddStroke(self.logoCircle, Colors.ACCENT, 2, 0.3)
    
    -- Logo text
    self.logoText = Create("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "UH",
        Font = Enum.Font.GothamBlack,
        TextSize = 36,
        TextColor3 = Colors.ACCENT
    }, self.logoCircle)
    
    -- Title
    self.title = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 40),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Text = "UNKNOWN HUB",
        Font = Enum.Font.GothamBlack,
        TextSize = 32,
        TextColor3 = Colors.TEXT_PRIMARY
    }, self.content)
    AddGradient(self.title, 0, {Colors.ACCENT, Colors.TEXT_PRIMARY, Colors.ACCENT})
    
    -- Subtitle
    self.subtitle = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0.64, 0),
        BackgroundTransparency = 1,
        Text = "Loading modules...",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Colors.TEXT_SECONDARY
    }, self.content)
    
    -- Progress bar background
    self.progressBg = Create("Frame", {
        Size = UDim2.new(0.8, 0, 0, 6),
        Position = UDim2.new(0.1, 0, 0.78, 0),
        BackgroundColor3 = Colors.BG_CARD_2,
        BorderSizePixel = 0
    }, self.content)
    AddCorner(self.progressBg, 3)
    
    -- Progress bar fill
    self.progressFill = Create("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Colors.ACCENT,
        BorderSizePixel = 0
    }, self.progressBg)
    AddCorner(self.progressFill, 3)
    
    -- Status text
    self.statusText = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0.88, 0),
        BackgroundTransparency = 1,
        Text = "Initializing...",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Colors.TEXT_MUTED
    }, self.content)
    
    -- Version
    self.versionText = Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0.95, 0),
        BackgroundTransparency = 1,
        Text = "v1.0.0 | " .. executorName,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Colors.TEXT_MUTED
    }, self.content)
    
    self.progress = 0
    self.isComplete = false
    self.callbacks = {}
    
    -- Animation loop
    self.connection = RunService.Heartbeat:Connect(function(dt)
        self:Update(dt)
    end)
    
    return self
end

function LoadingScreen:SetProgress(value, status)
    self.progress = math.clamp(value, 0, 1)
    if status then
        self.statusText.Text = status
    end
end

function LoadingScreen:AddProgress(amount, status)
    self:SetProgress(self.progress + amount, status)
end

function LoadingScreen:OnComplete(callback)
    table.insert(self.callbacks, callback)
end

function LoadingScreen:Complete()
    self.isComplete = true
    self:SetProgress(1, "Complete!")
    self.subtitle.Text = "Ready"
    
    task.delay(0.5, function()
        -- Fade out
        local tween = TweenService:Create(self.overlay, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            BackgroundTransparency = 1
        })
        
        for _, particle in ipairs(self.particles) do
            TweenService:Create(particle.instance, TweenInfo.new(0.6), {
                BackgroundTransparency = 1
            }):Play()
        end
        
        TweenService:Create(self.content, TweenInfo.new(0.6), {
            GroupTransparency = 1
        }):Play()
        
        tween:Play()
        tween.Completed:Connect(function()
            if self.connection then
                self.connection:Disconnect()
            end
            self.gui:Destroy()
            
            for _, cb in ipairs(self.callbacks) do
                pcall(cb)
            end
        end)
    end)
end

function LoadingScreen:ShowButtonLoading(duration)
    -- Mini loading overlay for button clicks
    local overlay = Create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Colors.SHADOW,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 100
    }, self.gui)
    
    local spinner = Create("Frame", {
        Size = UDim2.fromOffset(50, 50),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 101
    }, overlay)
    
    -- Create spinner ring
    for i = 0, 7 do
        local dot = Create("Frame", {
            Size = UDim2.fromOffset(8, 8),
            Position = UDim2.fromScale(0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0),
            BackgroundColor3 = Colors.ACCENT,
            BackgroundTransparency = (i / 8),
            BorderSizePixel = 0,
            ZIndex = 102
        }, spinner)
        AddCorner(dot, 4)
        dot.Rotation = (i * 45)
    end
    
    spawn(function()
        local startTime = tick()
        repeat
            local elapsed = tick() - startTime
            spinner.Rotation = elapsed * 360
            task.wait(0.016)
        until tick() - startTime >= duration
        
        TweenService:Create(overlay, TweenInfo.new(0.3), {
            BackgroundTransparency = 1
        }):Play()
        
        TweenService:Create(spinner, TweenInfo.new(0.3), {
            GroupTransparency = 1
        }):Play()
        
        task.delay(0.3, function()
            overlay:Destroy()
        end)
    end)
end

function LoadingScreen:Update(dt)
    -- Update particles
    for _, particle in ipairs(self.particles) do
        local pos = particle.instance.Position
        particle.instance.Position = UDim2.new(
            math.clamp(pos.X.Scale + particle.speedX * dt, 0, 1),
            0,
            math.clamp(pos.Y.Scale + particle.speedY * dt, 0, 1),
            0
        )
        particle.instance.Rotation = particle.instance.Rotation + particle.rotSpeed * dt
        
        -- Wrap around
        if pos.X.Scale < -0.05 then particle.instance.Position = UDim2.new(1.05, 0, pos.Y.Scale, 0) end
        if pos.X.Scale > 1.05 then particle.instance.Position = UDim2.new(-0.05, 0, pos.Y.Scale, 0) end
        if pos.Y.Scale < -0.05 then particle.instance.Position = UDim2.new(pos.X.Scale, 0, 1.05, 0) end
        if pos.Y.Scale > 1.05 then particle.instance.Position = UDim2.new(pos.X.Scale, 0, -0.05, 0) end
    end
    
    -- Animate progress bar
    local targetSize = UDim2.fromScale(self.progress, 1)
    self.progressFill.Size = UDim2.new(
        Lerp(self.progressFill.Size.X.Scale, targetSize.X.Scale, 0.15),
        0,
        1,
        0
    )
    
    -- Pulse logo when complete
    if self.isComplete then
        local pulse = math.sin(tick() * 4) * 0.1 + 1
        self.logoCircle.Size = UDim2.fromOffset(100 * pulse, 100 * pulse)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN HUB GUI
-- ═══════════════════════════════════════════════════════════════
local Hub = {}
Hub.__index = Hub

function Hub.new()
    local self = setmetatable({}, Hub)
    self.isOpen = false
    self.tabs = {}
    self.currentTab = nil
    self.toggles = {}
    self.sliders = {}
    self.buttons = {}
    
    self:BuildGui()
    return self
end

function Hub:BuildGui()
    -- Main GUI
    self.gui = Create("ScreenGui", {
        Name = "UnknownHub",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Enabled = false
    }, playerGui)
    
    -- Background blur
    self.blur = Create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Colors.SHADOW,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0
    }, self.gui)
    
    -- Main container
    self.main = Create("Frame", {
        Size = UDim2.fromOffset(520, 420),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.BG_DARK,
        BorderSizePixel = 0
    }, self.gui)
    AddCorner(self.main, 16)
    AddStroke(self.main, Colors.STROKE, 1, 0.3)
    
    -- Shadow effect
    local shadow = Create("ImageLabel", {
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Colors.SHADOW,
        ImageTransparency = 0.3,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    }, self.main)
    shadow.ZIndex = -1
    
    -- Title bar
    self.titleBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Colors.BG_CARD,
        BorderSizePixel = 0
    }, self.main)
    AddCorner(self.titleBar, 16)
    
    -- Fix bottom corners of title bar
    local titleFix = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 1, -16),
        BackgroundColor3 = Colors.BG_CARD,
        BorderSizePixel = 0
    }, self.titleBar)
    
    -- Title gradient bar
    local titleGrad = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Colors.ACCENT,
        BorderSizePixel = 0
    }, self.titleBar)
    AddGradient(titleGrad, 0, {Colors.ACCENT, Colors.ACCENT_DARK, Colors.ACCENT})
    
    -- Title text
    self.titleText = Create("TextLabel", {
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = "UNKNOWN HUB",
        Font = Enum.Font.GothamBlack,
        TextSize = 18,
        TextColor3 = Colors.TEXT_PRIMARY,
        TextXAlignment = Enum.TextXAlignment.Left
    }, self.titleBar)
    
    -- Close button
    self.closeBtn = Create("TextButton", {
        Size = UDim2.fromOffset(36, 36),
        Position = UDim2.new(1, -44, 0.5, -18),
        BackgroundColor3 = Colors.BG_CARD_2,
        BorderSizePixel = 0,
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Colors.TEXT_SECONDARY,
        AutoButtonColor = true
    }, self.titleBar)
    AddCorner(self.closeBtn, 8)
    
    self.closeBtn.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Minimize button
    self.minBtn = Create("TextButton", {
        Size = UDim2.fromOffset(36, 36),
        Position = UDim2.new(1, -84, 0.5, -18),
        BackgroundColor3 = Colors.BG_CARD_2,
        BorderSizePixel = 0,
        Text = "—",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Colors.TEXT_SECONDARY,
        AutoButtonColor = true
    }, self.titleBar)
    AddCorner(self.minBtn, 8)
    
    -- Tab bar (left side)
    self.tabBar = Create("Frame", {
        Size = UDim2.new(0, 130, 1, -56),
        Position = UDim2.new(0, 8, 0, 52),
        BackgroundColor3 = Colors.BG_CARD,
        BorderSizePixel = 0
    }, self.main)
    AddCorner(self.tabBar, 12)
    
    -- Tab list
    self.tabList = Create("ScrollingFrame", {
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Colors.ACCENT,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    }, self.tabBar)
    
    -- Content area (right side)
    self.contentArea = Create("Frame", {
        Size = UDim2.new(1, -150, 1, -56),
        Position = UDim2.new(0, 146, 0, 52),
        BackgroundTransparency = 1,
        BorderSizePixel = 0
    }, self.main)
    
    -- Make draggable
    self:MakeDraggable(self.titleBar, self.main)
    
    -- Keybind
    self.bindKey = Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == self.bindKey then
            self:Toggle()
        end
    end)
end

function Hub:MakeDraggable(handle, frame)
    local dragging = false
    local dragStart, startPos
    
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
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Hub:AddTab(name, icon)
    local tab = {
        name = name,
        icon = icon or "○",
        content = nil,
        button = nil
    }
    
    -- Tab button
    local btn = Create("TextButton", {
        Size = UDim2.new(1, -8, 0, 38),
        BackgroundColor3 = Colors.BG_CARD_2,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = "  " .. (icon or "") .. "  " .. name,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Colors.TEXT_SECONDARY,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false
    }, self.tabList)
    AddCorner(btn, 8)
    
    -- Tab content
    local content = Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Colors.ACCENT,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false
    }, self.contentArea)
    
    -- Content layout
    local layout = Create("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    }, content)
    
    Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4)
    }, content)
    
    tab.content = content
    tab.button = btn
    
    btn.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    btn.MouseEnter:Connect(function()
        if self.currentTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundTransparency = 0.5
            }):Play()
        end
    end)
    
    btn.MouseLeave:Connect(function()
        if self.currentTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundTransparency = 0
            }):Play()
        end
    end)
    
    self.tabs[name] = tab
    return tab
end

function Hub:SelectTab(name)
    -- Hide all tabs
    for tabName, tab in pairs(self.tabs) do
        tab.content.Visible = false
        TweenService:Create(tab.button, TweenInfo.new(0.2), {
            BackgroundColor3 = Colors.BG_CARD_2,
            TextColor3 = Colors.TEXT_SECONDARY
        }):Play()
    end
    
    -- Show selected tab
    local tab = self.tabs[name]
    if tab then
        tab.content.Visible = true
        TweenService:Create(tab.button, TweenInfo.new(0.2), {
            BackgroundColor3 = Colors.ACCENT_DARK,
            TextColor3 = Colors.TEXT_PRIMARY
        }):Play()
        self.currentTab = name
    end
end

function Hub:AddToggle(tabName, name, default, callback)
    local tab = self.tabs[tabName]
    if not tab then return nil end
    
    local isOn = default or (settings[tabName .. "_" .. name] ~= nil and settings[tabName .. "_" .. name]) or false
    settings[tabName .. "_" .. name] = isOn
    
    local container = Create("Frame", {
        Size = UDim2.new(1, -8, 0, 44),
        BackgroundColor3 = Colors.BG_CARD,
        BorderSizePixel = 0
    }, tab.content)
    AddCorner(container, 10)
    
    local label = Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Colors.TEXT_PRIMARY,
        TextXAlignment = Enum.TextXAlignment.Left
    }, container)
    
    -- Toggle background
    local toggleBg = Create("Frame", {
        Size = UDim2.fromOffset(44, 24),
        Position = UDim2.new(1, -56, 0.5, -12),
        BackgroundColor3 = isOn and Colors.TOGGLE_ON or Colors.TOGGLE_OFF,
        BorderSizePixel = 0
    }, container)
    AddCorner(toggleBg, 12)
    
    -- Toggle circle
    local toggleCircle = Create("Frame", {
        Size = UDim2.fromOffset(18, 18),
        Position = isOn and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
        BackgroundColor3 = Colors.TEXT_PRIMARY,
        BorderSizePixel = 0
    }, toggleBg)
    AddCorner(toggleCircle, 9)
    
    local toggleData = {
        isOn = isOn,
        container = container,
        bg = toggleBg,
        circle = toggleCircle,
        callback = callback
    }
    
    local function setToggle(state)
        toggleData.isOn = state
        settings[tabName .. "_" .. name] = state
        SaveConfig()
        
        TweenService:Create(toggleBg, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            BackgroundColor3 = state and Colors.TOGGLE_ON or Colors.TOGGLE_OFF
        }):Play()
        
        TweenService:Create(toggleCircle, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
            Position = state and UDim2.new(1, -22, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
        
        if callback then
            pcall(callback, state)
        end
    end
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            setToggle(not toggleData.isOn)
        end
    end)
    
    self.toggles[tabName .. "_" .. name] = toggleData
    return toggleData
end

function Hub:AddSlider(tabName, name, min, max, default, callback)
    local tab = self.tabs[tabName]
    if not tab then return nil end
    
    local value = default or (settings[tabName .. "_" .. name] or min)
    settings[tabName .. "_" .. name] = value
    
    local container = Create("Frame", {
        Size = UDim2.new(1, -8, 0, 60),
        BackgroundColor3 = Colors.BG_CARD,
        BorderSizePixel = 0
    }, tab.content)
    AddCorner(container, 10)
    
    local label = Create("TextLabel", {
        Size = UDim2.new(1, -100, 0, 24),
        Position = UDim2.new(0, 14, 0, 8),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Colors.TEXT_PRIMARY,
        TextXAlignment = Enum.TextXAlignment.Left
    }, container)
    
    local valueLabel = Create("TextLabel", {
        Size = UDim2.new(0, 80, 0, 24),
        Position = UDim2.new(1, -90, 0, 8),
        BackgroundTransparency = 1,
        Text = tostring(math.floor(value)),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Colors.ACCENT,
        TextXAlignment = Enum.TextXAlignment.Right
    }, container)
    
    -- Slider background
    local sliderBg = Create("Frame", {
        Size = UDim2.new(1, -28, 0, 8),
        Position = UDim2.new(0, 14, 0, 38),
        BackgroundColor3 = Colors.BG_CARD_2,
        BorderSizePixel = 0
    }, container)
    AddCorner(sliderBg, 4)
    
    -- Slider fill
    local percent = (value - min) / (max - min)
    local sliderFill = Create("Frame", {
        Size = UDim2.fromScale(percent, 1),
        BackgroundColor3 = Colors.ACCENT,
        BorderSizePixel = 0
    }, sliderBg)
    AddCorner(sliderFill, 4)
    
    -- Slider button
    local sliderBtn = Create("Frame", {
        Size = UDim2.fromOffset(16, 16),
        Position = UDim2.fromScale(percent, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.TEXT_PRIMARY,
        BorderSizePixel = 0
    }, sliderBg)
    AddCorner(sliderBtn, 8)
    
    local sliderData = {
        min = min,
        max = max,
        value = value,
        container = container,
        fill = sliderFill,
        btn = sliderBtn,
        valueLabel = valueLabel,
        callback = callback
    }
    
    local function updateSlider(newValue)
        sliderData.value = math.clamp(newValue, min, max)
        settings[tabName .. "_" .. name] = sliderData.value
        SaveConfig()
        
        local newPercent = (sliderData.value - min) / (max - min)
        sliderFill.Size = UDim2.fromScale(newPercent, 1)
        sliderBtn.Position = UDim2.fromScale(newPercent, 0.5)
        valueLabel.Text = tostring(math.floor(sliderData.value))
        
        if callback then
            pcall(callback, sliderData.value)
        end
    end
    
    local dragging = false
    
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    sliderBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            local relPos = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
            updateSlider(min + relPos * (max - min))
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relPos = (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
            updateSlider(min + relPos * (max - min))
        end
    end)
    
    self.sliders[tabName .. "_" .. name] = sliderData
    return sliderData
end

function Hub:AddButton(tabName, name, callback, showLoading)
    local tab = self.tabs[tabName]
    if not tab then return nil end
    
    local container = Create("TextButton", {
        Size = UDim2.new(1, -8, 0, 42),
        BackgroundColor3 = Colors.BG_CARD,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false
    }, tab.content)
    AddCorner(container, 10)
    AddStroke(container, Colors.STROKE, 1, 0.5)
    
    local label = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Colors.TEXT_PRIMARY,
        AutoButtonColor = false
    }, container)
    
    -- Arrow icon
    local arrow = Create("TextLabel", {
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(1, -30, 0, 0),
        BackgroundTransparency = 1,
        Text = "→",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Colors.ACCENT,
        AutoButtonColor = false
    }, container)
    
    container.MouseEnter:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.2), {
            BackgroundColor3 = Colors.BG_HOVER
        }):Play()
        TweenService:Create(arrow, TweenInfo.new(0.2), {
            Position = UDim2.new(1, -26, 0, 0)
        }):Play()
    end)
    
    container.MouseLeave:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.2), {
            BackgroundColor3 = Colors.BG_CARD
        }):Play()
        TweenService:Create(arrow, TweenInfo.new(0.2), {
            Position = UDim2.new(1, -30, 0, 0)
        }):Play()
    end)
    
    container.MouseButton1Click:Connect(function()
        if showLoading ~= false then
            -- Show mini loading effect
            local originalText = label.Text
            label.Text = "Loading..."
            label.TextColor3 = Colors.ACCENT
            
            spawn(function()
                task.wait(0.8)
                label.Text = originalText
                label.TextColor3 = Colors.TEXT_PRIMARY
                if callback then
                    pcall(callback)
                end
            end)
        else
            if callback then
                pcall(callback)
            end
        end
    end)
    
    return container
end

function Hub:AddLabel(tabName, text)
    local tab = self.tabs[tabName]
    if not tab then return nil end
    
    local label = Create("TextLabel", {
        Size = UDim2.new(1, -8, 0, 24),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = Colors.TEXT_MUTED,
        TextXAlignment = Enum.TextXAlignment.Left
    }, tab.content)
    
    return label
end

function Hub:AddSeparator(tabName)
    local tab = self.tabs[tabName]
    if not tab then return nil end
    
    local sep = Create("Frame", {
        Size = UDim2.new(1, -16, 0, 1),
        BackgroundColor3 = Colors.STROKE,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0
    }, tab.content)
    
    return sep
end

function Hub:Toggle()
    self.isOpen = not self.isOpen
    self.gui.Enabled = self.isOpen
    
    if self.isOpen then
        -- Animate in
        self.main.Size = UDim2.fromOffset(0, 0)
        self.main.BackgroundTransparency = 1
        self.blur.BackgroundTransparency = 1
        
        TweenService:Create(self.blur, TweenInfo.new(0.3), {
            BackgroundTransparency = 0.6
        }):Play()
        
        TweenService:Create(self.main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(520, 420),
            BackgroundTransparency = 0
        }):Play()
    end
end

-- ═══════════════════════════════════════════════════════════════
-- DISCORD POPUP (Modified for Unknown Hub)
-- ═══════════════════════════════════════════════════════════════
local function ShowDiscordPopup()
    if config.__DiscordShown then return end
    
    local popup = Create("ScreenGui", {
        Name = "UnknownHubDiscord",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, playerGui)
    
    -- Overlay
    local overlay = Create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Colors.SHADOW,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0
    }, popup)
    
    -- Card
    local card = Create("Frame", {
        Size = UDim2.fromOffset(380, 240),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Colors.BG_CARD,
        BorderSizePixel = 0
    }, popup)
    AddCorner(card, 20)
    AddStroke(card, Colors.ACCENT, 2, 0.3)
    
    -- Glow effect
    local glow = Create("UIStroke", {
        Thickness = 12,
        Transparency = 0.9,
        Color = Colors.ACCENT_GLOW,
        LineJoinMode = Enum.LineJoinMode.Round
    }, card)
    
    -- Title bar
    local topBar = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = Colors.BG_CARD_2,
        BorderSizePixel = 0
    }, card)
    AddCorner(topBar, 20)
    local topFix = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, -20),
        BackgroundColor3 = Colors.BG_CARD_2,
        BorderSizePixel = 0
    }, topBar)
    
    local title = Create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        BackgroundTransparency = 1,
        Text = "UNKNOWN HUB",
        Font = Enum.Font.GothamBlack,
        TextSize = 18,
        TextColor3 = Colors.ACCENT
    }, topBar)
    AddGradient(title, 0, {Colors.ACCENT, Colors.TEXT_PRIMARY})
    
    -- Close button
    local closeBtn = Create("TextButton", {
        Size = UDim2.fromOffset(32, 32),
        Position = UDim2.new(1, -40, 0.5, -16),
        BackgroundColor3 = Colors.BG_CARD,
        BorderSizePixel = 0,
        Text = "✕",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Colors.TEXT_SECONDARY,
        AutoButtonColor = true
    }, topBar)
    AddCorner(closeBtn, 8)
    AddStroke(closeBtn, Colors.STROKE, 1, 0.3)
    
    -- Body text
    local body = Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 80),
        Position = UDim2.new(0, 20, 0, 56),
        BackgroundTransparency = 1,
        Text = "Join our Discord for:\n• Secret features & updates\n• Giveaways & rewards\n• Community support",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = Colors.TEXT_SECONDARY,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextWrapped = true
    }, card)
    
    -- Copy button
    local copyBtn = Create("TextButton", {
        Size = UDim2.new(1, -40, 0, 42),
        Position = UDim2.new(0, 20, 1, -72),
        BackgroundColor3 = Colors.ACCENT,
        BorderSizePixel = 0,
        Text = "Copy Discord Invite",
        Font = Enum.Font.GothamBlack,
        TextSize = 15,
        TextColor3 = Colors.BG_DARK,
        AutoButtonColor = true
    }, card)
    AddCorner(copyBtn, 12)
    
    -- Link text
    local linkText = Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 20),
        Position = UDim2.new(0, 20, 1, -26),
        BackgroundTransparency = 1,
        Text = "discord.gg/unknown-hub",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Colors.TEXT_MUTED
    }, card)
    
    -- Toast
    local toast = Create("TextLabel", {
        Size = UDim2.new(1, -40, 0, 20),
        Position = UDim2.new(0, 20, 1, -50),
        BackgroundTransparency = 1,
        Text = "",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Colors.SUCCESS,
        TextTransparency = 1
    }, card)
    
    local DISCORD_LINK = "https://discord.gg/unknown-hub"
    
    local function copyClipboard(text)
        if setclipboard and pcall(setclipboard, text) then return true end
        if toclipboard and pcall(toclipboard, text) then return true end
        if syn and syn.write_clipboard and pcall(syn.write_clipboard, text) then return true end
        return false
    end
    
    copyBtn.MouseButton1Click:Connect(function()
        if copyClipboard(DISCORD_LINK) then
            toast.Text = "✓ Copied to clipboard!"
            toast.TextTransparency = 0
            task.delay(2, function()
                TweenService:Create(toast, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
            end)
        end
    end)
    
    local function close()
        config.__DiscordShown = true
        SaveConfig()
        TweenService:Create(overlay, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(card, TweenInfo.new(0.3), {
            Size = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1
        }):Play()
        task.delay(0.35, function()
            popup:Destroy()
        end)
    end
    
    closeBtn.MouseButton1Click:Connect(close)
    overlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            close()
        end
    end)
    
    -- Animate in
    card.Size = UDim2.fromOffset(0, 0)
    TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.fromOffset(380, 240)
    }):Play()
end

-- ═══════════════════════════════════════════════════════════════
-- FIRST RUN HANDLER
-- ═══════════════════════════════════════════════════════════════
local function HandleFirstRun()
    local needFirstRun = not CheckFirstRun()
    if needFirstRun then
        MarkFirstRun()
        -- You can add first-run specific logic here
        -- For example, loading additional scripts
        task.delay(2, function()
            pcall(function()
                -- Add your first-run remote script here
                -- loadstring(game:HttpGet("YOUR_FIRST_RUN_URL"))()
            end)
        end)
    end
end

-- ═══════════════════════════════════════════════════════════════
-- INITIALIZE EVERYTHING
-- ═══════════════════════════════════════════════════════════════
local loadingScreen = LoadingScreen.new()

-- Simulate loading progress
task.spawn(function()
    loadingScreen:SetProgress(0.05, "Checking executor...")
    task.wait(0.3)
    
    loadingScreen:AddProgress(0.1, "Executor: " .. executorName)
    task.wait(0.2)
    
    loadingScreen:AddProgress(0.15, "Loading configuration...")
    task.wait(0.25)
    
    loadingScreen:AddProgress(0.2, "Initializing modules...")
    task.wait(0.2)
    
    loadingScreen:AddProgress(0.15, "Loading UI components...")
    task.wait(0.2)
    
    loadingScreen:AddProgress(0.15, "Setting up features...")
    task.wait(0.2)
    
    loadingScreen:AddProgress(0.1, "Checking for updates...")
    task.wait(0.15)
    
    loadingScreen:AddProgress(0.05, "Finalizing...")
    task.wait(0.1)
    
    loadingScreen:Complete()
end)

loadingScreen:OnComplete(function()
    -- Handle first run
    HandleFirstRun()
    
    -- Create the hub
    local hub = Hub.new()
    
    -- ═══════════════════════════════════════════════════════════
    -- ADD TABS AND FEATURES
    -- ═══════════════════════════════════════════════════════════
    
    -- MAIN TAB
    local mainTab = hub:AddTab("Main", "🏠")
    hub:AddLabel(mainTab.name, "COMBAT")
    hub:AddToggle(mainTab.name, "Melee Aimbot", false, function(state)
        print("Melee Aimbot:", state)
    end)
    hub:AddToggle(mainTab.name, "Auto Steal Nearest", false, function(state)
        print("Auto Steal Nearest:", state)
    end)
    hub:AddToggle(mainTab.name, "Kill Aura", false, function(state)
        print("Kill Aura:", state)
    end)
    hub:AddSeparator(mainTab.name)
    hub:AddLabel(mainTab.name, "MOVEMENT")
    hub:AddToggle(mainTab.name, "Speed Hack", false, function(state)
        print("Speed Hack:", state)
    end)
    hub:AddSlider(mainTab.name, "Speed Value", 16, 500, 100, function(value)
        print("Speed Value:", value)
    end)
    hub:AddToggle(mainTab.name, "Infinite Jump", false, function(state)
        print("Infinite Jump:", state)
    end)
    hub:AddToggle(mainTab.name, "No Clip", false, function(state)
        print("No Clip:", state)
    end)
    hub:AddSeparator(mainTab.name)
    hub:AddLabel(mainTab.name, "PLAYER")
    hub:AddToggle(mainTab.name, "God Mode", false, function(state)
        print("God Mode:", state)
    end)
    hub:AddToggle(mainTab.name, "Invisible", false, function(state)
        print("Invisible:", state)
    end)
    hub:AddButton(mainTab.name, "Respawn", function()
        print("Respawning...")
    end)
    
    -- FARM TAB
    local farmTab = hub:AddTab("Farm", "🌾")
    hub:AddToggle(farmTab.name, "Auto Farm", false, function(state)
        print("Auto Farm:", state)
    end)
    hub:AddToggle(farmTab.name, "Auto Collect", false, function(state)
        print("Auto Collect:", state)
    end)
    hub:AddToggle(farmTab.name, "Auto Sell", false, function(state)
        print("Auto Sell:", state)
    end)
    hub:AddSlider(farmTab.name, "Collect Radius", 10, 500, 100, function(value)
        print("Collect Radius:", value)
    end)
    hub:AddSeparator(farmTab.name)
    hub:AddToggle(farmTab.name, "Cash Multiplier", false, function(state)
        print("Cash Multiplier:", state)
    end)
    hub:AddSlider(farmTab.name, "Multiplier Value", 1, 100, 2, function(value)
        print("Multiplier Value:", value)
    end)
    hub:AddToggle(farmTab.name, "Auto Quest", false, function(state)
        print("Auto Quest:", state)
    end)
    hub:AddButton(farmTab.name, "Teleport to Collect Zone", function()
        print("Teleporting...")
    end)
    
    -- SHOP TAB
    local shopTab = hub:AddTab("Shop", "🛒")
    hub:AddButton(shopTab.name, "Buy All Upgrades", function()
        print("Buying all upgrades...")
    end)
    hub:AddButton(shopTab.name, "Max All Stats", function()
        print("Maxing stats...")
    end)
    hub:AddToggle(shopTab.name, "Auto Buy Best", false, function(state)
        print("Auto Buy Best:", state)
    end)
    hub:AddSeparator(shopTab.name)
    hub:AddLabel(shopTab.name, "WEAPONS")
    hub:AddButton(shopTab.name, "Unlock All Weapons", function()
        print("Unlocking weapons...")
    end)
    hub:AddButton(shopTab.name, "Get Best Weapon", function()
        print("Getting best weapon...")
    end)
    hub:AddSeparator(shopTab.name)
    hub:AddLabel(shopTab.name, "ABILITIES")
    hub:AddButton(shopTab.name, "Unlock All Abilities", function()
        print("Unlocking abilities...")
    end)
    hub:AddButton(shopTab.name, "Max Abilities", function()
        print("Maxing abilities...")
    end)
    
    -- TELEPORT TAB
    local tpTab = hub:AddTab("Teleport", "⚡")
    hub:AddButton(tpTab.name, "Teleport to Spawn", function()
        print("Teleporting to spawn...")
    end)
    hub:AddButton(tpTab.name, "Teleport to Collect Zone", function()
        print("Teleporting to collect zone...")
    end)
    hub:AddButton(tpTab.name, "Teleport to Shop", function()
        print("Teleporting to shop...")
    end)
    hub:AddButton(tpTab.name, "Teleport to PvP Arena", function()
        print("Teleporting to PvP arena...")
    end)
    hub:AddSeparator(tpTab.name)
    hub:AddToggle(tpTab.name, "Teleport to Nearest Player", false, function(state)
        print("Teleport to Nearest Player:", state)
    end)
    hub:AddToggle(tpTab.name, "Teleport to Nearest Coin", false, function(state)
        print("Teleport to Nearest Coin:", state)
    end)
    hub:AddButton(tpTab.name, "Random Teleport", function()
        print("Random teleporting...")
    end)
    
    -- VISUALS TAB
    local visTab = hub:AddTab("Visuals", "👁")
    hub:AddToggle(visTab.name, "ESP Players", false, function(state)
        print("ESP Players:", state)
    end)
    hub:AddToggle(visTab.name, "ESP Items", false, function(state)
        print("ESP Items:", state)
    end)
    hub:AddToggle(visTab.name, "ESP Coins", false, function(state)
        print("ESP Coins:", state)
    end)
    hub:AddSeparator(visTab.name)
    hub:AddToggle(visTab.name, "Chams", false, function(state)
        print("Chams:", state)
    end)
    hub:AddToggle(visTab.name, "Tracers", false, function(state)
        print("Tracers:", state)
    end)
    hub:AddSlider(visTab.name, "ESP Distance", 50, 5000, 500, function(value)
        print("ESP Distance:", value)
    end)
    hub:AddSeparator(visTab.name)
    hub:AddLabel(visTab.name, "MISC VISUALS")
    hub:AddToggle(visTab.name, "Full Bright", false, function(state)
        print("Full Bright:", state)
    end)
    hub:AddToggle(visTab.name, "No Fog", false, function(state)
        print("No Fog:", state)
    end)
    
    -- MISC TAB
    local miscTab = hub:AddTab("Misc", "⚙")
    hub:AddButton(miscTab.name, "Anti-AFK", function()
        print("Anti-AFK enabled")
    end)
    hub:AddToggle(miscTab.name, "Auto Rejoin", false, function(state)
        print("Auto Rejoin:", state)
    end)
    hub:AddSlider(miscTab.name, "Rejoin Delay", 5, 60, 10, function(value)
        print("Rejoin Delay:", value)
    end)
    hub:AddSeparator(miscTab.name)
    hub:AddButton(miscTab.name, "Server Hop", function()
        print("Server hopping...")
    end)
    hub:AddButton(miscTab.name, "Rejoin Server", function()
        print("Rejoining...")
    end)
    hub:AddSeparator(miscTab.name)
    hub:AddLabel(miscTab.name, "SETTINGS")
    hub:AddButton(miscTab.name, "Reset Config", function()
        settings = {}
        SaveConfig()
        print("Config reset!")
    end)
    hub:AddButton(miscTab.name, "Save Config", function()
        SaveConfig()
        print("Config saved!")
    end, false)
    hub:AddLabel(miscTab.name, "Keybind: RightShift")
    
    -- CREDITS TAB
    local credTab = hub:AddTab("Credits", "ℹ")
    hub:AddLabel(credTab.name, "UNKNOWN HUB")
    hub:AddLabel(credTab.name, "Version 1.0.0")
    hub:AddSeparator(credTab.name)
    hub:AddLabel(credTab.name, "Developer: Unknown")
    hub:AddLabel(credTab.name, "Executor: " .. executorName)
    hub:AddSeparator(credTab.name)
    hub:AddButton(credTab.name, "Join Discord", function()
        pcall(function()
            if setclipboard then setclipboard("https://discord.gg/unknown-hub") end
        end)
        print("Discord link copied!")
    end)
    hub:AddButton(credTab.name, "Copy Hub Link", function()
        pcall(function()
            if setclipboard then setclipboard("https://raw.githubusercontent.com/unknown/unknown-hub/main/loader.lua") end
        end)
        print("Hub link copied!")
    end)
    
    -- Select first tab
    hub:SelectTab("Main")
    
    -- Show discord popup after a delay
    task.delay(1, function()
        ShowDiscordPopup()
    end)
    
    -- Open hub
    task.delay(0.5, function()
        hub:Toggle()
    end)
    
    -- Store hub globally for external access
    _G.UnknownHub = hub
end)

-- ═══════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════
local Notifications = {}

function Notifications.Show(title, text, duration, color)
    duration = duration or 3
    color = color or Colors.ACCENT
    
    local notifGui = Create("ScreenGui", {
        Name = "UnknownHubNotif_" .. tick(),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }, playerGui)
    
    local container = Create("Frame", {
        Size = UDim2.new(0, 300, 0, 80),
        Position = UDim2.new(1, 320, 1, -100),
        BackgroundColor3 = Colors.BG_CARD,
        BorderSizePixel = 0
    }, notifGui)
    AddCorner(container, 12)
    AddStroke(container, color, 1, 0.5)
    
    -- Accent bar
    Create("Frame", {
        Size = UDim2.new(0, 4, 0.7, 0),
        Position = UDim2.new(0, 4, 0.15, 0),
        BackgroundColor3 = color,
        BorderSizePixel = 0
    }, container)
    AddCorner(container, 2)
    
    local titleLbl = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 28),
        Position = UDim2.new(0, 16, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Colors.TEXT_PRIMARY,
        TextXAlignment = Enum.TextXAlignment.Left
    }, container)
    
    local textLbl = Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 16, 0, 38),
        BackgroundTransparency = 1,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Colors.TEXT_SECONDARY,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    }, container)
    
    -- Progress bar
    local progress = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = color,
        BorderSizePixel = 0
    }, container)
    
    -- Animate in
    TweenService:Create(container, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -320, 1, -100)
    }):Play()
    
    -- Progress animation
    spawn(function()
        local startTime = tick()
        while tick() - startTime < duration do
            local elapsed = tick() - startTime
            local remaining = 1 - (elapsed / duration)
            progress.Size = UDim2.new(remaining, 0, 0, 3)
            task.wait(0.016)
        end
        
        -- Animate out
        TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 320, 1, -100),
            BackgroundTransparency = 1
        }):Play()
        
        task.delay(0.35, function()
            notifGui:Destroy()
        end)
    end)
end

-- Make notifications global
_G.UnknownHubNotify = Notifications.Show

print("[Unknown Hub] Loaded successfully!")
print("[Unknown Hub] Executor: " .. executorName)
print("[Unknown Hub] Keybind: RightShift")

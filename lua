-- Trade GUI Script by Claude
-- Freeze Trade & Auto Duel toggles

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")

-- // State
local freezeTrade = false
local autoDuel  = false
local dragging  = false
local dragStart, startPos

-- // Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name            = "TradeGUI"
ScreenGui.ResetOnSpawn    = false
ScreenGui.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent          = LocalPlayer.PlayerGui

-- // Main Frame
local Frame = Instance.new("Frame")
Frame.Name            = "MainFrame"
Frame.Size            = UDim2.new(0, 360, 0, 220)
Frame.Position        = UDim2.new(0.5, -180, 0.5, -110)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 46)
Frame.BorderSizePixel  = 0
Frame.Active           = true
Frame.Parent           = ScreenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent        = Frame

-- // Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size            = UDim2.new(1, 0, 0, 44)
TitleBar.BackgroundColor3 = Color3.fromRGB(49, 49, 83)
TitleBar.BorderSizePixel  = 0
TitleBar.Parent           = Frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent        = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text            = "Polos Trade Script"
TitleLabel.Size            = UDim2.new(1, -50, 1, 0)
TitleLabel.Position        = UDim2.new(0, 16, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3      = Color3.fromRGB(200, 180, 255)
TitleLabel.TextSize        = 20
TitleLabel.Font             = Enum.Font.GothamBold
TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
TitleLabel.Parent           = TitleBar

-- // Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text            = "X"
CloseBtn.Size            = UDim2.new(0, 32, 0, 32)
CloseBtn.Position        = UDim2.new(1, -40, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.TextColor3      = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize        = 16
CloseBtn.Font             = Enum.Font.GothamBold
CloseBtn.BorderSizePixel  = 0
CloseBtn.Parent           = TitleBar
local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(0, 6)
cc.Parent        = CloseBtn
CloseBtn.MouseButton1Click:Connect(function()
  ScreenGui:Destroy()
end)

-- // Helper: create a toggle row
local function createToggle(labelText, yPos, callback)
  local row = Instance.new("Frame")
  row.Size            = UDim2.new(1, -32, 0, 52)
  row.Position        = UDim2.new(0, 16, 0, yPos)
  row.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
  row.BorderSizePixel  = 0
  row.Parent           = Frame
  local rc = Instance.new("UICorner")
  rc.CornerRadius = UDim.new(0, 8)
  rc.Parent        = row

  local lbl = Instance.new("TextLabel")
  lbl.Text                 = labelText
  lbl.Size                 = UDim2.new(1, -80, 1, 0)
  lbl.Position             = UDim2.new(0, 14, 0, 0)
  lbl.BackgroundTransparency = 1
  lbl.TextColor3           = Color3.fromRGB(230, 230, 255)
  lbl.TextSize             = 18
  lbl.Font                  = Enum.Font.GothamSemibold
  lbl.TextXAlignment       = Enum.TextXAlignment.Left
  lbl.Parent                = row

  local togBtn = Instance.new("TextButton")
  togBtn.Size            = UDim2.new(0, 56, 0, 28)
  togBtn.Position        = UDim2.new(1, -66, 0.5, -14)
  togBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
  togBtn.Text             = "OFF"
  togBtn.TextColor3       = Color3.fromRGB(180, 180, 180)
  togBtn.TextSize         = 14
  togBtn.Font              = Enum.Font.GothamBold
  togBtn.BorderSizePixel  = 0
  togBtn.Parent            = row
  local tc = Instance.new("UICorner")
  tc.CornerRadius = UDim.new(0, 6)
  tc.Parent        = togBtn

  local state = false
  togBtn.MouseButton1Click:Connect(function()
    state = not state
    if state then
      togBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
      togBtn.Text             = "ON"
      togBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
    else
      togBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
      togBtn.Text             = "OFF"
      togBtn.TextColor3       = Color3.fromRGB(180, 180, 180)
    end
    callback(state)
  end)
end

-- // Create the two toggle rows
createToggle("Freeze Trade", 56, function(v)
  freezeTrade = v
  print("Freeze Trade:", v)
  -- add your freeze logic here
end)

createToggle("Auto Duel", 120, function(v)
  autoDuel = v
  print("Auto Duel:", v)
  -- add your auto duel logic here
end)

-- // Drag logic
TitleBar.InputBegan:Connect(function(input)
  if input.UserInputType == Enum.UserInputType.MouseButton1 then
    dragging  = true
    dragStart = input.Position
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

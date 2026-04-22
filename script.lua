-- Platinum Cheat MM2 | Part 1 - Advanced UI
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Создание главного UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlatinumCheat"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- ============ ИКОНКА МЕНЮ ============
local IconButton = Instance.new("ImageButton")
IconButton.Name = "IconButton"
IconButton.Size = UDim2.new(0, 50, 0, 50)
IconButton.Position = UDim2.new(0, 20, 0, 20)
IconButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
IconButton.BorderSizePixel = 0
IconButton.Image = "rbxasset://textures/Cursors/DragLockedCursor.png"
IconButton.Parent = ScreenGui

local UICornerIcon = Instance.new("UICorner")
UICornerIcon.CornerRadius = UDim.new(0, 8)
UICornerIcon.Parent = IconButton

local IconStroke = Instance.new("UIStroke")
IconStroke.Color = Color3.fromRGB(100, 200, 255)
IconStroke.Thickness = 2
IconStroke.Parent = IconButton

-- Анимация при наведении на иконку
IconButton.MouseEnter:Connect(function()
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goals = {Size = UDim2.new(0, 60, 0, 60)}
    local tween = game:GetService("TweenService"):Create(IconButton, tweenInfo, goals)
    tween:Play()
    IconButton.BackgroundColor3 = Color3.fromRGB(120, 220, 255)
end)

IconButton.MouseLeave:Connect(function()
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goals = {Size = UDim2.new(0, 50, 0, 50)}
    local tween = game:GetService("TweenService"):Create(IconButton, tweenInfo, goals)
    tween:Play()
    IconButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
end)

-- ============ ГЛАВНОЕ МЕНЮ ============
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 380, 0, 520)
MainFrame.Position = UDim2.new(0, -400, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local Shadow = Instance.new("UIStroke")
Shadow.Color = Color3.fromRGB(0, 0, 0)
Shadow.Thickness = 3
Shadow.Parent = MainFrame

-- Переменная состояния меню
local menuOpen = false

-- ============ ФУНКЦИЯ ОТКРЫТИЯ/ЗАКРЫТИЯ МЕНЮ ============
local function toggleMenu()
    menuOpen = not menuOpen
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    
    if menuOpen then
        local goals = {Position = UDim2.new(0, 20, 0.5, -260)}
        local tween = game:GetService("TweenService"):Create(MainFrame, tweenInfo, goals)
        tween:Play()
        IconButton.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    else
        local goals = {Position = UDim2.new(0, -400, 0.5, -260)}
        local tween = game:GetService("TweenService"):Create(MainFrame, tweenInfo, goals)
        tween:Play()
    end
end

IconButton.MouseButton1Click:Connect(toggleMenu)

-- ============ ХЕДЕР С КНОПКОЙ ЗАКРЫТИЯ ============
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 70)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

-- Название
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ PLATINUM"
TitleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
TitleLabel.TextSize = 22
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local Padding = Instance.new("UIPadding")
Padding.PaddingLeft = UDim.new(0, 15)
Padding.Parent = TitleLabel

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0, 15)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(toggleMenu)

CloseButton.MouseEnter:Connect(function()
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goals = {BackgroundColor3 = Color3.fromRGB(255, 100, 100)}
    local tween = game:GetService("TweenService"):Create(CloseButton, tweenInfo, goals)
    tween:Play()
end)

CloseButton.MouseLeave:Connect(function()
    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local goals = {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}
    local tween = game:GetService("TweenService"):Create(CloseButton, tweenInfo, goals)
    tween:Play()
end)

-- ============ ФУНКЦИЯ ДРАГА ============
local dragging = false
local dragStart = Vector2.new(0, 0)
local dragOffset = Vector2.new(0, 0)

Header.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = Mouse.Position
        dragOffset = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = Mouse.Position - dragStart
        MainFrame.Position = dragOffset + UDim2.new(0, delta.X, 0, delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- ============ КОНТЕНТ ФРЕЙМ ============
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Size = UDim2.new(1, 0, 0, 380)
ContentFrame.Position = UDim2.new(0, 0, 0, 70)
ContentFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

-- Скролл список
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Size = UDim2.new(1, -12, 1, -10)
ScrollingFrame.Position = UDim2.new(0, 6, 0, 5)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 600)
ScrollingFrame.Parent = ContentFrame

-- ============ ПРОФИЛЬ ============
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Name = "Profile"
ProfileFrame.Size = UDim2.new(1, 0, 0, 70)
ProfileFrame.Position = UDim2.new(0, 0, 1, -70)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
BorderSizePixel = 0
ProfileFrame.Parent = MainFrame

local ProfileCorner = Instance.new("UICorner")
ProfileCorner.CornerRadius = UDim.new(0, 12)
ProfileCorner.Parent = ProfileFrame

local ProfileLabel = Instance.new("TextLabel")
ProfileLabel.Size = UDim2.new(0.9, 0, 1, 0)
ProfileLabel.BackgroundTransparency = 1
ProfileLabel.Text = "👤 " .. LocalPlayer.Name
ProfileLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
ProfileLabel.TextSize = 13
ProfileLabel.Font = Enum.Font.Gotham
ProfileLabel.TextXAlignment = Enum.TextXAlignment.Left
ProfileLabel.Parent = ProfileFrame

local ProfilePadding = Instance.new("UIPadding")
ProfilePadding.PaddingLeft = UDim.new(0, 15)
ProfilePadding.PaddingTop = UDim.new(0, 10)
ProfilePadding.Parent = ProfileLabel

-- ============ ФУНКЦИЯ СОЗДАНИЯ ТОГГЛА ============
local Toggles = {}

local function CreateToggle(name, callback)
    local ToggleButton = Instance.new("Frame")
    ToggleButton.Name = name
    ToggleButton.Size = UDim2.new(1, -4, 0, 40)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Parent = ScrollingFrame
    
    local UICornerToggle = Instance.new("UICorner")
    UICornerToggle.CornerRadius = UDim.new(0, 8)
    UICornerToggle.Parent = ToggleButton
    
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Color3.fromRGB(50, 50, 70)
    ToggleStroke.Thickness = 1
    ToggleStroke.Parent = ToggleButton
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0.65, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = name
    TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TextLabel.TextSize = 13
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = ToggleButton
    
    local TextPadding = Instance.new("UIPadding")
    TextPadding.PaddingLeft = UDim.new(0, 12)
    TextPadding.PaddingTop = UDim.new(0, 8)
    TextPadding.Parent = TextLabel
    
    local ToggleBox = Instance.new("Frame")
    ToggleBox.Size = UDim2.new(0, 35, 0, 22)
    ToggleBox.Position = UDim2.new(0.7, 0, 0.5, -11)
    ToggleBox.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    ToggleBox.BorderSizePixel = 0
    ToggleBox.Parent = ToggleButton
    
    local BoxCorner = Instance.new("UICorner")
    BoxCorner.CornerRadius = UDim.new(0, 4)
    BoxCorner.Parent = ToggleBox
    
    local isEnabled = false
    Toggles[name] = isEnabled
    
    local ClickButton = Instance.new("TextButton")
    ClickButton.Size = UDim2.new(1, 0, 1, 0)
    ClickButton.BackgroundTransparency = 1
    ClickButton.Text = ""
    ClickButton.Parent = ToggleButton
    
    ClickButton.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        Toggles[name] = isEnabled
        
        -- Анимация изменения
        local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local newColor = isEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        local goals = {BackgroundColor3 = newColor}
        local tween = game:GetService("TweenService"):Create(ToggleBox, tweenInfo, goals)
        tween:Play()
        
        callback(isEnabled)
    end)
    
    ToggleButton.MouseEnter:Connect(function()
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local goals = {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}
        local tween = game:GetService("TweenService"):Create(ToggleButton, tweenInfo, goals)
        tween:Play()
    end)
    
    ToggleButton.MouseLeave:Connect(function()
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local goals = {BackgroundColor3 = Color3.fromRGB(25, 25, 38)}
        local tween = game:GetService("TweenService"):Create(ToggleButton, tweenInfo, goals)
        tween:Play()
    end)
    
    return ToggleButton
end

-- ============ ФУНКЦИЯ СОЗДАНИЯ КНОПКИ ============
local function CreateButton(name, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, -4, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    Button.BorderSizePixel = 0
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.TextSize = 13
    Button.Font = Enum.Font.Gotham
    Button.Parent = ScrollingFrame
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = Button
    
    local ButtonStroke = Instance.new("UIStroke")
    ButtonStroke.Color = Color3.fromRGB(50, 50, 70)
    ButtonStroke.Thickness = 1
    ButtonStroke.Parent = Button
    
    Button.MouseEnter:Connect(function()
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local goals = {BackgroundColor3 = Color3.fromRGB(100, 200, 255)}
        local tween = game:GetService("TweenService"):Create(Button, tweenInfo, goals)
        tween:Play()
    end)
    
    Button.MouseLeave:Connect(function()
        local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local goals = {BackgroundColor3 = Color3.fromRGB(25, 25, 38)}
        local tween = game:GetService("TweenService"):Create(Button, tweenInfo, goals)
        tween:Play()
    end)
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

-- ============ СОХРАНЯЕМ ССЫЛКИ ============
_G.PlatinumUI = {
    MainFrame = MainFrame,
    ScrollingFrame = ScrollingFrame,
    CreateToggle = CreateToggle,
    CreateButton = CreateButton,
    Toggles = Toggles,
    ScreenGui = ScreenGui
}

print("✓ Platinum Part 1 загружен | UI инициализирован")
-- Platinum Cheat MM2 | Part 2 & 3 - ESP Functions & MM2 Features
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Получаем UI элементы из части 1
local ScrollingFrame = _G.PlatinumUI.ScrollingFrame
local CreateToggle = _G.PlatinumUI.CreateToggle
local CreateButton = _G.PlatinumUI.CreateButton
local Toggles = _G.PlatinumUI.Toggles
local ScreenGui = _G.PlatinumUI.ScreenGui

-- ============ ESP СИСТЕМА ============
local ESPTargets = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPTargets[player] then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local RootPart = character.HumanoidRootPart
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid then return end
    
    -- Определяем роль
    local role = "Innocent"
    if character:FindFirstChild("Knife") then
        role = "Murder"
    elseif character:FindFirstChild("Gun") or character:FindFirstChild("Revolver") then
        role = "Sheriff"
    end
    
    -- Цвета для ролей
    local espColor = Color3.fromRGB(0, 255, 0) -- Зеленый (невинный)
    if role == "Murder" then
        espColor = Color3.fromRGB(255, 0, 0) -- Красный (убийца)
    elseif role == "Sheriff" then
        espColor = Color3.fromRGB(0, 100, 255) -- Синий (шериф)
    end
    
    -- BillboardGui
    local BillboardGui = Instance.new("BillboardGui")
    BillboardGui.Size = UDim2.new(4, 0, 5, 0)
    BillboardGui.MaxDistance = 500
    BillboardGui.Parent = RootPart
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, 0, 1, 0)
    TextLabel.BackgroundColor3 = espColor
    TextLabel.BackgroundTransparency = 0.3
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Text = player.Name .. " [" .. role .. "]"
    TextLabel.TextSize = 14
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.Parent = BillboardGui
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = TextLabel
    
    ESPTargets[player] = {
        Billboard = BillboardGui,
        Role = role,
        Color = espColor
    }
end

local function RemoveESP(player)
    if ESPTargets[player] then
        if ESPTargets[player].Billboard then
            ESPTargets[player].Billboard:Destroy()
        end
        ESPTargets[player] = nil
    end
end

local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if Toggles["ESP"] then
            CreateESP(player)
        else
            RemoveESP(player)
        end
    end
end

RunService.RenderStepped:Connect(function()
    if Toggles["ESP"] then
        UpdateESP()
    end
end)

Players.PlayerAdded:Connect(function(player)
    if Toggles["ESP"] then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- ============ DROPPED GUN ============
local gunESPMarkers = {}

local function CreateDroppedGunESP()
    local workspace = game:GetService("Workspace")
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj.Name == "Gun" or obj.Name == "Revolver") and obj:IsA("Model") then
            if not gunESPMarkers[obj] then
                local gunPart = obj:FindFirstChild("Handle") or obj.PrimaryPart
                if gunPart then
                    local BillboardGui = Instance.new("BillboardGui")
                    BillboardGui.Size = UDim2.new(3, 0, 3, 0)
                    BillboardGui.MaxDistance = 300
                    BillboardGui.Parent = gunPart
                    
                    local TextLabel = Instance.new("TextLabel")
                    TextLabel.Size = UDim2.new(1, 0, 1, 0)
                    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                    TextLabel.BackgroundTransparency = 0.2
                    TextLabel.Text = "🔫 GUN"
                    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    TextLabel.TextSize = 12
                    TextLabel.Font = Enum.Font.GothamBold
                    TextLabel.Parent = BillboardGui
                    
                    local UICorner = Instance.new("UICorner")
                    UICorner.CornerRadius = UDim.new(0, 3)
                    UICorner.Parent = TextLabel
                    
                    gunESPMarkers[obj] = BillboardGui
                end
            end
        end
    end
end

local function RemoveDroppedGunESP()
    for _, billboard in pairs(gunESPMarkers) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    gunESPMarkers = {}
end

RunService.RenderStepped:Connect(function()
    if Toggles["Dropped Gun"] then
        CreateDroppedGunESP()
    end
end)

-- ============ ESP (ОСНОВНАЯ ФУНКЦИЯ) ============
CreateToggle("ESP", function(enabled)
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            CreateESP(player)
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            RemoveESP(player)
        end
    end
end)

-- ============ DROPPED GUN ============
CreateToggle("Dropped Gun", function(enabled)
    if enabled then
        CreateDroppedGunESP()
    else
        RemoveDroppedGunESP()
    end
end)

-- ============ SHOT MURDER ============
local ShotMurderButton = nil

CreateToggle("Shot Murder", function(enabled)
    if enabled then
        if not ShotMurderButton then
            ShotMurderButton = Instance.new("TextButton")
            ShotMurderButton.Name = "ShotButton"
            ShotMurderButton.Size = UDim2.new(0, 140, 0, 60)
            ShotMurderButton.Position = UDim2.new(0.5, -70, 0.5, -30)
            ShotMurderButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
            ShotMurderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ShotMurderButton.Text = "🎯 SHOOT"
            ShotMurderButton.TextSize = 16
            ShotMurderButton.Font = Enum.Font.GothamBold
            ShotMurderButton.Parent = ScreenGui
            ShotMurderButton.ZIndex = 100
            
            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 10)
            UICorner.Parent = ShotMurderButton
            
            local UIStroke = Instance.new("UIStroke")
            UIStroke.Color = Color3.fromRGB(255, 100, 100)
            UIStroke.Thickness = 2
            UIStroke.Parent = ShotMurderButton
            
            ShotMurderButton.MouseEnter:Connect(function()
                local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local goals = {BackgroundColor3 = Color3.fromRGB(255, 80, 80)}
                local tween = game:GetService("TweenService"):Create(ShotMurderButton, tweenInfo, goals)
                tween:Play()
            end)
            
            ShotMurderButton.MouseLeave:Connect(function()
                local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local goals = {BackgroundColor3 = Color3.fromRGB(255, 50, 50)}
                local tween = game:GetService("TweenService"):Create(ShotMurderButton, tweenInfo, goals)
                tween:Play()
            end)
            
            ShotMurderButton.MouseButton1Click:Connect(function()
                local murderer = nil
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local char = player.Character
                        if char:FindFirstChild("Knife") then
                            local camera = workspace.CurrentCamera
                            local targetPos = char.HumanoidRootPart.Position
                            local rayOrigin = camera.CFrame.Position
                            local rayDirection = (targetPos - rayOrigin).Unit
                            
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                            
                            local result = workspace:Raycast(rayOrigin, rayDirection * 500, raycastParams)
                            
                            if result and result.Instance:IsDescendantOf(char) then
                                murderer = player
                                break
                            end
                        end
                    end
                end
                
                if murderer and LocalPlayer.Character then
                    local gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Character:FindFirstChild("Revolver")
                    if gun then
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local remote = ReplicatedStorage:FindFirstChild("FireGun") or ReplicatedStorage:FindFirstChild("Shoot")
                        if remote then
                            pcall(function()
                                remote:FireServer(murderer.Character.HumanoidRootPart)
                            end)
                        end
                    end
                end
            end)
        end
        
        ShotMurderButton.Visible = true
    else
        if ShotMurderButton then
            ShotMurderButton.Visible = false
        end
    end
end)

-- ============ INVIS (НЕВИДИМОСТЬ) ============
CreateToggle("Invis", function(enabled)
    if LocalPlayer.Character then
        if enabled then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                    part.CanCollide = false
                end
            end
            if LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.HealthDisplayDistance = 0
            end
        else
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 0
                    part.CanCollide = true
                end
            end
            if LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.HealthDisplayDistance = 100
            end
        end
    end
end)

-- ============ TP GUN ============
CreateToggle("TP Gun", function(enabled)
    if enabled then
        RunService.RenderStepped:Connect(function()
            if not Toggles["TP Gun"] then return end
            
            local workspace = game:GetService("Workspace")
            for _, obj in pairs(workspace:GetDescendants()) do
                if (obj.Name == "Gun" or obj.Name == "Revolver") and obj:IsA("Model") then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local gunPos = obj:FindFirstChild("Handle") or obj.PrimaryPart
                        if gunPos then
                            local rayOrigin = gunPos.Position + Vector3.new(0, 5, 0)
                            local rayDirection = Vector3.new(0, -1, 0)
                            
                            local raycastParams = RaycastParams.new()
                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                            raycastParams.FilterDescendantsInstances = {obj}
                            
                            local result = workspace:Raycast(rayOrigin, rayDirection * 100, raycastParams)
                            local landPos = gunPos.Position
                            
                            if result then
                                landPos = result.Position + Vector3.new(0, 3, 0)
                            end
                            
                            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(landPos)
                            break
                        end
                    end
                end
            end
        end)
    end
end)

-- ============ SPEED ============
local speedConnection = nil
CreateToggle("Speed", function(enabled)
    if enabled then
        if not speedConnection then
            speedConnection = RunService.RenderStepped:Connect(function()
                if Toggles["Speed"] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                    LocalPlayer.Character.Humanoid.WalkSpeed = 50
                end
            end)
        end
    else
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

-- ============ SECRET (ОТТАЛКИВАНИЕ) ============
CreateToggle("Secret", function(enabled)
    if enabled then
        RunService.RenderStepped:Connect(function()
            if not Toggles["Secret"] then return end
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local myPos = LocalPlayer.Character.HumanoidRootPart.Position
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local playerPos = player.Character.HumanoidRootPart.Position
                        local distance = (myPos - playerPos).Magnitude
                        
                        if distance < 15 then
                            local direction = (playerPos - myPos).Unit
                            if player.Character:FindFirstChild("Humanoid") then
                                player.Character.HumanoidRootPart.Velocity = direction * 120 + Vector3.new(0, 50, 0)
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ============ ОБНОВЛЕНИЕ ПРИ ВОЗРОЖДЕНИИ ============
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    wait(0.3)
    if Toggles["Speed"] then
        local humanoid = newCharacter:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 50
        end
    end
    
    if Toggles["Invis"] then
        for _, part in pairs(newCharacter:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
                part.CanCollide = false
            end
        end
    end
end)

print("✓ Platinum Part 2 & 3 загружены | ВСЕ ФУНКЦИИ АКТИВНЫ!")
print("✓ Platinum Cheat полностью загружен и готов к использованию")
print("=" .. string.rep("=", 50))
print("Нажми на иконку ⚡ чтобы открыть меню")
print("=" .. string.rep("=", 50))

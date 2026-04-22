-- Platinum Cheat MM2 | Part 1
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Создание главного UI
local screenSize = LocalPlayer:GetMouse().ViewSizeX
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PlatinumCheat"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Фоновая панель с частицами
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0, 20, 1, -520)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Эффект частиц на фоне
local Particles = Instance.new("Frame")
Particles.Name = "Particles"
Particles.Size = UDim2.new(1, 0, 1, 0)
Particles.BackgroundTransparency = 1
Particles.Parent = MainFrame

-- Хедер
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "Title"
TitleLabel.Size = UDim2.new(1, 0, 1, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "PLATINUM"
TitleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
TitleLabel.TextSize = 24
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Parent = Header

-- Вкладка MM2
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "Content"
ContentFrame.Size = UDim2.new(1, 0, 0, 400)
ContentFrame.Position = UDim2.new(0, 0, 0, 60)
ContentFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

-- Скролл список
local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "ScrollingFrame"
ScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.ScrollBarThickness = 5
ScrollingFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 200, 255)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 500)
ScrollingFrame.Parent = ContentFrame

-- Функция создания кнопки
local function CreateButton(name, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name
    Button.Size = UDim2.new(1, -5, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Button.BorderSizePixel = 0
    Button.Text = name
    Button.TextColor3 = Color3.fromRGB(200, 200, 200)
    Button.TextSize = 14
    Button.Font = Enum.Font.Gotham
    Button.Parent = ScrollingFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = Button
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(100, 200, 255)
    UIStroke.Thickness = 1
    UIStroke.Parent = Button
    
    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)
    
    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    end)
    
    Button.MouseButton1Click:Connect(callback)
    
    return Button
end

-- Функция создания тоггла
local Toggles = {}
local function CreateToggle(name, callback)
    local ToggleButton = Instance.new("Frame")
    ToggleButton.Name = name
    ToggleButton.Size = UDim2.new(1, -5, 0, 35)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Parent = ScrollingFrame
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = ToggleButton
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = name
    TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TextLabel.TextSize = 14
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Parent = ToggleButton
    
    local ToggleBox = Instance.new("Frame")
    ToggleBox.Size = UDim2.new(0, 30, 0, 20)
    ToggleBox.Position = UDim2.new(0.75, 0, 0.5, -10)
    ToggleBox.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    ToggleBox.BorderSizePixel = 0
    ToggleBox.Parent = ToggleButton
    
    local UICorner2 = Instance.new("UICorner")
    UICorner2.CornerRadius = UDim.new(0, 3)
    UICorner2.Parent = ToggleBox
    
    local isEnabled = false
    Toggles[name] = isEnabled
    
    local ToggleButton2 = Instance.new("TextButton")
    ToggleButton2.Size = UDim2.new(1, 0, 1, 0)
    ToggleButton2.BackgroundTransparency = 1
    ToggleButton2.Text = ""
    ToggleButton2.Parent = ToggleButton
    
    ToggleButton2.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        Toggles[name] = isEnabled
        ToggleBox.BackgroundColor3 = isEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
        callback(isEnabled)
    end)
    
    return ToggleButton
end

-- Профиль игрока (внизу)
local ProfileFrame = Instance.new("Frame")
ProfileFrame.Name = "Profile"
ProfileFrame.Size = UDim2.new(1, 0, 0, 60)
ProfileFrame.Position = UDim2.new(0, 0, 1, -60)
ProfileFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ProfileFrame.BorderSizePixel = 0
ProfileFrame.Parent = MainFrame

local ProfileLabel = Instance.new("TextLabel")
ProfileLabel.Size = UDim2.new(0.7, 0, 1, 0)
ProfileLabel.BackgroundTransparency = 1
ProfileLabel.Text = "Player: " .. LocalPlayer.Name
ProfileLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
ProfileLabel.TextSize = 12
ProfileLabel.Font = Enum.Font.Gotham
ProfileLabel.TextXAlignment = Enum.TextXAlignment.Left
ProfileLabel.Parent = ProfileFrame

-- Сохраняем ссылки для части 2 и 3
_G.PlatinumUI = {
    MainFrame = MainFrame,
    ScrollingFrame = ScrollingFrame,
    CreateToggle = CreateToggle,
    CreateButton = CreateButton,
    Toggles = Toggles
}

print("✓ Platinum Part 1 загружен | UI инициализирован")
-- Platinum Cheat MM2 | Part 2 - ESP Functions
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ESP таблица
local ESPTargets = {}
local ESPEnabled = false

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
        if ESPEnabled then
            CreateESP(player)
        else
            RemoveESP(player)
        end
    end
end

-- Обновление ESP каждый кадр
RunService.RenderStepped:Connect(function()
    if ESPEnabled then
        UpdateESP()
    end
end)

Players.PlayerAdded:Connect(function(player)
    if ESPEnabled then
        CreateESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

-- Функция для дропнувшего пистолета
local function CreateDroppedGunESP()
    local gunESPConnection
    gunESPConnection = RunService.RenderStepped:Connect(function()
        if not Toggles or not Toggles["Dropped Gun"] then
            return
        end
        
        local workspace = game:GetService("Workspace")
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "Gun" or obj.Name == "Revolver" then
                if obj:IsA("Model") and not obj:FindFirstChild("ESPLabel") then
                    local BillboardGui = Instance.new("BillboardGui")
                    BillboardGui.Size = UDim2.new(3, 0, 3, 0)
                    BillboardGui.MaxDistance = 300
                    BillboardGui.Parent = obj
                    
                    local TextLabel = Instance.new("TextLabel")
                    TextLabel.Size = UDim2.new(1, 0, 1, 0)
                    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                    TextLabel.BackgroundTransparency = 0.2
                    TextLabel.Text = "GUN"
                    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    TextLabel.TextSize = 12
                    TextLabel.Font = Enum.Font.GothamBold
                    TextLabel.Parent = BillboardGui
                    
                    local marker = Instance.new("Part")
                    marker.Name = "ESPLabel"
                    marker.CanCollide = false
                    marker.Transparency = 1
                    marker.Parent = obj
                end
            end
        end
    end)
end

_G.PlatinumESP = {
    CreateESP = CreateESP,
    RemoveESP = RemoveESP,
    UpdateESP = UpdateESP,
    CreateDroppedGunESP = CreateDroppedGunESP,
    Toggles = Toggles
}

print("✓ Platinum Part 2 загружен | ESP функции готовы")
-- Platinum Cheat MM2 | Part 3 - MM2 Features
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Получаем UI элементы из части 1
local ScrollingFrame = _G.PlatinumUI.ScrollingFrame
local CreateToggle = _G.PlatinumUI.CreateToggle
local CreateButton = _G.PlatinumUI.CreateButton
local Toggles = _G.PlatinumUI.Toggles

-- ============ ESP ============
CreateToggle("ESP", function(enabled)
    if enabled then
        for _, player in pairs(Players:GetPlayers()) do
            _G.PlatinumESP.CreateESP(player)
        end
    else
        for _, player in pairs(Players:GetPlayers()) do
            _G.PlatinumESP.RemoveESP(player)
        end
    end
end)

-- ============ DROPPED GUN ============
CreateToggle("Dropped Gun", function(enabled)
    if enabled then
        _G.PlatinumESP.CreateDroppedGunESP()
    end
end)

-- ============ SHOT MURDER ============
local ShotMurderButton = nil
CreateToggle("Shot Murder", function(enabled)
    if enabled then
        -- Создаем кнопку на экране
        if not ShotMurderButton then
            local ScreenGui = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("PlatinumCheat")
            
            ShotMurderButton = Instance.new("TextButton")
            ShotMurderButton.Name = "ShotButton"
            ShotMurderButton.Size = UDim2.new(0, 120, 0, 50)
            ShotMurderButton.Position = UDim2.new(0.5, -60, 0.5, -25)
            ShotMurderButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
            ShotMurderButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            ShotMurderButton.Text = "SHOOT"
            ShotMurderButton.TextSize = 18
            ShotMurderButton.Font = Enum.Font.GothamBold
            ShotMurderButton.Parent = ScreenGui
            
            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 8)
            UICorner.Parent = ShotMurderButton
            
            ShotMurderButton.MouseButton1Click:Connect(function()
                local murderer = nil
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local char = player.Character
                        if char:FindFirstChild("Knife") then
                            -- Проверяем открытая ли территория
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
                
                if murderer then
                    -- Стреляем
                    local gun = Character:FindFirstChild("Gun") or Character:FindFirstChild("Revolver")
                    if gun then
                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("FireGun")
                        if remote then
                            remote:FireServer(murderer.Character.HumanoidRootPart)
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
    if enabled then
        LocalPlayer.Character.Humanoid.Health = 0
        wait(0.5)
        -- После возрождения будешь невидим
        LocalPlayer.Character:FindFirstChild("Head").CanCollide = false
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 1
                part.CanCollide = false
            end
        end
    else
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.Transparency = 0
                part.CanCollide = true
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
                            -- Ищем пол под пистолетом
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
                        end
                    end
                end
            end
        end)
    end
end)

-- ============ SPEED ============
CreateToggle("Speed", function(enabled)
    local speedConnection
    if enabled then
        speedConnection = RunService.RenderStepped:Connect(function()
            if Toggles["Speed"] and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 50
                end
            end
        end)
    else
        if speedConnection then
            speedConnection:Disconnect()
        end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
end)

-- ============ SECRET (Отталкивание) ============
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
                        
                        if distance < 10 then
                            -- Отталкиваем
                            local direction = (playerPos - myPos).Unit
                            player.Character.HumanoidRootPart.Velocity = direction * 100
                        end
                    end
                end
            end
        end)
    end
end)

-- Обновляем UI по возрождению
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    if Toggles["Speed"] then
        Humanoid.WalkSpeed = 50
    end
end)

print("✓ Platinum Part 3 загружен | ВСЕ ФУНКЦИИ АКТИВНЫ!")
print("✓ Platinum Cheat полностью загружен и готов к использованию")

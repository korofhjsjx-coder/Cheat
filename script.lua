-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
local MainButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "RagdollCheatGui"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Настройка кнопки
MainButton.Name = "MainButton"
MainButton.Parent = ScreenGui
MainButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
MainButton.Position = UDim2.new(0.9, 0, 0.4, 0)
MainButton.Size = UDim2.new(0, 60, 0, 60)
MainButton.Font = Enum.Font.GothamBold
MainButton.Text = "R"
MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainButton.TextSize = 35
MainButton.Draggable = true

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainButton

-- Переменные
local RagdollEnabled = false
local Player = game.Players.LocalPlayer
local SavedMotors = {}

-- Функция уведомлений
local function SendNotification(text)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Ragdoll";
        Text = text;
        Duration = 2;
    })
end

-- Функция включения Ragdoll
local function EnableRagdoll()
    local Character = Player.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    
    if Humanoid and HumanoidRootPart then
        -- Отключаем управление
        Humanoid.PlatformStand = true
        Humanoid.AutoRotate = false
        
        -- Останавливаем анимации
        for _, track in pairs(Humanoid:GetPlayingAnimationTracks()) do
            track:Stop()
        end
        
        -- Сохраняем и заменяем моторы на шарниры
        SavedMotors = {}
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("Motor6D") then
                local info = {
                    Motor = v,
                    Part0 = v.Part0,
                    Part1 = v.Part1,
                    C0 = v.C0,
                    C1 = v.C1,
                    Parent = v.Parent
                }
                table.insert(SavedMotors, info)
                
                local a0 = Instance.new("Attachment")
                local a1 = Instance.new("Attachment")
                
                a0.Parent = v.Part0
                a1.Parent = v.Part1
                a0.CFrame = v.C0
                a1.CFrame = v.C1
                a0.Name = "RagdollAttachment0"
                a1.Name = "RagdollAttachment1"
                
                local ball = Instance.new("BallSocketConstraint")
                ball.Parent = v.Parent
                ball.Attachment0 = a0
                ball.Attachment1 = a1
                ball.LimitsEnabled = true
                ball.UpperAngle = 50
                ball.Name = "RagdollConstraint"
                
                v.Enabled = false
            end
        end
        
        -- Настройка частей тела (БЕЗ ПРОВАЛИВАНИЯ)
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                if part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                    part.CollisionGroup = "RagdollParts"
                    part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
                else
                    -- HumanoidRootPart остается без коллизии с землей
                    part.CanCollide = false
                end
            end
        end
        
        -- Небольшой толчок для реалистичного падения
        local fallDirection = math.random(0, 1) == 0 and -1 or 1
        HumanoidRootPart.Velocity = Vector3.new(0, -5, fallDirection * 3)
    end
end

-- Функция отключения Ragdoll
local function DisableRagdoll()
    local Character = Player.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
    
    if Humanoid and HumanoidRootPart then
        -- Удаляем все рагдолл объекты
        for _, v in pairs(Character:GetDescendants()) do
            if v.Name == "RagdollConstraint" or v.Name == "RagdollAttachment0" or v.Name == "RagdollAttachment1" then
                v:Destroy()
            end
        end
        
        -- Восстанавливаем моторы
        for _, info in pairs(SavedMotors) do
            if info.Motor and info.Part0 and info.Part1 then
                info.Motor.Enabled = true
            end
        end
        
        -- Восстанавливаем коллизию
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.CollisionGroup = "Default"
                part.CustomPhysicalProperties = nil
            end
        end
        
        -- Поднимаем персонажа немного вверх
        HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + Vector3.new(0, 2, 0)
        HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
        
        -- Включаем управление обратно
        Humanoid.PlatformStand = false
        Humanoid.AutoRotate = true
        
        wait(0.1)
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        
        SavedMotors = {}
    end
end

-- Обработчик нажатия кнопки
MainButton.MouseButton1Click:Connect(function()
    RagdollEnabled = not RagdollEnabled
    
    if RagdollEnabled then
        MainButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        MainButton.Text = "R"
        MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        SendNotification("ВКЛЮЧЕН ✅")
        EnableRagdoll()
    else
        MainButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        MainButton.Text = "R"
        MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        SendNotification("ОТКЛЮЧЕН ❌")
        DisableRagdoll()
    end
end)

-- Обновление при респавне
Player.CharacterAdded:Connect(function(char)
    wait(0.5)
    RagdollEnabled = false
    SavedMotors = {}
    MainButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    MainButton.Text = "R"
end)

-- Первое уведомление
SendNotification("Ragdoll загружен! 🎮")

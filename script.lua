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
MainButton.Text = "💀"
MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MainButton.TextSize = 30
MainButton.Draggable = true -- Можно двигать

UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainButton

-- Переменные
local RagdollEnabled = false
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Функция уведомлений
local function SendNotification(text)
    game.StarterGui:SetCore("SendNotification", {
        Title = "Ragdoll Cheat";
        Text = text;
        Duration = 3;
    })
end

-- Функция включения Ragdoll
local function EnableRagdoll()
    local Character = Player.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        -- Устанавливаем состояние Ragdoll
        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        
        -- Отключаем все моторы для эффекта тряпичной куклы
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("Motor6D") then
                local socket = Instance.new("BallSocketConstraint")
                local a1 = Instance.new("Attachment")
                local a2 = Instance.new("Attachment")
                
                a1.Parent = v.Part0
                a2.Parent = v.Part1
                
                socket.Parent = v.Parent
                socket.Attachment0 = a1
                socket.Attachment1 = a2
                
                a1.CFrame = v.C0
                a2.CFrame = v.C1
                
                socket.LimitsEnabled = true
                socket.TwistLimitsEnabled = true
                
                v.Enabled = false
            end
        end
    end
end

-- Функция отключения Ragdoll
local function DisableRagdoll()
    local Character = Player.Character
    if not Character then return end
    
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        -- Восстанавливаем нормальное состояние
        Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        
        -- Включаем обратно все моторы
        for _, v in pairs(Character:GetDescendants()) do
            if v:IsA("Motor6D") then
                v.Enabled = true
            end
            if v:IsA("BallSocketConstraint") then
                v:Destroy()
            end
        end
    end
end

-- Обработчик нажатия кнопки
MainButton.MouseButton1Click:Connect(function()
    RagdollEnabled = not RagdollEnabled
    
    if RagdollEnabled then
        MainButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        MainButton.Text = "🔥"
        SendNotification("Ragdoll ВКЛЮЧЕН! ✅")
        EnableRagdoll()
    else
        MainButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        MainButton.Text = "💀"
        SendNotification("Ragdoll ОТКЛЮЧЕН! ❌")
        DisableRagdoll()
    end
end)

-- Обновление при респавне
Player.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    
    -- Если ragdoll был включен, применяем снова
    if RagdollEnabled then
        wait(0.5)
        EnableRagdoll()
    end
end)

-- Первое уведомление
SendNotification("Ragdoll чит загружен! 💀")
wait(0.5)
SendNotification("Нажми на кнопку для активации!")

--// MM2 Ragdoll + Bald (Improved)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Удаляем старый GUI
pcall(function()
    if game.CoreGui:FindFirstChild("MM2_Ragdoll") then
        game.CoreGui.MM2_Ragdoll:Destroy()
    end
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MM2_Ragdoll"
gui.Parent = game.CoreGui

local button = Instance.new("TextButton")
button.Parent = gui
button.Size = UDim2.new(0,65,0,65)
button.Position = UDim2.new(0.5,-32,0.75,0)
button.BackgroundColor3 = Color3.fromRGB(20,20,20)
button.Text = "R"
button.TextScaled = true
button.TextColor3 = Color3.new(1,1,1)
button.BorderSizePixel = 0
button.Active = true
button.Draggable = true

Instance.new("UICorner", button).CornerRadius = UDim.new(1,0)

-- Переменные
local enabled = false
local storedMotors = {}
local removedHair = {}

-- Уведомление
local function notify(text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "MM2 Ragdoll",
            Text = text,
            Duration = 2
        })
    end)
end

-- Проверка: волосы ли это
local function isHair(accessory)
    return accessory:IsA("Accessory") 
        and accessory.AccessoryType == Enum.AccessoryType.Hair
end

-- Сделать лысым
local function makeBald(character)
    removedHair = {}
    for _, acc in ipairs(character:GetChildren()) do
        if isHair(acc) then
            table.insert(removedHair, acc)
            acc.Parent = nil
        end
    end
end

-- Вернуть волосы
local function restoreHair(character)
    for _, acc in ipairs(removedHair) do
        if acc then
            acc.Parent = character
        end
    end
    removedHair = {}
end

-- Создать ragdoll
local function createRagdoll(character)
    storedMotors = {}

    for _, motor in ipairs(character:GetDescendants()) do
        if motor:IsA("Motor6D") and motor.Part0 and motor.Part1 then

            local att0 = Instance.new("Attachment")
            local att1 = Instance.new("Attachment")

            att0.CFrame = motor.C0
            att1.CFrame = motor.C1

            att0.Parent = motor.Part0
            att1.Parent = motor.Part1

            local ball = Instance.new("BallSocketConstraint")
            ball.Attachment0 = att0
            ball.Attachment1 = att1
            ball.Parent = motor.Part0

            storedMotors[motor] = {
                Motor = motor,
                A0 = att0,
                A1 = att1,
                Constraint = ball
            }

            motor.Enabled = false
        end
    end
end

-- Удалить ragdoll
local function removeRagdoll()
    for motor, data in pairs(storedMotors) do
        if motor and motor.Parent then
            motor.Enabled = true
        end
        if data.A0 then data.A0:Destroy() end
        if data.A1 then data.A1:Destroy() end
        if data.Constraint then data.Constraint:Destroy() end
    end
    storedMotors = {}
end

-- Переключение
local function toggle()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    enabled = not enabled

    if enabled then
        makeBald(char)
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        hum.AutoRotate = false
        createRagdoll(char)
        notify("💀 Ragdoll включён")
    else
        removeRagdoll()
        restoreHair(char)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hum.AutoRotate = true
        notify("✅ Ragdoll выключен")
    end
end

-- Фикс после смерти
player.CharacterAdded:Connect(function()
    enabled = false
    storedMotors = {}
    removedHair = {}
end)

button.MouseButton1Click:Connect(toggle)

--// MM2 Clean Ragdoll (Delta Full)

local player = game.Players.LocalPlayer

-- Удаляем старый GUI если был
pcall(function()
    if game.CoreGui:FindFirstChild("MM2_Ragdoll") then
        game.CoreGui.MM2_Ragdoll:Destroy()
    end
end)

-- Создание GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MM2_Ragdoll"
gui.Parent = game.CoreGui

local button = Instance.new("TextButton")
button.Parent = gui
button.Size = UDim2.new(0, 65, 0, 65)
button.Position = UDim2.new(0.5, -32, 0.75, 0)
button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
button.Text = "R"
button.TextScaled = true
button.TextColor3 = Color3.new(1,1,1)
button.BorderSizePixel = 0
button.Active = true
button.Draggable = true

local corner = Instance.new("UICorner")
corner.Parent = button
corner.CornerRadius = UDim.new(1,0)

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

-- Переменные
local enabled = false
local savedWalkSpeed = 16
local savedJumpPower = 50

local function toggleRagdoll()
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    enabled = not enabled

    if enabled then
        -- Сохраняем параметры
        savedWalkSpeed = hum.WalkSpeed
        savedJumpPower = hum.JumpPower

        -- Отключаем движение
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hum.AutoRotate = false
        hum.PlatformStand = true

        -- Останавливаем вращение и падение
        root.AssemblyAngularVelocity = Vector3.new(0,0,0)
        root.AssemblyLinearVelocity = Vector3.new(0,0,0)

        notify("✅ Персонаж лежит")
    else
        -- Возвращаем движение
        hum.PlatformStand = false
        hum.AutoRotate = true
        hum.WalkSpeed = savedWalkSpeed
        hum.JumpPower = savedJumpPower
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)

        notify("❌ Персонаж встал")
    end
end

button.MouseButton1Click:Connect(toggleRagdoll)

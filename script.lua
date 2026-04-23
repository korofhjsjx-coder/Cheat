--// MM2 Ragdoll + Bald (Delta)

local player = game.Players.LocalPlayer

pcall(function()
    if game.CoreGui:FindFirstChild("MM2_Ragdoll") then
        game.CoreGui.MM2_Ragdoll:Destroy()
    end
end)

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MM2_Ragdoll"

local button = Instance.new("TextButton", gui)
button.Size = UDim2.new(0, 65, 0, 65)
button.Position = UDim2.new(0.5, -32, 0.75, 0)
button.BackgroundColor3 = Color3.fromRGB(20,20,20)
button.Text = "R"
button.TextScaled = true
button.TextColor3 = Color3.new(1,1,1)
button.Active = true
button.Draggable = true
button.BorderSizePixel = 0

Instance.new("UICorner", button).CornerRadius = UDim.new(1,0)

local function notify(text)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = "MM2 Ragdoll",
            Text = text,
            Duration = 2
        })
    end)
end

local enabled = false
local storedMotors = {}
local removedAccessories = {}

-- Удаляем волосы
local function makeBald(character)
    for _, acc in pairs(character:GetChildren()) do
        if acc:IsA("Accessory") then
            if acc:FindFirstChild("Handle") then
                table.insert(removedAccessories, acc)
                acc.Parent = nil
            end
        end
    end
end

-- Возвращаем волосы
local function restoreHair(character)
    for _, acc in pairs(removedAccessories) do
        acc.Parent = character
    end
    removedAccessories = {}
end

-- Создание ragdoll
local function createRagdoll(character)
    for _, motor in pairs(character:GetDescendants()) do
        if motor:IsA("Motor6D") then
            local part0 = motor.Part0
            local part1 = motor.Part1

            if part0 and part1 then
                local att0 = Instance.new("Attachment", part0)
                local att1 = Instance.new("Attachment", part1)

                att0.CFrame = motor.C0
                att1.CFrame = motor.C1

                local ball = Instance.new("BallSocketConstraint")
                ball.Attachment0 = att0
                ball.Attachment1 = att1
                ball.Parent = part0

                storedMotors[motor] = {
                    Motor = motor,
                    Attachment0 = att0,
                    Attachment1 = att1,
                    Constraint = ball
                }

                motor.Enabled = false
            end
        end
    end
end

-- Удаление ragdoll
local function removeRagdoll()
    for motor, data in pairs(storedMotors) do
        if motor and motor.Parent then
            motor.Enabled = true
        end
        if data.Attachment0 then data.Attachment0:Destroy() end
        if data.Attachment1 then data.Attachment1:Destroy() end
        if data.Constraint then data.Constraint:Destroy() end
    end
    storedMotors = {}
end

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
        notify("💀 Лысый Ragdoll включён")
    else
        removeRagdoll()
        restoreHair(char)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hum.AutoRotate = true
        notify("✅ Волосы возвращены")
    end
end

button.MouseButton1Click:Connect(toggle)

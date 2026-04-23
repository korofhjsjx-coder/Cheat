--// MM2 Real Death Ragdoll (Stable)

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
			Title = "MM2 Death",
			Text = text,
			Duration = 2
		})
	end)
end

local enabled = false
local stored = {}
local removedAccessories = {}

-- Лысый режим
local function makeBald(char)
	for _, acc in pairs(char:GetChildren()) do
		if acc:IsA("Accessory") then
			table.insert(removedAccessories, acc)
			acc.Parent = nil
		end
	end
end

local function restoreHair(char)
	for _, acc in pairs(removedAccessories) do
		acc.Parent = char
	end
	removedAccessories = {}
end

-- Создание сустава с лимитами
local function createJoint(motor)
	local p0 = motor.Part0
	local p1 = motor.Part1
	if not p0 or not p1 then return end

	local a0 = Instance.new("Attachment", p0)
	local a1 = Instance.new("Attachment", p1)
	a0.CFrame = motor.C0
	a1.CFrame = motor.C1

	local ball = Instance.new("BallSocketConstraint")
	ball.Attachment0 = a0
	ball.Attachment1 = a1
	ball.LimitsEnabled = true
	ball.TwistLimitsEnabled = true
	ball.UpperAngle = 35
	ball.TwistLowerAngle = -25
	ball.TwistUpperAngle = 25
	ball.Restitution = 0
	ball.Parent = p0

	motor.Enabled = false

	stored[motor] = {a0, a1, ball}
end

local function enableRagdoll(char)
	for _, m in pairs(char:GetDescendants()) do
		if m:IsA("Motor6D") then
			createJoint(m)
		end
	end
end

local function disableRagdoll()
	for motor, parts in pairs(stored) do
		if motor and motor.Parent then
			motor.Enabled = true
		end
		for _, obj in pairs(parts) do
			if obj then obj:Destroy() end
		end
	end
	stored = {}
end

local function toggle()
	local char = player.Character
	if not char then return end

	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if not hum or not root then return end

	enabled = not enabled

	if enabled then
		makeBald(char)

		-- Убираем контроль
		hum.AutoRotate = false
		hum:ChangeState(Enum.HumanoidStateType.Physics)

		-- Останавливаем вращение
		root.AssemblyAngularVelocity = Vector3.new(0,0,0)

		-- Немного толкаем вниз чтобы реально упал
		root.AssemblyLinearVelocity = Vector3.new(0,-25,0)

		enableRagdoll(char)

		notify("💀 Вы убиты")
	else
		disableRagdoll()
		restoreHair(char)

		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		hum.AutoRotate = true

		notify("✅ Вы встали")
	end
end

button.MouseButton1Click:Connect(toggle)

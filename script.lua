--// MM2 Stable Realistic Ragdoll V2

local player = game.Players.LocalPlayer

pcall(function()
	if game.CoreGui:FindFirstChild("MM2_Ragdoll") then
		game.CoreGui.MM2_Ragdoll:Destroy()
	end
end)

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MM2_Ragdoll"

local button = Instance.new("TextButton", gui)
button.Size = UDim2.new(0, 60, 0, 60)
button.Position = UDim2.new(0.5, -30, 0.75, 0)
button.BackgroundColor3 = Color3.fromRGB(25,25,25)
button.Text = "R"
button.TextScaled = true
button.TextColor3 = Color3.new(1,1,1)
button.Active = true
button.Draggable = true
button.BorderSizePixel = 0
Instance.new("UICorner", button).CornerRadius = UDim.new(1,0)

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

-- Создание ограниченного сустава
local function createLimitedJoint(motor, angle, twist)
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
	ball.UpperAngle = angle
	ball.TwistLowerAngle = -twist
	ball.TwistUpperAngle = twist
	ball.Restitution = 0
	ball.Parent = p0

	motor.Enabled = false

	stored[motor] = {a0,a1,ball}
end

local function enableRagdoll(char)
	for _, m in pairs(char:GetDescendants()) do
		if m:IsA("Motor6D") then

			-- Оставляем позвоночник жёстким
			if m.Name == "RootJoint" or m.Name == "Waist" then
				continue
			end

			-- Шея (ограниченная)
			if m.Name == "Neck" then
				createLimitedJoint(m, 25, 20)
			else
				-- Руки и ноги
				createLimitedJoint(m, 45, 25)
			end
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

		hum.AutoRotate = false
		hum:ChangeState(Enum.HumanoidStateType.Physics)

		-- Убираем вращение
		root.AssemblyAngularVelocity = Vector3.zero

		-- Падаем вниз
		root.AssemblyLinearVelocity = Vector3.new(0,-30,0)

		enableRagdoll(char)
	else
		disableRagdoll()
		restoreHair(char)

		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
		hum.AutoRotate = true
	end
end

button.MouseButton1Click:Connect(toggle)

-- ============================================================
--   Phantom  |  Murder Mystery 2
--   Professional MM2 Script
-- ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")
local CoreGui          = game:GetService("CoreGui")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local StarterGui       = game:GetService("StarterGui")

local LP   = Players.LocalPlayer
local Char = LP.Character or LP.CharacterAdded:Wait()
local Cam  = Workspace.CurrentCamera

-- ============================================================
--  SETTINGS
-- ============================================================
local S = {
    -- Main
    AutoFarm    = false,
    AutoGrabGun = false,
    AntiAFK     = true,
    -- Combat
    Aimbot      = false,
    AimFOV      = 130,
    AimSmooth   = 3,
    AimHead     = true,
    ShowFOV     = true,
    MobileAuto  = false,
    -- ESP
    ESP         = false,
    ShowRoles   = false,   -- BillboardGui role labels (NO esp needed)
    ShowNames   = true,
    ShowDist    = true,
    FullBright  = false,
    NoFog       = false,
    Crosshair   = false,
    -- Player
    Speed       = 16,
    Jump        = 50,
    InfJump     = false,
    Noclip      = false,
    Fly         = false,
}

-- ============================================================
--  ROLE DETECTION
-- ============================================================
local function getRole(p)
    if p == LP then return "Self" end
    local c = p.Character if not c then return "Unknown" end
    local t = c:FindFirstChildOfClass("Tool")
    if t then
        local n = t.Name:lower()
        if n:find("knife") or n:find("shard") or n:find("dagger") or n:find("blade") then return "Murder"  end
        if n:find("gun")   or n:find("sheriff")or n:find("revolv") or n:find("pistol") then return "Sheriff" end
    end
    return "Innocent"
end

local RoleColors = {
    Murder   = Color3.fromRGB(255, 65,  65),
    Sheriff  = Color3.fromRGB(65,  220, 100),
    Innocent = Color3.fromRGB(200, 200, 215),
    Unknown  = Color3.fromRGB(140, 140, 155),
    Self     = Color3.fromRGB(255, 200, 50),
}

-- ============================================================
--  BILLBOARD ROLE LABELS  (independent of Drawing ESP)
-- ============================================================
local Billboards = {}

local function removeBillboard(p)
    local b = Billboards[p]
    if b then pcall(function() b:Destroy() end) end
    Billboards[p] = nil
end

local function buildBillboard(p)
    if p == LP then return end
    removeBillboard(p)
    local char = p.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local bb = Instance.new("BillboardGui")
    bb.Name          = "PhantomRoleTag"
    bb.Size          = UDim2.new(0, 120, 0, 40)
    bb.StudsOffset   = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop   = true          -- visible through walls
    bb.ResetOnSpawn  = false
    bb.Adornee       = head
    bb.Parent        = head

    local bg = Instance.new("Frame", bb)
    bg.Size             = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    bg.BackgroundTransparency = 0.35
    bg.BorderSizePixel  = 0
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", bg)
    lbl.Size              = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text              = "..."
    lbl.TextColor3        = Color3.fromRGB(255, 255, 255)
    lbl.TextSize          = 14
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextXAlignment    = Enum.TextXAlignment.Center
    lbl.TextYAlignment    = Enum.TextYAlignment.Center

    Billboards[p] = bb

    -- Update role text every frame
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not bb.Parent or not S.ShowRoles then
            bb.Enabled = false
            return
        end
        bb.Enabled = true
        local r = getRole(p)
        lbl.Text       = r
        lbl.TextColor3 = RoleColors[r] or RoleColors.Unknown
    end)

    -- Clean up when player leaves or dies
    char.AncestryChanged:Connect(function()
        if conn then conn:Disconnect() end
        removeBillboard(p)
    end)
end

local function refreshBillboards()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then buildBillboard(p) end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(1) buildBillboard(p) end)
    if p.Character then buildBillboard(p) end
end)
Players.PlayerRemoving:Connect(removeBillboard)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then
        p.CharacterAdded:Connect(function() task.wait(1) buildBillboard(p) end)
        if p.Character then buildBillboard(p) end
    end
end

-- ============================================================
--  DRAWING ESP
-- ============================================================
local ESPObjs = {}

local function makeESP(p)
    if p == LP then return end
    local d = {}
    local bx = Drawing.new("Square"); bx.Visible=false; bx.Thickness=1.5; bx.Filled=false; d.Box=bx
    local nm = Drawing.new("Text");   nm.Visible=false; nm.Size=13; nm.Outline=true; nm.Center=true; d.Name=nm
    local tr = Drawing.new("Line");   tr.Visible=false; tr.Thickness=1; d.Tracer=tr
    local hl = Drawing.new("Line");   hl.Visible=false; hl.Thickness=2; d.Health=hl
    ESPObjs[p] = d
end

local function removeESP(p)
    local o = ESPObjs[p]; if not o then return end
    for _, v in pairs(o) do pcall(function() v:Remove() end) end
    ESPObjs[p] = nil
end

local function updateESP()
    for p, o in pairs(ESPObjs) do
        local c = p.Character
        local root = c and c:FindFirstChild("HumanoidRootPart")
        local hd   = c and c:FindFirstChild("Head")
        local hum2 = c and c:FindFirstChildOfClass("Humanoid")

        if not S.ESP or not root or not hd then
            o.Box.Visible=false; o.Name.Visible=false; o.Tracer.Visible=false; o.Health.Visible=false
        else
            local r = getRole(p)
            local col = RoleColors[r] or RoleColors.Innocent
            local hp, hv = Cam:WorldToViewportPoint(hd.Position)
            local rp     = Cam:WorldToViewportPoint(root.Position)

            if hv then
                local ht = math.abs(hp.Y - rp.Y); local w = ht * 0.55
                o.Box.Visible=true; o.Box.Color=col
                o.Box.Position=Vector2.new(hp.X-w/2, hp.Y); o.Box.Size=Vector2.new(w, ht)

                local parts={}
                if S.ShowNames then table.insert(parts, p.Name) end
                if S.ShowDist  then
                    local d2 = (Char and Char:FindFirstChild("HumanoidRootPart"))
                        and (Char.HumanoidRootPart.Position - root.Position).Magnitude or 0
                    table.insert(parts, math.floor(d2).."m")
                end
                o.Name.Visible=true; o.Name.Color=col
                o.Name.Position=Vector2.new(hp.X, hp.Y-20); o.Name.Text=table.concat(parts," | ")

                o.Tracer.Visible=true; o.Tracer.Color=col
                o.Tracer.From=Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y)
                o.Tracer.To=Vector2.new(hp.X, hp.Y)

                -- Health bar
                if hum2 then
                    local hpct = hum2.Health/hum2.MaxHealth
                    local barH = ht; local barX = hp.X - w/2 - 6
                    o.Health.Visible=true
                    o.Health.From=Vector2.new(barX, hp.Y+barH)
                    o.Health.To=Vector2.new(barX, hp.Y+barH-(barH*hpct))
                    o.Health.Color=Color3.fromRGB(math.floor(255*(1-hpct)),math.floor(255*hpct),50)
                    o.Health.Thickness=3
                end
            else
                o.Box.Visible=false; o.Name.Visible=false; o.Tracer.Visible=false; o.Health.Visible=false
            end
        end
    end
end

for _, p in ipairs(Players:GetPlayers()) do makeESP(p) end
Players.PlayerAdded:Connect(makeESP)
Players.PlayerRemoving:Connect(removeESP)

-- ============================================================
--  AUTO GRAB GUN  (immediate equip when gun drops)
-- ============================================================
local function tryEquipTool(tool)
    local hum = Char and Char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function() hum:EquipTool(tool) end)
    end
    -- Try remote events
    for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
        if rem:IsA("RemoteEvent") then
            local n = rem.Name:lower()
            if n:find("equip") or n:find("pickup") or n:find("grab") or n:find("take") then
                pcall(function() rem:FireServer(tool) end)
            end
        end
    end
    -- Move character directly onto the tool
    local r = Char and Char:FindFirstChild("HumanoidRootPart")
    if r then
        for _, p in ipairs(tool:GetDescendants()) do
            if p:IsA("BasePart") then
                r.CFrame = CFrame.new(p.Position + Vector3.new(0, 3, 0)); break
            end
        end
    end
end

local function isGunTool(obj)
    if not obj:IsA("Tool") then return false end
    local n = obj.Name:lower()
    return n:find("gun") or n:find("sheriff") or n:find("revolv") or n:find("pistol")
end

local function scanForGun()
    for _, child in ipairs(Workspace:GetChildren()) do
        if isGunTool(child) then tryEquipTool(child); return end
        if child:IsA("Model") then
            for _, v in ipairs(child:GetChildren()) do
                if isGunTool(v) then tryEquipTool(v); return end
            end
        end
    end
end

Workspace.ChildAdded:Connect(function(child)
    if not S.AutoGrabGun then return end
    task.wait(0.02)
    if isGunTool(child) then tryEquipTool(child); return end
    if child:IsA("Model") then
        for _, v in ipairs(child:GetChildren()) do
            if isGunTool(v) then tryEquipTool(v); return end
        end
    end
end)

-- Watch all sheriff players — as soon as their humanoid dies, scan for gun
local function watchSheriff(p)
    if p == LP then return end
    local function attachWatch(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        hum.Died:Connect(function()
            if getRole(p) == "Sheriff" and S.AutoGrabGun then
                for i = 1, 8 do
                    task.wait(0.05)
                    scanForGun()
                end
            end
        end)
    end
    if p.Character then task.spawn(attachWatch, p.Character) end
    p.CharacterAdded:Connect(function(c) task.spawn(attachWatch, c) end)
end

for _, p in ipairs(Players:GetPlayers()) do watchSheriff(p) end
Players.PlayerAdded:Connect(watchSheriff)

-- ============================================================
--  AUTO FARM COINS  (collect ALL coins through walls)
-- ============================================================
local CoinConn = nil

local function startCoinFarm()
    if CoinConn then CoinConn:Disconnect() end
    CoinConn = RunService.Heartbeat:Connect(function()
        if not S.AutoFarm then return end
        local r = Char and Char:FindFirstChild("HumanoidRootPart"); if not r then return end

        -- Collect every coin in workspace every frame pass
        local coins = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("MeshPart") or obj:IsA("Part") then
                local n = obj.Name:lower()
                if n:find("coin") or n:find("gold") or n:find("reward") then
                    table.insert(coins, obj)
                end
            end
        end

        for _, coin in ipairs(coins) do
            if not S.AutoFarm then break end
            if coin and coin.Parent then
                r.CFrame = CFrame.new(coin.Position + Vector3.new(0, 2, 0))
                task.wait(0.08)
            end
        end
    end)
end
startCoinFarm()

-- ============================================================
--  AIMBOT
-- ============================================================
local AimTarget = nil

local FovDraw = Drawing.new("Circle")
FovDraw.Visible=false; FovDraw.Thickness=1.5; FovDraw.Color=Color3.fromRGB(255,255,255)
FovDraw.Filled=false; FovDraw.NumSides=64

local function bestTarget()
    local ctr = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    local best, bd = nil, S.AimFOV
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local part = S.AimHead and (p.Character:FindFirstChild("Head")) or p.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local sp, vis = Cam:WorldToViewportPoint(part.Position)
                if vis then
                    local d = (ctr - Vector2.new(sp.X, sp.Y)).Magnitude
                    if d < bd then bd=d; best=p end
                end
            end
        end
    end
    return best
end

local function updateAimbot()
    FovDraw.Position = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    FovDraw.Radius   = S.AimFOV
    FovDraw.Visible  = S.ShowFOV and S.Aimbot

    if not S.Aimbot then AimTarget=nil return end

    local lockOn = (not UserInputService.KeyboardEnabled) and S.MobileAuto
        or UserInputService:IsKeyDown(Enum.KeyCode.Q)

    AimTarget = lockOn and bestTarget() or nil

    if AimTarget then
        local part = S.AimHead and (AimTarget.Character and AimTarget.Character:FindFirstChild("Head"))
            or (AimTarget.Character and AimTarget.Character:FindFirstChild("HumanoidRootPart"))
        if part then
            local smooth = 1/(S.AimSmooth*3+1)
            Cam.CFrame = Cam.CFrame:Lerp(CFrame.lookAt(Cam.CFrame.Position, part.Position), smooth)
        end
    end
end

-- ============================================================
--  PLAYER MODS
-- ============================================================
local _ncConn, _flyConn, _ijConn

local function setSpeed(v)  S.Speed=v; local h=Char and Char:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=v end end
local function setJump(v)   S.Jump=v;  local h=Char and Char:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower=v end end

local function setNoclip(en)
    S.Noclip=en
    if _ncConn then _ncConn:Disconnect() end
    if en then
        _ncConn = RunService.Stepped:Connect(function()
            if Char then
                for _, p in ipairs(Char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=false end
                end
            end
        end)
    end
end

local function setFly(en)
    S.Fly=en
    if _flyConn then _flyConn:Disconnect() end
    local r = Char and Char:FindFirstChild("HumanoidRootPart"); if not r then return end
    if en then
        local bv = Instance.new("BodyVelocity",r); bv.Name="_PBV"; bv.MaxForce=Vector3.new(1e9,1e9,1e9); bv.Velocity=Vector3.zero
        local bg = Instance.new("BodyGyro",r);     bg.Name="_PBG"; bg.MaxTorque=Vector3.new(1e9,1e9,1e9); bg.D=100
        _flyConn = RunService.Heartbeat:Connect(function()
            if not S.Fly then return end
            local d2=Vector3.zero; local sp=S.Speed*1.8
            local KE = UserInputService.IsKeyDown
            if UserInputService:IsKeyDown(Enum.KeyCode.W)           then d2=d2+Cam.CFrame.LookVector  end
            if UserInputService:IsKeyDown(Enum.KeyCode.S)           then d2=d2-Cam.CFrame.LookVector  end
            if UserInputService:IsKeyDown(Enum.KeyCode.A)           then d2=d2-Cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D)           then d2=d2+Cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then d2=d2+Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then d2=d2-Vector3.new(0,1,0) end
            bv.Velocity=d2*sp; bg.CFrame=Cam.CFrame
        end)
    else
        if r:FindFirstChild("_PBV") then r._PBV:Destroy() end
        if r:FindFirstChild("_PBG") then r._PBG:Destroy() end
    end
end

local function setIJ(en)
    S.InfJump=en
    if _ijConn then _ijConn:Disconnect() end
    if en then
        _ijConn = UserInputService.JumpRequest:Connect(function()
            local h=Char and Char:FindFirstChildOfClass("Humanoid")
            if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end

local function tpRole(roleName)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and getRole(p) == roleName then
            local r = Char and Char:FindFirstChild("HumanoidRootPart")
            local tr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            if r and tr then r.CFrame = tr.CFrame + Vector3.new(0,4,0) end
            return
        end
    end
end

-- ============================================================
--  VISUALS
-- ============================================================
local _origAmb = Lighting.Ambient; local _origBri = Lighting.Brightness

local function setFB(en)
    S.FullBright=en
    Lighting.Ambient=en and Color3.fromRGB(178,178,178) or _origAmb
    Lighting.Brightness=en and 2 or _origBri
    if en then Lighting.FogEnd=100000 end
end

local _CHLines = {}
local function buildCH()
    for _, l in ipairs(_CHLines) do pcall(function() l:Remove() end) end; _CHLines={}
    if not S.Crosshair then return end
    local cx,cy=Cam.ViewportSize.X/2,Cam.ViewportSize.Y/2
    for _, pts in ipairs({
        {Vector2.new(cx-14,cy),Vector2.new(cx-4,cy)},{Vector2.new(cx+4,cy),Vector2.new(cx+14,cy)},
        {Vector2.new(cx,cy-14),Vector2.new(cx,cy-4)},{Vector2.new(cx,cy+4),Vector2.new(cx,cy+14)},
    }) do
        local l=Drawing.new("Line"); l.From=pts[1]; l.To=pts[2]
        l.Color=Color3.fromRGB(255,255,255); l.Thickness=2; l.Visible=true
        table.insert(_CHLines,l)
    end
end

-- ============================================================
--  ANTI AFK
-- ============================================================
local VU = game:GetService("VirtualUser")
LP.Idled:Connect(function()
    if S.AntiAFK then VU:CaptureController(); VU:ClickButton2(Vector2.new()) end
end)

-- ============================================================
--  GUI  — Vertex-style layout
-- ============================================================
if CoreGui:FindFirstChild("PhantomGUI") then CoreGui.PhantomGUI:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name="PhantomGUI"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.DisplayOrder=999; SG.IgnoreGuiInset=true; SG.Parent=CoreGui

local IS_MOBILE = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local SC = IS_MOBILE and 1.25 or 1

-- Window dimensions matching screenshot proportions
local SIDE_W = math.floor(170 * SC)
local CONT_W = math.floor(310 * SC)
local WIN_H  = math.floor(380 * SC)
local WIN_W  = SIDE_W + CONT_W
local ROW_H  = math.floor(50 * SC)
local FS     = IS_MOBILE and 14 or 13
local FS_SM  = IS_MOBILE and 12 or 11

-- Colour palette matching screenshot
local C = {
    WIN_BG   = Color3.fromRGB(30,  30,  32),   -- sidebar bg
    CONT_BG  = Color3.fromRGB(38,  38,  42),   -- content bg
    NAV_ACT  = Color3.fromRGB(50,  50,  56),   -- active nav item
    NAV_HV   = Color3.fromRGB(42,  42,  48),
    SEP      = Color3.fromRGB(58,  58,  65),   -- separator lines
    TOG_OFF  = Color3.fromRGB(88,  88,  95),   -- toggle off
    TOG_ON   = Color3.fromRGB(255,255,255),    -- toggle on (white)
    TXT      = Color3.fromRGB(235,235,240),    -- primary text
    TXT2     = Color3.fromRGB(140,140,152),    -- secondary / dim
    LOCK     = Color3.fromRGB(130,130,140),
    RED      = Color3.fromRGB(255, 70,  70),
    GREEN    = Color3.fromRGB(60,  210, 100),
    BLUE     = Color3.fromRGB(90,  140, 255),
    YELLOW   = Color3.fromRGB(255, 200, 50),
}

-- ── WINDOW ────────────────────────────────────────────────
local Win = Instance.new("Frame")
Win.Name="Win"; Win.Size=UDim2.new(0,WIN_W,0,WIN_H)
Win.Position=UDim2.new(0.5,-WIN_W/2,0.5,-WIN_H/2)
Win.BackgroundColor3=C.WIN_BG; Win.BorderSizePixel=0; Win.Visible=false; Win.Parent=SG
Instance.new("UICorner",Win).CornerRadius=UDim.new(0,12)

-- ── LEFT SIDEBAR ──────────────────────────────────────────
local Sidebar=Instance.new("Frame")
Sidebar.Name="Sidebar"; Sidebar.Size=UDim2.new(0,SIDE_W,1,0)
Sidebar.BackgroundColor3=C.WIN_BG; Sidebar.BorderSizePixel=0; Sidebar.Parent=Win
Instance.new("UICorner",Sidebar).CornerRadius=UDim.new(0,12)
-- fill the gap between sidebar and right panel
local SBFill=Instance.new("Frame")
SBFill.Size=UDim2.new(0,16,1,0); SBFill.Position=UDim2.new(1,-16,0,0)
SBFill.BackgroundColor3=C.WIN_BG; SBFill.BorderSizePixel=0; SBFill.Parent=Sidebar

-- Sidebar header
local SBHead=Instance.new("Frame")
SBHead.Size=UDim2.new(1,0,0,math.floor(70*SC)); SBHead.BackgroundTransparency=1; SBHead.Parent=Sidebar

local NameLbl=Instance.new("TextLabel")
NameLbl.Size=UDim2.new(1,-44,0,24); NameLbl.Position=UDim2.new(0,14,0,14)
NameLbl.BackgroundTransparency=1; NameLbl.Text="Phantom"
NameLbl.TextColor3=C.TXT; NameLbl.TextSize=IS_MOBILE and 17 or 16; NameLbl.Font=Enum.Font.GothamBold
NameLbl.TextXAlignment=Enum.TextXAlignment.Left; NameLbl.Parent=SBHead

local SubLbl=Instance.new("TextLabel")
SubLbl.Size=UDim2.new(1,-14,0,16); SubLbl.Position=UDim2.new(0,14,0,36)
SubLbl.BackgroundTransparency=1; SubLbl.Text="mm2.phantom"
SubLbl.TextColor3=C.TXT2; SubLbl.TextSize=FS_SM; SubLbl.Font=Enum.Font.Gotham
SubLbl.TextXAlignment=Enum.TextXAlignment.Left; SubLbl.Parent=SBHead

-- Sidebar nav container
local NavFrame=Instance.new("Frame")
NavFrame.Size=UDim2.new(1,-8,1,-math.floor(130*SC))
NavFrame.Position=UDim2.new(0,4,0,math.floor(72*SC))
NavFrame.BackgroundTransparency=1; NavFrame.Parent=Sidebar
local NavList=Instance.new("UIListLayout",NavFrame)
NavList.Padding=UDim.new(0,2); NavList.SortOrder=Enum.SortOrder.LayoutOrder

-- Sidebar bottom user info
local UserRow=Instance.new("Frame")
UserRow.Size=UDim2.new(1,0,0,math.floor(52*SC)); UserRow.AnchorPoint=Vector2.new(0,1)
UserRow.Position=UDim2.new(0,0,1,0); UserRow.BackgroundTransparency=1; UserRow.Parent=Sidebar

local UAv=Instance.new("Frame")
UAv.Size=UDim2.new(0,34,0,34); UAv.Position=UDim2.new(0,10,0.5,-17)
UAv.BackgroundColor3=Color3.fromRGB(60,60,70); UAv.BorderSizePixel=0; UAv.Parent=UserRow
Instance.new("UICorner",UAv).CornerRadius=UDim.new(1,0)
local UAvLbl=Instance.new("TextLabel",UAv)
UAvLbl.Size=UDim2.new(1,0,1,0); UAvLbl.BackgroundTransparency=1
UAvLbl.Text=string.sub(LP.Name,1,1):upper(); UAvLbl.TextColor3=C.TXT
UAvLbl.TextSize=14; UAvLbl.Font=Enum.Font.GothamBold

local UName=Instance.new("TextLabel")
UName.Size=UDim2.new(1,-54,0,18); UName.Position=UDim2.new(0,50,0,8)
UName.BackgroundTransparency=1; UName.Text=string.sub(LP.Name,1,12)..(#LP.Name>12 and "..." or "")
UName.TextColor3=C.TXT; UName.TextSize=FS; UName.Font=Enum.Font.GothamSemibold
UName.TextXAlignment=Enum.TextXAlignment.Left; UName.Parent=UserRow

local UAt=Instance.new("TextLabel")
UAt.Size=UDim2.new(1,-54,0,14); UAt.Position=UDim2.new(0,50,0,26)
UAt.BackgroundTransparency=1; UAt.Text="@"..string.sub(LP.Name,1,10):lower()
UAt.TextColor3=C.TXT2; UAt.TextSize=FS_SM; UAt.Font=Enum.Font.Gotham
UAt.TextXAlignment=Enum.TextXAlignment.Left; UAt.Parent=UserRow

-- ── RIGHT CONTENT ─────────────────────────────────────────
local ContPanel=Instance.new("Frame")
ContPanel.Size=UDim2.new(1,-SIDE_W,1,0); ContPanel.Position=UDim2.new(0,SIDE_W,0,0)
ContPanel.BackgroundColor3=C.CONT_BG; ContPanel.BorderSizePixel=0; ContPanel.Parent=Win
Instance.new("UICorner",ContPanel).CornerRadius=UDim.new(0,12)

-- fix left rounded corner (joins with sidebar)
local CPFix=Instance.new("Frame")
CPFix.Size=UDim2.new(0,14,1,0); CPFix.BackgroundColor3=C.CONT_BG; CPFix.BorderSizePixel=0; CPFix.Parent=ContPanel

-- Content header
local ContHead=Instance.new("Frame")
ContHead.Size=UDim2.new(1,0,0,math.floor(46*SC)); ContHead.BackgroundTransparency=1; ContHead.Parent=ContPanel

local TabTitleLbl=Instance.new("TextLabel")
TabTitleLbl.Size=UDim2.new(1,-50,1,0); TabTitleLbl.Position=UDim2.new(0,16,0,0)
TabTitleLbl.BackgroundTransparency=1; TabTitleLbl.Text="Main"
TabTitleLbl.TextColor3=C.TXT; TabTitleLbl.TextSize=FS+1; TabTitleLbl.Font=Enum.Font.GothamBold
TabTitleLbl.TextXAlignment=Enum.TextXAlignment.Left; TabTitleLbl.Parent=ContHead

-- Drag icon (cosmetic)
local DragIco=Instance.new("TextLabel")
DragIco.Size=UDim2.new(0,28,1,0); DragIco.AnchorPoint=Vector2.new(1,0)
DragIco.Position=UDim2.new(1,-12,0,0); DragIco.BackgroundTransparency=1
DragIco.Text="+"; DragIco.TextColor3=C.TXT2; DragIco.TextSize=18; DragIco.Font=Enum.Font.GothamBold
DragIco.TextXAlignment=Enum.TextXAlignment.Right; DragIco.Parent=ContHead

-- Header separator
local HeadSep=Instance.new("Frame")
HeadSep.Size=UDim2.new(1,-16,0,1); HeadSep.Position=UDim2.new(0,8,0,math.floor(46*SC)-1)
HeadSep.BackgroundColor3=C.SEP; HeadSep.BorderSizePixel=0; HeadSep.Parent=ContPanel

-- Scroll container
local Scroll=Instance.new("ScrollingFrame")
Scroll.Size=UDim2.new(1,0,1,-math.floor(50*SC))
Scroll.Position=UDim2.new(0,0,0,math.floor(50*SC))
Scroll.BackgroundTransparency=1; Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=IS_MOBILE and 3 or 2
Scroll.ScrollBarImageColor3=C.TXT2; Scroll.CanvasSize=UDim2.new(0,0,0,0)
Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; Scroll.Parent=ContPanel

-- Page frames inside scroll
local Pages = {}
local function mkPage(name)
    local pg=Instance.new("Frame")
    pg.Name=name; pg.Size=UDim2.new(1,0,0,0)
    pg.AutomaticSize=Enum.AutomaticSize.Y
    pg.BackgroundTransparency=1; pg.Visible=false; pg.Parent=Scroll
    local lay=Instance.new("UIListLayout",pg)
    lay.Padding=UDim.new(0,0); lay.SortOrder=Enum.SortOrder.LayoutOrder
    Pages[name]=pg
    return pg
end

-- ── DRAG WINDOW ───────────────────────────────────────────
local _drg,_drgS,_drgP=false,nil,nil
ContHead.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        _drg=true; _drgS=i.Position; _drgP=Win.Position
    end
end)
ContHead.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then _drg=false end
end)
UserInputService.InputChanged:Connect(function(i)
    if _drg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-_drgS
        Win.Position=UDim2.new(_drgP.X.Scale,_drgP.X.Offset+d.X,_drgP.Y.Scale,_drgP.Y.Offset+d.Y)
    end
end)

-- ── NAV + TABS ────────────────────────────────────────────
local NavBtns = {}
local ActivePage = nil

local NAV_ICONS = {
    Main    = "  *",
    Combat  = "  o",
    ESP     = "  #",
    Player  = "  >",
    Settings= "  =",
}

local NAV_DEFS = {
    {key="Main",     label="Main"},
    {key="Combat",   label="Combat"},
    {key="ESP",      label="ESP"},
    {key="Player",   label="Player"},
    {key="Settings", label="Settings"},
}

local function switchTab(key)
    ActivePage = key
    TabTitleLbl.Text = key
    for k, data in pairs(NavBtns) do
        local on = k == key
        TweenService:Create(data.Btn, TweenInfo.new(0.12), {
            BackgroundColor3 = on and C.NAV_ACT or C.WIN_BG,
            BackgroundTransparency = on and 0 or 1,
        }):Play()
        data.Lbl.TextColor3 = on and C.TXT or C.TXT2
        data.Ico.TextColor3 = on and C.TXT or C.TXT2
    end
    for name, pg in pairs(Pages) do
        pg.Visible = name == key
    end
end

for i, def in ipairs(NAV_DEFS) do
    mkPage(def.key)

    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(1,-8,0,math.floor(38*SC)); btn.Position=UDim2.new(0,4,0,0)
    btn.BackgroundColor3=C.WIN_BG; btn.BackgroundTransparency=1
    btn.Text=""; btn.BorderSizePixel=0; btn.LayoutOrder=i; btn.Parent=NavFrame
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,8)

    local ico=Instance.new("TextLabel",btn)
    ico.Size=UDim2.new(0,24,1,0); ico.Position=UDim2.new(0,8,0,0)
    ico.BackgroundTransparency=1; ico.Text="+"
    ico.TextColor3=C.TXT2; ico.TextSize=IS_MOBILE and 16 or 14; ico.Font=Enum.Font.GothamBold
    ico.TextXAlignment=Enum.TextXAlignment.Center

    local lbl=Instance.new("TextLabel",btn)
    lbl.Size=UDim2.new(1,-36,1,0); lbl.Position=UDim2.new(0,34,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=def.label
    lbl.TextColor3=C.TXT2; lbl.TextSize=FS; lbl.Font=Enum.Font.GothamSemibold
    lbl.TextXAlignment=Enum.TextXAlignment.Left

    NavBtns[def.key] = {Btn=btn, Lbl=lbl, Ico=ico}
    btn.MouseButton1Click:Connect(function() switchTab(def.key) end)
end

-- ── ROW WIDGETS ───────────────────────────────────────────

local function addSeparator(page)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,-32,0,1); f.BackgroundColor3=C.SEP; f.BorderSizePixel=0
    local p=Instance.new("UIPadding",f)
    p.PaddingLeft=UDim.new(0,16)
    local wrap=Instance.new("Frame")
    wrap.Size=UDim2.new(1,0,0,1); wrap.BackgroundTransparency=1; wrap.Parent=page
    f.Size=UDim2.new(1,-32,0,1); f.Position=UDim2.new(0,16,0,0); f.Parent=wrap
end

-- Toggle row  (locked=true -> greyed out, not clickable)
local function addToggle(page, label, getter, setter, locked)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,ROW_H); row.BackgroundTransparency=1; row.Parent=page

    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-80,1,0); lbl.Position=UDim2.new(0,16,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label
    lbl.TextColor3=locked and C.TXT2 or C.TXT; lbl.TextSize=FS
    lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left

    -- Lock icon
    if locked then
        local lockIco=Instance.new("TextLabel",row)
        lockIco.Size=UDim2.new(0,20,1,0); lockIco.AnchorPoint=Vector2.new(1,0.5)
        lockIco.Position=UDim2.new(1,-52,0.5,0); lockIco.BackgroundTransparency=1
        lockIco.Text="[L]"; lockIco.TextColor3=C.LOCK; lockIco.TextSize=FS_SM; lockIco.Font=Enum.Font.Gotham
    end

    local TW=IS_MOBILE and 46 or 40; local TH=IS_MOBILE and 26 or 22
    local pill=Instance.new("TextButton",row)
    pill.Size=UDim2.new(0,TW,0,TH); pill.AnchorPoint=Vector2.new(1,0.5)
    pill.Position=UDim2.new(1,-14,0.5,0); pill.Text=""; pill.BorderSizePixel=0
    pill.BackgroundColor3=(not locked and getter()) and C.TOG_ON or C.TOG_OFF
    pill.AutoButtonColor=false
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)

    local KS=TH-4
    local knob=Instance.new("Frame",pill)
    knob.Size=UDim2.new(0,KS,0,KS); knob.AnchorPoint=Vector2.new(0,0.5)
    knob.Position=(not locked and getter()) and UDim2.new(1,-(KS+2),0.5,0) or UDim2.new(0,2,0.5,0)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    if not locked then
        pill.MouseButton1Click:Connect(function()
            local v=not getter(); setter(v)
            TweenService:Create(pill,TweenInfo.new(0.15),{BackgroundColor3=v and C.TOG_ON or C.TOG_OFF}):Play()
            TweenService:Create(knob,TweenInfo.new(0.15),{Position=v and UDim2.new(1,-(KS+2),0.5,0) or UDim2.new(0,2,0.5,0)}):Play()
        end)
    else
        pill.BackgroundColor3=Color3.fromRGB(60,60,65)
    end
end

-- Chevron button row
local function addButton(page, label, callback, locked)
    local row=Instance.new("TextButton")
    row.Size=UDim2.new(1,0,0,ROW_H); row.BackgroundTransparency=1
    row.Text=""; row.BorderSizePixel=0; row.AutoButtonColor=false; row.Parent=page

    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-40,1,0); lbl.Position=UDim2.new(0,16,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=label
    lbl.TextColor3=locked and C.TXT2 or C.TXT; lbl.TextSize=FS
    lbl.Font=Enum.Font.Gotham; lbl.TextXAlignment=Enum.TextXAlignment.Left

    local chev=Instance.new("TextLabel",row)
    chev.Size=UDim2.new(0,24,1,0); chev.AnchorPoint=Vector2.new(1,0.5)
    chev.Position=UDim2.new(1,-12,0.5,0); chev.BackgroundTransparency=1
    chev.Text=">"; chev.TextColor3=C.TXT2; chev.TextSize=FS+2; chev.Font=Enum.Font.GothamBold
    chev.TextXAlignment=Enum.TextXAlignment.Right

    if not locked then
        row.MouseButton1Click:Connect(function()
            TweenService:Create(row,TweenInfo.new(0.08),{BackgroundTransparency=0.9}):Play()
            task.delay(0.15,function() TweenService:Create(row,TweenInfo.new(0.08),{BackgroundTransparency=1}):Play() end)
            callback()
        end)
    end
end

-- Slider row
local function addSlider(page, label, min, max, getter, setter)
    local rowH = math.floor(58*SC)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,rowH); row.BackgroundTransparency=1; row.Parent=page

    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-60,0,22); lbl.Position=UDim2.new(0,16,0,8)
    lbl.BackgroundTransparency=1; lbl.Text=label
    lbl.TextColor3=C.TXT; lbl.TextSize=FS; lbl.Font=Enum.Font.Gotham
    lbl.TextXAlignment=Enum.TextXAlignment.Left

    local val=Instance.new("TextLabel",row)
    val.Size=UDim2.new(0,44,0,22); val.AnchorPoint=Vector2.new(1,0)
    val.Position=UDim2.new(1,-16,0,8); val.BackgroundTransparency=1
    val.Text=tostring(getter()); val.TextColor3=C.TXT2; val.TextSize=FS; val.Font=Enum.Font.GothamBold
    val.TextXAlignment=Enum.TextXAlignment.Right

    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(1,-32,0,IS_MOBILE and 8 or 6)
    track.Position=UDim2.new(0,16,0,rowH-math.floor(18*SC))
    track.BackgroundColor3=C.TOG_OFF; track.BorderSizePixel=0
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local pct=(getter()-min)/(max-min)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=C.TOG_ON; fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local dragging=false
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local p2=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            local v=math.floor(min+(max-min)*p2); setter(v)
            fill.Size=UDim2.new(p2,0,1,0); val.Text=tostring(v)
        end
    end)
end

-- Section label (small grey text)
local function addSection(page, label)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,math.floor(28*SC)); f.BackgroundTransparency=1; f.Parent=page
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,-32,1,0); l.Position=UDim2.new(0,16,0,0)
    l.BackgroundTransparency=1; l.Text=label
    l.TextColor3=C.TXT2; l.TextSize=FS_SM-1; l.Font=Enum.Font.GothamBold
    l.TextXAlignment=Enum.TextXAlignment.Left
end

-- ── POPULATE PAGES ────────────────────────────────────────

-- MAIN
do local p=Pages["Main"]
    addToggle(p,"Auto Farm Coins",    function() return S.AutoFarm    end, function(v) S.AutoFarm=v end)
    addSeparator(p)
    addToggle(p,"Automatically Grab Gun",function() return S.AutoGrabGun end,function(v) S.AutoGrabGun=v if v then scanForGun() end end)
    addSeparator(p)
    addToggle(p,"Dodge Thrown Knife", function() return false end, function() end, true)  -- locked
    addToggle(p,"Anti AFK",           function() return S.AntiAFK     end, function(v) S.AntiAFK=v end)
    addSeparator(p)
    addButton(p,"Teleport To Lobby",  function()
        local tp=ReplicatedStorage:FindFirstChild("Teleport") or ReplicatedStorage:FindFirstChild("LobbyTp")
        if tp and tp:IsA("RemoteEvent") then pcall(function() tp:FireServer() end) end
        -- fallback: find lobby spawn and teleport
        local spawn=Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Lobby")
        if spawn then
            local r=Char and Char:FindFirstChild("HumanoidRootPart")
            if r then r.CFrame=spawn.CFrame+Vector3.new(0,5,0) end
        end
    end)
    addButton(p,"Teleport To Map",    function()
        local r=Char and Char:FindFirstChild("HumanoidRootPart")
        if r then r.CFrame=CFrame.new(0,50,0) end
    end)
end

-- COMBAT
do local p=Pages["Combat"]
    addToggle(p,"Enable Aimbot",      function() return S.Aimbot    end, function(v) S.Aimbot=v end)
    addToggle(p,"Head Priority",      function() return S.AimHead   end, function(v) S.AimHead=v end)
    addToggle(p,"Show FOV Circle",    function() return S.ShowFOV   end, function(v) S.ShowFOV=v end)
    if not UserInputService.KeyboardEnabled then
        addToggle(p,"Auto Lock (Mobile)", function() return S.MobileAuto end, function(v) S.MobileAuto=v end)
    end
    addSeparator(p)
    addSlider(p,"FOV Radius", 30, 400, function() return S.AimFOV end,    function(v) S.AimFOV=v end)
    addSlider(p,"Smoothness", 1, 10,   function() return S.AimSmooth end,  function(v) S.AimSmooth=v end)
    addSeparator(p)
    addButton(p,"Teleport To Murderer", function() tpRole("Murder")  end)
    addButton(p,"Teleport To Sheriff",  function() tpRole("Sheriff") end)
end

-- ESP
do local p=Pages["ESP"]
    addToggle(p,"Enable ESP",         function() return S.ESP       end, function(v) S.ESP=v end)
    addToggle(p,"Show Names",         function() return S.ShowNames end, function(v) S.ShowNames=v end)
    addToggle(p,"Show Distance",      function() return S.ShowDist  end, function(v) S.ShowDist=v end)
    addSeparator(p)
    addToggle(p,"Show Roles (Always On)",function() return S.ShowRoles end, function(v)
        S.ShowRoles=v
        if v then refreshBillboards() end
        -- toggle visibility on existing billboards
        for _, bb in pairs(Billboards) do
            bb.Enabled = v
        end
    end)
    addSeparator(p)
    addToggle(p,"Full Bright",        function() return S.FullBright end, function(v) setFB(v) end)
    addToggle(p,"Remove Fog",         function() return S.NoFog      end, function(v) S.NoFog=v if v then Lighting.FogEnd=100000 end end)
    addToggle(p,"Custom Crosshair",   function() return S.Crosshair  end, function(v) S.Crosshair=v buildCH() end)
end

-- PLAYER
do local p=Pages["Player"]
    addToggle(p,"Infinite Jump",      function() return S.InfJump end, function(v) setIJ(v) end)
    addToggle(p,"Noclip",             function() return S.Noclip  end, function(v) setNoclip(v) end)
    addToggle(p,"Fly Mode",           function() return S.Fly     end, function(v) setFly(v) end)
    addSeparator(p)
    addSlider(p,"Walk Speed", 8, 100, function() return S.Speed end, function(v) setSpeed(v) end)
    addSlider(p,"Jump Power", 10,200, function() return S.Jump  end, function(v) setJump(v) end)
    addButton(p,"Reset Speed & Jump", function()
        setSpeed(16); setJump(50)
    end)
end

-- SETTINGS
do local p=Pages["Settings"]
    addSection(p,"Appearance")
    addToggle(p,"Anti AFK",          function() return S.AntiAFK end, function(v) S.AntiAFK=v end)
    addSeparator(p)
    addToggle(p,"Webhook Logging",   function() return false end, function() end, true)  -- locked
    addToggle(p,"Auto End Round",    function() return false end, function() end, true)  -- locked
    addSeparator(p)
    addButton(p,"Print All Roles",   function()
        local out=""
        for _, pl in ipairs(Players:GetPlayers()) do
            out=out..pl.Name.." : "..getRole(pl).."\n"
        end
        warn("[Phantom]\n"..out)
    end)
    addButton(p,"Scan Gun Now",      function() scanForGun() end)
end

-- ── FLOATING OPEN BUTTON ──────────────────────────────────
local FBSize = IS_MOBILE and 58 or 48
local FB=Instance.new("TextButton")
FB.Size=UDim2.new(0,FBSize,0,FBSize); FB.Position=UDim2.new(0,10,0.5,-FBSize/2)
FB.BackgroundColor3=C.WIN_BG; FB.Text="P"; FB.TextSize=IS_MOBILE and 18 or 16
FB.TextColor3=C.TXT; FB.Font=Enum.Font.GothamBold; FB.BorderSizePixel=0; FB.ZIndex=10; FB.Parent=SG
Instance.new("UICorner",FB).CornerRadius=UDim.new(0,10)
local FBStroke=Instance.new("UIStroke",FB); FBStroke.Color=C.SEP; FBStroke.Thickness=1.5

-- drag FB
local _fbd,_fbS,_fbP=false,nil,nil
FB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        _fbd=true; _fbS=i.Position; _fbP=FB.Position
    end
end)
FB.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then _fbd=false end
end)
UserInputService.InputChanged:Connect(function(i)
    if _fbd and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-_fbS
        FB.Position=UDim2.new(_fbP.X.Scale,_fbP.X.Offset+d.X,_fbP.Y.Scale,_fbP.Y.Offset+d.Y)
    end
end)
FB.MouseButton1Click:Connect(function() Win.Visible=not Win.Visible end)

-- Keyboard
UserInputService.InputBegan:Connect(function(i,proc)
    if proc then return end
    if i.KeyCode==Enum.KeyCode.Insert or i.KeyCode==Enum.KeyCode.RightShift then
        Win.Visible=not Win.Visible
    end
end)

-- ── INIT ──────────────────────────────────────────────────
switchTab("Main")

LP.CharacterAdded:Connect(function(c)
    Char=c; task.wait(0.5)
    setSpeed(S.Speed); setJump(S.Jump)
    if S.Noclip  then setNoclip(true) end
    if S.Fly     then setFly(true)    end
    if S.InfJump then setIJ(true)     end
end)

-- Main render loop
RunService.RenderStepped:Connect(function()
    updateESP()
    updateAimbot()
    if S.NoFog then Lighting.FogEnd=100000 end
end)

warn("[Phantom] Loaded  |  Press the [P] button or Insert / RightShift")

-- ================================================
--   Phantom  |  Murder Mystery 2
--   github.com/your-username/phantom-mm2
-- ================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Workspace        = game:GetService("Workspace")
local Lighting         = game:GetService("Lighting")
local CoreGui          = game:GetService("CoreGui")
local ReplicatedStorage= game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Character   = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera      = Workspace.CurrentCamera
local IsMobile    = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ================================================
--  CONFIG
-- ================================================
local Cfg = {
    ESP    = { On=false, Names=true, Dist=true, Role=true,
               ColI=Color3.fromRGB(0,200,255), ColM=Color3.fromRGB(255,50,50), ColS=Color3.fromRGB(50,255,100) },
    Aimbot = { On=false, FOV=120, Smooth=0.25, ShowFOV=true, HeadOnly=true, MobileAuto=false },
    Player = { Speed=16, Jump=50, Noclip=false, Fly=false, InfJump=false },
    Visual = { FullBright=false, NoFog=false, Crosshair=false },
    Misc   = { Coins=false, AntiAFK=true, AutoGun=false, ChatSpam=false,
               ChatMsg="Phantom MM2 | github.com/your-username" },
}

-- ================================================
--  UTILS
-- ================================================
local function root(p)  local c=p.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function hum(p)   local c=p.Character return c and c:FindFirstChildOfClass("Humanoid")  end
local function head(p)  local c=p.Character return c and c:FindFirstChild("Head")             end
local function dist(pt) local r=root(LocalPlayer) return (r and pt) and (r.Position-pt.Position).Magnitude or math.huge end

local function role(p)
    if p==LocalPlayer then return "Self" end
    local c=p.Character if not c then return "?" end
    local t=c:FindFirstChildOfClass("Tool")
    if t then
        local n=t.Name:lower()
        if n:find("knife") or n:find("shard") or n:find("dagger") then return "Murder"  end
        if n:find("gun")   or n:find("sheriff")or n:find("revolv") then return "Sheriff" end
    end
    return "Innocent"
end

-- ================================================
--  AUTO GRAB GUN
-- ================================================
local function isGun(obj)
    if not obj:IsA("Tool") then return false end
    local n=obj.Name:lower()
    return n:find("gun") or n:find("sheriff") or n:find("revolv")
end
local function grabGun(gun)
    local r=root(LocalPlayer) if not r then return end
    local pos=Vector3.zero
    for _,p in ipairs(gun:GetDescendants()) do if p:IsA("BasePart") then pos=p.Position break end end
    r.CFrame=CFrame.new(pos+Vector3.new(0,3,0))
    for _,rem in ipairs(ReplicatedStorage:GetDescendants()) do
        if rem:IsA("RemoteEvent") then
            local n=rem.Name:lower()
            if n:find("equip") or n:find("pickup") or n:find("grab") then
                pcall(function() rem:FireServer(gun) end)
            end
        end
    end
end
local function scanGuns()
    for _,c in ipairs(Workspace:GetChildren()) do
        if isGun(c) then grabGun(c) return end
        if c:IsA("Model") then for _,v in ipairs(c:GetChildren()) do if isGun(v) then grabGun(v) return end end end
    end
end
Workspace.ChildAdded:Connect(function(c)
    if not Cfg.Misc.AutoGun then return end
    task.wait(0.05)
    if isGun(c) then grabGun(c) return end
    if c:IsA("Model") then for _,v in ipairs(c:GetChildren()) do if isGun(v) then grabGun(v) return end end end
end)

-- ================================================
--  ESP
-- ================================================
local ESPObj={}
local function mkESP(p)
    if p==LocalPlayer then return end
    local d={}
    local b=Drawing.new("Square"); b.Visible=false; b.Thickness=1.5; b.Filled=false; d.B=b
    local l=Drawing.new("Text");   l.Visible=false; l.Size=13; l.Outline=true; l.Center=true; d.L=l
    local t=Drawing.new("Line");   t.Visible=false; t.Thickness=1; d.T=t
    ESPObj[p]=d
end
local function rmESP(p)
    local o=ESPObj[p] if not o then return end
    if o.B then o.B:Remove() end if o.L then o.L:Remove() end if o.T then o.T:Remove() end
    ESPObj[p]=nil
end
local function updESP()
    for p,o in pairs(ESPObj) do
        local r2=root(p) local h=head(p)
        if not Cfg.ESP.On or not r2 or not h then
            o.B.Visible=false o.L.Visible=false o.T.Visible=false
        else
            local ro=role(p)
            local col=ro=="Murder" and Cfg.ESP.ColM or ro=="Sheriff" and Cfg.ESP.ColS or Cfg.ESP.ColI
            local hp,hv=Camera:WorldToViewportPoint(h.Position)
            local rp=Camera:WorldToViewportPoint(r2.Position)
            if hv then
                local ht=math.abs(hp.Y-rp.Y) local w=ht*0.5
                o.B.Visible=true; o.B.Color=col; o.B.Position=Vector2.new(hp.X-w/2,hp.Y); o.B.Size=Vector2.new(w,ht)
                local parts={}
                if Cfg.ESP.Names then table.insert(parts,p.Name) end
                if Cfg.ESP.Role  then table.insert(parts,"["..ro.."]") end
                if Cfg.ESP.Dist  then table.insert(parts,math.floor(dist(r2)).."m") end
                o.L.Visible=true; o.L.Color=col; o.L.Position=Vector2.new(hp.X,hp.Y-18); o.L.Text=table.concat(parts," | ")
                o.T.Visible=true; o.T.Color=col; o.T.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y); o.T.To=Vector2.new(hp.X,hp.Y)
            else o.B.Visible=false o.L.Visible=false o.T.Visible=false end
        end
    end
end

-- ================================================
--  AIMBOT
-- ================================================
local AimTarget=nil
local FovCirc=Drawing.new("Circle"); FovCirc.Visible=false; FovCirc.Thickness=1.5; FovCirc.Color=Color3.fromRGB(255,255,255); FovCirc.Filled=false; FovCirc.NumSides=64

local function nearestPlayer()
    local ctr=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    local best,bd=nil,Cfg.Aimbot.FOV
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and p.Character then
            local pt=Cfg.Aimbot.HeadOnly and head(p) or root(p)
            if pt then
                local sp,vis=Camera:WorldToViewportPoint(pt.Position)
                if vis then local d2=(ctr-Vector2.new(sp.X,sp.Y)).Magnitude if d2<bd then bd=d2 best=p end end
            end
        end
    end
    return best
end
local function updAimbot()
    FovCirc.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    FovCirc.Radius=Cfg.Aimbot.FOV; FovCirc.Visible=Cfg.Aimbot.ShowFOV and Cfg.Aimbot.On
    if not Cfg.Aimbot.On then AimTarget=nil return end
    local aim=IsMobile and Cfg.Aimbot.MobileAuto or UserInputService:IsKeyDown(Enum.KeyCode.Q)
    AimTarget=aim and nearestPlayer() or (not IsMobile and nil or AimTarget)
    if AimTarget then
        local pt=Cfg.Aimbot.HeadOnly and head(AimTarget) or root(AimTarget)
        if pt then Camera.CFrame=Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position,pt.Position),Cfg.Aimbot.Smooth) end
    end
end

-- ================================================
--  PLAYER MODS
-- ================================================
local ncConn,flyConn,ijConn
local function spd(v) local h2=hum(LocalPlayer) if h2 then h2.WalkSpeed=v end end
local function jmp(v) local h2=hum(LocalPlayer) if h2 then h2.JumpPower=v end end
local function setNC(en)
    Cfg.Player.Noclip=en
    if ncConn then ncConn:Disconnect() end
    if en then ncConn=RunService.Stepped:Connect(function()
        local c=LocalPlayer.Character
        if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
    end) end
end
local function setFly(en)
    Cfg.Player.Fly=en
    if flyConn then flyConn:Disconnect() end
    local r2=root(LocalPlayer) if not r2 then return end
    if en then
        local bv=Instance.new("BodyVelocity",r2); bv.Name="_PBV"; bv.MaxForce=Vector3.new(1e9,1e9,1e9); bv.Velocity=Vector3.zero
        local bg=Instance.new("BodyGyro",r2);     bg.Name="_PBG"; bg.MaxTorque=Vector3.new(1e9,1e9,1e9); bg.D=100
        flyConn=RunService.Heartbeat:Connect(function()
            if not Cfg.Player.Fly then return end
            local d2=Vector3.zero; local s2=Cfg.Player.Speed*1.8
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then d2=d2+Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then d2=d2-Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then d2=d2-Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then d2=d2+Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d2=d2+Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then d2=d2-Vector3.new(0,1,0) end
            bv.Velocity=d2*s2; bg.CFrame=Camera.CFrame
        end)
    else
        if r2:FindFirstChild("_PBV") then r2._PBV:Destroy() end
        if r2:FindFirstChild("_PBG") then r2._PBG:Destroy() end
    end
end
local function setIJ(en)
    Cfg.Player.InfJump=en
    if ijConn then ijConn:Disconnect() end
    if en then ijConn=UserInputService.JumpRequest:Connect(function()
        local h2=hum(LocalPlayer) if h2 then h2:ChangeState(Enum.HumanoidStateType.Jumping) end
    end) end
end
local function tpRole(r3)
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LocalPlayer and role(p)==r3 then
            local r4=root(LocalPlayer) local r5=root(p)
            if r4 and r5 then r4.CFrame=r5.CFrame+Vector3.new(0,4,0) end return
        end
    end
end

-- ================================================
--  VISUALS
-- ================================================
local oAmb=Lighting.Ambient; local oBri=Lighting.Brightness
local function setFB(en)
    Cfg.Visual.FullBright=en
    Lighting.Ambient=en and Color3.fromRGB(178,178,178) or oAmb
    Lighting.Brightness=en and 2 or oBri
    if en then Lighting.FogEnd=100000 end
end
local CHLines={}
local function mkCH()
    for _,l in ipairs(CHLines) do l:Remove() end CHLines={}
    if not Cfg.Visual.Crosshair then return end
    local cx,cy=Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2
    for _,pts in ipairs({
        {Vector2.new(cx-14,cy),Vector2.new(cx-5,cy)},{Vector2.new(cx+5,cy),Vector2.new(cx+14,cy)},
        {Vector2.new(cx,cy-14),Vector2.new(cx,cy-5)},{Vector2.new(cx,cy+5),Vector2.new(cx,cy+14)},
    }) do
        local l=Drawing.new("Line"); l.From=pts[1]; l.To=pts[2]; l.Color=Color3.fromRGB(255,255,255); l.Thickness=2; l.Visible=true
        table.insert(CHLines,l)
    end
end

-- ================================================
--  ANTI AFK
-- ================================================
do local VU=game:GetService("VirtualUser")
   LocalPlayer.Idled:Connect(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end) end

-- ================================================
--  AUTO COIN
-- ================================================
RunService.Heartbeat:Connect(function()
    if not Cfg.Misc.Coins then return end
    local r2=root(LocalPlayer) if not r2 then return end
    for _,o in ipairs(Workspace:GetDescendants()) do
        if (o:IsA("BasePart") or o:IsA("MeshPart")) and o.Name:lower():find("coin") then
            if (r2.Position-o.Position).Magnitude<50 then r2.CFrame=CFrame.new(o.Position) break end
        end
    end
end)

-- ================================================
--  GUI — Phantom Style
-- ================================================
if CoreGui:FindFirstChild("PhantomGUI") then CoreGui.PhantomGUI:Destroy() end

local SG = Instance.new("ScreenGui")
SG.Name="PhantomGUI"; SG.ResetOnSpawn=false; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.DisplayOrder=999; SG.IgnoreGuiInset=true; SG.Parent=CoreGui

-- ── COLOURS ────────────────────────────────────
local C = {
    BG       = Color3.fromRGB(13, 14, 22),      -- deepest navy
    SIDEBAR  = Color3.fromRGB(18, 19, 30),       -- sidebar panel
    PANEL    = Color3.fromRGB(20, 21, 34),       -- right panel
    ITEM     = Color3.fromRGB(26, 27, 42),       -- row bg
    ITEM_HV  = Color3.fromRGB(32, 33, 52),       -- row hover
    ACCENT   = Color3.fromRGB(88, 101, 242),     -- indigo accent (Discord-ish)
    ACCENT2  = Color3.fromRGB(110, 210, 255),    -- cyan highlight
    TXT      = Color3.fromRGB(210, 215, 240),    -- main text
    TXT2     = Color3.fromRGB(130, 135, 170),    -- dim text
    BORDER   = Color3.fromRGB(40, 42, 65),       -- border lines
    GREEN    = Color3.fromRGB(60, 220, 120),
    RED      = Color3.fromRGB(255, 70, 70),
}

local SCALE   = IsMobile and 1.3 or 1
local SB_W    = math.floor(58 * SCALE)   -- sidebar width
local TOTAL_W = math.floor(440 * SCALE)
local TOTAL_H = math.floor(360 * SCALE)
local ITEM_H  = math.floor(44 * SCALE)
local FS      = IsMobile and 14 or 13
local FS_SM   = IsMobile and 12 or 11

-- ── MAIN WINDOW ────────────────────────────────
local Win = Instance.new("Frame")
Win.Name="Win"; Win.Size=UDim2.new(0,TOTAL_W,0,TOTAL_H)
Win.Position=UDim2.new(0.5,-TOTAL_W/2,0.5,-TOTAL_H/2)
Win.BackgroundColor3=C.BG; Win.BorderSizePixel=0; Win.Visible=false; Win.Parent=SG
Instance.new("UICorner",Win).CornerRadius=UDim.new(0,12)
local WS=Instance.new("UIStroke",Win); WS.Color=C.BORDER; WS.Thickness=1.2

-- ── SIDEBAR ────────────────────────────────────
local Sidebar = Instance.new("Frame")
Sidebar.Size=UDim2.new(0,SB_W,1,0); Sidebar.BackgroundColor3=C.SIDEBAR
Sidebar.BorderSizePixel=0; Sidebar.Parent=Win
Instance.new("UICorner",Sidebar).CornerRadius=UDim.new(0,12)
-- cover right-side rounded corners
local SBFix=Instance.new("Frame")
SBFix.Size=UDim2.new(0,12,1,0); SBFix.Position=UDim2.new(1,-12,0,0)
SBFix.BackgroundColor3=C.SIDEBAR; SBFix.BorderSizePixel=0; SBFix.Parent=Sidebar

-- Logo area at top of sidebar
local Logo=Instance.new("TextLabel")
Logo.Size=UDim2.new(1,0,0,math.floor(50*SCALE))
Logo.BackgroundTransparency=1; Logo.Text="👻"
Logo.TextSize=math.floor(22*SCALE); Logo.Font=Enum.Font.GothamBold
Logo.TextColor3=C.ACCENT2; Logo.TextXAlignment=Enum.TextXAlignment.Center
Logo.Parent=Sidebar

-- Bottom version label in sidebar
local VerLbl=Instance.new("TextLabel")
VerLbl.Size=UDim2.new(1,0,0,24); VerLbl.Position=UDim2.new(0,0,1,-26)
VerLbl.BackgroundTransparency=1; VerLbl.Text="v2.0"
VerLbl.TextSize=FS_SM-1; VerLbl.Font=Enum.Font.Gotham
VerLbl.TextColor3=C.TXT2; VerLbl.TextXAlignment=Enum.TextXAlignment.Center
VerLbl.Parent=Sidebar

-- ── RIGHT PANEL ────────────────────────────────
local Panel=Instance.new("Frame")
Panel.Size=UDim2.new(1,-SB_W,1,0); Panel.Position=UDim2.new(0,SB_W,0,0)
Panel.BackgroundColor3=C.PANEL; Panel.BorderSizePixel=0; Panel.Parent=Win
Instance.new("UICorner",Panel).CornerRadius=UDim.new(0,12)
local PFix=Instance.new("Frame")
PFix.Size=UDim2.new(0,12,1,0); PFix.BackgroundColor3=C.PANEL; PFix.BorderSizePixel=0; PFix.Parent=Panel

-- Header strip inside right panel
local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,math.floor(44*SCALE))
Header.BackgroundColor3=C.SIDEBAR; Header.BorderSizePixel=0; Header.Parent=Panel
Instance.new("UICorner",Header).CornerRadius=UDim.new(0,12)
local HFix=Instance.new("Frame")
HFix.Size=UDim2.new(1,0,0,12); HFix.Position=UDim2.new(0,0,1,-12)
HFix.BackgroundColor3=C.SIDEBAR; HFix.BorderSizePixel=0; HFix.Parent=Header

local TabTitle=Instance.new("TextLabel")
TabTitle.Size=UDim2.new(1,-80,1,0); TabTitle.Position=UDim2.new(0,14,0,0)
TabTitle.BackgroundTransparency=1; TabTitle.Text="ESP"
TabTitle.TextColor3=C.TXT; TabTitle.TextSize=FS+1; TabTitle.Font=Enum.Font.GothamBold
TabTitle.TextXAlignment=Enum.TextXAlignment.Left; TabTitle.Parent=Header

-- Close button in header
local CloseBtn=Instance.new("TextButton")
CloseBtn.Size=UDim2.new(0,28,0,28); CloseBtn.Position=UDim2.new(1,-36,0.5,-14)
CloseBtn.BackgroundColor3=Color3.fromRGB(50,52,80); CloseBtn.Text="✕"
CloseBtn.TextColor3=C.TXT2; CloseBtn.TextSize=13; CloseBtn.Font=Enum.Font.GothamBold
CloseBtn.BorderSizePixel=0; CloseBtn.Parent=Header
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,7)
CloseBtn.MouseButton1Click:Connect(function() Win.Visible=false end)

-- Separator line under header
local Sep0=Instance.new("Frame")
Sep0.Size=UDim2.new(1,-20,0,1); Sep0.Position=UDim2.new(0,10,0,math.floor(44*SCALE))
Sep0.BackgroundColor3=C.BORDER; Sep0.BorderSizePixel=0; Sep0.Parent=Panel

-- Content scroll area
local ContentScroll=Instance.new("ScrollingFrame")
ContentScroll.Size=UDim2.new(1,0,1,-math.floor(50*SCALE))
ContentScroll.Position=UDim2.new(0,0,0,math.floor(50*SCALE))
ContentScroll.BackgroundTransparency=1; ContentScroll.BorderSizePixel=0
ContentScroll.ScrollBarThickness=IsMobile and 5 or 3
ContentScroll.ScrollBarImageColor3=C.ACCENT; ContentScroll.CanvasSize=UDim2.new(0,0,0,0)
ContentScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; ContentScroll.Parent=Panel
local CL=Instance.new("UIListLayout",ContentScroll)
CL.Padding=UDim.new(0,4); CL.SortOrder=Enum.SortOrder.LayoutOrder
local CP=Instance.new("UIPadding",ContentScroll)
CP.PaddingLeft=UDim.new(0,10); CP.PaddingRight=UDim.new(0,10)
CP.PaddingTop=UDim.new(0,8); CP.PaddingBottom=UDim.new(0,8)

-- ── DRAG ──────────────────────────────────────
local drg,drgS,drgP=false,nil,nil
Header.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        drg=true; drgS=i.Position; drgP=Win.Position
    end
end)
Header.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=false end
end)
UserInputService.InputChanged:Connect(function(i)
    if drg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-drgS
        Win.Position=UDim2.new(drgP.X.Scale,drgP.X.Offset+d.X,drgP.Y.Scale,drgP.Y.Offset+d.Y)
    end
end)

-- ── SIDEBAR TABS ───────────────────────────────
local Tabs={}
local TabDefs={
    {name="ESP",    icon="👁",  key="ESP"},
    {name="Aimbot", icon="🎯",  key="Aimbot"},
    {name="Player", icon="⚡",  key="Player"},
    {name="Visuals",icon="🌙",  key="Visuals"},
    {name="Misc",   icon="⚙",  key="Misc"},
}

local SBList=Instance.new("Frame")
SBList.Size=UDim2.new(1,0,1,-math.floor(80*SCALE))
SBList.Position=UDim2.new(0,0,0,math.floor(50*SCALE))
SBList.BackgroundTransparency=1; SBList.Parent=Sidebar
local SBL=Instance.new("UIListLayout",SBList)
SBL.Padding=UDim.new(0,4); SBL.SortOrder=Enum.SortOrder.LayoutOrder; SBL.HorizontalAlignment=Enum.HorizontalAlignment.Center
local SBP=Instance.new("UIPadding",SBList)
SBP.PaddingTop=UDim.new(0,6); SBP.PaddingLeft=UDim.new(0,6); SBP.PaddingRight=UDim.new(0,6)

-- Content pages map
local Pages={}

local function setTab(key)
    for k,t in pairs(Tabs) do
        local on=k==key
        TweenService:Create(t.Btn,TweenInfo.new(0.15),{
            BackgroundColor3=on and C.ACCENT or Color3.fromRGB(0,0,0),
            BackgroundTransparency=on and 0 or 1,
        }):Play()
        t.Btn.TextColor3=on and Color3.fromRGB(255,255,255) or C.TXT2
    end
    for k,pg in pairs(Pages) do pg.Visible=k==key end
    TabTitle.Text=key
end

for i,td in ipairs(TabDefs) do
    local btnW=math.floor(44*SCALE); local btnH=math.floor(44*SCALE)
    local btn=Instance.new("TextButton")
    btn.Size=UDim2.new(0,btnW,0,btnH)
    btn.BackgroundColor3=C.ACCENT; btn.BackgroundTransparency=1
    btn.Text=td.icon; btn.TextSize=IsMobile and 20 or 17
    btn.Font=Enum.Font.GothamBold; btn.TextColor3=C.TXT2
    btn.BorderSizePixel=0; btn.LayoutOrder=i; btn.Parent=SBList
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)

    -- Tooltip label
    local tip=Instance.new("TextLabel")
    tip.Size=UDim2.new(0,0,0,0); tip.BackgroundTransparency=1
    tip.Text=td.name; tip.TextColor3=C.TXT2; tip.TextSize=FS_SM; tip.Font=Enum.Font.Gotham
    tip.Visible=false; tip.Parent=btn

    Tabs[td.key]={Btn=btn}

    -- Page frame in content scroll
    local pg=Instance.new("Frame")
    pg.Size=UDim2.new(1,0,1,0); pg.BackgroundTransparency=1; pg.Visible=false; pg.Parent=ContentScroll
    local pgl=Instance.new("UIListLayout",pg); pgl.Padding=UDim.new(0,4); pgl.SortOrder=Enum.SortOrder.LayoutOrder
    Pages[td.key]=pg

    btn.MouseButton1Click:Connect(function() setTab(td.key) end)
end

-- ── WIDGET FACTORY ────────────────────────────

local function mkToggle(page, label, sublabel, getter, setter, accentCol)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,ITEM_H); row.BackgroundColor3=C.ITEM
    row.BorderSizePixel=0; row.Parent=page
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)

    -- left colour bar
    local bar=Instance.new("Frame")
    bar.Size=UDim2.new(0,3,0.6,0); bar.Position=UDim2.new(0,0,0.2,0)
    bar.BackgroundColor3=accentCol or C.ACCENT; bar.BorderSizePixel=0; bar.Parent=row
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-74,0,math.floor(20*SCALE)); lbl.Position=UDim2.new(0,12,0,sublabel and math.floor(6*SCALE) or nil)
    if not sublabel then lbl.AnchorPoint=Vector2.new(0,0.5); lbl.Position=UDim2.new(0,12,0.5,0) end
    lbl.BackgroundTransparency=1; lbl.Text=label
    lbl.TextColor3=C.TXT; lbl.TextSize=FS; lbl.Font=Enum.Font.GothamSemibold
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row

    if sublabel then
        local sub=Instance.new("TextLabel")
        sub.Size=UDim2.new(1,-74,0,math.floor(16*SCALE)); sub.Position=UDim2.new(0,12,0,math.floor(24*SCALE))
        sub.BackgroundTransparency=1; sub.Text=sublabel
        sub.TextColor3=C.TXT2; sub.TextSize=FS_SM; sub.Font=Enum.Font.Gotham
        sub.TextXAlignment=Enum.TextXAlignment.Left; sub.Parent=row
    end

    -- Toggle pill
    local TW=IsMobile and 48 or 40; local TH=IsMobile and 26 or 22
    local pill=Instance.new("TextButton")
    pill.Size=UDim2.new(0,TW,0,TH); pill.AnchorPoint=Vector2.new(1,0.5)
    pill.Position=UDim2.new(1,-12,0.5,0); pill.Text=""; pill.BorderSizePixel=0
    pill.BackgroundColor3=getter() and (accentCol or C.GREEN) or C.BORDER
    pill.Parent=row
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)

    local KS=TH-4
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,KS,0,KS); knob.AnchorPoint=Vector2.new(0,0.5)
    knob.Position=getter() and UDim2.new(1,-(KS+2),0.5,0) or UDim2.new(0,2,0.5,0)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0; knob.Parent=pill
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local KShadow=Instance.new("UIStroke",knob); KShadow.Color=Color3.fromRGB(0,0,0); KShadow.Transparency=0.7; KShadow.Thickness=1

    local function refresh(v)
        local on=accentCol or C.GREEN
        TweenService:Create(pill,TweenInfo.new(0.18),{BackgroundColor3=v and on or C.BORDER}):Play()
        TweenService:Create(knob,TweenInfo.new(0.18),{Position=v and UDim2.new(1,-(KS+2),0.5,0) or UDim2.new(0,2,0.5,0)}):Play()
    end
    pill.MouseButton1Click:Connect(function()
        local v=not getter(); setter(v); refresh(v)
    end)
    return row
end

local function mkSlider(page, label, min, max, getter, setter, col)
    local h2=math.floor(54*SCALE)
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,0,0,h2); row.BackgroundColor3=C.ITEM
    row.BorderSizePixel=0; row.Parent=page
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)

    local bar=Instance.new("Frame")
    bar.Size=UDim2.new(0,3,0.6,0); bar.Position=UDim2.new(0,0,0.2,0)
    bar.BackgroundColor3=col or C.ACCENT; bar.BorderSizePixel=0; bar.Parent=row
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)

    local valLbl=Instance.new("TextLabel")
    valLbl.Size=UDim2.new(0,40,0,18); valLbl.AnchorPoint=Vector2.new(1,0)
    valLbl.Position=UDim2.new(1,-12,0,8); valLbl.BackgroundTransparency=1
    valLbl.Text=tostring(getter()); valLbl.TextColor3=col or C.ACCENT2
    valLbl.TextSize=FS; valLbl.Font=Enum.Font.GothamBold
    valLbl.TextXAlignment=Enum.TextXAlignment.Right; valLbl.Parent=row

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-60,0,18); lbl.Position=UDim2.new(0,12,0,8)
    lbl.BackgroundTransparency=1; lbl.Text=label
    lbl.TextColor3=C.TXT; lbl.TextSize=FS; lbl.Font=Enum.Font.GothamSemibold
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row

    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-24,0,IsMobile and 8 or 6); track.Position=UDim2.new(0,12,0,h2-math.floor(20*SCALE))
    track.BackgroundColor3=C.BORDER; track.BorderSizePixel=0; track.Parent=row
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)

    local pct=(getter()-min)/(max-min)
    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=col or C.ACCENT
    fill.BorderSizePixel=0; fill.Parent=track
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)

    local slDrag=false
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then slDrag=true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then slDrag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if slDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local p2=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            local v=math.floor(min+(max-min)*p2)
            setter(v); fill.Size=UDim2.new(p2,0,1,0); valLbl.Text=tostring(v)
        end
    end)
end

local function mkButton(page, label, sublabel, cb, col)
    local row=Instance.new("TextButton")
    row.Size=UDim2.new(1,0,0,ITEM_H); row.BackgroundColor3=C.ITEM
    row.Text=""; row.BorderSizePixel=0; row.Parent=page
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)

    local bar=Instance.new("Frame")
    bar.Size=UDim2.new(0,3,0.6,0); bar.Position=UDim2.new(0,0,0.2,0)
    bar.BackgroundColor3=col or C.ACCENT; bar.BorderSizePixel=0; bar.Parent=row
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-50,0,sublabel and math.floor(20*SCALE) or ITEM_H)
    lbl.Position=UDim2.new(0,12,0,sublabel and math.floor(6*SCALE) or 0)
    lbl.BackgroundTransparency=1; lbl.Text=label
    lbl.TextColor3=C.TXT; lbl.TextSize=FS; lbl.Font=Enum.Font.GothamSemibold
    lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextYAlignment= sublabel and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
    lbl.Parent=row

    if sublabel then
        local sub=Instance.new("TextLabel")
        sub.Size=UDim2.new(1,-50,0,math.floor(16*SCALE)); sub.Position=UDim2.new(0,12,0,math.floor(24*SCALE))
        sub.BackgroundTransparency=1; sub.Text=sublabel
        sub.TextColor3=C.TXT2; sub.TextSize=FS_SM; sub.Font=Enum.Font.Gotham
        sub.TextXAlignment=Enum.TextXAlignment.Left; sub.Parent=row
    end

    local arrow=Instance.new("TextLabel")
    arrow.Size=UDim2.new(0,24,1,0); arrow.AnchorPoint=Vector2.new(1,0.5)
    arrow.Position=UDim2.new(1,-12,0.5,0); arrow.BackgroundTransparency=1
    arrow.Text="›"; arrow.TextColor3=C.TXT2; arrow.TextSize=20; arrow.Font=Enum.Font.GothamBold
    arrow.TextXAlignment=Enum.TextXAlignment.Right; arrow.Parent=row

    row.MouseButton1Click:Connect(function()
        TweenService:Create(row,TweenInfo.new(0.08),{BackgroundColor3=col or C.ACCENT,BackgroundTransparency=0.7}):Play()
        task.delay(0.15,function() TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.ITEM,BackgroundTransparency=0}):Play() end)
        cb()
    end)
end

local function mkSection(page, label)
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,math.floor(22*SCALE)); f.BackgroundTransparency=1; f.Parent=page
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,0,1,0); l.BackgroundTransparency=1; l.Text=label:upper()
    l.TextColor3=C.TXT2; l.TextSize=FS_SM-1; l.Font=Enum.Font.GothamBold
    l.TextXAlignment=Enum.TextXAlignment.Left; l.Position=UDim2.new(0,4,0,0)
    local sep=Instance.new("Frame",f)
    sep.Size=UDim2.new(1,-4,0,1); sep.Position=UDim2.new(0,4,1,-1)
    sep.BackgroundColor3=C.BORDER; sep.BorderSizePixel=0
end

-- ── FILL TABS ─────────────────────────────────

-- ESP
do local p=Pages["ESP"]
    mkSection(p,"Detection")
    mkToggle(p,"ESP Players","Show boxes, names and tracers",function() return Cfg.ESP.On end,function(v) Cfg.ESP.On=v end,C.ACCENT2)
    mkToggle(p,"Show Names",nil,function() return Cfg.ESP.Names end,function(v) Cfg.ESP.Names=v end)
    mkToggle(p,"Show Distance",nil,function() return Cfg.ESP.Dist end,function(v) Cfg.ESP.Dist=v end)
    mkToggle(p,"Show Role","Murder / Sheriff / Innocent",function() return Cfg.ESP.Role end,function(v) Cfg.ESP.Role=v end)
    mkSection(p,"Highlights")
    mkToggle(p,"Highlight Murder",nil,function() return true end,function() end,C.RED)
    mkToggle(p,"Highlight Sheriff",nil,function() return true end,function() end,C.GREEN)
end

-- Aimbot
do local p=Pages["Aimbot"]
    mkSection(p,"Settings")
    mkToggle(p,"Enable Aimbot",IsMobile and "Auto-aim at closest player" or "Hold Q to lock on",function() return Cfg.Aimbot.On end,function(v) Cfg.Aimbot.On=v end,C.RED)
    mkToggle(p,"Show FOV Circle",nil,function() return Cfg.Aimbot.ShowFOV end,function(v) Cfg.Aimbot.ShowFOV=v end)
    mkToggle(p,"Head Only","Target head instead of body",function() return Cfg.Aimbot.HeadOnly end,function(v) Cfg.Aimbot.HeadOnly=v end)
    if IsMobile then mkToggle(p,"Auto Aim (Mobile)","No key needed on phone",function() return Cfg.Aimbot.MobileAuto end,function(v) Cfg.Aimbot.MobileAuto=v end,Color3.fromRGB(255,140,40)) end
    mkSection(p,"Parameters")
    mkSlider(p,"FOV Radius",30,500,function() return Cfg.Aimbot.FOV end,function(v) Cfg.Aimbot.FOV=v end,C.RED)
    mkSlider(p,"Smoothness",1,10,function() return math.floor(Cfg.Aimbot.Smooth*10) end,function(v) Cfg.Aimbot.Smooth=v/10 end,Color3.fromRGB(255,160,60))
end

-- Player
do local p=Pages["Player"]
    mkSection(p,"Movement")
    mkSlider(p,"Walk Speed",8,100,function() return Cfg.Player.Speed end,function(v) Cfg.Player.Speed=v spd(v) end,C.GREEN)
    mkSlider(p,"Jump Power",10,200,function() return Cfg.Player.Jump end,function(v) Cfg.Player.Jump=v jmp(v) end,C.GREEN)
    mkToggle(p,"Infinite Jump",nil,function() return Cfg.Player.InfJump end,function(v) setIJ(v) end,C.GREEN)
    mkToggle(p,"Noclip","Walk through walls",function() return Cfg.Player.Noclip end,function(v) setNC(v) end,Color3.fromRGB(120,100,255))
    mkToggle(p,"Fly","WASD + Space/Ctrl",function() return Cfg.Player.Fly end,function(v) setFly(v) end,Color3.fromRGB(120,100,255))
    mkSection(p,"Teleport")
    mkButton(p,"Teleport To Murder","Instantly go to the killer",function() tpRole("Murder") end,C.RED)
    mkButton(p,"Teleport To Sheriff","Go to the sheriff",function() tpRole("Sheriff") end,C.GREEN)
    mkButton(p,"Reset Speed & Jump",nil,function() Cfg.Player.Speed=16; Cfg.Player.Jump=50; spd(16); jmp(50) end,C.TXT2)
end

-- Visuals
do local p=Pages["Visuals"]
    mkSection(p,"Environment")
    mkToggle(p,"Full Bright","Remove all darkness",function() return Cfg.Visual.FullBright end,function(v) setFB(v) end,Color3.fromRGB(255,220,80))
    mkToggle(p,"No Fog",nil,function() return Cfg.Visual.NoFog end,function(v) Cfg.Visual.NoFog=v if v then Lighting.FogEnd=100000 end end,Color3.fromRGB(180,140,255))
    mkToggle(p,"Crosshair","Custom centre dot",function() return Cfg.Visual.Crosshair end,function(v) Cfg.Visual.Crosshair=v mkCH() end,C.ACCENT2)
end

-- Misc
do local p=Pages["Misc"]
    mkSection(p,"Sheriff Gun")
    mkToggle(p,"Auto Grab Gun","Pick up gun the moment sheriff dies",function() return Cfg.Misc.AutoGun end,function(v) Cfg.Misc.AutoGun=v if v then scanGuns() end end,Color3.fromRGB(255,200,50))
    mkButton(p,"Scan For Gun Now","Search workspace immediately",function() scanGuns() end,Color3.fromRGB(200,160,30))
    mkSection(p,"Automation")
    mkToggle(p,"Auto Collect Coins",nil,function() return Cfg.Misc.Coins end,function(v) Cfg.Misc.Coins=v end,Color3.fromRGB(255,200,50))
    mkToggle(p,"Anti AFK",nil,function() return Cfg.Misc.AntiAFK end,function(v) Cfg.Misc.AntiAFK=v end)
    mkSection(p,"Chat")
    mkToggle(p,"Chat Spam",nil,function() return Cfg.Misc.ChatSpam end,function(v)
        Cfg.Misc.ChatSpam=v
        if v then task.spawn(function()
            while Cfg.Misc.ChatSpam do
                pcall(function() ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Cfg.Misc.ChatMsg,"All") end)
                task.wait(5)
            end
        end) end
    end,Color3.fromRGB(120,200,255))
    mkSection(p,"Info")
    mkButton(p,"Show All Roles","Print roles to console (F9)",function()
        local out=""
        for _,pl in ipairs(Players:GetPlayers()) do out=out..pl.Name.." → "..role(pl).."\n" end
        warn("[Phantom]\n"..out)
    end,C.ACCENT)
end

-- ── FLOATING BUTTON ────────────────────────────
local FB=Instance.new("TextButton")
FB.Size=UDim2.new(0,IsMobile and 64 or 52,0,IsMobile and 64 or 52)
FB.Position=UDim2.new(0,12,0.5,-32); FB.BackgroundColor3=C.SIDEBAR
FB.Text="👻"; FB.TextSize=IsMobile and 24 or 20; FB.Font=Enum.Font.GothamBold
FB.TextColor3=C.ACCENT2; FB.BorderSizePixel=0; FB.ZIndex=10; FB.Parent=SG
Instance.new("UICorner",FB).CornerRadius=UDim.new(0,14)
local FBS=Instance.new("UIStroke",FB); FBS.Color=C.BORDER; FBS.Thickness=1.5

-- drag floating btn
local fbd,fbS,fbP=false,nil,nil
FB.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        fbd=true; fbS=i.Position; fbP=FB.Position
    end
end)
FB.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then fbd=false end
end)
UserInputService.InputChanged:Connect(function(i)
    if fbd and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-fbS
        FB.Position=UDim2.new(fbP.X.Scale,fbP.X.Offset+d.X,fbP.Y.Scale,fbP.Y.Offset+d.Y)
    end
end)
FB.MouseButton1Click:Connect(function() Win.Visible=not Win.Visible end)

-- Keyboard toggle
UserInputService.InputBegan:Connect(function(i,p2)
    if p2 then return end
    if i.KeyCode==Enum.KeyCode.Insert or i.KeyCode==Enum.KeyCode.RightShift then
        Win.Visible=not Win.Visible
    end
end)

-- ── INIT ───────────────────────────────────────
for _,pl in ipairs(Players:GetPlayers()) do mkESP(pl) end
Players.PlayerAdded:Connect(mkESP)
Players.PlayerRemoving:Connect(rmESP)

setTab("Misc")

LocalPlayer.CharacterAdded:Connect(function(c)
    Character=c; task.wait(0.5)
    spd(Cfg.Player.Speed); jmp(Cfg.Player.Jump)
    if Cfg.Player.Noclip  then setNC(true)   end
    if Cfg.Player.Fly     then setFly(true)   end
    if Cfg.Player.InfJump then setIJ(true)    end
end)

RunService.RenderStepped:Connect(function()
    updESP(); updAimbot()
    if Cfg.Visual.NoFog then Lighting.FogEnd=100000 end
end)

warn("[Phantom] Ready  |  👻 button or Insert / RightShift to open")

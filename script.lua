local _P=game:GetService("Players") local _RS=game:GetService("RunService")
local _UI=game:GetService("UserInputService") local _Cam=workspace.CurrentCamera
local _LP=_P.LocalPlayer

local _cfg={e=true,n=true,h=true,tc=true,ae=true,fov=500,sf=true,tk=true,hb="HumanoidRootPart",cd=Color3.fromRGB(255,255,255),cf=Color3.fromRGB(255,255,255)}
local _alias={ESP_Enabled="e",ESP_Names="n",ESP_Health="h",ESP_TeamColor="tc",Aim_Enabled="ae",Aim_FOV="fov",Aim_ShowFOV="sf",Aim_TeamCheck="tk",Aim_Hitbox="hb"}
local function _get(k) return _cfg[_alias[k] or k] end
local function _set(k,v) _cfg[_alias[k] or k]=v end
local function _tog(k) _set(k, not _get(k)) end

local function _alive(p) local c=p.Character if not c then return false end local h=c:FindFirstChildOfClass("Humanoid") return h and h.Health>0 end
local function _hp(p) local c=p.Character if not c then return 0,100 end local h=c:FindFirstChildOfClass("Humanoid") if not h then return 0,100 end return math.floor(h.Health),math.floor(h.MaxHealth) end
local function _tc(p) if _get("ESP_TeamColor") and p.Team then return p.Team.TeamColor.Color end return _cfg.cd end
local function _st(p) return _LP.Team and p.Team and _LP.Team==p.Team end
local function _w2s(pos) local s,on=_Cam:WorldToViewportPoint(pos) return Vector2.new(s.X,s.Y),on end

local function _bbox(char)
	local hrp=char:FindFirstChild("HumanoidRootPart") if not hrp then return nil end
	local cf=hrp.CFrame local hw,hh,hd=1.1,2.8,0.6
	local pts={cf*Vector3.new(hw,hh,hd),cf*Vector3.new(-hw,hh,hd),cf*Vector3.new(-hw,hh,-hd),cf*Vector3.new(hw,hh,-hd),cf*Vector3.new(hw,-hh,hd),cf*Vector3.new(-hw,-hh,hd),cf*Vector3.new(-hw,-hh,-hd),cf*Vector3.new(hw,-hh,-hd)}
	local mnX,mnY,mxX,mxY=math.huge,math.huge,-math.huge,-math.huge local hit=false
	for _,c in ipairs(pts) do local s,on=_w2s(c) if on then hit=true end if s.X<mnX then mnX=s.X end if s.Y<mnY then mnY=s.Y end if s.X>mxX then mxX=s.X end if s.Y>mxY then mxY=s.Y end end
	if not hit then return nil end return{x0=mnX,y0=mnY,x1=mxX,y1=mxY}
end

local _pool={} local _rc=nil local _ic={} local _pc={} local _esp={}
local function _nd(t,pr) local d=Drawing.new(t) for k,v in pairs(pr) do d[k]=v end d.Visible=false table.insert(_pool,d) return d end
local function _ri(c) table.insert(_ic,c) return c end

local function _nuke()
	if _rc then _rc:Disconnect() end
	for _,c in ipairs(_ic) do pcall(function() c:Disconnect() end) end
	for _,c in ipairs(_pc) do pcall(function() c:Disconnect() end) end
	for _,d in ipairs(_pool) do pcall(function() d:Remove() end) end
	_pool={}
	local g=game.CoreGui:FindFirstChild("__hud") if g then g:Destroy() end
end

local function _mkEsp(p)
	_esp[p]={t=_nd("Line",{Thickness=1,ZIndex=1}),b=_nd("Line",{Thickness=1,ZIndex=1}),l=_nd("Line",{Thickness=1,ZIndex=1}),r=_nd("Line",{Thickness=1,ZIndex=1}),nm=_nd("Text",{Size=13,Center=true,Outline=true,Font=Drawing.Fonts.UI,ZIndex=2}),hp=_nd("Text",{Size=12,Center=true,Outline=true,Font=Drawing.Fonts.UI,ZIndex=2})}
end
local function _rmEsp(p) local o=_esp[p] if not o then return end for _,d in pairs(o) do pcall(function() d:Remove() end) end _esp[p]=nil end
local function _hide(o) for _,d in pairs(o) do d.Visible=false end end

local _fc=_nd("Circle",{Thickness=1,Filled=false,Color=_cfg.cf,NumSides=64,ZIndex=10})
local _at=nil local _aa=false

local function _best()
	local ctr=Vector2.new(_Cam.ViewportSize.X/2,_Cam.ViewportSize.Y/2)
	local best,bd=nil,_get("Aim_FOV")
	for _,p in ipairs(_P:GetPlayers()) do
		if p==_LP then continue end if not _alive(p) then continue end
		if _get("Aim_TeamCheck") and _st(p) then continue end
		local ch=p.Character if not ch then continue end
		local pt=ch:FindFirstChild(_get("Aim_Hitbox")) or ch:FindFirstChild("HumanoidRootPart") if not pt then continue end
		local s,on=_w2s(pt.Position) if not on then continue end
		local d=(s-ctr).Magnitude if d<bd then bd=d best=pt end
	end
	return best
end

_ri(_UI.InputBegan:Connect(function(i,gp)
	if i.UserInputType==Enum.UserInputType.MouseButton3 then _aa=true end
	if not gp and i.KeyCode==Enum.KeyCode.Delete then _nuke() end
end))
_ri(_UI.InputEnded:Connect(function(i)
	if i.UserInputType==Enum.UserInputType.MouseButton3 then _aa=false _at=nil end
end))

_rc=_RS.RenderStepped:Connect(function()
	local vp=_Cam.ViewportSize
	_fc.Position=Vector2.new(vp.X/2,vp.Y/2) _fc.Radius=_get("Aim_FOV") _fc.Visible=_get("Aim_Enabled") and _get("Aim_ShowFOV")
	if _get("Aim_Enabled") and _aa then
		_at=_best()
		if _at then local cp=_Cam.CFrame.Position local dir=(_at.Position-cp).Unit _Cam.CFrame=CFrame.new(cp,cp+dir) end
	end
	for _,p in ipairs(_P:GetPlayers()) do
		if p==_LP then if _esp[p] then _hide(_esp[p]) end continue end
		if not _esp[p] then _mkEsp(p) end
		local o=_esp[p]
		if not _get("ESP_Enabled") or not _alive(p) then _hide(o) continue end
		local ch=p.Character if not ch then _hide(o) continue end
		local bx=_bbox(ch) if not bx then _hide(o) continue end
		local col=_tc(p)
		local function _sl(ln,x0,y0,x1,y1) ln.From=Vector2.new(x0,y0) ln.To=Vector2.new(x1,y1) ln.Color=col ln.Visible=true end
		_sl(o.t,bx.x0,bx.y0,bx.x1,bx.y0) _sl(o.b,bx.x0,bx.y1,bx.x1,bx.y1)
		_sl(o.l,bx.x0,bx.y0,bx.x0,bx.y1) _sl(o.r,bx.x1,bx.y0,bx.x1,bx.y1)
		o.nm.Text=p.Name o.nm.Position=Vector2.new((bx.x0+bx.x1)/2,bx.y0-15) o.nm.Color=col o.nm.Visible=_get("ESP_Names")
		local hp,mhp=_hp(p)
		o.hp.Text=hp.."/"..mhp o.hp.Position=Vector2.new((bx.x0+bx.x1)/2,bx.y0-27) o.hp.Color=Color3.fromRGB(math.floor(255*(1-hp/mhp)),math.floor(255*(hp/mhp)),0) o.hp.Visible=_get("ESP_Health")
	end
end)

table.insert(_pc,_P.PlayerAdded:Connect(_mkEsp))
table.insert(_pc,_P.PlayerRemoving:Connect(_rmEsp))

local _sg=Instance.new("ScreenGui") _sg.Name="__hud" _sg.ResetOnSpawn=false _sg.ZIndexBehavior=Enum.ZIndexBehavior.Sibling _sg.Parent=game.CoreGui
local _mf=Instance.new("Frame") _mf.Size=UDim2.new(0,300,0,36) _mf.AutomaticSize=Enum.AutomaticSize.Y _mf.Position=UDim2.new(0,20,0.5,-150) _mf.BackgroundColor3=Color3.fromRGB(18,18,24) _mf.BorderSizePixel=0 _mf.Active=true _mf.Draggable=true _mf.Parent=_sg
Instance.new("UICorner",_mf).CornerRadius=UDim.new(0,8)
local _tb=Instance.new("Frame") _tb.Size=UDim2.new(1,0,0,32) _tb.BackgroundColor3=Color3.fromRGB(30,30,40) _tb.BorderSizePixel=0 _tb.Parent=_mf
Instance.new("UICorner",_tb).CornerRadius=UDim.new(0,8)
local _tfx=Instance.new("Frame") _tfx.Size=UDim2.new(1,0,0,8) _tfx.Position=UDim2.new(0,0,1,-8) _tfx.BackgroundColor3=Color3.fromRGB(30,30,40) _tfx.BorderSizePixel=0 _tfx.Parent=_tb
local _tl=Instance.new("TextLabel") _tl.Size=UDim2.new(1,-40,1,0) _tl.Position=UDim2.new(0,10,0,0) _tl.BackgroundTransparency=1 _tl.Text="🎯  v2.4  |  tassadar" _tl.TextColor3=Color3.fromRGB(220,220,255) _tl.TextSize=13 _tl.Font=Enum.Font.GothamBold _tl.TextXAlignment=Enum.TextXAlignment.Left _tl.Parent=_tb
local _hb=Instance.new("TextButton") _hb.Size=UDim2.new(0,28,0,24) _hb.Position=UDim2.new(1,-32,0,4) _hb.BackgroundColor3=Color3.fromRGB(60,60,90) _hb.Text="−" _hb.TextColor3=Color3.fromRGB(255,255,255) _hb.TextSize=18 _hb.Font=Enum.Font.GothamBold _hb.BorderSizePixel=0 _hb.Parent=_tb
Instance.new("UICorner",_hb).CornerRadius=UDim.new(0,5)
local _sc=Instance.new("ScrollingFrame") _sc.Size=UDim2.new(1,0,0,280) _sc.Position=UDim2.new(0,0,0,36) _sc.BackgroundTransparency=1 _sc.BorderSizePixel=0 _sc.ScrollBarThickness=4 _sc.ScrollBarImageColor3=Color3.fromRGB(100,100,160) _sc.CanvasSize=UDim2.new(0,0,0,0) _sc.AutomaticCanvasSize=Enum.AutomaticSize.Y _sc.Parent=_mf
local _sl2=Instance.new("UIListLayout",_sc) _sl2.Padding=UDim.new(0,4) _sl2.SortOrder=Enum.SortOrder.LayoutOrder
local _sp=Instance.new("UIPadding",_sc) _sp.PaddingLeft=UDim.new(0,8) _sp.PaddingRight=UDim.new(0,8) _sp.PaddingTop=UDim.new(0,6) _sp.PaddingBottom=UDim.new(0,6)

local _ord=0
local function _sec(nm)
	_ord=_ord+1
	local l=Instance.new("TextLabel") l.Size=UDim2.new(1,0,0,22) l.BackgroundColor3=Color3.fromRGB(35,35,50) l.Text="  "..nm l.TextColor3=Color3.fromRGB(160,160,220) l.TextSize=12 l.Font=Enum.Font.GothamBold l.TextXAlignment=Enum.TextXAlignment.Left l.BorderSizePixel=0 l.LayoutOrder=_ord l.Parent=_sc
	Instance.new("UICorner",l).CornerRadius=UDim.new(0,4)
end
local function _tgg(lbl,key,cb)
	_ord=_ord+1
	local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,28) row.BackgroundTransparency=1 row.LayoutOrder=_ord row.Parent=_sc
	local tx=Instance.new("TextLabel") tx.Size=UDim2.new(1,-50,1,0) tx.BackgroundTransparency=1 tx.Text=lbl tx.TextColor3=Color3.fromRGB(200,200,200) tx.TextSize=13 tx.Font=Enum.Font.Gotham tx.TextXAlignment=Enum.TextXAlignment.Left tx.Parent=row
	local bt=Instance.new("TextButton") bt.Size=UDim2.new(0,40,0,20) bt.Position=UDim2.new(1,-44,0.5,-10) bt.BorderSizePixel=0 bt.Font=Enum.Font.GothamBold bt.TextSize=11 bt.Parent=row
	Instance.new("UICorner",bt).CornerRadius=UDim.new(0,10)
	local function rf() local on=_get(key) bt.Text=on and"ON"or"OFF" bt.BackgroundColor3=on and Color3.fromRGB(50,180,90)or Color3.fromRGB(180,50,50) bt.TextColor3=Color3.fromRGB(255,255,255) end rf()
	bt.MouseButton1Click:Connect(function() _tog(key) rf() if cb then cb(_get(key)) end end)
end
local function _sld(lbl,key,mn,mx)
	_ord=_ord+1
	local row=Instance.new("Frame") row.Size=UDim2.new(1,0,0,44) row.BackgroundTransparency=1 row.LayoutOrder=_ord row.Parent=_sc
	local tx=Instance.new("TextLabel") tx.Size=UDim2.new(1,0,0,18) tx.BackgroundTransparency=1 tx.Text=lbl..":  ".._get(key) tx.TextColor3=Color3.fromRGB(200,200,200) tx.TextSize=12 tx.Font=Enum.Font.Gotham tx.TextXAlignment=Enum.TextXAlignment.Left tx.Parent=row
	local tr=Instance.new("Frame") tr.Size=UDim2.new(1,-4,0,8) tr.Position=UDim2.new(0,0,0,24) tr.BackgroundColor3=Color3.fromRGB(50,50,70) tr.BorderSizePixel=0 tr.Parent=row
	Instance.new("UICorner",tr).CornerRadius=UDim.new(0,4)
	local fi=Instance.new("Frame") fi.BackgroundColor3=Color3.fromRGB(90,130,255) fi.BorderSizePixel=0 fi.Parent=tr
	Instance.new("UICorner",fi).CornerRadius=UDim.new(0,4)
	local function sv(v) v=math.clamp(math.floor(v),mn,mx) _set(key,v) tx.Text=lbl..":  "..v fi.Size=UDim2.new((v-mn)/(mx-mn),0,1,0) end sv(_get(key))
	local drg=false
	tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drg=true end end)
	_ri(_UI.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then drg=false end end))
	_ri(_UI.InputChanged:Connect(function(i) if drg and i.UserInputType==Enum.UserInputType.MouseMovement then sv(mn+(i.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X*(mx-mn)) end end))
end
local function _hbpick()
	_ord=_ord+1
	local opts={"Head","UpperTorso","LowerTorso","HumanoidRootPart","LeftUpperLeg","RightUpperLeg","LeftUpperArm","RightUpperArm"}
	local ct=Instance.new("Frame") ct.Size=UDim2.new(1,0,0,0) ct.AutomaticSize=Enum.AutomaticSize.Y ct.BackgroundColor3=Color3.fromRGB(25,25,35) ct.BorderSizePixel=0 ct.LayoutOrder=_ord ct.Parent=_sc
	Instance.new("UICorner",ct).CornerRadius=UDim.new(0,6)
	local pd=Instance.new("UIPadding",ct) pd.PaddingLeft=UDim.new(0,6) pd.PaddingRight=UDim.new(0,6) pd.PaddingTop=UDim.new(0,6) pd.PaddingBottom=UDim.new(0,6)
	local gd=Instance.new("UIGridLayout",ct) gd.CellSize=UDim2.new(0.5,-4,0,26) gd.CellPadding=UDim2.new(0,4,0,4) gd.SortOrder=Enum.SortOrder.LayoutOrder
	local bs={}
	for i,pn in ipairs(opts) do
		local bt=Instance.new("TextButton") bt.Size=UDim2.new(1,0,1,0) bt.BackgroundColor3=Color3.fromRGB(50,50,75) bt.Text=pn bt.TextColor3=Color3.fromRGB(180,180,255) bt.TextSize=11 bt.Font=Enum.Font.Gotham bt.BorderSizePixel=0 bt.LayoutOrder=i bt.Parent=ct
		Instance.new("UICorner",bt).CornerRadius=UDim.new(0,4) bs[pn]=bt
		bt.MouseButton1Click:Connect(function()
			_set("Aim_Hitbox",pn)
			for _,b in pairs(bs) do b.BackgroundColor3=Color3.fromRGB(50,50,75) b.TextColor3=Color3.fromRGB(180,180,255) end
			bt.BackgroundColor3=Color3.fromRGB(90,130,255) bt.TextColor3=Color3.fromRGB(255,255,255)
		end)
	end
	if bs[_get("Aim_Hitbox")] then bs[_get("Aim_Hitbox")].BackgroundColor3=Color3.fromRGB(90,130,255) bs[_get("Aim_Hitbox")].TextColor3=Color3.fromRGB(255,255,255) end
end

_sec("── ESP ──────────────────")
_tgg("ESP",             "ESP_Enabled")
_tgg("Names",           "ESP_Names")
_tgg("HP",              "ESP_Health")
_tgg("Team Color",      "ESP_TeamColor")
_sec("── AIMBOT ───────────────")
_tgg("Aimbot",          "Aim_Enabled")
_tgg("Show FOV",        "Aim_ShowFOV")
_tgg("Team Check",      "Aim_TeamCheck")
_sld("FOV",             "Aim_FOV",50,900)
_sec("── HITBOX ───────────────")
_hbpick()

local _ex=true
_hb.MouseButton1Click:Connect(function()
	_ex=not _ex _sc.Visible=_ex _hb.Text=_ex and"−"or"+"
	if not _ex then _mf.Size=UDim2.new(0,300,0,36) else _mf.AutomaticSize=Enum.AutomaticSize.Y end
end)
_ri(_UI.InputBegan:Connect(function(i,gp)
	if not gp and i.KeyCode==Enum.KeyCode.Insert then _mf.Visible=not _mf.Visible end
end))

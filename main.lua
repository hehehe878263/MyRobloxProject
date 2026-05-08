local CoreGui = (gethui and gethui()) or game:GetService("CoreGui")
local LBLG = Instance.new("ScreenGui", CoreGui)
local Main = Instance.new("Frame", LBLG)
local Title = Instance.new("TextLabel", Main)
local Scroll = Instance.new("ScrollingFrame", Main)
local UIList = Instance.new("UIListLayout", Scroll)
local UIPadding = Instance.new("UIPadding", Scroll)
local MainCorner = Instance.new("UICorner", Main)
local TitleCorner = Instance.new("UICorner", Title)

Main.Name = "PowerOff_V4_Pro"
Main.Size = UDim2.new(0, 280, 0, 450)
Main.Position = UDim2.new(0.5, -140, 0.5, -225)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
MainCorner.CornerRadius = UDim.new(0, 10)

Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(45, 5, 5)
Title.Text = "POWEROFF V4 - PRO EDITION"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 16
Title.Font = Enum.Font.GothamBlack
TitleCorner.CornerRadius = UDim.new(0, 10)

local FixFrame = Instance.new("Frame", Main)
FixFrame.Size = UDim2.new(1, 0, 0, 10)
FixFrame.Position = UDim2.new(0, 0, 0, 35)
FixFrame.BackgroundColor3 = Color3.fromRGB(45, 5, 5)
FixFrame.BorderSizePixel = 0

Scroll.Size = UDim2.new(1, 0, 1, -45)
Scroll.Position = UDim2.new(0, 0, 0, 45)
Scroll.BackgroundTransparency = 1
Scroll.CanvasSize = UDim2.new(0, 0, 0, 750)
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 10, 10)

UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIPadding.PaddingTop = UDim.new(0, 10)
UIPadding.PaddingBottom = UDim.new(0, 10)

local Config = {
    SilentAim = false,
    Wallbang = false,
    ESP = false,
    BringItems = false,
    FOV = 150,
    Speed = 7,
    SpeedEnabled = false,
    JumpEnabled = false,
    ItemESP = false,
    ImageInvESP = false,
    HermanosDetector = true
}

local FOVing = Drawing.new("Circle")
FOVing.Thickness = 1.5
FOVing.NumSides = 100
FOVing.Visible = false
FOVing.Color = Color3.new(1, 0.2, 0.2)

local Line = Drawing.new("Line")
Line.Thickness = 1.5
Line.Color = Color3.new(1, 0.2, 0.2)
Line.Visible = false

local P = game:GetService("Players")
local LP = P.LocalPlayer
local Run = game:GetService("RunService")
local Cam = workspace.CurrentCamera

local function CreateToggle(txt, state_key, callback)
    local B = Instance.new("TextButton", Scroll)
    B.Size = UDim2.new(0.9, 0, 0, 38)
    B.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    B.Text = txt .. " : OFF"
    B.TextColor3 = Color3.fromRGB(200, 200, 200)
    B.Font = Enum.Font.GothamBold
    B.TextSize = 13
    B.AutoButtonColor = false
    
    local BCorner = Instance.new("UICorner", B)
    BCorner.CornerRadius = UDim.new(0, 6)
    
    B.MouseButton1Click:Connect(function()
        Config[state_key] = not Config[state_key]
        if Config[state_key] then
            B.Text = txt .. " : ON"
            B.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
            B.TextColor3 = Color3.new(1, 1, 1)
        else
            B.Text = txt .. " : OFF"
            B.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            B.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        if callback then callback(Config[state_key]) end
    end)
end

local function GetTarget()
    local target = nil
    local dist = Config.FOV
    local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    for _, v in ipairs(P:GetPlayers()) do
        if v ~= LP and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, vis = Cam:WorldToViewportPoint(v.Character.Head.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                if mag < dist then
                    dist = mag
                    target = v
                end
            end
        end
    end
    return target
end

local function GetWorldItems()
    local items = {}
    for _, v in ipairs(workspace:GetChildren()) do
        if v:IsA("BackpackItem") or v:IsA("Tool") or v:FindFirstChild("Handle") then
            table.insert(items, v)
        end
    end
    local folders = {"Items", "Dropped", "DroppedItems", "Debris"}
    for _, name in ipairs(folders) do
        local f = workspace:FindFirstChild(name)
        if f then
            for _, v in ipairs(f:GetChildren()) do
                table.insert(items, v)
            end
        end
    end
    return items
end

local suspectedExploiters = {}

task.spawn(function()
    while task.wait(1) do
        for _, v in ipairs(P:GetPlayers()) do
            if v ~= LP and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = v.Character.HumanoidRootPart
                if hrp.Velocity.Magnitude > 100 or hrp.AssemblyLinearVelocity.Magnitude > 100 then
                    suspectedExploiters[v.Name] = true
                end
            end
        end
    end
end)

CreateToggle("🎯 Aimbot + Tracer", "SilentAim", function(s)
    FOVing.Visible = s
end)
CreateToggle("🧱 Wallbang (Bypass)", "Wallbang")
CreateToggle("👤 Player ESP + Script Detect", "ESP")
CreateToggle("🧲 Bring Items (10m Max Priority)", "BringItems")
CreateToggle("🟢 Item ESP (500m)", "ItemESP")
CreateToggle("🎒 Image Inventory ESP", "ImageInvESP")

local FOVBtn = Instance.new("TextButton", Scroll)
FOVBtn.Size = UDim2.new(0.9, 0, 0, 38)
FOVBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
FOVBtn.Text = "⭕ FOV : 150"
FOVBtn.TextColor3 = Color3.new(1, 1, 1)
FOVBtn.Font = Enum.Font.GothamBold
FOVBtn.TextSize = 13
local FOVCorner = Instance.new("UICorner", FOVBtn)
FOVCorner.CornerRadius = UDim.new(0, 6)

FOVBtn.MouseButton1Click:Connect(function()
    Config.FOV = Config.FOV + 50
    if Config.FOV > 600 then Config.FOV = 100 end
    FOVBtn.Text = "⭕ FOV : " .. Config.FOV
end)

CreateToggle("⚡ Speed Hack", "SpeedEnabled")
local SpeedBtn = Instance.new("TextButton", Scroll)
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 38)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
SpeedBtn.Text = "🏃 Speed : 7"
SpeedBtn.TextColor3 = Color3.new(1, 1, 1)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 13
local SpeedCorner = Instance.new("UICorner", SpeedBtn)
SpeedCorner.CornerRadius = UDim.new(0, 6)

SpeedBtn.MouseButton1Click:Connect(function()
    Config.Speed = Config.Speed + 1
    if Config.Speed > 15 then Config.Speed = 7 end
    SpeedBtn.Text = "🏃 Speed : " .. Config.Speed
end)

CreateToggle("🦘 1.5x High Jump", "JumpEnabled")

task.spawn(function()
    while task.wait(0.2) do
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        
        if Config.ESP then
            for _, v in ipairs(P:GetPlayers()) do
                if v ~= LP and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") then
                    local head = v.Character.Head
                    local bb = head:FindFirstChild("D_ESP") or Instance.new("BillboardGui", head)
                    bb.Name = "D_ESP"
                    bb.AlwaysOnTop = true
                    bb.Size = UDim2.new(0, 150, 0, 60)
                    bb.ExtentsOffset = Vector3.new(0, 3, 0)
                    local l = bb:FindFirstChild("L") or Instance.new("TextLabel", bb)
                    l.Name = "L"
                    l.BackgroundTransparency = 1
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.TextSize = 13
                    l.Font = Enum.Font.GothamBold
                    
                    local txt = v.Name .. "\n" .. math.floor(v.Character.Humanoid.Health) .. " HP"
                    if suspectedExploiters[v.Name] then
                        txt = txt .. "\n[Hermanos Hub User]"
                        l.TextColor3 = Color3.new(1, 0, 0)
                    else
                        l.TextColor3 = Color3.new(1, 1, 1)
                    end
                    l.Text = txt
                    l.TextStrokeTransparency = 0.3
                end
            end
        else
            for _, v in ipairs(P:GetPlayers()) do
                if v.Character and v.Character:FindFirstChild("Head") and v.Character.Head:FindFirstChild("D_ESP") then
                    v.Character.Head.D_ESP:Destroy()
                end
            end
        end

        if Config.ItemESP and root then
            local allItems = GetWorldItems()
            for _, v in ipairs(allItems) do
                local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
                if part then
                    local mag = (part.Position - root.Position).Magnitude
                    local bb = part:FindFirstChild("I_ESP")
                    if mag <= 500 then
                        if not bb then
                            bb = Instance.new("BillboardGui", part)
                            bb.Name = "I_ESP"
                            bb.AlwaysOnTop = true
                            bb.Size = UDim2.new(0, 100, 0, 20)
                            local l = Instance.new("TextLabel", bb)
                            l.BackgroundTransparency = 1
                            l.Size = UDim2.new(1, 0, 1, 0)
                            l.TextColor3 = Color3.new(0, 1, 0.5)
                            l.Font = Enum.Font.GothamBold
                            l.TextSize = 12
                            l.TextStrokeTransparency = 0.3
                            l.Text = v.Name
                        end
                    elseif bb then
                        bb:Destroy()
                    end
                end
            end
        else
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BillboardGui") and v.Name == "I_ESP" then v:Destroy() end
            end
        end

        if Config.ImageInvESP then
            for _, v in ipairs(P:GetPlayers()) do
                if v ~= LP and v.Character and v.Character:FindFirstChild("Head") then
                    local head = v.Character.Head
                    local invESP = head:FindFirstChild("ImgInvESP")
                    if not invESP then
                        invESP = Instance.new("BillboardGui", head)
                        invESP.Name = "ImgInvESP"
                        invESP.AlwaysOnTop = true
                        invESP.Size = UDim2.new(0, 200, 0, 30)
                        invESP.ExtentsOffset = Vector3.new(0, -2.5, 0)
                        local layout = Instance.new("UIListLayout", invESP)
                        layout.FillDirection = Enum.FillDirection.Horizontal
                        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                        layout.Padding = UDim.new(0, 3)
                    end
                    for _, c in ipairs(invESP:GetChildren()) do
                        if c:IsA("ImageLabel") then c:Destroy() end
                    end
                    local function scan(parent)
                        if not parent then return end
                        for _, t in ipairs(parent:GetChildren()) do
                            if t:IsA("Tool") and t.TextureId and t.TextureId ~= "" then
                                local img = Instance.new("ImageLabel", invESP)
                                img.Size = UDim2.new(0, 28, 0, 28)
                                img.BackgroundTransparency = 1
                                img.Image = t.TextureId
                            end
                        end
                    end
                    scan(v.Character)
                    scan(v:FindFirstChild("Backpack"))
                end
            end
        else
            for _, v in ipairs(P:GetPlayers()) do
                if v.Character and v.Character:FindFirstChild("Head") and v.Character.Head:FindFirstChild("ImgInvESP") then
                    v.Character.Head.ImgInvESP:Destroy()
                end
            end
        end
    end
end)

Run.Stepped:Connect(function()
    if Config.BringItems then
        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local allItems = GetWorldItems()
            for _, v in ipairs(allItems) do
                local part = v:IsA("BasePart") and v or v:FindFirstChildWhichIsA("BasePart")
                if part then
                    local mag = (part.Position - root.Position).Magnitude
                    if mag <= 10 then
                        part.CFrame = root.CFrame
                        if firetouchinterest then
                            firetouchinterest(root, part, 0)
                            firetouchinterest(root, part, 1)
                        end
                    end
                end
            end
        end
    end
end)

Run.RenderStepped:Connect(function(deltaTime)
    local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    FOVing.Position = center
    FOVing.Radius = Config.FOV
    
    if LP.Character and LP.Character:FindFirstChild("Humanoid") and LP.Character:FindFirstChild("HumanoidRootPart") then
        local hum = LP.Character.Humanoid
        local root = LP.Character.HumanoidRootPart
        
        if Config.SpeedEnabled and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * (Config.Speed * deltaTime))
        end
        if Config.JumpEnabled then
            if hum.UseJumpPower then
                hum.JumpPower = 75
            else
                hum.JumpHeight = 10.8
            end
        end
    end

    local T = GetTarget()
    if T and T.Character and T.Character:FindFirstChild("Head") and Config.SilentAim then
        local tPos, tVis = Cam:WorldToViewportPoint(T.Character.Head.Position)
        if tVis then
            Line.From = center
            Line.To = Vector2.new(tPos.X, tPos.Y)
            Line.Visible = true
        else
            Line.Visible = false
        end
    else
        Line.Visible = false
    end
end)

local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if not checkcaller() then
        local T = GetTarget()
        if T and T.Character and T.Character:FindFirstChild("Head") then
            local headPos = T.Character.Head.Position
            local headCF = T.Character.Head.CFrame
            
            if Config.SilentAim then
                if method == "Raycast" then
                    args[2] = (headPos - args[1]).Unit * 1000
                    if Config.Wallbang then
                        local params = args[3] or RaycastParams.new()
                        params.FilterType = Enum.RaycastFilterType.Exclude
                        local currentFilter = params.FilterDescendantsInstances or {}
                        table.insert(currentFilter, workspace)
                        params.FilterDescendantsInstances = currentFilter
                        args[3] = params
                    end
                    return oldNamecall(self, unpack(args))
                elseif method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
                    local origin = args[1].Origin
                    args[1] = Ray.new(origin, (headPos - origin).Unit * 1000)
                    if Config.Wallbang and method == "FindPartOnRayWithIgnoreList" then
                        local ignoreList = args[2] or {}
                        table.insert(ignoreList, workspace)
                        args[2] = ignoreList
                    end
                    return oldNamecall(self, unpack(args))
                elseif method == "FireServer" and tostring(self) ~= "CharacterSoundEvent" then
                    for i, v in ipairs(args) do
                        if typeof(v) == "Vector3" then
                            args[i] = headPos
                        elseif typeof(v) == "CFrame" then
                            args[i] = headCF
                        end
                    end
                    return oldNamecall(self, unpack(args))
                end
            end

            if Config.Wallbang and not Config.SilentAim then
                if method == "Raycast" then
                    local params = args[3] or RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    local currentFilter = params.FilterDescendantsInstances or {}
                    table.insert(currentFilter, workspace)
                    params.FilterDescendantsInstances = currentFilter
                    args[3] = params
                    return oldNamecall(self, unpack(args))
                elseif method == "FindPartOnRayWithIgnoreList" then
                    local ignoreList = args[2] or {}
                    table.insert(ignoreList, workspace)
                    args[2] = ignoreList
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    
    return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

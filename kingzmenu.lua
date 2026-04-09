-- KINGZ MENU V2 
-- Script Universal

-- Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Configurações Globais
local Settings = {
    -- Player
    Fly = false,
    FlyActive = false,
    FlySpeed = 100,
    GodMode = false,
    NoClip = false,
    WalkSpeed = 16,
    JumpPower = 50,
    InfiniteJump = false,
    Invisible = false,
    
    -- Visual/ESP
    ESPName = false,
    ESPBox = false,
    ESPCorpo = false,
    ESPDistance = false,
    Fullbright = false,
    FreeCam = false,
    
    -- Combat
    Aimbot = false,
    AimbotFOV = 100,
    AimbotSmoothness = 5,
    ShowFOV = false,
    AimbotPrediction = true,
    AutoClick = false,
    AutoClickActive = false,
    ClickDelay = 100,
    
    -- Teleport
    ClickTP = false,
    TeleportTo = nil,
    
    -- Misc
    AntiAFK = false,
    ChatSpam = false,
    SpamMessage = "KINGZ MENU",
}

local currentFlyKey = Enum.KeyCode.F
local currentAimbotKey = Enum.KeyCode.Q
local currentFreeCamKey = Enum.KeyCode.C
local currentAutoClickKey = Enum.KeyCode.V
local espObjects = {}
local connections = {}
local flyBodyVelocity = nil
local flyBodyAngularVelocity = nil
local fovCircle = nil
local freeCamCFrame = nil
local originalCFrame = nil
local friendsList = {}
local antiAFKConnection = nil
local autoClickRunning = false

-- Função para arredondar cantos
local function roundify(guiObject, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = guiObject
end

-- Função para animar elementos
local function animateElement(element, targetProperty, targetValue, duration, easingStyle)
    local tween = TweenService:Create(
        element,
        TweenInfo.new(duration or 0.3, easingStyle or Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {[targetProperty] = targetValue}
    )
    tween:Play()
    return tween
end

-- GUI Principal
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KingzMenuUltimate"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Frame principal
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 700, 0, 500)
mainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
roundify(mainFrame, 15)

-- Efeito de brilho (será destruído manualmente no cleanup)
local glow = Instance.new("ImageLabel", mainFrame)
glow.Size = UDim2.new(1, 20, 1, 20)
glow.Position = UDim2.new(0, -10, 0, -10)
glow.BackgroundTransparency = 1
glow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
glow.ImageColor3 = Color3.fromRGB(100, 100, 255)
glow.ImageTransparency = 0.8
glow.ZIndex = -1

-- Título animado
local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleBar.BorderSizePixel = 0
roundify(titleBar, 15)

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.Text = "👑 KINGZ MENU ULTIMATE 👑"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

-- Animação do título
spawn(function()
    while title.Parent do
        animateElement(title, "TextColor3", Color3.fromRGB(255, 100, 100), 1)
        wait(1)
        animateElement(title, "TextColor3", Color3.fromRGB(100, 255, 100), 1)
        wait(1)
        animateElement(title, "TextColor3", Color3.fromRGB(100, 100, 255), 1)
        wait(1)
        animateElement(title, "TextColor3", Color3.fromRGB(255, 215, 0), 1)
        wait(1)
    end
end)

-- Botão fechar com animação
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -45, 0, 7.5)
closeBtn.Text = "✕"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 18
roundify(closeBtn, 8)

closeBtn.MouseEnter:Connect(function()
    animateElement(closeBtn, "BackgroundColor3", Color3.fromRGB(255, 70, 70), 0.2)
    animateElement(closeBtn, "Size", UDim2.new(0, 40, 0, 40), 0.2)
end)

closeBtn.MouseLeave:Connect(function()
    animateElement(closeBtn, "BackgroundColor3", Color3.fromRGB(200, 50, 50), 0.2)
    animateElement(closeBtn, "Size", UDim2.new(0, 35, 0, 35), 0.2)
end)

closeBtn.MouseButton1Click:Connect(function()
    animateElement(mainFrame, "Size", UDim2.new(0, 0, 0, 0), 0.5)
    wait(0.5)
    screenGui:Destroy()
end)

-- Sidebar
local sidebar = Instance.new("Frame", mainFrame)
sidebar.Size = UDim2.new(0, 180, 1, -50)
sidebar.Position = UDim2.new(0, 0, 0, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
sidebar.BorderSizePixel = 0
roundify(sidebar, 10)

-- Content Frame
local contentFrame = Instance.new("ScrollingFrame", mainFrame)
contentFrame.Size = UDim2.new(1, -180, 1, -50)
contentFrame.Position = UDim2.new(0, 180, 0, 50)
contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 10
contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
roundify(contentFrame, 10)

local contentLayout = Instance.new("UIListLayout", contentFrame)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Padding = UDim.new(0, 8)

-- Funções utilitárias
local function clearContent()
    for _, child in ipairs(contentFrame:GetChildren()) do
        if child:IsA("GuiObject") then 
            child:Destroy() 
        end
    end
end

local function createSection(title)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -15, 0, 35)
    section.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    section.BorderSizePixel = 0
    roundify(section, 8)
    
    local label = Instance.new("TextLabel", section)
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.Text = title
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 215, 0)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    section.Parent = contentFrame
    section.BackgroundTransparency = 1
    animateElement(section, "BackgroundTransparency", 0, 0.3)
    
    return section
end

local function createToggle(text, settingKey, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -15, 0, 40)
    btn.BackgroundColor3 = Settings[settingKey] and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(60, 60, 80)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Text = text .. ": " .. (Settings[settingKey] and "ON" or "OFF")
    btn.BorderSizePixel = 0
    roundify(btn, 8)

    btn.MouseEnter:Connect(function()
        animateElement(btn, "BackgroundColor3", Settings[settingKey] and Color3.fromRGB(100, 220, 100) or Color3.fromRGB(80, 80, 100), 0.2)
    end)

    btn.MouseLeave:Connect(function()
        animateElement(btn, "BackgroundColor3", Settings[settingKey] and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(60, 60, 80), 0.2)
    end)

    btn.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        btn.Text = text .. ": " .. (Settings[settingKey] and "ON" or "OFF")
        animateElement(btn, "BackgroundColor3", Settings[settingKey] and Color3.fromRGB(80, 200, 80) or Color3.fromRGB(60, 60, 80), 0.3)
        if callback then callback(Settings[settingKey]) end
    end)

    btn.Parent = contentFrame
    return btn
end

local function createSlider(text, min, max, default, settingKey, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -15, 0, 70)
    holder.BackgroundColor3 = Color3.fromRGB(45, 45, 70)
    holder.BorderSizePixel = 0
    roundify(holder, 8)

    local label = Instance.new("TextLabel", holder)
    label.Size = UDim2.new(1, -10, 0, 25)
    label.Position = UDim2.new(0, 5, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text .. ": " .. Settings[settingKey]
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 16
    label.TextXAlignment = Enum.TextXAlignment.Left

    local sliderBG = Instance.new("Frame", holder)
    sliderBG.Size = UDim2.new(1, -20, 0, 8)
    sliderBG.Position = UDim2.new(0, 10, 0, 45)
    sliderBG.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    sliderBG.BorderSizePixel = 0
    roundify(sliderBG, 4)

    local sliderFill = Instance.new("Frame", sliderBG)
    sliderFill.Size = UDim2.new((Settings[settingKey] - min) / (max - min), 0, 1, 0)
    sliderFill.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    sliderFill.BorderSizePixel = 0
    roundify(sliderFill, 4)

    local sliderKnob = Instance.new("TextButton", sliderBG)
    sliderKnob.Size = UDim2.new(0, 20, 0, 20)
    sliderKnob.Position = UDim2.new((Settings[settingKey] - min) / (max - min), -10, 0, -6)
    sliderKnob.Text = ""
    sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderKnob.BorderSizePixel = 0
    roundify(sliderKnob, 10)

    sliderKnob.MouseEnter:Connect(function()
        animateElement(sliderKnob, "Size", UDim2.new(0, 24, 0, 24), 0.2)
    end)

    sliderKnob.MouseLeave:Connect(function()
        animateElement(sliderKnob, "Size", UDim2.new(0, 20, 0, 20), 0.2)
    end)

    local dragging = false
    sliderKnob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    sliderKnob.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local percent = math.clamp((input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X, 0, 1)
            local value = math.floor(min + (max - min) * percent)
            label.Text = text .. ": " .. value
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderKnob.Position = UDim2.new(percent, -10, 0, -6)
            Settings[settingKey] = value
            if callback then callback(value) end
        end
    end)

    holder.Parent = contentFrame
    return holder
end

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -15, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 100)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Text = text
    btn.BorderSizePixel = 0
    roundify(btn, 8)

    btn.MouseEnter:Connect(function()
        animateElement(btn, "BackgroundColor3", Color3.fromRGB(90, 90, 120), 0.2)
    end)

    btn.MouseLeave:Connect(function()
        animateElement(btn, "BackgroundColor3", Color3.fromRGB(70, 70, 100), 0.2)
    end)

    btn.MouseButton1Click:Connect(function()
        animateElement(btn, "BackgroundColor3", Color3.fromRGB(50, 50, 80), 0.1)
        wait(0.1)
        animateElement(btn, "BackgroundColor3", Color3.fromRGB(70, 70, 100), 0.1)
        if callback then callback() end
    end)

    btn.Parent = contentFrame
    return btn
end

-- ==================== FUNÇÕES DAS FEATURES ====================

-- AIMBOT
local function setupAimbot()
    local function predictPosition(player, velocity)
        if Settings.AimbotPrediction and velocity then
            return player.Character.Head.Position + (velocity * 0.1)
        end
        return player.Character.Head.Position
    end

    local function getClosestPlayer()
        local closestPlayer = nil
        local shortestDistance = Settings.AimbotFOV
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
                if not table.find(friendsList, player.Name) then
                    local headPos = predictPosition(player, player.Character.HumanoidRootPart.Velocity)
                    local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
                    if onScreen then
                        local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                        if distance < shortestDistance then
                            closestPlayer = player
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
        
        return closestPlayer
    end
    
    if connections.aimbot then connections.aimbot:Disconnect() end
    if connections.aimbotInput then connections.aimbotInput:Disconnect() end
    
    local aimbotActive = false
    
    connections.aimbotInput = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == currentAimbotKey then
            aimbotActive = true
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == currentAimbotKey then
            aimbotActive = false
        end
    end)
    
    connections.aimbot = RunService.RenderStepped:Connect(function()
        if Settings.Aimbot and aimbotActive then
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local targetPosition = predictPosition(target, target.Character.HumanoidRootPart.Velocity)
                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPosition)
                local smoothFactor = (21 - Settings.AimbotSmoothness) / 20
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothFactor)
            end
        end
    end)
end

-- ESP
local function setupESP()
    for player, esp in pairs(espObjects) do
        if esp.nameGui then esp.nameGui:Destroy() end
        if esp.distanceGui then esp.distanceGui:Destroy() end
        if esp.boxOutline then esp.boxOutline:Remove() end
        if esp.skeletonLines then 
            for _, line in pairs(esp.skeletonLines) do
                line:Remove()
            end
        end
    end
    espObjects = {}
    
    if connections.espUpdate then connections.espUpdate:Disconnect() end
    if connections.playerRemoving then connections.playerRemoving:Disconnect() end
    
    local function getESPColor(player)
        if table.find(friendsList, player.Name) then
            return Color3.fromRGB(0, 255, 0)
        else
            return Color3.fromRGB(255, 255, 255)
        end
    end
    
    local function getPart(character, partNames)
        for _, name in ipairs(partNames) do
            local part = character:FindFirstChild(name)
            if part then return part end
        end
        return nil
    end
    
    local skeletonConnections = {
        {names = {"Head", "Head"}, targetNames = {"UpperTorso", "Torso", "HumanoidRootPart"}},
        {names = {"UpperTorso", "Torso", "HumanoidRootPart"}, targetNames = {"LowerTorso", "HumanoidRootPart"}},
        {names = {"UpperTorso", "Torso", "HumanoidRootPart"}, targetNames = {"LeftUpperArm", "LeftArm"}},
        {names = {"LeftUpperArm", "LeftArm"}, targetNames = {"LeftLowerArm", "LeftForearm"}},
        {names = {"LeftLowerArm", "LeftForearm"}, targetNames = {"LeftHand"}},
        {names = {"UpperTorso", "Torso", "HumanoidRootPart"}, targetNames = {"RightUpperArm", "RightArm"}},
        {names = {"RightUpperArm", "RightArm"}, targetNames = {"RightLowerArm", "RightForearm"}},
        {names = {"RightLowerArm", "RightForearm"}, targetNames = {"RightHand"}},
        {names = {"LowerTorso", "HumanoidRootPart"}, targetNames = {"LeftUpperLeg", "LeftLeg"}},
        {names = {"LeftUpperLeg", "LeftLeg"}, targetNames = {"LeftLowerLeg", "LeftFoot"}},
        {names = {"LeftLowerLeg", "LeftFoot"}, targetNames = {"LeftFoot"}},
        {names = {"LowerTorso", "HumanoidRootPart"}, targetNames = {"RightUpperLeg", "RightLeg"}},
        {names = {"RightUpperLeg", "RightLeg"}, targetNames = {"RightLowerLeg", "RightFoot"}},
        {names = {"RightLowerLeg", "RightFoot"}, targetNames = {"RightFoot"}}
    }
    
    local function createESPForPlayer(player)
        if player == LocalPlayer or espObjects[player] then return end
        if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
        
        local esp = {}
        local playerColor = getESPColor(player)
        local character = player.Character
        
        if Settings.ESPName then
            local nameGui = Instance.new("BillboardGui")
            nameGui.Size = UDim2.new(0, 200, 0, 50)
            nameGui.StudsOffset = Vector3.new(0, 2.5, 0)
            nameGui.AlwaysOnTop = true
            nameGui.Parent = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
            
            local nameLabel = Instance.new("TextLabel", nameGui)
            nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = player.Name
            nameLabel.TextColor3 = playerColor
            nameLabel.TextStrokeTransparency = 0
            nameLabel.Font = Enum.Font.SourceSansBold
            nameLabel.TextSize = 16
            esp.nameLabel = nameLabel
            esp.nameGui = nameGui
        end
        
        if Settings.ESPDistance then
            local distanceGui = Instance.new("BillboardGui")
            distanceGui.Size = UDim2.new(0, 100, 0, 30)
            distanceGui.StudsOffset = Vector3.new(0, -2.5, 0)
            distanceGui.AlwaysOnTop = true
            distanceGui.Parent = character:FindFirstChild("HumanoidRootPart")
            
            local distanceLabel = Instance.new("TextLabel", distanceGui)
            distanceLabel.Size = UDim2.new(1, 0, 1, 0)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.TextColor3 = playerColor
            distanceLabel.TextStrokeTransparency = 0
            distanceLabel.Font = Enum.Font.SourceSansBold
            distanceLabel.TextSize = 14
            distanceLabel.Text = "0m"
            esp.distanceLabel = distanceLabel
            esp.distanceGui = distanceGui
        end
        
        if Settings.ESPBox then
            local boxOutline = Drawing.new("Square")
            boxOutline.Visible = false
            boxOutline.Color = playerColor
            boxOutline.Thickness = 2
            boxOutline.Transparency = 1
            boxOutline.Filled = false
            esp.boxOutline = boxOutline
        end
        
        if Settings.ESPCorpo then
            esp.skeletonLines = {}
            for _, conn in ipairs(skeletonConnections) do
                local line = Drawing.new("Line")
                line.Visible = false
                line.Color = playerColor
                line.Thickness = 2
                line.Transparency = 1
                table.insert(esp.skeletonLines, line)
            end
        end
        
        espObjects[player] = esp
    end
    
    connections.espUpdate = RunService.RenderStepped:Connect(function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local hasAnyESP = Settings.ESPName or Settings.ESPDistance or Settings.ESPBox or Settings.ESPCorpo
                if hasAnyESP and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    createESPForPlayer(player)
                    
                    local esp = espObjects[player]
                    if esp then
                        local playerColor = getESPColor(player)
                        local character = player.Character
                        
                        if esp.nameLabel then esp.nameLabel.TextColor3 = playerColor end
                        if esp.distanceLabel then esp.distanceLabel.TextColor3 = playerColor end
                        if esp.boxOutline then esp.boxOutline.Color = playerColor end
                        
                        if esp.distanceLabel and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local distance = (character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            esp.distanceLabel.Text = math.floor(distance) .. "m"
                        end
                        
                        if esp.boxOutline then
                            local hrp = character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                                if onScreen then
                                    local size = Vector2.new(1500 / vector.Z, 2000 / vector.Z)
                                    esp.boxOutline.Size = size
                                    esp.boxOutline.Position = Vector2.new(vector.X - size.X / 2, vector.Y - size.Y / 2)
                                    esp.boxOutline.Visible = true
                                else
                                    esp.boxOutline.Visible = false
                                end
                            end
                        end
                        
                        if esp.skeletonLines then
                            for i, conn in ipairs(skeletonConnections) do
                                local line = esp.skeletonLines[i]
                                if line then
                                    local part1 = getPart(character, conn.names)
                                    local part2 = getPart(character, conn.targetNames)
                                    if part1 and part2 then
                                        local pos1, on1 = Camera:WorldToViewportPoint(part1.Position)
                                        local pos2, on2 = Camera:WorldToViewportPoint(part2.Position)
                                        if on1 and on2 then
                                            line.From = Vector2.new(pos1.X, pos1.Y)
                                            line.To = Vector2.new(pos2.X, pos2.Y)
                                            line.Color = playerColor
                                            line.Visible = true
                                        else
                                            line.Visible = false
                                        end
                                    else
                                        line.Visible = false
                                    end
                                end
                            end
                        end
                    end
                else
                    if espObjects[player] then
                        local esp = espObjects[player]
                        if esp.nameGui then esp.nameGui:Destroy() end
                        if esp.distanceGui then esp.distanceGui:Destroy() end
                        if esp.boxOutline then esp.boxOutline:Remove() end
                        if esp.skeletonLines then 
                            for _, line in pairs(esp.skeletonLines) do
                                line:Remove()
                            end
                        end
                        espObjects[player] = nil
                    end
                end
            end
        end
    end)
    
    connections.playerRemoving = Players.PlayerRemoving:Connect(function(player)
        if espObjects[player] then
            local esp = espObjects[player]
            if esp.nameGui then esp.nameGui:Destroy() end
            if esp.distanceGui then esp.distanceGui:Destroy() end
            if esp.boxOutline then esp.boxOutline:Remove() end
            if esp.skeletonLines then 
                for _, line in pairs(esp.skeletonLines) do
                    line:Remove()
                end
            end
            espObjects[player] = nil
        end
    end)
end

-- FOV CIRCLE
local function createFOVCircle()
    if fovCircle then fovCircle:Remove() end
    
    fovCircle = Drawing.new("Circle")
    fovCircle.Thickness = 2
    fovCircle.NumSides = 50
    fovCircle.Radius = Settings.AimbotFOV
    fovCircle.Filled = false
    fovCircle.Visible = Settings.ShowFOV
    fovCircle.ZIndex = 999
    fovCircle.Transparency = 1
    fovCircle.Color = Color3.new(1, 1, 1)
    
    connections.fovUpdate = RunService.RenderStepped:Connect(function()
        if Settings.ShowFOV and fovCircle then
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            fovCircle.Radius = Settings.AimbotFOV
            fovCircle.Visible = true
        elseif fovCircle then
            fovCircle.Visible = false
        end
    end)
end

-- FREECAM
local function setupFreeCam()
    connections.freeCam = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == currentFreeCamKey then
            Settings.FreeCam = not Settings.FreeCam
            if Settings.FreeCam then
                originalCFrame = Camera.CFrame
                freeCamCFrame = Camera.CFrame
                Camera.CameraType = Enum.CameraType.Scriptable
            else
                Camera.CameraType = Enum.CameraType.Custom
                Camera.CFrame = originalCFrame
            end
        end
    end)
    
    connections.freeCamUpdate = RunService.RenderStepped:Connect(function()
        if Settings.FreeCam and freeCamCFrame then
            local speed = 50
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then speed = 100 end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then speed = 10 end
            
            local direction = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + freeCamCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - freeCamCFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - freeCamCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + freeCamCFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.E) then direction = direction + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.Q) then direction = direction - Vector3.new(0, 1, 0) end
            
            freeCamCFrame = freeCamCFrame + direction * speed * (1/60)
            Camera.CFrame = freeCamCFrame
        end
    end)
    
    connections.freeCamMouse = Mouse.Move:Connect(function()
        if Settings.FreeCam then
            local deltaX = Mouse.Delta.X * 0.004
            local deltaY = Mouse.Delta.Y * 0.004
            freeCamCFrame = freeCamCFrame * CFrame.Angles(-deltaY, -deltaX, 0)
        end
    end)
end

-- AUTOCLICK
local function startAutoClick()
    if autoClickRunning then return end
    autoClickRunning = true
    spawn(function()
        while autoClickRunning and Settings.AutoClickActive and Settings.AutoClick do
            mouse1click()
            wait(Settings.ClickDelay / 1000)
        end
    end)
end

local function stopAutoClick()
    autoClickRunning = false
end

local function setupAutoClick()
    if connections.autoClickToggle then connections.autoClickToggle:Disconnect() end
    
    connections.autoClickToggle = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == currentAutoClickKey and Settings.AutoClick then
            Settings.AutoClickActive = not Settings.AutoClickActive
            if Settings.AutoClickActive then
                startAutoClick()
            else
                stopAutoClick()
            end
        end
    end)
end

-- INVISIBILITY
local function setupInvisible()
    local function toggleInvisible()
        if Settings.Invisible and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Transparency = 1
                elseif part:IsA("Accessory") then
                    part.Handle.Transparency = 1
                end
            end
            if LocalPlayer.Character:FindFirstChild("Head") then
                LocalPlayer.Character.Head.face.Transparency = 1
            end
        else
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0
                    elseif part:IsA("Accessory") then
                        part.Handle.Transparency = 0
                    end
                end
                if LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character.Head:FindFirstChild("face") then
                    LocalPlayer.Character.Head.face.Transparency = 0
                end
            end
        end
    end
    
    connections.invisible = RunService.Heartbeat:Connect(function()
        if Settings.Invisible then
            toggleInvisible()
        end
    end)
end

-- FLY SYSTEM
local function setupFly()
    local function enableFly()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = LocalPlayer.Character.HumanoidRootPart
        
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyAngularVelocity then flyBodyAngularVelocity:Destroy() end
        
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = hrp
        
        flyBodyAngularVelocity = Instance.new("BodyAngularVelocity")
        flyBodyAngularVelocity.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        flyBodyAngularVelocity.AngularVelocity = Vector3.new(0, 0, 0)
        flyBodyAngularVelocity.Parent = hrp
    end
    
    local function disableFly()
        if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
        if flyBodyAngularVelocity then flyBodyAngularVelocity:Destroy() flyBodyAngularVelocity = nil end
    end
    
    if connections.flyUpdate then connections.flyUpdate:Disconnect() end
    if connections.flyToggle then connections.flyToggle:Disconnect() end
    
    connections.flyUpdate = RunService.RenderStepped:Connect(function()
        if Settings.FlyActive and flyBodyVelocity and LocalPlayer.Character then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local direction = Vector3.new(0, 0, 0)
            local cameraCFrame = Camera.CFrame
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + cameraCFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - cameraCFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - cameraCFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + cameraCFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end
            
            if direction.Magnitude > 0 then
                flyBodyVelocity.Velocity = direction.Unit * Settings.FlySpeed
            else
                flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end)
    
    connections.flyToggle = UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == currentFlyKey and Settings.Fly then
            Settings.FlyActive = not Settings.FlyActive
            if Settings.FlyActive then
                enableFly()
            else
                disableFly()
            end
        end
    end)
end

-- GodMode, NoClip, SpeedHack, ClickTP, AntiAFK
local function setupGodMode()
    if connections.godMode then connections.godMode:Disconnect() end
    connections.godMode = RunService.Heartbeat:Connect(function()
        if Settings.GodMode and LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Health = humanoid.MaxHealth
            end
        end
    end)
end

local function setupNoClip()
    if connections.noClip then connections.noClip:Disconnect() end
    connections.noClip = RunService.Stepped:Connect(function()
        if Settings.NoClip and LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function setupSpeedHack()
    if connections.speedHack then connections.speedHack:Disconnect() end
    connections.speedHack = RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            local humanoid = LocalPlayer.Character.Humanoid
            humanoid.WalkSpeed = Settings.WalkSpeed
            humanoid.JumpPower = Settings.JumpPower
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(character)
    wait(0.5)
    local humanoid = character:WaitForChild("Humanoid", 2)
    if humanoid then
        humanoid.WalkSpeed = Settings.WalkSpeed
        humanoid.JumpPower = Settings.JumpPower
    end
end)

local function setupClickTP()
    if connections.clickTP then connections.clickTP:Disconnect() end
    connections.clickTP = Mouse.Button1Down:Connect(function()
        if Settings.ClickTP and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 5, 0))
        end
    end)
end

local function setupAntiAFK()
    if antiAFKConnection then antiAFKConnection:Disconnect() end
    
    local function doHumanActivity()
        if not Settings.AntiAFK then return end
        
        local activity = math.random(1, 4)
        
        if activity == 1 then
            local deltaX = math.random(-50, 50)
            local deltaY = math.random(-30, 30)
            mousemoverel(deltaX, deltaY)
        elseif activity == 2 then
            local keys = {Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S, Enum.KeyCode.D}
            local key = keys[math.random(1, #keys)]
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local originalVel = hrp.Velocity
                local direction = Vector3.new()
                if key == Enum.KeyCode.W then direction = Camera.CFrame.LookVector
                elseif key == Enum.KeyCode.S then direction = -Camera.CFrame.LookVector
                elseif key == Enum.KeyCode.A then direction = -Camera.CFrame.RightVector
                elseif key == Enum.KeyCode.D then direction = Camera.CFrame.RightVector end
                hrp.Velocity = direction * 5
                wait(0.3)
                hrp.Velocity = originalVel
            end
        elseif activity == 3 then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                local humanoid = LocalPlayer.Character.Humanoid
                if humanoid.FloorMaterial ~= Enum.Material.Air then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        elseif activity == 4 then
            if not Settings.FreeCam then
                local originalCF = Camera.CFrame
                local angles = math.rad(math.random(-15, 15))
                local newCF = originalCF * CFrame.Angles(0, angles, 0)
                for i = 1, 10 do
                    Camera.CFrame = originalCF:Lerp(newCF, i/10)
                    wait(0.02)
                end
                wait(0.2)
                for i = 1, 10 do
                    Camera.CFrame = newCF:Lerp(originalCF, i/10)
                    wait(0.02)
                end
            end
        end
    end
    
    antiAFKConnection = RunService.Heartbeat:Connect(function()
        if Settings.AntiAFK then
            local delay = math.random(30, 90)
            wait(delay)
            doHumanActivity()
        end
    end)
end

-- Friends system
local function addFriend(playerName)
    if not table.find(friendsList, playerName) then
        table.insert(friendsList, playerName)
        setupESP()
    end
end

local function removeFriend(playerName)
    local index = table.find(friendsList, playerName)
    if index then
        table.remove(friendsList, index)
        setupESP()
    end
end

-- ==================== CRIAÇÃO DAS ABAS ====================
local tabs = {
    {Name = "⚔️ Combat", Icon = "⚔️", Callback = function()
        clearContent()
        
        createSection("⚔️ Aimbot Settings")
        createToggle("Aimbot", "Aimbot", function(enabled)
            if enabled then 
                setupAimbot()
                createFOVCircle()
            else
                if fovCircle then fovCircle:Remove() fovCircle = nil end
            end
        end)
        
        createButton("Set Aimbot Keybind [" .. currentAimbotKey.Name .. "]", function()
            local aimbotBtn = contentFrame:GetChildren()[#contentFrame:GetChildren()]
            aimbotBtn.Text = "Press any key..."
            local listeningForKey = true
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if listeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentAimbotKey = input.KeyCode
                    aimbotBtn.Text = "Set Aimbot Keybind [" .. input.KeyCode.Name .. "]"
                    listeningForKey = false
                    connection:Disconnect()
                    setupAimbot()
                end
            end)
        end)
        
        createSlider("Aimbot FOV", 50, 500, Settings.AimbotFOV, "AimbotFOV", function(value)
            if fovCircle then fovCircle.Radius = value end
        end)
        
        createSlider("Smoothness (1=Strong,20=Smooth)", 1, 20, Settings.AimbotSmoothness, "AimbotSmoothness")
        
        createToggle("Show FOV Circle", "ShowFOV", function(enabled)
            if enabled and Settings.Aimbot then
                createFOVCircle()
            elseif fovCircle then
                fovCircle:Remove()
                fovCircle = nil
            end
        end)
        
        createToggle("Prediction", "AimbotPrediction")
        
        createSection("🎯 Auto Combat")
        createToggle("Auto Click", "AutoClick", function(enabled)
            if enabled then 
                setupAutoClick()
            else
                Settings.AutoClickActive = false
                stopAutoClick()
            end
        end)
        
        createButton("Set AutoClick Keybind [" .. currentAutoClickKey.Name .. "]", function()
            local clickBtn = contentFrame:GetChildren()[#contentFrame:GetChildren()]
            clickBtn.Text = "Press any key..."
            local listeningForKey = true
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if listeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentAutoClickKey = input.KeyCode
                    clickBtn.Text = "Set AutoClick Keybind [" .. input.KeyCode.Name .. "]"
                    listeningForKey = false
                    connection:Disconnect()
                    setupAutoClick()
                end
            end)
        end)
        
        createSlider("Click Delay (ms)", 10, 1000, Settings.ClickDelay, "ClickDelay")
        
        createSection("👥 Friends System")
        local friendsContainer = Instance.new("ScrollingFrame")
        friendsContainer.Size = UDim2.new(1, -15, 0, 220)
        friendsContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
        friendsContainer.BorderSizePixel = 0
        friendsContainer.ScrollBarThickness = 8
        friendsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        roundify(friendsContainer, 8)
        friendsContainer.Parent = contentFrame
        
        local friendsListLayout = Instance.new("UIListLayout", friendsContainer)
        friendsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        friendsListLayout.Padding = UDim.new(0, 3)
        
        local playerButtons = {}
        
        local function updateFriendsList()
            for playerName, btn in pairs(playerButtons) do
                if not Players:FindFirstChild(playerName) then
                    btn:Destroy()
                    playerButtons[playerName] = nil
                end
            end
            
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local btn = playerButtons[player.Name]
                    if not btn then
                        btn = Instance.new("TextButton")
                        btn.Size = UDim2.new(1, -10, 0, 35)
                        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                        btn.TextColor3 = Color3.new(1, 1, 1)
                        btn.Font = Enum.Font.SourceSans
                        btn.TextSize = 15
                        btn.BorderSizePixel = 0
                        roundify(btn, 6)
                        btn.Parent = friendsContainer
                        playerButtons[player.Name] = btn
                        
                        btn.MouseButton1Click:Connect(function()
                            if table.find(friendsList, player.Name) then
                                removeFriend(player.Name)
                                btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                                btn.Text = "➕ " .. player.Name
                            else
                                addFriend(player.Name)
                                btn.BackgroundColor3 = Color3.fromRGB(80, 120, 80)
                                btn.Text = "✔️ " .. player.Name
                            end
                        end)
                        
                        btn.MouseEnter:Connect(function()
                            animateElement(btn, "BackgroundColor3", Color3.fromRGB(80, 80, 100), 0.2)
                        end)
                        btn.MouseLeave:Connect(function()
                            if table.find(friendsList, player.Name) then
                                animateElement(btn, "BackgroundColor3", Color3.fromRGB(80, 120, 80), 0.2)
                            else
                                animateElement(btn, "BackgroundColor3", Color3.fromRGB(60, 60, 80), 0.2)
                            end
                        end)
                    end
                    
                    if table.find(friendsList, player.Name) then
                        btn.BackgroundColor3 = Color3.fromRGB(80, 120, 80)
                        btn.Text = "✔️ " .. player.Name
                    else
                        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                        btn.Text = "➕ " .. player.Name
                    end
                end
            end
            
            friendsContainer.CanvasSize = UDim2.new(0, 0, 0, friendsListLayout.AbsoluteContentSize.Y + 10)
        end
        
        spawn(function()
            while friendsContainer and friendsContainer.Parent do
                updateFriendsList()
                wait(0.5)
            end
        end)
        
        createButton("🗑️ Clear All Friends", function()
            friendsList = {}
            updateFriendsList()
            setupESP()
        end)
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
    end},

    {Name = "👁️ Visual", Icon = "👁️", Callback = function()
        clearContent()
        
        createSection("👁️ ESP Settings")
        createToggle("ESP Names", "ESPName", function(enabled)
            setupESP()
        end)
        createToggle("ESP Boxes", "ESPBox", function(enabled)
            setupESP()
        end)
        createToggle("ESP Corpo", "ESPCorpo", function(enabled)
            setupESP()
        end)
        createToggle("ESP Distance", "ESPDistance", function(enabled)
            setupESP()
        end)
        
        createSection("🌟 World")
        createToggle("Fullbright", "Fullbright", function(enabled)
            if enabled then
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            else
                Lighting.Brightness = 1
                Lighting.ClockTime = 8
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = true
                Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
            end
        end)
        
        createToggle("FreeCam", "FreeCam", function(enabled)
            if enabled then setupFreeCam() end
        end)
        
        createButton("Set FreeCam Keybind [" .. currentFreeCamKey.Name .. "]", function()
            local camBtn = contentFrame:GetChildren()[#contentFrame:GetChildren()]
            camBtn.Text = "Press any key..."
            local listeningForKey = true
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if listeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentFreeCamKey = input.KeyCode
                    camBtn.Text = "Set FreeCam Keybind [" .. input.KeyCode.Name .. "]"
                    listeningForKey = false
                    connection:Disconnect()
                    setupFreeCam()
                end
            end)
        end)
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
    end},

    {Name = "🏃 Player", Icon = "🏃", Callback = function()
        clearContent()
        
        createSection("🏃 Movement")
        createToggle("Fly", "Fly", function(enabled)
            if not enabled then
                Settings.FlyActive = false
                if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
                if flyBodyAngularVelocity then flyBodyAngularVelocity:Destroy() flyBodyAngularVelocity = nil end
            end
        end)
        
        createButton("Set Fly Keybind [" .. currentFlyKey.Name .. "]", function()
            local flyBtn = contentFrame:GetChildren()[#contentFrame:GetChildren()]
            flyBtn.Text = "Press any key..."
            local listeningForKey = true
            local connection
            connection = UserInputService.InputBegan:Connect(function(input)
                if listeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentFlyKey = input.KeyCode
                    flyBtn.Text = "Set Fly Keybind [" .. input.KeyCode.Name .. "]"
                    listeningForKey = false
                    connection:Disconnect()
                    setupFly()
                end
            end)
        end)
        
        createSlider("Fly Speed", 50, 1000, Settings.FlySpeed, "FlySpeed")
        
        createToggle("No Clip", "NoClip", function(enabled)
            if enabled then setupNoClip() end
        end)
        
        createToggle("Infinite Jump", "InfiniteJump")
        
        createSlider("Walk Speed", 16, 1000, Settings.WalkSpeed, "WalkSpeed")
        
        createSlider("Jump Power", 50, 500, Settings.JumpPower, "JumpPower")
        
        createSection("🛡️ Protection & Utilities")
        createToggle("God Mode", "GodMode", function(enabled)
            if enabled then setupGodMode() end
        end)
        
        createToggle("Invisibility", "Invisible", function(enabled)
            if enabled then setupInvisible() end
        end)
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
    end},

    {Name = "📍 Teleport", Icon = "📍", Callback = function()
        clearContent()
        
        createSection("📍 Teleport")
        createToggle("Click TP", "ClickTP", function(enabled)
            if enabled then setupClickTP() end
        end)
        
        local playersList = Instance.new("ScrollingFrame")
        playersList.Size = UDim2.new(1, -15, 0, 200)
        playersList.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
        playersList.BorderSizePixel = 0
        playersList.ScrollBarThickness = 8
        playersList.CanvasSize = UDim2.new(0, 0, 0, 0)
        roundify(playersList, 8)
        playersList.Parent = contentFrame
        
        local playersLayout = Instance.new("UIListLayout", playersList)
        playersLayout.SortOrder = Enum.SortOrder.LayoutOrder
        playersLayout.Padding = UDim.new(0, 3)
        
        local function refreshPlayerList()
            for _, child in pairs(playersList:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            for i, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, -10, 0, 30)
                    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
                    btn.TextColor3 = Color3.new(1, 1, 1)
                    btn.Font = Enum.Font.SourceSans
                    btn.TextSize = 16
                    btn.Text = "TP to " .. player.Name
                    btn.BorderSizePixel = 0
                    roundify(btn, 6)
                    btn.Parent = playersList
                    
                    btn.MouseEnter:Connect(function()
                        animateElement(btn, "BackgroundColor3", Color3.fromRGB(80, 80, 100), 0.2)
                    end)
                    
                    btn.MouseLeave:Connect(function()
                        animateElement(btn, "BackgroundColor3", Color3.fromRGB(60, 60, 80), 0.2)
                    end)
                    
                    btn.MouseButton1Click:Connect(function()
                        if LocalPlayer.Character and player.Character and 
                           LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                           player.Character:FindFirstChild("HumanoidRootPart") then
                            LocalPlayer.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                        end
                    end)
                end
            end
            
            playersList.CanvasSize = UDim2.new(0, 0, 0, playersLayout.AbsoluteContentSize.Y + 10)
        end
        
        refreshPlayerList()
        createButton("🔄 Refresh Players", refreshPlayerList)
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
    end},

    {Name = "🔧 Tools", Icon = "🔧", Callback = function()
        clearContent()
        
        createSection("🔧 Utilities")
        createToggle("Anti AFK", "AntiAFK", function(enabled)
            if enabled then 
                setupAntiAFK() 
            else
                if antiAFKConnection then antiAFKConnection:Disconnect() end
            end
        end)
        
        createSection("💬 Chat")
        createToggle("Chat Spam", "ChatSpam")
        
        local spamInput = Instance.new("TextBox")
        spamInput.Size = UDim2.new(1, -15, 0, 40)
        spamInput.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        spamInput.TextColor3 = Color3.new(1, 1, 1)
        spamInput.Font = Enum.Font.SourceSans
        spamInput.TextSize = 16
        spamInput.PlaceholderText = "Spam Message..."
        spamInput.Text = Settings.SpamMessage
        spamInput.BorderSizePixel = 0
        roundify(spamInput, 8)
        spamInput.Parent = contentFrame
        
        spamInput.FocusLost:Connect(function()
            Settings.SpamMessage = spamInput.Text
        end)
        
        createSection("⚙️ Settings")
        createButton("🔄 Reset All Settings", function()
            for key, _ in pairs(Settings) do
                if typeof(Settings[key]) == "boolean" then
                    Settings[key] = false
                elseif typeof(Settings[key]) == "number" then
                    if key == "WalkSpeed" then Settings[key] = 16
                    elseif key == "JumpPower" then Settings[key] = 50
                    elseif key == "FlySpeed" then Settings[key] = 100
                    elseif key == "AimbotFOV" then Settings[key] = 100
                    elseif key == "AimbotSmoothness" then Settings[key] = 5
                    elseif key == "ClickDelay" then Settings[key] = 100
                    end
                end
            end
            Settings.FlyActive = false
            Settings.AutoClickActive = false
            stopAutoClick()
            if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
            if flyBodyAngularVelocity then flyBodyAngularVelocity:Destroy() flyBodyAngularVelocity = nil end
            
            if LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.WalkSpeed = 16
                    humanoid.JumpPower = 50
                end
            end
            
            Lighting.Brightness = 1
            Lighting.ClockTime = 8
            Lighting.GlobalShadows = true
            
            friendsList = {}
            setupESP()
            print("All settings reset!")
        end)
        
        createButton("❌ Destroy Script", function()
            animateElement(mainFrame, "Size", UDim2.new(0, 0, 0, 0), 0.5)
            wait(0.5)
            screenGui:Destroy()
        end)
        
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
    end}
}

-- Criação dos botões da sidebar
local sidebarLayout = Instance.new("UIListLayout", sidebar)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 8)

for i, tab in ipairs(tabs) do
    local btn = Instance.new("TextButton", sidebar)
    btn.Size = UDim2.new(1, -15, 0, 45)
    btn.Text = tab.Name
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.BorderSizePixel = 0
    btn.LayoutOrder = i
    roundify(btn, 8)
    
    btn.MouseEnter:Connect(function()
        if btn.BackgroundColor3 ~= Color3.fromRGB(70, 120, 200) then
            animateElement(btn, "BackgroundColor3", Color3.fromRGB(70, 70, 90), 0.2)
        end
        animateElement(btn, "Size", UDim2.new(1, -10, 0, 50), 0.2)
    end)
    
    btn.MouseLeave:Connect(function()
        if btn.BackgroundColor3 ~= Color3.fromRGB(70, 120, 200) then
            animateElement(btn, "BackgroundColor3", Color3.fromRGB(50, 50, 70), 0.2)
        end
        animateElement(btn, "Size", UDim2.new(1, -15, 0, 45), 0.2)
    end)
    
    btn.MouseButton1Click:Connect(function()
        for _, child in pairs(sidebar:GetChildren()) do
            if child:IsA("TextButton") then
                animateElement(child, "BackgroundColor3", Color3.fromRGB(50, 50, 70), 0.3)
            end
        end
        animateElement(btn, "BackgroundColor3", Color3.fromRGB(70, 120, 200), 0.3)
        
        animateElement(contentFrame, "Position", UDim2.new(0, 200, 0, 50), 0.2)
        wait(0.2)
        tab.Callback()
        animateElement(contentFrame, "Position", UDim2.new(0, 180, 0, 50), 0.2)
    end)
end

-- Ativar primeira aba (Combate)
if sidebar:GetChildren()[2] and sidebar:GetChildren()[2]:IsA("TextButton") then
    animateElement(sidebar:GetChildren()[2], "BackgroundColor3", Color3.fromRGB(70, 120, 200), 0.5)
end
tabs[1].Callback()

-- Setup inicial
setupFly()
setupGodMode()
setupNoClip()
setupSpeedHack()
setupESP()
setupAimbot()
createFOVCircle()
setupClickTP()
setupAntiAFK()
setupFreeCam()
setupAutoClick()
setupInvisible()

-- Chat spam
spawn(function()
    while screenGui.Parent do
        if Settings.ChatSpam and Settings.SpamMessage ~= "" then
            pcall(function()
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Settings.SpamMessage, "All")
            end)
        end
        wait(1)
    end
end)

-- Infinite Jump
connections.infiniteJump = UserInputService.JumpRequest:Connect(function()
    if Settings.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- Toggle GUI com Insert
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        if screenGui.Enabled then
            animateElement(mainFrame, "Size", UDim2.new(0, 0, 0, 0), 0.3)
            wait(0.3)
            screenGui.Enabled = false
        else
            screenGui.Enabled = true
            mainFrame.Size = UDim2.new(0, 0, 0, 0)
            animateElement(mainFrame, "Size", UDim2.new(0, 700, 0, 500), 0.3)
        end
    end
end)

-- ==================== CLEANUP COMPLETO AO DESTRUIR O MENU ====================
screenGui.AncestryChanged:Connect(function()
    if not screenGui.Parent then
        -- 1. Desconectar todas as conexões
        for _, connection in pairs(connections) do
            pcall(function() if connection then connection:Disconnect() end end)
        end
        
        -- 2. Parar loops e atividades
        if antiAFKConnection then antiAFKConnection:Disconnect() end
        stopAutoClick()
        
        -- 3. Destruir ESP (BillboardGui, Drawings)
        for player, esp in pairs(espObjects) do
            pcall(function()
                if esp.nameGui then esp.nameGui:Destroy() end
                if esp.distanceGui then esp.distanceGui:Destroy() end
                if esp.boxOutline then esp.boxOutline:Remove() end
                if esp.skeletonLines then 
                    for _, line in pairs(esp.skeletonLines) do line:Remove() end
                end
            end)
        end
        espObjects = {}
        
        -- 4. Destruir desenhos e objetos físicos
        pcall(function()
            if fovCircle then fovCircle:Remove() end
            if flyBodyVelocity then flyBodyVelocity:Destroy() end
            if flyBodyAngularVelocity then flyBodyAngularVelocity:Destroy() end
            if glow then glow:Destroy() end  -- Remove o bloco de brilho
        end)
        
        -- 5. Restaurar todas as configurações do personagem
        if LocalPlayer.Character then
            local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
                humanoid.JumpPower = 50
                humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true) -- reativar pulo se necessário
            end
            
            -- Restaurar visibilidade e colisão
            for _, part in pairs(LocalPlayer.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                    part.Transparency = 0
                elseif part:IsA("Accessory") then
                    part.Handle.Transparency = 0
                end
            end
            
            if LocalPlayer.Character:FindFirstChild("Head") and LocalPlayer.Character.Head:FindFirstChild("face") then
                LocalPlayer.Character.Head.face.Transparency = 0
            end
        end
        
        -- 6. Restaurar iluminação
        Lighting.Brightness = 1
        Lighting.ClockTime = 8
        Lighting.GlobalShadows = true
        Lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        
        -- 7. Restaurar câmera (caso freecam estivesse ativa)
        if Camera then
            Camera.CameraType = Enum.CameraType.Custom
        end
        
        -- 8. Resetar todas as configurações para false (garantia)
        for key, value in pairs(Settings) do
            if typeof(value) == "boolean" then
                Settings[key] = false
            end
        end
        
        print("Kingz Menu destruído. Todas as funcionalidades foram desativadas e o jogo foi restaurado.")
    end
end)

-- Notificações
local function createNotification(text, duration, color)
    local notif = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    notif.Name = "KingzNotification"
    local frame = Instance.new("Frame", notif)
    frame.Size = UDim2.new(0, 350, 0, 80)
    frame.Position = UDim2.new(1, -370, 0, 20)
    frame.BackgroundColor3 = color or Color3.fromRGB(30, 30, 45)
    frame.BorderSizePixel = 0
    roundify(frame, 10)
    local glowNotif = Instance.new("Frame", frame)
    glowNotif.Size = UDim2.new(1, 4, 1, 4)
    glowNotif.Position = UDim2.new(0, -2, 0, -2)
    glowNotif.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    glowNotif.BackgroundTransparency = 0.8
    glowNotif.ZIndex = -1
    roundify(glowNotif, 12)
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Text = text
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    animateElement(frame, "Position", UDim2.new(1, -370, 0, 20), 0.5, Enum.EasingStyle.Back)
    game:GetService("Debris"):AddItem(notif, duration or 4)
    spawn(function()
        wait((duration or 4) - 0.5)
        animateElement(frame, "Position", UDim2.new(1, 0, 0, 20), 0.5)
    end)
end

mainFrame.Size = UDim2.new(0, 0, 0, 0)
animateElement(mainFrame, "Size", UDim2.new(0, 700, 0, 500), 1, Enum.EasingStyle.Back)

spawn(function()
    wait(1)
    createNotification("👑 KINGZ MENU ULTIMATE Loaded!\n🎮 Press [INSERT] to toggle\n✨ ESP: Friends Green, Enemies White\n📏 Distance below character\n🔫 AutoClick bind: " .. currentAutoClickKey.Name .. "\n✅ Menu fecha sem deixar lixo", 6, Color3.fromRGB(50, 150, 50))
    wait(2)
    createNotification("⚡ Keybinds:\nFly: [" .. currentFlyKey.Name .. "] (only if Fly ON)\nAimbot: [" .. currentAimbotKey.Name .. "]\nFreeCam: [" .. currentFreeCamKey.Name .. "]\nAutoClick: [" .. currentAutoClickKey.Name .. "]", 5, Color3.fromRGB(50, 100, 200))
end)

print("🌟" .. string.rep("=", 50) .. "🌟")
print("👑 KINGZ MENU ULTIMATE - CLEANUP CORRIGIDO")
print("✅ Ao destruir o menu, TODAS as funções são desativadas")
print("✅ O bloco de brilho (glow) é removido")
print("✅ Velocidade, pulo, invisibilidade, godmode, etc. são resetados")
print("✅ ESP, fly, aimbot, freecam, autoclick, anticlick, tudo desliga")
print("🌟" .. string.rep("=", 50) .. "🌟")
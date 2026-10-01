--========================================================
-- BeatBoss Hub
-- Auto Infinity Castle
-- Modern UI + Toggle + Unload + Self Cleanup
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ENV = (getgenv and getgenv()) or _G

--========================================================
-- SELF CLEANUP WHEN EXECUTED AGAIN
--========================================================

if ENV.BeatBossHub and ENV.BeatBossHub.Unload then
    pcall(function()
        ENV.BeatBossHub.Unload()
    end)
    task.wait(0.15)
end

local Hub = {
    Alive = true,
    AutoCastle = false,
    Connections = {},
    Worker = nil,
    Gui = nil,
}

ENV.BeatBossHub = Hub

--========================================================
-- HELPERS
--========================================================

local function connect(signal, callback)
    local c = signal:Connect(callback)
    table.insert(Hub.Connections, c)
    return c
end

local function tween(object, properties, duration)
    if not object or not object.Parent then
        return
    end

    local info = TweenInfo.new(
        duration or 0.16,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    TweenService:Create(object, info, properties):Play()
end

local function round(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
    return corner
end

local function addStroke(parent, color, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color
    s.Thickness = 1
    s.Transparency = transparency or 0
    s.Parent = parent
    return s
end

local function objectVisible(obj)
    if not obj or not obj.Parent then
        return false
    end

    if obj:IsA("GuiObject") and not obj.Visible then
        return false
    end

    local parent = obj.Parent

    while parent and parent ~= PlayerGui do
        if parent:IsA("GuiObject") and not parent.Visible then
            return false
        end
        parent = parent.Parent
    end

    return true
end

local function safeClick(button)
    if not Hub.Alive then
        return false
    end

    if not button or not button.Parent then
        return false
    end

    if button:IsA("GuiObject") and not objectVisible(button) then
        return false
    end

    -- Preferred executor method.
    if firesignal then
        local ok = pcall(function()
            if button:IsA("GuiButton") then
                firesignal(button.Activated)
            end
        end)

        if ok then
            return true
        end

        pcall(function()
            if button:IsA("GuiButton") then
                firesignal(button.MouseButton1Click)
            end
        end)
    end

    -- Fallback: real mouse event at button center.
    if button:IsA("GuiObject") then
        local center = button.AbsolutePosition + (button.AbsoluteSize / 2)

        local ok = pcall(function()
            VIM:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
            task.wait(0.04)
            VIM:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
        end)

        return ok
    end

    return false
end

local function waitForMain()
    local main = PlayerGui:FindFirstChild("Main")
    if main then
        return main
    end

    return PlayerGui:WaitForChild("Main", 15)
end

local function resolveGameObjects()
    local Main = waitForMain()
    if not Main then
        return nil
    end

    local InfinityFrame = Main:FindFirstChild("InfinityCastleFrame")
    local BattleFrame = Main:FindFirstChild("CastleStartFrame")
    local RewardsFrame = Main:FindFirstChild("CastleRewardsFrame")

    if not InfinityFrame then
        return nil
    end

    local InfinityMain = InfinityFrame:FindFirstChild("Main")
    if not InfinityMain then
        return nil
    end

    return {
        Main = Main,
        InfinityFrame = InfinityFrame,
        InfinityMain = InfinityMain,
        EquipBest = InfinityMain:FindFirstChild("EquipBest"),
        StartButton = InfinityMain:FindFirstChild("StartButton"),
        BattleFrame = BattleFrame,
        RewardsFrame = RewardsFrame,
    }
end

-- Best effort: automatically trigger the NPC prompt if executor supports it.
local function tryOpenInfinityCastle()
    if not fireproximityprompt then
        return false
    end

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local text = string.lower(
                tostring(obj.Name)
                .. " "
                .. tostring(obj.ActionText)
                .. " "
                .. tostring(obj.ObjectText)
            )

            if text:find("infinity", 1, true)
                or text:find("castle", 1, true)
            then
                local ok = pcall(function()
                    fireproximityprompt(obj)
                end)

                if ok then
                    return true
                end
            end
        end
    end

    return false
end

-- Reward/continue buttons have not been mapped exactly yet.
-- This safely looks for common button names/texts and clicks one visible match.
local function findRewardAction(rewardsFrame)
    if not rewardsFrame or not objectVisible(rewardsFrame) then
        return nil
    end

    local priorities = {
        "claim",
        "collect",
        "next",
        "continue",
        "retry",
        "ok",
        "close",
    }

    for _, wanted in ipairs(priorities) do
        for _, obj in ipairs(rewardsFrame:GetDescendants()) do
            if obj:IsA("GuiButton") and objectVisible(obj) then
                local text = string.lower(obj.Name)

                if obj:IsA("TextButton") then
                    text = text .. " " .. string.lower(obj.Text or "")
                end

                if text:find(wanted, 1, true) then
                    return obj
                end
            end
        end
    end

    return nil
end

--========================================================
-- UI
--========================================================

local Colors = {
    Background = Color3.fromRGB(14, 15, 19),
    Surface = Color3.fromRGB(21, 23, 28),
    Surface2 = Color3.fromRGB(29, 31, 38),
    Border = Color3.fromRGB(55, 58, 69),

    Text = Color3.fromRGB(244, 245, 247),
    Muted = Color3.fromRGB(150, 153, 166),

    Accent = Color3.fromRGB(103, 92, 255),
    Green = Color3.fromRGB(55, 199, 111),
    Red = Color3.fromRGB(224, 82, 82),
}

local oldGui = PlayerGui:FindFirstChild("BeatBossHubUI")
if oldGui then
    oldGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BeatBossHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

Hub.Gui = ScreenGui

local Window = Instance.new("Frame")
Window.Name = "Window"
Window.Size = UDim2.new(0, 410, 0, 305)
Window.Position = UDim2.new(0.5, -205, 0.32, 0)
Window.BackgroundColor3 = Colors.Background
Window.BorderSizePixel = 0
Window.Parent = ScreenGui
round(Window, 16)
addStroke(Window, Colors.Border, 0.2)

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 68)
Top.BackgroundTransparency = 1
Top.Parent = Window

local Logo = Instance.new("Frame")
Logo.Size = UDim2.new(0, 34, 0, 34)
Logo.Position = UDim2.new(0, 18, 0, 17)
Logo.BackgroundColor3 = Colors.Accent
Logo.BorderSizePixel = 0
Logo.Parent = Top
round(Logo, 10)

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.fromScale(1, 1)
LogoText.BackgroundTransparency = 1
LogoText.Text = "B"
LogoText.TextColor3 = Color3.new(1, 1, 1)
LogoText.TextSize = 17
LogoText.Font = Enum.Font.GothamBold
LogoText.Parent = Logo

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -130, 0, 24)
Title.Position = UDim2.new(0, 64, 0, 14)
Title.BackgroundTransparency = 1
Title.Text = "BeatBoss"
Title.TextColor3 = Colors.Text
Title.TextSize = 19
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -130, 0, 18)
Subtitle.Position = UDim2.new(0, 64, 0, 38)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Automation panel"
Subtitle.TextColor3 = Colors.Muted
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Top

local Minimize = Instance.new("TextButton")
Minimize.Size = UDim2.new(0, 34, 0, 34)
Minimize.Position = UDim2.new(1, -92, 0, 17)
Minimize.BackgroundColor3 = Colors.Surface2
Minimize.Text = "—"
Minimize.TextColor3 = Colors.Muted
Minimize.TextSize = 17
Minimize.Font = Enum.Font.GothamMedium
Minimize.AutoButtonColor = false
Minimize.Parent = Top
round(Minimize, 9)

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 34, 0, 34)
Close.Position = UDim2.new(1, -50, 0, 17)
Close.BackgroundColor3 = Colors.Surface2
Close.Text = "×"
Close.TextColor3 = Colors.Muted
Close.TextSize = 21
Close.Font = Enum.Font.GothamMedium
Close.AutoButtonColor = false
Close.Parent = Top
round(Close, 9)

local Card = Instance.new("Frame")
Card.Size = UDim2.new(1, -32, 0, 145)
Card.Position = UDim2.new(0, 16, 0, 72)
Card.BackgroundColor3 = Colors.Surface
Card.BorderSizePixel = 0
Card.Parent = Window
round(Card, 12)
addStroke(Card, Colors.Border, 0.35)

local FeatureTitle = Instance.new("TextLabel")
FeatureTitle.Size = UDim2.new(1, -110, 0, 24)
FeatureTitle.Position = UDim2.new(0, 16, 0, 15)
FeatureTitle.BackgroundTransparency = 1
FeatureTitle.Text = "Auto Infinity Castle"
FeatureTitle.TextColor3 = Colors.Text
FeatureTitle.TextSize = 15
FeatureTitle.Font = Enum.Font.GothamSemibold
FeatureTitle.TextXAlignment = Enum.TextXAlignment.Left
FeatureTitle.Parent = Card

local FeatureDesc = Instance.new("TextLabel")
FeatureDesc.Size = UDim2.new(1, -32, 0, 36)
FeatureDesc.Position = UDim2.new(0, 16, 0, 43)
FeatureDesc.BackgroundTransparency = 1
FeatureDesc.Text = "Auto Equip Best, Start, detect battle state and handle common reward/continue buttons."
FeatureDesc.TextColor3 = Colors.Muted
FeatureDesc.TextSize = 11
FeatureDesc.Font = Enum.Font.GothamMedium
FeatureDesc.TextWrapped = true
FeatureDesc.TextXAlignment = Enum.TextXAlignment.Left
FeatureDesc.TextYAlignment = Enum.TextYAlignment.Top
FeatureDesc.Parent = Card

local Toggle = Instance.new("TextButton")
Toggle.Size = UDim2.new(0, 54, 0, 30)
Toggle.Position = UDim2.new(1, -70, 0, 15)
Toggle.BackgroundColor3 = Colors.Surface2
Toggle.Text = ""
Toggle.AutoButtonColor = false
Toggle.Parent = Card
round(Toggle, 15)

local Knob = Instance.new("Frame")
Knob.Size = UDim2.new(0, 24, 0, 24)
Knob.Position = UDim2.new(0, 3, 0.5, -12)
Knob.BackgroundColor3 = Color3.fromRGB(215, 216, 220)
Knob.BorderSizePixel = 0
Knob.Parent = Toggle
round(Knob, 12)

local StatusHolder = Instance.new("Frame")
StatusHolder.Size = UDim2.new(1, -32, 0, 34)
StatusHolder.Position = UDim2.new(0, 16, 1, -46)
StatusHolder.BackgroundColor3 = Colors.Surface2
StatusHolder.BorderSizePixel = 0
StatusHolder.Parent = Card
round(StatusHolder, 9)

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 8, 0, 8)
StatusDot.Position = UDim2.new(0, 12, 0.5, -4)
StatusDot.BackgroundColor3 = Colors.Red
StatusDot.BorderSizePixel = 0
StatusDot.Parent = StatusHolder
round(StatusDot, 4)

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -40, 1, 0)
Status.Position = UDim2.new(0, 30, 0, 0)
Status.BackgroundTransparency = 1
Status.Text = "Disabled"
Status.TextColor3 = Colors.Muted
Status.TextSize = 11
Status.Font = Enum.Font.GothamMedium
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = StatusHolder

local Hint = Instance.new("TextLabel")
Hint.Size = UDim2.new(1, -32, 0, 22)
Hint.Position = UDim2.new(0, 16, 0, 224)
Hint.BackgroundTransparency = 1
Hint.Text = "RightShift: show / hide panel"
Hint.TextColor3 = Colors.Muted
Hint.TextSize = 10
Hint.Font = Enum.Font.GothamMedium
Hint.TextXAlignment = Enum.TextXAlignment.Left
Hint.Parent = Window

local Unload = Instance.new("TextButton")
Unload.Size = UDim2.new(0, 132, 0, 42)
Unload.Position = UDim2.new(1, -148, 1, -58)
Unload.BackgroundColor3 = Color3.fromRGB(46, 27, 30)
Unload.Text = "Unload Script"
Unload.TextColor3 = Color3.fromRGB(238, 115, 115)
Unload.TextSize = 12
Unload.Font = Enum.Font.GothamSemibold
Unload.AutoButtonColor = false
Unload.Parent = Window
round(Unload, 10)
addStroke(Unload, Color3.fromRGB(120, 52, 57), 0.25)

--========================================================
-- UI STATE
--========================================================

local function setStatus(text, good)
    if not Hub.Alive or not Status.Parent then
        return
    end

    Status.Text = text
    StatusDot.BackgroundColor3 = good and Colors.Green or Colors.Red
end

local function updateToggle()
    if Hub.AutoCastle then
        tween(Toggle, {BackgroundColor3 = Color3.fromRGB(37, 129, 72)})
        tween(Knob, {
            Position = UDim2.new(1, -27, 0.5, -12),
            BackgroundColor3 = Color3.new(1, 1, 1),
        })
    else
        tween(Toggle, {BackgroundColor3 = Colors.Surface2})
        tween(Knob, {
            Position = UDim2.new(0, 3, 0.5, -12),
            BackgroundColor3 = Color3.fromRGB(215, 216, 220),
        })
    end
end

--========================================================
-- AUTO CASTLE
--========================================================

local function runAutoCastle()
    if Hub.Worker then
        return
    end

    Hub.Worker = task.spawn(function()
        while Hub.Alive and Hub.AutoCastle do
            local G = resolveGameObjects()

            if not G then
                setStatus("Waiting for game UI...", false)
                task.wait(1)
                continue
            end

            if G.InfinityFrame and objectVisible(G.InfinityFrame) then
                setStatus("Equipping best units...", true)

                if G.EquipBest then
                    safeClick(G.EquipBest)
                end

                task.wait(0.55)

                if not Hub.Alive or not Hub.AutoCastle then
                    break
                end

                setStatus("Starting Infinity Castle...", true)

                if G.StartButton then
                    safeClick(G.StartButton)
                end

                local deadline = os.clock() + 10

                while Hub.Alive
                    and Hub.AutoCastle
                    and os.clock() < deadline
                do
                    if G.BattleFrame and objectVisible(G.BattleFrame) then
                        break
                    end

                    task.wait(0.2)
                end

                if G.BattleFrame and objectVisible(G.BattleFrame) then
                    setStatus("Battle in progress", true)
                else
                    setStatus("Start not confirmed - retrying", false)
                    task.wait(1.3)
                end

            elseif G.BattleFrame and objectVisible(G.BattleFrame) then
                setStatus("Battle in progress", true)

                repeat
                    task.wait(0.4)
                until
                    not Hub.Alive
                    or not Hub.AutoCastle
                    or not objectVisible(G.BattleFrame)

            elseif G.RewardsFrame and objectVisible(G.RewardsFrame) then
                setStatus("Handling rewards...", true)

                local action = findRewardAction(G.RewardsFrame)

                if action then
                    safeClick(action)
                    task.wait(0.8)
                else
                    setStatus("Reward screen - waiting", true)
                    task.wait(0.6)
                end

            else
                setStatus("Waiting for Infinity Castle...", true)

                -- If available, try to open the NPC prompt automatically.
                tryOpenInfinityCastle()
                task.wait(0.8)
            end
        end

        Hub.Worker = nil

        if Hub.Alive then
            setStatus("Disabled", false)
        end
    end)
end

--========================================================
-- UNLOAD
--========================================================

function Hub.Unload()
    if not Hub.Alive then
        return
    end

    Hub.Alive = false
    Hub.AutoCastle = false

    if Hub.Worker then
        pcall(function()
            task.cancel(Hub.Worker)
        end)
        Hub.Worker = nil
    end

    for _, connection in ipairs(Hub.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end

    table.clear(Hub.Connections)

    if Hub.Gui then
        pcall(function()
            Hub.Gui:Destroy()
        end)
        Hub.Gui = nil
    end

    if ENV.BeatBossHub == Hub then
        ENV.BeatBossHub = nil
    end
end

--========================================================
-- EVENTS
--========================================================

connect(Toggle.MouseButton1Click, function()
    if not Hub.Alive then
        return
    end

    Hub.AutoCastle = not Hub.AutoCastle
    updateToggle()

    if Hub.AutoCastle then
        setStatus("Enabled", true)
        runAutoCastle()
    else
        setStatus("Disabled", false)
    end
end)

connect(Unload.MouseButton1Click, function()
    tween(Unload, {BackgroundColor3 = Color3.fromRGB(89, 39, 44)}, 0.1)
    task.wait(0.08)
    Hub.Unload()
end)

connect(Close.MouseButton1Click, function()
    Hub.Unload()
end)

local minimized = false

connect(Minimize.MouseButton1Click, function()
    minimized = not minimized

    if minimized then
        Card.Visible = false
        Hint.Visible = false
        Unload.Visible = false

        tween(Window, {
            Size = UDim2.new(0, 410, 0, 68),
        })
    else
        tween(Window, {
            Size = UDim2.new(0, 410, 0, 305),
        })

        task.wait(0.08)
        Card.Visible = true
        Hint.Visible = true
        Unload.Visible = true
    end
end)

connect(UIS.InputBegan, function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.RightShift then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Drag window.
local dragging = false
local dragStart = nil
local startPosition = nil

connect(Top.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = Window.Position
    end
end)

connect(UIS.InputChanged, function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        Window.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

connect(UIS.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

updateToggle()
setStatus("Disabled", false)

print("[BeatBoss] Hub loaded.")

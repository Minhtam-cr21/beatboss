--========================================================
-- BEATBOSS HUB
-- Auto Infinity Castle
-- Modern UI + Safe Unload
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ENV = getgenv()

--========================================================
-- AUTO UNLOAD BẢN CŨ KHI EXECUTE LẠI
--========================================================

if ENV.BeatBossHub and ENV.BeatBossHub.Unload then
    pcall(function()
        ENV.BeatBossHub.Unload()
    end)

    task.wait(0.2)
end

local Hub = {
    Alive = true,
    AutoCastle = false,
    Connections = {},
    AutoTask = nil
}

ENV.BeatBossHub = Hub

--========================================================
-- GAME OBJECTS
--========================================================

local Main = PlayerGui:WaitForChild("Main")

local InfinityFrame =
    Main:WaitForChild("InfinityCastleFrame")

local InfinityMain =
    InfinityFrame:WaitForChild("Main")

local EquipBest =
    InfinityMain:WaitForChild("EquipBest")

local StartButton =
    InfinityMain:WaitForChild("StartButton")

local BattleFrame =
    Main:WaitForChild("CastleStartFrame")

local RewardsFrame =
    Main:WaitForChild("CastleRewardsFrame")

--========================================================
-- COLORS
--========================================================

local Colors = {
    Background = Color3.fromRGB(16, 17, 21),
    Surface = Color3.fromRGB(24, 25, 30),
    Surface2 = Color3.fromRGB(31, 32, 38),

    Border = Color3.fromRGB(52, 54, 63),

    Text = Color3.fromRGB(245, 245, 247),
    Muted = Color3.fromRGB(148, 151, 163),

    Green = Color3.fromRGB(57, 196, 105),
    GreenDark = Color3.fromRGB(37, 128, 70),

    Red = Color3.fromRGB(218, 72, 72),
    RedDark = Color3.fromRGB(132, 48, 48),

    Accent = Color3.fromRGB(112, 103, 255)
}

--========================================================
-- HELPERS
--========================================================

local function connect(signal, callback)
    local connection = signal:Connect(callback)

    table.insert(
        Hub.Connections,
        connection
    )

    return connection
end

local function round(parent, radius)

    local corner = Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, radius)

    corner.Parent = parent

    return corner
end

local function stroke(parent, color)

    local uiStroke = Instance.new("UIStroke")

    uiStroke.Color = color
    uiStroke.Thickness = 1
    uiStroke.Transparency = 0.25
    uiStroke.Parent = parent

    return uiStroke
end

local function tween(object, properties)

    local info =
        TweenInfo.new(
            0.16,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        )

    TweenService:Create(
        object,
        info,
        properties
    ):Play()
end

--========================================================
-- ROOT UI
--========================================================

local Old =
    PlayerGui:FindFirstChild(
        "BeatBossHubUI"
    )

if Old then
    Old:Destroy()
end

local ScreenGui =
    Instance.new("ScreenGui")

ScreenGui.Name = "BeatBossHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = false
ScreenGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

ScreenGui.Parent = PlayerGui

Hub.Gui = ScreenGui

--========================================================
-- MAIN WINDOW
--========================================================

local Window =
    Instance.new("Frame")

Window.Name = "Window"
Window.Size =
    UDim2.new(
        0,
        390,
        0,
        285
    )

Window.Position =
    UDim2.new(
        0.5,
        -195,
        0.33,
        0
    )

Window.BackgroundColor3 =
    Colors.Background

Window.BorderSizePixel = 0

Window.Parent = ScreenGui

round(Window, 16)
stroke(Window, Colors.Border)

--========================================================
-- TOP BAR
--========================================================

local Top =
    Instance.new("Frame")

Top.Size =
    UDim2.new(
        1,
        0,
        0,
        68
    )

Top.BackgroundTransparency = 1
Top.Parent = Window

local Title =
    Instance.new("TextLabel")

Title.Size =
    UDim2.new(
        1,
        -100,
        0,
        28
    )

Title.Position =
    UDim2.new(
        0,
        20,
        0,
        13
    )

Title.BackgroundTransparency = 1

Title.Text =
    "BeatBoss"

Title.TextColor3 =
    Colors.Text

Title.TextSize = 21
Title.Font =
    Enum.Font.GothamBold

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent = Top

local Subtitle =
    Instance.new("TextLabel")

Subtitle.Size =
    UDim2.new(
        1,
        -100,
        0,
        18
    )

Subtitle.Position =
    UDim2.new(
        0,
        20,
        0,
        39
    )

Subtitle.BackgroundTransparency = 1

Subtitle.Text =
    "Infinity Castle automation"

Subtitle.TextColor3 =
    Colors.Muted

Subtitle.TextSize = 12

Subtitle.Font =
    Enum.Font.GothamMedium

Subtitle.TextXAlignment =
    Enum.TextXAlignment.Left

Subtitle.Parent = Top

--========================================================
-- CLOSE / UNLOAD ICON
--========================================================

local Close =
    Instance.new("TextButton")

Close.Size =
    UDim2.new(
        0,
        34,
        0,
        34
    )

Close.Position =
    UDim2.new(
        1,
        -49,
        0,
        17
    )

Close.BackgroundColor3 =
    Colors.Surface2

Close.Text = "×"

Close.TextColor3 =
    Colors.Muted

Close.TextSize = 22

Close.Font =
    Enum.Font.GothamMedium

Close.AutoButtonColor = false

Close.Parent = Top

round(Close, 9)
stroke(Close, Colors.Border)

--========================================================
-- CONTENT CARD
--========================================================

local Card =
    Instance.new("Frame")

Card.Size =
    UDim2.new(
        1,
        -32,
        0,
        126
    )

Card.Position =
    UDim2.new(
        0,
        16,
        0,
        72
    )

Card.BackgroundColor3 =
    Colors.Surface

Card.BorderSizePixel = 0

Card.Parent = Window

round(Card, 12)
stroke(Card, Colors.Border)

--========================================================
-- FEATURE TITLE
--========================================================

local FeatureTitle =
    Instance.new("TextLabel")

FeatureTitle.Size =
    UDim2.new(
        1,
        -100,
        0,
        26
    )

FeatureTitle.Position =
    UDim2.new(
        0,
        16,
        0,
        15
    )

FeatureTitle.BackgroundTransparency = 1

FeatureTitle.Text =
    "Auto Infinity Castle"

FeatureTitle.TextColor3 =
    Colors.Text

FeatureTitle.TextSize = 15

FeatureTitle.Font =
    Enum.Font.GothamSemibold

FeatureTitle.TextXAlignment =
    Enum.TextXAlignment.Left

FeatureTitle.Parent = Card

local FeatureDesc =
    Instance.new("TextLabel")

FeatureDesc.Size =
    UDim2.new(
        1,
        -32,
        0,
        34
    )

FeatureDesc.Position =
    UDim2.new(
        0,
        16,
        0,
        43
    )

FeatureDesc.BackgroundTransparency = 1

FeatureDesc.Text =
    "Automatically equips the best units and starts Infinity Castle."

FeatureDesc.TextColor3 =
    Colors.Muted

FeatureDesc.TextSize = 11

FeatureDesc.Font =
    Enum.Font.GothamMedium

FeatureDesc.TextWrapped = true

FeatureDesc.TextXAlignment =
    Enum.TextXAlignment.Left

FeatureDesc.TextYAlignment =
    Enum.TextYAlignment.Top

FeatureDesc.Parent = Card

--========================================================
-- TOGGLE
--========================================================

local Toggle =
    Instance.new("TextButton")

Toggle.Size =
    UDim2.new(
        0,
        52,
        0,
        28
    )

Toggle.Position =
    UDim2.new(
        1,
        -68,
        0,
        16
    )

Toggle.BackgroundColor3 =
    Colors.Surface2

Toggle.Text = ""

Toggle.AutoButtonColor = false

Toggle.Parent = Card

round(Toggle, 14)

local Knob =
    Instance.new("Frame")

Knob.Size =
    UDim2.new(
        0,
        22,
        0,
        22
    )

Knob.Position =
    UDim2.new(
        0,
        3,
        0.5,
        -11
    )

Knob.BackgroundColor3 =
    Color3.fromRGB(
        210,
        210,
        215
    )

Knob.BorderSizePixel = 0
Knob.Parent = Toggle

round(Knob, 11)

--========================================================
-- STATUS PILL
--========================================================

local StatusHolder =
    Instance.new("Frame")

StatusHolder.Size =
    UDim2.new(
        1,
        -32,
        0,
        30
    )

StatusHolder.Position =
    UDim2.new(
        0,
        16,
        1,
        -40
    )

StatusHolder.BackgroundColor3 =
    Colors.Surface2

StatusHolder.BorderSizePixel = 0

StatusHolder.Parent = Card

round(StatusHolder, 8)

local Dot =
    Instance.new("Frame")

Dot.Size =
    UDim2.new(
        0,
        8,
        0,
        8
    )

Dot.Position =
    UDim2.new(
        0,
        11,
        0.5,
        -4
    )

Dot.BackgroundColor3 =
    Colors.Red

Dot.BorderSizePixel = 0
Dot.Parent = StatusHolder

round(Dot, 4)

local Status =
    Instance.new("TextLabel")

Status.Size =
    UDim2.new(
        1,
        -32,
        1,
        0
    )

Status.Position =
    UDim2.new(
        0,
        28,
        0,
        0
    )

Status.BackgroundTransparency = 1

Status.Text =
    "Disabled"

Status.TextColor3 =
    Colors.Muted

Status.TextSize = 11

Status.Font =
    Enum.Font.GothamMedium

Status.TextXAlignment =
    Enum.TextXAlignment.Left

Status.Parent = StatusHolder

--========================================================
-- UNLOAD BUTTON
--========================================================

local Unload =
    Instance.new("TextButton")

Unload.Size =
    UDim2.new(
        1,
        -32,
        0,
        48
    )

Unload.Position =
    UDim2.new(
        0,
        16,
        1,
        -64
    )

Unload.BackgroundColor3 =
    Color3.fromRGB(
        42,
        25,
        28
    )

Unload.Text =
    "Unload Script"

Unload.TextColor3 =
    Color3.fromRGB(
        235,
        105,
        105
    )

Unload.TextSize = 13

Unload.Font =
    Enum.Font.GothamSemibold

Unload.AutoButtonColor = false

Unload.Parent = Window

round(Unload, 10)

local UnloadStroke =
    stroke(
        Unload,
        Colors.RedDark
    )

--========================================================
-- STATUS FUNCTIONS
--========================================================

local function setStatus(text, active)

    if not Hub.Alive then
        return
    end

    Status.Text = text

    if active then
        Dot.BackgroundColor3 =
            Colors.Green
    else
        Dot.BackgroundColor3 =
            Colors.Red
    end
end

local function updateToggle()

    if Hub.AutoCastle then

        tween(
            Toggle,
            {
                BackgroundColor3 =
                    Colors.GreenDark
            }
        )

        tween(
            Knob,
            {
                Position =
                    UDim2.new(
                        1,
                        -25,
                        0.5,
                        -11
                    ),

                BackgroundColor3 =
                    Color3.new(
                        1,
                        1,
                        1
                    )
            }
        )

    else

        tween(
            Toggle,
            {
                BackgroundColor3 =
                    Colors.Surface2
            }
        )

        tween(
            Knob,
            {
                Position =
                    UDim2.new(
                        0,
                        3,
                        0.5,
                        -11
                    ),

                BackgroundColor3 =
                    Color3.fromRGB(
                        210,
                        210,
                        215
                    )
            }
        )

    end
end

--========================================================
-- GAME BUTTON CLICK
--========================================================

local function clickButton(button)

    if not Hub.Alive then
        return false
    end

    if not button then
        return false
    end

    if not button.Visible then
        return false
    end

    -- Executor firesignal
    if firesignal then

        local success =
            pcall(function()

                firesignal(
                    button.MouseButton1Click
                )

            end)

        if success then
            return true
        end

        pcall(function()

            firesignal(
                button.Activated
            )

        end)

    end

    -- Virtual mouse fallback
    local pos =
        button.AbsolutePosition
        + button.AbsoluteSize / 2

    pcall(function()

        VIM:SendMouseButtonEvent(
            pos.X,
            pos.Y,
            0,
            true,
            game,
            0
        )

        task.wait(0.05)

        VIM:SendMouseButtonEvent(
            pos.X,
            pos.Y,
            0,
            false,
            game,
            0
        )

    end)

    return true
end

--========================================================
-- AUTO CASTLE LOOP
--========================================================

local function runAutoCastle()

    if Hub.AutoTask then
        return
    end

    Hub.AutoTask =
        task.spawn(function()

            while
                Hub.Alive
                and Hub.AutoCastle
            do

                -- Castle selection screen
                if InfinityFrame.Visible then

                    setStatus(
                        "Equipping best units...",
                        true
                    )

                    clickButton(
                        EquipBest
                    )

                    task.wait(0.6)

                    if
                        not Hub.Alive
                        or not Hub.AutoCastle
                    then
                        break
                    end

                    setStatus(
                        "Starting Infinity Castle...",
                        true
                    )

                    clickButton(
                        StartButton
                    )

                    local timeout =
                        os.clock() + 8

                    while
                        Hub.Alive
                        and Hub.AutoCastle
                        and not BattleFrame.Visible
                        and os.clock() < timeout
                    do
                        task.wait(0.2)
                    end

                    if BattleFrame.Visible then

                        setStatus(
                            "Battle in progress",
                            true
                        )

                    else

                        setStatus(
                            "Start failed - retrying",
                            false
                        )

                        task.wait(1.5)

                    end

                -- Fighting
                elseif BattleFrame.Visible then

                    setStatus(
                        "Battle in progress",
                        true
                    )

                    repeat

                        task.wait(0.4)

                    until
                        not Hub.Alive
                        or not Hub.AutoCastle
                        or not BattleFrame.Visible

                -- Rewards
                elseif RewardsFrame.Visible then

                    setStatus(
                        "Waiting at reward screen",
                        true
                    )

                    task.wait(0.5)

                else

                    setStatus(
                        "Waiting for Infinity Castle",
                        true
                    )

                    task.wait(0.5)

                end

            end

            Hub.AutoTask = nil

            if Hub.Alive then

                setStatus(
                    "Disabled",
                    false
                )

            end

        end)
end

--========================================================
-- TOGGLE HANDLER
--========================================================

connect(
    Toggle.MouseButton1Click,
    function()

        if not Hub.Alive then
            return
        end

        Hub.AutoCastle =
            not Hub.AutoCastle

        updateToggle()

        if Hub.AutoCastle then

            setStatus(
                "Enabled",
                true
            )

            runAutoCastle()

        else

            setStatus(
                "Disabled",
                false
            )

        end
    end
)

--========================================================
-- UNLOAD FUNCTION
--========================================================

function Hub.Unload()

    if not Hub.Alive then
        return
    end

    Hub.Alive = false
    Hub.AutoCastle = false

    -- Stop task
    if Hub.AutoTask then

        pcall(function()

            task.cancel(
                Hub.AutoTask
            )

        end)

        Hub.AutoTask = nil
    end

    -- Disconnect UI events
    for _, connection
        in ipairs(
            Hub.Connections
        )
    do

        pcall(function()
            connection:Disconnect()
        end)

    end

    table.clear(
        Hub.Connections
    )

    -- Destroy UI
    if Hub.Gui then

        pcall(function()
            Hub.Gui:Destroy()
        end)

    end

    -- Remove global reference
    if
        ENV.BeatBossHub
        == Hub
    then

        ENV.BeatBossHub = nil

    end
end

--========================================================
-- UNLOAD BUTTON
--========================================================

connect(
    Unload.MouseButton1Click,
    function()

        tween(
            Unload,
            {
                BackgroundColor3 =
                    Colors.RedDark
            }
        )

        task.wait(0.08)

        Hub.Unload()
    end
)

connect(
    Close.MouseButton1Click,
    function()

        Hub.Unload()
    end
)

-- Hover unload
connect(
    Unload.MouseEnter,
    function()

        tween(
            Unload,
            {
                BackgroundColor3 =
                    Color3.fromRGB(
                        58,
                        30,
                        33
                    )
            }
        )

    end
)

connect(
    Unload.MouseLeave,
    function()

        tween(
            Unload,
            {
                BackgroundColor3 =
                    Color3.fromRGB(
                        42,
                        25,
                        28
                    )
            }
        )

    end
)

--========================================================
-- DRAG WINDOW
--========================================================

local Dragging = false
local DragStart
local StartPosition

connect(
    Top.InputBegan,
    function(input)

        if
            input.UserInputType
            == Enum.UserInputType.MouseButton1
        then

            Dragging = true
            DragStart =
                input.Position

            StartPosition =
                Window.Position

        end

    end
)

connect(
    UIS.InputChanged,
    function(input)

        if
            Dragging
            and input.UserInputType
            == Enum.UserInputType.MouseMovement
        then

            local delta =
                input.Position
                - DragStart

            Window.Position =
                UDim2.new(
                    StartPosition.X.Scale,
                    StartPosition.X.Offset
                        + delta.X,

                    StartPosition.Y.Scale,
                    StartPosition.Y.Offset
                        + delta.Y
                )

        end

    end
)

connect(
    UIS.InputEnded,
    function(input)

        if
            input.UserInputType
            == Enum.UserInputType.MouseButton1
        then

            Dragging = false

        end

    end
)

--========================================================
-- INITIAL STATE
--========================================================

updateToggle()

setStatus(
    "Disabled",
    false
)

print(
    "[BeatBoss] Hub loaded successfully."
)

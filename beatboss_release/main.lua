--========================================================
-- BEATBOSS HUB
-- Auto Infinity Castle
-- Modern UI + Dialogue + Unload
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local ENV = (getgenv and getgenv()) or _G

--========================================================
-- AUTO UNLOAD OLD VERSION
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

    LastPrompt = 0,
    LastDialogue = 0,
    LastEquip = 0,
    LastStart = 0
}

ENV.BeatBossHub = Hub

--========================================================
-- HELPERS
--========================================================

local function connect(signal, callback)

    local connection =
        signal:Connect(callback)

    table.insert(
        Hub.Connections,
        connection
    )

    return connection
end

local function round(parent, radius)

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, radius)

    corner.Parent = parent

    return corner
end

local function stroke(
    parent,
    color,
    transparency
)

    local s =
        Instance.new("UIStroke")

    s.Color = color
    s.Thickness = 1
    s.Transparency =
        transparency or 0

    s.Parent = parent

    return s
end

local function tween(
    object,
    properties,
    duration
)

    if not object
        or not object.Parent
    then
        return
    end

    local info =
        TweenInfo.new(
            duration or 0.16,
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
-- CHECK GUI VISIBILITY
--========================================================

local function objectVisible(obj)

    if not obj
        or not obj.Parent
    then
        return false
    end

    if obj:IsA("GuiObject")
        and not obj.Visible
    then
        return false
    end

    local parent =
        obj.Parent

    while parent
        and parent ~= PlayerGui
    do

        if parent:IsA("GuiObject")
            and not parent.Visible
        then
            return false
        end

        parent =
            parent.Parent
    end

    return true
end

--========================================================
-- CLICK GUI BUTTON
--========================================================

local function clickButton(button)

    if not Hub.Alive then
        return false
    end

    if not button
        or not button.Parent
    then
        return false
    end

    if button:IsA("GuiObject")
        and not objectVisible(button)
    then
        return false
    end

    -- Executor firesignal
    if firesignal
        and button:IsA("GuiButton")
    then

        local ok =
            pcall(function()

                firesignal(
                    button.Activated
                )

            end)

        if ok then
            return true
        end

        ok =
            pcall(function()

                firesignal(
                    button.MouseButton1Click
                )

            end)

        if ok then
            return true
        end
    end

    -- Mouse click fallback
    if button:IsA("GuiObject") then

        local center =
            button.AbsolutePosition
            + button.AbsoluteSize / 2

        local ok =
            pcall(function()

                VIM:SendMouseButtonEvent(
                    center.X,
                    center.Y,
                    0,
                    true,
                    game,
                    0
                )

                task.wait(0.04)

                VIM:SendMouseButtonEvent(
                    center.X,
                    center.Y,
                    0,
                    false,
                    game,
                    0
                )

            end)

        return ok
    end

    return false
end

--========================================================
-- CLICK GUI OBJECT POSITION
-- Used for dialogue TextLabels
--========================================================

local function clickGuiObject(obj)

    if not obj
        or not obj.Parent
        or not objectVisible(obj)
    then
        return false
    end

    local center =
        obj.AbsolutePosition
        + obj.AbsoluteSize / 2

    return pcall(function()

        VIM:SendMouseButtonEvent(
            center.X,
            center.Y,
            0,
            true,
            game,
            0
        )

        task.wait(0.05)

        VIM:SendMouseButtonEvent(
            center.X,
            center.Y,
            0,
            false,
            game,
            0
        )

    end)
end

--========================================================
-- GAME OBJECTS
--========================================================

local function resolveGameObjects()

    local Main =
        PlayerGui:FindFirstChild(
            "Main"
        )

    if not Main then
        return nil
    end

    local InfinityFrame =
        Main:FindFirstChild(
            "InfinityCastleFrame"
        )

    local BattleFrame =
        Main:FindFirstChild(
            "CastleStartFrame"
        )

    local RewardsFrame =
        Main:FindFirstChild(
            "CastleRewardsFrame"
        )

    if not InfinityFrame then
        return nil
    end

    local InfinityMain =
        InfinityFrame:FindFirstChild(
            "Main"
        )

    if not InfinityMain then
        return nil
    end

    return {

        Main = Main,

        InfinityFrame =
            InfinityFrame,

        InfinityMain =
            InfinityMain,

        EquipBest =
            InfinityMain:
            FindFirstChild(
                "EquipBest"
            ),

        StartButton =
            InfinityMain:
            FindFirstChild(
                "StartButton"
            ),

        BattleFrame =
            BattleFrame,

        RewardsFrame =
            RewardsFrame
    }
end

--========================================================
-- FIND INFINITY CASTLE NPC PROMPT
--========================================================

local function findInfinityPrompt()

    for _, obj
        in ipairs(
            workspace:GetDescendants()
        )
    do

        if obj:IsA(
            "ProximityPrompt"
        ) then

            local search =
                string.lower(
                    tostring(obj.Name)
                    .. " "
                    .. tostring(
                        obj.ActionText
                    )
                    .. " "
                    .. tostring(
                        obj.ObjectText
                    )
                )

            if
                search:find(
                    "infinity",
                    1,
                    true
                )
                or
                search:find(
                    "castle",
                    1,
                    true
                )
            then

                return obj
            end
        end
    end

    return nil
end

--========================================================
-- OPEN NPC
--========================================================

local function openInfinityNPC()

    if not fireproximityprompt then
        return false
    end

    -- Prevent prompt spam
    if os.clock()
        - Hub.LastPrompt
        < 1.2
    then
        return false
    end

    local prompt =
        findInfinityPrompt()

    if not prompt then
        return false
    end

    Hub.LastPrompt =
        os.clock()

    return pcall(function()

        fireproximityprompt(
            prompt
        )

    end)
end

--========================================================
-- DIALOGUE
--========================================================

local function normalizeText(text)

    text =
        string.lower(
            tostring(text or "")
        )

    text =
        text:gsub(
            "%s+",
            " "
        )

    return text
end

local function isLetsGoText(text)

    text =
        normalizeText(text)

    -- Examples:
    -- Let's go!
    -- ["Let's go!"]
    -- 1.) ["Let's go!"]

    if text:find(
        "let's go",
        1,
        true
    ) then
        return true
    end

    if text:find(
        "lets go",
        1,
        true
    ) then
        return true
    end

    -- Extra fallback
    if text:find(
        "let",
        1,
        true
    )
    and text:find(
        "go",
        1,
        true
    )
    then
        return true
    end

    return false
end

local function findLetsGoChoice()

    for _, obj
        in ipairs(
            PlayerGui:GetDescendants()
        )
    do

        if
            (
                obj:IsA("TextButton")
                or
                obj:IsA("TextLabel")
            )
            and objectVisible(obj)
        then

            local text =
                obj.Text

            if isLetsGoText(text) then

                -- Direct TextButton
                if obj:IsA(
                    "TextButton"
                ) then

                    return obj, obj
                end

                -- TextLabel inside a button
                local parent =
                    obj.Parent

                while parent
                    and parent
                    ~= PlayerGui
                do

                    if parent:IsA(
                        "GuiButton"
                    ) then

                        return parent, obj
                    end

                    parent =
                        parent.Parent
                end

                -- Raw TextLabel
                return nil, obj
            end
        end
    end

    return nil, nil
end

--========================================================
-- CLICK "LET'S GO!"
--========================================================

local function acceptInfinityDialogue()

    if os.clock()
        - Hub.LastDialogue
        < 0.7
    then
        return false
    end

    local button, label =
        findLetsGoChoice()

    if not button
        and not label
    then
        return false
    end

    Hub.LastDialogue =
        os.clock()

    if button then

        return clickButton(
            button
        )

    elseif label then

        return clickGuiObject(
            label
        )
    end

    return false
end

--========================================================
-- REWARD / CONTINUE FINDER
--========================================================

local function findRewardButton(
    rewardFrame
)

    if not rewardFrame
        or not objectVisible(
            rewardFrame
        )
    then
        return nil
    end

    local priorities = {

        "claim",

        "collect",

        "next",

        "continue",

        "retry",

        "again",

        "ok",

        "close"
    }

    for _, keyword
        in ipairs(priorities)
    do

        for _, obj
            in ipairs(
                rewardFrame:
                GetDescendants()
            )
        do

            if
                obj:IsA(
                    "GuiButton"
                )
                and objectVisible(obj)
            then

                local text =
                    string.lower(
                        obj.Name
                    )

                if obj:IsA(
                    "TextButton"
                ) then

                    text =
                        text
                        .. " "
                        .. string.lower(
                            tostring(
                                obj.Text
                            )
                        )
                end

                if text:find(
                    keyword,
                    1,
                    true
                )
                then

                    return obj
                end
            end
        end
    end

    return nil
end

--========================================================
-- UI COLORS
--========================================================

local Colors = {

    Background =
        Color3.fromRGB(
            14,
            15,
            19
        ),

    Surface =
        Color3.fromRGB(
            21,
            23,
            28
        ),

    Surface2 =
        Color3.fromRGB(
            29,
            31,
            38
        ),

    Border =
        Color3.fromRGB(
            55,
            58,
            69
        ),

    Text =
        Color3.fromRGB(
            244,
            245,
            247
        ),

    Muted =
        Color3.fromRGB(
            150,
            153,
            166
        ),

    Accent =
        Color3.fromRGB(
            103,
            92,
            255
        ),

    Green =
        Color3.fromRGB(
            55,
            199,
            111
        ),

    GreenDark =
        Color3.fromRGB(
            37,
            129,
            72
        ),

    Red =
        Color3.fromRGB(
            224,
            82,
            82
        )
}

--========================================================
-- DELETE OLD UI
--========================================================

local Old =
    PlayerGui:
    FindFirstChild(
        "BeatBossHubUI"
    )

if Old then
    Old:Destroy()
end

--========================================================
-- SCREEN GUI
--========================================================

local ScreenGui =
    Instance.new(
        "ScreenGui"
    )

ScreenGui.Name =
    "BeatBossHubUI"

ScreenGui.ResetOnSpawn =
    false

ScreenGui.IgnoreGuiInset =
    false

ScreenGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

ScreenGui.Parent =
    PlayerGui

Hub.Gui =
    ScreenGui

--========================================================
-- WINDOW
--========================================================

local Window =
    Instance.new(
        "Frame"
    )

Window.Name =
    "Window"

Window.Size =
    UDim2.new(
        0,
        410,
        0,
        305
    )

Window.Position =
    UDim2.new(
        0.5,
        -205,
        0.32,
        0
    )

Window.BackgroundColor3 =
    Colors.Background

Window.BorderSizePixel =
    0

Window.Parent =
    ScreenGui

round(
    Window,
    16
)

stroke(
    Window,
    Colors.Border,
    0.2
)

--========================================================
-- TOP BAR
--========================================================

local Top =
    Instance.new(
        "Frame"
    )

Top.Size =
    UDim2.new(
        1,
        0,
        0,
        68
    )

Top.BackgroundTransparency =
    1

Top.Parent =
    Window

--========================================================
-- LOGO
--========================================================

local Logo =
    Instance.new(
        "Frame"
    )

Logo.Size =
    UDim2.new(
        0,
        34,
        0,
        34
    )

Logo.Position =
    UDim2.new(
        0,
        18,
        0,
        17
    )

Logo.BackgroundColor3 =
    Colors.Accent

Logo.BorderSizePixel =
    0

Logo.Parent =
    Top

round(
    Logo,
    10
)

local LogoText =
    Instance.new(
        "TextLabel"
    )

LogoText.Size =
    UDim2.fromScale(
        1,
        1
    )

LogoText.BackgroundTransparency =
    1

LogoText.Text =
    "B"

LogoText.TextColor3 =
    Color3.new(
        1,
        1,
        1
    )

LogoText.TextSize =
    17

LogoText.Font =
    Enum.Font.GothamBold

LogoText.Parent =
    Logo

--========================================================
-- TITLE
--========================================================

local Title =
    Instance.new(
        "TextLabel"
    )

Title.Size =
    UDim2.new(
        1,
        -130,
        0,
        24
    )

Title.Position =
    UDim2.new(
        0,
        64,
        0,
        14
    )

Title.BackgroundTransparency =
    1

Title.Text =
    "BeatBoss"

Title.TextColor3 =
    Colors.Text

Title.TextSize =
    19

Title.Font =
    Enum.Font.GothamBold

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent =
    Top

local Subtitle =
    Instance.new(
        "TextLabel"
    )

Subtitle.Size =
    UDim2.new(
        1,
        -130,
        0,
        18
    )

Subtitle.Position =
    UDim2.new(
        0,
        64,
        0,
        38
    )

Subtitle.BackgroundTransparency =
    1

Subtitle.Text =
    "Automation panel"

Subtitle.TextColor3 =
    Colors.Muted

Subtitle.TextSize =
    11

Subtitle.Font =
    Enum.Font.GothamMedium

Subtitle.TextXAlignment =
    Enum.TextXAlignment.Left

Subtitle.Parent =
    Top

--========================================================
-- MINIMIZE
--========================================================

local Minimize =
    Instance.new(
        "TextButton"
    )

Minimize.Size =
    UDim2.new(
        0,
        34,
        0,
        34
    )

Minimize.Position =
    UDim2.new(
        1,
        -92,
        0,
        17
    )

Minimize.BackgroundColor3 =
    Colors.Surface2

Minimize.Text =
    "—"

Minimize.TextColor3 =
    Colors.Muted

Minimize.TextSize =
    17

Minimize.Font =
    Enum.Font.GothamMedium

Minimize.AutoButtonColor =
    false

Minimize.Parent =
    Top

round(
    Minimize,
    9
)

--========================================================
-- CLOSE
--========================================================

local Close =
    Instance.new(
        "TextButton"
    )

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
        -50,
        0,
        17
    )

Close.BackgroundColor3 =
    Colors.Surface2

Close.Text =
    "×"

Close.TextColor3 =
    Colors.Muted

Close.TextSize =
    21

Close.Font =
    Enum.Font.GothamMedium

Close.AutoButtonColor =
    false

Close.Parent =
    Top

round(
    Close,
    9
)

--========================================================
-- FEATURE CARD
--========================================================

local Card =
    Instance.new(
        "Frame"
    )

Card.Size =
    UDim2.new(
        1,
        -32,
        0,
        145
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

Card.BorderSizePixel =
    0

Card.Parent =
    Window

round(
    Card,
    12
)

stroke(
    Card,
    Colors.Border,
    0.35
)

local FeatureTitle =
    Instance.new(
        "TextLabel"
    )

FeatureTitle.Size =
    UDim2.new(
        1,
        -110,
        0,
        24
    )

FeatureTitle.Position =
    UDim2.new(
        0,
        16,
        0,
        15
    )

FeatureTitle.BackgroundTransparency =
    1

FeatureTitle.Text =
    "Auto Infinity Castle"

FeatureTitle.TextColor3 =
    Colors.Text

FeatureTitle.TextSize =
    15

FeatureTitle.Font =
    Enum.Font.GothamSemibold

FeatureTitle.TextXAlignment =
    Enum.TextXAlignment.Left

FeatureTitle.Parent =
    Card

local FeatureDesc =
    Instance.new(
        "TextLabel"
    )

FeatureDesc.Size =
    UDim2.new(
        1,
        -32,
        0,
        38
    )

FeatureDesc.Position =
    UDim2.new(
        0,
        16,
        0,
        43
    )

FeatureDesc.BackgroundTransparency =
    1

FeatureDesc.Text =
    "Automatically enter, equip best units and run Infinity Castle."

FeatureDesc.TextColor3 =
    Colors.Muted

FeatureDesc.TextSize =
    11

FeatureDesc.Font =
    Enum.Font.GothamMedium

FeatureDesc.TextWrapped =
    true

FeatureDesc.TextXAlignment =
    Enum.TextXAlignment.Left

FeatureDesc.TextYAlignment =
    Enum.TextYAlignment.Top

FeatureDesc.Parent =
    Card

--========================================================
-- TOGGLE
--========================================================

local Toggle =
    Instance.new(
        "TextButton"
    )

Toggle.Size =
    UDim2.new(
        0,
        54,
        0,
        30
    )

Toggle.Position =
    UDim2.new(
        1,
        -70,
        0,
        15
    )

Toggle.BackgroundColor3 =
    Colors.Surface2

Toggle.Text =
    ""

Toggle.AutoButtonColor =
    false

Toggle.Parent =
    Card

round(
    Toggle,
    15
)

local Knob =
    Instance.new(
        "Frame"
    )

Knob.Size =
    UDim2.new(
        0,
        24,
        0,
        24
    )

Knob.Position =
    UDim2.new(
        0,
        3,
        0.5,
        -12
    )

Knob.BackgroundColor3 =
    Color3.fromRGB(
        215,
        216,
        220
    )

Knob.BorderSizePixel =
    0

Knob.Parent =
    Toggle

round(
    Knob,
    12
)

--========================================================
-- STATUS
--========================================================

local StatusHolder =
    Instance.new(
        "Frame"
    )

StatusHolder.Size =
    UDim2.new(
        1,
        -32,
        0,
        34
    )

StatusHolder.Position =
    UDim2.new(
        0,
        16,
        1,
        -46
    )

StatusHolder.BackgroundColor3 =
    Colors.Surface2

StatusHolder.BorderSizePixel =
    0

StatusHolder.Parent =
    Card

round(
    StatusHolder,
    9
)

local StatusDot =
    Instance.new(
        "Frame"
    )

StatusDot.Size =
    UDim2.new(
        0,
        8,
        0,
        8
    )

StatusDot.Position =
    UDim2.new(
        0,
        12,
        0.5,
        -4
    )

StatusDot.BackgroundColor3 =
    Colors.Red

StatusDot.BorderSizePixel =
    0

StatusDot.Parent =
    StatusHolder

round(
    StatusDot,
    4
)

local Status =
    Instance.new(
        "TextLabel"
    )

Status.Size =
    UDim2.new(
        1,
        -40,
        1,
        0
    )

Status.Position =
    UDim2.new(
        0,
        30,
        0,
        0
    )

Status.BackgroundTransparency =
    1

Status.Text =
    "Disabled"

Status.TextColor3 =
    Colors.Muted

Status.TextSize =
    11

Status.Font =
    Enum.Font.GothamMedium

Status.TextXAlignment =
    Enum.TextXAlignment.Left

Status.Parent =
    StatusHolder

--========================================================
-- HINT
--========================================================

local Hint =
    Instance.new(
        "TextLabel"
    )

Hint.Size =
    UDim2.new(
        1,
        -32,
        0,
        22
    )

Hint.Position =
    UDim2.new(
        0,
        16,
        0,
        224
    )

Hint.BackgroundTransparency =
    1

Hint.Text =
    "RightShift: show / hide panel"

Hint.TextColor3 =
    Colors.Muted

Hint.TextSize =
    10

Hint.Font =
    Enum.Font.GothamMedium

Hint.TextXAlignment =
    Enum.TextXAlignment.Left

Hint.Parent =
    Window

--========================================================
-- UNLOAD BUTTON
--========================================================

local Unload =
    Instance.new(
        "TextButton"
    )

Unload.Size =
    UDim2.new(
        0,
        132,
        0,
        42
    )

Unload.Position =
    UDim2.new(
        1,
        -148,
        1,
        -58
    )

Unload.BackgroundColor3 =
    Color3.fromRGB(
        46,
        27,
        30
    )

Unload.Text =
    "Unload Script"

Unload.TextColor3 =
    Color3.fromRGB(
        238,
        115,
        115
    )

Unload.TextSize =
    12

Unload.Font =
    Enum.Font.GothamSemibold

Unload.AutoButtonColor =
    false

Unload.Parent =
    Window

round(
    Unload,
    10
)

stroke(
    Unload,
    Color3.fromRGB(
        120,
        52,
        57
    ),
    0.25
)

--========================================================
-- STATUS FUNCTIONS
--========================================================

local function setStatus(
    text,
    good
)

    if not Hub.Alive
        or not Status.Parent
    then
        return
    end

    Status.Text =
        text

    if good then

        StatusDot.BackgroundColor3 =
            Colors.Green

    else

        StatusDot.BackgroundColor3 =
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
                        -27,
                        0.5,
                        -12
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
                        -12
                    ),

                BackgroundColor3 =
                    Color3.fromRGB(
                        215,
                        216,
                        220
                    )
            }
        )
    end
end

--========================================================
-- AUTO INFINITY CASTLE
--========================================================

local function runAutoCastle()

    if Hub.Worker then
        return
    end

    Hub.Worker =
        task.spawn(function()

            while
                Hub.Alive
                and Hub.AutoCastle
            do

                local G =
                    resolveGameObjects()

                if not G then

                    setStatus(
                        "Waiting for game UI...",
                        false
                    )

                    task.wait(1)

                else

                    --====================================
                    -- 1. CASTLE MENU OPEN
                    --====================================

                    if
                        G.InfinityFrame
                        and objectVisible(
                            G.InfinityFrame
                        )
                    then

                        if
                            os.clock()
                            - Hub.LastEquip
                            > 1
                        then

                            setStatus(
                                "Equipping best units...",
                                true
                            )

                            if G.EquipBest then

                                clickButton(
                                    G.EquipBest
                                )

                            end

                            Hub.LastEquip =
                                os.clock()

                            task.wait(0.55)
                        end

                        if
                            not Hub.Alive
                            or not Hub.AutoCastle
                        then
                            break
                        end

                        if
                            os.clock()
                            - Hub.LastStart
                            > 1.5
                        then

                            setStatus(
                                "Starting Infinity Castle...",
                                true
                            )

                            if G.StartButton then

                                clickButton(
                                    G.StartButton
                                )

                            end

                            Hub.LastStart =
                                os.clock()
                        end

                        local deadline =
                            os.clock() + 8

                        while
                            Hub.Alive
                            and Hub.AutoCastle
                            and os.clock()
                                < deadline
                        do

                            if
                                G.BattleFrame
                                and objectVisible(
                                    G.BattleFrame
                                )
                            then
                                break
                            end

                            task.wait(0.2)
                        end

                    --====================================
                    -- 2. BATTLE RUNNING
                    --====================================

                    elseif
                        G.BattleFrame
                        and objectVisible(
                            G.BattleFrame
                        )
                    then

                        setStatus(
                            "Battle in progress",
                            true
                        )

                        repeat

                            task.wait(0.4)

                        until
                            not Hub.Alive
                            or not Hub.AutoCastle
                            or not objectVisible(
                                G.BattleFrame
                            )

                    --====================================
                    -- 3. REWARD SCREEN
                    --====================================

                    elseif
                        G.RewardsFrame
                        and objectVisible(
                            G.RewardsFrame
                        )
                    then

                        setStatus(
                            "Handling rewards...",
                            true
                        )

                        local rewardButton =
                            findRewardButton(
                                G.RewardsFrame
                            )

                        if rewardButton then

                            clickButton(
                                rewardButton
                            )

                            task.wait(0.8)

                        else

                            setStatus(
                                "Reward screen - waiting",
                                true
                            )

                            task.wait(0.6)
                        end

                    --====================================
                    -- 4. NPC DIALOGUE
                    --====================================

                    elseif
                        findLetsGoChoice()
                    then

                        setStatus(
                            "Selecting Let's go!...",
                            true
                        )

                        acceptInfinityDialogue()

                        task.wait(0.8)

                    --====================================
                    -- 5. FIND / OPEN NPC
                    --====================================

                    else

                        setStatus(
                            "Opening Infinity Castle...",
                            true
                        )

                        openInfinityNPC()

                        -- Wait for dialogue
                        task.wait(0.45)

                        -- Click Let's go if it appeared
                        if acceptInfinityDialogue() then

                            setStatus(
                                "Entering Infinity Castle...",
                                true
                            )

                            task.wait(0.8)

                        else

                            setStatus(
                                "Waiting for Infinity Castle...",
                                true
                            )

                            task.wait(0.4)
                        end
                    end
                end
            end

            Hub.Worker =
                nil

            if Hub.Alive then

                setStatus(
                    "Disabled",
                    false
                )

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

    Hub.Alive =
        false

    Hub.AutoCastle =
        false

    if Hub.Worker then

        pcall(function()

            task.cancel(
                Hub.Worker
            )

        end)

        Hub.Worker =
            nil
    end

    for _, connection
        in ipairs(
            Hub.Connections
        )
    do

        pcall(function()

            connection:
            Disconnect()

        end)

    end

    table.clear(
        Hub.Connections
    )

    if Hub.Gui then

        pcall(function()

            Hub.Gui:
            Destroy()

        end)

        Hub.Gui =
            nil
    end

    if ENV.BeatBossHub
        == Hub
    then

        ENV.BeatBossHub =
            nil
    end
end

--========================================================
-- TOGGLE
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
-- UNLOAD BUTTON
--========================================================

connect(
    Unload.MouseButton1Click,
    function()

        tween(
            Unload,
            {
                BackgroundColor3 =
                    Color3.fromRGB(
                        89,
                        39,
                        44
                    )
            },
            0.1
        )

        task.wait(
            0.08
        )

        Hub.Unload()
    end
)

--========================================================
-- CLOSE
--========================================================

connect(
    Close.MouseButton1Click,
    function()

        Hub.Unload()

    end
)

--========================================================
-- MINIMIZE
--========================================================

local Minimized =
    false

connect(
    Minimize.MouseButton1Click,
    function()

        Minimized =
            not Minimized

        if Minimized then

            Card.Visible =
                false

            Hint.Visible =
                false

            Unload.Visible =
                false

            tween(
                Window,
                {
                    Size =
                        UDim2.new(
                            0,
                            410,
                            0,
                            68
                        )
                }
            )

        else

            tween(
                Window,
                {
                    Size =
                        UDim2.new(
                            0,
                            410,
                            0,
                            305
                        )
                }
            )

            task.wait(
                0.08
            )

            Card.Visible =
                true

            Hint.Visible =
                true

            Unload.Visible =
                true
        end
    end
)

--========================================================
-- RIGHT SHIFT SHOW / HIDE
--========================================================

connect(
    UIS.InputBegan,
    function(
        input,
        processed
    )

        if processed then
            return
        end

        if input.KeyCode
            == Enum.KeyCode.RightShift
        then

            ScreenGui.Enabled =
                not ScreenGui.Enabled
        end
    end
)

--========================================================
-- DRAG WINDOW
--========================================================

local Dragging =
    false

local DragStart =
    nil

local StartPosition =
    nil

connect(
    Top.InputBegan,
    function(input)

        if input.UserInputType
            == Enum.UserInputType.MouseButton1
        then

            Dragging =
                true

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

        if input.UserInputType
            == Enum.UserInputType.MouseButton1
        then

            Dragging =
                false
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

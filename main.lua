--[[
    AnimeBossDemo Client Hub
    Designed for the AnimeBossDemo project.

    Requires:
    ReplicatedStorage
    └── AnimeBossDemo
        ├── Config
        ├── Request
        └── State
]]

-- =========================================================
-- SERVICES
-- =========================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

if not player then
    error("[AnimeBoss] LocalPlayer not available")
end

-- =========================================================
-- CLEAN OLD INSTANCE
-- =========================================================

local env = getgenv and getgenv() or _G

if env.AnimeBossDemoHub then
    if env.AnimeBossDemoHub.Stop then
        pcall(env.AnimeBossDemoHub.Stop)
    end
end

local Runtime = {
    Running = true,
    Connections = {},
    AutoAttack = false
}

env.AnimeBossDemoHub = Runtime

-- =========================================================
-- FIND DEMO
-- =========================================================

local shared = ReplicatedStorage:WaitForChild(
    "AnimeBossDemo",
    10
)

if not shared then
    error(
        "[AnimeBoss] ReplicatedStorage.AnimeBossDemo not found. " ..
        "This client only works with AnimeBossDemo."
    )
end

local configModule = shared:WaitForChild("Config", 10)
local request = shared:WaitForChild("Request", 10)
local response = shared:WaitForChild("State", 10)

if not configModule then
    error("[AnimeBoss] Config ModuleScript not found")
end

if not request then
    error("[AnimeBoss] Request RemoteEvent not found")
end

if not response then
    error("[AnimeBoss] State RemoteEvent not found")
end

local okConfig, Config = pcall(require, configModule)

if not okConfig then
    error("[AnimeBoss] Cannot require Config: " .. tostring(Config))
end

print("[AnimeBoss] Server connection found.")

-- =========================================================
-- STATE
-- =========================================================

local state = nil
local selected = nil
local confirmFusion = nil

local pending = false
local sequence = 0
local lastSent = -math.huge

-- =========================================================
-- COLORS
-- =========================================================

local colors = {
    Background = Color3.fromRGB(17, 20, 29),
    Panel = Color3.fromRGB(29, 35, 48),
    Panel2 = Color3.fromRGB(38, 46, 62),

    Text = Color3.fromRGB(240, 243, 250),
    Muted = Color3.fromRGB(150, 162, 185),

    Accent = Color3.fromRGB(86, 190, 214),
    Success = Color3.fromRGB(105, 210, 142),
    Error = Color3.fromRGB(245, 118, 118)
}

-- =========================================================
-- UTILITIES
-- =========================================================

local function connect(signal, callback)
    local connection = signal:Connect(callback)

    table.insert(
        Runtime.Connections,
        connection
    )

    return connection
end

local function make(className, properties, parent)

    local object = Instance.new(className)

    for key, value in pairs(properties or {}) do
        object[key] = value
    end

    if parent then
        object.Parent = parent
    end

    return object
end

local function corner(object, radius)

    make(
        "UICorner",
        {
            CornerRadius = UDim.new(0, radius or 8)
        },
        object
    )
end

local function stroke(object)

    make(
        "UIStroke",
        {
            Thickness = 1,
            Transparency = 0.75,
            Color = Color3.fromRGB(120, 140, 170)
        },
        object
    )
end

-- =========================================================
-- REMOVE OLD GUI
-- =========================================================

local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild(
    "AnimeBossExecutorUI"
)

if oldGui then
    oldGui:Destroy()
end

-- =========================================================
-- GUI
-- =========================================================

local gui = make(
    "ScreenGui",
    {
        Name = "AnimeBossExecutorUI",
        ResetOnSpawn = false,
        IgnoreGuiInset = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    },
    playerGui
)

local main = make(
    "Frame",
    {
        Size = UDim2.fromOffset(520, 610),
        Position = UDim2.new(
            0,
            24,
            0.5,
            -305
        ),

        BackgroundColor3 = colors.Background,
        BorderSizePixel = 0
    },
    gui
)

corner(main, 14)
stroke(main)

-- =========================================================
-- HEADER
-- =========================================================

local header = make(
    "Frame",
    {
        Size = UDim2.new(1, 0, 0, 58),

        BackgroundColor3 = colors.Panel,
        BorderSizePixel = 0
    },
    main
)

corner(header, 14)

local title = make(
    "TextLabel",
    {
        Size = UDim2.new(1, -130, 0, 30),
        Position = UDim2.fromOffset(16, 7),

        BackgroundTransparency = 1,

        Text = "ANIME BOSS",
        TextColor3 = colors.Text,

        TextSize = 21,
        Font = Enum.Font.GothamBold,

        TextXAlignment = Enum.TextXAlignment.Left
    },
    header
)

local subtitle = make(
    "TextLabel",
    {
        Size = UDim2.new(1, -130, 0, 18),
        Position = UDim2.fromOffset(16, 33),

        BackgroundTransparency = 1,

        Text = "AnimeBossDemo Client",
        TextColor3 = colors.Muted,

        TextSize = 11,
        Font = Enum.Font.Gotham,

        TextXAlignment = Enum.TextXAlignment.Left
    },
    header
)

local close = make(
    "TextButton",
    {
        Size = UDim2.fromOffset(38, 34),

        Position = UDim2.new(
            1,
            -48,
            0,
            12
        ),

        BackgroundColor3 = colors.Panel2,

        BorderSizePixel = 0,

        Text = "X",
        TextColor3 = colors.Text,

        Font = Enum.Font.GothamBold,
        TextSize = 13
    },
    header
)

corner(close, 8)

-- =========================================================
-- SCROLL
-- =========================================================

local scroll = make(
    "ScrollingFrame",
    {
        Size = UDim2.new(
            1,
            -20,
            1,
            -78
        ),

        Position = UDim2.fromOffset(
            10,
            68
        ),

        BackgroundTransparency = 1,
        BorderSizePixel = 0,

        ScrollBarThickness = 3,

        AutomaticCanvasSize =
            Enum.AutomaticSize.Y,

        CanvasSize =
            UDim2.new()
    },
    main
)

local layout = make(
    "UIListLayout",
    {
        Padding = UDim.new(
            0,
            8
        ),

        SortOrder =
            Enum.SortOrder.LayoutOrder
    },
    scroll
)

local order = 0

-- =========================================================
-- UI FUNCTIONS
-- =========================================================

local function label(
    text,
    height,
    fontSize,
    color
)

    order = order + 1

    return make(
        "TextLabel",
        {
            Size = UDim2.new(
                1,
                -10,
                0,
                height or 28
            ),

            LayoutOrder = order,

            BackgroundTransparency = 1,

            Text = text,

            TextColor3 =
                color or colors.Text,

            TextSize =
                fontSize or 13,

            Font =
                Enum.Font.Gotham,

            TextWrapped = true,

            TextXAlignment =
                Enum.TextXAlignment.Left
        },
        scroll
    )
end

local function section(text)

    order = order + 1

    local frame = make(
        "Frame",
        {
            Size = UDim2.new(
                1,
                -10,
                0,
                34
            ),

            LayoutOrder = order,

            BackgroundColor3 =
                colors.Panel,

            BorderSizePixel = 0
        },
        scroll
    )

    corner(frame, 8)

    make(
        "TextLabel",
        {
            Size = UDim2.new(
                1,
                -18,
                1,
                0
            ),

            Position =
                UDim2.fromOffset(
                    9,
                    0
                ),

            BackgroundTransparency = 1,

            Text = text,

            TextColor3 =
                colors.Accent,

            TextSize = 13,

            Font =
                Enum.Font.GothamBold,

            TextXAlignment =
                Enum.TextXAlignment.Left
        },
        frame
    )
end

local function buttonRow(specs)

    order = order + 1

    local frame = make(
        "Frame",
        {
            Size = UDim2.new(
                1,
                -10,
                0,
                42
            ),

            LayoutOrder = order,

            BackgroundTransparency = 1
        },
        scroll
    )

    for index, spec in ipairs(specs) do

        local count = #specs

        local button = make(
            "TextButton",
            {
                Size = UDim2.new(
                    1 / count,
                    -5,
                    1,
                    0
                ),

                Position = UDim2.new(
                    (index - 1) / count,
                    0,
                    0,
                    0
                ),

                BackgroundColor3 =
                    colors.Panel,

                BorderSizePixel = 0,

                Text = spec[1],

                TextColor3 =
                    colors.Text,

                TextSize = 12,

                TextWrapped = true,

                Font =
                    Enum.Font.GothamMedium
            },
            frame
        )

        corner(button, 8)

        connect(
            button.Activated,
            spec[2]
        )
    end

    return frame
end

-- =========================================================
-- STATUS
-- =========================================================

section("STATUS")

local wallet =
    label(
        "Waiting for server...",
        30,
        14
    )

local stats =
    label(
        "",
        32,
        12,
        colors.Muted
    )

local battleLabel =
    label(
        "No encounter",
        46,
        14
    )

local message =
    label(
        "Connecting...",
        46,
        12,
        colors.Muted
    )

-- =========================================================
-- SEND REQUEST
-- =========================================================

local function send(action, argument)

    if not Runtime.Running then
        return
    end

    local now = os.clock()

    local requestInterval =
        Config.RequestInterval or 0.15

    if pending then
        return
    end

    if now - lastSent <
        requestInterval + 0.03
    then
        return
    end

    lastSent = now

    if action ~= "Fuse" then
        confirmFusion = nil
    end

    pending = true

    sequence = sequence + 1

    local current =
        sequence

    message.Text =
        "Waiting for server..."

    message.TextColor3 =
        colors.Muted

    request:FireServer(
        action,
        argument
    )

    task.delay(
        3,
        function()

            if not Runtime.Running then
                return
            end

            if current == sequence
                and pending then

                pending = false

                message.Text =
                    "No server response."

                message.TextColor3 =
                    colors.Error
            end
        end
    )
end

-- =========================================================
-- ENCOUNTER
-- =========================================================

section("ENCOUNTER")

buttonRow({
    {
        "Boss",
        function()
            send(
                "Start",
                "Boss"
            )
        end
    },

    {
        "Raid",
        function()
            send(
                "Start",
                "Raid"
            )
        end
    },

    {
        "Castle",
        function()
            send(
                "Start",
                "Castle"
            )
        end
    }
})

buttonRow({
    {
        "ATTACK",
        function()
            send("Attack")
        end
    },

    {
        "LEAVE",
        function()
            send("Leave")
        end
    },

    {
        "REFRESH",
        function()
            send("Sync")
        end
    }
})

-- =========================================================
-- AUTO ATTACK
-- =========================================================

local autoAttackButton

autoAttackButton =
    buttonRow({
        {
            "Auto Attack: OFF",

            function()

                Runtime.AutoAttack =
                    not Runtime.AutoAttack

                local buttons =
                    autoAttackButton:
                    GetChildren()

                for _, object
                    in ipairs(buttons) do

                    if object:
                        IsA("TextButton") then

                        object.Text =
                            Runtime.AutoAttack
                            and
                            "Auto Attack: ON"
                            or
                            "Auto Attack: OFF"
                    end
                end
            end
        }
    })

task.spawn(function()

    while Runtime.Running do

        if Runtime.AutoAttack
            and state
            and state.Battle
            and not pending then

            send("Attack")
        end

        task.wait(
            math.max(
                Config.AttackInterval
                    or 0.45,
                0.45
            )
        )
    end
end)

-- =========================================================
-- RAID AUTO EQUIP
-- =========================================================

local autoEquipLabel =
    label(
        "Raid Auto Equip: loading...",
        28,
        12,
        colors.Accent
    )

buttonRow({
    {
        "Toggle Raid Auto Equip",

        function()

            if state then

                send(
                    "SetRaidAutoEquip",
                    not
                    state.AutoEquipBestRaid
                )
            end
        end
    }
})

-- =========================================================
-- REWARDS
-- =========================================================

section("REWARDS")

local rewards =
    label(
        "No pending rewards",
        32,
        12,
        colors.Muted
    )

buttonRow({
    {
        "Collect Reward",
        function()
            send("Collect")
        end
    }
})

-- =========================================================
-- SUMMON
-- =========================================================

section("SUMMON")

buttonRow({
    {
        "Fighter",
        function()
            send(
                "Roll",
                "Fighter"
            )
        end
    },

    {
        "Boss",
        function()
            send(
                "Roll",
                "Boss"
            )
        end
    }
})

-- =========================================================
-- TEAM
-- =========================================================

section("TEAM")

buttonRow({
    {
        "Equip Best",
        function()
            send(
                "EquipBest"
            )
        end
    }
})

local selectedLabel =
    label(
        "Select a unit.",
        48,
        12
    )

local function unitAction(action)

    if not selected then

        message.Text =
            "Select a unit first."

        message.TextColor3 =
            colors.Error

        return
    end

    if action == "Fuse" then

        if confirmFusion
            ~= selected then

            confirmFusion =
                selected

            message.Text =
                "Press Fuse again to confirm."

            message.TextColor3 =
                colors.Muted

            return
        end

        confirmFusion = nil
    end

    send(
        action,
        selected
    )
end

buttonRow({
    {
        "Equip",
        function()
            unitAction(
                "Equip"
            )
        end
    },

    {
        "Upgrade",
        function()
            unitAction(
                "Upgrade"
            )
        end
    },

    {
        "Fuse",
        function()
            unitAction(
                "Fuse"
            )
        end
    }
})

buttonRow({
    {
        "Mutation",
        function()
            unitAction(
                "Mutation"
            )
        end
    },

    {
        "Awaken",
        function()
            unitAction(
                "Awaken"
            )
        end
    }
})

-- =========================================================
-- INVENTORY
-- =========================================================

section("INVENTORY")

order = order + 1

local inventory =
    make(
        "Frame",
        {
            Size = UDim2.new(
                1,
                -10,
                0,
                0
            ),

            AutomaticSize =
                Enum.AutomaticSize.Y,

            BackgroundTransparency = 1,

            LayoutOrder = order
        },
        scroll
    )

make(
    "UIListLayout",
    {
        Padding =
            UDim.new(
                0,
                5
            ),

        SortOrder =
            Enum.SortOrder.LayoutOrder
    },
    inventory
)

local inventorySignature = ""

local function renderInventory()

    if not state then
        return
    end

    local signatureParts = {
        tostring(selected)
    }

    for _, unit
        in ipairs(state.Units or {}) do

        table.insert(
            signatureParts,

            table.concat({
                unit.UID,
                unit.Level,
                unit.Fusion,
                unit.Mutation,
                tostring(
                    unit.Awakened
                ),
                tostring(
                    unit.Equipped
                )
            }, ":")
        )
    end

    local signature =
        table.concat(
            signatureParts,
            "|"
        )

    if signature ==
        inventorySignature then

        return
    end

    inventorySignature =
        signature

    for _, child
        in ipairs(
            inventory:
            GetChildren()
        ) do

        if child:
            IsA("TextButton") then

            child:Destroy()
        end
    end

    for index, unit
        in ipairs(
            state.Units or {}
        ) do

        local text =
            string.format(
                "%s#%d %s · %s\nLv.%d | Fusion %d | %s | Power %d%s",

                unit.Equipped
                    and "[TEAM] "
                    or "",

                unit.UID,

                tostring(unit.Name),

                tostring(unit.Rarity),

                unit.Level,

                unit.Fusion,

                tostring(
                    unit.Mutation
                ),

                unit.Power,

                unit.Awakened
                    and
                    " | Awakened"
                    or ""
            )

        local unitButton =
            make(
                "TextButton",
                {
                    Size =
                        UDim2.new(
                            1,
                            0,
                            0,
                            58
                        ),

                    LayoutOrder =
                        index,

                    BackgroundColor3 =
                        unit.UID ==
                            selected
                        and
                        Color3.fromRGB(
                            40,
                            78,
                            91
                        )
                        or
                        colors.Panel,

                    BorderSizePixel = 0,

                    Text = text,

                    TextColor3 =
                        colors.Text,

                    TextSize = 11,

                    TextWrapped = true,

                    Font =
                        Enum.Font.Gotham
                },
                inventory
            )

        corner(
            unitButton,
            8
        )

        connect(
            unitButton.Activated,

            function()

                selected =
                    unit.UID

                confirmFusion =
                    nil

                selectedLabel.Text =
                    string.format(
                        "Selected #%d %s\nUpgrade: %d coins",

                        unit.UID,

                        tostring(
                            unit.Name
                        ),

                        unit.Level * 25
                    )

                inventorySignature = ""

                renderInventory()
            end
        )
    end
end

-- =========================================================
-- RECEIVE SERVER STATE
-- =========================================================

connect(
    response.OnClientEvent,

    function(
        snapshot,
        text,
        successful
    )

        pending = false

        if type(snapshot)
            ~= "table" then

            message.Text =
                "Invalid server state."

            message.TextColor3 =
                colors.Error

            return
        end

        state = snapshot

        message.Text =
            text or "Ready"

        message.TextColor3 =
            successful == false
            and colors.Error
            or colors.Text

        wallet.Text =
            string.format(
                "Coins: %d    Gems: %d    Crystals: %d",

                state.Coins or 0,

                state.Gems or 0,

                state.Crystals or 0
            )

        stats.Text =
            string.format(
                "Power: %d | Wins: %d | Best room: %d | Units: %d/%d",

                state.TeamPower or 0,

                state.Wins or 0,

                state.BestRoom or 0,

                #(state.Units or {}),

                Config.InventoryLimit
                    or 100
            )

        if state.Battle then

            local battle =
                state.Battle

            battleLabel.Text =
                string.format(
                    "%s | Wave %d/%d\nHP %d / %d",

                    tostring(
                        battle.Mode
                    ),

                    battle.Wave,

                    battle.Waves,

                    battle.Health,

                    battle.MaxHealth
                )

        else

            battleLabel.Text =
                "No active encounter"
        end

        local pendingReward =
            state.Pending
            or {}

        rewards.Text =
            string.format(
                "Pending: %d coins | %d gems | %d crystals",

                pendingReward.Coins
                    or 0,

                pendingReward.Gems
                    or 0,

                pendingReward.Crystals
                    or 0
            )

        local raidConfig =
            Config.RaidAutoEquip
            or {}

        autoEquipLabel.Text =
            string.format(
                "Raid Auto Equip: %s | %d-%ds",

                state.AutoEquipBestRaid
                    and "ON"
                    or "OFF",

                raidConfig.MinSeconds
                    or 0,

                raidConfig.MaxSeconds
                    or 0
            )

        local selectedUnit = nil

        for _, unit
            in ipairs(
                state.Units
                or {}
            ) do

            if unit.UID ==
                selected then

                selectedUnit =
                    unit

                break
            end
        end

        if selected
            and not selectedUnit then

            selected = nil
            confirmFusion = nil

            selectedLabel.Text =
                "Select a unit."
        end

        renderInventory()
    end
)

-- =========================================================
-- KEYBINDS
-- =========================================================

connect(
    UserInputService.InputBegan,

    function(
        input,
        processed
    )

        if processed then
            return
        end

        if input.KeyCode ==
            Enum.KeyCode.RightControl then

            main.Visible =
                not main.Visible

        elseif input.KeyCode ==
            Enum.KeyCode.Space then

            if state
                and state.Battle then

                send("Attack")
            end
        end
    end
)

-- =========================================================
-- CLOSE / STOP
-- =========================================================

function Runtime.Stop()

    if not Runtime.Running then
        return
    end

    Runtime.Running = false
    Runtime.AutoAttack = false

    for _, connection
        in ipairs(
            Runtime.Connections
        ) do

        pcall(function()
            connection:
                Disconnect()
        end)
    end

    table.clear(
        Runtime.Connections
    )

    if gui then
        gui:Destroy()
    end

    if env.AnimeBossDemoHub
        == Runtime then

        env.AnimeBossDemoHub =
            nil
    end

    print(
        "[AnimeBoss] Script stopped."
    )
end

connect(
    close.Activated,
    Runtime.Stop
)

-- =========================================================
-- START
-- =========================================================

print(
    "[AnimeBoss] Client loaded."
)

print(
    "[AnimeBoss] RightCtrl = hide/show"
)

send("Sync")

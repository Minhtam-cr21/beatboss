print("========== GAME INFO ==========")
print("PlaceId:", game.PlaceId)
print("GameId:", game.GameId)
print("JobId:", game.JobId)

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("\n========== REMOTES ==========")

for _, v in ipairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        print(v.ClassName, v:GetFullName())
    end
end

print("\n========== POSSIBLE RAID / CASTLE / UNIT OBJECTS ==========")

local keywords = {
    "raid",
    "castle",
    "infinite",
    "unit",
    "equip",
    "inventory",
    "lobby",
    "queue",
    "teleport",
    "stage",
    "wave",
    "battle"
}

for _, v in ipairs(game:GetDescendants()) do
    local name = string.lower(v.Name)

    for _, word in ipairs(keywords) do
        if string.find(name, word, 1, true) then
            print(v.ClassName, v:GetFullName())
            break
        end
    end
end

print("\n========== PLAYER GUI ==========")

if player:FindFirstChild("PlayerGui") then
    for _, v in ipairs(player.PlayerGui:GetDescendants()) do
        local name = string.lower(v.Name)

        if string.find(name, "raid")
        or string.find(name, "castle")
        or string.find(name, "unit")
        or string.find(name, "equip") then
            print(v.ClassName, v:GetFullName())
        end
    end
end

print("========== SCAN FINISHED ==========")

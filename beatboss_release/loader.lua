-- BeatBoss loader.lua
-- Minimal loader: downloads and executes main.lua from GitHub.

local MAIN_URL =
    "https://raw.githubusercontent.com/Minhtam-cr21/beatboss/main/main.lua?nocache="
    .. tostring(os.time())

local ok, source = pcall(function()
    return game:HttpGet(MAIN_URL)
end)

if not ok then
    error("[BeatBoss] Failed to download main.lua: " .. tostring(source))
end

if type(source) ~= "string" or #source < 10 then
    error("[BeatBoss] main.lua returned empty/invalid content")
end

if source:find("404: Not Found", 1, true) then
    error("[BeatBoss] main.lua returned 404")
end

local fn, compileError = loadstring(source)

if not fn then
    error("[BeatBoss] main.lua compile error: " .. tostring(compileError))
end

fn()

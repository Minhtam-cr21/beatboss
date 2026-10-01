-- AnimeBossDemo Loader
-- GitHub: Minhtam-cr21/beatboss

local MAIN_URL =
    "https://raw.githubusercontent.com/Minhtam-cr21/beatboss/main/AnimeBossDemo/main.lua"

print("[AnimeBoss] Loader starting...")

if type(loadstring) ~= "function" then
    error("[AnimeBoss] loadstring is not available")
end

local ok, source = pcall(function()
    return game:HttpGet(MAIN_URL)
end)

if not ok then
    error("[AnimeBoss] Cannot download main.lua: " .. tostring(source))
end

if not source or #source < 50 then
    error("[AnimeBoss] main.lua returned empty/invalid content")
end

if source:find("404: Not Found", 1, true) then
    error("[AnimeBoss] main.lua not found on GitHub")
end

local compiled, compileError = loadstring(source)

if not compiled then
    error("[AnimeBoss] main.lua compile error: " .. tostring(compileError))
end

local success, runtimeError = pcall(compiled)

if not success then
    error("[AnimeBoss] main.lua runtime error: " .. tostring(runtimeError))
end

print("[AnimeBoss] Loader finished.")

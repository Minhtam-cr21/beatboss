local MAIN_URL = "https://raw.githubusercontent.com/Minhtam-cr21/beatboss/main/main.lua"

print("[AnimeBoss] Loader starting...")
print("[AnimeBoss] URL:", MAIN_URL)

local ok, source = pcall(function()
    return game:HttpGet(MAIN_URL)
end)

if not ok then
    error("[AnimeBoss] HttpGet failed: " .. tostring(source))
end

print("[AnimeBoss] Download length:", #source)
print("[AnimeBoss] First content:", source:sub(1, 100))

if source:find("404: Not Found", 1, true) then
    error("[AnimeBoss] main.lua = 404 Not Found")
end

if #source < 20 then
    error("[AnimeBoss] main.lua quá ngắn: " .. tostring(#source) .. " bytes")
end

local func, err = loadstring(source)

if not func then
    error("[AnimeBoss] Compile error: " .. tostring(err))
end

local success, runtimeError = pcall(func)

if not success then
    error("[AnimeBoss] Runtime error: " .. tostring(runtimeError))
end

print("[AnimeBoss] Loaded successfully.")

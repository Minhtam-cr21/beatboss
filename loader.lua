print("[AnimeBoss] Loader starting...")

local MAIN_URL =
    "https://raw.githubusercontent.com/Minhtam-cr21/beatboss/main/main.lua?nocache="
    .. os.time()

local ok, source = pcall(function()
    return game:HttpGet(MAIN_URL)
end)

if not ok then
    error("[AnimeBoss] Cannot download main.lua: " .. tostring(source))
end

print("[AnimeBoss] Download length:", #source)
print("[AnimeBoss] First content:", source:sub(1, 100))

if type(source) ~= "string" or #source == 0 then
    error("[AnimeBoss] main.lua returned empty content")
end

if source:find("404: Not Found", 1, true) then
    error("[AnimeBoss] main.lua URL returned 404")
end

local main, compileError = loadstring(source)

if not main then
    error("[AnimeBoss] main.lua compile error: " .. tostring(compileError))
end

print("[AnimeBoss] main.lua loaded successfully")

main()

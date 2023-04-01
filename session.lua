VERSION = "0.0.1"
local micro = import("micro")
local config = import("micro/config")
local buffer = import("micro/buffer")

local cwd = config.ConfigDir .. "/plug/session/"
local loaded = false


function file_exists(name)
   local f = io.open(name, "r")
   return f ~= nil and io.close(f)
end

function onBufferOpen(bp)
    if loaded == false then
        return true
    end

    if file_exists(bp.AbsPath) == true and bp.Path ~= "" then
        local f = io.open(cwd .. "current_session", "a+")
        
        if f == nil then
            return false
        end
        
        f:write(bp.AbsPath .. "\n")
        io.close(f)
    end
    return true
    
end

function preQuit(bp)
    
    local path = cwd .. "current_session"
    local f = io.open(path, "r")
    --local lines = f:lines()
    local data = f:read("*a")
    local fn = bp:Name()

    io.close(f)
    
    f = io.open(path, "w+")
    
    for token in data:gmatch("[^\r\n]+") do
        if token ~= fn then
            f:write(token .. "\n")
        end
    end
    
    io.close(f)

end

function init() 
    local f = io.open(cwd .. "current_session", "r")
    local lines = f:lines()
    
    -- load all files from previous session
    for line in lines do
        micro.CurPane():NewTabCmd( {line} )
    end
    io.close(f)
    
    loaded = true
end

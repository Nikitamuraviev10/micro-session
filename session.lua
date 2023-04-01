VERSION = "0.0.2"
local micro = import("micro")
local config = import("micro/config")
local buffer = import("micro/buffer")

local cwd = config.ConfigDir .. "/plug/session/"
local loaded = false


function file_exists(name)
   local f = io.open(name, "r")
   return f ~= nil and io.close(f)
end

function pop_from_file(path, fn)

    micro.Log("Remove from session " .. fn)
    local f = io.open(path, "r")
    if f == nil then
        return
    end
    
    local data = f:read("*a")

    io.close(f)
    
    f = io.open(path, "w+")
    for token in data:gmatch("[^\r\n]+") do
        if token ~= fn then
            f:write(token .. "\n")
        end
    end
    io.close(f)
end


function onBufferOpen(bp)
    if loaded == false then
        return true
    end

    local fn = cwd .. "current_session"

    if file_exists(bp.AbsPath) == true and bp.Path ~= "" then
        local f = io.open(fn, "a+")
        
        if f == nil then
            return false
        end
        
        -- Reopen file in current tab
        pop_from_file(fn, micro.CurPane().Buf.AbsPath)
        micro.Log("Append to session " .. bp.AbsPath)
        f:write(bp.AbsPath .. "\n")
        io.close(f)
    end
    return true
    
end

function preQuit(bp)
    
    local path = cwd .. "current_session"
    local fn = bp.Buf.AbsPath
    pop_from_file(path, fn)

end

function init() 
    local f = io.open(cwd .. "current_session", "r")
    if f ~= nil then
        local lines = f:lines()
        
        -- load all files from previous session
        micro.CurPane():OpenCmd( {lines()} )
        for line in lines do
            micro.CurPane():NewTabCmd( {line} )
        end
        io.close(f)
    end
    
    loaded = true
end

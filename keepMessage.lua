local M = {}

local cw = display.contentWidth
local ch = display.contentHeight
local cx = display.contentCenterX
local cy = display.contentCenterY

M.filename = "message.txt"
--M.highScore
function M.load()
    local path = system.pathForFile( M.filename, system.DocumentsDirectory)
    local contents = ""
    local file = io.open( path, "r" )
    if file then
         -- read all contents of file into a string
         local contents = file:read( "*a" )
         local messageNo = tonumber(contents);
         io.close( file )
         return messageNo
    else
        print("Could not read scores from ", M.filename, ".")
        return nil
    end
end

function M.save(value)
	local path = system.pathForFile( M.filename, system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        local contents = tostring( value )
        file:write( contents )
        io.close( file )
        return true
    else
    	print("Error: could not read ", M.filename, ".")
        return false
    end
end


return M
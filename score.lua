-- Score Module
--

local M = {} -- create our local M = {}
M.highScore = 0


local cw = display.contentWidth
local ch = display.contentHeight
local cx = display.contentCenterX
local cy = display.contentCenterY

function M.init( options )

--[[local customOptions = options or {}
	local opt = {}
	opt.fontSize = customOptions.fontSize or 24
	opt.font = customOptions.font or native.systemFontBold
	opt.x = customOptions.x or display.contentCenterX
	opt.y = customOptions.y or opt.fontSize * 0.5
	opt.maxDigits = customOptions.maxDigits or 6
	opt.leadingZeros = customOptions.leadingZeros or false
	M.filename = customOptions.filename or "scorefile.txt"

	local prefix = ""
	if opt.leadingZeros then 
		prefix = "0"
	end
	M.format = "%" .. prefix .. opt.maxDigits .. "d"]]



	M.highScoreText = display.newText(M.highScore, cx, cy,native.systemFont, 20 )
	return M.highScoreText
end

function M.set( value )
	M.highScore = value
	highScoreText.text = (M.highScore)

end

function M.get()
	return M.highScore
end

function M.add( amount )
	M.highScore = M.score + amount
	M.highScoreText.text = string.format(M.format, M.highScore)
end

function M.save()
	local path = system.pathForFile( M.filename, system.DocumentsDirectory)
    local file = io.open(path, "w")
    if file then
        local contents = tostring( M.highScore )
        file:write( contents )
        io.close( file )
        return true
    else
    	print("Error: could not read ", M.filename, ".")
        return false
    end
end

function M.load()
    local path = system.pathForFile( M.filename, system.DocumentsDirectory)
    local contents = ""
    local file = io.open( path, "r" )
    if file then
         -- read all contents of file into a string
         local contents = file:read( "*a" )
         local highSscore = tonumber(contents);
         io.close( file )
         return highScore
    end
    print("Could not read scores from ", M.filename, ".")
    return nil
end

return M

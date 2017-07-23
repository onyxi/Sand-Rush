--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:adb92e184137da79d4bfeb83a063c50d:aa736666b82b44406616ccf06449b237:ed9bccf5f6a14012736a2babf88fae7d$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- t1
            x=40,
            y=2,
            width=17,
            height=60,

        },
        {
            -- t2
            x=21,
            y=2,
            width=17,
            height=60,

        },
        {
            -- t3
            x=2,
            y=2,
            width=17,
            height=60,

        },
    },
    
    sheetContentWidth = 59,
    sheetContentHeight = 64
}

SheetInfo.frameIndex =
{

    ["t1"] = 1,
    ["t2"] = 2,
    ["t3"] = 3,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo

--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:61fdb7f8dc14273f340ff28223fb7499:ae26d94da91280230ebf9045b0667d1f:ed9bccf5f6a14012736a2babf88fae7d$
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
            -- 1
            x=271,
            y=2,
            width=54,
            height=54,

        },
        {
            -- 2
            x=217,
            y=2,
            width=54,
            height=54,

        },
        {
            -- 3
            x=163,
            y=2,
            width=54,
            height=54,

        },
        {
            -- 4
            x=109,
            y=2,
            width=54,
            height=54,

        },
        {
            -- 5
            x=55,
            y=2,
            width=54,
            height=54,

        },
        {
            -- 6
            x=1,
            y=2,
            width=54,
            height=54,

        },
    },
    
    sheetContentWidth = 326,
    sheetContentHeight = 56
}

SheetInfo.frameIndex =
{

    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo

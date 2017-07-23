

display.setStatusBar (display.HiddenStatusBar)
--> Hides the status bar

local composer = require "composer"
local facebook = require( "facebook" )
local TwitterManager = require( "scripts.Twitter" )
local myData = require("scripts.myData")
myData.tryCount = math.random(1,2)


 ------- require scripts -------
physics = require ("physics")
--tnt = require ("scripts.tnt")
_G.TextCandy = require("lib_text_candy")
_G.TextCandy.AddCharset("numbersFont", "numbersCode", "numbers.png", "0123456789", 5)



-------load sounds----------------
----------------------------------
mainSong1 = audio.loadSound( "audio/mainSong1.wav" )
mainSong2 = audio.loadSound( "audio/mainSong2.wav" )
endSong = audio.loadSound("audio/endTune.wav")
audio.setVolume( 0.7 ,{channel = 6} )
bushSound1 = audio.loadSound("audio/weed1.wav")
bushSound2 = audio.loadSound("audio/weed2.wav")
bushSound3 = audio.loadSound("audio/weed3.wav")
gateSound = audio.loadSound("audio/gateSound.wav")
audio.setVolume( 0.1 ,{channel=5} )

---- play desert Sounds ---------
----------------------------------
local cricketSound =  audio.loadSound( "audio/cricketSound.wav" )
--audio.setVolume(0, {channel=1})
    --[[local playCricketSound
    playCricketSound = function()
      audio.play(cricketSound)
    --timer.performWithDelay(157500, playCricketSound)
    end]]
    local cricketSoundOptions = 
      {
        channel = 1,
        loops = -1,
        fadein = 3000
      }
      local cricketSoundDelay = function()
        audio.play(cricketSound, cricketSoundOptions)
      end
      timer.performWithDelay(100, cricketSoundDelay)
  --timer.performWithDelay(157500, playDesertSound)

-------------------------------------------
-------------------------------------------

---------------------------------- ads ----------------------------------

-----------listeners----------------------------------
--------------------------------------------------------------
local ads = require( "ads" )

local function vungleListener( event )
   -- Video ad not yet downloaded and available
   if ( event.type == "adStart" and event.isError ) then
      if ( system.getInfo("platformName") == "Android" ) then
         ads:setCurrentProvider( "admob" )
      else
         ads:setCurrentProvider( "iads" )
      end
      myData.adType = "interstitial"
      ads.show( "interstitial" )
   elseif ( event.type == "adEnd" ) then
      -- Ad was successfully shown and ended; hide the overlay so the app can resume.
      storyboard.hideOverlay()

   else
      print( "Received event", event.type )
   end
   return true
end


local function adMobListener( event )
   if ( event.isError ) then
     -- storyboard.showOverlay( "selfpromo" )
   end
   return true
end


local function iAdsListener( event )
   if (event.isError ) then
     -- storyboard.showOverlay( "selfpromo" )
        ads:setCurrentProvider( "admob" )
        if myData.adType == "interstitial" then
          ads.show("interstitial", {appId = "ca-app-pub-9588489135351549/7033011917"})
        else
          ads.show( "banner", {x = 0, y = 100000, appId = "ca-app-pub-9588489135351549/9347349916"})
        end
   end
   return true
end
-----------------initiate ads----
----------------------------------

ads.init( "vungle", "54442aba8aac827b320000c1", vungleListener )
ads.init( "admob", "ca-app-pub-9588489135351549/9347349916", adMobListener )
--ads.show( "banner" , { appId = "ca-app-pub-9588489135351549/9347349916", x=0, y=100000 } )
--ads.show( "interstitial" , { appId = "ca-app-pub-9588489135351549/7033011917", x=0, y=100000 } )
ads.init( "iads", "uk.co.onyxinteractive.timmy", iAdsListener )
--ads.show( "banner" , { x=0, y=100000 } )




---------------get device font names----------------------------------
--------------------------------------------------------------------
--[[
local fonts = native.getFontNames()
for i,fontname in ipairs(fonts) do
    print(fonts[i])
end
]]
--------------------------------------------------------------------

----------------ONYX logo------------------
------------------------------------
local logoGroup = display.newGroup()

local ch = display.contentHeight
local cw = display.contentWidth
local cx = display.contentCenterX
local cy = display.contentCenterY

local textWidth = 12
local centreLogoX = cx - (1+((textWidth/26)*370))/2
local textCorner = (textWidth/30)*14
local startPosX = centreLogoX
-- cx-213

local startPosY = cy-100
local circleRad = textWidth*1.5

local bgColor1 = 20/255
local bgColor2 = 20/255
local bgColor3 = 20/255
local textColor1 = 255/255
local textColor2 = 255/255
local textColor3 = 232/255


local bg = display.newRect(cx, cy,cw, ch)
bg:setFillColor(bgColor1, bgColor2, bgColor3)
logoGroup:insert(bg)

local myCircle = display.newCircle(startPosX, startPosY, circleRad)
myCircle.strokeWidth = textWidth
myCircle:setStrokeColor(textColor1, textColor2, textColor3)
myCircle:setFillColor(bgColor1, bgColor2, bgColor3)
myCircle.alpha = 0
logoGroup:insert(myCircle)

local onLineBack = display.newRoundedRect(startPosX, startPosY - ((textWidth/26)*30), (textWidth/26)*40, (textWidth/26)*70, textCorner)
onLineBack:setFillColor(bgColor1, bgColor2, bgColor3)
logoGroup:insert(onLineBack)
local onLine = display.newRoundedRect(startPosX, startPosY - ((textWidth/26)*60), textWidth, (textWidth/26)*60, textCorner)
onLine:setFillColor(textColor1, textColor2, textColor3)
onLine.anchorY = 0
onLine.yScale = 0.5
onLine.alpha = 0
logoGroup:insert(onLine)

local n1 = display.newRoundedRect(startPosX+((textWidth/26)*88), startPosY+((textWidth/26)*50), textWidth, (textWidth/26)*100, textCorner)
n1:setFillColor(textColor1, textColor2, textColor3)
n1.anchorY = 1
n1.yScale = 0.25
n1.alpha = 0
logoGroup:insert(n1)

local n2 = display.newRoundedRect(startPosX+((textWidth/26)*80), startPosY-((textWidth/26)*48), (textWidth/26)*130, textWidth, textCorner)
n2:setFillColor(textColor1, textColor2, textColor3)
n2.rotation = 45
n2.anchorX = 0
n2.xScale = 0.2
n2.alpha = 0
logoGroup:insert(n2)

local n3 = display.newRoundedRect(startPosX+((textWidth/26)*168), startPosY+((textWidth/26)*48), textWidth,(textWidth/26)*100, textCorner)
n3:setFillColor(textColor1, textColor2, textColor3)
n3.anchorY = 1
n3.yScale = 0.25
n3.alpha = 0
logoGroup:insert(n3)

local y1 = display.newRoundedRect(startPosX+((textWidth/26)*250), startPosY-((textWidth/26)*12), textWidth,(textWidth/26)*60, textCorner)
y1:setFillColor(textColor1, textColor2, textColor3)
y1.anchorY=0
y1.yScale = 0.25
y1.alpha = 0
logoGroup:insert(y1)

local y2 = display.newRoundedRect(startPosX+((textWidth/26)*245), startPosY, textWidth,(textWidth/26)*70, textCorner)
y2:setFillColor(textColor1, textColor2, textColor3)
y2.anchorY=1
y2.rotation = 45
y2.yScale = 0.2
y2.alpha = 0
logoGroup:insert(y2)

local y3 = display.newRoundedRect(startPosX+((textWidth/26)*255), startPosY, textWidth,(textWidth/26)*70, textCorner)
y3:setFillColor(textColor1, textColor2, textColor3)
y3.anchorY=1
y3.rotation = -45
y3.yScale = 0.2
y3.alpha = 0
logoGroup:insert(y3)

local x1 = display.newRoundedRect(startPosX+((textWidth/26)*370), startPosY, (textWidth/26)*130,textWidth,textCorner)
x1:setFillColor(textColor1, textColor2, textColor3)
x1.rotation = 45
x1.xScale = 0.15
x1.alpha = 0
logoGroup:insert(x1)

local x2 = display.newRoundedRect(startPosX+((textWidth/26)*370), startPosY, (textWidth/26)*130,textWidth,textCorner)
x2:setFillColor(textColor1, textColor2, textColor3)
x2.rotation = -45
x2.xScale = 0.15
x2.alpha = 0
logoGroup:insert(x2)

local interactiveText = display.newText("interactive", startPosX+((1+((textWidth/26)*370))/2), startPosY+(textWidth/26)*100, "IndieFlower",(textWidth/26)*86)
interactiveText.yScale = 0.6
interactiveText.alpha = 0
logoGroup:insert(interactiveText)

--
local startSize = (textWidth/26)*14
local oStart = display.newCircle(startPosX+((1+((textWidth/26)*370))/2), startPosY, startSize)
oStart:setFillColor(textColor1, textColor2, textColor3)
oStart.alpha=0
oStart.xScale = 0.01
oStart.yScale = 0.01
logoGroup:insert(oStart)

local n1Start = display.newCircle(startPosX+((1+((textWidth/26)*370))/2), startPosY,startSize)
n1Start:setFillColor(textColor1, textColor2, textColor3)
n1Start.alpha=0
n1Start.xScale = 0.01
n1Start.yScale = 0.01
logoGroup:insert(n1Start)

local n2Start = display.newCircle(startPosX+((1+((textWidth/26)*370))/2),startPosY, startSize)
n2Start:setFillColor(textColor1, textColor2, textColor3)
n2Start.alpha=0
n2Start.xScale = 0.01
n2Start.yScale = 0.01
logoGroup:insert(n2Start)

local n3Start = display.newCircle(startPosX+((1+((textWidth/26)*370))/2),startPosY, startSize)
n3Start:setFillColor(textColor1, textColor2, textColor3)
n3Start.alpha=0
n3Start.xScale = 0.01
n3Start.yScale = 0.01
logoGroup:insert(n3Start)

local yStart = display.newCircle(startPosX+((1+((textWidth/26)*370))/2),startPosY, startSize)
yStart:setFillColor(textColor1, textColor2, textColor3)
yStart.alpha=0
yStart.xScale = 0.01
yStart.yScale = 0.01
logoGroup:insert(yStart)

local xStart = display.newCircle(startPosX+((1+((textWidth/26)*370))/2),startPosY, startSize)
xStart:setFillColor(textColor1, textColor2, textColor3)
xStart.alpha=0
xStart.xScale = 0.01
xStart.yScale = 0.01
logoGroup:insert(xStart)


local startFade = function()
  local startMove = function()
  local easeType = easing.outExpo
  local easeTime = 1000
    transition.to(oStart, {time = easeTime, x = startPosX, y = startPosY-((textWidth/26)*46) , transition = easeType})
    transition.to(n1Start, {time = easeTime, x = startPosX+((textWidth/26)*88), y = startPosY+((textWidth/26)*38), transition = easeType})
    transition.to(n2Start, {time = easeTime, x = startPosX+((textWidth/26)*88), y = startPosY-((textWidth/26)*38) , transition = easeType})
    transition.to(n3Start, {time = easeTime, x = startPosX+((textWidth/26)*168), y = startPosY+((textWidth/26)*38) , transition = easeType})
    transition.to(yStart, {time = easeTime, x = startPosX+((textWidth/26)*250), y = startPosY-((textWidth/26)*5), transition = easeType})
    transition.to(xStart, {time = easeTime, x = startPosX+((textWidth/26)*370), y = startPosY, transition = easeType})
  end
  timer.performWithDelay(1500, startMove)
  local easeType = easing.inCubic
  local growTime = 1500
  transition.to(oStart, {time = growTime, alpha = 1, xScale = 1, yScale = 1, transition = easeType})
  transition.to(n1Start, {time = growTime, alpha = 1, xScale = 1, yScale = 1, transition = easeType})
  transition.to(n2Start, {time = growTime, alpha = 1, xScale = 1, yScale = 1, transition = easeType})
  transition.to(n3Start, {time = growTime, alpha = 1, xScale = 1, yScale = 1, transition = easeType})
  transition.to(yStart, {time = growTime, alpha = 1, xScale = 1, yScale = 1, transition = easeType})
  transition.to(xStart, {time = growTime, alpha = 1, xScale = 1, yScale = 1, transition = easeType})
end
startFade()

local function logoTrans()
   local fadeIn = function() 
      --local interactiveFade = function()
        transition.to(interactiveText, {time = 1000, alpha = 1, transition = easing.inQuad})
       --end

       --timer.performWithDelay(300, interactiveFade)
    transition.to(x1, {time = 1000, xScale = 1, alpha = 1})
    transition.to(x2, {time = 1000, xScale = 1, alpha = 1})
    transition.to(myCircle, {time = 1000, alpha = 1, transition = easing.inCubic})
    transition.to(onLine, {time = 1000, yScale = 1})
    transition.to(n1, {time = 1000, yScale = 1})
    transition.to(n2, {time = 1000, xScale = 1})
    transition.to(n3, {time = 1000, yScale = 1})
    transition.to(y1, {time = 1000, yScale = 1})
    transition.to(y2, {time = 1000, yScale = 1})
    transition.to(y3, {time = 1000, yScale = 1})

  end
    local easeTime = 300
    transition.to(x1, {time = easeTime, alpha = 1})
    transition.to(x2, {time = easeTime, alpha = 1})
    transition.to(onLine, {time = easeTime, alpha = 1})
    transition.to(n1, {time = easeTime, alpha = 1})
    transition.to(n2, {time = easeTime, alpha = 1})
    transition.to(n3, {time = easeTime, alpha = 1})
    transition.to(y1, {time = easeTime, alpha = 1})
    transition.to(y2, {time = easeTime, alpha = 1})
    transition.to(y3, {time = easeTime, alpha = 1})
    timer.performWithDelay(easeTime, fadeIn)
end

timer.performWithDelay(2500, logoTrans)

local beginDelay = function()--
	--audio.play(mainSong1)
	--timer.performWithDelay(81790, playSong2)

  composer.gotoScene( "scripts.scene1", "crossFade", 100 )
  logoGroup:removeSelf()
  logoGroup = nil
end
timer.performWithDelay(5000, beginDelay)



--------		
--------------------memory monitor----------------------------------------

--[[ Uncomment to monitor app's lua memory/texture memory usage in terminal...

local function garbagePrinting()
	collectgarbage("collect")
    local memUsage_str = string.format( "memUsage = %.3f KB", collectgarbage( "count" ) )
    print( memUsage_str )
    local texMemUsage_str = system.getInfo( "textureMemoryUsed" )
    texMemUsage_str = texMemUsage_str/1000
    texMemUsage_str = string.format( "texMemUsage = %.3f MB", texMemUsage_str )
    print( texMemUsage_str )
end

Runtime:addEventListener( "enterFrame", garbagePrinting )
--]]
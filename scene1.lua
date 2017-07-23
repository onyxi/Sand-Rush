---------------------------------------------------------------------------------
--
-- scene1.lua
--
---------------------------------------------------------------------------------
--------require modules-----
local composer = require( "composer" )
local scene = composer.newScene()
local myData = require("scripts.myData")
local highScore = require("scripts.keepScore")
local ads = require( "ads" )

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

-------------load image sheets-------------------
----------------------------------------------------
local dungImages = require ("scripts.dungSheet")
local dungSheet = graphics.newImageSheet( "images/dungSheet.png", dungImages:getSheet() )
local timmyImages = require ("scripts.timmySheet")
local timmySheet = graphics.newImageSheet( "images/timmySheet.png", timmyImages:getSheet() )

----------------------------------------------------

-------display dimension shortcuts-
----------------------------------------------------
local cw = display.contentWidth
local ch = display.contentHeight
local cx = display.contentCenterX
local cy = display.contentCenterY

------------define collision filters--------------
----------------------------------------------------
local dCollisionFilter = {categoryBits = 1, maskBits = 130}
local dBaseCollisionFilter = {categoryBits = 2, maskBits = 1}
local sCollisionFilter = {categoryBits = 4, maskBits = 136}
local sBaseCollisionFilter = {categoryBits = 8, maskBits = 4}
local groundCollisionFilter = {categoryBits = 16, maskBits = 32}
local ballCollisionFilter = {categoryBits = 32, maskBits = 144}
local timmyCollisionFilter = {categoryBits = 64, maskBits = 128}
local gateCollisionFilter = {categoryBits = 128, maskBits = 101}
local backFilter = {categoryBits = 2, maskBits = 4}
----------------------------------------------------


-------initiate physics-----------------------------
----------------------------------------------------
--physics.setDrawMode( "hybrid" )
physics.start()

----------------------------------------------------


-- forward references: set variables ---------------
----------------------------------------------------
local canBegin = false
local canRoll = false
local gameActive = false
local timmyActive = false
local prompt = false
local gameSpeed = 80
local gateSpeed = 3000
local score = 0
local scoreText
local newHi
local gameFont = "numbersFont"
local scroll = true
local ballRotate = true
local gravityInstant = false
local xGravityInstant = 0
local yGravityInstant = 0

-----------------------------------------------------

-- forward references: functions --------------------
-----------------------------------------------------

--------enable game-start-----
local canBeginTrue = function()
	canBegin = true
end








---------------------------------------------------------------------------------
-- Create:
-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view

	local mainGroup = display.newGroup()
	sceneGroup:insert(mainGroup)
	local scoreGroup = display.newGroup()
	sceneGroup:insert(scoreGroup)

	-----add screen color corrector/filter
	local filterGroup = display.newGroup()
	sceneGroup:insert(filterGroup)
	local screenFilter = display.newRect(cx,cy, cw, ch)
		screenFilter:setFillColor(215/255, 175/255, 220 /255)
		screenFilter.alpha = 0.15
		filterGroup:insert(screenFilter)



	---------forward reference: variable/objects---
	-----------------------------------------------
	local tilt1
	local tilt2
	local startLoopTimer
	local loopTimer
	local timerSet
	local currentChannel = 2

	------------show banner ad--------
			myData.adType = "banner"
			ads:setCurrentProvider( "iads" )
			ads.show("banner", {x = 0, y = 100000})	
	---------------------------

	---------------------------
	---------------------------

	local playMainMusic = function()

	local mainSongOptions = {channel = currentChannel}

		audio.setVolume( 0.3 , {channel = 2} )
		audio.setVolume( 0.3 , {channel = 3} )
		local mainSong1 = mainSong1
		local mainSong2 = mainSong2

		local playSong2
		playSong2 = function()
			if currentChannel == 2 then
				currentChannel = 3
			else
				currentChannel = 2
			end
			local loopSongOptions = {channel = currentChannel}
			audio.play(mainSong2, loopSongOptions)
		loopTimer = timer.performWithDelay(79250, playSong2)
		timerSet = "loopMain"
		end

	audio.play(mainSong1, mainSongOptions)
	startLoopTimer = timer.performWithDelay(81790, playSong2)
	timerSet = "startMain"
	--audio.setVolume(0, 0)
	end
	local startMusicTimer = timer.performWithDelay(600, playMainMusic)
	--timer.cancel(startMusicTimer)
	------add scrolling backgrounds
	--local back = display.newRect(cx, -cy, cw, ch+10)
	local back = display.newImageRect("images/sand.png", 360, 580)
	back.x = cx
	back.y = -cy
	--back.alpha = 0
	--display.newImage("images/sand.png", cx, -cy)	
		--back:setFillColor(0.2, 0, 0)
		physics.addBody(back, "kinematic",{filter = backFilter})
		back:setLinearVelocity( 0, gameSpeed )
	mainGroup:insert(back)

	--local back2 = display.newRect(cx, cy, cw, ch+10)
	local back2 = display.newImageRect("images/sand.png", 360, 580)
	back2.x = cx
	back2.y = cy
	--display.newImage("images/sand.png", cx, cy)	
		--back2:setFillColor(0.1, 0.2, 0)
		physics.addBody(back2, "kinematic",{filter = backFilter})
		back2:setLinearVelocity( 0, gameSpeed )
	mainGroup:insert(back2)
	----------------


	---------HUD-------------------
	-----------------------------
	local bannerShadow = display.newRoundedRect( cx+2, -93, 290, 100, 10 )
		transition.to(bannerShadow, {time = 1100, y = cy-153, transition = easing.inOutElastic})
		bannerShadow:setFillColor(0,0,0)
		bannerShadow.alpha = 0.55
	mainGroup:insert(bannerShadow)

	local bannerBack = display.newImageRect("images/bannerBack.png", 290,100)
	bannerBack.x = cx
	bannerBack.y = -100
	--display.newImage("images/bannerBack.png", cx, -100)

	--display.newRoundedRect(cx, -100, 290, 100, 20)
	--bannerBack:setFillColor( gray )
	mainGroup:insert(bannerBack)
	transition.to(bannerBack, {time = 1100, y = cy-160, transition = easing.inOutElastic})


	local scoreShadow = display.newRoundedRect(cx+2, -95, 160, 46, 12)
		transition.to(scoreShadow, {time = 1300, y = cy-70, transition = easing.inOutElastic})
		scoreShadow:setFillColor(0,0,0)
		scoreShadow.alpha = 0.55
	mainGroup:insert(scoreShadow)

	local scoreBack = display.newImageRect("images/scoreBack.png", 160, 46)
	scoreBack.x = cx
	scoreBack.y = -100
	--display.newImage("images/scoreBack.png", cx, -100)
	--display.newRoundedRect(cx, -100, 120, 70, 15)
	--scoreBack:setFillColor( gray )
	mainGroup:insert(scoreBack)
	transition.to(scoreBack, {time = 1300, y = cy-75, transition = easing.inOutElastic})

	local sun = display.newImageRect("images/sun.png", 27, 27)
	sun.x = cx+45
	sun.y = cy-140
	--newImage("images/sun.png", cx+60, cy-140)
	sun.alpha = 0
	local showSun = function()
		sun.alpha = 1
		transition.to(sun, {time = 300, y = sun.y-40, transition = easing.outCubic , onComplete = canBeginTrue})
	end
	timer.performWithDelay(1100, showSun)
	mainGroup:insert(sun)

	---- add text to instruct start game
	local bannerText = display.newImageRect("images/SRText.png", 230, 42)
	--("images/bannerText.png", 224, 52)
	bannerText.x = cx-20
	bannerText.y =  -85
	--display.newImage("images/bannerText.png", cx-12, -85)
	--display.newText ("Sandy Rush", cx, -100, gameFont, 48)
	--	bannerText.rotation = -8
	mainGroup:insert(bannerText)
	transition.to(bannerText, {time = 1100, y = cy-145, transition = easing.inOutElastic})

	local timmyText = display.newText("Timmy's", cx-42,-120,"IndieFlower", 18)
	--display.newImageRect ("images/timmyText.png", 86, 34)
	--timmyText.x = cx-52
	--timmyText.y = -120
	--display.newImage ("images/timmyText.png", cx-52, -120)
	timmyText.rotation = -8
	timmyText:setFillColor(255/255, 246/255, 235/255)
	mainGroup:insert(timmyText)
	transition.to(timmyText, {time = 1100, y = cy-180, transition = easing.inOutElastic})
	
	local cactus = display.newImageRect("images/cactus.png", 44, 76)
	cactus.x = cx+113
	cactus.y = -98
	--display.newImage("images/cactus2.png", cx+113, -98)
	mainGroup:insert(cactus)
	transition.to(cactus, {time = 1100, y = cy-158, transition = easing.inOutElastic})

	

	---------retrieve & display high scores
	local highScore = highScore
	newHi = false

	----------retrieve current hi score
	local hi = highScore.load()
	if hi == nil then 
		hi = 0
	end

	----display hi score text
	local hiText = display.newImageRect("images/hiText.png", 130, 23)
	hiText.x = cx
	hiText.y = -100
	--display.newImage("images/hiText.png", cx, -100)
	--display.newText("Hi-Score",cx, -100, gameFont, 20)
	mainGroup:insert(hiText)
	transition.to(hiText, {time = 1300, y = cy-75, transition = easing.inOutElastic})
	-----display hi score value
	local hiValueShadow = TextCandy.CreateText({ fontName = "numbersFont", x = cx+2, y = -95, text = hi })
	hiValueShadow.yScale = 0.35
	hiValueShadow.xScale = 0.35
	hiValueShadow:setColor(0,0,0,0.5)
	mainGroup:insert(hiValueShadow)
	transition.to(hiValueShadow, {time = 1350, y = cy-15, transition = easing.inOutElastic})

	local hiValue = TextCandy.CreateText({ fontName = "numbersFont", x = cx, y = -100, text = hi })
	hiValue.yScale = 0.35
	hiValue.xScale = 0.35

	--display.newText(hi, cx, -100,gameFont, 70 )
	--hiValue:setFillColor( 255/255, 237/255, 195/255 )
	mainGroup:insert(hiValue)
	transition.to(hiValue, {time = 1350, y = cy-20, transition = easing.inOutElastic})

	---- 'tap to play' text---
	local tapShadow = display.newImageRect("images/tapText.png", 72, 28 )
	tapShadow.x = cx
	tapShadow.y = cy+115
	tapShadow:setFillColor(0,0,0)
	tapShadow.alpha = 0
	--tapShadow.xScale = 1.05
	--tapShadow.yScale = 1.05
	mainGroup:insert(tapShadow)
	transition.to(tapShadow, {time = 1000, alpha = 0.3, transition = easing.continuousLoop, iterations = 0})

	local tapText = display.newImageRect("images/tapText.png", 72, 28)
	tapText.x = cx
	tapText.y = cy+110
	--display.newImage("images/tapText.png", cx, cy+100)
	--display.newText("Tap to play", cx, cy+100, gameFont, 20)
	mainGroup:insert(tapText)
	tapText.alpha = 0
	transition.to(tapText, {time = 1000, alpha = 1, transition = easing.continuousLoop, iterations = 0})

-------create sprite----------
	local shadow = display.newCircle(cx, cy+47,26)
	shadow:setFillColor(0,0,0)
	shadow.alpha = 0.4
	physics.addBody(shadow, "dynamic",{filter = timmyCollisionFilter})
	shadow.gravityScale = 0
		mainGroup:insert(shadow)
	local dungSequenceData = {
	{name = "rolling", start = 1, count = 6, time = 600}
	}

	local ball = display.newSprite( dungSheet , dungSequenceData )
	ball:play()
	ball.x = cx
	ball.y = cy+45
	--display.newImage("images/dung.png", cx, cy+45)
	--display.newCircle(cx, cy+45, 26) radius = 26
		physics.addBody(ball,"dynamic",{density=0, friction=0, bounce=0, radius = 26,filter = ballCollisionFilter})
		ball.name = "ball"
		ball.isFixedRotation = true




	local timmySequenceData = {
			{name = "withBall", start = 1, count = 3, time = 200, loopDirection = "bounce"}
		}
	local timmy = display.newSprite(timmySheet, timmySequenceData)
	timmy:play()
--	timmy.anchorX = -80
	timmy.x = ball.x
	timmy.y = ball.y
	timmy.xScale = 1
	timmy.yScale = 1.1

	
	--[[local timmyShadow = display.newSprite(timmySheet, timmySequenceData)
	timmyShadow:setFillColor(0,0,0)
	timmyShadow.alpha = 0.3
	timmyShadow:play()
--	timmy.anchorX = -80
	timmyShadow.x = ball.x
	timmyShadow.y = ball.y+7
	timmyShadow.xScale = 1
	timmyShadow.yScale = 0.9
	sceneGroup:insert(timmyShadow)]]
	mainGroup:insert(ball)
	mainGroup:insert(timmy)
	mainGroup:insert(hiValue)


------- show banner Ad -------
------------------------------
--ads.show( "banner", { x=0, y=0 } )

--local bannerAd = ads.show( "banner", { x=0, y = ch-50, appId=bannerAppID } )
--[[local bannerAd = display.newRect(cx, ch+40, cw, 80)
	bannerAd:setFillColor(0.3,0.4,0.3)
	sceneGroup:insert(bannerAd)

local adText = display.newText("This is an Ad!", bannerAd.x, bannerAd.y, "IndieFlower", 20)
	sceneGroup:insert(adText)

transition.to(bannerAd, {time = 2000, y = ch-40, transition = easing.outCubic})
transition.to(adText, {time = 2000, y = ch-40, transition = easing.outCubic})
]]
------------------------------	

	-------movement
		local timmyVelX = 0
		local timmyVelY = 0
		local ballInstantX = 0
		local ballInstantY = 0
		local currentTiltX = 0
		local currentTiltY = 0
		function onTilt( event )
			currentTiltX = event.xGravity
			currentTiltY = event.yGravity
			VelX = (event.xGravity-ballInstantX)
			VelY = (event.yGravity-ballInstantY)

			--print (event.xGravity)


			if canRoll == true then
				if timmyActive == false then
			  		ball:applyForce(VelX)
			  			--event.xGravity*4)
			 -- print(event.xGravity)
			  --physics.setGravity( ( 9.8 * event.xGravity ), ( -9.8 * event.yGravity ) )
				  	if gravityInstant == true then
				  		xGravityInstant = event.xGravity
				  		yGravityInstant = event.yGravity
				  		gravityInstant = false
				  		--print (xGravityInstant)
				  		--print (yGravityInstant)
				  		timmyXInstant = timmy.x
				  		timmyYInstant = timmy.y
				  	end
				elseif timmyActive == true then
					timmy:applyForce(VelX/5,(-VelY/5))
				end
			end
		end
				
		
			Runtime:addEventListener( "accelerometer", onTilt )

------- constrain sprite movement
---detect x speed
local dungX = ball.x

local ballPos = function()
	if gameActive == true then
		if ball.x<-30 then
			ball.x = cw+30
		elseif ball.x>cw+30 then
			ball.x =-30
		end
	end
	if scroll == true then
		if back.y > ch+cy then 
			back.y = -cy
		end
		if back2.y > ch+cy then
			back2.y = -cy
		end
	end
	shadow.x = ball.x
	shadow.y = ball.y+5

	if timmyActive == false and ballRotate == true then
		----set dung rotation
		local oldDungX = dungX
		local newDungX = ball.x
		local dungSpeed = newDungX - oldDungX
		dungX = newDungX
		--print (dungSpeed)
		ball.rotation = dungSpeed*8
		if ball.rotation>50 then 
			ball.rotation = 50 
		elseif ball.rotation<-50 then
			ball.rotation = -50
		end

		------ adjust timmy position
			timmy.x = ball.x
		--timmy.y = ball.y
		timmy.rotation = dungSpeed*14
		--print (timmy.rotation)
		if timmy.rotation>50 then 
			timmy.rotation = 50 
		elseif timmy.rotation<-50 then
			timmy.rotation = -50
		end

	elseif timmyActive == true then
			vx, vy = timmy:getLinearVelocity()
			
			velocityAngle = math.atan2( vy, vx)
			
			velocityAngle = math.deg(velocityAngle)
			timmy.angle = velocityAngle
			--print (velocityAngle)
			--print (velocityAngle)
			local offset = 90
			timmy.rotation = velocityAngle+offset
			if velocityAngle == 0 then
				timmy.rotation = 0
			end

			if (vx == 0 and vy == 0) then timmy:pause()  end
			--if (vx > 0 and vx < 11) or (vx < 0 and vx > -11) or (vy > 0 and vy < 11) or (vy < 0 and vy > -11) then
			--	timmy.timeScale = 0.2
			--else
			if (vx > 0 and vx < 31) or (vx < 0 and vx > -31) or (vy > 0 and vy < 31) or (vy < 0 and vy > -31) then
				timmy:play()
				timmy.timeScale = 0.4
			elseif (vx > 30 and vx < 51) or (vx < 30 and vx > -51) or (vy > 30 and vy < 51) or (vy < 30 and vy > -51) then
				timmy.timeScale = 0.6
			elseif (vx > 50 and vx < 79) or (vx < 50 and vx > -79) or (vy > 50 and vy < 79) or (vy < 50 and vy > -79) then
				timmy.timeScale = 0.8
			elseif (vx > 80) or (vx < 80) or (vy > 80) or (vy < 80) then
				timmy.timeScale = 1
			end
			--print (vy)

	end

	--[[timmyShadow.x = timmy.x
	timmyShadow.y = timmy.y
	timmyShadow.rotation = timmy.rotation]]
end
Runtime:addEventListener("enterFrame", ballPos)

local jumpTimer
local ballJump
ballJump = function()
	local jumpForce = math.random (20,25)/1000
	local jumpTime = math.random (150,400)
	ball:applyLinearImpulse( 0, -jumpForce, 0, 0 )
	shadow:applyLinearImpulse(0,jumpForce+10,0,0)
	jumpTimer = timer.performWithDelay(jumpTime,ballJump)
	--print (jumpForce)
end
ballJump()

------display current game score
local scoreText = TextCandy.CreateText({ fontName = "numbersFont", x = cx, y = 100, text = score })
scoreText.xScale = 0.5
scoreText.yScale = 0.5
	scoreText.alpha = 0
mainGroup:insert(scoreText)
local createScore = function()	
	--scoreText.alpha = 1
	transition.to(scoreText, {time = 500, alpha = 1})
end

--------create gates to pass through
local gateTable= {} 	--to hold gates
local gateTimer			
local currentX = cx
local currentGate = "left"

local gateFunc
	gateFunc = function (event)

		--local gateX = math.random(60, cw-60)
		local currentGateX = currentX
		print (currentGateX)
		local gateX

		if score < 1 then
			if currentGate == "left" then
				gateX = math.random(cx-20, cx)
			else
				gateX = math.random(cx, cx+20)
			end
			currentX = gateX

		else 
			gateX = math.random(currentX-100, currentX + 100)
			local widthLeft = currentX - 100
				if gateX > (currentX-40) and gateX < (currentX+40) then 
					if gateX < currentX then 
						gateX = currentX - 40
					else 
						gateX = currentX +40
					end
				end
			if widthLeft < 60 then 
				widthLeft = 60
			end
			local widthRight = currentX + 100
				if gateX > currentX-40 and gateX < currentX+40 then 
					if gateX < currentX then gateX = currentX - 40
					else 
						gateX = currentX +40
					end
				end
			if widthRight >(cw-60) then
				widthRight = (cw-60)
			end
			--gateX = math.random(widthLeft, widthRight)
		

		if gateX<45 then
			gateX = 45
		elseif 
			gateX>cw-45 then
			gateX = cw-45
		end

		end

			--gateX = math.random(currentGateX, currentGateX+((cw/2) - 60))
	--	elseif score > 3 and score < 11 then
	--		gateX = math.random (60, cw-60)
			--gateX = math.random(currentGateX, currentGateX+((cw/2) - 60))
		
		--[[elseif score >= 1 and score < 10 then		
			--and score < 21 then

			--local widthLeft = currentX
			--local widthRight = currentX + (cx-60)
			
			local widthLeft = currentX - 100
			if widthLeft < 60 then 
				widthLeft = 60
			end
			local widthRight = currentX + 100
			if widthRight >(cw-60) then
				widthRight = (cw-60)
			end

			local diffSpace = 20
			gateX = math.random(widthLeft, widthRight)
			if gateX < (currentX+diffSpace) and gateX > (currentX-diffSpace) then
				if gateX < (currentX+diffSpace) then
					gateX = currentX+diffSpace
				elseif gateX > (currentX-diffSpace) then
					gateX = currentX-diffSpace
				end
			end

			if gateX < 60 then
				gateX = currentX + (currentX-gateX)
			elseif gateX > (cw-60) then
				gateX = currentX-(gateX-currentX)
			end
			currentX = gateX
			--gateX = math.random(currentGateX, currentGateX+((cw/2) - 60))
		elseif score >= 10 and score < 20 then 
			local widthLeft = currentX - 100
			if widthLeft < 60 then 
				widthLeft = 60
			end
			local widthRight = currentX + 100
			if widthRight >(cw-60) then
				widthRight = (cw-60)
			end

			local diffSpace = 30
			gateX = math.random(widthLeft, widthRight)
			if gateX < (currentX+diffSpace) and gateX > (currentX-diffSpace) then
				if gateX < (currentX+diffSpace) then
					gateX = currentX+diffSpace
				elseif gateX > (currentX-diffSpace) then
					gateX = currentX-diffSpace
				end
			end

			if gateX < 60 then
				gateX = currentX + (currentX-gateX)
			elseif gateX > (cw-60) then
				gateX = currentX-(gateX-currentX)
			end
			currentX = gateX
		elseif score >= 20 and score < 50 then 
			local widthLeft = currentX - 100
			if widthLeft < 60 then 
				widthLeft = 60
			end
			local widthRight = currentX + 100
			if widthRight >(cw-60) then
				widthRight = (cw-60)
			end

			local diffSpace = 40
			gateX = math.random(widthLeft, widthRight)
			if gateX < (currentX+diffSpace) and gateX > (currentX-diffSpace) then
				if gateX < (currentX+diffSpace) then
					gateX = currentX+diffSpace
				elseif gateX > (currentX-diffSpace) then
					gateX = currentX-diffSpace
				end
			end

			if gateX < 60 then
				gateX = currentX + (currentX-gateX)
			elseif gateX > (cw-60) then
				gateX = currentX-(gateX-currentX)
			end
			currentX = gateX
		elseif score >= 50 then 
			local widthLeft = currentX - 100
			if widthLeft < 60 then 
				widthLeft = 60
			end
			local widthRight = currentX + 100
			if widthRight >(cw-60) then
				widthRight = (cw-60)
			end

			local diffSpace = 60
			gateX = math.random(widthLeft, widthRight)
			if gateX < (currentX+diffSpace) and gateX > (currentX-diffSpace) then
				if gateX < (currentX+diffSpace) then
					gateX = currentX+diffSpace
				elseif gateX > (currentX-diffSpace) then
					gateX = currentX-diffSpace
				end
			end

			if gateX < 60 then
				gateX = currentX + (currentX-gateX)
			elseif gateX > (cw-60) then
				gateX = currentX-(gateX-currentX)
			end
			currentX = gateX
		end
		]]
		--[[elseif score > 20 and score < 31 then
			local widthLeft
			local widthRight
			if currentGate == "left" then
				widthLeft = currentX
				widthRight = 130
			else 
				widthLeft = cw-130
				widthRight = cw-60
			end
			 
			gateX = math.random(widthLeft, widthRight)
			--gateX = math.random(currentGateX, currentGateX+((cw/2) - 60))
		else 
			if currentGate == "left" then
				widthLeft = currentX
				widthRight = 100
			else 
				widthLeft = cw-100
				widthRight = cw-60
			end
			 
			gateX = math.random(widthLeft, widthRight)

		end

		if currentGate == "left" then
			currentGate = "right"
			currentX = cx
		else
			currentGate = "left"
			currentX = 60
		end
		]]

		gateTimer = timer.performWithDelay(gateSpeed,gateFunc)
		local bushShape = {-183, -34, -175, -39, 173, -39, 180, -33, 180, 33, 173, 39, -175, 39, -182, 33}

		local gate1 = display.newImageRect("images/cactusBush.png", 376, 90)
			gate1.x = gateX - 40
			gate1.y = -60
		--display.newImage("images/cactusBush.png", gateX - 40, -60)
		--display.newRect(0,0, gateX - 30, 80)
		gate1.anchorX = 1
		physics.addBody(gate1, "kinematic", {shape = bushShape, bounce = 0, filter = gateCollisionFilter})
		gate1:setLinearVelocity(0,gameSpeed)
		gate1.name = "gate1"
		gate1.isSensor = true
		gateTable[#gateTable+1] = gate1
		mainGroup:insert(gate1)
		mainGroup:insert(scoreText)
		--gate1.yScale = 0.8
	--	sceneGroup:insert(adSpace)

		local gate2 = display.newImageRect("images/cactusBush.png", 376, 90)
		gate2.x = gateX +40
		gate2.y = -60
		--display.newImage("images/cactusBush.png", gateX +40, -60)
		--display.newRect(gateX+50,0, cw-(gateX+30), 80)
		gate2.anchorX = 0
		physics.addBody(gate2, "kinematic",{shape = bushShape, bounce = 0, filter = gateCollisionFilter})
		gate2:setLinearVelocity(0,gameSpeed)
		gate2.name = "gate2"
		gate2.isSensor = true
		gateTable[#gateTable+1] = gate2
		mainGroup:insert(gate2)
		mainGroup:insert(scoreText)
		--gate2.yScale = 0.8
	--	sceneGroup:insert(adSpace)
	end

------- function to remove gates
------------------
	local collisionHandler = function()
		for i = #gateTable, 1, -1 do
			if gateTable[i].remove == true then
				local child = table.remove(gateTable, i)
					if child~= nil then
						child:removeSelf()
						child = nil									
					end	
				return 
			end
		end
	end
	Runtime:addEventListener("enterFrame", collisionHandler)

-------exit screen and move to end screen
local endScreen = function()
	local hi = hi
	local score = score
	local options = {
		effect = "flipFadeOutIn",
		time = 100,
		params = {
				hi = hi,
				score = score,
				newHi = newHi,
				--newHi = true
				}
		}
		Runtime:removeEventListener("enterFrame", ballPos)
		Runtime:removeEventListener( "accelerometer", onTilt )
		composer.gotoScene("scripts.scene2",options)
		local removeDelay = function()
			composer.removeScene("scripts.scene1")
		end
		timer.performWithDelay(200,removeDelay)
end



--------stop game  & prepare to exit screen
local endGame = function(event)
	if ((event.other.name == "gate2") or (event.other.name == "gate1")) and event.phase == "began" and gameActive == true and prompt == false then
		ball.isSensor = true
		audio.stop(currentChannel)
		audio.setVolume( 1 , {channel = 1} )

		if timerSet == "startMain" then
			timer.cancel(startLoopTimer)
			startLoopTimer = nil
		else
			timer.cancel(loopTimer)
			loopTimer = nil
		end

		local bushSound
		local bushSelector = math.random(1,3)
		if bushSelector == 1 then
			bushSound = bushSound1
		elseif bushSelector == 2 then
			bushSound = bushSound2
		else
			bushSound = bushSound3
		end

		local bushSoundOptions = {
			channel = 5
		}
		audio.play(bushSound, bushSoundOptions)
		--ball.isFixedRotation = true
		--ball.isSensor = true
		ballInstantY = currentTiltY
		gravityInstant = true

		local changeBallBody = function()
		ball:setLinearVelocity( 0,  0 )
			physics.removeBody( ball )
			--physics.addBody(ball,"static",{density=0, friction=0, bounce=0, radius = 26, filter = ballCollisionFilter})
		end
		timer.performWithDelay(5,changeBallBody)
		print (ball.bodyType)
		ballRotate = false
		timer.cancel(gateTimer)
		gateTimer = nil
		timer.cancel(jumpTimer)
		jumpTimer = nil
		prompt = true
		scroll = false



		---- pause scrolling background
		back:setLinearVelocity( 0, 0 )
		back2:setLinearVelocity( 0, 0 )

		-------pause gate movements
		local gateTable = gateTable
		for i = #gateTable, 1, -1 do
			gateTable[i]:setLinearVelocity( 0, 0 )
			gateTable[i].isSensor = false
			--physics.removeBody(gate1)
		end


		gameActive = false

		ball:setLinearVelocity(0,0)
		ball:pause()
		local timmyPhysics = function()
			local newTimmyY = timmy.rotation/6
			if newTimmyY<0 then newTimmyY = 0-newTimmyY end
			--print(newTimmyY)
			timmy.y=timmy.y+(25-newTimmyY)
			--print ((timmy.y+(22+newTimmyY)-timmy.y))
			local newTimmyX = (timmy.rotation/2.5)
			timmy.x = timmy.x-newTimmyX
			physics.addBody(timmy,"dynamic",{density=0, friction=0, bounce=0, filter = timmyCollisionFilter, radius = 10})
			timmy.gravityScale = 0
			timmy.anchorY = 0.85
			timmy.rotation = 90+ball.rotation
			timmyActive = true
		end
		timer.performWithDelay(10,timmyPhysics)
		-------determine hi score & save
		if score > hi then
			highScore.save(score)
			newHi = true
		end
		--Runtime:removeEventListener("enterFrame", ballPos)
		Runtime:removeEventListener("enterFrame", collisionHandler)
		Runtime:removeEventListener("touch", begin)
		gateTable = nil
		local function selectEnd()
			endScreen()
		end
		timer.performWithDelay(2000, selectEnd)
	end
end
ball:addEventListener("collision", endGame)


local onTilt

---------begin game function
local begin = function(event)
	if event.phase == "began" and canBegin == true and gameActive == false and prompt == false then
		audio.setVolume( 0.4 , {channel = 1} )
	
		ballInstantX = currentTiltX
		
		myData.tryCount = myData.tryCount+1
--[[		
		if myData.tryCount == 2 then
			ads:setCurrentProvider( "admob" )
			myData.adType = "interstitial"
			ads.load( "interstitial", { appId="ca-app-pub-9588489135351549/7033011917", testMode=false } )
		end
]]
		gameActive = true
		canRoll = true
		tapText:removeSelf()
		tapText = nil
		tapShadow:removeSelf()
		tapShadow = nil
			------add instruction signals to tilt left and right
			tilt1Shadow = display.newImage("images/tilt.png", cx - 77, cy+48)
			tilt1Shadow:setFillColor(0,0,0)
			tilt1Shadow.alpha = 0
			transition.to(tilt1Shadow, {time = 1500, alpha = 0.3, transition = easing.continuousLoop, iterations = 2})
			mainGroup:insert(tilt1Shadow)
		tilt1 = display.newImageRect("images/tilt.png", 44, 34)
		tilt1.x = cx - 80
		tilt1.y = cy+45
		--display.newRect(cx-80, cy+45, 40, 5)
			tilt1.alpha = 0
			transition.to(tilt1, {time = 1500, alpha = 1, transition = easing.continuousLoop, iterations = 2})
			mainGroup:insert(tilt1)

			tilt2Shadow = display.newImage("images/tilt.png", cx+83, cy+48)
			tilt2Shadow:setFillColor(0,0,0)
			tilt2Shadow.xScale = -1
			tilt2Shadow.yScale = -1
			tilt2Shadow.alpha = 0
			transition.to(tilt2Shadow, {time = 1500, alpha = 0.3, transition = easing.continuousLoop, iterations = 2})
			mainGroup:insert(tilt2Shadow)

		tilt2 = display.newImage("images/tilt.png", 44, 34)
		tilt2.x = cx+80
		tilt2.y = cy+45
		--display.newImage("images/tilt.png", cx+80, cy+45)
		--display.newRect(cx+80, cy+45, 40, 5)
			tilt2.xScale = -1
			tilt2.yScale = -1
			tilt2.alpha = 0
			transition.to(tilt2, {time = 1500, alpha = 1, transition = easing.continuousLoop, iterations = 2})
			mainGroup:insert(tilt2)

		-----------------------------------
		------------goTimmy Text-----------


		local removeTilts = function()
			tilt1Shadow:removeSelf()
			tilt1Shadow = nil
			tilt2Shadow:removeSelf()
			tilt2Shadow = nil
			tilt1:removeSelf()
			tilt1 = nil
			tilt2:removeSelf()
			tilt2 = nil
		end
		timer.performWithDelay(3500, removeTilts)

		local start = function()
				local removeText = function()
					bannerText:removeSelf()
					bannerText = nil
					hiText:removeSelf()
					hiText = nil
					hiValue:removeSelf()
					hiValue = nil
					createScore()
				end
				timer.performWithDelay(1000, removeText)
			gateFunc() 
			
		end
		transition.to(bannerText, {time = 1300, y = -100, transition = easing.inOutElastic})
		transition.to(timmyText, {time = 1300, y = -120, transition = easing.inOutElastic})
		transition.to(sun, {time = 1300, y = -120, transition = easing.inOutElastic})
		transition.to(cactus, {time = 1300, y = -98, transition = easing.inOutElastic})
		transition.to(hiText, {time = 1300, y = -100, transition = easing.inOutElastic})
		transition.to(hiValue, {time = 1300, y = -100, transition = easing.inOutElastic})
		transition.to(hiValueShadow, {time = 1300, y = -95, transition = easing.inOutElastic})
		transition.to(bannerBack, {time = 1300, y = -100, transition = easing.inOutElastic})
		transition.to(bannerShadow, {time = 1300, y = -93, transition = easing.inOutElastic})
		transition.to(scoreBack, {time = 1300, y = -100, transition = easing.inOutElastic})
		transition.to(scoreShadow, {time = 1300, y = -95, transition = easing.inOutElastic})
		timer.performWithDelay(500, start)

		transition.to(bannerAd, {time = 1300, y = ch+40, transition = easing.outSine})
		transition.to(adText, {time = 1300, y = ch+40, transition = easing.outSine})
	end
end

local function tiltMove()
	if gameActive == true then
		tilt1.x = ball.x-80
		tilt2.x = ball.x+80
	end
end
--Runtime:addEventListener("enterFrame", tiltMove)

--Runtime:addEventListener("touch", begin)
screenFilter:addEventListener("touch", begin)
-------- set physics bodies to restrict movement & update score
-----scoring sensors-----
local scoreBase = display.newRect(-30, cy+110, cw+60, 5)
scoreBase.anchorX = 0
scoreBase.alpha = 0
physics.addBody(scoreBase, "static",{bounce = 0, filter = sBaseCollisionFilter})
scoreBase.name = "scoreBase"
mainGroup:insert(scoreBase)

local scoreSensor = display.newRect(-30, cy+105, cw+60, 5)
scoreSensor.anchorX = 0
scoreSensor.alpha = 0
physics.addBody(scoreSensor, "dynamic",{bounce = 0, filter = sCollisionFilter})
scoreSensor.name = "scoreSensor"
mainGroup:insert(scoreSensor)

------gate destroying sensors-----
local destroyerBase = display.newRect(0, ch+100, cw+cw+cw,20)
destroyerBase.anchorX = 0; destroyerBase.anchorY = 0
destroyerBase.alpha = 0
physics.addBody (destroyerBase, "static", {bounce = 0, filter = dBaseCollisionFilter})
destroyerBase.name = "base"
mainGroup:insert(destroyerBase)

local destroyer = display.newRect(0, ch+105, cw+cw+cw, 5)
destroyer.anchorX = 0
destroyer.alpha = 0
physics.addBody(destroyer, "dynamic",{bounce = 0, filter = dCollisionFilter})
destroyer.name = "destroyer"
mainGroup:insert(destroyer)



	------------collision events
	--------set flags to gates for removal
	local remove = function(event)
		if event.phase == "began" and event.other.name ~= "base" and event.other.name ~= "ball" then
			if event.target.name == "destroyer" then
				event.other.remove = true
		
			elseif event.target.name == "scoreSensor" and event.other.name~= "scoreBase" and event.other.name == "gate1" then
				if gameActive == true then
					score = score+1
				end

				scoreText:updateChars (score)

				local gateSoundOptions = {channel = 5}
				audio.play(gateSound, gateSoundOptions)	
			end
			
		end
		------------destroy ball after game over
		if event.target.name == "destroyer" and event.other.name == "ball" then
			gameActive = false
			event.other:removeSelf()
			event.other = nil
			endScreen()
			Runtime:removeEventListener("enterFrame", ballPos)
		end
	end
	destroyer:addEventListener("collision", remove)
	scoreSensor:addEventListener("collision", remove)



------ads----------

--


--

local ground = display.newRect(-30, cy+80, cw+60, 20)
ground.anchorX = 0
physics.addBody(ground, "static", {bounce = 0, filter = groundCollisionFilter})
ground.name = "ground"
ground.alpha = 0
mainGroup:insert(ground)

--
------temp controls-----
--[[
local left =  display.newRect(0, ch-40, cx, 80)
left.anchorX = 0
left.alpha = 0.01
mainGroup:insert(left)

local right = display.newRect(cx, ch-40, cx, 80)
right.anchorX = 0
right.alpha = 0.01
mainGroup:insert(right)

local up = display.newRect(0, ch-200, cx, 80)
up.anchorX = 0
up.alpha = 0
mainGroup:insert(up)

local down = display.newRect(0, ch-120, cx, 80)
down.anchorX = 0
down.alpha = 0
mainGroup:insert(down)

local moveLeft = function(event)
	if event.phase == "began" and gameActive == true then
		ball:applyForce( -0.3, 0, 0, 0 )
	end
	if timmyActive == true then
		timmy:applyForce( -0.05, 0, 0, 0 )
	end
	
end
left:addEventListener("touch", moveLeft)


local moveRight = function(event)
	if event.phase == "began" and gameActive == true then
		ball:applyForce( 0.3, 0, 0, 0 )
	end
	if timmyActive == true then
		timmy:applyForce( 0.05, 0, 0, 0 )
	end
end
right:addEventListener("touch", moveRight)

local moveUp = function(event)
	if event.phase == "began" and timmyActive == true then
		timmy:applyForce( 0, -0.05, 0, 0 )
	end
end
up:addEventListener("touch", moveUp)

local moveDown = function(event)
	if event.phase == "began" and timmyActive == true then
		timmy:applyForce( 0, 0.05, 0, 0 )
	end
end
down:addEventListener("touch", moveDown)
]]

	print( "\n1: create event")
end
--------------------------------------------------
-- Show:
function scene:show( event )

	local phase = event.phase
	
	
end
--------------------------------------------------
-- Hide:
function scene:hide( event )
	
	local phase = event.phase
	
	
end
--------------------------------------------------
-- Destroy:
function scene:destroy( event )
-- Destroys scene
	
	print( "((destroying scene 1's view))" )
	--sceneGroup:removeSelf()
	--sceneGroup = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
---------------------------------------------------------------------------------

return scene
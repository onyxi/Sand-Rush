---------------------------------------------------------------------------------
--
-- scene1.lua
--
---------------------------------------------------------------------------------


--------require modules-----
local composer = require( "composer" )
local scene = composer.newScene()
local myData = require ("scripts.myData")
	    myData.overlayActive = false
local ads = require( "ads" )
local facebook = require( "facebook" )
local TwitterManager = require( "scripts.Twitter" )
local keepMessageInfo = require("scripts.keepMessage")



-------------load image sheets-------------------
----------------------------------------------------
local dungImages = require ("scripts.dungSheet")
local dungSheet = graphics.newImageSheet( "images/dungSheet.png", dungImages:getSheet() )



---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION

-------display dimension shortcuts-
----------------------------------------------------
local cw = display.contentWidth
local ch = display.contentHeight
local cx = display.contentCenterX
local cy = display.contentCenterY

---------------------------------------------------------------------------------
-- forward references / functions:
local canRetry = false
local canCancelPost = false

---------------------------------------------------------------------------------
-- Create:
-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view

local postOverlayGroup

local messageBack
local messagePostText
local message2Text
local postText
local postBack
local rateBack
local postBackShadow
local facebookBtn
local facebookBtnOverlay
local twitterBtn

local posted = false
local hasClickedYes = false

------------------------------------
------------------------------------
-------------- facebook & twitter - listeners and functions-------------------------
local json = require( "json" )

local okBtn
--local postText
--local overlayScreen


local postOverlayBg
local postOverlayNo
local postOverlayNoOverlay
local postOverlayNoText
local postOverlayOk
local postOverlayOkOverlay
local postOverlayText
local postOverlayOkText
local postCancel
local postDone
local postDoneOverlay
local postDoneText



local postNo = 0
local fbPostText
local canOk = false
local okCancels = false

    	local closeFunction = function(event)
	      if event.phase == "ended" and canCancelPost == true then
	      	if event.target.id == "noBtn" then
		      	postOverlayNoOverlay.alpha = 0.8
	    		transition.to(postOverlayNoOverlay, {time = 1000, alpha = 0})
	    	elseif event.target.id == "doneBtn" then
	    		postDoneOverlay.alpha = 0.8
	    		transition.to(postDoneOverlay, {time = 1000, alpha = 0})
	      	end
	      	canCancelPost = false
	      	local removeGroup = function()
		        postOverlayGroup:removeSelf()
		       -- postOverlayGroup = nil
		       -- facebook.logout( )
		       	myData.overlayActive = false 
	  		end
	        transition.to(postOverlayBg, {time = 1100, y = ch+100, transition = easing.inOutElastic})
	        transition.to(postOverlayText, {time = 1100, y = ch+100, transition = easing.inOutElastic})
	        if posted == false then
		        transition.to(postOverlayOk, {time = 1100, y = ch+160, transition = easing.inOutElastic})
		        transition.to(postOverlayOkOverlay, {time = 1100, y = ch+160, transition = easing.inOutElastic})
		        transition.to(postOverlayOkText, {time = 1100, y = ch+160, transition = easing.inOutElastic, onComplete = removeGroup})
		        transition.to(postOverlayNo, {time = 1100, y = ch+160, transition = easing.inOutElastic})
		        transition.to(postOverlayNoOverlay, {time = 1100, y = ch+160, transition = easing.inOutElastic})
		        transition.to(postOverlayNoText, {time = 1100, y = ch+160, transition = easing.inOutElastic})
	      	else 
	      		transition.to(postDone, {time = 1100, y = ch+160, transition = easing.inOutElastic})
		        transition.to(postDoneOverlay, {time = 1100, y = ch+160, transition = easing.inOutElastic})
		        transition.to(postDoneText, {time = 1100, y = ch+160, transition = easing.inOutElastic, onComplete = removeGroup})
	      	end
	      end
	    end


local function facebookListener( event )

    print( "event.name", event.name )  --"fbconnect"
    print( "event.type:", event.type ) --type is either "session", "request", or "dialog"
    print( "isError: " .. tostring( event.isError ) )
    print( "didComplete: " .. tostring( event.didComplete ) )

    --"session" events cover various login/logout events
    --"request" events handle calls to various Graph API calls
    --"dialog" events are standard popup boxes that can be displayed

    if ( "session" == event.type ) then

        --options are: "login", "loginFailed", "loginCancelled", or "logout"
        if ( "login" == event.phase ) then
            local access_token = event.token
            --code for tasks following a successful login
            if myData.fbCanPublish == false then
                myData.fbCanPublish = true
                local fbAppID = "289342331274712"
                facebook.login( fbAppID, facebookListener, {"publish_actions"})
            end
        end
--------------------

    elseif ( "request" == event.type ) then
        print("facebook request")
        if ( not event.isError ) then
            response = json.decode( event.response )
            --print(response)
            --process response data here
           -- printTable( response, "message", 3 )
            postOverlayText.text = "Hi-Score Posted!"
            canCancelPost = true
            canOk = true
            okCancels = true
            --fbPostLog = fbPostLog+1
            --fbPostText.text = fbPostLog
          --  facebook.logout( )
        else
        	postText.text = "Post failed"
        	canCancelPost = true
        	canOk = true
        end


    elseif ( "dialog" == event.type ) then
        print( "dialog", event.response )
        --handle dialog results here
    end
end

--------------------
--twitter
--------------------
----------------twitter-------------
----------------------------------
local callback = {}

-- Callbacks
function callback.twitterCancel()
	print( "Twitter Cancel" )
	--statusMessage.textObject.text = "Twitter Cancel"
	postOverlayText.text = "Twitter Cancel"
end

-----------------------------------------------------------------
-- Successful Twitter Callback
--
-- Determine the request type and update the display
-----------------------------------------------------------------
--
function callback.twitterSuccess( requestType, name, response )
	local results = ""
	
	print( "Twitter Success" )
	--statusMessage.textObject.text = "Twitter Success"
	postOverlayText.text = "Twitter Success"
	if "friends" == requestType then
		results = response.users[1].name .. ", count: " ..
			response.users[1].statuses_count
	end
	
	if "users" == requestType then
		results = response.name .. ", count: " ..
			response.statuses_count
	end

	if "tweet" == requestType then
		results = "Tweet Posted!"
	end

	print( results )
	postOverlayText.text = results	
	posted = true
	--getInfoMessage.text = results	
	--userNameMessage.text = name
	if hasClickedYes == false then
		postOverlayNo:removeSelf()
		postOverlayNo = nil
		postOverlayNoOverlay:removeSelf()
		postOverlayNoOverlay = nil
		postOverlayNoText:removeSelf()
		postOverlayNoText = nil
		postOverlayOk:removeSelf()
		postOverlayOk = nil
		postOverlayOkOverlay:removeSelf()
		postOverlayOkOverlay = nil
		postOverlayOkText:removeSelf()
		postOverlayOkText = nil
	end

	postDone = display.newRoundedRect(cx, cy+180, 60, 40, 7)
	if postType == "facebook" then
    	postDone:setFillColor(75/255,87/255, 132/255)
    else
    	postDone:setFillColor(116/255,178/255, 225/255)
    end
    postDone:setStrokeColor(1,1,1)
    postDone.strokeWidth = 3
    postDone.id = "doneBtn"
    postDone:addEventListener("touch", closeFunction)
	postOverlayGroup:insert(postDone)
	postDoneOverlay = display.newRoundedRect(cx, cy+180, 60, 40, 7)
	postDoneOverlay.alpha = 0
	postOverlayGroup:insert(postDoneOverlay)
	postDoneText = display.newText("OK", cx, cy+180, "LucidaGrande-Bold", 15)
	postOverlayGroup:insert(postDoneText)

	


end

function callback.twitterFailed()
	print( "Failed: Invalid Token" )
	postOverlayText.text = "Failed: Invalid Token"
end

--------------------------------
-- Tweet the message
--------------------------------
--
local function tweetit( event )
	local time = os.date( "*t" )		-- Get time to append to our tweet
	local hiScore = myData.hiPublish
	local value = "Got a Hi Score of "..hiScore.." on Timmy's Sand Rush at www.onyx-interactive.co.uk at " ..time.hour..":"
			.. time.min
			
	local params = {"tweet", "statuses/update.json", "POST",
		{"status", value} }
	TwitterManager.tweet(callback, params)
end
---------

----------post display pop-up----------
---------------------------------------
local postStart = function(event)
	local hiScore = myData.currentHiScore
	local postType = event.target.id
	if event.phase == "ended" and myData.overlayActive == false then
		myData.overlayActive = true 
		okCancels = false
		posted = false

		postOverlayGroup = display.newGroup()
		hasClickedYes = false

		if postType == "facebook" then
			facebookBtnOverlay.alpha = 0.8
			transition.to(facebookBtnOverlay, {time = 1000, alpha = 0})
		else
			twitterBtnOverlay.alpha = 0.8
			transition.to(twitterBtnOverlay, {time = 1000, alpha = 0})			
		end


		if postType == "facebook" then
			local fbAppID = "289342331274712"
	   		facebook.login( fbAppID, facebookListener )
   		else
   			------------twitter login details here?
   		end

	    local okFunction = function(event)
	      if event.phase == "ended" and canOk == true then
	      	if okCancels ~= true then
	      		canOk = false
	      		--local toggleCanPostOn = function()
	      		--	canOk = true
	      		--end
	      		local removeYesNo = function()
			        postOverlayNo:removeSelf()
					postOverlayNo = nil
					postOverlayNoOverlay:removeSelf()
					postOverlayNoOverlay = nil
					postOverlayNoText:removeSelf()
					postOverlayNoText = nil
					postOverlayOk:removeSelf()
					postOverlayOk = nil
					postOverlayOkOverlay:removeSelf()
					postOverlayOkOverlay = nil
					postOverlayOkText:removeSelf()
					postOverlayOkText = nil
					hasClickedYes = true
	      		end

	      		postOverlayOkOverlay.alpha = 0.8
	      		transition.to(postOverlayOkOverlay, {time = 1000, alpha = 0, onComplete = removeYesNo})
		      	postNo = postNo+1

		      	if postType == "facebook" then

		      		local messageNo = keepMessageInfo.load()
					if messageNo == nil then
						messageNo = 0
					end
		      		messageNo = messageNo+1
		      		hiScore = myData.currentHiScore

		      		if messageNo == 1 then 
		      			messagePostText = "I got a Hi-Score of "..hiScore.."!"
		      		elseif messageNo == 2 then 
		      			messagePostText = "I scored "..hiScore.."!"
		      		elseif messageNo == 3 then
		      			messagePostText = "I got "..hiScore.."!"
		      			messageNo = 0
		      		end
		      		keepMessageInfo.save(messageNo)

	
			    local attachment = {
				name = "Timmy's Sand Rush!",
				link = "http://www.onyx-interactive.co.uk",
				caption = messagePostText,
				description = "A game about rolling dung.",
				picture = "http://image.basekit.com/bkpam2113063_tsrappicon.png",
				actions = json.encode( { { name = "Learn More", link = "http://www.onyx-interactive.co.uk" } } )
				}
		
				facebook.request( "me/feed", "POST", attachment )		-- posting the photo
		      		
		      	--[[	
			        local postMsg = {
			                message = messagePostText
			                --"Test Facebook Post! "..postNo
			                }
		        facebook.request( "me/feed", "POST", postMsg )    -- posting the message  
			        
		        ]]


			        postOverlayText.text = "Please wait..."
		        	canCancelPost = false 
		        else
		        	
		        	tweetit()
		        	----------------twitter post command here?
		        end


		        	
		    else
	      		--canCancelPost = false
	      		postOverlayOkOverlay.alpha = 0.8
	      		transition.to(postOverlayOkOverlay, {time = 1000, alpha = 0})
		      	local removeGroup = function()
			        postOverlayGroup:removeSelf()
			        --postOverlayGroup = nil
			       -- facebook.logout( )
			       	myData.overlayActive = false 
		  		end
		        transition.to(postOverlayBg, {time = 1100, y = ch+100, transition = easing.inOutElastic})
		        transition.to(postOverlayText, {time = 1100, y = ch+100, transition = easing.inOutElastic})
		        transition.to(postOverlayOk, {time = 1100, y = ch+160, transition = easing.inOutElastic})
		        transition.to(postOverlayOkOverlay, {time = 1100, y = ch+160, transition = easing.inOutElastic})
		        transition.to(postOverlayOkText, {time = 1100, y = ch+160, transition = easing.inOutElastic, onComplete = removeGroup})

	        	--[[
		        	local grad1 = display.newRect(cx-110, cy+120, 32, 40)
					local gradient1 = {
					    type="gradient",
					    color1={ 75/255,87/255, 132/255, 0}, color2={ 75/255,87/255, 132/255 }, direction="right"
					}
					grad1:setFillColor( gradient1 )
					postGroup:insert(grad1)
					transition.to(grad1, {time = 2000, x = cx+80})

					local grad2 = display.newRect(cx-80, cy+120, 32, 40)
					local gradient2 = {
					    type="gradient",
					    color1={ 75/255,87/255, 132/255, 0 }, color2={75/255,87/255, 132/255 }, direction="left"
					}
					grad2:setFillColor( gradient2 )
					postGroup:insert(grad2)
					local resPositionGrads = function()
						grad1.x = cx-110
						grad2.x = cx-80
					end
					transition.to(grad2, {time = 2000, x = cx+110, onComplete = resPositionGrads})
					]]
	        end
	      end
	    end



	--local postBgHeight = ch
    postOverlayBg = display.newRect(cx, ch+100, cw, ch)
    postOverlayBg.anchorY = 0
    if postType == "facebook" then
    	postOverlayBg:setFillColor(75/255,87/255, 132/255)
    else
    	postOverlayBg:setFillColor(116/255,178/255, 225/255)
    end
    postOverlayGroup:insert(postOverlayBg)
    transition.to(postOverlayBg, {time = 1100, y = cy+80, transition = easing.inOutElastic})

    if postType == "facebook" then
		postOverlayText = display.newText("Post Hi-Score to Facebook?", cx, ch+100, "LucidaGrande-Bold", 20)
	else
		postOverlayText = display.newText("Tweet Hi-Score on Twitter?", cx, ch+100, "HelveticaNeue-Bold", 20)
	end
	transition.to(postOverlayText, {time = 1100, y = cy+120, transition = easing.inOutElastic})
	postOverlayGroup:insert(postOverlayText)

    postOverlayOk = display.newRoundedRect(cx+50, ch+160, 60, 40, 7)
    postOverlayOk:addEventListener("touch", okFunction)
    if postType == "facebook" then
    	postOverlayOk:setFillColor(75/255,87/255, 132/255)
    else
    	postOverlayOk:setFillColor(116/255,178/255, 225/255)
    end
    postOverlayOk:setStrokeColor(1,1,1)
    postOverlayOk.strokeWidth = 3
    local toggleCanPostOn = function()
	    canOk = true
	    canCancelPost = true
	end
    transition.to(postOverlayOk, {time = 1100, y = cy+180, transition = easing.inOutElastic, onComplete = toggleCanPostOn})
    postOverlayGroup:insert(postOverlayOk)

    postOverlayOkOverlay = display.newRoundedRect(cx+50, ch+160, 60, 40, 7)
    --postOk.strokeWidth = 3
    postOverlayOkOverlay.alpha = 0
    transition.to(postOverlayOkOverlay, {time = 1100, y = cy+180, transition = easing.inOutElastic})
    postOverlayGroup:insert(postOverlayOkOverlay)

    postOverlayOkText = display.newText("Yes", cx+50, ch+160, "LucidaGrande-Bold", 15)
    transition.to(postOverlayOkText, {time = 1100, y = cy+180, transition = easing.inOutElastic})
    postOverlayGroup:insert(postOverlayOkText)

    postCancel = display.newRect(cx, 0, cw, ch - (cy-80))
    postCancel.anchorY = 0
    postCancel.alpha = 0
    postCancel.isHitTestable = true
    postOverlayGroup:insert(postCancel)

    postCancel:addEventListener( "touch", closeFunction )


   --[[ local noFunction = function(event)
    	if event.phase == "ended" then
    		postOverlayNoOverlay.alpha = 0.8
    		transition.to(postOverlayNoOverlay, {time = 1000, alpha = 0})
    		--closeFunction()
    	end
	end]]

  	postOverlayNo = display.newRoundedRect(cx-50, ch+160, 60, 40, 7)
  	postOverlayNo.id = "noBtn"
    postOverlayNo:addEventListener("touch", closeFunction)
    if postType == "facebook" then
    	postOverlayNo:setFillColor(75/255,87/255, 132/255)
    else
    	postOverlayNo:setFillColor(116/255,178/255, 225/255)
    end
    postOverlayNo:setStrokeColor(1,1,1)
    postOverlayNo.strokeWidth = 3
	postOverlayGroup:insert(postOverlayNo)
	transition.to(postOverlayNo, {time = 1100, y = cy+180, transition = easing.inOutElastic})

    postOverlayNoOverlay = display.newRoundedRect(cx-50, ch+160, 60, 40, 7)
    --postOk.strokeWidth = 3
    postOverlayNoOverlay.alpha = 0
    transition.to(postOverlayNoOverlay, {time = 1100, y = cy+180, transition = easing.inOutElastic})
    postOverlayGroup:insert(postOverlayNoOverlay)


    postOverlayNoText = display.newText("No", cx-50, ch+160, "LucidaGrande-Bold", 15)
    transition.to(postOverlayNoText, {time = 1100, y = cy+180, transition = easing.inOutElastic})
    postOverlayGroup:insert(postOverlayNoText)

	end
end



-------------------------------------------------------
------------------draw scene---------------------------
-------------------------------------------------------

------activate retry button
local retryBtnActivate = function()
	canRetry = true
end


	local cloudGroup = display.newGroup()
	sceneGroup:insert(cloudGroup)
	local cactusGroup = display.newGroup()
	sceneGroup:insert(cactusGroup)
	local hudGroup = display.newGroup()
	sceneGroup:insert(hudGroup)

		-----add screen color corrector/filter
	local filterGroup = display.newGroup()
	sceneGroup:insert(filterGroup)
	local screenFilter = display.newRect(cx,cy, cw, ch)
		screenFilter:setFillColor(215/255, 175/255, 220 /255)
		screenFilter.alpha = 0.15
		filterGroup:insert(screenFilter)

	audio.setVolume( 0.7 ,{channel = 6} )
	local endSongOptions = {
			channel = 6, 
		}
	local endTune = audio.play(endSong, endSongOptions)

	local params = event.params
		
	---------forward reference: variable/objects---
	-----------------------------------------------

	local hi = params.hi
	local score = params.score
	local newHi = params.newHi

	local currentHiScoreCheck = hi 
	if score > currentHiScoreCheck then
		currentHiScoreCheck = score
	end
	myData.currentHiScore = currentHiScoreCheck

	local sky = display.newImageRect("images/sky.png", 360, 300)
	sky.x = cx
	sky.y = 0
	--display.newImage("images/sky.png",cx, 0)
	sky.anchorY = 0
	--Rect(cx, cy, cw,ch)
		--sky:setFillColor(2/255, 170/255, 229/255)
	cloudGroup:insert(sky)

	

	local createCloud1 = function(event)
		local cloudX
		local speed
		local params = event.source.params
		if params.newCloud == true then
			cloudX = -50	
			speed = math.random(50000, 80000)
		else
			cloudX = math.random(0, cw)
			speed = math.random(100000, 160000)
		end
		print(params.newCloud)
		local cloudY = math.random(50, cy-180)
		local cloud1 = display.newImageRect("images/cloud.png", 87, 23)
			cloud1.x = cloudX
			cloud1.y = cloudY
		--display.newImage("images/cloud.png", cloudX, cloudY)
		--display.newRect(cloudX, cloudY, 90, 45)
		local scale  = math.random(700, 1200)/1000
		cloud1.xScale = scale
		cloud1.yScale = scale
	--	cloud1:setFillColor(0,0,0.1)
		transition.to(cloud1, {time = speed, x = cw+50})
		cloudGroup:insert(cloud1)
	return cloud1
	end

	local createCloud2 = function(event)
		local cloudX
		local speed 
		local params = event.source.params
		if params.newCloud == true then
			cloudX = -20	
			speed = math.random(60000, 100000)
		else
			cloudX = math.random(0, cw)
			speed = math.random(120000, 200000)
		end
		print(params.newCloud)
		local cloudY = math.random(cy-180, cy-80)
		local cloud2 = display.newImageRect("images/cloud.png", 87, 23)
			cloud2.x = cloudX
			cloud2.y = cloudY
		--display.newImage("images/cloud.png", cloudX, cloudY)
		--display.newRect(cloudX, cloudY, 90, 45)
		local scale = math.random(400, 600)/1000
		cloud2.xScale = scale
		cloud2.yScale = scale
		--cloud2:setFillColor(0,0.2,0)
		transition.to(cloud2, {time = speed, x = cw+50})
		cloudGroup:insert(cloud2)
	return cloud2
	end

	local createCloud3 = function(event)
		local cloudX
		local speed
		local params = event.source.params
		if params.newCloud == true then
			cloudX = -20	
			speed = math.random(70000, 120000)
		else
			cloudX = math.random(0, cw)
			speed = math.random(140000, 240000)
		end
		print(params.newCloud)
		local cloudY = math.random(cy-80, cy-50)
		local cloud3 = display.newImage("images/cloud.png", cloudX, cloudY)
		--display.newRect(cloudX, cloudY, 90, 45)
		local scale = math.random(100, 300)/1000
		cloud3.xScale = scale
		cloud3.yScale = scale
		--cloud3:setFillColor(0.2,0,0)
		transition.to(cloud2, {time = speed , x = cw+50})
		cloudGroup:insert(cloud3)
	return cloud3
	end

local firstClouds3 = timer.performWithDelay(1, createCloud3, 10)
firstClouds3.params = {newCloud = false}
local firstClouds2 = timer.performWithDelay(1, createCloud2, 5)
firstClouds2.params = {newCloud = false}
local firstClouds1 = timer.performWithDelay(1, createCloud1, 3)
firstClouds1.params = {newCloud = false}

local newClouds3 = timer.performWithDelay(100000, createCloud3, 0)
newClouds3.params = {newCloud = true}

local newClouds2 = timer.performWithDelay(30000, createCloud2, 0)
newClouds2.params = {newCloud = true}

local newClouds1 = timer.performWithDelay(15000, createCloud1, 0)
newClouds1.params = {newCloud = true}

	local createCloud = function()
		local cloudX = math.random(50, cw - 50)
		local cloudY = math.random(30, cy - 70)
		local cloud = display.newRect(cloudX, cloudY, 90, 45)
		cloudGroup:insert(cloud)
		if cloudY > 50 and cloudY <cw-100 then 
			cloud.xScale = 0.6
			cloud.yScale = 0.6
			transition.to(cloud, {time = math.random(20000, 29000), x = cw+60})
		elseif cloudY > cw-101 and cloudY <cw-71 then 
			cloud.xScale = 0.3
			cloud.yScale = 0.3
			transition.to(cloud, {time = math.random(30000, 40000), x = cw+60})
		else
			transition.to(cloud, {time = math.random(9000, 19000), x = cw+60})
		end
	return cloud
	end




	local ground = display.newImageRect("images/endGround.png", 360, 285)
	ground.x = cx
	ground.y = cy
	--display.newImage("images/endGround.png", cx, cy)
		ground.anchorY = 0
	--back = display.newRect(cx,cy,cw,ch)
	--back:setFillColor(0,0,220)
	cloudGroup:insert(ground)


local createDungTimer

  local createDung = function()
    dungX = math.random(0, cw)
    local dungSequenceData = {
			{name = "rolling", start = 1, count = 6, time = 600}
		}
	dung = display.newSprite( dungSheet , dungSequenceData )
	--dung:setFillColor(116/255,113/255,58/255)
    dung.x = dungX
    dung.y = ch
    --display.newCircle(dungX,ch,40)
    cloudGroup:insert(dung)
   -- dung:setFillColor(0.5,0.5,0.5)
    local destroyDung = function(self)
      self:removeSelf()
      self = nil
    end
    local dungX2
      if dungX>cx then
      dungX2 = cx + ((dungX-cx)/2)
      elseif
        dungX<cx then
        dungX2 = cx - ((cx-dungX)/2)
      else
        dungX2 = cx
      end
    transition.to(dung, {time = 800, x = dungX2, y = cy+20, xScale = 0.2, yScale = 0.2, transition = easing.outCubic, onComplete = destroyDung})
    createDungTimer()
  	
  	return dung
  	end

	createDungTimer = function()
		local dungDelay = math.random(2000,8000)
	  	dungTimer = timer.performWithDelay(dungDelay, createDung)
	  return dungTimer
	end
createDungTimer()



----cacti
	local createCactus = function(cactusType, cactusX, cactusY, scale, flip)
	local cactusX = cactusX
	local cactusY = cactusY
	local flip = flip
	local cactusType = cactusType
	local cactusImage = "images/cactus.png"
	if cactusType == 3 then 
		cactusImage = "images/cactus2.png" 
		--cactusY = cactusY+20
	end
		local cactus = display.newImageRect(cactusImage, 44, 76)
			cactus.x = cactusX 
			cactus.y = cactusY
		--display.newImage(cactusImage, cactusX, cactusY)
			if flip == 1 then 
				cactus.xScale = 0-scale
			else
				cactus.xScale = scale
			end
				cactus.yScale = scale
			cactusGroup:insert(cactus)
			return cactus
	end
local screenDiv = cw/13
createCactus(math.random(1,3), math.random(screenDiv,screenDiv*2), cy-math.random(30,50), math.random(5,10)/10, math.random(1,2))
createCactus(math.random(1,3), math.random(screenDiv*3,screenDiv*4), cy-math.random(30,50), math.random(5,10)/10, math.random(1,2))
createCactus(math.random(1,3), math.random(screenDiv*5,screenDiv*6), cy-math.random(30,50), math.random(5,10)/10, math.random(1,2))
createCactus(math.random(1,3), math.random(screenDiv*7,screenDiv*8), cy-math.random(30,50), math.random(5,10)/10, math.random(1,2))
createCactus(math.random(1,3), math.random(screenDiv*9,screenDiv*10), cy-math.random(30,50), math.random(5,10)/10, math.random(1,2))
createCactus(math.random(1,3), math.random(screenDiv*11,screenDiv*12), cy-math.random(30,50), math.random(5,10)/10, math.random(1,2))
--[[createCactus(math.random(20, screenQ-10), cy - math.random(40,60))
createCactus(screenQ+10+math.random(0, screenQ-20), cy - math.random(40,60))
--createCactus(cx+math.random(-20,20) , cy-10 )
createCactus(cx+math.random(-20, 20), cy - math.random(40,60))
createCactus(cx+20+math.random(0, screenQ-10), cy - math.random(40,60))
createCactus(cx+screenQ+10+math.random(0, screenQ-30), cy - math.random(40,60))
]]

-----create timmy------------------------------------------------------------
-----------------------------------------------------------------
--local newHiScore = true
local endTimmyFadeIn
local jumpTimer
local endTimmy = display.newImageRect("images/endTimmy.png", 16, 20)
local yayTimmy
local timmyStartY = cy-187
local timmyNewStartY = cy-197
endTimmy.x = math.random(cx-110, cx+110)
endTimmy.y = timmyStartY
endTimmy.alpha = 0
cactusGroup:insert(endTimmy)
local timmyMove = function()
	local timmyChange = function()
		if newHi == true then
			yayTimmy = display.newImageRect("images/yayTimmy.png", 16, 20)
			cactusGroup:insert(yayTimmy)
			yayTimmy.x = endTimmy.x
			yayTimmy.y = endTimmy.y
			endTimmy:removeSelf()
			endTimmy = nil
		end
	end
	endTimmy.alpha = 1
	local endTimmyMove = transition.to(endTimmy, {time = 500, y = timmyNewStartY, onComplete = timmyChange})
end
endTimmyFadeIn = timer.performWithDelay(1500, timmyMove)

local timmyJump
local timmyJumpFunction
timmyJumpFunction = function()
	if newHi == true then
		local timmyReturn = function()	
			timmyJump = transition.to(yayTimmy, {time = 200, y = timmyNewStartY, transition = easing.inQuart, onComplete = timmyJumpFunction})
		end
		timmyJump = transition.to(yayTimmy, {time = 200, y = timmyNewStartY-20, transition = easing.outQuart, onComplete = timmyReturn})
	end
end

	jumpTimer = timer.performWithDelay(2100, timmyJumpFunction)


-----------------------------------------------------------------
-----------------------------------------------------------------

	local scoreBack = display.newImageRect("images/scoreBack2.png", 360, 80)
		scoreBack.x = cx
		scoreBack.y = cy-5
	--display.newImage("images/scoreBack2.png", cx, cy-5)
	--Rect(cx, cy-5, cw, 80)
	hudGroup:insert(scoreBack)

	local scoreShadow = display.newRect(cx, cy+150, cw, 8)
		scoreShadow:setFillColor(0,0,0)
		scoreShadow.alpha = 0.03
	hudGroup:insert(scoreShadow)


		messageBack = display.newImageRect("images/messageBack2.png", 265, 80)
		 messageBack.x = cx
		 messageBack.y = -100

		hudGroup:insert(messageBack)
		transition.to(messageBack, {time = 1100, y = cy-160, transition = easing.inOutElastic})

		if newHi == false then
			messageText = display.newImageRect("images/poorTimmy.png", 234, 44)
		else
			messageText = display.newImageRect("images/goTimmy.png", 190, 45)
		end
		messageText.x = cx
		messageText.y = -100
		--display.newImage("images/badLuck.png", cx, -100)
		--display.newText( "Bad Luck!", cx, -50, gameFont, 55 )
		hudGroup:insert(messageText)
		transition.to(messageText, {time = 1100, y = cy-158, transition = easing.inOutElastic})

		if newHi == false then
			local createPostBack = function ()
				postBack = display.newImageRect("images/postBack1.png", 84, 128)
				postBack.x = cw+50
				postBack.y = cy-5
				--display.newImage("images/postBack1.png", cw+50, cy-5)
				--display.newRoundedRect(cw+50, cy-4, 80, 140, 10)
				--postBack:setFillColor( gray )
				hudGroup:insert(postBack)
				transition.to(postBack, {time = 1100, x = cw-20, transition = easing.inOutElastic})
			return postBack
			end
			timer.performWithDelay(300, createPostBack)

			local createPostBackShadow = function()
				 postBackShadow = display.newRoundedRect(cw+50,cy+170, 80, 14, 5 )
					postBackShadow:setFillColor(0,0,0)
					postBackShadow.alpha = 0.03
				hudGroup:insert(postBackShadow)
				transition.to(postBackShadow, {time = 1100, x = cw-20, transition = easing.inOutElastic})
			return postBackShadow
			end
			timer.performWithDelay(300, createPostBackShadow)
		else
			local createPostBack = function ()
				postBack = display.newImageRect("images/postBack2.png", 294, 68)
					postBack.x = cx
					postBack.y = -50
				--display.newImage("images/postBack2.png", cx, -50)
				--display.newRoundedRect(cx, -50, 290, 50, 5)
				hudGroup:insert(postBack)
				--postBack:setFillColor( gray )
				transition.to(postBack, {time = 1100, y = cy - 83, transition = easing.inOutElastic})
				return postBack
			end
			timer.performWithDelay(300, createPostBack)

			local createPostText = function()
				postText = display.newImageRect("images/hiScore.png", 145, 28)
					postText.x = cx
					postText.y = -50
				--display.newImage("images/postNow2.png", cx,-50)
				--Text("post now?", cx ,-50, gameFont, 25)
				hudGroup:insert(postText)
				transition.to(postText, {time = 1100, y = cy - 83, transition = easing.inOutElastic})
				return postText
			end
			timer.performWithDelay(300, createPostText)
		end

		local createFacebook = function()
			--facebookBtn = display.newRoundedRect(cw+100, cy-50, 80, 40, 10)
			facebookBtn = display.newImageRect( "images/fbIcon.png", 52, 52)
				if newHi == false then
					facebookBtn.x = cw+100
					facebookBtn.y = cy-35 
				else
					facebookBtn.x = cx+111
					--cw+100
					facebookBtn.y = -50
					--cy-85
				end
			--display.newImage( "images/fbIcon.png", cw+100, cy-35 )
				facebookBtn.id = "facebook"
				facebookBtn:addEventListener( "touch", postStart )
				hudGroup:insert(facebookBtn)
				if newHi == false then
					transition.to(facebookBtn, {time = 1100, x = cw-27, transition = easing.inOutElastic})
				else
					transition.to(facebookBtn, {time = 1100, y = cy-83, transition = easing.inOutElastic})
						--x = cx+111, transition = easing.inOutElastic})
				end
		return facebookBtn
		end
		timer.performWithDelay(300, createFacebook)

		local createFacebookOverlay = function()
			--facebookBtn = display.newRoundedRect(cw+100, cy-50, 80, 40, 10)
			facebookBtnOverlay = display.newRoundedRect(facebookBtn.x, facebookBtn.y, 48, 48, 7) 
				facebookBtnOverlay.alpha = 0
			--display.newImage( "images/fbIcon.png", cw+100, cy-35 )
			hudGroup:insert(facebookBtnOverlay)
			if newHi == false then
				transition.to(facebookBtnOverlay, {time = 1100, x = cw-27, transition = easing.inOutElastic})
			else
				transition.to(facebookBtnOverlay, {time = 1100, y = cy-83, transition = easing.inOutElastic})
					--x = cx+111, transition = easing.inOutElastic})
			end
		return facebookBtnOverlay
		end
		timer.performWithDelay(300, createFacebookOverlay)

		local createTwitter = function()
			--twitterBtn = display.newRoundedRect(cw+100, cy+10, 80 , 40,10)
			twitterBtn = display.newImageRect( "images/twitterIcon.png", 52, 52)
				if newHi == false then
					twitterBtn.x = cw+100
					twitterBtn.y = cy+25
				else
					twitterBtn.x = cx-111
					-- -100
					twitterBtn.y = -50
					-- cy-85					
				end
				twitterBtn.id = "twitter"
			--display.newImage( "images/twitterIcon.png", cw+100, cy+25)
				twitterBtn:addEventListener( "touch", postStart )
			hudGroup:insert(twitterBtn)
			if newHi == false then
				transition.to(twitterBtn, {time = 1100, x = cw-27, transition = easing.inOutElastic})
			else 
				transition.to(twitterBtn, {time = 1100, y = cy-83, transition = easing.inOutElastic})
					--x = cx-111, transition = easing.inOutElastic})
			end
		return twitterBtn
		end
		timer.performWithDelay(300, createTwitter)
	

		local createTwitterOverlay = function()
			--facebookBtn = display.newRoundedRect(cw+100, cy-50, 80, 40, 10)
			twitterBtnOverlay = display.newRoundedRect(twitterBtn.x, twitterBtn.y, 48, 48, 7) 
				twitterBtnOverlay.alpha = 0
			--display.newImage( "images/fbIcon.png", cw+100, cy-35 )
			hudGroup:insert(twitterBtnOverlay)
			if newHi == false then
				transition.to(twitterBtnOverlay, {time = 1100, x = cw-27, transition = easing.inOutElastic})
			else
				transition.to(twitterBtnOverlay, {time = 1100, y = cy-83, transition = easing.inOutElastic})
			end
		return twitterBtnOverlay
		end
		timer.performWithDelay(300, createTwitterOverlay)


		local createRateBack = function ()
				rateBack = display.newImageRect("images/rateBack.png", 80, 70)
				rateBack.x = -48
				rateBack.y = cy-5
				rateBack.xScale = -1
				--rateBack.yScale = -1
				--display.newImage("images/postBack1.png", cw+50, cy-5)
				--display.newRoundedRect(cw+50, cy-4, 80, 140, 10)
				--postBack:setFillColor( gray )
				hudGroup:insert(rateBack)
				transition.to(rateBack, {time = 1100, x = 22, transition = easing.inOutElastic})
			return rateBack
		end
		timer.performWithDelay(300, createRateBack)

		local rateBtn
		local rateBtnOverlay
		local canRate = true

		local rateApp = function(event)
			if event.phase == "ended" and canRate == true then
				canRate = false
				rateBtnOverlay.alpha = 1
				local ratePopup = function()
					canRate = true
				local options = { iOSAppId = "933331507"}
				native.showPopup("rateApp", options)
				end
				transition.to(rateBtnOverlay, {time = 1000, alpha = 0, onComplete = ratePopup})
				
			end
		end

		local createRateBtn = function()
			--twitterBtn = display.newRoundedRect(cw+100, cy+10, 80 , 40,10)
			rateBtn = display.newImageRect( "images/rateApp.png", 52, 52)
				rateBtn.x = -48
				rateBtn.y = cy-5
				rateBtn.id = "rate"
			--display.newImage( "images/twitterIcon.png", cw+100, cy+25)
				rateBtn:addEventListener( "touch", rateApp )
				hudGroup:insert(rateBtn)
				transition.to(rateBtn, {time = 1100, x = 27, transition = easing.inOutElastic})
			
			return rateBtn
		end
		timer.performWithDelay(300, createRateBtn)

		local createRateBtnOverlay = function()
			--facebookBtn = display.newRoundedRect(cw+100, cy-50, 80, 40, 10)
			rateBtnOverlay = display.newRoundedRect(rateBtn.x, rateBtn.y, 48, 48, 7) 
				rateBtnOverlay.alpha = 0
			--display.newImage( "images/fbIcon.png", cw+100, cy-35 )
			hudGroup:insert(rateBtnOverlay)

				transition.to(rateBtnOverlay, {time = 1100, x = 27, transition = easing.inOutElastic})

		return rateBtnOverlay
		end
		timer.performWithDelay(300, createRateBtnOverlay)

	

	local scoreText = display.newImageRect("images/score.png", 90, 23)
		scoreText.x = cx-50
		scoreText.y = cy-25
	--display.newImage("images/score2.png", cx-60, cy-30)
	scoreText.xScale = 0.8
	scoreText.yScale = 0.8
		--scoreText:setFillColor( gray )
	hudGroup:insert(scoreText)

	local scoreValue = TextCandy.CreateText({ fontName = "numbersFont", x = cx-50, y = cy+10, text = score })
	--display.newText(score, cx-60, cy+10, gameFont, 30)
		--scoreValue:setFillColor( gray )
		scoreValue.xScale = 0.3
		scoreValue.yScale = 0.35
	hudGroup:insert(scoreValue)

	local hiText = display.newImageRect("images/best.png", 73, 25)
	hiText.x = cx+50
	hiText.y =  cy-25
	--display.newImage("images/best.png", cx+60, cy-30)
	hiText.xScale = 0.8
	hiText.yScale = 0.8
	--display.newText("Best", cx+60, cy-30, gameFont, 30)
		--hiText:setFillColor( gray )
	hudGroup:insert(hiText)

	local hiValue = TextCandy.CreateText({ fontName = "numbersFont", x = cx+50, y = cy+10, text = hi })
	--display.newText(hi, cx+60, cy+10, gameFont, 30)
		--hiValue:setFillColor( gray )
		hiValue.xScale = 0.3
		hiValue.yScale = 0.35
	hudGroup:insert(hiValue)

	local retryShadow = display.newRoundedRect(cx+3, ch+173, 152, 12, 5)
	retryShadow:setFillColor(0,0,0)
	retryShadow.alpha = 0.1
	transition.to(retryShadow, {time = 1000, y = cy+203, transition = easing.inOutElastic})
	hudGroup:insert(retryShadow)

	local retryBtn = display.newImageRect("images/retry.png", 152, 82)
	retryBtn.x = cx
	retryBtn.y = ch+90
	--display.newImage("images/retry2.png", cx, ch+90)
	--display.newRoundedRect(cx, ch+90, 130, 80, 20)
		--retryBtn:setFillColor(0, 100, 0)
	hudGroup:insert(retryBtn)
	transition.to(retryBtn, {time = 1000, y = cy+140, transition = easing.inOutElastic, onComplete = retryBtnActivate})
	
	local vertices = {0, 28, 14, 14, 0, 0}
	local retryOverlay = display.newPolygon( cx+60, cy+141, vertices )
	--retryOverlay:setFillColor(234/255, 83/255, 68/255)
	retryOverlay.alpha = 0
	hudGroup:insert(retryOverlay)
	--transition.to(retryOverlay, {time = 1000, y = cy+90, transition = easing.inOutElastic})

	local retryText = display.newImageRect("images/retryText.png", 111, 56)
	retryText.x = cx-7
	retryText.y = ch+90
	--display.newImage("images/retryText.png", cx-7, ch+90)
	--display.newText("Retry", cx, ch+90, gameFont, 50)
		--retryText:setFillColor(100, 0,0)
	hudGroup:insert(retryText)
	local textGrow = function()
		--transition.to(retryText, {time = 2000, xScale = 1.1, yScale = 1.1, transition = easing.continuosLoop, iterations = 0})
	end
	transition.to(retryText, {time = 1000, y = cy+140, transition = easing.inOutElastic, onComplete = textGrow})

	-----------------------------------------------------
	------- show banner Ad ------------------------------
	-----------------------------------------------------

--[[	if myData.tryCount ~= 10 then
		if myData.tryCount ~= 20 then
]]

		--	myData.adType = "banner"
		--	ads:setCurrentProvider( "iads" )
		--	ads.show("banner", {x = 0, y = 100000})
	--	end
--	end

	-----------------------------------------------------

	local resetGame = function(event)
		if event.phase == "began" and canRetry == true and myData.overlayActive == false then
			audio.fadeOut( { channel=6, time=300 })
			canRetry = false
			local canRetryToggle = function()
				canRetry = true
			end
			local retryTimer = timer.performWithDelay(2000, canRetryToggle)
				-------show interstitial ad -----
				---------------------------------
			if myData.tryCount == 10 or myData.tryCount == 21 then

				ads.hide()
				ads:setCurrentProvider( "iads" )
				myData.adType = "interstitial"
				ads.show("interstitial")
				local tryUp = math.random(1,2)
				myData.tryCount = myData.tryCount+tryUp
			
			elseif myData.tryCount == 31 then
				ads.hide()
				ads:setCurrentProvider( "vungle" )
				myData.adType = "interstitial"
				if ( ads.isAdAvailable() ) then
				local vungleParams = {
					   isAnimated = false,
					   isAutoRotation = true,
					}
				    ads.show( "interstitial", vungleParams )
				else
					ads:setCurrentProvider( "iads")
					myData.adType = "interstitial"
					ads.show( "interstitial" )
					--myData.tryCount = myData.tryCount+1
				end
				myData.tryCount = 0							
				

			

			--elseif myData.tryCount == 20 then
			--[[	ads.hide()
				ads:setCurrentProvider( "vungle" )

				if ( ads.isAdAvailable() ) then
				local vungleParams = {
					   isAnimated = false,
					   isAutoRotation = true,
					}
				    ads.show( "interstitial", vungleParams )
				else
					ads:setCurrentProvider( "iads")
					myData.adType = "interstitial"
					ads.show( "interstitial" )
				end		]]				


				---------------------------------------
			else 

				if newHi == true then
					transition.cancel(timmyJump)
					local destroyYayTimmy = function()
						yayTimmy:removeSelf()
						yayTimmy = nil
					end
					transition.to(yayTimmy, {time = 200, y = timmyStartY, onComplete = destroyYayTimmy})
				else
					local destroyEndTimmy = function()
						endTimmy:removeSelf()
						endTimmy = nil
					end
					transition.to(endTimmy, {time = 200, y = timmyStartY, onComplete = destroyEndTimmy})
				end
				ads.hide()

			-------------	
				timer.cancel(dungTimer)
				timer.cancel(endTimmyFadeIn)
				timer.cancel(jumpTimer)
				dungTimer = nil
				canRetry = false
				retryOverlay.alpha = 1
				transition.to( retryOverlay, {time = 1000 , alpha = 0}) 
				
				local removeButtons = function()
					facebookBtn:removeSelf()	
					facebookBtn = nil
					twitterBtn:removeSelf()
					twitterBtn = nil
				end

				if newHi == false then
					transition.to(facebookBtn, {time = 600, x = cw+100, transition = easing.inOutElastic, onComplete = removeButtons})
					transition.to(twitterBtn, {time = 600, x = cw+100, transition = easing.inOutElastic})
					transition.to(postBack, {time = 600, x = cw+50, transition = easing.inOutElastic})
					transition.to(postBackShadow, {time = 600, x = cw+50, transition = easing.inOutElastic})
					transition.to(messageText, {time = 1100, y = -50, transition = easing.inOutElastic})
					transition.to(messageBack, {time = 1100, y = -100, transition = easing.inOutElastic})
					transition.to(rateBack, {time = 950, x = - 50, transition = easing.inOutElastic})
					transition.to(rateBtn, {time = 950, x = -50, transition = easing.inOutElastic})
				else 
					transition.to(facebookBtn, {time = 950, y = -50, transition = easing.inOutElastic, onComplete = removeButtons})
						--x = cw+50, transition = easing.inOutElastic, onComplete = removeButtons})
					transition.to(twitterBtn, {time = 950, y = -50, transition = easing.inOutElastic})
					transition.to(rateBtn, {time = 950, x = -50, transition = easing.inOutElastic})
						--x = -50, transition = easing.inOutElastic})
					transition.to(messageText, {time = 850, y = -130, transition = easing.inOutElastic})
				--	transition.to(message2Text, {time = 900, y = -50, transition = easing.inOutElastic})
					transition.to(messageBack, {time = 850, y = -130, transition = easing.inOutElastic})
					transition.to(postText, {time = 950, y = - 50, transition = easing.inOutElastic})
					transition.to(postBack, {time = 950, y = - 50, transition = easing.inOutElastic})
					transition.to(rateBack, {time = 950, x = - 50, transition = easing.inOutElastic})

				end

				transition.to(retryBtn, {time = 1000, y = ch+90, transition = easing.inOutElastic})
				transition.to(retryShadow, {time = 1000, y = ch+173, transition = easing.inOutElastic})
				transition.to(retryOverlay, {time = 1000, y = ch+90, transition = easing.inOutElastic})
				transition.to(retryText, {time = 1000, y = ch+90, transition = easing.inOutElastic})
				
				transition.to(bannerAd, {time = 1000, y = ch+40, transition = easing.outSine})
				transition.to(adText, {time = 1000, y = ch+40, transition = easing.outSine})

				----cancel timers
				timer.cancel(newClouds3)
				newClouds3 = nil
				timer.cancel(newClouds2)
				newClouds2 = nil
				timer.cancel(newClouds1)
				newClouds1 = nil

				local changeDelay = function ()
					local options = {
						effect = "flipFadeOutIn",
						time = 100,
					}
					composer.gotoScene("scripts.scene1", options)

					local removeDelay = function()
						composer.removeScene("scripts.scene2")
					end
					timer.performWithDelay(600, removeDelay)
				end
				timer.performWithDelay(600, changeDelay)				
			end

		end
	end
	retryBtn:addEventListener( "touch", resetGame )

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
	local sceneGroup = self.view
-- Destroys scene
	--sceneGroup:removeSelf()
	--sceneGroup = nil
	--composer.removeScene("scripts.scene2")
	print( "((destroying scene 1's view))" )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
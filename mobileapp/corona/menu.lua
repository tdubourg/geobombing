local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

-- include Corona's "widget" library
local widget = require "widget"

-- forward declarations and other locals
local playBtn

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	storyboard.gotoScene( "game", "fade", 500 )

	return true	-- indicates successful touch
end


-- Those constants are the ratio of the sizes and positions of the widget button relative to the full sized-background,
-- As the background is going to be scaled, using the ratio, and multiplying by the contentWidth/contentHeight, we're
-- going to place them at the exact location where they should be
POS_X_WIDGET_BUTTON = 0.55
POS_Y_WIDGET_BUTTON = 0.7407407407407407

-- Those constants are because Corona does weird things
WIDTH_RATIO_WIDGET_BUTTON = 0.5
HEIGHT_RATIO_WIDGET_BUTTON = 0.5
PLAY_BTN_PIXELS_HEIGHT = 114
PLAY_BTN_PIXELS_WIDTH = 454

function scene:createScene( event )
	local group = self.view

	-- print ("display.contentWidth", "display.contentHeight")
	-- print (display.contentWidth, display.contentHeight)

	-- display a background image
	local background = display.newImageRect( "images/startscreen.png", display.contentWidth, display.contentHeight)
	-- background:setReferencePoint( display.TopLeftReferencePoint )
	background.x, background.y = display.contentCenterX, display.contentCenterY

	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		label="",
		labelColor = { default={255}, over={128} },
		defaultFile="images/play-button-startscreen.png",
		overFile="images/play-button-startscreen-mouseover.png",
		width=PLAY_BTN_PIXELS_WIDTH*WIDTH_RATIO_WIDGET_BUTTON,
		height=PLAY_BTN_PIXELS_HEIGHT*HEIGHT_RATIO_WIDGET_BUTTON,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	-- playBtn:setReferencePoint( display.TopLeftReferencePoint )
	playBtn.x = display.contentWidth*POS_X_WIDGET_BUTTON - 30
	playBtn.y = display.contentHeight*POS_Y_WIDGET_BUTTON

	-- all display objects must be inserted into group
	group:insert( background )
	group:insert( playBtn )
end


local function onKeyEvent( event )

	 local phase = event.phase
	 local keyName = event.keyName
	 -- print( event.phase, event.keyName )

	 if ( "back" == keyName and phase == "up" ) then
			if ( storyboard.currentScene == "splash" ) then
				 native.requestExit()
			else
				 if ( storyboard.isOverlay ) then
						storyboard.hideOverlay()
				 else
						local lastScene = storyboard.returnTo
						DBG(INFO, {"previous scene", lastScene} )
						if ( lastScene ) then
							 storyboard.gotoScene( lastScene, { effect="crossFade", time=500 } )
						else
							 native.requestExit()
						end
				 end
			end
	 end
	 return false  -- We only return true for the keys the app is "overriding", false for the other ones
end


-- Called immediately after scene has moved onscreen:
function scene:enterScene( event )
	local group = self.view
	storyboard.returnTo = nil -- We want to exit things, if back button is pressed when on menu
	Runtime:addEventListener( "key", onKeyEvent )
end

-- Called when scene is about to move offscreen:
function scene:exitScene( event )
	local group = self.view
	Runtime:removeEventListener( "key", onKeyEvent )
end

-- If scene's view is removed, scene:destroyScene() will be called just prior to:
function scene:destroyScene( event )
	local group = self.view

		background:removeSelf()
		background = nil
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end
-- "createScene" event is dispatched if scene's view does not exist
scene:addEventListener( "createScene", scene )

-- "enterScene" event is dispatched whenever scene transition has finished
scene:addEventListener( "enterScene", scene )

-- "exitScene" event is dispatched whenever before next scene's transition begins
scene:addEventListener( "exitScene", scene )

-- "destroyScene" event is dispatched before view is unloaded, which can be
-- automatically unloaded in low memory situations, or explicitly via a call to
-- storyboard.purgeScene() or storyboard.removeScene().
scene:addEventListener( "destroyScene", scene )


return scene
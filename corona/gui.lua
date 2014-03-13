local widget = require "widget"

local gui_group = display.newGroup( )
local bombBtn = nil
btnBombClicked = false

local net = require("network2")

local function onBombBtnRelease()
	if(not rankOn and not player.isDead) then
		btnBombClicked = true
		net.sendBombRequestToServer()
	end

	return true	-- indicates successful touch
end

local function onBombBtnDown()
	if (not rankOn and not player.isDead ) then
	end
	return true	-- indicates successful touch, to avoid other layers to grab the tap event as well
end

local function update()
  -- OPTIM: pull au lieu de fetch
  local name = player:getCurrentStreetName()
  if name then
    -- if streetText then
    --  streetText:removeSelf()
    -- end
    -- streetText = display.newText(name , 10, 10, native.systemFont, 24 )
    -- streetText.anchorX = 0
    -- streetText.anchorY = 0
    -- streetText:setFillColor( 0.7, 0, 0.3 )

    if not streetText then
      streetText = display.newText(name , 10, 10, native.systemFont, 20 )
      streetText.anchorX = 0
      streetText.anchorY = 0
      streetText:setFillColor( 0.7, 0, 0.3 )
    end
    streetText.text = name
  end
end


local initGUI = function (  )
	guiLayer:insert(gui_group)
	-- Those constants are the ratio of the sizes and positions of the widget button relative to the full sized-background,
	-- As the background is going to be scaled, using the ratio, and multiplying by the contentWidth/contentHeight, we're
	-- going to place them at the exact location where they should be
	POS_X_WIDGET_BUTTON = 0.90
	POS_Y_WIDGET_BUTTON = 0.85

	-- Those constants are because Corona does weird things
	WIDTH_RATIO_WIDGET_BUTTON = 0.5
	HEIGHT_RATIO_WIDGET_BUTTON = 0.5
	BOMB_BTN_PIXELS_HEIGHT = 100
	BOMB_BTN_PIXELS_WIDTH = 100
	-- create a widget button (which will loads level1.lua on release)
	bombBtn = widget.newButton {
		label="",
		labelColor = { default={128}, over={128} },
		defaultFile="images/bombButton2.png",
		overFile="images/bombButton3.png",
		width=BOMB_BTN_PIXELS_WIDTH*WIDTH_RATIO_WIDGET_BUTTON,
		height=BOMB_BTN_PIXELS_HEIGHT*HEIGHT_RATIO_WIDGET_BUTTON,
		onPress = onBombBtnDown,
		onRelease = onBombBtnRelease
	}
	
	bombBtn.x = display.contentWidth*POS_X_WIDGET_BUTTON 
	bombBtn.y = display.contentHeight*POS_Y_WIDGET_BUTTON
	gui_group:insert(bombBtn)
	gui_group:toFront()
end

local exitGUI = function (  )
	if bombBtn then
		bombBtn:removeSelf()	-- widgets must be manually removed
		bombBtn = nil
	end
	gui_group:removeSelf( )
end
 
return {
	initGUI = initGUI,
	exitGUI = exitGUI,
	update = update,
}
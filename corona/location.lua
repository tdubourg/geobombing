currentLatitude = nil
currentLongitude = nil

local locationHandler = function( event ) 
	-- Check for error (user may have turned off Location Services)
	if event.errorCode then
		native.showAlert( "GPS Location Error", event.errorMessage, {"OK"} )
		print( "Location error: " .. tostring( event.errorMessage ) )
	else
		local latitudeText = string.format( '%.4f', event.latitude )
		print ("Inside", latText)
		currentLatitude = latitudeText
		print ("Lat", latitudeText )
		-- display.newText(latitudeText, 0, 10, "Helvetica", 18 )

		local longitudeText = string.format( '%.4f', event.longitude )
		currentLongitude = longitudeText
		print ("Lat",  longitudeText )
		-- display.newText(longitudeText, 0, 30, "Helvetica", 18 )

		local altitudeText = string.format( '%.3f', event.altitude )
		print ("Altitude",  altitudeText )
		-- display.newText(altitudeText, 0, 50, "Helvetica", 18 )

		local accuracyText = string.format( '%.3f', event.accuracy )
		print ("Accuracy",  accuracyText )
		-- display.newText(accuracyText, 0, 70, "Helvetica", 18 )

		local speedText = string.format( '%.3f', event.speed )
		print ("Speed",  speedText )
		-- display.newText(speedText, 0, 90, "Helvetica", 18 )

		local directionText = string.format( '%.3f', event.direction )
		print ("Dir",  directionText )
		-- display.newText(directionText, 0, 110, "Helvetica", 18 )

		-- Note: event.time is a Unix-style timestamp, expressed in seconds since Jan. 1, 1970
		local timeText = string.format( '%.0f', event.time )
		print ("Time",  timeText )
		-- display.newText(timeText, 0, 130, "Helvetica", 18 )
	end
end

local enable_location = function (  )
	Runtime:addEventListener( "location", locationHandler )
end

local disable_location = function (  )
	Runtime:removeEventListener( "location", locationHandler )
end
-- Activate location listener
return {
	enable_location= enable_location,
	disable_location= disable_location
}
-----------------------------------------------------------------------------------------
--
-- Sound.lua
--
-- An abstract layer over the Corona sound library.
-- It features:
--  A cleaner way to handle the sounds
--  Default options defined on startup for fade in, fade out, volume, etc.
--  Auto-reset volume before playing the sound
--  Duration parameter along with fade out
--  Sound variations
--  Pitch modulation
--  Pan sound
--  Use media library instead of audio for Android devices
--  Lazy loading of sounds
--
-----------------------------------------------------------------------------------------
require "utils"
require "consts"
local utils = require("lib.ecusson.Utils")

-----------------------------------------------------------------------------------------

local Class = {}

-----------------------------------------------------------------------------------------
-- Main
-----------------------------------------------------------------------------------------

-- Load libraries
local audio = require("audio")
local media = require("media")

-- 'Touch' the audio class to enable it by getting one of its attributes
local totalChannels = audio.totalChannels

-- For panning: ensure correct distance model is being used.
al.DistanceModel(al.INVERSE_DISTANCE_CLAMPED)
al.Listener(al.POSITION, 0, 0, 0)
al.Listener(al.ORIENTATION, 0, 1, 0, 0, 0, 1)

-----------------------------------------------------------------------------------------
-- Class attributes
-----------------------------------------------------------------------------------------

local nativeTimer = timer
local random = math.random
local sin = math.sin
local cos = math.cos
local MATH_PI_180 = math.pi / 180

-- The sound path
local soundsPath

-- The sounds handles
local sounds = {}

-- Use mp3 by default
local defaultExtension = "mp3"

-- Enable the use of the media library only on iAndroid
local platformName = system.getInfo("platformName")
local enableMedia = platformName == "Android"

-- The sound global volume
local globalVolume = 1.0

-----------------------------------------------------------------------------------------
-- Class methods
-----------------------------------------------------------------------------------------

-- Setup sounds
--
-- Parameters:
--  soundsPath: The path to the sounds (e.g. "runtimedata/audio/")
--  soundsData: The user-defined sound data (See Sounds.lua for an example)
function Class.setup(options)
	soundsPath = options.soundsPath

	-- Load sounds
	for soundId, soundOptions in pairs(options.soundsData) do
		-- Select the appropriate method to load the sound
		local media = enableMedia and (soundOptions.media or false)
		local loadMethod
		local autoDestroy

		if soundOptions.stream then
			loadMethod = audio.loadStream
			autoDestroy = false
		elseif media then
			loadMethod = media.newEventSound
			autoDestroy = true
		else
			loadMethod = audio.loadSound
			autoDestroy = true
		end

		if soundOptions.autoDestroy ~= nil then
			autoDestroy = soundOptions.autoDestroy
		end

		-- Save sound settings
		sounds[soundId] = {
			name = soundId,
			loadMethod = loadMethod,
			loaded = false,
			settings = {
				loops = soundOptions.loops or 0,
				volume = soundOptions.volume or 1,
				duration = soundOptions.duration or nil,
				fadeIn = soundOptions.fadeIn or nil,
				fadeOut = soundOptions.fadeOut or nil,
				pitch = soundOptions.pitch or 1,
				stream = soundOptions.stream or false,
				media = media,
				variations = soundOptions.variations or { "" },
				extension = soundOptions.extension or defaultExtension,
				autoDestroy = autoDestroy, 
				autoUnload = soundOptions.autoUnload or false
			}
		}
	end
end

-- Stop audio and unload all sounds
function Class.tearDown()
	-- Stop all audio
	audio.stop()

	-- Dispose of all sounds
	for soundId, soundDefinition in pairs(sounds) do
		Class.unloadSound(soundId)
	end

	sounds = {}
end

-- Load a single sound (without playing it)
--
-- Parameters:
--  soundId: The sound to load
function Class.loadSound(soundId)
	dbg(ERRORS, {"[Sound] load sound   "..soundId})

	-- Load variations
	local variations = {}
	local soundSettings = sounds[soundId].settings
	for i, variation in ipairs(soundSettings.variations) do
		-- Local sound settings
		local localSettings = {}
		for key, value in pairs(soundSettings) do
			localSettings[key] = value
		end

		-- Determine suffix
		local suffix
		if type(variation) == "string" then
			suffix = variation
		else
			suffix = variation.suffix

			-- Override settings
			for key, value in pairs(localSettings) do
				localSettings[key] = variation[key] or localSettings[key]
			end
		end

		local filePath = soundsPath..soundId..suffix.."."..localSettings.extension
		localSettings.handle = sounds[soundId].loadMethod(filePath)
		assert(localSettings.handle, "Cannot load sound ("..filePath..")")

		variations[i] = localSettings
	end

	sounds[soundId].variations = variations
	sounds[soundId].loaded = true
end

-- Unload a sound previously loaded with loadSound
--
-- Parameters:
--  soundId: The sound to unload
function Class.unloadSound(soundId)
	local soundDefinition = sounds[soundId]

	if soundDefinition.loaded then
		dbg(ERRORS, {"[Sound] unload sound "..soundId})

		for i = 1, #soundDefinition.variations do
			audio.dispose(soundDefinition.variations[i].handle)
		end

		sounds[soundId].loaded = false
		sounds[soundId].variations = nil
	end
end

-- Set the global volume of the whole application
--
-- Parameters:
--  volume: The new volume, in [0, 1]
function Class.setGlobalVolume(volume)
	globalVolume = volume

	Runtime:dispatchEvent{
		name = "resetSoundsVolume"
	}
end

-----------------------------------------------------------------------------------------
-- Initialization and Destruction
-----------------------------------------------------------------------------------------

-- Create the sound
--
-- Parameters:
--  sound: The sound name
--  stream: If true, streams the sound instead of loading everything in memory
--  media: If true, uses the media library instead of audio tu play this sound on
--    Android devices (may be more reactive but cannot change the volume, pause it, etc.)
--  loops: The number of times you want the audio to loop (Default is 0).
--    Notice that 0 means the audio will loop 0 times which means that the sound
--    will play once and not loop. Continuing that thought, 1 means the audio will
--    play once and loop once which means you will hear the sound a total of
--    2 times. Passing -1 will tell the system to infinitely loop the sample.
--  volume: The volume of this sound, in [0 ; 1] (Default is 1).
--    It can be an interval to pick a random value from (e.g. { 0.5, 0.6 }).
--  duration: The sound duration in seconds (Default is nil, until the sound is finished).
--    It can be an interval to pick a random value from (e.g. { 0.5, 0.6 }).
--  fadeIn: The fade in time in seconds, this will cause the system to start playing
--    a sound muted and linearly ramp up to the maximum volume over the specified
--    number of seconds (Default is nil, no fade in).
--    It can be an interval to pick a random value from (e.g. { 0.5, 0.6 }).
--  fadeOut: The fade out time in seconds, this will cause the system to stop a
--    sound linearly from its level to no volume over the specified
--    number of seconds (Default is nil, no fade out).
--    It can be an interval to pick a random value from (e.g. { 0.5, 0.6 }).
--  pitch: The pitch to apply to the sound (Default is 1).
--    It can be an interval to pick a random value from (e.g. { 0.9, 1.2 }).
--  pan: The position of the sounds from 0 (left) to 1 (right).
--  autoDestroy: Automatically destroys the sound as soon as it has finished playing
--    (Default is false for stream sounds and true for others).
--  autoUnload: Automatically unloads the sound as soon as it has finishes playing
--    (Default is false).
--  onSoundComplete: The callback called when the sound has finished playing (optional).
function Class.create(sound, options)
	local self = utils.extend(Class)
	self.id = sound

	-- Lazy-load sound if not already loaded
	local soundDefinition = sounds[sound]
	if not soundDefinition.loaded then
		Class.loadSound(sound)
	end

	options = options or {}

	if audio.freeChannels == 0 then
		dbg(ERRORS, {"[Ecusson:Sound] Sound "..soundDefinition.name.." could not be played because all channels are in use."})
	else
		-- Determine which variation to play
		local variationId = options.variation or random(#soundDefinition.variations)
		local variation = soundDefinition.variations[variationId]

		-- Initialize attributes
		local duration = options.duration or variation.duration
		local fadeIn = options.fadeIn or variation.fadeIn
		local pitch = options.pitch or variation.pitch
		local volume = options.volume or variation.volume
		self.isMedia = options.media or variation.media
		self.isStream = options.stream or variation.stream
		self.fadeOut = options.fadeOut or variation.fadeOut
		self.autoUnload = options.autoUnload or variation.autoUnload
		self.onComplete = options.onSoundComplete
		self.handle = variation.handle
		self.playing = true

		-- Play sound
		if self.isMedia then
			media.playEventSound(self.handle, system.ResourceDirectory, function(event)
				self:onSoundComplete()
			end)
		else
			self.channel, self.source = audio.play(self.handle, {
				loops = options.loops or variation.loops,
				fadeIn = fadeIn and utils.extractValue(fadeIn) * 1000 or nil,
				onComplete = function(event)
					self:onSoundComplete()
				end
			})

			-- Initialize sound for panning
			al.Source(self.source, al.ROLLOFF_FACTOR, 1)
			al.Source(self.source, al.REFERENCE_DISTANCE, 2)
			al.Source(self.source, al.MAX_DISTANCE, 4)

			-- Set volume
			if not fadeIn then
				self:setVolume{
					volume = utils.extractValue(volume)
				}
			end

			-- Set pan
			if options.pan then
				self:pan(options.pan)
			end

			-- Set pitch
			self:setPitch(pitch)

			-- Manual duration handling (to have a proper fade out if any)
			if duration then
				if duration == 0 then
					self:stop()
				else
					self.timerId = nativeTimer.performWithDelay(utils.extractValue(duration) * 1000, self)
				end
			end

			Runtime:addEventListener("resetSoundsVolume", self)
		end
	end

	return self
end

-- Destroy the sound object
function Class:destroy()
	Runtime:removeEventListener("resetSoundsVolume", self)

	utils.deleteObject(self)
end

-----------------------------------------------------------------------------------------
-- Methods
-----------------------------------------------------------------------------------------

-- Check if the sound is playing
--
-- Returns true if the sound is currently playing
function Class:isPlaying()
	return self.isPlaying
end

-- Pause the sound
-- Warning: This does not free the channel
function Class:pause()
	if self.isMedia then
		dbg(ERRORS, {"[Ecusson:Sound] Error: Cannot pause a media sound"})
	elseif self.channel then
		if self.timerId then
			nativeTimer.pause(self.timerId)
		end

		audio.pause(self.channel)
	end
end

-- Resume the sound
function Class:resume()
	if self.isMedia then
		dbg(ERRORS, {"[Ecusson:Sound] Error: Cannot resume a media sound"})
	elseif self.channel then
		if self.timerId then
			nativeTimer.resume(self.timerId)
		end

		audio.resume(self.channel)
	end
end

-- Rewind the sound
function Class:rewind()
	if self.isMedia then
		dbg(ERRORS, {"[Ecusson:Sound] Error: Cannot rewind a media sound"})
	elseif self.channel then
		if self.isStream then
			audio.rewind(self.handle)
		else
			audio.rewind{
				channel = self.channel
			}
		end
	end
end

-- Seek to a time position
--
-- Parameters:
--  time: The time to seek, in seconds
function Class:seek(time)
	if self.isMedia then
		dbg(ERRORS, {"[Ecusson:Sound] Error: Cannot seek a media sound"})
	elseif self.channel then
		audio.seek(time * 1000, {
			channel = self.channel
		})
	end
end

-- Change the volume
--
-- Parameters:
--  volume: The new volume to set, in [0 ; 1]
--  time: The time in seconds to fade the volume (default is nil, no fade)
function Class:setVolume(options)
	if self.isMedia then
		dbg(ERRORS, {"[Ecusson:Sound] Error: Cannot set the volume of a media sound"})
	elseif self.channel then
		self.volume = utils.extractValue(options.volume)

		if options.time and options.time > 0 then
			audio.fade{
				channel = self.channel,
				time = utils.extractValue(options.time) * 1000,
				volume = self.volume * globalVolume
			}
		else
			audio.setVolume(self.volume * globalVolume, {
				channel = self.channel
			})
		end
	end
end

-- Change the pitch
--
-- Parameters:
--  pitch: The new pitch value
function Class:setPitch(pitch)
	if self.isMedia then
		dbg(ERRORS, {"[Ecusson:Sound] Error: Cannot change the pitch of a media sound"})
	else
		al.Source(self.source, al.PITCH, utils.extractValue(pitch))
	end
end

-- Pan the sound
--
-- Parameters:
--  value: The pan value, in [-1 ; 1]
function Class:pan(value)
	if self.isMedia then
		dbg(ERRORS, {"[Ecusson:Sound] Error: Cannot pan a media sound"})
	else
		local radi = (-90 + ((1 + value) * -90)) * MATH_PI_180
		al.Source(self.source, al.POSITION, sin(radi), cos(radi), 0)
	end
end

-- Stop the sound
--
-- Parameters:
--  fadeOutTime: The time in seconds to fade out (default is nil, no fade)
function Class:stop(fadeOutTime)
	if self.isMedia then
		dbg(ERRORS, {"[Ecusson:Sound] Error: Cannot stop a media sound"})
	elseif self.channel then
		if self.timerId then
			nativeTimer.cancel(self.timerId)
		end

		local fadeOut = fadeOutTime or self.fadeOut

		if fadeOut and fadeOut > 0 then
			audio.fadeOut{
				channel = self.channel,
				time = utils.extractValue(fadeOut) * 1000
			}
		else
			audio.stop(self.channel)
		end
	end
end

-----------------------------------------------------------------------------------------
-- Event handlers
-----------------------------------------------------------------------------------------

-- Event callback for the finished timer used to handle the duration
function Class:timer(event)
	self:stop()
end

-- Resets the sound volume, taking into account the global volume (called by setGlobalVolume)
function Class:resetSoundsVolume(event)
	self:setVolume{
		volume = self.volume
	}
end

-- Called when the sound has finished playing
function Class:onSoundComplete()
	self.playing = false

	-- Auto-rewind
	if self.isStream then
		self:rewind()
	end

	-- Call user callback if any
	utils.resolveCallback(self.onComplete, "onSoundComplete", event)

	-- Unload & destroy if needed
	if self.autoDestroy then
		if self.autoUnload then
			Class.unloadSound(self.id)
		end

		self:destroy()
	end
end

-----------------------------------------------------------------------------------------

return Class

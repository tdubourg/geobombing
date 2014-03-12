require("consts")
-----------------------------------------------------------------------------------------
--
-- Author: Aurélien Defossez
-- (c) 2014 Tabemasu Games (www.tabemasu.com)
--
-- Sprites configuration
--
-- Parameters:
--  frameCount: The number of frames defining the animation (default is 1)
--    If frameCount > 1, then the source images should be suffixed by _01, _02
--    and so on
--    (e.g. zombie_attack_right_blue_01.png and zombie_attack_right_blue_02.png)
--  period: The period in seconds to play the whole animation.
--	  (Optional if there is only one frame)
--  loopCount: Tells how many times the animation loops (Default is 0, indefinitely).
--  randomStartFrame: Starts at a random frame (Default is false).
--  attachments: A list of possible attachments to the sprite, with these parameters:
--    animation: The attachment animation
--    positions: The attachment positions relative to the sprite position
--
-----------------------------------------------------------------------------------------

return {
	sheets = {
		sprites = {
			level = {
				background = {},
				foreground = {}
			},

			man = {
				leftwalk = {
					frameCount = 4,
					period = 0.9
					-- loopCount = 1
				},
				leftstand = {
					frameCount = 2,
					period = 0.9
					-- loopCount = 1
				},
				rightwalk = {
					frameCount = 4,
					period = 0.9
					-- loopCount = 1
				},
				rightstand = {
					frameCount = 2,
					period = 0.9
					-- loopCount = 1
				},
				upwalk = {
					frameCount = 2,
					period = 0.9
					-- loopCount = 1
				},
				upstand = {
					frameCount = 2,
					period = 0.9
					-- loopCount = 1
				},
				downwalk = {
					frameCount = 2,
					period = 0.9
					-- loopCount = 1
				},
				downstand = {
					frameCount = 2,
					period = 0.9
					-- loopCount = 1
				},
				death = {
					frameCount = 2,
					period = 1,
					loopCount = 1
				},

			},

			manc = {
				leftwalk = {
					frameCount = 4,
					period = 0.9
					-- loopCount = 1
				},
				leftstand = {
					frameCount = 2,
					period = 0.9
					-- loopCount = 1
				},
				rightwalk = {
					frameCount = 4,
					period = 0.9
					-- loopCount = 1
				},
				rightstand = {
					frameCount = 2,
					period = 0.9
					-- loopCount = 1
				},
				upwalk = {
					frameCount = 2,
					period = 0.9
					-- loopCount = 1
				},
				upstand = {
					frameCount = 2,
					period = 0.9
					-- loopCount = 1
				},
				downwalk = {
					frameCount = 2,
					period = 0.9
					-- loopCount = 1
				},
				downstand = {
					frameCount = 2,
					period = 0.9
					-- loopCount = 1
				},
				death = {
					frameCount = 2,
					period = 1,
					loopCount = 1
				},
			},

			bomb = {
				idle = {
					frameCount = 1,
					period = 10000,
					loopCount = 1
				},

				explode = {
					frameCount = 60,
					period = EXPLOSION_DURATION,
					loopCount = 1
				}
			}
		}
	},

	-----------------------------------------------------------------------------------------
	-- Sprite attachments configuration
	--
	-- Parameters:
	--  spriteSet: The attachment spriteSet
	--  toBack: If true, add the attachment below the sprite (optional, default is false)
	--
	-----------------------------------------------------------------------------------------

	attachments = {
	}
}

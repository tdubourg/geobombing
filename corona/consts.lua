require("utils")

DEV_MODE = true
EXPLOSION_DELAY = 3000 -- in ms
EXPLOSION_DURATION = 1.5 -- in seconds
-- JSON labels
	-- protocol
	JSON_FRAME_TYPE = "type"
	JSON_FRAME_DATA = "data"
		-- Frame Types
		if (DEV_MODE) then
			NETWORK_PLAYER_UPDATE_POS_KEY = "pos"
			NETWORK_PLAYER_UPDATE_STATE_KEY = "s"
			NETWORK_PLAYER_UPDATE_ID_KEY = "id"
			NETWORK_PLAYER_UPDATE_DEAD_KEY = "dead"

			NETWORK_INIT_MAP_KEY = "map"
			NETWORK_INIT_KEY_KEY = "key"
			NETWORK_INIT_PLAYER_ID_KEY = "id"
			FRAMETYPE_PLAYER_UPDATE = "pu"
			FRAMETYPE_MOVE = "move"
			FRAMETYPE_GPS = "gps"
			FRAMETYPE_BOMB = "bomb"
			FRAMETYPE_INIT = "init"
			JSON_MOVE_NODES = "nodes"
			JSON_MOVE_START_EDGE_POS = "start_edge_pos"
			JSON_MOVE_END_EDGE_POS = "end_edge_pos"
			NETWORK_POS_N1 = "n1"
			NETWORK_POS_N2 = "n2"
			NETWORK_POS_C = "c"
			JSON_FRAME_KEY = "key"
			FRAMETYPE_PLAYER_DISCONNECT = "gone"
		else
			NETWORK_PLAYER_UPDATE_POS_KEY = "pos"
			NETWORK_PLAYER_UPDATE_STATE_KEY = "s"
			NETWORK_PLAYER_UPDATE_ID_KEY = "id"
			NETWORK_PLAYER_UPDATE_DEAD_KEY = "dead"
			
			NETWORK_INIT_PLAYER_ID_KEY = "id"
			NETWORK_INIT_MAP_KEY = "map"
			NETWORK_INIT_KEY_KEY = "key"
			FRAMETYPE_PLAYER_UPDATE = "pu"
			FRAMETYPE_INIT = "init"
			FRAMETYPE_MOVE = "mv"
			FRAMETYPE_GPS = "gps"
			FRAMETYPE_BOMB = "bb"
			JSON_MOVE_NODES = "n"
			JSON_MOVE_START_EDGE_POS = "sep"
			JSON_MOVE_END_EDGE_POS = "eep"
			NETWORK_POS_N1 = "n1"
			NETWORK_POS_N2 = "n2"
			NETWORK_POS_C = "c"
			JSON_FRAME_KEY = "key"
			FRAMETYPE_PLAYER_DISCONNECT = "gone"
		end

	-- ranking
	FRAMETYPE_GAME_END = "end"
	NETWORK_GAME_RANKING = "ranking"
	NETWORK_RANKING_ID= "id"
	NETWORK_RANKING_NB_DEATH ="pdeads"
	NETWORK_RANKING_NB_KILL = "pkills"
	NETWORK_RANKING_POINTS= "ppoints"

	-- tiles 
	TYPETILES = "tiles"
	TYPEGRID = "grid"
	TYPEPOINT = "topLeftPoint"

	-- time remaining
	NETWORK_TIME = "time"
	
	--bomb data
	FRAMETYPE_BOMB_UPDATE = "bu"
	NETWORK_BOMB_UPDATE_ID_KEY = "bid"
	NETWORK_BOMB_UPDATE_STATE_KEY = "bs"
	NETWORK_BOMB_UPDATE_TYPE_KEY = "btype"
	NETWORK_BOMB_UPDATE_POS_KEY = "pos"
	NETWORK_BOMB_UPDATE_POWER_KEY = "rad"
	-- map data
	JSON_MAP_NAME = "mapName"
	JSON_NODE_LIST = "mapListNode"
	JSON_WAY_LIST = "mapListWay"
	JSON_WAY_NODE_LIST = "wLstNdId"
	JSON_WAY_NAME = "wName"

	JSON_NODE_UID = "id"
	JSON_NODE_X = "x"
	JSON_NODE_Y = "y"

	-- GPS data
	JSON_GPS_LATITUDE = "latitude"
	JSON_GPS_LONGITUDE = "longitude"

-- DISPLAY
EXPLOSION_INTERVAL = 0.02


-- GAMEPLAY

BOMB_DBG_MODE = false

-- require("consts-local")
silent_fail_require("consts-local")
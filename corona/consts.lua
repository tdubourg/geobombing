require("utils")

SERVER_IP_ADDR = "127.0.0.1"
SERVER_PORT = "3000"
DEV_MODE = true
EXPLOSION_DELAY = 3000 -- in ms
EXPLOSION_DURATION = 1.5 -- in seconds

DISPLAY_MAP_ARCS = false
DISPLAY_MAP_NODES = false

ZOOM = 2000

-- JSON labels
	-- protocol
	JSON_FRAME_TYPE = "type"
	JSON_FRAME_DATA = "data"
	NETW_INIT_GRID_BOUNDS_SMTLP = 'sessionMapTopLeftPoint'				-- node in OSM tiles coordinates
	NETW_INIT_GRID_BOUNDS_SMBRP = 'sessionMapBottomRightPoint'
	NETW_INIT_GRID_BOUNDS_TTLP = 'tilesTopLeftPoint'							-- tiles boundaries in OSM tiles coordinates
	NETW_INIT_GRID_BOUNDS_TBRP = 'tilesBottomRightPoint'
		-- Frame Types
		if (DEV_MODE) then
			NETWORK_PLAYER_UPDATE_POS_KEY = "pos"
			NETWORK_PLAYER_UPDATE_STATE_KEY = "s"
			NETWORK_PLAYER_UPDATE_ID_KEY = "id"
			NETWORK_PLAYER_UPDATE_DEAD_KEY = "dead"
			NETWORK_PLAYER_UPDATE_TIMESTAMP_KEY = "ts"

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
			NETWORK_PLAYER_UPDATE_TIMESTAMP_KEY = "ts"
			
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
	NETWORK_TIME = "tr"

	-- number of kills
	NETWORK_KILLS = "k"

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

PLAYER_UPDATE_DISCARD_DELAY_IN_MS = 500

-- Other
NETW_RECV_OPTIMIZATION = true
NETW_DISCARD_PU_OPTIMIZATION = false

-- GAMEPLAY

BOMB_DBG_MODE = false
NETW_DBG_MODE = false
NETW_DUMP_MODE = false
DISCARDED_PLAYER_UPDATES = true
GAME_DBG = false

-- require("consts-local")
silent_fail_require("consts-local")
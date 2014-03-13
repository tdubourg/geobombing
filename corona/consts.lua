require("utils")

SERVER_IP_ADDR = "127.0.0.1"
SERVER_PORT = "3000"

DISPLAY_MAP_ARCS = false
DISPLAY_MAP_NODES = false

ZOOM = 2000
PERSPECTIVE_PROJ = 1 -- 1 for top-down, 0.4-0.6 for iso perspective

-- anim
EXPLOSION_PERIOD = 1.2 -- in seconds
DEATH_ANIM_PERIOD = 3
BOMB_PULSE_PERIOD = 0.5

-- JSON labels
	-- protocol
	JSON_FRAME_TYPE = "type"
	JSON_FRAME_DATA = "data"
	NETW_INIT_GRID_BOUNDS_SMTLP = 'sessionMapTopLeftPoint'				-- node in OSM tiles coordinates
	NETW_INIT_GRID_BOUNDS_SMBRP = 'sessionMapBottomRightPoint'
	NETW_INIT_GRID_BOUNDS_TTLP = 'tilesTopLeftPoint'							-- tiles boundaries in OSM tiles coordinates
	NETW_INIT_GRID_BOUNDS_TBRP = 'tilesBottomRightPoint'

		-- Frame Types
	NETWORK_PLAYER_UPDATE_PLAYERS_KEY = "pl"
	NETWORK_PLAYER_UPDATE_POS_KEY = "pos"
	NETWORK_PLAYER_UPDATE_STATE_KEY = "s"
	NETWORK_PLAYER_UPDATE_ID_KEY = "id"
	NETWORK_PLAYER_UPDATE_DEAD_KEY = "dead"
	NETWORK_PLAYER_UPDATE_TIMESTAMP_KEY = "ts"

	NETWORK_MONSTER_UPDATE_MONSTERS_KEY = "ms"
	NETWORK_MONSTER_UPDATE_POS_KEY = "pos"
	NETWORK_MONSTER_UPDATE_ID_KEY = "id"
	NETWORK_MONSTER_UPDATE_DEAD_KEY = "dead"
	NETWORK_MONSTER_UPDATE_TIMESTAMP_KEY = "ts"

	NETWORK_INIT_MAP_KEY = "map"
	NETWORK_INIT_KEY_KEY = "key"
	NETWORK_INIT_PLAYER_ID_KEY = "id"
	FRAMETYPE_PLAYERS_UPDATE = "pu" -- players
	FRAMETYPE_MONSTERS_UPDATE = "mu" -- monsters
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
	
	-- player name
	NETWORK_NAME = "name"

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
	NETWORK_REMAINING_TIME = "tr"

	-- number of kills
	NETWORK_KILLS = "k"

	--bomb data
	FRAMETYPE_BOMB_UPDATE = "bu"
	NETWORK_BOMB_UPDATE_ID_KEY = "bid"
	NETWORK_BOMB_UPDATE_OWNER_KEY = "id"
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
EXPLOSION_INTERVAL = 0.012

PLAYER_UPDATE_DISCARD_DELAY_IN_MS = 100

-- Other
NETW_RECV_OPTIMIZATION = true
NETW_DISCARD_PU_OPTIMIZATION = true

-- GAMEPLAY
PLAYER_MOVE_ON_DRAG_UPDATE_INTERVAL_IN_MS = 100
ERRORS = true -- enables or disables displaying errors on stdout
INFO = true -- INFO traces
BOMB_DBG_MODE = false
NETW_DBG_MODE = false
NETW_DUMP_MODE = false
DISCARDED_PLAYER_UPDATES_MSG = true
GAME_DBG = false

-- require("consts-local")
silent_fail_require("consts-local")
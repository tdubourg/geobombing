DEV_MODE = true
EXPLOSION_DELAY = 3000 -- in ms
EXPLOSION_DURATION = 1.5 -- in seconds
-- JSON labels
  -- protocol
    JSON_FRAME_TYPE = "type"
    JSON_FRAME_DATA = "data"
    -- Frame Types
    if (DEV_MODE) then
      FRAMETYPE_MOVE = "move"
      FRAMETYPE_MAP = "map"
      FRAMETYPE_GPS = "gps"
      FRAMETYPE_BOMB = "bomb"
      JSON_MOVE_NODES = "nodes"
      JSON_MOVE_START_EDGE_POS = "start_edge_pos"
      JSON_MOVE_END_EDGE_POS = "end_edge_pos"
    else
      FRAMETYPE_MOVE = "mv"
      FRAMETYPE_MAP = "mp"
      FRAMETYPE_GPS = "gps"
      FRAMETYPE_BOMB = "bb"
      JSON_MOVE_NODES = "n"
      JSON_MOVE_START_EDGE_POS = "sep"
      JSON_MOVE_END_EDGE_POS = "eep"
    end

  -- map data
    JSON_MAP_NAME = "mapName"
    JSON_NODE_LIST = "mapListNode"
    JSON_WAY_LIST = "mapListWay"
    JSON_WAY_NODE_LIST = "wLstNdId"

    JSON_NODE_UID = "id"
    JSON_NODE_X = "x"
    JSON_NODE_Y = "y"

  -- GPS data
    JSON_GPS_LATITUDE = "latitude"
    JSON_GPS_LONGITUDE = "longitude"

--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:313134a95193bebfb461a8c492bcab3d:465cf561e2d5fc4f4a109cdec467ca52:f5c322b4188998d6cd973301e8657e5f$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- bombButton
            x=928,
            y=272,
            width=256,
            height=256,

        },
        {
            -- bombButton2
            x=528,
            y=720,
            width=512,
            height=512,

        },
        {
            -- bombButton3
            x=0,
            y=624,
            width=512,
            height=512,

        },
        {
            -- bomb_explode_01
            x=1232,
            y=1680,
            width=160,
            height=160,

        },
        {
            -- bomb_explode_02
            x=1056,
            y=1856,
            width=160,
            height=160,

        },
        {
            -- bomb_explode_03
            x=1056,
            y=1680,
            width=160,
            height=160,

        },
        {
            -- bomb_idle
            x=1104,
            y=544,
            width=32,
            height=32,

        },
        {
            -- bombe_idle_01
            x=880,
            y=1776,
            width=160,
            height=160,

        },
        {
            -- bombe_idle_02
            x=704,
            y=1776,
            width=160,
            height=160,

        },
        {
            -- bombec_idle_01
            x=880,
            y=1600,
            width=160,
            height=160,

        },
        {
            -- bombec_idle_02
            x=704,
            y=1600,
            width=160,
            height=160,

        },
        {
            -- man_death_01
            x=528,
            y=1856,
            width=160,
            height=160,

        },
        {
            -- man_death_02
            x=528,
            y=1680,
            width=160,
            height=160,

        },
        {
            -- man_downstand_01
            x=352,
            y=1856,
            width=160,
            height=160,

        },
        {
            -- man_downstand_02
            x=352,
            y=1856,
            width=160,
            height=160,

        },
        {
            -- man_downwalk_01
            x=352,
            y=1680,
            width=160,
            height=160,

        },
        {
            -- man_downwalk_02
            x=176,
            y=1856,
            width=160,
            height=160,

        },
        {
            -- man_leftstand_01
            x=176,
            y=1680,
            width=160,
            height=160,

        },
        {
            -- man_leftstand_02
            x=352,
            y=1504,
            width=160,
            height=160,

        },
        {
            -- man_leftwalk_01
            x=176,
            y=1504,
            width=160,
            height=160,

        },
        {
            -- man_leftwalk_02
            x=0,
            y=1856,
            width=160,
            height=160,

        },
        {
            -- man_leftwalk_03
            x=0,
            y=1504,
            width=160,
            height=160,

        },
        {
            -- man_leftwalk_04
            x=0,
            y=1856,
            width=160,
            height=160,

        },
        {
            -- man_rightstand_01
            x=0,
            y=1680,
            width=160,
            height=160,

        },
        {
            -- man_rightstand_02
            x=1232,
            y=1504,
            width=160,
            height=160,

        },
        {
            -- man_rightwalk_01
            x=1056,
            y=1504,
            width=160,
            height=160,

        },
        {
            -- man_rightwalk_02
            x=880,
            y=1424,
            width=160,
            height=160,

        },
        {
            -- man_rightwalk_03
            x=704,
            y=1424,
            width=160,
            height=160,

        },
        {
            -- man_rightwalk_04
            x=880,
            y=1424,
            width=160,
            height=160,

        },
        {
            -- man_upstand_01
            x=528,
            y=1424,
            width=160,
            height=160,

        },
        {
            -- man_upstand_02
            x=352,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- man_upwalk_01
            x=176,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- man_upwalk_02
            x=0,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- manc_death_01
            x=1232,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- manc_death_02
            x=1056,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- manc_downstand_01
            x=1232,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- manc_downstand_02
            x=1232,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- manc_downwalk_01
            x=880,
            y=1248,
            width=160,
            height=160,

        },
        {
            -- manc_downwalk_02
            x=704,
            y=1248,
            width=160,
            height=160,

        },
        {
            -- manc_leftstand_01
            x=528,
            y=1248,
            width=160,
            height=160,

        },
        {
            -- manc_leftstand_02
            x=352,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- manc_leftwalk_01
            x=176,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- manc_leftwalk_02
            x=0,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- manc_leftwalk_03
            x=1232,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- manc_leftwalk_04
            x=0,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- manc_rightstand_01
            x=1056,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- manc_rightstand_02
            x=1232,
            y=976,
            width=160,
            height=160,

        },
        {
            -- manc_rightwalk_01
            x=1056,
            y=976,
            width=160,
            height=160,

        },
        {
            -- manc_rightwalk_02
            x=1232,
            y=800,
            width=160,
            height=160,

        },
        {
            -- manc_rightwalk_03
            x=1056,
            y=800,
            width=160,
            height=160,

        },
        {
            -- manc_rightwalk_04
            x=1232,
            y=800,
            width=160,
            height=160,

        },
        {
            -- manc_upstand_01
            x=1104,
            y=624,
            width=160,
            height=160,

        },
        {
            -- manc_upstand_02
            x=928,
            y=544,
            width=160,
            height=160,

        },
        {
            -- manc_upwalk_01
            x=1200,
            y=448,
            width=160,
            height=160,

        },
        {
            -- manc_upwalk_02
            x=1200,
            y=272,
            width=160,
            height=160,

        },
        {
            -- play-button-startscreen-mouseover
            x=928,
            y=136,
            width=456,
            height=120,

        },
        {
            -- play-button-startscreen
            x=928,
            y=0,
            width=456,
            height=120,

        },
        {
            -- startscreen
            x=0,
            y=0,
            width=912,
            height=608,

        },
    },
    
    sheetContentWidth = 1392,
    sheetContentHeight = 2016
}

SheetInfo.frameIndex =
{

    ["bombButton"] = 1,
    ["bombButton2"] = 2,
    ["bombButton3"] = 3,
    ["bomb_explode_01"] = 4,
    ["bomb_explode_02"] = 5,
    ["bomb_explode_03"] = 6,
    ["bomb_idle"] = 7,
    ["bombe_idle_01"] = 8,
    ["bombe_idle_02"] = 9,
    ["bombec_idle_01"] = 10,
    ["bombec_idle_02"] = 11,
    ["man_death_01"] = 12,
    ["man_death_02"] = 13,
    ["man_downstand_01"] = 14,
    ["man_downstand_02"] = 15,
    ["man_downwalk_01"] = 16,
    ["man_downwalk_02"] = 17,
    ["man_leftstand_01"] = 18,
    ["man_leftstand_02"] = 19,
    ["man_leftwalk_01"] = 20,
    ["man_leftwalk_02"] = 21,
    ["man_leftwalk_03"] = 22,
    ["man_leftwalk_04"] = 23,
    ["man_rightstand_01"] = 24,
    ["man_rightstand_02"] = 25,
    ["man_rightwalk_01"] = 26,
    ["man_rightwalk_02"] = 27,
    ["man_rightwalk_03"] = 28,
    ["man_rightwalk_04"] = 29,
    ["man_upstand_01"] = 30,
    ["man_upstand_02"] = 31,
    ["man_upwalk_01"] = 32,
    ["man_upwalk_02"] = 33,
    ["manc_death_01"] = 34,
    ["manc_death_02"] = 35,
    ["manc_downstand_01"] = 36,
    ["manc_downstand_02"] = 37,
    ["manc_downwalk_01"] = 38,
    ["manc_downwalk_02"] = 39,
    ["manc_leftstand_01"] = 40,
    ["manc_leftstand_02"] = 41,
    ["manc_leftwalk_01"] = 42,
    ["manc_leftwalk_02"] = 43,
    ["manc_leftwalk_03"] = 44,
    ["manc_leftwalk_04"] = 45,
    ["manc_rightstand_01"] = 46,
    ["manc_rightstand_02"] = 47,
    ["manc_rightwalk_01"] = 48,
    ["manc_rightwalk_02"] = 49,
    ["manc_rightwalk_03"] = 50,
    ["manc_rightwalk_04"] = 51,
    ["manc_upstand_01"] = 52,
    ["manc_upstand_02"] = 53,
    ["manc_upwalk_01"] = 54,
    ["manc_upwalk_02"] = 55,
    ["play-button-startscreen-mouseover"] = 56,
    ["play-button-startscreen"] = 57,
    ["startscreen"] = 58,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo

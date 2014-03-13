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
            x=232,
            y=68,
            width=64,
            height=64,

        },
        {
            -- bombButton2
            x=132,
            y=180,
            width=128,
            height=128,

        },
        {
            -- bombButton3
            x=0,
            y=156,
            width=128,
            height=128,

        },
        {
            -- bomb_explode_01
            x=308,
            y=420,
            width=40,
            height=40,

        },
        {
            -- bomb_explode_02
            x=264,
            y=464,
            width=40,
            height=40,

        },
        {
            -- bomb_explode_03
            x=264,
            y=420,
            width=40,
            height=40,

        },
        {
            -- bomb_idle
            x=276,
            y=136,
            width=8,
            height=8,

        },
        {
            -- bombe_idle_01
            x=220,
            y=444,
            width=40,
            height=40,

        },
        {
            -- bombe_idle_02
            x=176,
            y=444,
            width=40,
            height=40,

        },
        {
            -- bombec_idle_01
            x=220,
            y=400,
            width=40,
            height=40,

        },
        {
            -- bombec_idle_02
            x=176,
            y=400,
            width=40,
            height=40,

        },
        {
            -- man_death_01
            x=132,
            y=464,
            width=40,
            height=40,

        },
        {
            -- man_death_02
            x=132,
            y=420,
            width=40,
            height=40,

        },
        {
            -- man_downstand_01
            x=88,
            y=464,
            width=40,
            height=40,

        },
        {
            -- man_downstand_02
            x=88,
            y=464,
            width=40,
            height=40,

        },
        {
            -- man_downwalk_01
            x=88,
            y=420,
            width=40,
            height=40,

        },
        {
            -- man_downwalk_02
            x=44,
            y=464,
            width=40,
            height=40,

        },
        {
            -- man_leftstand_01
            x=44,
            y=420,
            width=40,
            height=40,

        },
        {
            -- man_leftstand_02
            x=88,
            y=376,
            width=40,
            height=40,

        },
        {
            -- man_leftwalk_01
            x=44,
            y=376,
            width=40,
            height=40,

        },
        {
            -- man_leftwalk_02
            x=0,
            y=464,
            width=40,
            height=40,

        },
        {
            -- man_leftwalk_03
            x=0,
            y=376,
            width=40,
            height=40,

        },
        {
            -- man_leftwalk_04
            x=0,
            y=464,
            width=40,
            height=40,

        },
        {
            -- man_rightstand_01
            x=0,
            y=420,
            width=40,
            height=40,

        },
        {
            -- man_rightstand_02
            x=308,
            y=376,
            width=40,
            height=40,

        },
        {
            -- man_rightwalk_01
            x=264,
            y=376,
            width=40,
            height=40,

        },
        {
            -- man_rightwalk_02
            x=220,
            y=356,
            width=40,
            height=40,

        },
        {
            -- man_rightwalk_03
            x=176,
            y=356,
            width=40,
            height=40,

        },
        {
            -- man_rightwalk_04
            x=220,
            y=356,
            width=40,
            height=40,

        },
        {
            -- man_upstand_01
            x=132,
            y=356,
            width=40,
            height=40,

        },
        {
            -- man_upstand_02
            x=88,
            y=332,
            width=40,
            height=40,

        },
        {
            -- man_upwalk_01
            x=44,
            y=332,
            width=40,
            height=40,

        },
        {
            -- man_upwalk_02
            x=0,
            y=332,
            width=40,
            height=40,

        },
        {
            -- manc_death_01
            x=308,
            y=332,
            width=40,
            height=40,

        },
        {
            -- manc_death_02
            x=264,
            y=332,
            width=40,
            height=40,

        },
        {
            -- manc_downstand_01
            x=308,
            y=332,
            width=40,
            height=40,

        },
        {
            -- manc_downstand_02
            x=308,
            y=332,
            width=40,
            height=40,

        },
        {
            -- manc_downwalk_01
            x=220,
            y=312,
            width=40,
            height=40,

        },
        {
            -- manc_downwalk_02
            x=176,
            y=312,
            width=40,
            height=40,

        },
        {
            -- manc_leftstand_01
            x=132,
            y=312,
            width=40,
            height=40,

        },
        {
            -- manc_leftstand_02
            x=88,
            y=288,
            width=40,
            height=40,

        },
        {
            -- manc_leftwalk_01
            x=44,
            y=288,
            width=40,
            height=40,

        },
        {
            -- manc_leftwalk_02
            x=0,
            y=288,
            width=40,
            height=40,

        },
        {
            -- manc_leftwalk_03
            x=308,
            y=288,
            width=40,
            height=40,

        },
        {
            -- manc_leftwalk_04
            x=0,
            y=288,
            width=40,
            height=40,

        },
        {
            -- manc_rightstand_01
            x=264,
            y=288,
            width=40,
            height=40,

        },
        {
            -- manc_rightstand_02
            x=308,
            y=244,
            width=40,
            height=40,

        },
        {
            -- manc_rightwalk_01
            x=264,
            y=244,
            width=40,
            height=40,

        },
        {
            -- manc_rightwalk_02
            x=308,
            y=200,
            width=40,
            height=40,

        },
        {
            -- manc_rightwalk_03
            x=264,
            y=200,
            width=40,
            height=40,

        },
        {
            -- manc_rightwalk_04
            x=308,
            y=200,
            width=40,
            height=40,

        },
        {
            -- manc_upstand_01
            x=276,
            y=156,
            width=40,
            height=40,

        },
        {
            -- manc_upstand_02
            x=232,
            y=136,
            width=40,
            height=40,

        },
        {
            -- manc_upwalk_01
            x=300,
            y=112,
            width=40,
            height=40,

        },
        {
            -- manc_upwalk_02
            x=300,
            y=68,
            width=40,
            height=40,

        },
        {
            -- play-button-startscreen-mouseover
            x=232,
            y=34,
            width=114,
            height=30,

        },
        {
            -- play-button-startscreen
            x=232,
            y=0,
            width=114,
            height=30,

        },
        {
            -- startscreen
            x=0,
            y=0,
            width=228,
            height=152,

        },
    },
    
    sheetContentWidth = 348,
    sheetContentHeight = 504
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

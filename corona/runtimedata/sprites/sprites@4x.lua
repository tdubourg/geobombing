--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:2505061f02acd919ee4a3a7b2870c668:ffa1bce64f2cded35ca043af94c45ab1:f5c322b4188998d6cd973301e8657e5f$
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
            y=528,
            width=256,
            height=256,

        },
        {
            -- bombButton2
            x=1456,
            y=0,
            width=512,
            height=512,

        },
        {
            -- bombButton3
            x=928,
            y=0,
            width=512,
            height=512,

        },
        {
            -- bomb_explode_01
            x=1408,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- bomb_explode_02
            x=1232,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- bomb_explode_03
            x=1056,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- bomb_explode_04
            x=880,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- bomb_explode_05
            x=1760,
            y=1232,
            width=160,
            height=160,

        },
        {
            -- bomb_explode_06
            x=1584,
            y=1232,
            width=160,
            height=160,

        },
        {
            -- bomb_explode_07
            x=1408,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- bomb_explode_08
            x=1232,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- bomb_idle_01
            x=1056,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- bomb_idle_02
            x=880,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- bombc_idle_01
            x=704,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- bombc_idle_02
            x=704,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- man_death_01
            x=528,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- man_death_02
            x=528,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- man_downstand_01
            x=352,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- man_downstand_02
            x=352,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- man_downwalk_01
            x=352,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- man_downwalk_02
            x=1760,
            y=1056,
            width=160,
            height=160,

        },
        {
            -- man_leftstand_01
            x=1584,
            y=1056,
            width=160,
            height=160,

        },
        {
            -- man_leftstand_02
            x=1408,
            y=976,
            width=160,
            height=160,

        },
        {
            -- man_leftwalk_01
            x=1232,
            y=976,
            width=160,
            height=160,

        },
        {
            -- man_leftwalk_02
            x=1056,
            y=976,
            width=160,
            height=160,

        },
        {
            -- man_leftwalk_03
            x=880,
            y=976,
            width=160,
            height=160,

        },
        {
            -- man_leftwalk_04
            x=1056,
            y=976,
            width=160,
            height=160,

        },
        {
            -- man_rightstand_01
            x=704,
            y=976,
            width=160,
            height=160,

        },
        {
            -- man_rightstand_02
            x=528,
            y=976,
            width=160,
            height=160,

        },
        {
            -- man_rightwalk_01
            x=352,
            y=976,
            width=160,
            height=160,

        },
        {
            -- man_rightwalk_02
            x=176,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- man_rightwalk_03
            x=176,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- man_rightwalk_04
            x=176,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- man_upstand_01
            x=176,
            y=976,
            width=160,
            height=160,

        },
        {
            -- man_upstand_02
            x=1760,
            y=880,
            width=160,
            height=160,

        },
        {
            -- man_upwalk_01
            x=1584,
            y=880,
            width=160,
            height=160,

        },
        {
            -- man_upwalk_02
            x=1408,
            y=800,
            width=160,
            height=160,

        },
        {
            -- manc_death_01
            x=1232,
            y=800,
            width=160,
            height=160,

        },
        {
            -- manc_death_02
            x=1056,
            y=800,
            width=160,
            height=160,

        },
        {
            -- manc_downstand_01
            x=1232,
            y=800,
            width=160,
            height=160,

        },
        {
            -- manc_downstand_02
            x=1232,
            y=800,
            width=160,
            height=160,

        },
        {
            -- manc_downwalk_01
            x=880,
            y=800,
            width=160,
            height=160,

        },
        {
            -- manc_downwalk_02
            x=704,
            y=800,
            width=160,
            height=160,

        },
        {
            -- manc_leftstand_01
            x=528,
            y=800,
            width=160,
            height=160,

        },
        {
            -- manc_leftstand_02
            x=352,
            y=800,
            width=160,
            height=160,

        },
        {
            -- manc_leftwalk_01
            x=176,
            y=800,
            width=160,
            height=160,

        },
        {
            -- manc_leftwalk_02
            x=0,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- manc_leftwalk_03
            x=0,
            y=1152,
            width=160,
            height=160,

        },
        {
            -- manc_leftwalk_04
            x=0,
            y=1328,
            width=160,
            height=160,

        },
        {
            -- manc_rightstand_01
            x=0,
            y=976,
            width=160,
            height=160,

        },
        {
            -- manc_rightstand_02
            x=0,
            y=800,
            width=160,
            height=160,

        },
        {
            -- manc_rightwalk_01
            x=704,
            y=624,
            width=160,
            height=160,

        },
        {
            -- manc_rightwalk_02
            x=528,
            y=624,
            width=160,
            height=160,

        },
        {
            -- manc_rightwalk_03
            x=352,
            y=624,
            width=160,
            height=160,

        },
        {
            -- manc_rightwalk_04
            x=528,
            y=624,
            width=160,
            height=160,

        },
        {
            -- manc_upstand_01
            x=176,
            y=624,
            width=160,
            height=160,

        },
        {
            -- manc_upstand_02
            x=0,
            y=624,
            width=160,
            height=160,

        },
        {
            -- manc_upwalk_01
            x=1672,
            y=704,
            width=160,
            height=160,

        },
        {
            -- manc_upwalk_02
            x=1672,
            y=528,
            width=160,
            height=160,

        },
        {
            -- play-button-startscreen-mouseover
            x=1200,
            y=664,
            width=456,
            height=120,

        },
        {
            -- play-button-startscreen
            x=1200,
            y=528,
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
    
    sheetContentWidth = 1968,
    sheetContentHeight = 1488
}

SheetInfo.frameIndex =
{

    ["bombButton"] = 1,
    ["bombButton2"] = 2,
    ["bombButton3"] = 3,
    ["bomb_explode_01"] = 4,
    ["bomb_explode_02"] = 5,
    ["bomb_explode_03"] = 6,
    ["bomb_explode_04"] = 7,
    ["bomb_explode_05"] = 8,
    ["bomb_explode_06"] = 9,
    ["bomb_explode_07"] = 10,
    ["bomb_explode_08"] = 11,
    ["bomb_idle_01"] = 12,
    ["bomb_idle_02"] = 13,
    ["bombc_idle_01"] = 14,
    ["bombc_idle_02"] = 15,
    ["man_death_01"] = 16,
    ["man_death_02"] = 17,
    ["man_downstand_01"] = 18,
    ["man_downstand_02"] = 19,
    ["man_downwalk_01"] = 20,
    ["man_downwalk_02"] = 21,
    ["man_leftstand_01"] = 22,
    ["man_leftstand_02"] = 23,
    ["man_leftwalk_01"] = 24,
    ["man_leftwalk_02"] = 25,
    ["man_leftwalk_03"] = 26,
    ["man_leftwalk_04"] = 27,
    ["man_rightstand_01"] = 28,
    ["man_rightstand_02"] = 29,
    ["man_rightwalk_01"] = 30,
    ["man_rightwalk_02"] = 31,
    ["man_rightwalk_03"] = 32,
    ["man_rightwalk_04"] = 33,
    ["man_upstand_01"] = 34,
    ["man_upstand_02"] = 35,
    ["man_upwalk_01"] = 36,
    ["man_upwalk_02"] = 37,
    ["manc_death_01"] = 38,
    ["manc_death_02"] = 39,
    ["manc_downstand_01"] = 40,
    ["manc_downstand_02"] = 41,
    ["manc_downwalk_01"] = 42,
    ["manc_downwalk_02"] = 43,
    ["manc_leftstand_01"] = 44,
    ["manc_leftstand_02"] = 45,
    ["manc_leftwalk_01"] = 46,
    ["manc_leftwalk_02"] = 47,
    ["manc_leftwalk_03"] = 48,
    ["manc_leftwalk_04"] = 49,
    ["manc_rightstand_01"] = 50,
    ["manc_rightstand_02"] = 51,
    ["manc_rightwalk_01"] = 52,
    ["manc_rightwalk_02"] = 53,
    ["manc_rightwalk_03"] = 54,
    ["manc_rightwalk_04"] = 55,
    ["manc_upstand_01"] = 56,
    ["manc_upstand_02"] = 57,
    ["manc_upwalk_01"] = 58,
    ["manc_upwalk_02"] = 59,
    ["play-button-startscreen-mouseover"] = 60,
    ["play-button-startscreen"] = 61,
    ["startscreen"] = 62,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo

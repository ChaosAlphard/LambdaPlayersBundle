
LambdaEntityLimits = {}

-- Creates a entity limit for keeping track of whatever entities
-- See lambda/sv_entitylimits.lua for functions to add to the limit and check
function CreateLambdaEntLimit( name, default, max )
    local entityLimitTransMap = {
        ["Prop"] = "道具",
        ["Entity"] = "实体",
        ["NPC"] = "NPC",
        ["Balloon"] = "气球",
        ["Dynamite"] = "爆炸物",
        ["Emitter"] = "发射器",
        ["Hoverball"] = "悬浮球",
        ["Lamp"] = "电灯",
        ["Light"] = "光源",
        ["Rope"] = "绳子",
        ["Thruster"] = "推进器",
        ["Wheel"] = "车轮"
    }
    local entityLimitTransVal = entityLimitTransMap[name] or name
    CreateLambdaConvar( "lambdaplayers_limits_" .. name .. "limit", default, true, false, false, "Lambda Player 所能允许生成的" .. entityLimitTransVal .. "的最大数量限制", 0, max, { type = "Slider", name = entityLimitTransVal .. "数量限制", decimals = 0, category = "Limits and Tool Permissions" } )
    if SERVER then LambdaEntityLimits[ #LambdaEntityLimits + 1 ] = name end
end


CreateLambdaEntLimit( "Prop", 300, 50000 )
CreateLambdaEntLimit( "Entity", 5, 200 )
CreateLambdaEntLimit( "NPC", 1, 200 )
CreateLambdaEntLimit( "Balloon", 10, 200 )
CreateLambdaEntLimit( "Dynamite", 5, 200 )
CreateLambdaEntLimit( "Emitter", 5, 200 )
CreateLambdaEntLimit( "Hoverball", 5, 200 )
CreateLambdaEntLimit( "Lamp", 5, 200 )
CreateLambdaEntLimit( "Light", 5, 200 )
CreateLambdaEntLimit( "Rope", 5, 200 )
CreateLambdaEntLimit( "Thruster", 5, 200 )
CreateLambdaEntLimit( "Wheel", 5, 200 )

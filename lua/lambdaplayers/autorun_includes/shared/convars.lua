local table_insert = table.insert
local GetConVar = GetConVar
local tostring = tostring
local CreateConVar = CreateConVar
local CreateClientConVar = CreateClientConVar
local defDisplayClr = Color( 255, 136, 0 )

-- Will be used for presets
_LAMBDAPLAYERSCONVARS = {}

if CLIENT then
    _LAMBDAConVarNames = {}
    _LAMBDAConVarSettings = {}
elseif SERVER then
    _LAMBDAEntLimits = {}
end

-- A multi purpose function for both client and server convars
function CreateLambdaConvar( name, val, shouldsave, isclient, userinfo, desc, min, max, settingstbl )
    isclient = isclient or false
    if isclient and SERVER then return end

    local strVar = tostring( val )
    if !_LAMBDAPLAYERSCONVARS[ name ] then _LAMBDAPLAYERSCONVARS[ name ] = strVar end

    local convar = GetConVar( name ) 
    if !convar then
        shouldsave = shouldsave or true
        if isclient then
            convar = CreateClientConVar( name, strVar, shouldsave, userinfo, desc, min, max )
        else
            convar = CreateConVar( name, strVar, ( shouldsave and ( FCVAR_ARCHIVE + FCVAR_REPLICATED ) or ( FCVAR_NONE + FCVAR_REPLICATED ) ), desc, min, max )
        end
    end

    if CLIENT and settingstbl and !_LAMBDAConVarNames[ name ] then
        settingstbl.convar = name
        settingstbl.min = min
        settingstbl.default = val
        settingstbl.isclient = isclient
        settingstbl.desc = ( isclient and "[客户端]" or "[服务端]" ) .. desc .. ( isclient and "" or "\nConVar: " .. name )
        settingstbl.max = max

        _LAMBDAConVarNames[ name ] = true
        table_insert( _LAMBDAConVarSettings, settingstbl )
    end

    return convar
end

local function AddSourceConVarToSettings( cvarname, desc, settingstbl )
    if CLIENT and settingstbl and !_LAMBDAConVarNames[ cvarname ] then
        settingstbl.convar = cvarname
        settingstbl.isclient = false
        settingstbl.desc = "[服务端]" .. desc .. "\nConVar: " .. cvarname

        _LAMBDAConVarNames[ cvarname ] = true
        table_insert( _LAMBDAConVarSettings, settingstbl )
    end
end

function CreateLambdaColorConvar( name, defaultcolor, isclient, userinfo, desc, settingstbl )
    local nameR = name .. "_r"
    local nameG = name .. "_g"
    local nameB = name .. "_b"

    local redCvar = GetConVar( nameR )
    if !redCvar then redCvar = CreateLambdaConvar( nameR, defaultcolor.r, true, isclient, userinfo, desc, 0, 255, nil ) end

    local greenCvar = GetConVar( nameG )
    if !greenCvar then greenCvar = CreateLambdaConvar( nameG, defaultcolor.r, true, isclient, userinfo, desc, 0, 255, nil ) end

    local blueCvar = GetConVar( nameB )
    if !blueCvar then blueCvar = CreateLambdaConvar( nameB, defaultcolor.r, true, isclient, userinfo, desc, 0, 255, nil ) end

    if CLIENT and !_LAMBDAConVarNames[ name ] then
        settingstbl.red = nameR
        settingstbl.green = nameG
        settingstbl.blue = nameB

        settingstbl.default = "Red = " .. tostring( defaultcolor.r ) .. " | " .. "Green = " .. tostring( defaultcolor.g ) .. " | " .. "Blue = " .. tostring( defaultcolor.b )
        settingstbl.type = "Color"

        settingstbl.isclient = isclient
        settingstbl.desc = ( isclient and "[客户端]" or "[服务端]" ) .. desc .. ( isclient and "" or "\nConVar: " .. name )
        settingstbl.max = max

        _LAMBDAConVarNames[ name ] = true
        table_insert( _LAMBDAConVarSettings, settingstbl )
    end

    return redCvar, greenCvar, blueCvar
end

-- These Convar Functions are capable of creating spawnmenu settings automatically.

---------- Valid Table options ----------
-- type | String | Must be one of the following: Slider, Bool, Text, Combo. For Colors, you must use CreateLambdaColorConvar()
-- name | String | Pretty name
-- decimals | Number | Slider only! How much decimals the slider should have
-- category | String | The Lambda Settings category to place the convar into. Will create one if one doesn't exist already
-- options | Table | Combo only! A table with its keys being the text and values being the data

-- Other Convars
CreateLambdaConvar( "lambdaplayers_drawflashlights", 1, true, true, false, "是否渲染 Lambda Player 的手电筒", 0, 1, { type = "Bool", name = "渲染手电筒", category = "Lambda Player Settings" } )
CreateLambdaConvar( "lambdaplayers_uiscale", 0, true, true, false, "用户界面缩放，例如：名称弹窗，语音弹窗等", ( CLIENT and -ScrW() or 1 ), ( CLIENT and ScrW() or 1 ), { type = "Slider", name = "界面缩放", decimals = 1, category = "Utilities" } )
CreateLambdaConvar( "lambdaplayers_corpsecleanuptime", 15, true, true, false, "多少时间后清理尸体。设置为0表示不清理", 0, 190, { type = "Slider", name = "尸体清理时间", decimals = 0, category = "Utilities" } )
CreateLambdaConvar( "lambdaplayers_corpsecleanupeffect", 0, true, true, false, "将要被清理的尸体拥有特殊的视觉效果", 0, 1, { type = "Bool", name = "尸体清理效果", category = "Utilities" } )
CreateLambdaConvar( "lambdaplayers_removecorpseonrespawn", 0, true, true, false, "在 Lambda Player 复活后立即清理对应的尸体", 0, 1, { type = "Bool", name = "复活后移除尸体", category = "Utilities" } )
CreateLambdaConvar( "lambdaplayers_lambda_serversideragdolls", 0, true, false, false, "启用服务端布娃娃(Server-Side Ragdolls)，这将允许插件与布娃娃进行互动，但会消耗更多性能，启用后将使用服务端尸体清理选项", 0, 1, { type = "Bool", name = "服务端布娃娃", category = "Utilities" } )
CreateLambdaConvar( "lambdaplayers_lambda_serversideragdollcleanuptime", 15, true, false, false, "多少时间后清理尸体。设置为0表示不清理", 0, 190, { type = "Slider", decimals = 0, name = "尸体清理时间", category = "Utilities" } )
CreateLambdaConvar( "lambdaplayers_lambda_serversideragdollcleanupeffect", 0, true, false, false, "将要被清理的尸体拥有特殊的视觉效果", 0, 1, { type = "Bool", name = "尸体清理效果", category = "Utilities" } )
CreateLambdaConvar( "lambdaplayers_lambda_serversideremovecorpseonrespawn", 0, true, false, false, "在 Lambda Player 复活后立即清理对应的尸体", 0, 1, { type = "Bool", name = "复活后移除尸体", category = "Utilities" } )
CreateLambdaConvar( "lambdaplayers_voice_warnvoicestereo", 0, true, true, false, "控制台是否对有立体声通道的语音线路发出警告", 0, 1, { type = "Bool", name = "立体声警告", category = "Utilities" } )
CreateLambdaConvar( "lambdaplayers_displayarmor", 0, true, true, false, "看向 Lambda Player 时，显示目标的护甲值百分比", 0, 1, { type = "Bool", name = "显示护甲", category = "Lambda Player Settings" } )

CreateLambdaConvar( "lambdaplayers_useplayermodelcolorasdisplaycolor", 0, true, true, true, "将 Lambda Player 的玩家模型颜色(Playermodel Color)设置为显示颜色。此选项的优先级高于下方的显示颜色选项", 0, 1, { type = "Bool", name = "玩家模型颜色作为显示颜色", category = "Misc" } )
CreateLambdaColorConvar( "lambdaplayers_displaycolor", defDisplayClr, true, true, "Lambda Player 的名称显示以及其他显示的显示颜色", { name = "显示颜色", category = "Misc" } )
CreateLambdaConvar( "lambdaplayers_animatedpfpsprayframerate", 10, true, true, false, "Lambda Player 的喷漆(Spray) VTFs 以及资料图片(Profile Picture) VTFs 的帧率", 1, 60, { type = "Slider", decimals = 0, name = "VTF 动画帧率", category = "Misc" } )
CreateLambdaConvar( "lambdaplayers_randomizepathingcost", 0, true, false, false, "Lambda Player将尝试不同的路径到达目的地，而不是固定使用最短和最快的路径", 0, 1, { type = "Bool", name = "随机寻路成本", category = "Misc" } )
--

-- Lambda Player Server Convars
CreateLambdaConvar( "lambdaplayers_lambda_infwanderdistance", 0, true, false, false, "允许 Lambda Player 在导航网(Navmesh)上的任何地方行走，而不是在1500源单位(Source Units)内行走", 0, 1, { type = "Bool", name = "无限制活动距离", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_avoid", 0, true, false, false, "Lambda Player 会尽量避开障碍。启用该选项会降低性能", 0, 1, { type = "Bool", name = "障碍回避", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_maxhealth", 100, true, false, false, "Lamda Player 的最大生命值", 1, 10000, { type = "Slider", decimals = 0, name = "最大生命值", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_spawnhealth", 100, true, false, false, "Lambda Player 生成时自带的生命值", 1, 10000, { type = "Slider", decimals = 0, name = "自带生命值", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_maxarmor", 100, true, false, false, "Lambda Player 的最大护甲值", 0, 10000, { type = "Slider", decimals = 0, name = "最大护甲值", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_spawnarmor", 0, true, false, false, "Lambda Player 生成时自带的护甲值", 0, 10000, { type = "Slider", decimals = 0, name = "自带护甲值", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_walkspeed", 200, true, false, false, "Lambda Player 的行走速度。默认：200", 100, 1500, { type = "Slider", decimals = 0, name = "行走速度", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_runspeed", 400, true, false, false, "Lambda Player 的奔跑速度。默认：400", 100, 1500, { type = "Slider", decimals = 0, name = "奔跑速度", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_allownoclip", 1, true, false, false, "允许 Lambda Player 使用 Noclip 模式", 0, 1, { type = "Bool", name = "允许 Noclip 模式", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_allowkillbind", 0, true, false, false, "Lambda Player 将会随机使用他们的 Killbind", 0, 1, { type = "Bool", name = "允许 Killbind", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_allowrandomaddonsmodels", 0, true, false, false, "允许 Lambda Player 使用其他插件提供的玩家模型(Playermodel)", 0, 1, { type = "Bool", name = "使用附加玩家模型", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_onlyaddonmodels", 0, true, false, false, "Lambda Player 只使用其他插件提供的玩家模型(Playermodel)。至少需要有一个可用的附加玩家模型才能生效", 0, 1, { type = "Bool", name = "仅使用附加玩家模型", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_allowrandomskinsandbodygroups", 0, true, false, false, "如果 Lambda Player 使用的玩家模型有皮肤或者身体组件，则会随机选择皮肤和身体组件", 0, 1, { type = "Bool", name = "随机皮肤与身体组件", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_voiceprofileusechance", 0, true, false, false, "Lambda Player 使用随机语音配置文件(Voice Profile)的概率，至少需要有一个可用的语音配置文件才能生效，设置为0表示禁用该功能", 0, 100, { type = "Slider", decimals = 0, name = "语音文件使用概率", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_textprofileusechance", 0, true, false, false, "Lambda Player 使用随机聊天配置文件(Text Profile)的概率，至少需要有一个可用的聊天配置文件才能生效，设置为0表示禁用该功能", 0, 100, { type = "Slider", decimals = 0, name = "聊天文件使用概率", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_profileusechance", 0, true, false, false, "使用你自定义的人物配置文件生成 Lambda Player 的几率，随机选择不重复的配置文件使用。(在Panels选项卡中可编辑自定义人物配置)", 0, 100, { type = "Slider", decimals = 0, name = "人物配置使用概率", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_realisticfalldamage", 0, true, false, false, "Lambda Player 应该受到真实的摔落伤害", 0, 1, { type = "Bool", name = "真实摔落伤害", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_respawntime", 2, true, false, false, "Lambda Player 在多少秒后复活", 0.1, 30, { type = "Slider", decimals = 1, name = "重生时间", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_respawnatplayerspawns", 0, true, false, false, "Lambda Player 在玩家出生点复活", 0, 1, { type = "Bool", name = "在玩家出生点重生", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_dontrespawnifspeaking", 0, true, false, false, "如果 Lambda Player 在复活倒计时结束后仍在进行语音行为，则应该等到语音行为结束后再复活", 0, 1, { type = "Bool", name = "语音结束后复活", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_obeynavmeshattributes", 0, true, false, false, "Lambda Player 应该遵从导航网(Navmesh)的属性，例如：回避，行走，奔跑，跳跃，蹲下", 0, 1, { type = "Bool", name = "遵从导航网", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_overridegamemodehooks", 1, true, false, false, "允许插件重写游戏钩子(Hooks) 以监听更多事件，例如：GM:PlayerDeath()、GM:PlayerStartVoice()、GM:PlayerEndVoice()、GM:OnNPCKilled()、GM:CreateEntityRagdoll() 等事件，并且能将 Lambda Player 显示在游戏计分板上(Scoreboard)。修改后需要重启服务器/游戏", 0, 1, { type = "Bool", name = "重写游戏钩子", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_callonnpckilledhook", 0, true, false, false, "Lambda Player 死亡时会调用OnNPCKilled事件。需要开启\"重写游戏钩子\"选项", 0, 1, { type = "Bool", name = "死后调用OnNPCKilled事件", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_singleplayerthinkdelay", 0, true, false, false, "Lambda Player 的思考延迟(插件作者推荐设置为0.1)。以 Lambda Player 的延迟为代价提高性能。\n只适用于单人游戏，多人游戏会自动调整思考延迟", 0, 0.24, { type = "Slider", decimals = 2, name = "思考延迟", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_noplycollisions", 0, true, false, false, "Lambda Player 可以无视碰撞直接穿过玩家", 0, 1, { type = "Bool", name = "禁用玩家碰撞", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_panicanimations", 0, true, false, false, "恐慌状态下的 Lambda Player 应该使用恐慌动画", 0, 1, { type = "Bool", name = "使用恐慌动画", category = "Lambda Server Settings" } )
CreateLambdaConvar( "lambdaplayers_lambda_physupdatetime", 0.5, true, false, false, "Lambda Player 更新物理对象的时间。如果物体与 Lambda Player 之间的碰撞出现问题，则降低该选项的值", 0, 1, { type = "Slider", decimals = 2, name = "物理更新时间", category = "Lambda Server Settings" } )
--

-- Combat Convars 
CreateLambdaConvar( "lambdaplayers_combat_allowtargetyou", 1, true, true, true, "允许 Lambda Player 将你作为攻击目标", 0, 1, { type = "Bool", name = "允许被攻击", category = "Combat" } )
CreateLambdaConvar( "lambdaplayers_combat_retreatonlowhealth", 1, true, false, false, "Lambda Player 在低血量时会尝试逃跑，这也会使他们在看见 RDM 时会尝试逃离", 0, 1, { type = "Bool", name = "低血量逃跑", category = "Combat" } )
CreateLambdaConvar( "lambdaplayers_combat_spawnbehavior", 0, true, false, false, "Lambda Player 在生成后的行为。0 - 无, 1 - 攻击你, 2 - 随机", 0 , 2, { type = "Slider", decimals = 0, name = "修改生成后行为", category = "Combat" } )
CreateLambdaConvar( "lambdaplayers_combat_spawnmedkits", 1, true, false, false, "允许 Lambda Player 在低血量时生成医疗包治疗自己。需要允许 Lambda Player 生成实体", 0 , 1, { type = "Bool", name = "生成医疗包", category = "Combat" } )
CreateLambdaConvar( "lambdaplayers_combat_spawnbatteries", 1, true, false, false, "允许 Lambda Player 在低护甲值时生成护甲电池来补充护甲。需要允许 Lambda Player 生成实体", 0 , 1, { type = "Bool", name = "生成护甲电池", category = "Combat" } )
CreateLambdaConvar( "lambdaplayers_combat_weapondmgmultiplier", 1, true, false, false, "调整 Lambda Player 的武器伤害倍率", 0, 5, { type = "Slider", decimals = 2, name = "武器伤害倍率", category = "Lambda Weapons" } )
--

-- Lambda Player Convars
CreateLambdaConvar( "lambdaplayers_lambda_shouldrespawn", 0, true, true, true, "允许 Lambda Player 在死亡后复活。注意：这只对之后生成的 Lambda Player 起效", 0, 1, { type = "Bool", name = "Lambda Player 可重生", category = "Lambda Player Settings" } )
---- lambdaplayers_lambda_voiceprofile Located in shared/voiceprofiles.lua
---- lambdaplayers_lambda_spawnweapon  Located in shared/globals.lua due to code order
--

-- Building Convars
CreateLambdaConvar( "lambdaplayers_building_caneditworld", 1, true, false, false, "允许 Lambda Player 使用物理枪与工具枪编辑地图物体", 0, 1, { type = "Bool", name = "允许编辑地图物体", category = "Building" } )
CreateLambdaConvar( "lambdaplayers_building_caneditnonworld", 1, true, false, false, "允许 Lambda Player 使用物理枪与工具枪编辑非地图物体，例如：玩家生成的实体与插件生成的实体", 0, 1, { type = "Bool", name = "允许编辑非地图物体", category = "Building" } )
CreateLambdaConvar( "lambdaplayers_building_canedityourents", 1, true, true, true, "允许 Lambda Player 使用物理枪与工具枪编辑你生成的道具与实体", 0, 1, { type = "Bool", name = "允许编辑你的物体", category = "Building" } )
CreateLambdaConvar( "lambdaplayers_lambda_allowphysgunpickup", 1, true, false, false, "允许 Lambda Player 使用物理枪移动物品", 0, 1, { type = "Bool", name = "允许使用物理枪", category = "Building" } )
CreateLambdaConvar( "lambdaplayers_building_freezeprops", 0, true, false, false, "Lambda Player 生成的道具应具有以下效果中的任意一种：生成后立即冻结、生成10秒后被冻结。这能改善游戏性能", 0, 1, { type = "Bool", name = "冻结道具", category = "Building" } )
CreateLambdaConvar( "lambdaplayers_building_alwaysfreezelargeprops", 0, true, false, false, "Lambda Player 生成的大型道具总是立即被冻结。这能改善游戏性能", 0, 1, { type = "Bool", name = "冻结大型道具", category = "Building" } )
CreateLambdaConvar( "lambdaplayers_building_cleanupondeath", 0, true, false, false, "由可重生的 Lambda Player 生成的实体将在他们死后被清理\n(非可重生的 Lambda Player 生成的实体将在他们死后自动清理)", 0, 1, { type = "Bool", name = "死后清理实体", category = "Building" } )
--

-- Voice Related Convars
CreateLambdaConvar( "lambdaplayers_voice_globalvoice", 0, true, true, false, "Lambda Player 的语音能在地图的任何地方被听到", 0, 1, { type = "Bool", name = "全图语音", category = "Voice Options" } )
CreateLambdaConvar( "lambdaplayers_voice_voicepopups", 1, true, true, false, "Lambda Player 进行语音时绘制语音弹窗", 0, 1, { type = "Bool", name = "绘制语音弹窗", category = "Voice Options" } )
CreateLambdaConvar( "lambdaplayers_voice_usegmodvoicepopups", 0, true, false, false, "Lambda Player 的应该使用游戏的语音弹窗系统而不是插件的弹窗系统，需要开启\"重写游戏钩子\"选项(在LambdaServerSettings选项卡中)。从 Lambda Player 的下一条语音开始生效", 0, 1, { type = "Bool", name = "使用游戏的语音弹窗", category = "Voice Options" } )
CreateLambdaConvar( "lambdaplayers_voice_talklimit", 0, true, true, false, "可以同时进行语音的 Lambda Player 的数量限制。设为0表示不限制", 0, 20, { type = "Slider", decimals = 0, name = "语音限制", category = "Voice Options" } )
CreateLambdaConvar( "lambdaplayers_voice_voicevolume", 1, true, true, false, "Lambda Player 的语音音量", 0, 10, { type = "Slider", name = "语音音量", decimals = 2, category = "Voice Options" } )
CreateLambdaConvar( "lambdaplayers_voice_voicepopupxpos", 278, true, true, false, "语音弹窗在屏幕X轴的位置", 0, ( CLIENT and ScrW() or 1 ), { type = "Slider", decimals = 0, name = "语音弹窗X轴位置", category = "Voice Options" } )
CreateLambdaConvar( "lambdaplayers_voice_voicepopupypos", 150, true, true, false, "语音弹窗在屏幕Y轴的位置", 0, ( CLIENT and ScrH() or 1 ), { type = "Slider", decimals = 0, name = "语音弹窗Y轴位置", category = "Voice Options" } )
CreateLambdaConvar( "lambdaplayers_voice_voicepitchmax", 100, true, false, false, "Lambda Player 的最高音调", 100, 255, { type = "Slider", decimals = 0, name = "最高音调", category = "Voice Options" } )
CreateLambdaConvar( "lambdaplayers_voice_voicepitchmin", 100, true, false, false, "Lambda Player 的最低音调", 10, 100, { type = "Slider", decimals = 0, name = "最低音调", category = "Voice Options" } )
CreateLambdaConvar( "lambdaplayers_voice_mergeaddonvoicelines", 1, true, false, false, "是否使用其他插件提供的语音。修改后需要更新Lambda数据", 0, 1, { type = "Bool", name = "使用附加语音", category = "Voice Options" } )
CreateLambdaConvar( "lambdaplayers_voice_alwaysplaydeathsnds", 0, true, false, false, "Lambda Player 在死亡时总是播放死亡语音，而不是根据他们各自的语音几率来决定是否播放。这个选项不会覆盖他们的死亡台词(Death Text Lines)", 0, 1, { type = "Bool", name = "总是播放死亡语音", category = "Voice Options" } )
--

-- Text Chat Convars --
CreateLambdaConvar( "lambdaplayers_text_enabled", 1, true, false, false, "允许 Lambda Player 使用文字聊天与其他 Lambda Player 交流", 0, 1, { type = "Bool", name = "启用文字聊天", category = "Text Chat Options" } )
CreateLambdaConvar( "lambdaplayers_text_usedefaultlines", 1, true, false, false, "Lambda Player 可以使用默认的聊天文本(Text Chat)。如果只需要自定义的聊天文本，则应该禁用此选项。修改后需要更新Lambda数据", 0, 1, { type = "Bool", name = "使用默认聊天文本", category = "Text Chat Options" } )
CreateLambdaConvar( "lambdaplayers_text_useaddonlines", 1, true, false, false, "Lambda Player 可以使用其他插件提供的聊天文本(Text Chat)。修改后需要更新Lambda数据", 0, 1, { type = "Bool", name = "使用插件提供的聊天文本", category = "Text Chat Options" } )
CreateLambdaConvar( "lambdaplayers_text_chatlimit", 1, true, false, false, "可以同时发送聊天消息的 Lambda Player 的数量限制。设为0表示不限制", 0, 60, { type = "Slider", decimals = 0, name = "聊天限制", category = "Text Chat Options" } )
CreateLambdaConvar( "lambdaplayers_text_markovgenerate", 0, true, false, false, "使用马尔可夫链(Markov Chain)来生成随机文本台词(Text Lines)", 0, 1, { type = "Bool", name = "使用马尔可夫链", category = "Text Chat Options" } )
--

-- Force Related Convars
CreateLambdaConvar( "lambdaplayers_force_radius", 750, true, false, false, "Force Menu 选项的影响范围", 250, 25000, { type = "Slider", name = "影响范围", decimals = 0, category = "Force Menu" } )
CreateLambdaConvar( "lambdaplayers_force_spawnradiusply", 3000, true, false, false, "Lambda Player 在玩家周围一定范围内生成。设为0禁用", 0, 25000, { type = "Slider", name = "生成范围", decimals = 0, category = "Force Menu" } )
CreateLambdaConvar( "lambdaplayers_lambda_spawnatplayerspawns", 0, true, false, false, "Lambda Player 在玩家出生点生成", 0, 1, { type = "Bool", name = "玩家出生点生成", category = "Force Menu" } )
--

-- DEBUGGING CONVARS. Server-side only
CreateLambdaConvar( "lambdaplayers_debug", 0, false, false, false, "启用 Debug 特性", 0, 1, { type = "Bool", name = "启用 Debug", category = "Debugging" } )
CreateLambdaConvar( "lambdaplayers_debughelper_drawscale", 0.1, true, true, false, "Debug Helper 的缩放大小", 0, 1, { type = "Slider", decimals = 2, name = "Debug Helper 缩放", category = "Debugging" } )
CreateLambdaConvar( "lambdaplayers_debug_path", 0, false, false, false, "绘制 Lambda Player 当前的移动路径", 0, 1, { type = "Bool", name = "启用路径绘制", category = "Debugging" } )
CreateLambdaConvar( "lambdaplayers_debug_eyetracing", 0, false, false, false, "绘制 Lambda Player 的视线朝向。需要启用开发者模式", 0, 1, { type = "Bool", name = "启用视线追踪", category = "Debugging" } )
AddSourceConVarToSettings( "developer", "启用开发者模式(Source's Developer mode)", { type = "Bool", name = "开发者模式", category = "Debugging" } )
--

-- Note, Weapon allowing convars are located in the shared/globals.lua
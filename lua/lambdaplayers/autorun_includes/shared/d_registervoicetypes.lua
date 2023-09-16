local table_insert = table.insert

LambdaValidVoiceTypes = {}

-- This allows the creation of new voice types

-- voicetypename    | String |  The name of the voice type. Should be lowercare letters only
-- defaultpath  | String |  The default directory for this voice type
-- voicetypedescription     | String |  The description of when this voice type is typically used
function LambdaRegisterVoiceType( voicetypename, defaultpath, voicetypedescription )
    local voiceTypeTransMap = {
        ["idle"] = "闲逛",
        ["taunt"] = "挑衅",
        ["death"] = "死亡",
        ["kill"] = "击杀",
        ["laugh"] = "嘲笑",
        ["fall"] = "摔落",
        ["assist"] = "助攻",
        ["witness"] = "目击",
        ["panic"] = "恐慌"
    }
    local typeTransVal = voiceTypeTransMap[voicetypename] or voicetypename
    CreateLambdaConvar( "lambdaplayers_voice_" .. voicetypename .. "dir", defaultpath, true, false, false, "存放" .. typeTransVal .. "语音的文件夹，修改后需要更新Lambda数据\n" .. voicetypedescription, nil, nil, { type = "Text", name = typeTransVal .. "语音文件夹", category = "Voice Options" } )
    table_insert( LambdaValidVoiceTypes, { voicetypename, "lambdaplayers_voice_" .. voicetypename .. "dir" } )
end

LambdaRegisterVoiceType( "idle", "lambdaplayers/vo/idle", "Lambda Player 闲逛时的语音，这个类型的语音也会随机出现在其他语音场景" )
LambdaRegisterVoiceType( "taunt", "lambdaplayers/vo/taunt", "Lambda Player 即将进行攻击时的语音" )
LambdaRegisterVoiceType( "death", "lambdaplayers/vo/death", "Lambda Player 死亡时的语音" )
LambdaRegisterVoiceType( "kill", "lambdaplayers/vo/kill", "Lambda Player 杀死敌人时的语音" )
LambdaRegisterVoiceType( "laugh", "lambdaplayers/vo/laugh", "Lambda Player 嘲笑其他人时的语音" )
LambdaRegisterVoiceType( "fall", "lambdaplayers/vo/fall", "Lambda Player 从可以将他们摔死的高度开始跌落时的语音" )
LambdaRegisterVoiceType( "assist", "lambdaplayers/vo/assist", "Lambda Player 的敌人被其他人杀死时的语音" )
LambdaRegisterVoiceType( "witness", "lambdaplayers/vo/witness", "Lambda Player 看见有人被杀死时的语音" )
LambdaRegisterVoiceType( "panic", "lambdaplayers/vo/panic", "Lambda Player 血量较低并开始逃跑时的语音" )
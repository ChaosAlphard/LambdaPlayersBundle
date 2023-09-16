--- Include files in the corresponding folders
-- Autorun files are seperated in folders unlike the ENT include lua files



-- Base Addon includes --

function LambdaReloadAddon( ply )

    if SERVER and IsValid( ply ) then 
        if !ply:IsSuperAdmin() then return end -- No lol
        PrintMessage( HUD_PRINTTALK, "服务器正在重载 Lua 文件/SERVER is reloading all Lambda Lua files.." )
    end

    if SERVER then

        local serversidefiles = file.Find( "lambdaplayers/autorun_includes/server/*", "LUA", "nameasc" )

        for k, luafile in ipairs( serversidefiles ) do
            include( "lambdaplayers/autorun_includes/server/" .. luafile )
            print( "Lambda Players: 已载入服务端 Lua 文件/Included Server Side Lua File [ " .. luafile .. " ]" )
        end

    end

    print("\n")

    local sharedfiles = file.Find( "lambdaplayers/autorun_includes/shared/*", "LUA", "nameasc" )

    for k, luafile in ipairs( sharedfiles ) do
        if SERVER then
            AddCSLuaFile( "lambdaplayers/autorun_includes/shared/" .. luafile )
        end
        include( "lambdaplayers/autorun_includes/shared/" .. luafile )
        print( "Lambda Players: 已载入共享 Lua 文件/Included Shared Lua File [ " .. luafile .. " ]" )
    end

    print("\n")


    local clientsidefiles = file.Find( "lambdaplayers/autorun_includes/client/*", "LUA", "nameasc" )

    for k, luafile in ipairs( clientsidefiles ) do
        if SERVER then
            AddCSLuaFile( "lambdaplayers/autorun_includes/client/" .. luafile )
        elseif CLIENT then
            include( "lambdaplayers/autorun_includes/client/" .. luafile )
            print( "Lambda Players: 已载入客户端 Lua 文件/Included Client Side Lua File [ " .. luafile .. " ]" )
        end
    end
    --

    print( "Lambda Players: 准备加载外部 Lua 文件/Preparing to load External Addon Lua Files.." )

    -- External Addon Includes --
    if SERVER then

        local serversidefiles = file.Find( "lambdaplayers/extaddon/server/*", "LUA", "nameasc" )

        for k, luafile in ipairs( serversidefiles ) do
            include( "lambdaplayers/extaddon/server/" .. luafile )
            print( "Lambda Players: 已载入服务端外部 Lua 文件/Included Server Side External Lua File [ " .. luafile .. " ]" )
        end

    end

    print("\n")

    local sharedfiles = file.Find( "lambdaplayers/extaddon/shared/*", "LUA", "nameasc" )

    for k, luafile in ipairs( sharedfiles ) do
        if SERVER then
            AddCSLuaFile( "lambdaplayers/extaddon/shared/" .. luafile )
        end
        include( "lambdaplayers/extaddon/shared/" .. luafile )
        print( "Lambda Players: 已载入共享外部 Lua 文件/Included Shared External Lua File [ " .. luafile .. " ]" )
    end

    print("\n")


    local clientsidefiles = file.Find( "lambdaplayers/extaddon/client/*", "LUA", "nameasc" )

    for k, luafile in ipairs( clientsidefiles ) do
        if SERVER then
            AddCSLuaFile( "lambdaplayers/extaddon/client/" .. luafile )
        elseif CLIENT then
            include( "lambdaplayers/extaddon/client/" .. luafile )
            print( "Lambda Players: 已载入客户端外部 Lua 文件/Included Client Side External Lua File [ " .. luafile .. " ]" )
        end
    end

    print( "Lambda Players: 所有文件加载完毕 / Loaded all External Addon Lua Files!")
    hook.Run( "LambdaOnModulesLoaded" )
    --

    if SERVER and IsValid( ply ) then 
        PrintMessage( HUD_PRINTTALK, "服务器已经重载所有 Lua 文件 / SERVER has reloaded all Lambda Lua files" )
    end

    if SERVER and LambdaHasFirstInit then
        net.Start( "lambdaplayers_reloadaddon" )
        net.Broadcast()
    end


    LambdaHasFirstInit = true
end
---

LambdaReloadAddon()


-- Initialize these globals --
-- These will be run after external addon lua files have been run so it is ensured anything they add is included here
LambdaPersonalProfiles = LambdaPersonalProfiles or file.Exists( "lambdaplayers/profiles.json", "DATA" ) and LAMBDAFS:ReadFile( "lambdaplayers/profiles.json", "json" ) or nil
LambdaPlayerNames = LambdaPlayerNames or LAMBDAFS:GetNameTable()
LambdaPlayerProps = LambdaPlayerProps or LAMBDAFS:GetPropTable()
LambdaPlayerMaterials = LambdaPlayerMaterials or LAMBDAFS:GetMaterialTable()
Lambdaprofilepictures = Lambdaprofilepictures or LAMBDAFS:GetProfilePictures()
LambdaVoiceLinesTable = LambdaVoiceLinesTable or LAMBDAFS:GetVoiceLinesTable()
LambdaVoiceProfiles = LambdaVoiceProfiles or LAMBDAFS:GetVoiceProfiles()
LambdaPlayerSprays = LambdaPlayerSprays or LAMBDAFS:GetSprays()
LambdaTextTable = LambdaTextTable or LAMBDAFS:GetTextTable()
LambdaTextProfiles = LambdaTextProfiles or LAMBDAFS:GetTextProfiles()
LambdaModelVoiceProfiles = LambdaModelVoiceProfiles or LAMBDAFS:GetModelVoiceProfiles()
--

-- Voice Profiles --
-- Had to move these here for code order reason
local combotable = {}

for k, v in pairs( LambdaVoiceProfiles ) do
    combotable[ k ] = k
end
combotable[ "None" ] = "" 

CreateLambdaConvar( "lambdaplayers_lambda_voiceprofile", "", true, true, true, "设置新生成的 LambdaPlayer 所使用的语音配置文件(VoiceProfile)。注意：需要服务器拥有对应的语音配置文件才会生效", 0, 1, { type = "Combo", options = combotable, name = "Voice Profile", category = "Lambda Player Settings" } )
--

-- Text Profiles --
combotable = {}

for k, v in pairs( LambdaTextProfiles ) do
    combotable[ k ] = k
end
combotable[ "None" ] = "" 

CreateLambdaConvar( "lambdaplayers_lambda_textprofile", "", true, true, true, "设置新生成的 LambdaPlayer 所使用的聊天配置文件(TextProfile)。注意：需要服务器拥有对应的聊天配置文件才会生效", 0, 1, { type = "Combo", options = combotable, name = "Text Profile", category = "Lambda Player Settings" } )
--

-- This will reload the Lambda addon ingame without having to resave this lua file and trigger a lua refresh
concommand.Add( "lambdaplayers_dev_reloadaddon", LambdaReloadAddon )
local table_insert = table.insert
local ents_GetAll = ents.GetAll
local ents_FindInSphere = ents.FindInSphere
local ipairs = ipairs
local random = math.random
local IsValid = IsValid
local distance = GetConVar( "lambdaplayers_force_radius" )
local spawnatplayerpoints = GetConVar( "lambdaplayers_lambda_spawnatplayerspawns" )
local plyradius = GetConVar( "lambdaplayers_force_spawnradiusply" )

-- The reason this lua file has a d_ in its filename is because of the order on how lua files are loaded.
-- If we didn't do this, we wouldn't have _LAMBDAConVarSettings 
-- are ya learnin son?

-- settingstbl is just about the same as the convar's settingstbl
function CreateLambdaConsoleCommand( name, func, isclient, helptext, settingstbl )
    
    if isclient and SERVER then return end

    if isclient then
        concommand.Add( name, func, nil, helptext )
    elseif !isclient and SERVER then
        concommand.Add( name, func, nil, helptext )
    end

    if CLIENT and settingstbl and !_LAMBDAConVarNames[ name ] then
        settingstbl.concmd = name
        settingstbl.isclient = isclient
        settingstbl.type = "Button"
        settingstbl.desc = ( isclient and "[客户端]" or "[服务端]" ) .. helptext .. "\n控制台指令：" .. name
        
        _LAMBDAConVarNames[ name ] = true
        table_insert( _LAMBDAConVarSettings, settingstbl )
    end

end

function AddConsoleCommandToLambdaSettings( cmd, isclient, helptext, settingstbl )
    if SERVER or _LAMBDAConVarNames[ cmd ] then return end
    settingstbl.concmd = cmd
    settingstbl.isclient = isclient
    settingstbl.type = "Button"
    settingstbl.desc = ( isclient and "[客户端]" or "[服务端]" ) .. helptext .. "\n控制台指令：" .. cmd

    _LAMBDAConVarNames[ cmd ] = true
    table_insert( _LAMBDAConVarSettings, settingstbl )
end

local cooldown = 0

CreateLambdaConsoleCommand( "lambdaplayers_cmd_updatedata", function( ply ) 
    if IsValid( ply ) and !ply:IsSuperAdmin() then return end
    if CurTime() < cooldown then LambdaPlayers_Notify( ply, "指令冷却中，等待3秒后再试", 1, "buttons/button10.wav" ) return end
    print( "Lambda Players: 通过控制台指令更新数据. Ran by ", ( IsValid( ply ) and ply:Name() .. " | " .. ply:SteamID() or "Console" )  )

    LambdaPlayerNames = LAMBDAFS:GetNameTable()
    LambdaPlayerProps = LAMBDAFS:GetPropTable()
    LambdaPlayerMaterials = LAMBDAFS:GetMaterialTable()
    Lambdaprofilepictures = LAMBDAFS:GetProfilePictures()
    LambdaVoiceLinesTable = LAMBDAFS:GetVoiceLinesTable()
    LambdaVoiceProfiles = LAMBDAFS:GetVoiceProfiles()
    LambdaPlayerSprays = LAMBDAFS:GetSprays()
    LambdaTextTable = LAMBDAFS:GetTextTable()
    LambdaTextProfiles = LAMBDAFS:GetTextProfiles()
    LambdaModelVoiceProfiles = LAMBDAFS:GetModelVoiceProfiles()
    LambdaPersonalProfiles = file.Exists( "lambdaplayers/profiles.json", "DATA" ) and LAMBDAFS:ReadFile( "lambdaplayers/profiles.json", "json" ) or nil
    LambdaUpdatePlayerModels()

    LambdaPlayers_Notify( ply, "已更新 Lambda 数据", 3, "buttons/button15.wav" )

    net.Start( "lambdaplayers_updatedata" )
    net.Broadcast()

    cooldown = CurTime() + 3

    LambdaRunHook( "LambdaOnDataUpdate" )

end, false, "更新名称、道具等数据。在对自定义内容进行更改后，必须使用此选项才能使更改生效", { name = "更新数据", category = "Utilities" } )

CreateLambdaConsoleCommand( "lambdaplayers_cmd_cleanupclientsideents", function( ply ) 

    for k, v in ipairs( _LAMBDAPLAYERS_ClientSideEnts ) do
        if IsValid( v ) then v:Remove() end
    end

    surface.PlaySound( "buttons/button15.wav" )
    notification.AddLegacy( "已清理客户端实体", 4, 3 )

end, true, "清理客户端实体，例如布娃娃和掉落的武器", { name = "清理客户端实体", category = "Utilities" } )

CreateLambdaConsoleCommand( "lambdaplayers_cmd_cleanuplambdaents", function( ply ) 
    if IsValid( ply ) and !ply:IsAdmin() then return end

    for k, v in ipairs( ents_GetAll() ) do
        if IsValid( v ) and v.IsLambdaSpawned then v:Remove() end
    end

    LambdaPlayers_Notify( ply, "已清理所有 Lambda 实体", 4, "buttons/button15.wav" )
end, false, "清理 Lambda Players 产生的所有实体", { name = "清理 Lambda 实体", category = "Utilities" } )

AddConsoleCommandToLambdaSettings( "r_cleardecals", true, "清理你在地图上的所有标记，这不会移除地图预制的标记", { name = "Clean Decals", category = "Utilities" } )

CreateLambdaConsoleCommand( "lambdaplayers_cmd_cacheplayermodels", function( ply )
    if IsValid( ply ) and !ply:IsAdmin() then return end

    for k,v in pairs(player_manager.AllValidModels()) do util.PrecacheModel(v) end
    LambdaPlayers_Notify( ply, "Playermodels cached!", 0, "plats/elevbell1.wav" )
end, false, "警告：这将会使游戏进入假死状态！时间根据你安装的玩家模型(PlayerModel)数量决定", { name = "缓存玩家模型", category = "Utilities" } )

CreateLambdaConsoleCommand( "lambdaplayers_cmd_forcespawnlambda", function( ply ) 
	if IsValid( ply ) and !ply:IsSuperAdmin() then return end
    if !navmesh.IsLoaded() then return end

    local function GetRandomNavmesh()
        local FindAllNavMesh_NearPly = navmesh.Find( ply:GetPos(), plyradius:GetInt(), 30, 50 )
        local NavMesh_NearPly = FindAllNavMesh_NearPly[ random( #FindAllNavMesh_NearPly ) ]

        local FindAllNavMesh_Random = navmesh.Find( ply:GetPos(), random( 250, 99999 ), 30, 50 )
        local NavMesh_Random = FindAllNavMesh_Random[ random( #FindAllNavMesh_Random ) ]
        
        -- Once we got all nearby NavMesh areas near the player, pick out a random
        -- navmesh spot to spawn around with the set radius.
        -- BUG: it doesn't get different heights, unless our player is on that level
        if plyradius:GetInt() > 1 then
            for k, v in ipairs( FindAllNavMesh_NearPly ) do
                if IsValid( v ) and v:GetSizeX() > 35 and v:GetSizeY() > 35 then -- We don't want to spawn them in smaller nav areas, or water.
                    return NavMesh_NearPly:GetRandomPoint() -- We found a suitable location, spawn it!
                end
            end
        else -- If the radius is 0, find a random navmesh around the player at any range
            for k, v in ipairs( FindAllNavMesh_Random ) do
                if IsValid( v ) and v:GetSizeX() > 35 and v:GetSizeY() > 35 then
                    return NavMesh_Random:GetRandomPoint()
                end
            end
        end
    end

    local pos
    local ang
    local spawns

    -- Spawning at player spawn points
    if spawnatplayerpoints:GetBool() then
		spawns = LambdaGetPossibleSpawns()
		local spawn = spawns[ random( #spawns ) ]
        
        pos = spawn:GetPos()
        ang = Angle( 0, random( -180, 180 ), 0 )
    else -- We spawn at a random navmesh
        pos = GetRandomNavmesh()
        ang = Angle( 0, random( -180, 180 ), 0 )
    end


	local lambda = ents.Create( "npc_lambdaplayer" )
	lambda:SetPos( pos )
	lambda:SetAngles( ang )
	lambda:Spawn()

    lambda.l_SpawnWeapon = ply:GetInfo( "lambdaplayers_lambda_spawnweapon" )
    lambda:SwitchToSpawnWeapon()

	undo.Create( "Lambda Player ( " .. lambda:GetLambdaName() .. " )" )
		undo.SetPlayer( ply )
		undo.SetCustomUndoText( "Undone " .. "Lambda Player ( " .. lambda:GetLambdaName() .. " )" )
		undo.AddEntity( lambda )
	undo.Finish( "Lambda Player ( " .. lambda:GetLambdaName() .. " )" )

	local dynLight = ents.Create( "light_dynamic" )
	dynLight:SetKeyValue( "brightness", "2" )
	dynLight:SetKeyValue( "distance", "90" )
	dynLight:SetPos( lambda:GetPos() )
	dynLight:SetLocalAngles( lambda:GetAngles() )
	dynLight:Fire( "Color", "255 145 0" )
	dynLight:Spawn()
	dynLight:Activate()
	dynLight:Fire( "TurnOn", "", 0 )
	dynLight:Fire( "Kill", "", 0.75 )

end, false, "在随机区域生成一个 Lambda Player", { name = "生成 Lambda Player", category = "Force Menu" } )

CreateLambdaConsoleCommand( "lambdaplayers_cmd_forcecombat", function( ply ) 
    if IsValid( ply ) and !ply:IsSuperAdmin() then return end

    for k, v in ipairs( ents_FindInSphere( ply:GetPos(), distance:GetInt() ) ) do
        if IsValid( v ) and v.IsLambdaPlayer then v:AttackTarget( ply ) end
    end

end, false, "强制所有 Lambda Player 攻击你", { name = "Lambda Players 攻击你", category = "Force Menu" } )

CreateLambdaConsoleCommand( "lambdaplayers_cmd_forcecombatlambda", function( ply ) 
    if IsValid( ply ) and !ply:IsSuperAdmin() then return end

    for k, v in ipairs( ents_FindInSphere( ply:GetPos(), distance:GetInt() ) ) do
        if IsValid( v ) and v.IsLambdaPlayer then
			local npcs = v:FindInSphere( nil, 25000, function( ent ) return ( ent:IsNPC() or ent:IsNextBot() ) end )
			v:AttackTarget( npcs[ random( #npcs ) ] )
		end
    end

end, false, "强制所有 Lambda Player 攻击他们看到的任何东西", { name = "Lambda Players 攻击所有东西", category = "Force Menu" } )

CreateLambdaConsoleCommand( "lambdaplayers_cmd_forcekill", function( ply ) 
    if IsValid( ply ) and !ply:IsSuperAdmin() then return end

    for k, v in ipairs( ents_FindInSphere( ply:GetPos(), distance:GetInt() ) ) do
        if v.IsLambdaPlayer then
            local dmginfo = DamageInfo()
            dmginfo:SetDamage( 1000 )
            dmginfo:SetDamageForce( v:GetForward()*2000 or v:GetForward()*500 )
            dmginfo:SetAttacker( v )
            dmginfo:SetInflictor( v )
            v:TakeDamageInfo( dmginfo )
        end
    end

end, false, "杀死半径范围内的所有 Lambda Player", { name = "杀死附近的 Lambda Players", category = "Force Menu" } )

CreateLambdaConsoleCommand( "lambdaplayers_cmd_forcepanic", function( ply ) 
    if IsValid( ply ) and !ply:IsSuperAdmin() then return end

    for k, v in ipairs( ents_FindInSphere( ply:GetPos(), distance:GetInt() ) ) do
        if v.IsLambdaPlayer then
            v:RetreatFrom( ply )
        end
    end

end, false, "使半径范围内的所有 Lambda Player 陷入恐慌", { name = "使附近的 Lambda Players 恐慌", category = "Force Menu" } )

CreateLambdaConsoleCommand( "lambdaplayers_cmd_debugtogglegod", function( ply ) 
    if IsValid( ply ) and !ply:IsAdmin() then return end

    ply.l_godmode = !ply.l_godmode

    LambdaPlayers_ChatAdd( ply, ply.l_godmode and "进入上帝模式" or "退出上帝模式" )
end, false, "阻止你受到任何伤害", { name = "切换上帝模式", category = "Debugging" } )


if CLIENT then
    local r = GetConVar( "lambdaplayers_displaycolor_r" )
    local g = GetConVar( "lambdaplayers_displaycolor_g" )
    local b = GetConVar( "lambdaplayers_displaycolor_b" )

    _LambdaDisplayColor = Color( r:GetInt(), g:GetInt(), b:GetInt() )
end

CreateLambdaConsoleCommand( "lambdaplayers_cmd_updatedisplaycolor", function( ply ) 
    local r = GetConVar( "lambdaplayers_displaycolor_r" )
    local g = GetConVar( "lambdaplayers_displaycolor_g" )
    local b = GetConVar( "lambdaplayers_displaycolor_b" )

    _LambdaDisplayColor = Color( r:GetInt(), g:GetInt(), b:GetInt() )

end, true, "应用对显示颜色(Display Color)所进行的更改", { name = "更新显示颜色", category = "Misc" } )

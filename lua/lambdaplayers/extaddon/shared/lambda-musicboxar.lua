
CreateLambdaConvar( "lambdaplayers_musicbox_dancechance", 10, true, false, false, "Lambda Player 在音乐盒附近跳舞的几率", 0, 100, { type = "Slider", decimals = 0, name = "跳舞几率", category = "Music Box" } )
CreateLambdaConvar( "lambdaplayers_musicbox_drawvisualizer", 1, true, true, false, "在音乐盒上方绘制圆形音频频谱", 0, 1, { type = "Bool", name = "音频可视化", category = "Music Box" } )
CreateLambdaConvar( "lambdaplayers_musicbox_drawvisualizerlight", 1, true, true, false, "绘制音频频谱时使音乐盒发光", 0, 1, { type = "Bool", name = "音乐盒发光", category = "Music Box" } )
CreateLambdaConvar( "lambdaplayers_musicbox_visualizerresolution", 100, true, true, false, "圆形音频频谱柱体的数量", 20, 200, { type = "Slider", decimals = 0, name = "音频可视化分辨率", category = "Music Box" } )
CreateLambdaConvar( "lambdaplayers_musicbox_samples", 5, true, true, false, "音频可视化的采样等级(插件作者推荐的值为5)", 0, 7, { type = "Slider", decimals = 0, name = "采样等级", category = "Music Box" } )
CreateLambdaConvar( "lambdaplayers_musicbox_shufflemusic", 1, true, true, true, "随机化音乐播放顺序", 0, 1, { type = "Bool", name = "随机播放", category = "Music Box" } )
CreateLambdaConvar( "lambdaplayers_musicbox_custommusiconly", 0, true, false, false, "仅播放自定义音乐", 0, 1, { type = "Bool", name = "仅自定义音乐", category = "Music Box" } )
CreateLambdaConvar( "lambdaplayers_musicbox_musicvolume", 1, true, true, false, "音乐盒的音量", 0, 10, { type = "Slider", decimals = 2, name = "音量", category = "Music Box" } )
CreateLambdaConvar( "lambdaplayers_musicbox_playonce", 0, true, false, false, "音乐盒在播放完一次后自动删除", 0, 1, { type = "Bool", name = "一次性音乐盒", category = "Music Box" } )
CreateLambdaConvar( "lambdaplayers_musicbox_clientsidemode", 0, true, true, true, "音乐盒使用客户端模式。注意：这只在多人游戏中生效，并且只有你能听到你播放的音乐", 0, 1, { type = "Bool", name = "客户端模式", category = "Music Box" } )


local VectorRand = VectorRand
local table_insert = table.insert

local function MusicBoxTool( self, ent )
    if !self:IsUnderLimit( "MusicBox" ) then return end
    
    local rand = VectorRand( -1000, 1000 )
    rand.z = -50
    local tr = self:Trace( self:WorldSpaceCenter() + rand  )
    local pos = tr.HitPos

    self:LookTo( pos, 2 )

    coroutine.wait( 1 )

    self:UseWeapon( pos )
    local SpawnPos = tr.HitPos + tr.HitNormal * 10
    local musicbox = ents.Create( "lambda_musicbox" )
    musicbox:SetPos( SpawnPos )
    musicbox:SetAngles( Angle( 0, self:GetAngles()[ 2 ], 0 ) )
    musicbox:SetSpawner( self )
    musicbox.LambdaOwner = self
    musicbox.IsLambdaSpawned = true
    musicbox:Spawn()
    self:ContributeEntToLimit( musicbox, "MusicBox" )
    table_insert( self.l_SpawnedEntities, 1, musicbox )
    return true
end

AddToolFunctionToLambdaTools( "MusicBox", MusicBoxTool )
CreateLambdaEntLimit( "MusicBox", 1, 10 )


local function nearmusicbox( self )
    local nearby = self:FindInSphere( nil, 1000, function( ent )
        return ent:GetClass() == "lambda_musicbox"
    end )
    return #nearby > 0
end
LambdaAddConditionalKeyWord( "|nearmusicbox|", nearmusicbox )


duplicator.RegisterEntityClass( "lambda_musicbox", function( ply, Pos, Ang, info )

	local musicbox = ents.Create( "lambda_musicbox" )
	musicbox:SetPos( Pos )
	musicbox:SetAngles( Ang )
    musicbox:SetSpawner( ply )
	musicbox:Spawn()
    timer.Simple( 0, function()
        if !IsValid( musicbox ) then return end
        musicbox:PlayMusic()
    end )

	return musicbox
end, "Pos", "Ang" )



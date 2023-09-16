
AddCSLuaFile()

if CLIENT then

TOOL.Information = {
    { name = "left" },
}


language.Add("tool.lambdaprofilespawner", "Lambda Profile Spawner")

language.Add("tool.lambdaprofilespawner.name", "LambdaPlayer生成工具")
language.Add("tool.lambdaprofilespawner.desc", "使用选择的人物配置生成LambdaPlayer" )
language.Add("tool.lambdaprofilespawner.left", "生成一个LambdaPlayer" )

end

TOOL.Tab = "Lambda Player"
TOOL.Category = "Tools"
TOOL.Name = "#tool.lambdaprofilespawner"
TOOL.ClientConVar = {
    [ "profilename" ] = "",
    [ "respawn" ] = "1"
}


local isempty = table.IsEmpty

function TOOL:LeftClick( tr )
    local owner = self:GetOwner()

    if SERVER and LambdaPersonalProfiles and !isempty( LambdaPersonalProfiles ) then
        local profileinfo = LambdaPersonalProfiles[ self:GetClientInfo( "profilename" ) ]

        if profileinfo then
            local lambda = ents.Create( "npc_lambdaplayer" )
            lambda:SetPos( tr.HitPos )
            lambda:SetAngles( Angle( 0, owner:EyeAngles().y, 0 ) )
            lambda:SetCreator( owner )
            lambda:Spawn()

            lambda:SetRespawn( self:GetClientNumber( "respawn", 0 ) == 1 )

            lambda:ApplyLambdaInfo( profileinfo )
            lambda:SimpleTimer( 0, function() LambdaRunHook( "LambdaOnProfileApplied", lambda, info ) end, true )
        else
            LambdaPlayers_ChatAdd( owner, self:GetClientInfo( "profilename" ) .. "'s profile data does not exist on the Server"  )
        end
    end


    return true
end

function TOOL.BuildCPanel( pnl )
    pnl:Help( "注意：这里列出的配置文件为当前客户端的本地文件，这意味着如果服务器没有对应的配置文件则不会生效")

    pnl:CheckBox( "重生", "lambdaprofilespawner_respawn" )
    pnl:ControlHelp( "是否允许生成工具生成的LambdaPlayer在死后复活" )

    local box = pnl:ComboBox( "人物名称", "lambdaprofilespawner_profilename" )

    if LambdaPersonalProfiles and !isempty( LambdaPersonalProfiles ) then
        for name, info in pairs( LambdaPersonalProfiles ) do
            box:AddChoice( name, name )
        end
    end

    pnl:ControlHelp( "要生成的LambdaPlayer的名称" )

    local update = vgui.Create( "DButton", pnl )
    update:SetText( "Update Profile List" )
    pnl:AddItem( update )

    function update:DoClick()
        box:Clear()

        if LambdaPersonalProfiles and !isempty( LambdaPersonalProfiles ) then
            for name, info in pairs( LambdaPersonalProfiles ) do
                box:AddChoice( name, name )
            end
        end
    end


end
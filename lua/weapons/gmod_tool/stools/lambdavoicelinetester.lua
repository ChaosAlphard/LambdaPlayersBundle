
AddCSLuaFile()

if CLIENT then

TOOL.Information = {
    { name = "left" },
    { name = "right" },
}


language.Add("tool.lambdavoicelinetester", "Voice Line Tester")

language.Add("tool.lambdavoicelinetester.name", "语音测试工具")
language.Add("tool.lambdavoicelinetester.desc", "强制LambdaPlayer播放语音" )
language.Add("tool.lambdavoicelinetester.left", "强制LambdaPlayer播放菜单中指定类型的语音" )
language.Add("tool.lambdavoicelinetester.right", "强制LambdaPlayer播放菜单中指定路径的语言文件" )

end

TOOL.Tab = "Lambda Player"
TOOL.Category = "Tools"
TOOL.Name = "#tool.lambdavoicelinetester"
TOOL.ClientConVar = {
    [ "voicetype" ] = "idle",
    [ "voicelinepath" ] = ""
}


function TOOL:LeftClick( tr )
    local ent = tr.Entity
    local owner = self:GetOwner()
    if !IsValid( ent ) or !ent.IsLambdaPlayer then return end

    if SERVER then
        ent:PlaySoundFile( ent:GetVoiceLine( self:GetClientInfo( "voicetype" ) ) )
    end

    return true
end


function TOOL:RightClick( tr )
    local ent = tr.Entity
    local owner = self:GetOwner()
    if !IsValid( ent ) or !ent.IsLambdaPlayer then return end

    if SERVER then
        ent:PlaySoundFile( self:GetClientInfo( "voicelinepath" ) )
    end

    return true
end

function TOOL.BuildCPanel( pnl )

    local box = pnl:ComboBox( "语音类型", "lambdavoicelinetester_voicetype" )

    for k, v in pairs( LambdaVoiceLinesTable ) do
        box:AddChoice( k, k )
    end

    pnl:ControlHelp( "使用工具左键点击时要播放的语音类型\nidle：闲逛时的语音\ntaunt：挑衅时的语音\ndeath：死亡时的语音\nkill：击杀时的语音\nlaugh：嘲笑时的语音\nfall：摔落时的语音\nassist：助攻时的语音\nwitness：目击其他LambdaPlayer被杀死时的语音\npanic：恐慌时的语音" )

    pnl:TextEntry( "语音文件路径", "lambdavoicelinetester_voicelinepath" )
    pnl:ControlHelp( "使用工具右键点击时要播放的语音文件的路径" )

end
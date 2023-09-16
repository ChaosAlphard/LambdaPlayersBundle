AddCSLuaFile()

if CLIENT then

TOOL.Information = {
    { name = "left" },
    { name = "right" },
}


language.Add("tool.lambdatexttester", "Text Line Tester")

language.Add("tool.lambdatexttester.name", "聊天文本测试工具")
language.Add("tool.lambdatexttester.desc", "强制LambdaPlayer在聊天框中发送信息" )
language.Add("tool.lambdatexttester.left", "强制LambdaPlayer发送菜单中指定类型的信息" )
language.Add("tool.lambdatexttester.right", "强制LambdaPlayer发送菜单中指定的单条信息" )

end

TOOL.Tab = "Lambda Player"
TOOL.Category = "Tools"
TOOL.Name = "#tool.lambdatexttester"
TOOL.ClientConVar = {
    [ "texttype" ] = "idle",
    [ "textline" ] = ""
}

local random = math.random

function TOOL:LeftClick( tr )
    local ent = tr.Entity
    local owner = self:GetOwner()
    if !IsValid( ent ) or !ent.IsLambdaPlayer then return end

    if SERVER then
        ent:TypeMessage( ent:GetTextLine( self:GetClientInfo( "texttype" ) ) )
    end

    return true
end


function TOOL:RightClick( tr )
    local ent = tr.Entity
    local owner = self:GetOwner()
    if !IsValid( ent ) or !ent.IsLambdaPlayer then return end

    if SERVER then
        ent:TypeMessage( self:GetClientInfo( "textline" ) )
    end

    return true
end

function TOOL.BuildCPanel( pnl )

    local box = pnl:ComboBox( "消息类型", "lambdatexttester_texttype" )

    for k, v in pairs( LambdaTextTable ) do
        box:AddChoice( k, k )
    end

    pnl:ControlHelp( "使用工具左键点击时要发送的消息类型\nidle：闲逛时的文本\nkill：LambdaPlayer杀死其他玩家或LambdaPlayer时的文本\ndeathbyplayer：LambdaPlayer被玩家或其他LambdaPlayer杀死时的文本\ndeath：LambdaPlayer因玩家或其他LambdaPlayer以外的因素死亡时的文本\nresponse：LambdaPlayer回应玩家或者其他LambdaPlayer的消息时的文本\nwitness：LambdaPlayer看见玩家或者其他LambdaPlayer死亡时的文本" )

    pnl:TextEntry( "消息文本", "lambdatexttester_textline" )
    pnl:ControlHelp( "使用工具右键点击时要发送的消息文本" )

end
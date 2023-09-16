
AddCSLuaFile()

if CLIENT then

TOOL.Information = {
    { name = "left" },
}


language.Add("tool.lambdaprofilecreator", "Lambda Profile Creator")

language.Add("tool.lambdaprofilecreator.name", "人物配置创建工具")
language.Add("tool.lambdaprofilecreator.desc", "快捷创建LambdaPlayer人物配置" )
language.Add("tool.lambdaprofilecreator.left", "以目标LambdaPlayer作为模板创建一个人物配置" )

end

TOOL.Tab = "Lambda Player"
TOOL.Category = "Tools"
TOOL.Name = "#tool.lambdaprofilecreator"


function TOOL:LeftClick( tr )
    local ent = tr.Entity
    local owner = self:GetOwner()
    if !IsValid( ent ) then return end
    if !ent.IsLambdaPlayer then return end

    if SERVER and owner:IsListenServerHost() then
        local info = ent:ExportLambdaInfo()
        LambdaPlayers_ChatAdd( owner, "Saved " .. info.name .. " to your profiles" )
        LAMBDAFS:UpdateKeyValueFile( "lambdaplayers/profiles.json", { [ info.name ] = info }, "json" )
    elseif CLIENT then
        local info = ent:ExportLambdaInfo()
        chat.AddText( "Saved " .. info.name .. " to your profiles" )
        LAMBDAFS:UpdateKeyValueFile( "lambdaplayers/profiles.json", { [ info.name ] = info }, "json" )
    end



    return true
end
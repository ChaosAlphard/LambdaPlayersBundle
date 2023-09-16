local round = math.Round
local months = {
    [ "一月" ] = "January",
    [ "二月"] =  "February",
    [ "三月" ] = "March",
    [ "四月" ] = "April",
    [ "五月" ] = "May",
    [ "六月" ] = "June",
    [ "七月" ] = "July",
    [ "八月" ] = "August",
    [ "九月" ] = "September",
    [ "十月" ] = "October",
    [ "十一月" ] = "November",
    [ "十二月" ] = "December"
}

local function OpenBirthdaypanel( ply )

    local frame = LAMBDAPANELS:CreateFrame( "Birthday Editor", 300, 100 )

    LAMBDAPANELS:CreateLabel( "Changes are saved when you close the panel", frame, TOP )

    local box = LAMBDAPANELS:CreateComboBox( frame, LEFT, months )
    box:SetSize( 100, 5 )
    box:Dock( LEFT )
    box:SetValue( "Select a Month" )

    local day = LAMBDAPANELS:CreateNumSlider( frame, LEFT, 0, "Week day", 1, 31, 0 )
    day:SetSize( 200, 5 )
    day:Dock( LEFT )

    local birthdaydata = LAMBDAFS:ReadFile( "lambdaplayers/playerbirthday.json", "json" )

    if birthdaydata then
        box:SelectOptionByKey( birthdaydata.month )
        day:SetValue( birthdaydata.day )
    end

    function frame:OnClose() 
        local _, month = box:GetSelected()
        if !month or month == "" then return end
        LAMBDAFS:UpdateKeyValueFile(  "lambdaplayers/playerbirthday.json", { month = month, day = round( day:GetValue(), 0 ) }, "json" ) 

        net.Start( "lambdaplayers_onclosebirthdaypanel" )
        net.WriteString( month )
        net.WriteUInt( round( day:GetValue(), 0 ), 5 ) 
        net.SendToServer()
    end
end
RegisterLambdaPanel( "Birthday", "设置你的生日", OpenBirthdaypanel )
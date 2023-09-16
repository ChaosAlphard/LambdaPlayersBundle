local player_GetAll = player.GetAll
local color_white = color_white
local rand = math.Rand
local random = math.random

CreateLambdaConvar( "lambdaplayers_cd_showconnectmessage", 1, true, false, false, "在 Lambda Player 加入服务器(生成)时显示一条消息", 0, 1, { type = "Bool", name = "发送加入消息", category = "Misc" } )
CreateLambdaConvar( "lambdaplayers_cd_connectmessage", "加入服务器", true, false, false, "Lambda Player 加入服务器(生成)时显示的消息", nil, nil, { type = "Text", name = "加入服务器消息", category = "Misc" } )
CreateLambdaConvar( "lambdaplayers_cd_allowdisconnecting", 1, true, false, false, "允许 Lambda Player 在一定时间后自动离开服务器", 0, 1, { type = "Bool", name = "允许退出服务器", category = "Misc" } )
CreateLambdaConvar( "lambdaplayers_cd_disconnectmessage", "离开服务器", true, false, false, "Lambda Player 离开服务器时显示的消息", nil, nil, { type = "Text", name = "退出服务器消息", category = "Misc" } )
CreateLambdaConvar( "lambdaplayers_cd_disconnecttime", 5000, true, false, false, "Lambda Player 在服务器内停留的最长时间", 15, 5000, { type = "Slider", decimals = 0, name = "退出时间", category = "Misc" } )

local allowdisconnectline = CreateLambdaConvar( "lambdaplayers_cd_allowdisconnectlines", 1, true, false, false, "Lambda Player 在离开服务器前发送一条消息", 0, 1, { type = "Bool", name = "启用离开服务器文本", category = "Text Chat Options" } )
local allowconnectline = CreateLambdaConvar( "lambdaplayers_cd_allowconnectlines", 1, true, false, false, "Lambda Player 在加入服务器后发送一条消息", 0, 1, { type = "Bool", name = "启用加入服务器文本", category = "Text Chat Options" } )


-- This is all very simple. I don't really need to put a lot of documentation on this


local function Initialize( self )

    self.l_nextdisconnect = CurTime() + rand( 1, GetConVar( "lambdaplayers_cd_disconnecttime" ):GetInt() )  -- The next time until we will disconnect


    -- Very basic disconnecting stuff
    function self:DisconnectState()

        if allowdisconnectline:GetBool() and random( 1, 100 ) <= self:GetTextChance() and !self:IsSpeaking() and self:CanType() then
            self:TypeMessage( self:GetTextLine( "disconnect" ) )
        end
        
        while self:GetIsTyping() do 
            coroutine.yield() 
        end
        
        coroutine.wait( rand( 0.5, 2 ) )

        self:Disconnect()
    end
    
    function self:ConnectedState()
        if allowconnectline:GetBool() and random( 1, 100 ) <= self:GetTextChance() and !self:IsSpeaking() and self:CanType() then
            self:TypeMessage( self:GetTextLine( "connect" ) )
        end
        
        while self:GetIsTyping() do 
            coroutine.yield() 
        end

        if self:GetState() == "ConnectedState" then self:SetState( "Idle" ) end
    end

    -- Leave the game
    function self:Disconnect()
    
        for k, ply in ipairs( player_GetAll() ) do
            LambdaPlayers_ChatAdd( ply, self:GetDisplayColor( ply ), self:GetLambdaName(), color_white,  " " .. GetConVar( "lambdaplayers_cd_disconnectmessage" ):GetString() )
        end
    
        self:Remove()
    end

end

-- Handle connect message
local function AIInitialize( self )

    if GetConVar( "lambdaplayers_cd_showconnectmessage" ):GetBool() then 
        for k, ply in ipairs( player_GetAll() ) do
            LambdaPlayers_ChatAdd( ply, self:GetDisplayColor( ply ), self:GetLambdaName(), color_white,  " " .. GetConVar( "lambdaplayers_cd_connectmessage" ):GetString() )
        end
    end

    self:SetState( "ConnectedState" )

end

local function Think( self )
    if CLIENT then return end

    if CurTime() > self.l_nextdisconnect then

        if GetConVar( "lambdaplayers_cd_allowdisconnecting" ):GetBool() then
            self:SetState( "DisconnectState" )
            self:CancelMovement()
        end
        
        self.l_nextdisconnect = CurTime() + rand( 1, GetConVar( "lambdaplayers_cd_disconnecttime" ):GetInt() ) 
    end

end

hook.Add( "LambdaOnThink", "lambdadisconnecting_think", Think )
hook.Add( "LambdaAIInitialize", "lambdadisconnecting_AIinit", AIInitialize )
hook.Add( "LambdaOnInitialize", "lambdadisconnecting_init", Initialize )

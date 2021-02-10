function onScriptLoad() {
	print( " ..::$$[[NT5]]$$::.. " );
	print( "Cargando Script...." );
	LoadModule( "sq_lite" );
	LoadModule( "sq_hashing" );
	LoadModule( "sq_ini" );
	db <- ConnectSQL( "database/Database.db" );
	dofile( "Functions.nut" );
	dofile( "Commands.nut" );
	dofile( "Remote.nut" );
	LoadArrays(); LoadProps(); LoadVehicles(); LoadMessenges(); LoadIrcMessenges(); ConnectEcho();
	NewTimer("SetConfigServer",2000,1);
}
function SetConfigServer() {
	SetServerName(GetConfig("ServerName"));
	SetGamemodeName(GetConfig("GameMode"));
	if ( GetConfig("Password") != "none" ) SetPassword(GetConfig("Password"));
	SetMaxPlayers(GetConfig("MaxPlayers").tointeger());
	print(GetServerName()+" Iniciado. - GameMode: "+GetGamemodeName());
}
function onScriptUnload() {
	print( "Desconectando Scrit...." );
	DisconnectSQL(db); KillBots();
}
function onPlayerJoin( player ) {
	print( "[" + player.ID + "] " + player.Name + " " + GetMsg( "join1" ) );
	Echo( "14[" + player.ID + "]3 " + player.Name + " " + GetMsg( "join1" ) );
	if (Iswm(player.Name,"$") || Iswm(player.Name,"#") || Iswm(player.Name,"'")) AutoKick(player,GetMsg("cnick2"));
	else if ( player.Name.len() < 3 ) AutoKick(player,GetMsg("cnick1"));
	else {
	if ( PlayerLevel( player ) != 0 ) IncreaseJoins( player, 1 );
    PrivMessage( GetMsg( "well1" ) + " " + GetServerName() + "!", player );
	AccountInfo( player );
}}
function onPlayerRequestClass( player, pclass, pteam, pskin ) {
	Announce( "~t~\x10 \x10 \x10 \x10 \x10 \x10 " + GetSkinName( pskin ) , player );
	if ( player.ID > 9 ) Announce( "~v~\x10 \x10 \x10 \x10 " + GetSkinName( pskin ) , player );
	SetCinematicBorder( player, true );
}
function onPlayerSpawn( player ) {
	if (PlayerInfo[player.ID].Hide!=false) PlayerInfo[player.ID].Hide=false;
	SetCinematicBorder( player, false );
	if ( PlayerLevel( player ) == 0 || GetLoggedStatus( player ) != true ) {
	PrivMessage(GetMsg("spraw1"),player);
	player.Health = 0;
	if ( PlayerLevel( player ) == 0 ) Announce( "/c register", player );
	else if ( GetLoggedStatus( player ) != true ) Announce( "/c login", player );
	Echo( "4>" + player + " " + GetMsg("sprwn2") ); 
	print( ">" + player + " " + GetMsg("sprwn2") ); 
	msg( ">" + player + " " + GetMsg("sprwn2"), 200, 0, 0 );
	}
	else {
	local pos = player.Pos;
	Echo( "14->[" + player.ID + "] 5" + player.Name + " " + GetMsg( "spaw1" ) + " " + GetSkinName( player.Skin ) + ", " + GetMsg( "spaw2" ) + " " + GetDistrictName( pos.x, pos.y ) + " Ping: ("+player.Ping+"ms)." );
    print( "->[" + player.ID + "] " + player.Name + " " + GetMsg( "spaw1" ) + " " + GetSkinName( player.Skin ) + ", " + GetMsg( "spaw2" ) + " " + GetDistrictName( pos.x, pos.y ) + " Ping: ("+player.Ping+"ms)." );
    msg( player.Name + " " + GetMsg( "spaw1" ) + " " + GetSkinName( player.Skin ) + ", " + GetMsg( "spaw2" ) + " " + GetDistrictName( pos.x, pos.y ) + " Ping: ("+player.Ping+"ms).", 200 , 250, 0 );
	PlayerInfo[player.ID].TimePlay=GetTime();
	PlayerInfo[player.ID].SpawnPro=true;
	SpawnProTimer<-NewTimer("SpawnProOff",5000,1,player);
	local Cash = PlayerCash( player );
	if ( PlayerLevel( player ) != 0 && GetLoggedStatus( player ) == true ) player.Cash = Cash;
	}
}
function onPickupPickedUp( player, pickup ){
	if ( pickup.Model == 407 ) {
		local q = QuerySQL( db, "SELECT Name, Owner, Shared, Cost FROM Properties WHERE rowid LIKE '" + pickup.ID + "'");
		local Owner = "", Shared = "", Cost = "";
		if ( GetSQLColumnData( q, 1 ) != "None" ) Owner = " Owner:[ " + GetSQLColumnData( q, 1 ) + " ]";
		else Cost = " Cost:[ $"+mformat(GetSQLColumnData( q, 3 ).tointeger())+" ]";
		if ( GetSQLColumnData( q, 2 ) != "None" ) Shared = " Shared with:[ " + GetSQLColumnData( q, 2 ) + " ]";
		PrivMessage( "Property -", player );
		PrivMessage( "ID:[ " + pickup.ID + " ] Name:[ " + GetSQLColumnData( q, 0 ) + " ] " + Owner + Shared + Cost, player );
		pickup.RespawnTime = 2;
}}
function onPlayerExitVehicle( player, vehicle, isPassenger ) {
if (PlayerInfo[player.ID].Stunt) {
PlayerInfo[player.ID].Stunt=null;
StuntCheck.Delete();
}
if (PlayerInfo[player.ID].Speedo) {
SeedoMeterV.Delete();
Announce("\x10",player,1); 
PlayerInfo[player.ID].Speedo = false; 
}}
function onPlayerEnterVehicle( player, veh, isPassenger ) {
//Speedo
PlayerInfo[player.ID].Speedo = format("%.4f %.4f %.4f", player.Pos.x, player.Pos.y, player.Pos.z );
SeedoMeterV <- NewTimer("SpeedoVehicle",500,0,player);
//StuntCheck
PlayerInfo[player.ID].Stunt=format("%i",(player.Pos.z))+" 0 0";
StuntCheck <- NewTimer("OnStunt",500,0,player);
//CarInfo
local Cars = QuerySQL( db, "SELECT ID, Owner, Shared FROM Vehicles WHERE ID LIKE '" + player.Vehicle.ID + "'" );
local Cost = QuerySQL( db, "SELECT Name, Cost FROM VehicleCost WHERE Name LIKE '" + GetVehicleNameFromModel( player.Vehicle.Model ) + "'" );
local Owner = "", Shared = "", CCost = "";
if (GetSQLColumnData( Cars, 1 )) Owner = " Owner:[ " + GetSQLColumnData( Cars, 1 ) + " ]";
else CCost = " Cost:[ $" + mformat(GetSQLColumnData( Cost, 1 ).tointeger())+" ]";
if (GetSQLColumnData( Cars, 2 )) Shared = " Shared with:[ " + GetSQLColumnData( Cars, 2 ) + " ]";
PrivMessage("- Car -",player);
PrivMessage( "Name:[ "+GetVehicleNameFromModel(player.Vehicle.Model)+" ], ID:[ "+player.Vehicle.ID+" ] "+Owner+Shared+CCost+ " "+"Heal [" + player.Vehicle.Health / 10 + "%]", player );
FreeSQLQuery(Cars); FreeSQLQuery(Cost);
}
function onPlayerKill( killer, killed, weapon, bodypart ) {
	local Part=GetBodyPart(bodypart),dist=GetDistance(killer.Pos,killed.Pos);
	print( "** " + killer.Name + " killed " + killed.Name + " (" + GetWeaponName( weapon ) + ") (" + Part + ")" + " " + GetMsg( "dist1" )+" ("+format("%.2f",(dist))+"m)" );
	Echo( "2> 4" + killer.Name + " killed " + killed.Name + " (" + GetWeaponName( weapon ) + ") (" + Part + ")" + " " + GetMsg( "dist1" )+"("+format("%.2f",(dist))+"m)" );
	msg( "** " + killer.Name + " killed " + killed.Name + " (" + GetWeaponName( weapon ) + ") (" + Part + ")" + " " + GetMsg( "dist1" ) + "("+format("%.2f",(dist))+"m)", 0, 200, 0 );
	if (PlayerInfo[killed.ID].SpawnPro) KillPlayer(killer, "Spawn Kill.");
	else if (onBank( killed )) KillPlayer( killer, "Kill On Bank." );
	else if (onSunshine( killed )) KillPlayer( killer, "Kill On Sunshine." );
	else {
	PlayerInfo[killer.ID].Spree++;
	if ( Part == "Head" ) Announce( "~b~head~t~shoot", killer );
	if ( PlayerLevel( killer ) != 0 ) IncreaseCash( killer, 500 ), IsSpree( killer );
	PrivMessage( GetMsg("timeplay1") + " " + duration(PlayerInfo[killed.ID].TimePlay), killed );
	if ( PlayerInfo[killed.ID].Spree >= 10 ) {
	Echo( "4* " + killed + " " + GetMsg("spree8") + " " + killer );
	msg( "* " + killed + " " + GetMsg("spree8") + " " + killer, 200, 0, 0 );
	print( "* " + killed + " " + GetMsg("spree8") + " " + killer );
	PlayerInfo[killed.ID].Spree=0;
	}
	PlayerInfo[killed.ID].Spree=0;
	if ( PlayerLevel( killer ) != 0  &&  StatsToggle( killer ) == "on" ) IncreaseKills( killer );
	if ( PlayerLevel( killed ) != 0  &&  StatsToggle( killed ) == "on" ) IncreaseDeaths( killed );
	if ( PlayerCash( killed ) >= 250 ) DecreaseCash( killed, 250 );
	else DecreaseCash( killed, PlayerCash( killed ) );
	
	if (LMS.IsStard == true) {
	if (LMSPlayer[killed.ID] == true) LMSPlayer[killed.ID] = false, LMS.Players--;
	if (LMS.Players == 1) EndLMS();
	}}
}
function onPlayerDeath( player, weapon ) {
	local Toggle = StatsToggle( player ), Log = GetLoggedStatus( player );
	if ( ( Toggle == "on" ) && ( Log == true ) ) IncreaseDeaths( player );
	Echo( "10> 4" + player.Name + " " + GetMsg( "die1" ) );
	Message(player+" Died.");
	if ( PlayerInfo[ player.ID ].TimePlay != 0 )PrivMessage( GetMsg("timeplay1") + " " + duration(PlayerInfo[ player.ID ].TimePlay), player);
	if ( PlayerInfo[player.ID].Spree >= 10 ) {	
	PlayerInfo[player.ID].Spree = 0;
	msg( "* " + player + " " + GetMsg("spree9"), 250, 0, 0 );
	Echo( "4* " + player + " " + GetMsg("spree9") );
	print( "* " + player + " " + GetMsg("spree9") );
	}
	PlayerInfo[player.ID].Spree=0;
	if (LMS.IsStard == true) {
	if (LMSPlayer[player.ID] == true) LMSPlayer[player.ID] = false, LMS.Players--;
	if (LMS.Players == 1 || LMS.Players == 0) EndLMS();
}}
function onPlayerChat( player, text ) {
	::ServerSpam(player,text);
	Echo( "10>[" + player.ID + "] 12" + player.Name + ": 1" + text );
	if ( text ) {
		if ( text.slice( 0, 1 ) == "!" ) {
			local i = NumTok( text, " " );
			if ( i == 1 ) onPlayerCommand2( player, GetTok( text.slice( 1 ), " ", 1 ), null );
			else onPlayerCommand2( player, GetTok( text.slice( 1 ), " ", 1 ), GetTok( text.slice( 1 ), " ", 2, i ) );
}}}
function onPlayerAction( player, text ) {	
	if ( text ) {
	Echo( "10>>13" + player.Name + " " + text );
	print( "** " + player.Name + " " + text );
}}
function onPlayerPart( player, reason ) {
	local Text=GetPartReason(reason);
	print( "[" + player.ID + "] " + player.Name + " " + GetMsg( "left" ) + " (" + Text + ")" );
	Echo( "10>>3[" + player.ID + "] " + player.Name + " " + GetMsg( "left" ) + " (" + Text + ")" );
	if ( PlayerInfo[player.ID].Spree >= 10 ) {
	msg( "* " + player + " " + GetMsg("spree9"), 250, 0, 0 );
	Echo( "4* " + player + " " + GetMsg("spree9") );
	print( "* " + player + " " + GetMsg("spree9") );
	}
	if (PlayerInfo[player.ID].Speedo) SeedoMeterV.Delete();
	if (PlayerInfo[player.ID].Stunt) StuntCheck.Delete();
	if (PlayerLevel(player)!=0) SavePlayerData(player);
	if (PlayerInfo[player.ID].SpawnPro) SpawnProTimer.Delete();
	RestoreArrays( player ); 
	if (LMS.IsStard == true) {
	if (LMSPlayer[player.ID] == true) LMSPlayer[player.ID] = false, LMS.Players--;
	if (LMS.Players == 1) EndLMS();
}}
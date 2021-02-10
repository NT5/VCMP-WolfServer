//!commands
ServerCMDS<-[ 
"!loc","!spree","!wep","!disarm","!heal","!withdraw","!deposit",
"!goto","!randloc","!gotoloc","!saveloc","!bstunt","!check","!hide",
"!cash","!showcash","!stats","!eject","!fix","!flip","!ff","!cd","!drunk",
"!undrunk","!night","!day","!foogy","!sellprop","!myprops","!buyprop","!gotomyhome",
"!sellcar","!mycars","!getcar","!gotomycar","!car","!irc","!forsale",
"/c register","/c login","/c logout","/c stat","/c nogoto","/c ipm"
];
function onPlayerCommand2( player, command, text )
{	
	local plr, Level = PlayerLevel( player ),cmd = command.tolower();
	if ( text ) plr = GetPlayer( text );
	else plr = player;
	if ( cmd == "commands" || cmd == "cmds" ) {
	local l=0,t=0,buffer;
	PrivMessage( "--- All Commands ---",player);
	while ( t < ServerCMDS.len() ) {
	if (l >= 15) { PrivMessage(buffer,player); buffer=""; l=0; }
	if (!buffer) buffer = ServerCMDS[t];
	else buffer = buffer + ", " + ServerCMDS[t];
	if (buffer.slice(0,1) == ","  ) buffer=buffer.slice(2);
	t++; l++;
	} PrivMessage(buffer,player); }
	else if ( cmd == "admin" || cmd == "admins" ) {
	local a=0,b;
	while (a<=GetMaxPlayers()) {
	local plr = FindPlayer(a.tointeger());
	if ( plr ) {
	if ( PlayerLevel(plr) >= 2 ) {
	if (b)b=b+", "+plr.Name+" (Level: "+ PlayerLevel( plr )+")"
	else b=plr.Name+" (Level: "+PlayerLevel(plr)+")"
	}}
	a++; }
	if (b) { msg("> Admins: "+b,0,0,200); Echo("2> Admins: "+b); }
	else { msg( "> There are no admins ingame.",200,0,0); Echo("4> There are no admins ingame."); }
	}
	else if (cmd == "server") {
	Echo("7>10 Server Name: ["+GetServerName()+"] GameMode: ["+GetGamemodeName()+"] IP:["+Bot.MeIP+":2339] MaxPlayers: ["+GetMaxPlayers()+"] Scrip Vercion: ["+Server.VerScript+"] Password: ["+GetPassword()+"] Registers Users: ["+Server.Registers+"]");
	msg("> Server Name: ["+GetServerName()+"] GameMode: ["+GetGamemodeName()+"] IP:["+Bot.MeIP+":2339] MaxPlayers: ["+GetMaxPlayers()+"] Scrip Vercion: ["+Server.VerScript+"] Password: ["+GetPassword()+"] Registers Users: ["+Server.Registers+"]",200,200,0);
	}
	else if (cmd == "irc") {
	msg(">Chanell: "+Bot.Chan+" Network: "+Bot.NetName,200,0,200);
	Echo("10>Chanell: "+Bot.Chan+" Network: "+Bot.NetName);
	msg( " --- IRC Users --- ",200,0,200); Echo("10--- IRC Users --- "); local buffer;
	for (local i=0,t=0; i<=50; i++,t++) {
	if(IrcUsers[i].Name) {
	if (t >= 15) { msg(buffer,200,0,200); Echo("10"+buffer); buffer=""; t=0; }
	if (!buffer) buffer = IrcUsers[i].Name;
	else buffer = buffer+", "+IrcUsers[i].Name;
	if (buffer.slice(0,1) == ","  ) buffer=buffer.slice(2);
	}} msg(buffer,200,0,200); Echo("10"+buffer); }
	else if ( cmd == "lms" )
	{
	if (LMS.IsStard == true) PrivMessage(GetMsg("lms6"),player);
	else ParceLMS();
	}
	else if ( cmd == "join" )
	{
	if (!player.IsSpawned) PrivMessage( GetMsg( "playerspra" ),player );
	else if (LMS.IsStard == false) PrivMessage(GetMsg("lms8"),player);
	else if (player.Health < 80) PrivMessage(GetMsg("lms9"),player);
	else if (LMSPlayer[player.ID] == true) PrivMessage(GetMsg("lms7"),player);
	else JoinLMS(player);
	}
	else if ( cmd == "eject" ) {
	if ( !player.Vehicle ) PrivMessage( GetMsg("novhe"), player );
	else {
	local pos = player.Vehicle.Pos;
    pos.z +=1; pos.x +=1; pos.y +=1;
	player.Pos = pos;
	}}
	else if ( cmd == "ff" ) {
	if ( !player.Vehicle ) PrivMessage( GetMsg("novhe"), player );
	else {
	player.Vehicle.Fix();
	local pos = player.Vehicle.Pos;
    pos.z += 1; pos.x += 1; pos.y += 1;
    player.Vehicle.Pos = pos;
	PrivMessage(GetMsg("ff1"),player);
	}}
	else if ( cmd == "flip" ) {
    if ( !player.Vehicle ) PrivMessage( GetMsg("novhe"), player );
    else {
        local pos = player.Vehicle.Pos;
        pos.z += 1; pos.x += 1; pos.y += 1;
        player.Vehicle.Pos = pos;
	}}
	else if ( cmd == "fix" ) {
	if (!player.Vehicle) PrivMessage( GetMsg("novhe"), player );
	else if (player.Vehicle.Health/10 >= 75 ) PrivMessage( GetMsg("fix1"), player );
	else {
	PrivMessage( GetMsg("fix2"), player ); 
	player.Vehicle.Fix();
	}}
	else if ( cmd == "day" ) {
	if (GetTime()-Server.WeaterChange <= 15) PrivMessage( GetMsg("weat1"), player );
	else {
		Server.WeaterChange=GetTime();
        msg( "* "+player+" "+GetMsg("weat2"),0,200,0 );
		Echo("10* "+player+" "+GetMsg("weat2"));
        SetTime(12,00);
        SetWeather(11);              
    }}
	else if ( cmd == "night" ) {
	if (GetTime()-Server.WeaterChange <= 15) PrivMessage( GetMsg("weat1"), player );
	else {
		Server.WeaterChange = GetTime();
		msg( "* "+player+" "+GetMsg("weat3"),0,200,0 );
		Echo("10* "+player+" "+GetMsg("weat3"));
        SetTime(00,00);
        SetWeather(6);
	}}
	else if ( cmd == "foogy" ) {
	if (GetTime()-Server.WeaterChange <= 15) PrivMessage( GetMsg("weat1"), player );
	else {
		Server.WeaterChange = GetTime();
        msg( "* "+player+" "+GetMsg("weat4"),0,200,0);
		Echo("10* "+player+" "+GetMsg("weat4"));
        SetTime(14,00);
        SetWeather(10);               
    }}
	else if ( cmd == "hide" ) {
	if (!player.IsSpawned) PrivMessage(GetMsg("playerspra" ),player);
	else if (PlayerInfo[player.ID].Hide==true) PrivMessage(GetMsg("hide1"),player);
	else {
	PlayerInfo[player.ID].Hide=true;
	Echo("14> "+player+" "+GetMsg("hide2"));
	msg("> "+player+" "+GetMsg("hide2"),0,0,200);
	player.RemoveMarker();
	}}
	else if (cmd == "hunt") {
	if (Hunt.IsStard == true) PrivMessage("Error - There are currently a hunt activate.",player);
	else { StardHunt(); }}
	else if (cmd == "hunted") {
	if (Hunt.IsStard == false) PrivMessage("Error - No players in hunt, type !hunt to hunt.",player);
	else { Message("Hunt Status: Player:"+Hunt.Player+", Duration:"+Hunt.Time+"min, Reward: $"+Hunt.Reward+"."); }}
	
	else if (cmd == "undrunk") {
	if (!player.IsSpawned) PrivMessage(GetMsg("playerspra" ),player);
	else if (PlayerInfo[player.ID].IsDrunk==false) PrivMessage(GetMsg("drunk5"),player);
	else if (!NeedPlayerInArea(player,-626.4150,-580.3410,622.6376,651.6790)) PrivMessage(GetMsg("drunk1"),player);
	else {
			PlayerInfo[player.ID].IsDrunk=false;
			PrivMessage(GetMsg("drunk3"),player);
			player.SetDrunkLevel(0,0);
	}}
	else if (cmd == "drunk") {
	if (!player.IsSpawned) PrivMessage(GetMsg("playerspra" ),player);
	else if (PlayerInfo[player.ID].IsDrunk==true) PrivMessage(GetMsg("drunk4"),player);
	else if (!NeedPlayerInArea(player,-626.4150,-580.3410,622.6376,651.6790)) PrivMessage(GetMsg("drunk1"),player);
	else {
			PlayerInfo[player.ID].IsDrunk=true;
			PrivMessage(GetMsg("drunk2"),player);
			player.SetDrunkLevel(100,100);
	}}
	else if ( cmd == "cd" ) {
	if ( Server.OnCD == true ) PrivMessage(GetMsg("cd1"),player);
	else {
	Server.OnCD=true;
	msg( "------- 3 -------", 0, 250, 250 ), AnnounceAll( "~b~-~o~ 3 ~b~-" );
	NewTimer( "msg", 1000, 1, "------- 2 -------", 0, 250, 250 ), NewTimer( "AnnounceAll", 1000, 1, "~b~-~o~ 2 ~b~-" );
	NewTimer( "msg", 2000, 1, "------- 1 -------", 0, 250, 250 ), NewTimer( "AnnounceAll", 2000, 1, "~b~-~o~ 1 ~b~-" );
	NewTimer( "msg", 3000, 1, "-- Go, Go, Go! --", 0, 250, 250 ), NewTimer( "AnnounceAll", 3000, 1 "~b~-~g~ go! ~b~-" );
	NewTimer( "EndCD",4000,1);
	}}
	else if ( cmd == "heal" ) {
		local Cash = PlayerCash( player );
		local Cost = 100 - player.Health;
		if ( !player.IsSpawned ) PrivMessage( GetMsg( "playerspra" ), player );
		else if ( player.Health == 100 ) PrivMessage( GetMsg("heal1"), player );
		else if ( Cash < Cost ) PrivMessage( GetMsg("heal2") + Cost + "!", player );
		else {
			msg( "* "+player+" "+GetMsg("heal3")+Cost,255,255,0);
			Echo( "7* "+player+" "+GetMsg("heal3")+Cost);
			print( "* "+player+" "+GetMsg("heal3")+Cost);
			player.Health = 100;
			DecreaseCash( player, Cost );
	}}
	else if ( cmd == "check" ) {
		if ( !plr ) PrivMessage( GetMsg("errornick"), player );
		else if ( !plr.IsSpawned ) PrivMessage(GetMsg("playerspra"),player);
		else {
		msg("-> "+plr+"'"+GetMsg("check1")+"["+plr.Health+"%] "+GetMsg("check2")+"["+plr.Armour+"%] "+"Ping: ["+plr.Ping+"ms]",0,100,0);
		Echo("10-> "+plr+"'"+GetMsg("check1")+"["+plr.Health+"%] "+GetMsg("check2")+"["+plr.Armour+"%] "+"Ping: ["+plr.Ping+"ms]");
		print("-> "+plr+"'"+GetMsg("check1")+"["+plr.Health+"%] "+GetMsg("check2")+"["+plr.Armour+"%] "+"Ping: ["+plr.Ping+"ms]");
	}}
	else if ( cmd == "loc" ) {
		if ( !plr ) PrivMessage( GetMsg( "errornick" ), player );
		else if ( !plr.IsSpawned ) PrivMessage( GetMsg( "playerspra" ), player );
		else {
			local pos = plr.Pos;
			msg( "* " + plr.Name + " " + GetMsg( "spaw2" ) + "(" + GetDistrictName( pos.x, pos.y ) + ") " + GetMsg("loc1") + " " + pos, 0, 200, 200 );
			Echo( "10* " + plr.Name + " " + GetMsg( "spaw2" ) + "(" + GetDistrictName( pos.x, pos.y ) + ") " + GetMsg("loc1") + " " + pos );
			print( "* " + plr.Name + " " + GetMsg( "spaw2" ) + "(" + GetDistrictName( pos.x, pos.y ) + ") " + GetMsg("loc1") + " " + pos );
	}}
	else if ( cmd == "bstunt") {
	if (!text) PrivMessage("!"+cmd+" <on/off>", player);
	else if (!player.IsSpawned) PrivMessage( GetMsg( "playerspra" ), player );
	else if (!player.Vehicle) PrivMessage(GetMsg("novhe"),player);
	else {
	if (text == "on") {
	if (player.StuntMode == true) PrivMessage(GetMsg("stb2"),player); 
	else {
	PrivMessage(GetMsg("stb1"),player); 
	player.StuntMode = true;
	}}
	else if (text == "off") {
	if (player.StuntMode == false) PrivMessage(GetMsg("stb3"),player); 
	else {
	player.StuntMode = false;
	PrivMessage(GetMsg("stb4"),player); 
	}}
	else PrivMessage("!"+cmd+" <on/off>", player);
	}}
	else if (cmd == "forsale") {
	msg(GetMsg("forsale1")+" ["+ServerCCars("get")+"] "+GetMsg("forsale2")+" ["+ServerCProps("get")+"]",0,200,0);
	Echo(">10"+GetMsg("forsale1")+" ["+ServerCCars("get")+"] "+GetMsg("forsale2")+" ["+ServerCProps("get")+"]");
	print(GetMsg("forsale1")+" ["+ServerCCars("get")+"] "+GetMsg("forsale2")+" ["+ServerCProps("get")+"]");
	}
	else if ( cmd == "car" ) {
		if ( text ) {
		local plr = GetPlayer( text );
		if ( plr ) {
				if ( plr.Vehicle ) {
					local Cars = QuerySQL( db, "SELECT ID, Owner, Shared FROM Vehicles WHERE ID LIKE '" + plr.Vehicle.ID + "'" );
					local Cost = QuerySQL( db, "SELECT Name, Cost FROM VehicleCost WHERE Name LIKE '" + GetVehicleNameFromModel( plr.Vehicle.Model ) + "'" );
					local Owner = "", Shared = "", CCost = "";
					if ( GetSQLColumnData( Cars, 1 ) ) Owner = " Owner:[ " + GetSQLColumnData( Cars, 1 ) + " ]";
					else CCost = " Cost:[ $" + mformat(GetSQLColumnData( Cost, 1 ).tointeger()) + " ]";
					if ( GetSQLColumnData( Cars, 2 ) ) Shared = " Shared with:[ " + GetSQLColumnData( Cars, 2 ) + " ]";
					PrivMessage( "Car -", player );
					PrivMessage( "Name:[ " + GetVehicleNameFromModel( plr.Vehicle.Model ) + " ], ID:[ " + plr.Vehicle.ID + " ] " + Owner + Shared + CCost, player );
					FreeSQLQuery(Cars); FreeSQLQuery(Cost);
				}
				else PrivMessage("Error - "+plr.Name+" "+GetMsg("car1"),player);
			}
			else PrivMessage(GetMsg("errornick"),player );
		}
		else {
			local plr = player;
			
			if ( plr.Vehicle ) {
					local Cars = QuerySQL( db, "SELECT ID, Owner, Shared FROM Vehicles WHERE ID LIKE '" + plr.Vehicle.ID + "'" );
					local Cost = QuerySQL( db, "SELECT Name, Cost FROM VehicleCost WHERE Name LIKE '" + GetVehicleNameFromModel( plr.Vehicle.Model ) + "'" );
					local Owner = "", Shared = "", CCost = "";
					if ( GetSQLColumnData( Cars, 1 ) ) Owner = " Owner:[ " + GetSQLColumnData( Cars, 1 ) + " ]";
					else CCost = " Cost:[ $" +mformat(GetSQLColumnData( Cost, 1 ).tointeger()) + " ]";
					if ( GetSQLColumnData( Cars, 2 ) ) Shared = " Shared with:[ " + GetSQLColumnData( Cars, 2 ) + " ]";
					PrivMessage( "Car -", player );
					PrivMessage( "Name:[ " + GetVehicleNameFromModel( plr.Vehicle.Model ) + " ], ID:[ " + plr.Vehicle.ID + " ] " + "Health: " + (  plr.Vehicle.Health / 10 ) + "%" + Owner + Shared + CCost, player );
					FreeSQLQuery(Cars); FreeSQLQuery(Cost);
			}
			else PrivMessage("Error - "+plr.Name+" "+GetMsg("car1"),player);
	}}
	else if ( cmd == "buycar" ) {
	if ( !player.IsSpawned ) PrivMessage( GetMsg("respaw"), player );
	else {
		if ( player.Vehicle ) {
			if ( !text ) {
				local veh = player.Vehicle;
				local Cash = PlayerCash( player );
				local Cars = QuerySQL( db, "SELECT Owner FROM Vehicles WHERE ID LIKE '" + player.Vehicle.ID + "'" );
				local Cost = QuerySQL( db, "SELECT Cost FROM VehicleCost WHERE Name LIKE '" + GetVehicleNameFromModel( player.Vehicle.Model ) + "'" );
				if ( Cash < GetSQLColumnData( Cost, 0 ).tointeger() ) PrivMessage( GetMsg("heal2")+GetSQLColumnData( Cost, 0 ).tointeger()+" "+GetMsg("car2"),player );
				else if ( onSunshine( player ) != true ) PrivMessage( GetMsg("car3"),player );
				else if ( GetSQLColumnData( Cars, 0 ) ) PrivMessage( GetMsg("car4"),player )
				else if ( !veh ) PrivMessage( GetMsg("novhe"),player ); 
				else {
				local a=QuerySQL( db, "INSERT INTO Vehicles ( ID, Owner, Name ) values ( '" + player.Vehicle.ID + "', '" + player.Name + "', '" + GetVehicleNameFromModel( player.Vehicle.Model ) + "' )" );	
				FreeSQLQuery(a);
				PlayerCCars(player,"inc");
				PrivMessage( GetMsg("car5")+GetVehicleNameFromModel(player.Vehicle.Model)+" "+GetMsg("goto5")+" $"+mformat(GetSQLColumnData( Cost, 0 ).tointeger()), player );
				PrivMessage( GetMsg("car6")+" !sellcar, !mycars, !getcar", player );
				DecreaseCash( player, GetSQLColumnData( Cost, 0 ).tointeger() );
				msg( GetMsg("car7")+" "+GetVehicleNameFromModel(player.Vehicle.Model )+" "+GetMsg("goto5")+" $"+mformat(GetSQLColumnData( Cost, 0 ).tointeger()),0,206,209 );
				Echo( "3>"+GetMsg("car7")+" "+GetVehicleNameFromModel(player.Vehicle.Model )+" "+GetMsg("goto5")+" $"+mformat(GetSQLColumnData( Cost, 0 ).tointeger() ));
				print( GetMsg("car7")+" "+GetVehicleNameFromModel(player.Vehicle.Model )+" "+GetMsg("goto5")+" $"+mformat(GetSQLColumnData( Cost, 0 ).tointeger()) );
				FreeSQLQuery(Cars); FreeSQLQuery(Cost);
		}}}
		else PrivMessage( GetMsg("car8"),player );
	}}
	
	else if ( cmd == "sellcar" ) {
	if ( !player.IsSpawned ) PrivMessage( GetMsg("respaw"), player );
	else {
		if ( player.Vehicle ) {
			if ( !text ) {
				local Cars = QuerySQL( db, "SELECT Owner FROM Vehicles WHERE ID LIKE '" + player.Vehicle.ID + "'" );
				local Cost = QuerySQL( db, "SELECT Cost FROM VehicleCost WHERE Name LIKE '" + GetVehicleNameFromModel( player.Vehicle.Model ) + "'" );
				local Cars = QuerySQL( db, "SELECT Owner FROM Vehicles WHERE ID LIKE '" + player.Vehicle.ID + "'" );
				local Cost = QuerySQL( db, "SELECT Cost FROM VehicleCost WHERE Name LIKE '" + GetVehicleNameFromModel( player.Vehicle.Model ) + "'" );
				if ( onSunshine( player ) != true ) PrivMessage( GetMsg("car3"),player );
				else if ( GetSQLColumnData( Cars, 0 ) != player.Name ) PrivMessage( GetMsg("car9"), player );
				else {
					PlayerCCars(player,"dec");
					local q=QuerySQL(db, "DELETE FROM Vehicles WHERE ID LIKE '" + player.Vehicle.ID + "'" ); FreeSQLQuery(q);
					PrivMessage( GetMsg("car10")+" "+GetVehicleNameFromModel(player.Vehicle.Model)+" "+GetMsg("goto5")+" $"+GetSQLColumnData( Cost, 0 ).tointeger()/2, player );
					IncreaseCash( player, GetSQLColumnData( Cost, 0 ).tointeger() / 2 );
					msg( GetMsg("car10")+" "+GetVehicleNameFromModel(player.Vehicle.Model)+" "+GetMsg("goto5")+" $"+mformat(GetSQLColumnData( Cost, 0 ).tointeger()/2) ,0,206,209 );
					Echo( "3>"+GetMsg("car10")+" "+GetVehicleNameFromModel(player.Vehicle.Model)+" "+GetMsg("goto5")+" $"+mformat(GetSQLColumnData( Cost, 0 ).tointeger()/2) );
					FreeSQLQuery(Cars); FreeSQLQuery(Cost);
	}}}
	else PrivMessage( GetMsg("car11"), player );
	}}

	else if ( cmd == "mycars" ) {
	if ( !player.IsSpawned ) PrivMessage( GetMsg("respaw"), player );
	else {
		local q = QuerySQL( db, "SELECT Name, ID FROM Vehicles WHERE Owner LIKE '" + player.Name + "'" );
		if (!GetSQLColumnData(q,0)) PrivMessage(GetMsg("car12"),player);
		else {
		while (GetSQLColumnData(q,0)) {
		PrivMessage(GetSQLColumnData(q,0)+" - ID "+GetSQLColumnData(q,1),player); 
		GetSQLNextRow(q);
		if (!q) { break; FreeSQLQuery(q); }
	}}}}
	else if ( cmd == "getcar" ) {
		local q=QuerySQL(db,"SELECT Owner, Shared, Name FROM Vehicles WHERE ID LIKE '"+text+"'" );
		if ( !text ) PrivMessage( "!"+cmd+" <vehicle ID>", player );
		else if ( GetSQLColumnData( q, 0 ) != player.Name ) PrivMessage( GetMsg("car9"), player );
		else if ( !player.IsSpawned ) PrivMessage( GetMsg("respaw"), player );
		else if ( player.Health <= 50 ) PrivMessage( GetMsg("car13"), player );
		else{
			local veh = FindVehicle( text.tointeger() ), pos = player.Pos;	
			if ( veh ) veh.Pos = Vector( pos.x + 2, pos.y, pos.z );
			PrivMessage( GetMsg("car14")+GetSQLColumnData( q, 2 ), player );
			FreeSQLQuery(q);
	}}
	else if ( cmd == "gotomycar" ) {
	local q=QuerySQL(db,"SELECT Owner, Shared, Name FROM Vehicles WHERE ID LIKE '"+text+"'" );
	if ( !text ) PrivMessage( "!"+cmd+" <vehicle ID>", player );
	else if ( GetSQLColumnData( q, 0 ) != player.Name ) PrivMessage( GetMsg("car9"), player );
	else if ( !player.IsSpawned ) PrivMessage( GetMsg("respaw"), player );
	else if ( player.Health <= 50 ) PrivMessage( GetMsg("car13"), player );
	else {
		player.Pos=FindVehicle(text.tointeger()).Pos;
		PrivMessage( GetMsg("car14")+GetSQLColumnData( q, 2 ), player );
		FreeSQLQuery(q);
	}}
	else if ( cmd == "gotomyhome" ) {
	if (!player.IsSpawned ) PrivMessage( GetMsg("respaw"), player );
	else if (!text) PrivMessage( "!"+cmd+" <Prop ID>", player );
	else if (!IsNum(text)) PrivMessage( "!"+cmd+" <Prop ID>", player );
	else {
	local q=QuerySQL(db,"SELECT Owner, Shared, Name, Pos FROM Properties WHERE rowid LIKE '"+text+"'");
	if ( player.Health <= 50 ) PrivMessage( GetMsg("car13"), player )
	else if (GetSQLColumnData(q,0) != player.Name) PrivMessage( GetMsg("prop9"), player );
	else {
	local SplitPos=split(GetSQLColumnData(q,3)," ");
	local x=SplitPos[0],y=SplitPos[1],z=SplitPos[2];
	player.Pos=Vector(x.tofloat(),y.tofloat(),z.tofloat());
	FreeSQLQuery(q);
	}}}
	else if ( cmd == "buyprop" ) {
	local Cash = PlayerCash( player ),q=QuerySQL(db,"SELECT Owner, Cost, Name FROM Properties WHERE rowid LIKE '"+text+"'" );
	if ( !player.IsSpawned ) PrivMessage( GetMsg("respaw"), player );
	else if ( !text ) PrivMessage( GetMsg("errorcmd2")+" !"+cmd+" <property ID>", player );
	else if ( !GetSQLColumnData( q, 1 ) ) PrivMessage( GetMsg("prop1"), player );
	else if ( Cash < GetSQLColumnData(q,1).tointeger()) PrivMessage(GetMsg("heal2")+GetSQLColumnData(q,1)+GetMsg("prop2"),player );
	else if ( GetSQLColumnData( q, 0 ) != "None" ) PrivMessage( GetMsg("prop3"), player );
	else {
			local a=QuerySQL( db, "UPDATE Properties SET Owner = '" + player.Name + "' WHERE rowid = '" + text + "'" );
			FreeSQLQuery( a ); PlayerCProps(player,"inc");
			DecreaseCash(player, GetSQLColumnData(q,1).tointeger() );
			PrivMessage( GetMsg("prop4"), player );
			PrivMessage( "Name: "+GetSQLColumnData( q, 2 )+", ID: "+text, player );
			PrivMessage( GetMsg("car6")+" !sellprop,!myprops", player );
			msg(GetMsg("prop5")+" - "+GetSQLColumnData(q,2)+" "+GetMsg("goto5")+" $"+mformat(GetSQLColumnData(q,1).tointeger()),0,200,0);
			Echo("3>"+GetMsg("prop5")+" - "+GetSQLColumnData(q,2)+" "+GetMsg("goto5")+" $"+mformat(GetSQLColumnData(q,1).tointeger()));
			FreeSQLQuery(q);
	}}
	else if ( cmd == "sellprop" ) {
	local q=QuerySQL( db, "SELECT Owner, Cost, Name FROM Properties WHERE rowid LIKE '" + text + "'" );
	if ( !player.IsSpawned ) PrivMessage( GetMsg("respaw"), player );
	else if ( !text ) PrivMessage( GetMsg("errorcmd2")+" !"+cmd+" <property ID>", player );
	else if (GetSQLColumnData(q,0) != player.Name ) PrivMessage( GetMsg("prop6"), player );
	else {
			local a=QuerySQL( db, "UPDATE Properties SET Owner = 'None' WHERE rowid = '" + text + "'" );
			local b=QuerySQL( db, "UPDATE Properties SET Shared = 'None' WHERE rowid = '" + text + "'" );
			FreeSQLQuery(a); FreeSQLQuery(b); PlayerCProps(player,"dec");
			PrivMessage( GetMsg("prop7")+mformat(GetSQLColumnData(q,1).tointeger()/2)+".",player );
			PrivMessage( "Name: " + GetSQLColumnData( q, 2 ) + ", ID: " + text, player );
			msg("-> "+GetSQLColumnData(q,2)+" - "+GetMsg("prop7")+mformat(GetSQLColumnData(q,1).tointeger()/2)+".",0,200,0);
			Echo("3-> "+GetSQLColumnData(q,2)+" - "+GetMsg("prop7")+mformat(GetSQLColumnData(q,1).tointeger()/2)+".");
			IncreaseCash(player,GetSQLColumnData(q,1).tointeger()/2); FreeSQLQuery(q);
	}}
	else if ( cmd == "myprops" ) {
	local q=QuerySQL( db, "SELECT Name, rowid FROM Properties WHERE Owner LIKE '" + player.Name + "'" );
	if ( !player.IsSpawned ) PrivMessage( GetMsg("respaw"), player );
	else {
	if ( !GetSQLColumnData( q, 0 ) ) PrivMessage( GetMsg("prop8"), player );
	while ( GetSQLColumnData(q,0)) {
	PrivMessage( GetSQLColumnData( q, 0 ) + " - ID " + GetSQLColumnData( q, 1 ), player );
	GetSQLNextRow(q);
	if (!q) { break; FreeSQLQuery(q); }
	}}}
	else if ( cmd == "spree" ) {
		local a = 0, b = null;
		while ( a < GetMaxPlayers() ) {
			local plr = FindPlayer( a );
			if ( plr ) {
				local spree =  PlayerSpree( plr );
				if ( spree >= 10 ) {
					if ( b ) b = b + " - " + plr.Name + " (" + spree + ")";
					else b = plr.Name + " (" + spree + ")";
		}}
		a ++;
	}
	if ( b ) { 
		Echo( GetMsgIRC("spree1") + b ); 
		print( GetMsg("spree6") + b );
		msg( GetMsg("spree6") + b, 0, 200, 0 );
	}
	else {
		Echo( GetMsgIRC("spree2") );
		print( GetMsg("spree7") );
		msg( GetMsg("spree7" ), 200, 0, 0 );
	}}
	else if ( cmd == "stat" || cmd == "stats" ){
	if ( !plr ) PrivMessage( GetMsg("errornick"), player );
		else {
		local PLevel = PlayerLevel( plr );
		if ( PLevel == 0 ) {
			msg( "* " + plr + " " + GetMsg("reg4"), 200, 0, 0 ); 
			print( "* " + plr + " " + GetMsg("reg4") );
			Echo( "* 3" + plr + " 4" + GetMsg("reg4") );
		}
		else {
				local Tog = StatsToggle( plr );
				if ( Tog == "off" ) PrivMessage( "* " + plr + " " + GetMsg("stats1"), player );
				else {
					local PKills = PlayerKills( plr ), PDeaths = PlayerDeaths( plr ), Joins = PlayerJoins(plr), Spree = PlayerSSpree(plr), Ratio;
					if ((PKills > 0) && (PDeaths > 0)) { Ratio=PKills.tofloat()/PDeaths.tofloat(); Ratio=format("%.2f",Ratio); }
					if ( Ratio ) { 
					msg( "* Stats: " + plr + ", Joins: " + Joins + ", Kills: " + PKills + " Deaths: " + PDeaths + " Spree's: " + Spree + " Ratio: " + Ratio, 139, 69, 19 );
					Echo( "* 5Stats: " + plr + ", Joins: " + Joins + ", Kills: " + PKills + " Deaths: " + PDeaths + " Spree's: " + Spree + " Ratio: " + Ratio );
					print( "* Stats: " + plr + ", Joins: " + Joins + ", Kills: " + PKills + " Deaths: " + PDeaths + " Spree's: " + Spree + " Ratio: " + Ratio );
					}
					else {
					msg( "* Stats: " + plr + ", Joins: " + Joins + ", Kills: " + PKills + " Deaths: " + PDeaths + " Spree's: " + Spree, 139, 69, 19 );
					Echo( "* 5Stats: " + plr + ", Joins: " + Joins + ", Kills: " + PKills + " Deaths: " + PDeaths + " Spree's: " + Spree );
					print( "* Stats: " + plr + ", Joins: " + Joins + ", Kills: " + PKills + " Deaths: " + PDeaths + " Spree's: " + Spree );
	}}}}}
	else if ( cmd == "disarm" ) {
	if ( !player.IsSpawned ) PrivMessage( GetMsg( "respaw" ), player );
	else { PrivMessage(GetMsg("disarm1"),player); player.SetWeapon(0,0); }
	}
	else if ( cmd == "wep" || cmd == "we" ) {
	local wep, wepname;
	if ( !text ) PrivMessage( GetMsg( "wep1" ) + " " + cmd + " " + GetMsg( "wep2" ), player );
	else if ( !player.IsSpawned ) PrivMessage( GetMsg( "respaw" ), player );
	else {
		local arms = Replace( text, ",", " " ), a = 1, nun = NumTok( arms, " " );
		while ( a <= nun ) {
			local wep2 = GetTok( arms, " ", a );
			if ( IsNum( wep2 ) ) wep = wep2;
			else wep = GetWeaponID( wep2 );	
			if ( !ValidWep( wep ) ) {
			PrivMessage( wep2 + " - " + GetMsg( "wep3" ), player );
			a = a + 1;
			}
			else {
				if ( wepname ) wepname = wepname + "-" + GetWeaponName( wep );
				else wepname = GetWeaponName( wep );
				player.SetWeapon( wep, 900 );
				a++;
			}}
			if ( wepname ) {
			Message( "* " + GetMsg( "wep4" ) + " " + wepname + " - " + player );
			Echo( "2* 10" + GetMsg( "wep4" ) + " " +  wepname + " - " + player );
	}}}
	else if ( cmd == "goto" ) {
	local Cash=PlayerCash(player);
	if ( !text ) PrivMessage( GetMsg("wep1") + "!" + cmd + " <Nick/ID>", player );
	else if ( !plr ) PrivMessage( GetMsg("errornick"), player );
	else {
	cost=GetDistance(player.Pos,plr.Pos); cost=format("%.f",(cost)).tointeger();
	if ( plr.ID == player.ID ) PrivMessage( GetMsg("goto1"), player );
	else if ( Cash < cost ) PrivMessage( GetMsg("goto2")+" $"mformat(cost), player );
	else if ( !player.IsSpawned ) PrivMessage( GetMsg("respaw"), player );
	else {
		local Toggle = GoToToggle( plr );
		if ( Toggle == "on" ) PrivMessage( GetMsg("goto3"), player );
		else {
			msg( "* " + player + " " + GetMsg("goto4") + " " + plr + " " + GetMsg("goto5") + " $"+mformat(cost), 34, 139, 34 );
			Echo( "10* " + player + " " + GetMsg("goto4") + " " + plr + " " + GetMsg("goto5") + " $"+mformat(cost) );
			DecreaseCash(player,cost);
			player.Pos = plr.Pos;
	}}}}
	else if ( cmd == "cash" ) {
		PrivMessage("Balance: "+GetMsg("money1")+mformat(PlayerCash( player ))+" "+GetMsg("money2")+mformat(PlayerBank( player )),player);
		Announce( "~b~$"+mformat(PlayerCash( player )), player );
	}
	else if ( cmd == "showcash" ) {
		local TheMSG = player+" "+"Balance: "+GetMsg("money1")+mformat(PlayerCash( player ))+" "+GetMsg("money2")+mformat(PlayerBank( player ));
		msg(">> "+TheMSG,25,25,112);
		Echo("10>> "+TheMSG);
		print(TheMSG);
	}
	else if ( cmd == "deposit" ) {
	if ( !text ) PrivMessage("!"+cmd+" <amount/all>", player);
	else if ( onBank( player ) != true ) PrivMessage( GetMsg("nobank"), player );
	else {
	local Cash = PlayerCash( player );
	if ( text == "all" ) {
	if ( Cash == 0 ) PrivMessage( GetMsg("depostit1"), player );
	else {
	DecreaseCash( player, Cash );
	IncreaseBank( player, Cash );
	PrivMessage(GetMsg("deposit2"), player );
	PrivMessage("Balance: "+GetMsg("money1")+mformat(PlayerCash( player ))+" "+GetMsg("money2")+mformat(PlayerBank( player )),player);
	}}
	else {
	if ( !IsNum( text ) ) PrivMessage( GetMsg("deposit3"), player );
	else if ( Cash < text.tointeger() ) PrivMessage(GetMsg("depostit1"),player );
	else {
	DecreaseCash( player, text.tointeger() );
	IncreaseBank( player, text.tointeger() );
	PrivMessage(GetMsg("deposit2"), player );
	PrivMessage("Balance: "+GetMsg("money1")+mformat(PlayerCash( player ))+" "+GetMsg("money2")+mformat(PlayerBank( player )),player);
	}}}}
	else if ( cmd == "withdraw" ) {
	if ( !text ) PrivMessage("!"+cmd+" <amount/all>", player);
	else if ( onBank( player ) != true ) PrivMessage( GetMsg("nobank"), player );
	else {
	local Bank = PlayerBank( player );
	if ( text == "all" ) {
	if ( Bank == 0 ) PrivMessage(GetMsg("depostit1"),player );
	else {
	IncreaseCash( player, Bank );
	DecreaseBank( player, Bank );
	PrivMessage( GetMsg("withdraw1"), player );
	PrivMessage("Balance: "+GetMsg("money1")+mformat(PlayerCash( player ))+" "+GetMsg("money2")+mformat(PlayerBank( player )),player);
	}}
	else {
	if ( !IsNum( text ) ) PrivMessage( GetMsg("deposit3"), player );
	else if ( Bank < text.tointeger() ) PrivMessage(GetMsg("depostit1"),player );
	else {
	IncreaseCash( player, text.tointeger() );
	DecreaseBank( player, text.tointeger() );
	PrivMessage( GetMsg("withdraw1"), player );
	PrivMessage("Balance: "+GetMsg("money1")+mformat(PlayerCash( player ))+" "+GetMsg("money2")+mformat(PlayerBank( player )),player);
	}}}}
	else if ( cmd == "saveloc" ) {
	if ( !text ) PrivMessage( GetMsg("saveloc1"), player );
	else if ( !player.IsSpawned ) PrivMessage( GetMsg("respaw"), player );
	else if ( FindGotoLoc( text ) ) PrivMessage( GetMsg("saveloc2"), player );
	else {
		local a=QuerySQL( db, "INSERT INTO Gotoloc (Name, x, y, z, Creator) values ( '" + text + "', '" + player.Pos.x + "', '" + player.Pos.y + "', '" + player.Pos.z + "', '" + player.Name + "' )" );
		FreeSQLQuery( a );
		PrivMessage( GetMsg("saveloc3") + " " + text, player );                                       
	}}
	else if (cmd == "gotoloc") {          
	if ( !text ) PrivMessage( "!"+cmd+" <locname>", player );
	else if ( !player.IsSpawned ) PrivMessage( GetMsg("respaw"), player );
	else {
	local q = QuerySQL( db, "SELECT x, y, z, Creator FROM Gotoloc WHERE Name = '"+ text +"'" );
	if (GetSQLColumnData(q,0) != null) {
		local x = GetSQLColumnData(q,0), y = GetSQLColumnData(q,1), z = GetSQLColumnData(q,2), Creator = GetSQLColumnData(q,3);
		GotolocPut(player,x,y,z);
		PrivMessage( GetMsg("gotoloc2") + " " + text + " - Creator: " + Creator + ".", player );
	}
	else PrivMessage(GetMsg("gotoloc3"), player);
	}}
	else if (cmd == "randloc") {
	if ( !player.IsSpawned ) PrivMessage( GetMsg("respaw"), player );
	else {
	local name=GotolocRand();
	local q=QuerySQL(db,"SELECT x, y, z, Creator FROM Gotoloc WHERE Name = '"+name+"'");
	local x = GetSQLColumnData(q,0), y = GetSQLColumnData(q,1), z = GetSQLColumnData(q,2), Creator = GetSQLColumnData(q,3);
	GotolocPut(player,x,y,z);
	PrivMessage(GetMsg("gotoloc2")+" "+name+" - Creator: "+Creator+".", player );
	}}
	else PrivMessage( GetMsg( "errorcmd" ), player );
}
//c Commands
function onPlayerCommand( player, cmd, text ) {
	local Level=PlayerLevel(player),Password=PlayerPassword(player),cmd=cmd.tolower(),plr,i,Logged=GetLoggedStatus(player);
	if (text) { i=NumTok(text," "); plr=GetPlayer(text); }
	else plr=player;
	
	if ( cmd == "register" ) {
		if ( !text ) PrivMessage( GetMsg("errorcmd2") + ", /c register <password>", player );
		else if ( Level != 0 ) PrivMessage( GetMsg("reg1"), player );
		else {
			PrivMessage( GetMsg("reg2"), player );
			msg( player + " " + GetMsg("reg2") + ".", 200, 0 , 200 );
			Echo( "10>> " + player + " " + GetMsg("reg2") + "." );
			PrivMessage( GetMsg("reg3") + " - " + text, player );
			player.IsFrozen = false;
			RegisterUser(player,text);
	}}
	else if ( cmd == "login" ) {
		if ( !text ) PrivMessage( GetMsg("errorcmd2") + ", /c login <password>", player );
		else if ( Level == 0 ) PrivMessage( GetMsg("login1"), player );
		else if ( text != Password ) PrivMessage( GetMsg("login2"), player );
		else if ( Logged == true ) PrivMessage( GetMsg("login3"), player );
		else {
			PrivMessage( GetMsg("login4"), player );
			PrivMessage( "New Auto-Login IP - " + player.IP, player );
			msg( "-> " + player + " " + GetMsg("login5") + " " + Level, 0 ,0, 200 );
			Echo( "->2 " + player + " " + GetMsg("login5") + " " + Level );
			player.IsFrozen = false;
			LoginPlayer( player );
	}}
	else if ( cmd == "logout" ) {
		if ( Level == 0 ) PrivMessage( GetMsg("login1"), player );
		else if ( Logged == true ) {
		Logout( player);
		PrivMessage( GetMsg("logut1"), player );
		PrivMessage( "/c login <Password>, " + GetMsg("logut2"), player );
		}
		else PrivMessage( GetMsg("logut3"), player );
	}
	else if ( cmd == "stat" ) {
	if ( !text ) PrivMessage( GetMsg("errorcmd2") + "/c stat <on/off>", player );
	else if ( Level == 0 ) PrivMessage( GetMsg("login1"), player );
	else if ( Logged == false ) PrivMessage( GetMsg("logut3"), player );
	else {
	local Toggle = StatsToggle( player );
	text = text.tolower();		
	if ( ( text != "on" ) && ( text != "off" ) ) PrivMessage( GetMsg("errorcmd2") + "/c stat <on/off>", player );
	else if ( text == "on" ) {
	if ( Toggle == "on" ) PrivMessage( GetMsg("stats2"), player );
	else {
	local a=QuerySQL(db,"UPDATE Stats SET Toggle = 'on' WHERE Name = '"+player.Name+"'"); FreeSQLQuery(a);
	PrivMessage( GetMsg("stats3"), player );
	}}
	else if ( text == "off" ) {
	if ( Toggle == "off" ) PrivMessage( GetMsg("stats4"), player );
	else {
	local a=QuerySQL(db,"UPDATE Stats SET Toggle = 'off' WHERE Name = '"+player.Name+"'" );FreeSQLQuery(a);
	PrivMessage( GetMsg("stats5"), player );
	}}}}
	else if ( cmd == "nogoto" ) {
	if ( !text ) PrivMessage( GetMsg("errorcmd2") + "/c nogoto <on/off>", player );
	else if ( Level == 0 ) PrivMessage( GetMsg("login1"), player );
	else if ( Logged == false ) PrivMessage( GetMsg("logut3"), player );
	else {
		local GToggle = GoToToggle( player );
		text = text.tolower();
		if ( ( text != "on" ) && ( text != "off" ) ) PrivMessage( GetMsg("errorcmd2") + "/c nogoto <on/off>", player );
		else if ( text == "on" ) {
		if ( GToggle == "on" ) PrivMessage( GetMsg("nogoto1"), player );
		else {
				local a=QuerySQL(db,"UPDATE Accounts SET Goto = 'on' WHERE Name = '"+player.Name+"'"); FreeSQLQuery(a);
				PrivMessage( GetMsg("nogoto2"), player );
		}}
		else if ( text == "off" ) {
		if ( GToggle == "off" ) PrivMessage( GetMsg("nogoto3"), player );
		else {
			local a=QuerySQL(db,"UPDATE Accounts SET Goto = 'off' WHERE Name = '"+player.Name+"'"); FreeSQLQuery(a);
			PrivMessage( GetMsg("nogoto4"), player );
	}}}}
	else if ( cmd == "ipm" ) {
	if (!text) PrivMessage("/c "+cmd+" <IrcUser> <Text>",player);
	else {
	local msg = GetTok(text," ",2,NumTok(text, " ")), usr = GetTok(text," ",1);
	if (!msg || !usr) PrivMessage("/c "+cmd+" <IrcUser> <Text>",player);
	else {
	if (FindIrcUserID(usr) >= 0) {
	PrivMessage(GetMsgIRC("pm1")+" "+usr+", '"+msg+"'",player);
	EchoN(usr,"(Server PM) ["+player.ID+"] "+player.Name+": "+msg);
	} else PrivMessage(usr+" No such nick/channel",player);
	}}}
	else if ( cmd == "exe" ) {
	if (!text) PrivMessage(GetMsgIRC("error1")+cmd+" "+GetMsgIRC("exe1"),player);
	else {
	try {
	local script=compilestring(text);
	script();
	}
	catch(e) { 
	PrivMessage("Error: "+e+".",player);
	}}}
	/*
	else if ( cmd == "savewep" ) {
	if ( !text ) PrivMessage( "/c "+cmd+" <wep1/wep2/wep3>", player );
	else {
	local wep
	if ( !player.IsSpawned ) PrivMessage( GetMsg("respaw"), player );
	else {
	}}}*/
	else PrivMessage( GetMsg( "errorcmd" ), player );
}
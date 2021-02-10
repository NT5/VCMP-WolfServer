class CLMS { IsStard=false; Wep=0; Loc=0; Players=0; }
class CMsg { Name=null; Messenge=null; }
class CServer { UpTime=GetTime(); OnCD=false; WeaterChange=0; Lenguaje=null; Registers=0; VerScript=0; }
class CPlayer {  
LoggedIn=false;
Kills=0; 
Deaths=0; 
Joins=0; 
Spree=0;
SSpree=0; 
Cash=0; 
Bank=0; 
TimePlay=0; 
SpawnPro=false; 
Hide=false; 
IsDrunk=false; 
Speedo=false;
Stunt=null;
}
LMSLoc <- [ 
"-1094.28332519, 1307.67419433, 34.24106979", "-1635.2369, -501.1630, 50.1828", "-969.2894, 743.3184, 57.2507", 
"-804.1165, 815.6527, 11.0846", "-70.8055, 568.1187, -84.2334, 9.4397", "-37.6370, 1197.8688, 21.4526" 
];
class CHunt { IsStard=false; Timer=null; Time=0; Player=null; Reward=0; }
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function LoadArrays() {
	Server<-CServer();
	PlayerInfo<-array(50,null);
	Server.Lenguaje=GetConfig("Lenguaje"); Server.Registers=GetConfig("Registers"); Server.VerScript=GetConfig("VerSript");
	IrcUsers <- array(51,null); Spam <- array(51,null); Away <- array(51,null); 
	EnMsg <- array(500,null); SpMsg <- array(500,null); EnIrcMsg <- array(500,null); SpIrcMsg <- array(500,null);

	LMS <- CLMS(); Hunt<-CHunt();
	LMSPlayer <- array( GetMaxPlayers(), false );
	for (local i=0; i<=GetMaxPlayers()-1; i++) { PlayerInfo[i]=CPlayer(); }
	for (local i=0; i<=SpMsg.len()-1; i++) { EnMsg[i]=CMsg(); SpMsg[i]=CMsg(); }
	for (local i=0; i<=SpIrcMsg.len()-1; i++) { EnIrcMsg[i]=CMsg(); SpIrcMsg[i]=CMsg(); }
	for (local i=0; i<=50; i++) { Spam[i]=CSPAM(); Away[i]=CAway(); }
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function RandomPlayer() {
if (GetPlayers() != 0) {
for(local plr,i=0; ; i++) {
plr = FindPlayer(0 + ((GetPlayers() - 0 + 1) * rand() / 32767).tointeger());
if (plr) { return plr; break; }
}}}
function StardHunt() {
Hunt.IsStard = true,Hunt.Player = RandomPlayer(), Hunt.Reward=GetPlayers()*500, Hunt.Time = GetTime();
Echo("Activate!,HUNT: "+Hunt.Player+", Duration:"+Hunt.Time+"min, Reward: $"+Hunt.Reward+".");
ClientMessageToAll("Activate!,HUNT: "+Hunt.Player+", Duration:"+Hunt.Time+"min, Reward: $"+Hunt.Reward+".",138,43,226);
Hunt.Timer=NewTimer("CloseHunt",GetPlayers()*60000,1,0,".");
}
function CloseHunt(idreason,reason) {
if (idreason == 0) {
Echo("Fail Hunt: "+Hunt.Player+"'s, nobody wanted the reward.");
ClientMessageToAll("Fail HUNT: "+Hunt.Player+"'s, nobody wanted the reward.",139,69,19);
Hunt.IsStard = false, Hunt.Player = null, Hunt.Reward = 0, Hunt.Time= 0;
} else if (idreason == 1) {
Echo("Hunt: "+Hunt.Player+"'s Canceled!, Reason:[ "+reason+" ]");
Hunt.Timer.Delete();
ClientMessageToAll("HUNT: "+Hunt.Player+"'s Canceled!, Reason:[ "+reason+" ]",139,69,19);
Hunt.IsStard = false, Hunt.Player = null, Hunt.Reward = 0, Hunt.Time= 0;
}}
function TimeHunt() {
	local srt = "", m, s, ms, secs =  Hunt.Time - GetPlayers()*60000;
	ms = secs % 3600, m = ms / 60, s = ms % 60;
	if ( s > 0 ) srt = s + "sec ";
	if ( m > 0 ) srt = m + "min " + srt;
	return srt;
}
function Random(min, max) return min + ((max - min + 1) * rand() / 32767).tointeger();
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function RestoreArrays( player ) {
local id=player.ID;
PlayerInfo[id].LoggedIn=false; 
PlayerInfo[id].Spree=0;
PlayerInfo[id].SSpree=0;
PlayerInfo[id].TimePlay=0;
PlayerInfo[id].Hide=false;
PlayerInfo[id].IsDrunk=false; 
PlayerInfo[id].Speedo=false;
PlayerInfo[id].Stunt=null;
PlayerInfo[id].SpawnPro=false;  
PlayerInfo[id].Kills=0; 
PlayerInfo[id].Deaths=0;
PlayerInfo[id].Joins=0;
PlayerInfo[id].Cash=0; 
PlayerInfo[id].Bank=0;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function LoadPlayerData(player) {
if (player) {
local f=QuerySQL(db,"SELECT Cash, Bank FROM Finance WHERE Name LIKE '"+player+"'");
local s=QuerySQL(db,"SELECT Kills, Deaths, Toggle, Joins, Spree FROM Stats WHERE Name LIKE '"+player+"'");
PlayerInfo[player.ID].SSpree=GetSQLColumnData(s,4);
PlayerInfo[player.ID].Kills=GetSQLColumnData(s,0); 
PlayerInfo[player.ID].Deaths=GetSQLColumnData(s,1);
PlayerInfo[player.ID].Joins=GetSQLColumnData(s,3); 
PlayerInfo[player.ID].Cash=GetSQLColumnData(f,0); 
PlayerInfo[player.ID].Bank=GetSQLColumnData(f,1); 
FreeSQLQuery(f); FreeSQLQuery(s);
}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function SavePlayerData(player) {
if (player) {
local id=player.ID;
local f=QuerySQL(db,"UPDATE Finance SET Cash='"+PlayerInfo[id].Cash+"',Bank='"+PlayerInfo[id].Bank+"' WHERE Name='"+player.Name+"'");
local s=QuerySQL(db,"UPDATE Stats SET Kills='"+PlayerInfo[id].Kills+"',Deaths='"+PlayerInfo[id].Deaths+"',Joins='"+PlayerInfo[id].Joins+"',Spree='"+PlayerInfo[id].SSpree+"' WHERE Name='"+player.Name+"'");
FreeSQLQuery(f); FreeSQLQuery(s);
}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function AutoKick( player, reason ) {
	if (GetLoggedStatus(player) == true ) {
	if ( PlayerInfo[player.ID].Spree >= 10 ) {
	msg( "* "+player+" "+GetMsg("spree9"),250,0,0);
	Echo("4* "+player+" "+GetMsg("spree9")); 
	print("* "+player+" "+GetMsg("spree9")); }
	RestoreArrays(player);
	}
	msg( "* Auto-Kick:[ "+player+" ] Reason:[ "+reason+" ]",200,0,0);	
	Echo( "* 4Auto-Kick:[ "+player+" ] Reason:[ "+reason+" ]");
	print( "* Auto-Kick:[ " +player+" ] Reason:[ "+reason+" ]");		
	KickPlayer(player);
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function SpawnProOff(player) if (PlayerInfo[player.ID].SpawnPro) PlayerInfo[player.ID].SpawnPro=false;
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function KillPlayer( player, reason ) {
player.Health = 0;
Echo( "4>"+player+" "+GetMsg("kill1")+" "+reason );
msg( ">"+player+" "+GetMsg("kill1")+" "+reason, 200, 0, 0);
print( ">"+player+" "+GetMsg("kill1")+" "+reason);
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function RandNum(start, finish) {
	local t;
	if (start<0) t=((rand()%(-start+finish))+start)
	else  t=((rand()%(finish-start))+start);
	return t;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function LoadVehicles() {
	local total=ReadIniString("database/Vehicles.ini","Count","CountVehicles"),i=0,vehicle;
	local model,x,y,z,angle,col1,col2;
	print("--- Loading Server Vehicles... ---");
	while (i<=total.tointeger()) {
	vehicle=ReadIniString("database/Vehicles.ini","Vehicles",i.tostring());
	if (vehicle.len()>1) {
	model=split(vehicle," ")[0],x=split(vehicle," ")[1],y=split(vehicle," ")[2],z=split(vehicle," ")[3],angle=split(vehicle," ")[4],col1=split(vehicle," ")[5],col2=split(vehicle," ")[6];
	CreateVehicle(model.tointeger(),Vector(x.tofloat(),y.tofloat(),z.tofloat()),angle.tofloat(),col1.tointeger(),col2.tointeger());
	}
	i++;
	}
	print("Complete Vehicles Load.");
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function LoadMessenges() {
MSdb<-ConnectSQL("Messenges/Server.lgn");
if(!MSdb) print("Failed. Not Open Messenges");
else {
local Sq=QuerySQL(MSdb,"SELECT Name, SPMSG FROM Messenges WHERE rowid LIKE '1'"),i=1,
Eq=QuerySQL(MSdb,"SELECT Name, ENMSG FROM Messenges WHERE rowid LIKE '1'");
print("Loading Server Messages...");
while (i<SpMsg.len()-1) {
SpMsg[i].Name=GetSQLColumnData(Sq,0),SpMsg[i].Messenge=GetSQLColumnData(Sq,1);
EnMsg[i].Name=GetSQLColumnData(Eq,0),EnMsg[i].Messenge=GetSQLColumnData(Eq,1);
i++; Sq=QuerySQL(MSdb,"SELECT Name, SPMSG FROM Messenges WHERE rowid LIKE '"+i+"'");
Eq=QuerySQL(MSdb,"SELECT Name, ENMSG FROM Messenges WHERE rowid LIKE '"+i+"'");
} FreeSQLQuery(Sq); FreeSQLQuery(Eq); DisconnectSQL(MSdb); print("Complete Server Message Load."); }}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function LoadIrcMessenges() {
MIdb<-ConnectSQL("Messenges/IRC.lgn");
if(!MIdb) print("Failed. Not Open Messenges");
else {
local Sq=QuerySQL(MIdb,"SELECT Name, SPMSG FROM Messenges WHERE rowid LIKE '1'"),i=1,
Eq=QuerySQL(MIdb,"SELECT Name, ENMSG FROM Messenges WHERE rowid LIKE '1'");
print("Loading Irc Messages...");
while (i<SpIrcMsg.len()) {
SpIrcMsg[i-1].Name=GetSQLColumnData(Sq,0),SpIrcMsg[i-1].Messenge=GetSQLColumnData(Sq,1);
EnIrcMsg[i-1].Name=GetSQLColumnData(Eq,0),EnIrcMsg[i-1].Messenge=GetSQLColumnData(Eq,1);
i++; Sq=QuerySQL(MIdb,"SELECT Name, SPMSG FROM Messenges WHERE rowid LIKE '"+i+"'");
Eq=QuerySQL(MIdb,"SELECT Name, ENMSG FROM Messenges WHERE rowid LIKE '"+i+"'");
} FreeSQLQuery(Sq); FreeSQLQuery(Eq); DisconnectSQL(MIdb); print("Complete Irc Message Load."); }}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function LoadProps() {
	local q=QuerySQL(db,"SELECT Pos FROM Properties WHERE rowid LIKE '%'");
	while (GetSQLColumnData(q,0)) {
		local SplitPos=split(GetSQLColumnData(q,0)," ");
		local x = SplitPos[ 0 ], y = SplitPos[ 1 ], z = SplitPos[ 2 ];
		CreatePickup( 407, Vector( x.tofloat(), y.tofloat(), z.tofloat() ) );
		GetSQLNextRow( q );
	}
	FreeSQLQuery(q);
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function AccountInfo( player ) {
	local AccountIP = Getip( player ), Level = PlayerLevel( player );
	if ( Level != 0 ) {
		if ( player.IP == AccountIP ) {
			PrivMessage( GetMsg("welcome1") + ", " + player + "!", player );
			PrivMessage( GetMsg("welcome2") + Level, player );
			PrivMessage( "Auto-Login IP - " + player.IP, player );
			SendIRCUsers(player);
			msg( "-> " + player + " " + GetMsg("welcome2") + " " + Level, 200, 0, 200 );
			Echo( "12-> " + player + " " + GetMsg("welcome2") + " " + Level );
			print( "-> " + player + " " + GetMsg("welcome2") + " " + Level );
			LoginPlayer( player );
		}
		if ( player.IP != AccountIP ) {
			PrivMessage( GetMsg("welcome1") + " " + player + "!", player );
			PrivMessage( GetMsg("welcome3"), player );
			PrivMessage( "IRC Users: "+Bot.Users,player );			
	}}
	else {
		PrivMessage( GetMsg("welcome4") + " " + player + "!", player );
		PrivMessage( GetMsg("welcome5") + " " + ", /c register <password>", player );
		PrivMessage( GetMsg("welcome6"), player );
		PrivMessage( "IRC Users: "+Bot.Users,player );
}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function GetBodyPart(id) {
local Part="Unknown";
if (id==0) Part = "Body";
if (id==1) Part = "Torso";
if (id==2) Part = "Left Arm";
if (id==3) Part = "Right Arm";
if (id==4) Part = "Left Leg";
if (id==5) Part = "Right Leg";
if (id==6) Part = "Head";
return Part;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function GetPartReason(reason) {
local re = "Unknown";
if (reason==PARTREASON_DISCONNECTED) re="Quit";
if (reason==PARTREASON_TIMEOUT) re="Crash/Timeout";
if (reason==PARTREASON_KICKED) re="Kicked";
if (reason==PARTREASON_BANNED) re="Banned";
return re;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function LevelTag(level) {
	local lvl;
	if (level == 0) lvl = "No Registered";
	if (level == 1) lvl = "Member";
    if (level == 5) lvl = "Moderator";
	if (level == 6) lvl = "Admin";
	else if (level >= 7) lvl = "Management";
	return lvl;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function TranSecs(secs) return secs/0.001;
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function ServerSpam(player,text) {
	local id = player.ID
	Spam[id].CServer++;
	if (!Spam[id].TServer) Spam[id].TServer=text;
	if (!Spam[id].TiServer) Spam[id].TiServer=GetTime();
	if (Spam[id].CServer >= 3 && Spam[id].TServer == text && GetTime()-Spam[id].TiServer <= 5) {
	msg("Spam "+Spam[id].CServer+"Reps, "+duration(Spam[id].TiServer),200,0,0);
	Spam[id].CServer=0; Spam[id].TServer=null; Spam[id].TiServer=0;
	}
	if (Spam[id].CServer >= 5 && GetTime()-Spam[id].TiServer >= 5) { Spam[id].CServer=0; Spam[id].TServer=null; Spam[id].TiServer=0; }
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function OnStunt(player) {
if (!player.Vehicle) {
PlayerInfo[player.ID].Stunt=null;
StuntCheck.Delete();
} else {
local ThePos=format("%i",(player.Pos.z)).tointeger();
local oldpos=split(PlayerInfo[player.ID].Stunt," ")[0].tointeger();
local Theoldpos=split(PlayerInfo[player.ID].Stunt," ")[1].tointeger()+1;
local Thealture=split(PlayerInfo[player.ID].Stunt," ")[2].tointeger()+1;
local gan=Theoldpos+Thealture;
oldpos+=2;
if (oldpos<ThePos) {
 Announce("~t~\x10 \x10 \x10 stunt $"+mformat(gan),player);
 IncreaseCash(player,gan);
 PlayerInfo[player.ID].Stunt=format("%i",(player.Pos.z))+" 0 0";
}
else PlayerInfo[player.ID].Stunt=format("%i",(player.Pos.z))+" "+Theoldpos+" "+Thealture;
}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function SpeedoVehicle( player ) {
	if ( player.Vehicle ) {
	local param = split( PlayerInfo[player.ID].Speedo, " " );
	Announce(format( "~b~K~p~p~y~H: ~b~ %i",(sqrt((player.Pos.x-param[0].tofloat())*(player.Pos.x-param[0].tofloat())+(player.Pos.y-param[1].tofloat())*(player.Pos.y-param[1].tofloat())+(player.Pos.z-param[2].tofloat())*(player.Pos.z-param[2].tofloat()) ) )*2.8),player,1);
	PlayerInfo[player.ID].Speedo = format("%.4f %.4f %.4f", player.Pos.x, player.Pos.y, player.Pos.z );
	} else {
	Announce("\x10",player,1); 
	PlayerInfo[player.ID].Speedo = false; 
	SeedoMeterV.Delete();
}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function GetIpLoc(IP) {
	local result, query;
	database <- ConnectSQL( "database/IpDb.db" );	
	if( database ) {
	if ( IP == "127.0.0.1" ) query = "Localhost";
	else {
	local IPsplit = split( IP, "." );
	if ( IPsplit.len() != 4 ) query = "Invalid IP";
	else {
	query = format("SELECT Country FROM countrydetected WHERE Ip_From <= ((16777216*%d) + (65536*%d) + (256*%d) + %d) AND Ip_to >= ((16777216*%d) + (65536*%d) + (256*%d) + %d) LIMIT 1", IPsplit[0].tointeger(), IPsplit[1].tointeger(), IPsplit[2].tointeger(), IPsplit[3].tointeger(), IPsplit[0].tointeger(), IPsplit[1].tointeger(), IPsplit[2].tointeger(), IPsplit[3].tointeger());
	result = QuerySQL(database, query);
	query = GetSQLColumnData( result, 0 );
	if( !query ) query = "Unknown"; 
	FreeSQLQuery( result );
	}}
	DisconnectSQL( database ); } 
	else query = "Failed. Not Open Database";
	return query;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function msg(text,r,g,b) ClientMessageToAll(text,r,g,b);
function SetLenguaje(text) {
local leng;
if (text == 1) leng="Spanish",Server.Lenguaje="Spanish";
else if (text == 2) leng="English",Server.Lenguaje="English";
local a = QuerySQL(db,"UPDATE ServerConfig SET Param = '"+leng+"' WHERE Name = 'Lenguaje'");
FreeSQLQuery(a);
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function GetMsg(name) {
if (Server.Lenguaje=="Spanish" ) {
for (local i=0; i<SpMsg.len(); i++) {
if (SpMsg[i].Name==name) { return SpMsg[i].Messenge; break; }
if (i==SpMsg.len()-1) return "GetMsg() The Index '"+name+"' Does Not Exist.";
}}
if (Server.Lenguaje=="English" ) {
for (local i=0; i<EnMsg.len(); i++) {
if (EnMsg[i].Name==name) { return EnMsg[i].Messenge; break; }
if (i==EnMsg.len()-1) return "GetMsg() The Index '"+name+"' Does Not Exist.";
}}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function GetMsgIRC(name) {
if (Server.Lenguaje=="Spanish" ) {
for (local i=0; i<SpIrcMsg.len(); i++) {
if (SpIrcMsg[i].Name==name) { return SpIrcMsg[i].Messenge; break; }
if (i==SpIrcMsg.len()-1) return "GetMsgIrc() The Index '"+name+"' Does Not Exist.";
}}
if (Server.Lenguaje=="English" ) {
for (local i=0; i<EnIrcMsg.len(); i++) {
if (EnIrcMsg[i].Name==name) { return EnIrcMsg[i].Messenge; break; }
if (i==EnIrcMsg.len()-1) return "GetMsgIrc() The Index '"+name+"' Does Not Exist.";
}}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function GetConfig( param ) {
local q, ret;
q=QuerySQL(db,"SELECT Name, Param FROM ServerConfig WHERE Name LIKE '"+param+"'" );
ret = GetSQLColumnData( q, 1 ); FreeSQLQuery(q);
if ( ret ) return ret;
else return "GetConfig() The Index '" + param + "' Not Exist.";
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function GetText(text,n) {
local b,i=n,t=text;
while (i<split(text," ").len()) {
if (!b) b=split(t," ")[i];
else b=b+" "+split(t," ")[i];
i++;
} return b;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function ClanTag(strPlayer) {
	local D_DELIM = regexp(@"([\[(=^<]+\w+[\])=^>]+)").capture(strPlayer),S_DELIM = regexp(@"(\w.+[.*=]+)").capture(strPlayer);
	if ( D_DELIM != null ) return strPlayer.slice( D_DELIM[ 0 ].begin, D_DELIM[ 0 ].end );
	else if ( S_DELIM != null ) return strPlayer.slice( S_DELIM[ 0 ].begin, S_DELIM[ 0 ].end );
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function GetDistance( v1, v2 ) return sqrt( (v2.x-v1.x)*(v2.x-v1.x) + (v2.y-v1.y)*(v2.y-v1.y) + (v2.z-v1.z)*(v2.z-v1.z) );
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function Replace( text, oldchar, newchar ) {
local Str = "";
foreach(i, char in text) {
local chr = char.tochar();
if ( chr == oldchar ) chr = newchar;
Str += chr;
}
return Str;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function Remove(text,char) {
local b,i=0;
while (i<split(text," ").len()) {
if (!b) b=split(text,char)[i];
else b=b+" "+split(text,char)[i];
i++;
} return b;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function Iswm(text,char) {
char=char.slice(0,1);
for (local i=0; i<text.len(); i++) {
if(text.slice(i,i+1) == char) { return true; break; }
}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function IsOn(Text,TheText) {
for (local i=0; i<split(Text," ").len(); i++) {
if (split(Text," ")[i]==TheText) return true;
}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function mformat( x ) {
local v = "";
local nvm = x % 1000;
while(nvm != x) {
Echo(nvm);
v = format(",%03d", (nvm < 0 ? -nvm : nvm)) + v;
x /= 1000;
nvm = x % 1000;
}
v = nvm.tostring() + v;
return v;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
/*function duration(secs) {
	local srt = "", d, h, m, s, ms, secs = GetTime() - secs;
	if (secs) { 
		h = secs / 3600, ms = secs % 3600, m = ms / 60, s = ms % 60, d = h/24;
		if ( s > 0 ) srt = s + "sec ";
		if ( m > 0 ) srt = m + "min " + srt;
		if ( h > 0 ) srt = h + "hrs " + srt;
		if ( d > 0 ) srt = d + "days " + srt;
	    return srt;
}}*/
function duration(secs) {
local secs = GetTime() - secs;
local days = "", hours = "", minutes = "", seconds = "", remainder;
days = floor(secs / 86400);
remainder = floor(secs % 86400);
hours = floor(remainder / 3600);
remainder = floor(remainder % 3600);
minutes = floor(remainder / 60);
seconds = floor(remainder % 60);

if (days > 0) days = days+"day ";
if (hours > 0) hours = hours+"hrs ";
if (minutes > 0) minutes = minutes+"mins ";
if (seconds > 0) seconds = seconds+"segs";
return days+hours+minutes+seconds;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function KillsTop() {
	local q = QuerySQL( db, "SELECT kills, name FROM stats ORDER BY kills DESC LIMIT 3");
	local tmp = "", i = 1;
	while ( GetSQLColumnData( q, 0 ) != null ) {
     	tmp = tmp + i + "). " + GetSQLColumnData( q, 1 ) + ": " + GetSQLColumnData( q, 0 ) + " - ";
		GetSQLNextRow( q );
		if ( !q ) break;
		i++;
	}
	return tmp != "" ? tmp.slice(0, tmp.len() - 2) : "No top killers!";
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function SpreeTop() {
	local q = QuerySQL( db, "SELECT Spree, Name FROM Stats ORDER BY Spree DESC LIMIT 3");
	local tmp = "", i = 1;
	while ( GetSQLColumnData( q, 0 ) != null ) {
     	tmp = tmp + i + "). " + GetSQLColumnData( q, 1 ) + ": " + GetSQLColumnData( q, 0 ) + " - ";
		GetSQLNextRow( q );
		if ( !q ) break;
		i++;
	}
	return tmp != "" ? tmp.slice(0, tmp.len() - 2) : "No top killers!";
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
/*function CheckLMS()
{
if (LMS.Players == 1 || LMS.Players == 0)
{
Echo("4>"+GetMsg("lms4") );
msg( GetMsg("lms4"), 200, 0, 0 );
print( GetMsg("lms4") );
LMS.IsStard = false; 
LMS.Players = 0;
UnFrezeLMS();
local a=0,plr=FindPlayer(a); 
while (a < GetMaxPlayers()) { 
if(LMSPlayer[a] == true) LMSPlayer[a] = false; 
a++;
}
}
else StartLMS();
}
function ParceLMS()
{
if (LMS.IsStard == false)
{
local wep, locx, locy, r = RandNum(1,10), rl = LMSLoc[RandNum(0,5)];
if (r == 1) { wep = 21; } 
if (r == 6) { wep = 15; }
if (r == 2) { wep = 22; } 
if (r == 7) { wep = 10; }
if (r == 3) { wep = 26; } 
if (r == 8) { wep = 25; }
if (r == 4) { wep = 19; } 
if (r == 9) { wep = 32; }
if (r == 5) { wep = 18; } 
if (r == 10) { wep = 24;}
locx = GetTok( rl, ",", 1 ), locy = GetTok( rl, ",", 2 );
Echo("10>"+GetMsg("lms1")+" "+GetWeaponName(wep)+" "+GetMsg("lms2")+" "+GetDistrictName(locx.tofloat(),locy.tofloat()));
msg(GetMsg("lms1")+" "+GetWeaponName(wep)+" "+GetMsg("lms2")+" "+GetDistrictName(locx.tofloat(),locy.tofloat()), 200, 0, 0);
print(GetMsg("lms1")+" "+GetWeaponName(wep)+" "+GetMsg("lms2")+" "+GetDistrictName(locx.tofloat(),locy.tofloat()));
LMS.IsStard = true;
LMS.Loc = rl;
LMS.Wep = wep;
NewTimer( "CheckLMS", 20000, 1);
}
}
function JoinLMS( player )
{
local x,y,z;
x = GetTok( LMS.Loc, ",", 1 ).tofloat(), y = GetTok( LMS.Loc, ",", 2 ).tofloat(), z =GetTok( LMS.Loc, ",", 3 ).tofloat();
player.Pos = Vector(x,y,z);
player.IsFrozen = true;
player.SetWeapon(0, 0);
player.SetWeapon(LMS.Wep, 900);
LMSPlayer[player.ID] = true;
if (LMS.Players == 0) LMS.Players=1;
else LMS.Players = LMS.Players+1;
Echo("3>"+player+" "+GetMsg("lms3"));
msg(player+" "+GetMsg("lms3"), 107,66,38);
print(player+" "+GetMsg("lms3"));
}
function StartLMS()
{
Echo("6>"+GetMsg("lms5"));
msg(GetMsg("lms5"),34,139,34);
print(GetMsg("lms5"));
local a=0,plr=FindPlayer(a);
while (a < GetMaxPlayers())
{
if (LMSPlayer[a] == true) {
Announce( "~b~-~o~ 3 ~b~-", FindPlayer(a) );
NewTimer( "Announce", 1000, 1, "~b~-~o~ 2 ~b~-", FindPlayer(a) );
NewTimer( "Announce", 2000, 1, "~b~-~o~ 1 ~b~-", FindPlayer(a) );
NewTimer( "Announce", 3000, 1, "~b~-~g~ go! ~b~-", FindPlayer(a) );
NewTimer( "UnFrezeLMS", 3000, 1);
}
a++;
}
}
function UnFrezeLMS()
{
local a=0; 
while (a < GetMaxPlayers()) { 
if(LMSPlayer[a] == true) FindPlayer(a).IsFrozen = false; 
a++;
}
}
function EndLMS()
{
if (LMS.Players == 0)
{
Echo("LMS END WIN: NONE!");
LMS.IsStard = false; 
LMS.Players = 0;
UnFrezeLMS();
}
local name,a=0; 
while (a < GetMaxPlayers()) { 
if(LMSPlayer[a] == true) name=FindPlayer(a); 
a++;
}
if (name)
{
Echo("3>"+GetMsg("lms10")+" "+name);
msg("3>"+GetMsg("lms10")+" "+name,0,250,0);
print("3>"+GetMsg("lms10")+" "+name);
LMS.IsStard = false; 
LMS.Players = 0;
UnFrezeLMS();
LMSPlayer[a] = false; 
}
}*/
function EndCD() Server.OnCD=false;
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function PlayerSpree( player ) return PlayerInfo[player.ID].Spree;
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function IsSpree( killer ) {
	local Kills = PlayerInfo[killer.ID].Spree, reward = Kills * 500;
	if ( Kills == 5 || Kills == 20 ) return;
	else if ( Kills == 10 ) {
	msg( "* " + killer.Name + " " + GetMsg("spree1") + " " + Kills + " " + GetMsg("spreek"), 200, 0, 0 );
	msg( GetMsg("spreer") + mformat( reward ), 112, 216, 219 );
	Echo( "4>> " + killer.Name + " " + GetMsg("spree1") + " " + Kills + " " + GetMsg("spreek") );
	Echo( "10> " + GetMsg("spreer") + mformat( reward ) );
	Announce( "~o~Killing Spree", killer );
	IncreaseCash( killer, reward );
	IncreaseSSpree( killer, 10 );
	}
	else if ( Kills == 15 ) {
	msg( "* " + killer.Name + " " + GetMsg("spree2") + " " + Kills + " " + GetMsg("spreek"), 200, 0, 0 );
	msg( GetMsg("spreer") + mformat( reward ), 112, 216, 219 );
	Echo( "4>> " + killer.Name + " " + GetMsg("spree2") + " " + Kills + " " + GetMsg("spreek") );
	Echo( "10> " + GetMsg("spreer") + mformat( reward ) );
	Announce( "~o~Dangerous Spree", killer );
	IncreaseCash( killer, reward );
	IncreaseSSpree( killer, 15 );
	}
	else if ( Kills == 25 ) {
	msg( "* " + killer.Name + " " + GetMsg("spree3") + " " + Kills + " " + GetMsg("spreek"), 200, 0, 0 );
	msg( GetMsg("spreer") + mformat( reward ), 112, 216, 219 );
	Echo( "4>> " + killer.Name + " " + GetMsg("spree3") + " " + Kills + " " + GetMsg("spreek") );
	Echo( "10> " + GetMsg("spreer") + mformat( reward ) );
	Announce( "~o~Murderous Spree", killer );
	IncreaseCash( killer, reward );
	IncreaseSSpree( killer, 25 );
	}
	else if ( Kills == 30 ) {
	msg( "* " + killer.Name + " " + GetMsg("spree4") + " " + Kills + " " + GetMsg("spreek"), 200, 0, 0 );
	msg( GetMsg("spreer") + mformat( reward ), 112, 216, 219 );
	Echo( "4>> " + killer.Name + " " + GetMsg("spree4") + " " + Kills + " " + GetMsg("spreek") );
	Echo( "10> " + GetMsg("spreer") + mformat( reward ) );
	Announce( "~o~Psychotic Spree", killer );
	IncreaseCash( killer, reward );
	IncreaseSSpree( killer, 30 );
	}
	else {
	if ( ( Kills % 5 == 0 ) && ( Kills > 0 ) ) {
	msg( "* " + killer.Name + " " + GetMsg("spree5") + " " + Kills + " " + GetMsg("spreek"), 200, 0, 0 );
	msg( GetMsg("spreer") + mformat( reward ), 112, 216, 219 );
	Echo( "4>> " + killer.Name + " " + GetMsg("spree5") + " " + Kills + " " + GetMsg("spreek") );
	Echo( "10> " + GetMsg("spreer") + mformat( reward ) );
	Announce( "~o~UNSTOPPABLE Spree", killer );
	IncreaseCash( killer, reward );
	IncreaseSSpree( killer, Kills );
}}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function ValidWep( wep ) {
	if ( wep > 11 && wep < 16 ) return false;
	if ( wep > 27 && wep < 31 ) return false;
	if ( wep == 33 ) return false;
	if ( wep == 0 ) return false;
	if ( wep == 255 ) return false;
	if ( wep == 13 ) return false;
	if ( wep > 33 ) return false;
	else return true;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function GetPlayer( target ) {
	target = target.tostring();
	if ( IsNum( target ) ) {
		target = target.tointeger();
		if ( FindPlayer( target ) ) return FindPlayer( target );
		else return null;
	}
	else if ( FindPlayer( target ) ) return FindPlayer( target );
	else return null;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function CountRegisters(param) {
local a,b,total=GetConfig("Registers").tointeger();
if (param == "inc") {
b=total+1;
a=QuerySQL( db, "UPDATE ServerConfig SET Param = '"+b+"' WHERE Name = 'Registers'" ); 
FreeSQLQuery(a);
} 
else if (param == "dec") {
b=total-1;
a=QuerySQL( db, "UPDATE ServerConfig SET Param = '"+b+"' WHERE Name = 'Registers'" );
FreeSQLQuery(a);
}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function RegisterUser( player, text ) {
local password = text, name = player.Name, ip =  player.IP;
local a=QuerySQL( db, "INSERT INTO Accounts ( Password, Name, IP, Level, Goto, CCars, CProps, DateReg, LastActive) VALUES ( '"+password+"','"+name+"', '"+ip+"','1','off','0','0','"+GetFullTime()+"','"+GetTime()+"')" );
local b=QuerySQL( db, "INSERT INTO Finance (Name, Cash, Bank) VALUES ( '" + name + "', '2000', '0' )" );
local c=QuerySQL( db, "INSERT INTO Stats (Name, Kills, Deaths, Toggle, Joins, Spree) VALUES ( '" + name + "', '0', '0', 'on', '1', '0' )" );
FreeSQLQuery(a); FreeSQLQuery(b); FreeSQLQuery(c); CountRegisters("inc");
PlayerInfo[player.ID].LoggedIn=true;
player.Cash = 2000;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function DellAccount(player) {
local a=QuerySQL( db, "DELETE FROM Accounts WHERE Name LIKE '"+player+"'" );
local b=QuerySQL( db, "DELETE FROM Finance WHERE Name LIKE '"+player+"'" );
local c=QuerySQL( db, "DELETE FROM Stats WHERE Name LIKE '"+player+"'" );
CountRegisters("dec"); FreeSQLQuery(a); FreeSQLQuery(b); FreeSQLQuery(c);
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function TrasfAccount(player,next) {
local q=QuerySQL( db, "SELECT Name FROM Accounts WHERE Name LIKE '"+player+"'" );
if (GetSQLColumnData(q,0)) {
QuerySQL(db,"UPDATE Accounts SET Name = '"+next+"' WHERE Name = '"+player+"'");
QuerySQL(db,"UPDATE Finance SET Name = '"+next+"' WHERE Name = '"+player+"'");
QuerySQL(db,"UPDATE Stats SET Name = '"+next+"' WHERE Name = '"+player+"'");
}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function LoginPlayer( player ) {
	local a = QuerySQL( db, "UPDATE Accounts SET IP = '" + player.IP + "' WHERE Name = '" + player.Name + "'" );
	local b = QuerySQL( db, "UPDATE Accounts SET LastActive = '" + GetTime() + "' WHERE Name = '" + player.Name + "'" );
	FreeSQLQuery(a);
	FreeSQLQuery(b);
	PlayerInfo[player.ID].LoggedIn=true; LoadPlayerData(player);
	local Cash = PlayerCash( player );
	player.Cash = Cash;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function Getip( player ) {
	local q = QuerySQL( db, "SELECT Name, IP FROM Accounts WHERE Name LIKE '" + player.Name + "'" );
	local a = GetSQLColumnData( q, 1 ); FreeSQLQuery(q);
	return a;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function Login( player ) PlayerInfo[player.ID].LoggedIn=true;
function Logout( player ) PlayerInfo[player.ID].LoggedIn=false;
function GetLoggedStatus( player ) return PlayerInfo[player.ID].LoggedIn;
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function PlayerLevel( player )
{
	local q = QuerySQL( db, "SELECT Name, Level FROM Accounts WHERE Name LIKE '" + player + "'" );
	local Level = GetSQLColumnData( q, 1 );
	if (Level!=null) return Level;
	else return 0;
	FreeSQLQuery(q);
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function PlayerPassword( player ) {
	local q = QuerySQL( db, "SELECT Name, Password FROM Accounts WHERE Name LIKE '" + player.Name + "'" );
	local Password = GetSQLColumnData( q, 1 );
	return Password;
	FreeSQLQuery(q);
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function IncreaseCash( player, amount ) { PlayerInfo[player.ID].Cash+=amount; player.Cash+=amount; }
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function DecreaseCash( player, amount ) { PlayerInfo[player.ID].Cash-=amount; player.Cash-=amount; }
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function IncreaseBank( player, amount ) PlayerInfo[player.ID].Bank+=amount;
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function DecreaseBank( player, amount ) PlayerInfo[player.ID].Bank-=amount;
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function PlayerCash( player ) return PlayerInfo[player.ID].Cash;
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function PlayerBank( player ) return PlayerInfo[player.ID].Bank;
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function NeedPlayerInArea(player,Xmin,Xmax,Ymin,Ymax) {
if(player.Pos.x >= Xmin && player.Pos.x <= Xmax && player.Pos.y >= Ymin && player.Pos.y <= Ymax) return true;
else return false;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function IsPlayerInArea(player,Xmin,Xmax,Ymin,Ymax) {
if (player.Pos.x > Xmin && player.Pos.x < Xmax && player.Pos.y > Ymin && player.Pos.y < Ymax) return true;
return false;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function onBank( player ) {
	local area = InPoly( player.Pos.x, player.Pos.y, -898.2357,-326.6091,-898.2196,-355.5072,-936.2309,-355.5205,-939.2854,-352.5587,-952.3001,-342.9138,-957.1079,-341.7898,-966.5380,-337.4671,-966.5401,-328.1766 );
	if ( area == false ) return area;
	else return area;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function onSunshine( player ) {
	local area = InPoly( player.Pos.x, player.Pos.y, -1060.54,-807.183,-959.702,-807.183,-959.702,-910.663,-1060.54,-910.663 );
	if ( area == false ) return area;
	else return area;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function StatsToggle( player ) {
	local q = QuerySQL( db, "SELECT Name, Toggle FROM Stats WHERE Name LIKE '" + player.Name + "'" );
	local Toggle = GetSQLColumnData( q, 1 ); FreeSQLQuery(q);
	return Toggle;	
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function GoToToggle( player ) {
	local q = QuerySQL( db, "SELECT Name, Goto FROM Accounts WHERE Name LIKE '" + player.Name + "'" );
	local Toggle = GetSQLColumnData( q, 1 ); FreeSQLQuery(q);
	return Toggle;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function ServerCProps(param) {
if (param == "get") {
local q=QuerySQL( db, "SELECT Name, Param FROM ServerConfig WHERE Name LIKE 'Props'" );
return GetSQLColumnData(q,1).tointeger(); FreeSQLQuery(q);
}
else if (param == "inc") {
local total=ServerCProps("get")+1;
local a=QuerySQL(db,"UPDATE ServerConfig SET Param = '"+total+"' WHERE Name = 'Props'");
FreeSQLQuery(a);
}
else if (param == "dec") {
local total=ServerCProps("get")-1;
local a=QuerySQL(db,"UPDATE ServerConfig SET Param = '"+total+"' WHERE Name = 'Props'");
FreeSQLQuery(a);
}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function ServerCCars(param) {
if (param == "get") {
local q=QuerySQL( db, "SELECT Name, Param FROM ServerConfig WHERE Name LIKE 'Cars'" );
return GetSQLColumnData(q,1).tointeger(); FreeSQLQuery(q);
}
else if (param == "inc") {
local total=ServerCCars("get")+1;
local a=QuerySQL(db,"UPDATE ServerConfig SET Param = '"+total+"' WHERE Name = 'Cars'");
FreeSQLQuery(a);
}
else if (param == "dec") {
local total=ServerCCars("get")-1;
local a=QuerySQL(db,"UPDATE ServerConfig SET Param = '"+total+"' WHERE Name = 'Cars'");
FreeSQLQuery(a);
}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function PlayerCProps(player,param) {
if (param == "get") {
local q=QuerySQL( db, "SELECT Name, CProps FROM Accounts WHERE Name LIKE '"+player+"'" );
return GetSQLColumnData(q,1); FreeSQLQuery(q);
}
else if (param == "inc") {
local total=PlayerCProps(player,"get")+1;
local a=QuerySQL(db,"UPDATE Accounts SET CProps = '"+total+"' WHERE Name = '"+player+"'");
FreeSQLQuery(a); ServerCProps("dec");
}
else if (param == "dec") {
local total=PlayerCProps(player,"get")-1;
local a=QuerySQL(db,"UPDATE Accounts SET CProps = '"+total+"' WHERE Name = '"+player+"'");
FreeSQLQuery(a); ServerCProps("inc");
}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function PlayerCCars(player,param) {
if (param == "get") {
local q=QuerySQL( db, "SELECT Name, CCars FROM Accounts WHERE Name LIKE '"+player+"'" );
return GetSQLColumnData(q,1); FreeSQLQuery(q);
}
else if (param == "inc") {
local total=PlayerCCars(player,"get")+1;
local a=QuerySQL(db,"UPDATE Accounts SET CCars = '"+total+"' WHERE Name = '"+player+"'");
FreeSQLQuery(a); ServerCCars("dec");
}
else if (param == "dec") {
local total=PlayerCCars(player,"get")-1;
local a=QuerySQL(db,"UPDATE Accounts SET CCars = '"+total+"' WHERE Name = '"+player+"'");
FreeSQLQuery(a); ServerCCars("inc");
}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function PlayerKills( player ) {
	local q = QuerySQL( db, "SELECT Name, Kills FROM Stats WHERE Name LIKE '" + player.Name + "'" );
	local Kills = GetSQLColumnData( q, 1 ); FreeSQLQuery(q);
	return Kills;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function PlayerDeaths( player ) {
	local q = QuerySQL( db, "SELECT Name, Deaths FROM Stats WHERE Name LIKE '" + player.Name + "'" );
	local Deaths = GetSQLColumnData( q, 1 ); FreeSQLQuery(q);
	return Deaths;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function PlayerSSpree( player ) {
	local q = QuerySQL( db, "SELECT Name, Spree FROM Stats WHERE Name LIKE '" + player.Name + "'" );
	local Spree = GetSQLColumnData( q, 1 ); FreeSQLQuery(q);
	return Spree;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function IncreaseSSpree( player, param ) {
	local Spree = PlayerSSpree( player ), TotalSpree = Spree += param;
	local a = QuerySQL( db, "UPDATE Stats SET Spree = '" + TotalSpree + "' WHERE Name = '" + player.Name + "'" );
	FreeSQLQuery( a );
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function PlayerJoins( player ) {
	local q = QuerySQL( db, "SELECT Name, Joins FROM Stats WHERE Name LIKE '" + player.Name + "'" );
	local Joins = GetSQLColumnData( q, 1 ); FreeSQLQuery(q);
	return Joins;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function IncreaseJoins( player, amount ) {
	local Joins = PlayerJoins( player );
	local TotalJoins = Joins += amount;
	local a = QuerySQL( db, "UPDATE Stats SET Joins = '" + TotalJoins + "' WHERE Name = '" + player.Name + "'" );
	FreeSQLQuery( a );
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function IncreaseKills( player ) {
	local Kills = PlayerKills( player ), TotalKills = Kills += 1;
	local a = QuerySQL( db, "UPDATE Stats SET Kills = '" + TotalKills + "' WHERE Name = '" + player.Name + "'" );
	FreeSQLQuery( a );
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function IncreaseDeaths( player ) {
	local Deaths = PlayerDeaths( player ), TotalDeaths = Deaths += 1;
	local a = QuerySQL( db, "UPDATE Stats SET Deaths = '" + TotalDeaths + "' WHERE Name = '" + player.Name + "'" );
	FreeSQLQuery( a );
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function GotolocRand() {
for (local i=0,loc; i<=rand(); i++) {
if (!loc) {
local q=QuerySQL(db,"SELECT Name FROM Gotoloc WHERE rowid = '"+rand()%10+"'");
loc=GetSQLColumnData(q,0); FreeSQLQuery(q);
} else { return loc; break; }
}}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function GotolocPut( player, x, y, z ) player.Pos = Vector( x, y, z );
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function FindGotoLoc( text ) {
        local Location = QuerySQL( db, "SELECT Name FROM Gotoloc WHERE Name='" + text + "'" );
        local Locname = GetSQLColumnData( Location, 0 ); FreeSQLQuery(Location);
        return Locname;
}
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function GetTok(string, separator, n, ...) {
	local m=vargv.len()>0?vargv[0]:n,tokenized=split(string,separator),text="";
	if (n > tokenized.len() || n < 1) return null;
	for (; n <= m; n++) {
		text += text == "" ? tokenized[n-1] : separator + tokenized[n-1];
	} return text; }
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~
function NumTok(string, separator) return split(string,separator).len();
//~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~o~

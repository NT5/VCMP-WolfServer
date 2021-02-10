//Echo
class EchoInfo { OnWhois=null; MeIP=0; NetName=null; Users=null; Chan=GetConfig("BotChan"); CPass=GetConfig("BotCPass"); Nick=GetConfig("BotName"); Pass=GetConfig("BotPass"); Net=GetConfig("BotNet"); Port=6667; }
class CSPAM { CServer=0; TServer=null; TiServer=0; CIRC=0; TIRC=null; TiIRC=0; }
class EInfo { Name=null; Level=0; }
class CAway { Razon=null; Time=0; }
Bot <- EchoInfo();
IRCCMDS<-[
"4,!exe","5,!turn","5,!reload","5,!acscript","0,!online","0,!whois","0,!away","0,!back","0,!afk",
"0,!players","0,!sever","0,!pm","0,!check","0,!seen","0,!spree","0,!stats"
];
function ConnectEcho()
{
	print( "Confirmando Detalles del Bot..." );
	Socket <- NewSocket( "ParceData" );
	Socket.Connect( Bot.Net, Bot.Port );
	Socket.SetNewConnFunc( "Login" );
	print( "Detalles Confirmados!" );
}
function KillBots()
{
	print( "Desconectando Bot Del IRC..." );
	Socket.Send( "QUIT " + Bot.Nick + "\n" );
	Socket.Delete();
	print( Bot.Nick + " Desconectado Correctamente de IRC." );
}
function Login()
{
	print( "Conectando a " + Bot.Chan + "..." );
	Socket.Send( "USER " + Bot.Nick + " 0 * :Wolf.Man.Echo.Bot\n" );
	Socket.Send( "NICK " + Bot.Nick + "\n" ); 
	Socket.Send( "PRIVMSG NickServ IDENTIFY " + Bot.Pass + "\n" ); 
	NewTimer("JoinEcho", 2000,1);
}
function JoinEcho()
{
Socket.Send( "JOIN " + Bot.Chan + " " + Bot.CPass + "\n" );
Socket.Send( "PRIVMSG NickServ IDENTIFY " + Bot.Pass + "\n" );
Socket.Send( "MODE "+Bot.Nick+" +B\n" );
print("Bot Conectado a "+Bot.Chan+".");
Echo( "4---5> 6EchoBot Conectado 5<4---" );
}
function ParceData( sz )
{
	local PING = GetTok( sz, " ", 1 ), EVENT = GetTok( sz, " ", 2 ), CHANEVENT = GetTok( sz, " ", 3 ), Count = NumTok( sz, " " );
	local Nick, Command, Prefix, Text;
	if ( PING ) Socket.Send( "PONG " + PING + "\n" );
	if ( EVENT == "353" ) { Bot.NetName=split(sz," ")[0].slice(1); Bot.Users=GetTok(sz,":",2),Bot.Users=Bot.Users.slice(0,Bot.Users.len()-1); ExamineNicks(); }
	if (IsOn(sz,"IP") && EVENT=="NOTICE") { Bot.MeIP=split(sz," ")[17]; Bot.MeIP=split(Bot.MeIP,"()")[0]; }
	if ( EVENT == "JOIN" )
	{
	local msg1 = "(IRC)" + GetTok( sz, "!", 1 ).slice( 1 ) + " " + GetMsgIRC("irc1") + " " + Bot.Chan;
	msg( msg1, 200, 200, 0 );
	print( msg1 )
	}
	if ( EVENT == "PART" )
	{
	local msg2="(IRC)"+GetTok(sz,"!",1).slice(1)+" "+GetMsgIRC("irc2")+" "+ Bot.Chan,id=FindIrcUserID(GetTok(sz,"!",1).slice(1));
	if (Away[id].Razon) Away[id].Razon=null,Away[id].Time=null;
	msg( msg2, 200, 200, 0 );
	print(msg2)
	}
	if ( EVENT == "NICK" )
	{
	local msg3="(IRC)"+GetTok(sz,"!",1).slice(1)+" "+GetMsgIRC("irc3")+" "+GetTok(sz," ",3),msg3=msg3.slice(0,msg3.len()-1);
	msg( msg3, 200, 200, 0 );
	print(msg3);
	}
	if ( EVENT == "KICK" ) {
	local nick=GetTok(sz,"!",1).slice(1),knick=GetTok(sz," ",4),reason=GetTok(sz," ",5,Count);
	msg("(IRC)"+knick+" "+"was kicked by "+nick+" ( "+reason.slice(0,reason.len()-1)+" )",200,200,0);
	print("(IRC)"+knick+" "+"was kicked by "+nick+" Reason"+reason.slice(0,reason.len()-1));
	if (knick==Bot.Nick) Socket.Send("JOIN "+Bot.Chan+" "+Bot.CPass+"\n");
	}
	if ( EVENT == "QUIT" )
	{
	local quit=GetTok(sz," ",3,Count),msg4="(IRC)Quit: "+GetTok(sz,"!",1).slice(1)+" ->"+quit.slice(0,quit.len()-1);
	local id=FindIrcUserID(GetTok(sz,"!",1).slice(1));
	if (Away[id].Razon) Away[id].Razon=null,Away[id].Time=null;
	msg( msg4, 200, 200, 0 );
	print(msg4);
	}
	if ( EVENT == "MODE" )
	{
	local msg5="(IRC)"+GetTok(sz,"!",1).slice(1)+" "+GetMsgIRC("irc4")+" "+GetTok(sz," ",4,Count),msg5=msg5.slice(0,msg5.len()-1);
	msg(msg5,200,200,0);
	print(msg5);
	}
	if ( ( EVENT == "MODE" ) || ( EVENT == "KICK" ) || ( EVENT == "NICK" ) || ( EVENT == "JOIN" ) || ( EVENT == "PART" ) || ( EVENT == "QUIT" ) ) Socket.Send("NAMES :"+Bot.Chan+"\n");
	if ( CHANEVENT == Bot.Chan )
	{
		Nick = GetTok( sz, "!", 1 ).slice( 1 );
		local toc = GetTok( sz, " ", 2 );
		if ( toc == "PRIVMSG") Command = GetTok( sz, " ", 4 ).slice( 1 );
		if ( Command )
		{
		if ( NumTok( sz, " " ) > 4 ) Text = GetTok( sz, " ", 5, Count );
		else Command = split( Command, "\r\n" )[ 0 ];
		if ( ( Count > 4 ) ) IrcCommand( Nick, Command, Text );
		else if ( Count == 4 ) IrcCommand( Nick, Command, null );
		}
	}
	//WHOIS
	if (Bot.OnWhois) {
	local n=Bot.OnWhois;
	if (EVENT == "311") { 
	EchoN(n,">> Nickname: "+GetTok(sz," ",4));
	EchoN(n,">> Name: "+GetText(sz,7)); 
	EchoN(n,">> Identity: "+GetTok(sz," ",4));
	EchoN(n,">> Host: "+GetTok(sz," ",6));
	Bot.OnWhois=null;
	}
	if (EVENT == "401") { EchoN(n,"No such nick/channel"); }
	}
}

function EchoN( nick, text ) Socket.Send( "NOTICE " + nick + " " + text + "\n" );
function Echo( text ) Socket.Send( "PRIVMSG " + Bot.Chan + " " + text + "\n" );
function IrcKick(user,reason) Socket.Send("KICK "+Bot.Chan+" "+user+" "+reason+" \n");
function ExamineNicks() {
local c,b,nicks=Bot.Users,a=0,nun=split(nicks," ").len(); IrcUsers<-array(51,null);
for (local i=0; i<=50; i++) { IrcUsers[i]=EInfo(); }
while ( a < nun ) {
b=split(nicks," ")[a];
if(b.slice(0,1) == "~") { b=b.slice(1); c=5 }
else if(b.slice(0,1) == "&") { b=b.slice(1); c=4 }
else if(b.slice(0,1) == "@") { b=b.slice(1); c=3 }
else if(b.slice(0,1) == "%") { b=b.slice(1); c=2 }
else if(b.slice(0,1) == "+") { b=b.slice(1); c=1 }
else { b=b; c=0; }
if(!IrcUsers[a].Name) { IrcUsers[a].Name=b; IrcUsers[a].Level=c; }
a++;
}}
function FindIrcUserName(id) return IrcUsers[id].Name
function FindIrcUserID(user) for (local a=0;a <= 50; a++) if (IrcUsers[a].Name == user) { return a; break;}
function SendIRCUsers(player) {
PrivMessage( "IRC Users: "+Bot.Chan+": ",player); local buffer;
for (local i=0,t=0; i<=50; i++,t++) {
if(IrcUsers[i].Name) {
if (t >= 15) { PrivMessage(buffer,player); buffer=""; t=0; }
if (!buffer) buffer = IrcUsers[i].Name;
else buffer = buffer+", "+IrcUsers[i].Name;
if (buffer.slice(0,1) == ","  ) buffer=buffer.slice(2);
}} PrivMessage(buffer,player); }
function IrcSpam(user,text) {
	local id = FindIrcUserID(user);
	Spam[id].CIRC++;
	if (!Spam[id].TIRC) Spam[id].TIRC=text;
	if (!Spam[id].TiIRC) Spam[id].TiIRC=GetTime();
	if (Spam[id].CIRC >= 3 && Spam[id].TIRC == text && GetTime()-Spam[id].TiIRC <= 5) {
	IrcKick(user,"Spam "+Spam[id].CIRC+"Reps, "+duration(Spam[id].TiIRC));
	Spam[id].CIRC=0; Spam[id].TIRC=null; Spam[id].TiIRC=0;
	}
	if (Spam[id].CIRC >= 5 && GetTime()-Spam[id].TiIRC >= 5) { Spam[id].CIRC=0; Spam[id].TIRC=null; Spam[id].TiIRC=0; }
}
function IrcCommand( user, cmd, text )
{
	if (cmd && text) IrcSpam(user,cmd+" "+text);
	else IrcSpam(user,cmd);
	local level=IrcUsers[FindIrcUserID(user)].Level;
	if (!level) level=0;
	if (text) text=text.slice(0,text.len()-2);
	if (!cmd) cmd=" ";
	//if ( cmd == "!say" || cmd.slice(0,1) == "." ) EchoN(user,GetMsgIRC("irc5"));
	if (cmd=="ACTION") {
	if (IsOn(text.slice(0,text.len()-1),Bot.Nick)) IrcKick(user,"UPS!");
	msg("(IRC)"+user+" "+text.slice(0,text.len()-1),200,0,200); print("(IRC)"+user+" "+text.slice(0,text.len()-1)); 
	}
	else if (cmd && text) { msg("(IRC)"+user+": "+cmd+" "+text,200,200,0); print("(IRC)"+user+": "+cmd+" "+text); }
	else if (cmd) { msg("(IRC)"+user+": "+cmd,200,200,0); print("(IRC)"+user+": "+cmd); }
	if (cmd.slice(0,1) == "!") {
	if ( cmd == "!commands" || cmd == "!cmds" ) {
	local ml=level,l,t=0,buffer;
	while ( t < IRCCMDS.len() ) {
	l=IRCCMDS[t].slice(0,1);
	if (ml.tointeger()>=l.tointeger()) {
	if (!buffer) buffer=IRCCMDS[t].slice(2);
	else buffer=buffer+", "+IRCCMDS[t].slice(2);
	}
	t++; 
	} EchoN(user,"All Commands: "+buffer); }
	else if (cmd == "!server") {
	Echo("7>10 Server Name: ["+GetServerName()+"] GameMode: ["+GetGamemodeName()+"] IP:["+Bot.MeIP+":2339] MaxPlayers: ["+GetMaxPlayers()+"] Scrip Vercion: ["+Server.VerScript+"] Password: ["+GetPassword()+"] Registers Users: ["+Server.Registers+"]");
	msg("> Server Name: ["+GetServerName()+"] GameMode: ["+GetGamemodeName()+"] IP:["+Bot.MeIP+":2339] MaxPlayers: ["+GetMaxPlayers()+"] Scrip Vercion: ["+Server.VerScript+"] Password: ["+GetPassword()+"] Registers Users: ["+Server.Registers+"]",200,200,0);
	}
	else if ( cmd == "!away") {
	local id=FindIrcUserID(user);
	if (!text) EchoN(user,cmd+" <reason>");
	else if (Away[id].Razon) EchoN(user,GetMsgIRC("away1"));
	else {
	Echo("2"+user+" "+GetMsgIRC("away2")+" "+text);
	Away[id].Razon=text,Away[id].Time=GetTime();
	}}
	else if ( cmd == "!back" ) {
	local id=FindIrcUserID(user);
	if (!Away[id].Razon) EchoN(user,GetMsgIRC("away3"));
	else {
	Echo("2"+user+" "+GetMsgIRC("away4")+" "+Away[id].Razon+" 2"+GetMsgIRC("away5")+"1 "+duration(Away[id].Time));
	Away[id].Razon=null,Away[id].Time=0;
	} }
	else if ( cmd == "!afk" ) {
	local a=0,cbuffer=0,rbuffer;
	while(a <= 50) { 
	if (Away[a].Razon) cbuffer++; 
	a++; 
	}
	a=0;
	if (cbuffer == 0) Echo("10"+GetMsgIRC("away7"));
	else {
	Echo("4[10Count4]1 "+cbuffer);
	while(a <= 50) {
	if (Away[a].Razon) Echo("2"+FindIrcUserName(a)+" "+GetMsgIRC("away6")+" "+Away[a].Razon+" 2"+GetMsgIRC("away5")+"1 "+duration(Away[a].Time));
	a++;
	}}}
	else if ( cmd == "!whois" ) {
	if (!text) EchoN(user,cmd+" <name>");
	else { Bot.OnWhois=user; Socket.Send("WHOIS "+text+" \n"); }
	}
	else if ( cmd == "!exe" )
	{
	if (level <= 3) EchoN( user, GetMsgIRC("error2") );
	else if ( !text ) EchoN( user, GetMsgIRC("error1") + cmd + " " + GetMsgIRC("exe1") );
	else if (Iswm(text,"~")) EchoN(user,GetMsgIRC("spc1"));
	else {
	try {
	local script = compilestring(text);
	script();
	}
	catch(e) { 
	Echo("4Error: "+e+".");
	} } }
	else if (cmd == "!acscript") {
	if (level != 5) EchoN( user, GetMsgIRC("error2") );
	else {
	try {
	dofile( "main.nut" ); dofile( "Functions.nut" );
	dofile( "Commands.nut" ); dofile( "Remote.nut" );
	print("> "+GetMsgIRC("acscrip1")); msg("> "+GetMsgIRC("acscrip1"),200,0,0); Echo("3> "+GetMsgIRC("acscrip1"));
	}catch(e) {Echo("4Error: "+e+".");}}}
	else if (cmd == "!reload") {
	if (level != 5) EchoN( user, GetMsgIRC("error2") );
	else {
	try { ReloadScripts(); } catch(e) {Message("Error: "+e+".");}
	}}
	else if ( cmd == "!online" ) Echo( GetMsgIRC("hoston1")+" "+duration(Server.UpTime));
	else if ( cmd == "!turn" )
	{
	if (level != 5) EchoN( user, GetMsgIRC("error2") );
	else if ( !text ) EchoN(user, GetMsgIRC("error1") + " " + cmd + " sp/en" );
	else {
	if ( text == "sp" ) {
	if ( GetConfig("Lenguaje") == "Spanish" ) EchoN( user, "Error - El Idioma Ya Es Español!" );
	else Echo( "* 3" + user + " " + "A Cambiado El Idioma A Español." ), SetLenguaje(1);
	}
	else if ( text == "en" ) {
	if ( GetConfig("Lenguaje") == "English" ) EchoN( user, "The Language Is Already English!" );
	else Echo( "* 3" + user + " " + "Has Changed The Language To English." ), SetLenguaje(2);
	}
	else Echo( GetMsgIRC("error1") + " " + cmd + " sp/en" );
	} }
	else if ( cmd == "!pm" ) {
	if ( !text ) EchoN(user,GetMsgIRC("error1")+cmd+" <name><messege>");
	else if (Iswm(text,"~")) EchoN(user,GetMsgIRC("spc1"));
	else {
		local msg = GetTok( text, " ", 2,NumTok( text, " "));
		local plr = GetPlayer( GetTok( text, " ", 1 ) );
		if ( !msg ) EchoN(user,GetMsgIRC("error1")+cmd+" <name><messege>");
		else if ( !plr ) EchoN(user,GetMsgIRC("error3"));
		else {  
			EchoN(user,GetMsgIRC("pm1")+" "+plr+", '"+msg+"'");
			PrivMessage("(IRC) "+user+": "+msg+"." plr);
			Announce("~b~read~t~mp",plr);
	} } }
	else if ( cmd == "!seen" ) {
	if (!text) EchoN(user,cmd+" <FullName>");
	else {
	local q = QuerySQL( db, "SELECT Name, DateReg, LastActive FROM Accounts WHERE Name LIKE '" +text+"'" );
	if (!GetSQLColumnData(q,0)) EchoN(user,GetMsgIRC("stats1"));
	else {
	Echo("10>> 1"+GetSQLColumnData(q,0)+"10 "+GetMsgIRC("last2")+" "+duration(GetSQLColumnData(q,2))+" "+GetMsgIRC("last1")+" "+GetSQLColumnData(q,1));
	}}}
	else if ( cmd == "!players" ) {
		local b=null;
		for (local a=0; a<GetMaxPlayers(); a++) {
		local plr = FindPlayer( a.tointeger() );
		if ( plr ) {
		if ( b ) b=b+", ["+plr.ID+"] "+plr.Name
		else b = "["+plr.ID+"] "+plr.Name
		}}
		if ( b ) Echo( "2** 12Players: 5[" + GetPlayers() + "/" + GetMaxPlayers() + "] " + " - " + b  );
		else Echo( GetMsgIRC("player1") );
	}
	else if ( cmd == "!check" ) {
		if (!text) EchoN(user,cmd+" <Nick/ID>");
		else {
		local plr = GetPlayer( text );
		if ( !plr ) EchoN(user,GetMsg("errornick"));
		else if ( !plr.IsSpawned ) EchoN(user,GetMsg("playerspra"));
		else {
		msg("-> "+plr+"'"+GetMsg("check1")+"["+plr.Health+"%] "+GetMsg("check2")+"["+plr.Armour+"%] "+"Ping: ["+plr.Ping+"ms]",0,100,0);
		Echo("10-> "+plr+"'"+GetMsg("check1")+"["+plr.Health+"%] "+GetMsg("check2")+"["+plr.Armour+"%] "+"Ping: ["+plr.Ping+"ms]");
		print("-> "+plr+"'"+GetMsg("check1")+"["+plr.Health+"%] "+GetMsg("check2")+"["+plr.Armour+"%] "+"Ping: ["+plr.Ping+"ms]");
	}}}
	else if ( ( cmd == "!stat" ) || ( cmd == "!stats" ) )
	{
	if (!text) EchoN(user, GetMsgIRC("error1") + cmd + " <player>");
	else {
	local plr = text, kills, deaths, joins, spree, Ratio;
	local q = QuerySQL( db, "SELECT Name, Kills, Deaths, Joins, Spree, Toggle FROM Stats WHERE Name LIKE '" + plr + "'" );
	if (GetSQLColumnData( q, 0 )) {
	kills = GetSQLColumnData(q, 1), deaths = GetSQLColumnData(q, 2), joins = GetSQLColumnData(q, 3), spree = GetSQLColumnData(q, 4);
	if (GetSQLColumnData(q, 5) == "off") EchoN(user, "> " + plr + " " + GetMsg("stats1"));
	else {
	plr=GetSQLColumnData( q, 0 );
	if ( ( kills > 0 ) && ( deaths > 0 ) ) { Ratio=kills.tofloat()/deaths.tofloat(); Ratio=format("%.2f",Ratio); }
	if ( Ratio ) { 
		msg( "* Stats: " + plr + ", Joins: " + joins + ", Kills: " + kills + " Deaths: " + deaths + " Spree's: " + spree + " Ratio: " + Ratio, 139, 69, 19 );
		Echo( "* 5Stats: " + plr + ", Joins: " + joins + ", Kills: " + kills + " Deaths: " + deaths + " Spree's: " + spree + " Ratio: " + Ratio );
		print( "* Stats: " + plr + ", Joins: " + joins + ", Kills: " + kills + " Deaths: " + deaths + " Spree's: " + spree + " Ratio: " + Ratio );
	}
	else {
		msg( "* Stats: " + plr + ", Joins: " + joins + ", Kills: " + kills + " Deaths: " + deaths + " Spree's: " + spree, 139, 69, 19 );
		Echo( "* 5Stats: " + plr + ", Joins: " + joins + ", Kills: " + kills + " Deaths: " + deaths + " Spree's: " + spree );
		print( "* Stats: " + plr + ", Joins: " + joins + ", Kills: " + kills + " Deaths: " + deaths + " Spree's: " + spree );
	} } }
	else EchoN(user, GetMsgIRC("stats1"));
	} }
	else if ( cmd == "!spree" )	{
		local a = 0, b = null;
		while ( a < GetMaxPlayers() ) {
			local plr = FindPlayer( a );
			if ( plr ) {
				local spree =  PlayerSpree( plr );
				
				if ( spree >= 10 ) {
					if ( b ) b = b + " - " + plr.Name + " (" + spree + ")";
					else b = plr.Name + " (" + spree + ")";
				} }
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
	else if ( cmd == "!pass" ) {
	local param = text;
	if ( param ) {
	if (GetPassword()==param) EchoN(user,"Error the pass is allredy "+param);
	else {
		SetPassword(param);
		Echo( "Server password was changed to: "+param );
		msg( "Server password was changed to: "+param,0,250,0);
	}} else {
	if (GetPassword()=="none") EchoN(user,"Error the Pass is allready turner off");
	else {
		Echo( "Server password was turned off" );
		msg( "Server password was turned off",0,250,0);
		SetPassword();
	}}}
	else if ( cmd == "!ann" )  {
	if ( !text ) Echo( "Error - Syntax: "+cmd+" <player/all><Message>" );
	else {
	if (split(text," ")[0]=="all") {
	if (split(text," ").len()<=1) Echo( "Error - Syntax: "+cmd+" <player/all><Message>" );
	else {
	Echo( "Anuncio Embiado: " +GetText(text,1)+", a Todos Los Jugadores." );
	AnnounceAll(GetText(text,1));
	}} else {
		local msg,plr;
		if (split( text, " " ).len()>1) msg = GetText(text,1);
		plr = FindPlayer( split( text, " " )[0] );
		if (!plr) Echo( "** Error - Nick Invalido" );
		else if (!msg) Echo( "Error - Syntax: "+cmd+" <player/all><Message>" );
		else {
			Echo( "Anuncio Embiado: " + msg + ", to " + plr );
			Announce( msg, plr );
			PrivMessage( "Anucio Embiado: " + msg + ".", plr );
	}}}}
	else if (cmd == "!drown") {
	if ( !text ) Echo("Error - Syntax: " + cmd + " <Nombre>" );
	else {
		local plr,reason;
		if (split( text, " " ).len()>1) reason=GetText(text,1);
		else reason="None";
		plr = FindPlayer( split( text, " " )[0] );
		if (!plr) Echo( "** Error - Nick Name Invalido." ); 
		else {
			if ( !plr.IsSpawned ) Echo( "** Error - Este Jugador No Esta Generado." );
			else {
			PrivMessage( "You Have been Drowned. Reason: "+reason, plr );
			Announce( "~b~drowning", plr );
			plr.Health = 2;
			plr.Pos = Vector( 216.9180,-1897.6561,7.0830 );
			Echo( "** Drowning:[ " + plr.Name + " ] By "+user+" Reason: "+reason );
			Message( "** Drowning:[ " + plr.Name + " ] By "+user+" Reason: "+reason );
	}}}}
	else EchoN(user,GetMsg("errorcmd"));
}}
//Console
function onConsoleInput( cmd, text )
{
	if ( cmd == "!say" )
	{
	if ( !text ) print( "Error - Syntax: "  + cmd + " <text> " );
	else
	{
		Echo( "5(3Console5) 3Admin: 1" + text );
		msg( "(Console) Admin: " + text, 200, 200, 0 );
		print( text );
	}
	}
	else if ( cmd == "!compile" ) {
	if ( !text ) print("Error - Invalid arguments (compile <script>)");
	else {
	local file = loadfile(text);
	if (!file) print( "Unable to load script "+text);
	else {
	local name; for (local a=0; a<text.len(); a++) if(text.slice(a,a+1)==".") name=text.slice(0,a);
	print( "Script "+text+" compiled successfully to _"+name+".cnut" );
	writeclosuretofile( "_"+name+".cnut",file );
	}}}
	else if (cmd == "!acscript") {
	dofile( "main.nut" ); dofile( "Functions.nut" );
	dofile( "Commands.nut" ); dofile( "Remote.nut" );
	print("Script Actualizada.");
	}
	else if (cmd == "!uirc") print(">"+Bot.Chan+" "+"Users: "+Bot.Users);
	else if (cmd == "!connect" )
	{
	if (!text) print("Error - !"+cmd+" <lu/local>");
	else {
	local q;
	if (text == "lu") {
	q = QuerySQL( db, "UPDATE ServerConfig SET Param = '85.17.189.153' WHERE Name = 'BotNet'" );
	FreeSQLQuery( q );
	}
	else if (text == "local") {
	q = QuerySQL( db, "UPDATE ServerConfig SET Param = '127.0.0.1' WHERE Name = 'BotNet'" );
	FreeSQLQuery( q );
	} 
	else print("Error - !"+cmd+" <lu/local>");
	}
	}
	else if ( cmd == "!players" )
	{
		local b = null;
		
		for ( local a = 0; a < GetMaxPlayers(); a++ )
		{
			local plr = FindPlayer( a.tointeger() );
			
			if ( plr )
			{
				if ( b ) b = b + ", [" + plr.ID + "] " + plr.Name
				else b = "[" + plr.ID + "] " + plr.Name
			}
		}
		
		if ( b ) print( "** Players: [" + GetPlayers() + "/" + GetMaxPlayers() + "] " + " - " + b );
		else print( "** No Hay Jugadores En el Server." );
	}
	
	else if ( cmd == "!pass" )
	{
	local param = text;
	if ( param )
	{
		SetPassword( param );
		print( "Server password was changed to: " + param );
		msg( "Server password was changed to: " + param, 0, 250, 0 );
	}
	else
		{
		print( "Server password was turned off" );
		msg( "Server password was turned off", 0, 250,0 );
		SetPassword( );
		}
	}
	else if ( cmd == "!spree" )
	{
		local a = 0, b = null;
		while ( a < GetMaxPlayers() )
		{
			local plr = FindPlayer( a );
			if ( plr )
			{
				local spree =  PlayerSpree( plr );
				
				if ( spree >= 10 )
				{
					if ( b ) b = b + " - " + plr.Name + " (" + spree + ")";
					else b = plr.Name + " (" + spree + ")";
				}
			}
			a ++;
		}
		
		if ( b ) print( "Players en spree: " + b );
		else print( "No Hay Juadores en killing spree." );
	}

	else if ( cmd == "!ann" ) 
	{
	if ( !text ) print( "Error - Syntax: " + cmd + " <Nombre><Mensaje> " );
	else
	{
		local msg = text.slice( text.find( " " ) + 1 );
		local plr = FindPlayer( split( text, " " )[ 0 ] );
		if ( !plr ) print( "** Error - Nick Invalido" );
		else
		{
			print( "Anuncio Embiado: " + msg + ", to " + plr );
			Announce( msg, plr );
			PrivMessage( "Anucio Embiado: " + msg + ".", plr );
		}
	}
	}
	else if ( cmd == "!annall" ) 
	{
	if ( !text ) print( "Error - Syntax: " + cmd + " <text> " );
	else
	{
		print( "Anuncio Embiado: " + text + ", a Todos Los Jugadores." );
		AnnounceAll( text );
	}
	}

	else if ( cmd == "!ping" )
        	{
	if ( !text ) print( "Error - Syntax: " + cmd + " <name> " );
	else
		{
			local plr = FindPlayer( split( text, " " )[ 0 ] );
			if ( !plr ) print( "** Error - Nick Name Invalido." ); 
			else
				{  
                       			print("**" + plr.Name + " 's Ping: " + plr.Ping );
                       			Message( plr.Name + " 's Ping: " + plr.Ping );
                       			}
                     	 }
                 }

	else if ( cmd == "!pm" ) 
	{
	if ( !text ) print( "Error - Syntax: " + cmd + " <Nombre><Mensaje> " );
	else
	{
		local msg = text.slice( text.find( " " ) + 1 );
		local plr = FindPlayer( split( text, " " )[ 0 ] );
		if ( !plr ) print( "** Error - Nick Invalido." );
		else
		{  
			print( "PM Embiado : " + msg + ", a " + plr );
			PrivMessage( "(Console-Admin): " + msg + ".", plr );
			Announce( "~b~lee, el ~t~mp", plr );
		}
	}
	}

	else if ( cmd == "!drown" )
         	{
	if ( !text ) print("Error - Syntax: " + cmd + " <Nombre>" );
	else
	{
		local plr = FindPlayer( split( text, " " )[ 0 ] );
		if ( !plr ) print( "** Error - Nick Name Invalido." ); 
		else
		{
			if ( !plr.IsSpawned ) print( "** Error - Este Jugador No Esta Generado." );
			else
			{
			PrivMessage( "You Have been Drowned.", plr );
			Announce( "~b~drowning", plr );
			plr.Health = 2;
			plr.Pos = Vector( 216.9180,-1897.6561,7.0830 );
			print( "** Drowning:[ " + plr.Name + " ] By Admin." );
			Message( "Drowning:[ " + plr.Name + " ] By Admin." );
		    	}
		}
	}
	}

	else if ( cmd == "!freeze" )
         	{
	if ( !text ) print( "Error - Syntax: " + cmd + " <Nombre>" );
	else
	{
		local plr = FindPlayer( split( text, " " )[ 0 ] );
		if ( !plr ) print( "** Error - Nick Name Invalido." ); 
		else
		{
                                  		if ( plr.IsFrozen == true ) print( "Error - Este Jugador Ya Esta Freeze." );
                                     	else
                                		{
				if ( !plr.IsSpawned ) print( "** Error - Este Jugador No Se Ha Generado." );
				else
				{
					PrivMessage( "You Have Been Freeze.", plr );
					Announce( "~t~freeze", plr );
					plr.IsFrozen = true;
					print( "** Admin A Congelado a " + plr + "..." );
					Message( "* Admin A Congelado a " + plr + "..." );
				 }
			  }
		     }
	}
	}

	else if ( cmd == "!unfreeze" )
         	{
	if ( !text ) print( "Error - Syntax: " + cmd + " <Nombre>" );
	else
	{
			local plr = FindPlayer( split( text, " " )[ 0 ] );
			if ( !plr ) print( "** Error - Nick Name Invalido." ); 
			else
			    {
                                  			if ( plr.IsFrozen == false ) print( "Error - Este Jugador No Esta frozen." );
                                     		else
                                			       {
					PrivMessage( "You Have Been UnFreeze.", plr );
					plr.IsFrozen = false;
					print( "** Admin A DesCongelado a " + plr + "..." );
					Message( "* Admin A DesCongelado a " + plr + "..." );
				       }
			      }
	}
	}

	else if ( cmd == "!mute" )
	{
	if ( !text ) print( "Error - Invalid Format. !mute <player>" );
	local plr = FindPlayer( split( text, " " )[ 0 ] );
	if ( !plr ) print( "Error - Invalid Nick/ID." );
	if ( plr.IsMuted ) print( "Error - This player has already been muted." );
	else
	{
		Announce( "~t~mute", plr );
		Message( "* Admin has muted " + plr + "..." );
		print( "Muted ," + plr + "..." );
		plr.IsMuted = true;			
	}
	}		

	else if ( cmd == "!unmute" )
	{
	if ( !text ) print( "Error - Invalid Format. !unmute <player>" );
	local plr = FindPlayer( split( text, " " )[ 0 ] );
	if ( !plr ) print( "Error - Invalid Nick/ID." );
	if ( !plr.IsMuted ) print( "Error - This player hasn't been muted." );
	else
	{
		Announce( "~t~unmute", plr );
		Message( "* Admin has unmuted " + plr + "..." );
		print( "UNMuted ," + plr + "..." );
		plr.IsMuted = false;
		
	}		
	}

	else if ( cmd == "!jail" )
         	{
	if ( !text ) print( "Error - Syntax: " + cmd + " <Nombre>" );
	else
	{
	local plr = FindPlayer( split( text, " " )[ 0 ] );
	if ( !plr ) print( "** Error - Nick Name Invalido." ); 
	else
	{
	if ( !plr.IsSpawned ) print( "** Error - Este Jugador No Se Ha Generado." );
	else
	{
        if ( Jailed[ plr.ID ] == true ) print( "Error - " + plr + " is already Jailed." );
		else
		{
			PrivMessage( "You Have Been Jailed.", plr );
			Announce( "~b~Jailing", plr );
			plr.IsFrozen = true;
			Jailed[ plr.ID ] = true;
			plr.Pos = Vector( 389.117432,-509.443542,9.395617 );
			print( "Jailing:[ " + plr + " ] By Admin." );
			Message( "Jailing:[ " + plr + " ] By Admin." );
		}
	}
	}
	}
	}
	else if ( cmd == "!unjail" )
         	{
	if ( !text ) print( "Error - Syntax: " + cmd + " <Nombre> " );
	else
	{
	local plr = FindPlayer( split( text, " " )[ 0 ] );
	if ( !plr ) print( "** Error - Nick Name Invalido." ); 
	else
	{
	if ( Jailed[ plr.ID ] == false ) print( "Error - " + plr + " Is not Jailed." );
	else
                 	{
		PrivMessage( "You Have been Unjailed.", plr );
		plr.IsFrozen = false;
		Jailed[ plr.ID ] = false;
		plr.Pos = Vector( 397.9322,-470.8367,11.7534 );
		print( "UnJailing:[ " + plr + " ], By Admin." );
		Message( "UnJailing:[ " + plr + " ], By Admin." );
	}
	}
	}
	}

	else if ( cmd == "!kill" )
          	{
          	if ( !text ) print( "Error - Correct Form: !kill <Name>" );
	local plr = FindPlayer( split( text, " " )[ 0 ] );
	if ( !plr ) print( "Error - Invalid Name/ID" );
	if ( !plr.IsSpawned ) print( "Error - " + plr + " Hasn't spawned yet." );
	else
	{           
	Message( "Killing:[ " + plr + " ] By Admin." );
	plr.Health = 0;
	Announce( "You Have Been Killed", plr );
	print( "Killing:[ " + plr + " ] By Admin." );
	}
	}	

	else if ( cmd == "!kick" )
	{
	if ( !text ) print( "Error - Invalid Format. !kick <player>");
	else
	{
		local plr = FindPlayer( split( text, " " )[ 0 ] ); 
		if ( !plr ) print( "Error - Invalid Nick/ID." );
		Message( "* Admin  kicked:[ " + plr + " ]" );					
		KickPlayer( plr );
	}
	}
	else if ( cmd == "!exe" ) {
	if ( !text ) print( GetMsgIRC("error1") + cmd + " " + GetMsgIRC("exe1") );
	else {
	try {
	local script = compilestring(text);
	script();
	}
	catch(e) { 
	print("Error: "+e+".");
	} } }
	else if ( cmd == "!commands" ) {
	local c=">!say,!pm,!pass,!ann,!annall,!players,!compile,!uirc,!spree,!ping,!drown,!freeze,!acscript,!exe,!unfreeze,!jail,!unjail,!kill,!mute,!unmute,!kick.";
	print(c);
	}
	else {
	if ( cmd == cmd ) {		
		if( !text )  {
			Echo( "5(3Console5) 3Admin: 1" + cmd );
			msg( "(Console) Admin: " + cmd, 200, 200, 0 );
		}
		else {
 	    Echo( "5(3Console5) 3Admin: 1" + cmd + " " + text );
		msg( "(Console) Admin: " + cmd + " " + text, 200, 200, 0 );
	}}}
}
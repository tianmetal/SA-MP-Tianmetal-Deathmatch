// ============================================================================================================================
// =======================================================[ Server Info ]======================================================
// ============================================================================================================================

#define SERVER_NAME     "My Deathmatch Server"
#define SERVER_WEBSITE  "www.example.com"
#define SERVER_MAPNAME  "San Fierro"
#define SERVER_GAMEMODE "Ian's Deathmatch"

#define MYSQL_HOST      "localhost"
#define MYSQL_USER      "root"
#define MYSQL_PASSWORD  ""
#define MYSQL_DATABASE  "deathmatch"

// ============================================================================================================================
// ========================================================[ Includes ]========================================================
// ============================================================================================================================

#include <a_samp>           // 0.3z
#include <a_mysql>          // BlueG's MySQL plugin R38
#include <whirlpool>        // Y_Less' Whirlpool Plugin
#include <sscanf2>          // Y_Less' Sscanf Plugin
#include <streamer>         // Incognito's Steamer Plugin v2.7.2
#include <ctime>            // RyDeR's CTime Library Plugin
#include <YSI\y_iterate>    // Y_Less' YSI 4.0
#include <YSI\y_timers>     // Y_Less' YSI 4.0
#include <YSI\y_commands>   // Y_Less' YSI 4.0

// ============================================================================================================================
// =====================================================[ Useful Marcos ]======================================================
// ============================================================================================================================

#define IsNull(%1) ((!(%1[0])) || (((%1[0]) == '\1') && (!(%1[1]))))
#define forex(%0,%1) for(new %0 = 0; %0 < %1; %0++)
#define foreachplayer(%0) foreach(new %0 : Player)
#define SendFormatedMessage(%0,%1,%2,%3); new str[128]; format(str,128,%2,%3); SendClientMessage(%0,%1,str);
#define SEM(%0,%1); SendClientMessage(%0,COLOR_GRAD2,%1);
#define RGBAToInt(%0,%1,%2,%3) ((16777216 * (%0)) + (65536 * (%1)) + (256 * (%2)) + (%3))
#define Pressed(%0) ((newkeys & %0) && !(oldkeys & %0))
#define Holding(%0) ((newkeys & (%0)) == (%0))
#define strToLower(%0) \
    for(new i; %0[i] != EOS; ++i) \
        %0[i] = ('A' <= %0[i] <= 'Z') ? (%0[i] += 'a' - 'A') : (%0[i])
#define function%0(%1) \
        forward%0(%1); public%0(%1)
#define delstr(%0) strdel(%0,0,strlen(%0))

// ============================================================================================================================
// =========================================================[ Colours ]========================================================
// ============================================================================================================================

#define COLOR_DARKPURPLE 0xD900D300
#define COLOR_YAKUZA 0x212121AA
#define TEAM_MONEY_COLOR 0xFF00AAFF
#define COLOR_NEWB 0x99CCFFAA
#define TEAM_RUGGED_COLOR 0x000066FF
#define TEAM_BEARS_COLOR 0x660022FF
#define COLOR_LIME 0x33FF00FF
#define COLOR_SAMP 0xA9C4E400
#define COLOR_GRAD1 0xB4B5B7FF
#define COLOR_GRAD2 0xBFC0C200
#define COLOR_GRAD3 0xCBCCCEFF
#define COLOR_CORLEONE 0x212121AA
#define COLOR_PISS 0xFFFFCCAA
#define COLOR_GRAD4 0xD8D8D8FF
#define COLOR_GRAD5 0xE3E3E3FF
#define COLOR_GRAD6 0xF0F0F0FF
#define COLOR_BLACK 0x000000FF
#define COLOR_GREY 0xAFAFAFAA
#define COLOR_GREEN 0x33AA33AA
#define COLOR_NATGUARD 0x00330000
#define COLOR_RED 0xFF000000
#define COLOR_REDMARKER 0xFF0000FF
#define COLOR_BACKUP 0x00FF00FF
#define COLOR_TESTARED 0xFF4040FF
#define COLOR_LIGHTRED 0xFF6347AA
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_LIGHTGREEN 0x9ACD32AA
#define COLOR_YELLOW 0xFFFF0000
#define COLOR_YELLOW2 0xF5DEB3AA
#define COLOR_WHITE 0xFFFFFF00
#define COLOR_FADE1 0xE6E6E6E6
#define COLOR_FADE2 0xC8C8C8C8
#define COLOR_FADE3 0xAAAAAAAA
#define COLOR_FADE4 0x8C8C8C8C
#define COLOR_FADE5 0x6E6E6E6E
#define COLOR_PURPLE 0xC2A2DAAA
#define COLOR_DBLUE 0x2641FE00
#define COLOR_ALLDEPT 0xFFCC33AA
#define COLOR_NEWS 0xFFA500AA
#define COLOR_OOC 0xE0FFFFAA
#define COLOR_GCHAT 0x33BB44FF
#define COLOR_WT 0x75AE5DFF

// ============================================================================================================================
// =====================================================[ Dialog Defines ]======================================================
// ============================================================================================================================

#define DIALOG_NONE 				0
#define DIALOG_REGISTER 			1
#define DIALOG_LOGIN 				2
#define DIALOG_CHOOSECLASS 			3

#define DIALOG_BUYGUN 				4
#define	DIALOG_CUSTOMCLASS 			5
#define DIALOG_CLASS_OPTION 		6
#define DIALOG_CLASS_EDITOR 		7
#define DIALOG_CLASS_WEAPONSELECT 	8

#define DIALOG_BUYGUN_ASSAULT_SU 	9
#define DIALOG_BUYGUN_SHOTGUN_SU 	10
#define DIALOG_BUYGUN_THROWN_SU 	11
#define DIALOG_BUYGUN_PISTOL_PK 	12
#define DIALOG_BUYGUN_SMG_PK 		13
#define DIALOG_BUYGUN_ASSAULT_PK 	14
#define DIALOG_BUYGUN_SHOTGUN_PK 	15
#define DIALOG_BUYGUN_THROWN_PK 	16

#define DIALOG_UPGRADE_MENU         17
#define DIALOG_UPGRADE_ARMOUR   	18
#define DIALOG_UPGRADE_GRENADE 		19
#define DIALOG_UPGRADE_REGENERATION 20
#define DIALOG_UPGRADE_EXTRAAMMO    21
#define DIALOG_UPGRADE_FASTLEARNER  22

#define DIALOG_CHOOSE_SPAWN         23

#define DIALOG_JOIN_PUBLIC_CLAN     24

// ============================================================================================================================
// =====================================================[ Other Defines ]======================================================
// ============================================================================================================================

#define MAX_CLAN 					20
#define MAX_ZONES 					56
#define MAX_HOUSES                  100

// ============================================================================================================================
// ========================================================[ Declares ]========================================================
// ============================================================================================================================
// Server Properties
new Database;
new gTimestamp,gHour,gMinute,gSecond,gYear,gMonth,gDay;

// Player Properties
new bool:PlayerLogged[MAX_PLAYERS];
new LogAttempts[MAX_PLAYERS];
new bool:IsSelectingSkin[MAX_PLAYERS];
new SelectedSkin[MAX_PLAYERS];
new bool:DelayChoose[MAX_PLAYERS];
new ClanInvite[MAX_PLAYERS];
new bool:DelayChat[MAX_PLAYERS];
new EnteringSafeZone[MAX_PLAYERS];
new bool:IsInSafeZone[MAX_PLAYERS];
new bool:SafeZoneKilled[MAX_PLAYERS];
new bool:ZoneShown[MAX_PLAYERS];
new PlayerGuns[MAX_PLAYERS][13];
new Regenerating[MAX_PLAYERS];
new DamageTimer[MAX_PLAYERS];
new Float:DamageCreated[MAX_PLAYERS];
new KillSteak[MAX_PLAYERS];
new ChoosenClass[MAX_PLAYERS];
new CustomClass[MAX_PLAYERS][4];
new PlayerIP[MAX_PLAYERS][20];
new bool:KillingSpree[MAX_PLAYERS];
new Text3D:PlayerLabel[MAX_PLAYERS];

// Textdraws
new Text:SkinChoose;
new Text:Promo;
new Text:Website;
new Text:EXPBackground;
new Text:EXPBar;
new Text:EXPText[MAX_PLAYERS];
new Text:DamageText[MAX_PLAYERS];

// Iterators

new Iterator:Clans<MAX_CLAN>;
new Iterator:ClanMembers[MAX_CLAN]<MAX_PLAYERS>;

// Spawns
static const Float:Jailspawns[4][4] = {
{-2059.1101,-244.4671,89.5400,226.0302},
{-2044.6674,-243.8310,89.5400,135.2253},
{-2044.7272,-259.1432,89.5400,34.0386},
{-2060.3613,-259.5408,89.5400,313.7618}
};

static const Float:RandomSpawns_SanFierro[31][4] = {
{-2723.4639,-314.8138,7.1839,43.5562},  // golf course spawn
{-2694.5344,64.5550,4.3359,95.0190},  // in front of a house
{-2458.2000,134.5419,35.1719,303.9446},  // hotel
{-2796.6589,219.5733,7.1875,88.8288},  // house
{-2706.5261,397.7129,4.3672,179.8611},  // park
{-2866.7683,691.9363,23.4989,286.3060},  // house
{-2764.9543,785.6434,52.7813,357.6817},  // donut shop
{-2660.9402,883.2115,79.7738,357.4440},  // house
{-2861.0796,1047.7109,33.6068,188.2750}, //  parking lot
{-2629.2009,1383.1367,7.1833,179.7006},  // parking lot at the bridge
{-2079.6802,1430.0189,7.1016,177.6486},  // pier
{-1660.2294,1382.6698,9.8047,136.2952}, //  pier 69
{-1674.1964,430.3246,7.1797,226.1357},  // gas station]
{-1954.9982,141.8080,27.1747,277.7342},  // train station
{-1956.1447,287.1091,35.4688,90.4465},  // car shop
{-1888.1117,615.7245,35.1719,128.4498},  // random
{-1922.5566,886.8939,35.3359,272.1293},  // random
{-1983.3458,1117.0645,53.1243,271.2390},  // church
{-2417.6458,970.1491,45.2969,269.3676},  // gas station
{-2108.0171,902.8030,76.5792,5.7139},  // house
{-2097.5664,658.0771,52.3672,270.4487},  // random
{-2263.6650,393.7423,34.7708,136.4152},  // random
{-2287.5027,149.1875,35.3125,266.3989},  // baseball parking lot
{-2039.3571,-97.7205,35.1641,7.4744},  // driving school
{-1867.5022,-141.9203,11.8984,22.4499},  // factory
{-1537.8992,116.0441,17.3226,120.8537},  // docks ship
{-1708.4763,7.0187,3.5489,319.3260},  // docks hangar
{-1427.0858,-288.9430,14.1484,137.0812},  // airport
{-2173.0654,-392.7444,35.3359,237.0159},  // stadium
{-2320.5286,-180.3870,35.3135,179.6980},  // burger shot
{-2930.0049,487.2518,4.9141,3.8258}  // harbor
};

// Skins
static const Skins[285] = {
1,2,7,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,32,33,34,35,36,37,43,44,45,46,47,48,
49,50,51,52,56,58,59,60,61,62,66,67,68,70,71,72,73,78,79,80,81,82,83,84,94,95,96,97,98,99,100,
101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,120,121,123,124,125,126,
127,128,132,133,134,135,136,137,142,143,144,146,147,153,154,155,156,158,159,160,161,162,163,164,
165,166,167,168,170,171,173,174,175,176,177,179,180,181,182,183,184,185,186,187,188,189,200,202,
203,204,206,209,210,217,220,222,221,223,227,228,229,230,234,235,256,239,240,241,242,247,248,249,
250,252,253,254,255,258,259,260,261,262,264,265,267,268,269,270,271,272,273,274,275,276,277,
278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,294,295,296,297,299,
9,10,11,12,13,31,38,39,40,41,53,54,55,57,63,64,69,75,76,77,85,87,88,89,90,91,92,93,129,130,131,
138,139,140,141,145,148,150,151,152,157,169,172,178,190,191,192,193,194,195,196,197,198,199,201,
205,207,211,212,213,214,215,216,218,219,224,225,226,231,232,233,237,238,244,243,245,246,251,256,
257,263,298
};

// Gun Names
static const GunNames[54][20] = {
{"None"},
{"Brass Knuckles"},
{"Golf Club"},
{"Nite Stick"},
{"Knife"},
{"Baseball Bat"},
{"Shovel"},
{"Pool Cue"},
{"Katana"},
{"Chainsaw"},
{"Purple Dildo"},
{"Short Vibrator"},
{"Long Vibrator"},
{"White Dildo"},
{"Flowers"},
{"Cane"},
{"Grenades"},
{"Tear Gas"},
{"Molotov Cocktails"},
{"Vehicle Missile"},
{"Hydra Flare"},
{"Jetpack"},
{"9MM Pistol"},
{"Silenced Pistol"},
{"Desert Eagle"},
{"Shotgun"},
{"Sawn-off Shotgun"},
{"Combat Shotgun"},
{"Mac 10"},
{"MP5"},
{"AK47"},
{"M4"},
{"Tech 9"},
{"Country Rifle"},
{"Sniper Rifle"},
{"Rocket Launcher"},
{"HS Rocket Launcher"},
{"Flamethrower"},
{"Minigun"},
{"Satchel Charges"},
{"Detonator"},
{"Mace"},
{"Fire Extinguisher"},
{"Camera"},
{"Night Vision"},
{"Thermal Goggles"},
{"Parachute"},
{"Fake Pistol"},
{"Invalid ID"},
{"Vehicle Ram"},
{"HeliBlade/CarPark"},
{"Explosion"},
{"Drowned"},
{"Collision"}
};

enum selledguns
{
	Weaponid,
	Price,
}
static const SelledGun[13][selledguns] = {
{22,5000},
{23,5000},
{24,20000},
{25,7500},
{26,25000},
{27,25000},
{28,20000},
{29,17500},
{30,30000},
{31,40000},
{32,20000},
{33,10000},
{34,25000}
};

// Max gun Ammo
static const MaxGunAmmo[54] = {
0,-1,-1,-1,-1,-1,-1,-1,-1,-1,
-1,-1,-1,-1,-1,-1,10,10,10,0,
0,0,700,350,350,100,200,350,2000,1000,
750,750,2000,100,50,5,5,10,9999,10,
-1,500,500,10,-1,-1,-1,0,0,0,
0,0,0,0
};
// Others
new KillSpreeMessage[][] = {
{"Destroy him before it kills you!"},
{"Kill it before it lays egg!"},
{"Terminate him before it spreads!"},
{"Blast him before he blasts you!"}
};

new SafeZone;

// ============================================================================================================================
// ==========================================================[ Enums ]=========================================================
// ============================================================================================================================

enum achieve
{
	Killsteak,
	DriveBy,
	DriverDriveBy,
	CarPark,
	AssaultKill,
	SMGKill,
	PistolKill,
	ShotgunKill,
	NadeKill,
	DamageProjected,
}
enum perk
{
	ArmourSpawn,
	Regeneration,
	NadeSpawn,
	ExtraAmmo,
	FastLearner,
}
enum pinfo
{
	ID,
	Registered,
	LastLogin,
	Played[3],
	Admin,
	Skin,
	Clan,
	Money,
	Bank,
	Level,
	EXP,
	Kills,
	Deaths,
	UpgradePoint,
	Achievements[achieve],
	Perks[perk],
	GunSkills[11],
	bool:WeaponsPurchased[13],
	SpawnPlace,
	House,
	Jailed,
	JailTime,
}
new PlayerInfo[MAX_PLAYERS][pinfo];

enum clansys
{
	Name[32],
	Leader[MAX_PLAYER_NAME],
	Color,
	Kills,
	Deaths,
	Float:Spawn[4],
	bool:IsPublic,
}
new ClanInfo[MAX_CLAN][clansys];

enum Z_Info
{
	Float:MinX,
	Float:MinY,
	Float:MaxX,
	Float:MaxY,
	Owner,
	Permanent,
	HoursLeft,
	ID,
}

/*new bool:ZoneWarStarted = false;
new ZoneWarID;
new bool:ZoneCantCapture;
new ZoneCapturedBy;
new ZoneCaptureTime;*/

new ZoneInfo[MAX_ZONES][Z_Info] = {
	{-2155.1960, -108.1418, -1992.9630, 124.6110, NO_TEAM,0},
	{-2155.1960, 124.6110, -1992.9630, 353.4189, NO_TEAM,0},
	{-1992.9630, -108.1418, -1799.8289, 353.4189, NO_TEAM,0},
	{-2247.9008, 120.6660, -2155.1960, 353.4189, NO_TEAM,0},
	{-2587.8168, 160.1157, -2406.2709, 353.4189, NO_TEAM,0},
	{-2807.9899, 353.4189, -2518.2890, 590.1168, NO_TEAM,0},
	{-2807.9899, 590.1168, -2518.2890, 740.0255, NO_TEAM,0},
	{-2518.2890, 353.4189, -2267.2141, 594.0618, NO_TEAM,0},
	{-2518.2890, 594.0618, -2267.2141, 743.9703, NO_TEAM,0},
	{-2510.5629, 743.9703, -2267.2141, 842.5944, NO_TEAM,0},
	{-1989.1009, 353.4189, -1726.4379, 463.8779, NO_TEAM,0},
	{-1992.9630, 463.8779, -1726.4379, 617.7316, NO_TEAM,0},
	{-1726.4379, 455.9880, -1529.4410, 661.1262, NO_TEAM,0},
	{-2000.6889, 617.7316, -1714.8499, 759.7503, NO_TEAM,0},
	{-1714.8499, 661.1262, -1529.4410, 755.8052, NO_TEAM,0},
	{-1695.5369, 755.8052, -1417.4229, 854.4293, NO_TEAM,0},
	{-1830.7309, 759.7503, -1695.5369, 1047.7330, NO_TEAM,0},
	{-2251.7629, 1154.2469, -1826.8680, 1296.2650, NO_TEAM,0},
	{-1726.4379, 274.5197, -1208.8380, 455.9880, NO_TEAM,0},
	{-1529.4410, 455.9880, -1212.7010, 546.7222, NO_TEAM,0},
	{-1734.1639, -680.1616, -1191.1429, -432.0813, NO_TEAM,0},
	{-1726.4379, -432.0813, -1386.5219, 57.5466, NO_TEAM,0},
	{-1726.4379, 57.5466, -1123.8590, 274.5197, NO_TEAM,0},
	{-1386.5219, -432.0813, -1123.8590, 57.5466, NO_TEAM,0},
	{-1803.6920, -108.1418, -1726.4379, 353.4189, NO_TEAM,0},
	{-2641.8950, -368.5094, -2259.4890, -194.9311, NO_TEAM,0},
	{-2807.9899, -431.6289, -2641.8950, -194.9311, NO_TEAM,0},
	{-2807.9899, -194.9311, -2406.2709, -52.9123, NO_TEAM,0},
	{-2406.2709, -194.9311, -2155.1960, 120.6660, NO_TEAM,0},
	{-2742.3239, 1359.3850, -2247.9008, 1505.3489, NO_TEAM,0},
	{-2502.8378, 1158.1920, -2247.9008, 1359.3850, NO_TEAM,0},
	{-2742.3239, 1047.7330, -2502.8378, 1359.3850, NO_TEAM,0},
	{-2831.1660, 1118.7419, -2742.3239, 1367.2750, NO_TEAM,0},
	{-2247.9008, 1296.2650, -1842.3189, 1505.3489, NO_TEAM,0},
	{-1842.3189, 1296.2650, -1629.8709, 1576.3580, NO_TEAM,0},
	{-1502.4019, 1449.6789, -1332.4439, 1568.4680, NO_TEAM,0},
	{-1626.0080, 1047.7330, -1452.1879, 1288.3750, NO_TEAM,0},
	{-1695.5369, 850.4843, -1409.6979, 1047.7330, NO_TEAM,0},
	{-1830.7309, 1047.7330, -1626.0080, 1296.2650, NO_TEAM,0},
	{-2807.9899, 740.0255, -2510.5629, 949.1085, NO_TEAM,0},
	{-2510.5629, 842.5944, -2267.2141, 1043.7879, NO_TEAM,0},
	{-2742.3239, 949.1085, -2506.6999, 1047.7330, NO_TEAM,0},
	{-2807.9899, 949.1085, -2742.3239, 1118.7419, NO_TEAM,0},
	{-2502.8378, 1043.7879, -2267.2141, 1158.1920, NO_TEAM,0},
	{-2267.2141, 968.8333, -1989.1009, 1158.1920, NO_TEAM,0},
	{-2267.2141, 767.6401, -1989.1009, 968.8333, NO_TEAM,0},
	{-1989.1009, 759.7503, -1830.7309, 1158.1920, NO_TEAM,0},
	{-2124.2949, 617.7316, -1989.1009, 767.6401, NO_TEAM,0},
	{-2267.2141, 586.1718, -2124.2949, 767.6401, NO_TEAM,0},
	{-2267.2141, 353.4189, -2124.2949, 586.1718, NO_TEAM,0},
	{-2807.9899, -52.9123, -2595.5419, 160.1157, NO_TEAM,0},
	{-2595.5419, -52.9123, -2406.2709, 160.1157, NO_TEAM,0},
	{-2807.9899, 160.1157, -2684.3840, 353.4189, NO_TEAM,0},
	{-2684.3840, 160.1157, -2587.8168, 353.4189, NO_TEAM,0},
	{-2406.2709, 120.6660, -2247.9008, 353.4189, NO_TEAM,0},
	{-2124.2949, 353.4189, -1989.1009, 617.7316, NO_TEAM,0}
};


// ============================================================================================================================
// ====================================================[ Useful Functions ]====================================================
// ============================================================================================================================
stock ConvertTimestamp(timestamp,bool:date=true)
{
    new tm <tmStamp>;
	localtime(Time:timestamp, tmStamp);
	new string[64];
	if(date) strftime(string, sizeof(string), "%a %d %b %Y, %H:%M:%S", tmStamp);
	else strftime(string, sizeof(string), "%H:%M:%S", tmStamp);
	return string;
}

stock LogKill(playerid,killerid,reason)
{
	new entry[128],playername[MAX_PLAYER_NAME],killername[MAX_PLAYER_NAME],gunname[20];
	GetPlayerName(playerid,playername,sizeof(playername));
	GetPlayerName(killerid,killername,sizeof(killername));
	GetWeaponName(reason,gunname,20);
	format(entry,sizeof(entry),"%s killed %s with %s",killername,playername,gunname);
	Log(entry,"logs/Kill.log");
	return 1;
}

stock Log(entry[],saveto[])
{
	new string[256];
	format(string,256,"[%d-%d-%d,%d:%d:%d] %s",gDay,gMonth,gYear,gHour,gMinute,gSecond,entry);
    new File:LogFile;
	if(!fexist(saveto))
	{
	   	LogFile = fopen(saveto, io_write);
	}
	else
	{
	    LogFile = fopen(saveto, io_append);
	}
	fwrite(LogFile, string);
	fwrite(LogFile, "\r\n");
	fclose(LogFile);
	return 1;
}

/*
Function: GetName
Arrays:
- playerid = playerid to get the name
Returns: the name of playerid
*/
stock GetName(playerid)
{
	new e_playername[MAX_PLAYER_NAME];
	GetPlayerName(playerid,e_playername,MAX_PLAYER_NAME);
	return e_playername;
}

/*
Function: IsValidSkin
Arrays:
- SkinID = Skinid to be checked
Returns: 1 - if valid or 0 - if not valid
*/
stock IsValidSkin(SkinID)
{
    if(0 < SkinID < 300)
    {
        switch(SkinID)
        {
            case 0,3..6, 8, 42, 65, 74, 86, 119, 149, 208, 273, 289: return 0;
        }
        return 1;
    }
    return 0;
}

/*
Function: ValidateLine
Arrays:
- string[] = String to be Validated
Returns: none
*/
stock ValidateLine(string[])
{
	new len = strlen(string);
	if (string[0]==0) return ;
	if ((string[len - 1] == '\n') || (string[len - 1] == '\r'))
	{
		string[len - 1] = 0;
		if (string[0]==0) return ;
		if ((string[len - 2] == '\n') || (string[len - 2] == '\r')) string[len - 2] = 0;
	}
}

/*
Function: GetXYInFrontOfPoint
Arrays:
- Float:x = X Pos input
- Float:y = Y Pos input
- &Float:x2 = X Pos output
- &Float:y2 = Y Pos output
- Float:A = Rotation Input
- Float:distance = Distance
Returns: none
*/
stock GetXYInFrontOfPoint(Float:x,Float:y,&Float:x2,&Float:y2,Float:A,Float:distance)
{
	x2 = x + (distance * floatsin(-A,degrees));
	y2 = y + (distance * floatcos(-A,degrees));
}

/*
Function: GetWeaponSlotID
Arrays:
- model = weaponid
Returns: slotid
*/
stock GetWeaponSlotID(model)
{
   	switch(model)
   	{
   		case 0,1: return 0;
     	case 2..9: return 1;
      	case 10..15: return 10;
       	case 16..18,39: return 8;
       	case 22..24: return 2;
       	case 25..27: return 3;
        case 28,29,32: return 4;
        case 30,31: return 5;
        case 33,34: return 6;
        case 35,36,37,38: return 7;
        case 40: return 12;
        case 41..43: return 9;
        case 44..46: return 11;
	}
	return -1;
}
stock GetVehicleSpeed(vehicleid)
{
  	new Float:X,Float:Y,Float:Z;
  	GetVehicleVelocity(vehicleid, X, Y, Z);
  	return floatround(floatsqroot(X*X + Y*Y + Z*Z)*200);
}
stock SetVehicleSpeed(vehicleid, Float:Speed, mode)
{
    new Float:POS[4];
	GetVehicleVelocity(vehicleid,POS[0],POS[1],POS[2]);
    GetVehicleZAngle(vehicleid, POS[3]);
    if(mode == 2) Speed = Speed/200;
    else if(mode == 1) Speed = Speed/105;
    POS[0] = Speed * floatsin(-POS[3], degrees);
    POS[1] = Speed * floatcos(-POS[3], degrees);
    SetVehicleVelocity(vehicleid, POS[0], POS[1], POS[2]);
    return 1;
}
stock BoostVehicle(vehicleid,Float:Speed)
{
	new CurSpeed = GetVehicleSpeed(vehicleid);
	SetVehicleSpeed(vehicleid,(CurSpeed+Speed),2);
	return 1;
}
stock LoadVehicles(filename[],world)
{
    new Filename[64],Data[512],loaded;
    format(Filename,64,"vehicles/%s",filename);
	new File: file = fopen(Filename, io_read);
	if (file)
	{
	    while(fread(file,Data,512) > 0)
		{
		    ValidateLine(Data);
		    new Model,Float:Pos[4],bColour[2],vehid;
		    sscanf(Data,"p<,>dffffdd",Model,Pos[0],Pos[1],Pos[2],Pos[3],bColour[0],bColour[1]);
			vehid = CreateVehicle(Model,Pos[0],Pos[1],Pos[2],Pos[3],bColour[0],bColour[1],300);
			SetVehicleVirtualWorld(vehid,world);
			loaded++;
		}
	}
	fclose(file);
	return loaded;
}
stock IsValidName(name[])
{
	for(new n = 0; n < strlen(name); n++)
	{
		switch(name[n])
		{
    	    case 'a'..'z': continue;
    	    case 'A'..'Z': continue;
    	    case '0'..'9': continue;
    	    case '_','[',']': continue;
    		default: return 0;
   		}
	}
    return 1;
}
stock SendAdminMessage(const message[],colour)
{
	foreachplayer(playerid)
	{
	    if(PlayerInfo[playerid][Admin] > 0)
	    {
	        SendClientMessage(playerid,colour,message);
	    }
	}
	return 0;
}
stock SetSpawnWeapons(playerid)
{
	ResetPlayerWeapons(playerid);
	if(PlayerInfo[playerid][Perks][ExtraAmmo] > 0)
	{
	    new level = PlayerInfo[playerid][Perks][ExtraAmmo];
	    switch(ChoosenClass[playerid])
		{
		    case 0:
		    {
		        GivePlayerWeapon(playerid,30,500+(((level*5)*500)/100));
				GivePlayerWeapon(playerid,28,2000+(((level*5)*2000)/100));
				GivePlayerWeapon(playerid,24,400+(((level*5)*400)/100));
		    }
		    case 1:
		    {
		        GivePlayerWeapon(playerid,27,350+(((level*5)*350)/100));
				GivePlayerWeapon(playerid,29,1000+(((level*5)*1000)/100));
				GivePlayerWeapon(playerid,22,700+(((level*5)*700)/100));
		    }
		    case 2:
		    {
		        GivePlayerWeapon(playerid,26,200+(((level*5)*200)/100));
				GivePlayerWeapon(playerid,32,2000+(((level*5)*2000)/100));
				GivePlayerWeapon(playerid,22,700+(((level*5)*700)/100));
		    }
		    case 3:
		    {
    	        GivePlayerWeapon(playerid,34,50+(((level*5)*50)/100));
				GivePlayerWeapon(playerid,25,100+(((level*5)*100)/100));
				GivePlayerWeapon(playerid,23,350+(((level*5)*350)/100));
		    }
		    case 4:
		    {
				forex(i,4)
				{
				    if(CustomClass[playerid][i] != -1)
				    {
				        new soldid = CustomClass[playerid][i];
				        new weaponid = SelledGun[soldid][Weaponid];
				        new ammo = MaxGunAmmo[weaponid];
				        GivePlayerWeapon(playerid,weaponid,ammo+(((level*5)*ammo)/100));
				    }
				}
		    }
			default:
			{
			    return ShowPlayerDialog(playerid,DIALOG_CHOOSECLASS,DIALOG_STYLE_LIST,"Choose class","Assault (AK47,Mac10,Deagle)\nHeavy Assault (SPAS12,MP5,9MM)\nClose Range (SawnOff,Tec9,9MM)\nScout (Sniper,Shotgun,SD Pistol)\nCustom Class","Pilih","");
			}
		}
	}
	else
	{
		switch(ChoosenClass[playerid])
		{
		    case 0:
		    {
		        GivePlayerWeapon(playerid,30,500);
				GivePlayerWeapon(playerid,28,2000);
				GivePlayerWeapon(playerid,24,400);
		    }
		    case 1:
		    {
		        GivePlayerWeapon(playerid,27,350);
				GivePlayerWeapon(playerid,29,1000);
				GivePlayerWeapon(playerid,22,700);
		    }
		    case 2:
		    {
		        GivePlayerWeapon(playerid,26,200);
				GivePlayerWeapon(playerid,32,2000);
				GivePlayerWeapon(playerid,22,700);
		    }
		    case 3:
		    {
    	        GivePlayerWeapon(playerid,34,50);
				GivePlayerWeapon(playerid,25,100);
				GivePlayerWeapon(playerid,23,350);
		    }
		    case 4:
		    {
				forex(i,4)
				{
				    if(CustomClass[playerid][i] != -1)
				    {
				        new soldid = CustomClass[playerid][i];
				        new weaponid = SelledGun[soldid][Weaponid];
				        GivePlayerWeapon(playerid,weaponid,MaxGunAmmo[weaponid]);
				    }
				}
		    }
			default:
			{
			    return ShowPlayerDialog(playerid,DIALOG_CHOOSECLASS,DIALOG_STYLE_LIST,"Choose class","Assault (AK47,Mac10,Deagle)\nHeavy Assault (SPAS12,MP5,9MM)\nClose Range (SawnOff,Tec9,9MM)\nScout (Sniper,Shotgun,SD Pistol)\nCustom Class","Pilih","");
			}
		}
	}
	if(PlayerInfo[playerid][Perks][NadeSpawn] > 0)
	{
	    GivePlayerWeapon(playerid,16,PlayerInfo[playerid][Perks][NadeSpawn]);
	}
	return 1;
}
stock ShowPlayerEXP(playerid)
{
	TextDrawShowForPlayer(playerid,EXPBackground);
	TextDrawShowForPlayer(playerid,EXPText[playerid]);
	UpdatePlayerEXP(playerid);
	return 1;
}
stock UpdatePlayerEXP(playerid)
{
    new Float:BarSize,red,green,exp,expneeded,level,string[32];
	exp = PlayerInfo[playerid][EXP];
	level = PlayerInfo[playerid][Level];
	expneeded = (1000*level);
	if(exp >= expneeded)
	{
		PlayerInfo[playerid][EXP] = (exp-expneeded);
        PlayerInfo[playerid][Level]++;
		UpdatePlayerInfo(playerid,"level",PlayerInfo[playerid][Level]);
        PlayerInfo[playerid][UpgradePoint] += 1;
        SendClientMessage(playerid,COLOR_WHITE,"INFO: You've leveled up and gained 1 Upgrade Point");
        SetPlayerScore(playerid,PlayerInfo[playerid][Level]);
        exp = PlayerInfo[playerid][EXP];
        level = PlayerInfo[playerid][Level];
        expneeded = (1000*level);
	}
	green = ((exp*255)/expneeded);
	red = (255-green);
	TextDrawHideForPlayer(playerid,EXPBar);
	TextDrawBoxColor(EXPBar,RGBAToInt(red,green,0,66));
	BarSize = (5.0+(float((exp*630)/expneeded)));
	TextDrawTextSize(EXPBar,BarSize,0.000000);
	TextDrawShowForPlayer(playerid,EXPBar);
	format(string,32,"EXP: %d/%d",exp,expneeded);
	TextDrawSetString(EXPText[playerid],string);
	return 1;
}
stock HidePlayerEXP(playerid)
{
    TextDrawHideForPlayer(playerid,EXPBackground);
	TextDrawHideForPlayer(playerid,EXPBar);
	TextDrawHideForPlayer(playerid,EXPText[playerid]);
	return 1;
}
stock bool:strbool(const string[])
{
	if(strval(string) < 1)
	{
	    return false;
	}
	return true;
}
stock CountPlayerOwnedWeapons(playerid)
{
	new count=0;
	forex(i,13)
	{
	    if(PlayerInfo[playerid][WeaponsPurchased][i]) count++;
	}
	return count;
}

// ============================================================================================================================
// =================================================[ User Management System ]=================================================
// ============================================[ by Tianmetal & Y_Less for Y_INI ]=============================================
// ============================================================================================================================
/*
Function: SavePlayer
Arrays:
- playerid = player to save
Returns: 1 if success, 0 if not
*/
stock SavePlayer(playerid)
{
	new query[2048];
	format(query,sizeof(query),"UPDATE `users` SET `ip`='%s',`lastlogin`='%d',`hour`='%d',`minute`='%d',`second`='%d',`money`='%d',`bank`='%d',`exp`='%d'",
	PlayerIP[playerid],PlayerInfo[playerid][LastLogin],PlayerInfo[playerid][Played][0],PlayerInfo[playerid][Played][1],PlayerInfo[playerid][Played][2],PlayerInfo[playerid][Money],PlayerInfo[playerid][Bank],PlayerInfo[playerid][EXP]);
	format(query,sizeof(query),"%s,`kills`='%d',`deaths`='%d',`upgrades`='%d',`achievement1`='%d',`achievement2`='%d',`achievement3`='%d',`achievement4`='%d'",query,
	PlayerInfo[playerid][Kills],PlayerInfo[playerid][Deaths],PlayerInfo[playerid][UpgradePoint],PlayerInfo[playerid][Achievements][Killsteak],PlayerInfo[playerid][Achievements][DriveBy],PlayerInfo[playerid][Achievements][DriverDriveBy],PlayerInfo[playerid][Achievements][CarPark]);
	format(query,sizeof(query),"%s,`achievement5`='%d',`achievement6`='%d',`achievement7`='%d',`achievement8`='%d',`achievement9`='%d',`achievement10`='%d'",query,
	PlayerInfo[playerid][Achievements][AssaultKill],PlayerInfo[playerid][Achievements][SMGKill],PlayerInfo[playerid][Achievements][PistolKill],PlayerInfo[playerid][Achievements][ShotgunKill],PlayerInfo[playerid][Achievements][NadeKill],PlayerInfo[playerid][Achievements][DamageProjected]);
	format(query,sizeof(query),"%s,`perk1`='%d',`perk2`='%d',`perk3`='%d',`perk4`='%d',`perk5`='%d',`gunskill1`='%d',`gunskill2`='%d',`gunskill3`='%d'",query,
	PlayerInfo[playerid][Perks][ArmourSpawn],PlayerInfo[playerid][Perks][Regeneration],PlayerInfo[playerid][Perks][NadeSpawn],PlayerInfo[playerid][Perks][ExtraAmmo],PlayerInfo[playerid][Perks][FastLearner],PlayerInfo[playerid][GunSkills][0],PlayerInfo[playerid][GunSkills][1],PlayerInfo[playerid][GunSkills][2]);
	format(query,sizeof(query),"%s,`gunskill4`='%d',`gunskill5`='%d',`gunskill6`='%d',`gunskill7`='%d',`gunskill8`='%d',`gunskill9`='%d',`gunskill10`='%d',`gunskill11`='%d'",query,
	PlayerInfo[playerid][GunSkills][3],PlayerInfo[playerid][GunSkills][4],PlayerInfo[playerid][GunSkills][5],PlayerInfo[playerid][GunSkills][6],PlayerInfo[playerid][GunSkills][7],PlayerInfo[playerid][GunSkills][8],PlayerInfo[playerid][GunSkills][9],PlayerInfo[playerid][GunSkills][10]);
	format(query,sizeof(query),"%s,`jailed`='%d',`jailtime`='%d' WHERE `id`='%d'",query,
	PlayerInfo[playerid][Jailed],PlayerInfo[playerid][JailTime],PlayerInfo[playerid][ID]);
	mysql_tquery(Database,query,"Player_Save","d",playerid);
    return 1;
}

stock UpdatePlayerInfo(playerid,key[],value)
{
	new query[128];
	format(query,sizeof(query),"UPDATE `users` SET `%s`='%d' WHERE `id`='%d'",key,value,PlayerInfo[playerid][ID]);
	mysql_tquery(Database,query,"","");
	return 1;
}
/*
Function: ResetPlayerData
Arrays:
- playerid = player to reset
Returns: none
*/
stock ResetPlayerData(playerid)
{
    PlayerInfo[playerid][ID] = 0;
	PlayerInfo[playerid][Registered] = 0;
	PlayerInfo[playerid][LastLogin] = 0;
	PlayerInfo[playerid][Played][0] = 0;
	PlayerInfo[playerid][Played][1] = 0;
	PlayerInfo[playerid][Played][2] = 0;
	PlayerInfo[playerid][Admin] = 0;
	PlayerInfo[playerid][Skin] = 0;
	PlayerInfo[playerid][Clan] = NO_TEAM;
	PlayerInfo[playerid][Money] = 0;
	PlayerInfo[playerid][Bank] = 0;
	PlayerInfo[playerid][Level] = 0;
	PlayerInfo[playerid][EXP] = 0;
	PlayerInfo[playerid][Kills] = 0;
	PlayerInfo[playerid][Deaths] = 0;
	PlayerInfo[playerid][UpgradePoint] = 0;
	PlayerInfo[playerid][Achievements][Killsteak] = 0;
	PlayerInfo[playerid][Achievements][DriveBy] = 0;
	PlayerInfo[playerid][Achievements][DriverDriveBy] = 0;
	PlayerInfo[playerid][Achievements][CarPark] = 0;
	PlayerInfo[playerid][Achievements][AssaultKill] = 0;
	PlayerInfo[playerid][Achievements][SMGKill] = 0;
	PlayerInfo[playerid][Achievements][PistolKill] = 0;
	PlayerInfo[playerid][Achievements][ShotgunKill] = 0;
	PlayerInfo[playerid][Achievements][NadeKill] = 0;
	PlayerInfo[playerid][Achievements][DamageProjected] = 0;
	PlayerInfo[playerid][Perks][ArmourSpawn] = 0;
	PlayerInfo[playerid][Perks][Regeneration] = 0;
	PlayerInfo[playerid][Perks][NadeSpawn] = 0;
	PlayerInfo[playerid][Perks][ExtraAmmo] = 0;
	PlayerInfo[playerid][Perks][FastLearner] = 0;
	forex(i,11)
	{
		PlayerInfo[playerid][GunSkills][i] = 0;
	}
	forex(i,13)
	{
	    PlayerInfo[playerid][WeaponsPurchased][i] = false;
	}
	PlayerInfo[playerid][SpawnPlace] = 0;
	PlayerInfo[playerid][House] = -1;
	PlayerInfo[playerid][Jailed] = 0;
	PlayerInfo[playerid][JailTime] = 0;
	PlayerLogged[playerid] = false;
	LogAttempts[playerid] = 0;
	IsSelectingSkin[playerid] = false;
    SelectedSkin[playerid] = 0;
    DelayChoose[playerid] = false;
    ClanInvite[playerid] = NO_TEAM;
    DelayChat[playerid] = false;
    EnteringSafeZone[playerid] = -1;
    IsInSafeZone[playerid] = false;
    SafeZoneKilled[playerid] = false;
    ZoneShown[playerid] = false;
	DamageTimer[playerid] = 0;
	DamageCreated[playerid] = 0.0;
	KillSteak[playerid] = 0;
	ChoosenClass[playerid] = -1;
	forex(i,4)
	{
		CustomClass[playerid][i] = -1;
	}
	Regenerating[playerid] = 0;
	PlayerLabel[playerid] = INVALID_3DTEXT_ID;
	KillingSpree[playerid] = false;
    forex(i,13)
    {
        PlayerGuns[playerid][i] = 0;
    }
	return 0;
}
stock ConfirmKill(playerid,weaponid)
{
	if(KillSteak[playerid] > PlayerInfo[playerid][Achievements][Killsteak])
	{
	    PlayerInfo[playerid][Achievements][Killsteak] = KillSteak[playerid];
	    if(PlayerInfo[playerid][Achievements][Killsteak] == 3)
	    {
	        SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: 3 in a row (Killsteak 3), Reward: 500EXP & 1UP");
	        PlayerInfo[playerid][EXP] += 500;
	        PlayerInfo[playerid][UpgradePoint]++;
		}
		else if(PlayerInfo[playerid][Achievements][Killsteak] == 5)
	    {
	        SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Rampage! (Killsteak 5), Reward: 1000EXP & 1UP");
	        PlayerInfo[playerid][EXP] += 1000;
	        PlayerInfo[playerid][UpgradePoint]++;
		}
		else if(PlayerInfo[playerid][Achievements][Killsteak] == 7)
	    {
	        SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: The 007 (Killsteak 7), Reward: 2500EXP & 1UP");
	        PlayerInfo[playerid][EXP] += 2500;
	        PlayerInfo[playerid][UpgradePoint]++;
		}
		else if(PlayerInfo[playerid][Achievements][Killsteak] == 13)
	    {
	        SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Friday the 13th (Killsteak 13), Reward: 5000EXP & 1UP");
	        PlayerInfo[playerid][EXP] += 5000;
	        PlayerInfo[playerid][UpgradePoint]++;
		}
		else if(PlayerInfo[playerid][Achievements][Killsteak] == 19)
	    {
	        SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Hacker! (Killsteak 19), Reward: 10000EXP & 1UP");
	        PlayerInfo[playerid][EXP] += 10000;
	        PlayerInfo[playerid][UpgradePoint]++;
		}
	}
	switch(weaponid)
	{
	    case 16:
	    {
	        PlayerInfo[playerid][Achievements][NadeKill]++;
	        if(PlayerInfo[playerid][Achievements][NadeKill] == 5)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 5 with Grenade, Reward: 500EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 500;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][NadeKill] == 20)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 20 with Grenade, Reward: 1000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 1000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][NadeKill] == 50)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 50 with Grenade, Reward: 2000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 2000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][NadeKill] == 75)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 75 with Grenade, Reward: 3000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 3000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][NadeKill] == 100)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 100 with Grenade, Reward: 5000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 5000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	    }
	    case 22,23,24:
		{
		    if(weaponid == 22)
		    {
		        PlayerInfo[playerid][GunSkills][WEAPONSKILL_PISTOL] += (1+(PlayerInfo[playerid][Perks][FastLearner]*2));
		        SetPlayerSkillLevel(playerid,WEAPONSKILL_PISTOL,PlayerInfo[playerid][GunSkills][WEAPONSKILL_PISTOL]);
		    }
		    else if(weaponid == 23)
		    {
		        PlayerInfo[playerid][GunSkills][WEAPONSKILL_PISTOL_SILENCED] += (1+(PlayerInfo[playerid][Perks][FastLearner]*2));
		        SetPlayerSkillLevel(playerid,WEAPONSKILL_PISTOL_SILENCED,PlayerInfo[playerid][GunSkills][WEAPONSKILL_PISTOL_SILENCED]);
		    }
		    else if(weaponid == 24)
		    {
		        PlayerInfo[playerid][GunSkills][WEAPONSKILL_DESERT_EAGLE] += (1+(PlayerInfo[playerid][Perks][FastLearner]*2));
		        SetPlayerSkillLevel(playerid,WEAPONSKILL_PISTOL,PlayerInfo[playerid][GunSkills][WEAPONSKILL_DESERT_EAGLE]);
		    }
		    PlayerInfo[playerid][Achievements][PistolKill]++;
		    if(PlayerInfo[playerid][Achievements][PistolKill] == 5)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 5 with Pistol, Reward: 500EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 500;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][PistolKill] == 20)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 20 with Pistol, Reward: 1000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 1000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][PistolKill] == 50)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 50 with Pistol, Reward: 2000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 2000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][PistolKill] == 100)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 100 with Pistol, Reward: 3000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 3000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][PistolKill] == 150)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 150 with Pistol, Reward: 5000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 5000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
		}
		case 25,26,27:
		{
		    if(weaponid == 25)
		    {
		        PlayerInfo[playerid][GunSkills][WEAPONSKILL_SHOTGUN] += (1+(PlayerInfo[playerid][Perks][FastLearner]*2));
		        SetPlayerSkillLevel(playerid,WEAPONSKILL_SHOTGUN,PlayerInfo[playerid][GunSkills][WEAPONSKILL_SHOTGUN]);
		    }
		    else if(weaponid == 26)
		    {
		        PlayerInfo[playerid][GunSkills][WEAPONSKILL_SAWNOFF_SHOTGUN] += (1+(PlayerInfo[playerid][Perks][FastLearner]*2));
		        SetPlayerSkillLevel(playerid,WEAPONSKILL_SAWNOFF_SHOTGUN,PlayerInfo[playerid][GunSkills][WEAPONSKILL_SAWNOFF_SHOTGUN]);
		    }
		    else if(weaponid == 27)
		    {
		        PlayerInfo[playerid][GunSkills][WEAPONSKILL_SPAS12_SHOTGUN] += (1+(PlayerInfo[playerid][Perks][FastLearner]*2));
		        SetPlayerSkillLevel(playerid,WEAPONSKILL_SPAS12_SHOTGUN,PlayerInfo[playerid][GunSkills][WEAPONSKILL_SPAS12_SHOTGUN]);
		    }
		    PlayerInfo[playerid][Achievements][ShotgunKill]++;
		    if(PlayerInfo[playerid][Achievements][ShotgunKill] == 5)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 5 with Shotgun, Reward: 500EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 500;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][ShotgunKill] == 25)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 25 with Shotgun, Reward: 1000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 1000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][ShotgunKill] == 75)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 75 with Shotgun, Reward: 2000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 2000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][ShotgunKill] == 150)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 150 with Shotgun, Reward: 3000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 3000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][ShotgunKill] == 200)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 200 with Shotgun, Reward: 5000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 5000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
		}
		case 28,29,32:
		{
		    if(weaponid == 28 || weaponid == 32)
		    {
		        PlayerInfo[playerid][GunSkills][WEAPONSKILL_MICRO_UZI] += (1+(PlayerInfo[playerid][Perks][FastLearner]*2));
		        SetPlayerSkillLevel(playerid,WEAPONSKILL_MICRO_UZI,PlayerInfo[playerid][GunSkills][WEAPONSKILL_MICRO_UZI]);
		    }
		    else if(weaponid == 29)
		    {
		        PlayerInfo[playerid][GunSkills][WEAPONSKILL_MP5] += (1+(PlayerInfo[playerid][Perks][FastLearner]*2));
		        SetPlayerSkillLevel(playerid,WEAPONSKILL_MP5,PlayerInfo[playerid][GunSkills][WEAPONSKILL_MP5]);
		    }
		    PlayerInfo[playerid][Achievements][SMGKill]++;
		    if(PlayerInfo[playerid][Achievements][SMGKill] == 10)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 10 with SMG, Reward: 500EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 500;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][SMGKill] == 30)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 30 with SMG, Reward: 1000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 1000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][SMGKill] == 80)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 80 with SMG, Reward: 2000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 2000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][SMGKill] == 125)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 125 with SMG, Reward: 3000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 3000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][SMGKill] == 250)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 250 with SMG, Reward: 5000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 5000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
		}
		case 30,31:
		{
		    if(weaponid == 30)
		    {
		        PlayerInfo[playerid][GunSkills][WEAPONSKILL_AK47] += (1+(PlayerInfo[playerid][Perks][FastLearner]*2));
		        SetPlayerSkillLevel(playerid,WEAPONSKILL_AK47,PlayerInfo[playerid][GunSkills][WEAPONSKILL_AK47]);
		    }
		    else if(weaponid == 31)
		    {
		        PlayerInfo[playerid][GunSkills][WEAPONSKILL_M4] += (1+(PlayerInfo[playerid][Perks][FastLearner]*2));
		        SetPlayerSkillLevel(playerid,WEAPONSKILL_M4,PlayerInfo[playerid][GunSkills][WEAPONSKILL_M4]);
		    }
		    PlayerInfo[playerid][Achievements][AssaultKill]++;
		    if(PlayerInfo[playerid][Achievements][AssaultKill] == 5)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 5 with Assault rifle, Reward: 500EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 500;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][AssaultKill] == 25)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 25 with Assault rifle, Reward: 1000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 1000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][AssaultKill] == 75)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 75 with Assault rifle, Reward: 2000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 2000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][AssaultKill] == 150)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 150 with Assault rifle, Reward: 3000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 3000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
	        else if(PlayerInfo[playerid][Achievements][AssaultKill] == 200)
	        {
	            SendClientMessage(playerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Kill 200 with Assault rifle, Reward: 5000EXP & 1UP");
	            PlayerInfo[playerid][EXP] += 5000;
	            PlayerInfo[playerid][UpgradePoint]++;
	        }
		}
		case 34:
		{
		    PlayerInfo[playerid][GunSkills][WEAPONSKILL_SNIPERRIFLE] += (1+(PlayerInfo[playerid][Perks][FastLearner]*2));
		    SetPlayerSkillLevel(playerid,WEAPONSKILL_SNIPERRIFLE,PlayerInfo[playerid][GunSkills][WEAPONSKILL_SNIPERRIFLE]);
		}
	}
	return 1;
}
// ============================================================================================================================
// ========================================================[ Clan System ]=====================================================
// ============================================================================================================================

stock SaveClans()
{
	new query[512];
	foreach(new id : Clans)
	{
		format(query,sizeof(query),"UPDATE `clans` SET `name`='%s',`leader`='%s',`color`='%d',`kills`='%d',`deaths`='%d',`spawnx`='%.2f',`spawny`='%.2f',`spawnz`='%.2f',`spawna`='%.2f',`public`='%d' WHERE `id`='%d'",
        ClanInfo[id][Name],ClanInfo[id][Leader],ClanInfo[id][Color],ClanInfo[id][Kills],ClanInfo[id][Deaths],ClanInfo[id][Spawn][0],ClanInfo[id][Spawn][1],ClanInfo[id][Spawn][2],ClanInfo[id][Spawn][3],ClanInfo[id][IsPublic],id);
        mysql_tquery(Database,query,"","");
	}
	return 1;
}
stock SetClanName(clanid,newname[])
{
    if(Iter_Contains(Clans,clanid))
	{
	    strmid(ClanInfo[clanid][Name],newname,0,strlen(newname),32);
	}
	else return 0;
	return 1;
}
stock SetClanLeader(clanid,newleader[])
{
    if(Iter_Contains(Clans,clanid))
	{
	    strmid(ClanInfo[clanid][Leader],newleader,0,strlen(newleader),MAX_PLAYER_NAME);
	}
	else return 0;
	return 1;
}
stock SetClanColour(clanid,cred,cgreen,cblue)
{
    if(Iter_Contains(Clans,clanid))
	{
	    ClanInfo[clanid][Color] = RGBAToInt(cred,cgreen,cblue,255);
	    foreach(new playerid : ClanMembers[clanid])
	    {
	        SetPlayerColor(playerid,RGBAToInt(cred,cgreen,cblue,255));
	    }
	}
	else return 0;
	return 1;
}
stock SendClanChat(playerid,msg[])
{
	new string[128],playername[MAX_PLAYER_NAME],
		clanid = PlayerInfo[playerid][Clan];
	GetPlayerName(playerid,playername,sizeof(playername));
	format(string,sizeof(string),"[CLAN] %s: %s",playername,msg);
	foreach(new i : ClanMembers[clanid])
	{
	    SendClientMessage(i,COLOR_LIGHTBLUE,string);
	}
	format(string,sizeof(string),"(ID:%d) %s: %s",clanid,msg,msg);
	Log(string,"logs/ClanChat.log");
	return 1;
}
stock SendBonusEXP(playerid,expamount)
{
    new clanid = PlayerInfo[playerid][Clan];
	foreach(new member : ClanMembers[clanid])
	{
		if(member != playerid)
		{
			PlayerInfo[member][EXP] += expamount;
			UpdatePlayerEXP(member);
		}
	}
	return 1;
}


// ============================================================================================================================
// ===================================================[ Clan Zones Functions ]=================================================
// ============================================================================================================================

stock LoadZones()
{
    new Filename[64],Data[512],loaded;
    format(Filename,64,"clans/clanzones.cfg");
    if(!fexist(Filename))
    {
        forex(i,MAX_ZONES)
		{
            ZoneInfo[i][Owner] = NO_TEAM;
            ZoneInfo[i][Permanent] = 0;
            ZoneInfo[i][HoursLeft] = 0;
            ZoneInfo[i][ID] = GangZoneCreate(ZoneInfo[i][MinX], ZoneInfo[i][MinY], ZoneInfo[i][MaxX], ZoneInfo[i][MaxY]);
        }
        SaveZones();
    }
    else
    {
        new File: file = fopen(Filename, io_read);
		if(file)
		{
			new i = 0;
		    while(fread(file,Data,512) > 0)
			{
			    ValidateLine(Data);
			    if(ZoneInfo[i][Owner] != NO_TEAM)
			    {
			        if(Iter_Contains(Clans,ZoneInfo[i][Owner]) == 0)
			        {
			            ZoneInfo[i][Owner] = NO_TEAM;
			            ZoneInfo[i][Permanent] = 0;
			        }
			    }
				unformat(Data,"p<,>ffffddd",ZoneInfo[i][MinX], ZoneInfo[i][MinY], ZoneInfo[i][MaxX], ZoneInfo[i][MaxY],ZoneInfo[i][Owner],ZoneInfo[i][Permanent],ZoneInfo[i][HoursLeft]);
				ZoneInfo[i][ID] = GangZoneCreate(ZoneInfo[i][MinX], ZoneInfo[i][MinY], ZoneInfo[i][MaxX], ZoneInfo[i][MaxY]);
				loaded++;
				i++;
			}
		}
		fclose(file);
    }
	return loaded;
}
stock SaveZones()
{
    new i;
	new coordsstring[512];
	new File: file;
	file = fopen("clans/clanzones.cfg", io_write);
	while(i < MAX_ZONES)
	{
		format(coordsstring, sizeof(coordsstring), "%f,%f,%f,%f,%d,%d,%d",ZoneInfo[i][MinX], ZoneInfo[i][MinY], ZoneInfo[i][MaxX], ZoneInfo[i][MaxY],ZoneInfo[i][Owner],ZoneInfo[i][Permanent],ZoneInfo[i][HoursLeft]);
		fwrite(file, coordsstring);
		fwrite(file, "\r\n");
		i++;
	}
	fclose(file);
	return i;
}
stock HideZones(playerid)
{
    forex(i,MAX_ZONES)
	{
		GangZoneHideForPlayer(playerid,ZoneInfo[i][ID]);
	}
	ZoneShown[playerid] = false;
	return 1;
}
stock ShowZones(playerid)
{
    new clanowner;
    forex(i,MAX_ZONES)
	{
	    clanowner = ZoneInfo[i][Owner];
	    if(clanowner != NO_TEAM)
	    {
	        GangZoneShowForPlayer(playerid, ZoneInfo[i][ID], (ClanInfo[clanowner][Color]-205));
	    }
		else
		{
		    GangZoneShowForPlayer(playerid, ZoneInfo[i][ID], RGBAToInt(255,255,255,50));
		}
	}
	ZoneShown[playerid] = true;
	return 1;
}
stock GetPlayerZone(playerid)
{
	forex(i,MAX_ZONES)
	{
	    if(IsPlayerInZone(playerid,i))
	    {
	        return i;
	    }
	}
	return -1;
}
stock IsPlayerInZone(playerid,zoneid)
{
	new i = zoneid;
	if(IsPlayerInArea(playerid, ZoneInfo[i][MaxX], ZoneInfo[i][MinX], ZoneInfo[i][MaxY], ZoneInfo[i][MinY]))
	{
		return 1;
	}
	return 0;
}
stock IsPlayerInArea(playerid, Float:max_x, Float:min_x, Float:max_y, Float:min_y)
{
	new Float:poX, Float:poY, Float:poZ;
	GetPlayerPos(playerid, poX, poY, poZ);
	if(poX <= max_x && poX >= min_x && poY <= max_y && poY >= min_y) return 1;
	return 0;
}

// ============================================================================================================================
// ===================================================[ Anti Cheat Functions ]=================================================
// ============================================================================================================================

stock ResetPlayerCash(playerid)
{
    PlayerInfo[playerid][Money] = 0;
    ResetPlayerMoney(playerid);
    return 1;
}
stock GivePlayerCash(playerid,cash)
{
	PlayerInfo[playerid][Money] += cash;
	GivePlayerMoney(playerid,cash);
	return 1;
}
stock GetPlayerCash(playerid)
{
	return PlayerInfo[playerid][Money];
}
stock SetPlayerCash(playerid,cash)
{
	PlayerInfo[playerid][Money] = cash;
	SetPlayerMoney(playerid,cash);
	return 1;
}
stock SetPlayerMoney(playerid,amount)
{
	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid,amount);
	return 1;
}
stock GivePlayerGun(playerid,weapondid,ammo)
{
    new slotid = GetWeaponSlotID(weapondid);
    if(slotid == 0 ||slotid == 1 ||slotid == 10 || slotid == 11)
    {
        ammo = -1;
    }
    PlayerGuns[playerid][slotid] = weaponid;
    GivePlayerWeapon(playerid,weaponid,ammo);
    return 0;
}
stock ResetPlayerGuns(playerid)
{
	forex(i,13)
	{
	    PlayerGuns[playerid][i] = 0;
	}
	ResetPlayerWeapons(playerid);
	return 0;
}
stock SetPlayerWeapons(playerid)
{
    ResetPlayerWeapons(playerid);
    forex(i,13)
	{
	    if(PlayerGuns[playerid][i] != 0)
	    {
            GivePlayerWeapon(playerid,PlayerGuns[playerid][i],MaxGunAmmo[PlayerGuns[playerid][i]]);
	    }
	}
	return 0;
}
// ============================================================================================================================
// =================================================[ SA-MP default Callbacks ]================================================
// ============================================================================================================================

main() { } // Important WARNING: DO NOT DELETE

public OnGameModeInit()
{
	new timestamp = GetTickCount();
	print("Loading Gamemode...");
	
	// Connect to database
	mysql_debug(0);
	Database = mysql_connect(MYSQL_HOST,MYSQL_USER,MYSQL_DATABASE,MYSQL_PASSWORD);
	if(Database == 1)
    {
        printf("MYSQL: Successfully connected to database on handle %d!",Database);
    }
    else
	{
		print("MYSQL: Error connecting to database!");
		SendRconCommand("exit");
	}
	
	// Define Server properties
	SetGameModeText(SERVER_GAMEMODE);
	SendRconCommand("hostname "SERVER_NAME"");
	SendRconCommand("weburl "SERVER_WEBSITE"");
	SendRconCommand("mapname "SERVER_MAPNAME"");
	
	// Classes
	AddPlayerClass(299,0.0,0.0,3.0,0.0,0,0,0,0,0,0);
	
	// Vehicles
	new totalveh=0;
	totalveh += LoadVehicles("flint.txt",0);
	totalveh += LoadVehicles("sf_airport.txt",0);
	totalveh += LoadVehicles("sf_gen.txt",0);
	totalveh += LoadVehicles("sf_law.txt",0);
	printf("%d Vehicles loaded!",totalveh);
	totalveh = 0;

	// Objects
	CreateObject(4832,-2067.87,-251.30,48.16,0.00,0.00,0.00);
	CreateObject(18857,-2052.57,-251.67,91.04,0.00,0.00,0.00);

	// Textdraws
	TextDrawCreate(1.000000,1.000000," "); // Default Textdraw
	
	SkinChoose = TextDrawCreate(148.000000,379.000000,"Tekan '~r~~k~~GO_LEFT~~w~' atau '~r~~k~~GO_RIGHT~~w~' untuk mencari skin~n~Tekan '~r~~k~~PED_JUMPING~~w~' jika skin sudah cocok");
	TextDrawUseBox(SkinChoose,1);
	TextDrawBoxColor(SkinChoose,0x00000033);
	TextDrawTextSize(SkinChoose,462.000000,0.000000);
	TextDrawAlignment(SkinChoose,0);
	TextDrawBackgroundColor(SkinChoose,0x000000ff);
	TextDrawFont(SkinChoose,1);
	TextDrawLetterSize(SkinChoose,0.399999,1.300000);
	TextDrawColor(SkinChoose,0xffffffff);
	TextDrawSetOutline(SkinChoose,1);
	TextDrawSetProportional(SkinChoose,1);
	TextDrawSetShadow(SkinChoose,1);
	
	Website = TextDrawCreate(450.000000,400.000000,"website: ''~y~"SERVER_WEBSITE"~w~''");
	TextDrawAlignment(Website,0);
	TextDrawBackgroundColor(Website,0x000000ff);
	TextDrawFont(Website,3);
	TextDrawLetterSize(Website,0.299999,1.000000);
	TextDrawColor(Website,0xffffffff);
	TextDrawSetOutline(Website,1);
	TextDrawSetProportional(Website,1);
	TextDrawSetShadow(Website,1);
	
	EXPBackground = TextDrawCreate(1.000000,431.000000,"I");
	EXPBar = TextDrawCreate(5.000000,434.000000,"I");
	TextDrawUseBox(EXPBackground,1);
	TextDrawBoxColor(EXPBackground,0x00000066);
	TextDrawTextSize(EXPBackground,639.000000,0.000000);
	TextDrawUseBox(EXPBar,1);
	TextDrawBoxColor(EXPBar,0x00ff0066);
	TextDrawTextSize(EXPBar,635.000000,0.000000);
	TextDrawAlignment(EXPBackground,0);
	TextDrawAlignment(EXPBar,0);
	TextDrawBackgroundColor(EXPBackground,0x000000ff);
	TextDrawBackgroundColor(EXPBar,0x000000ff);
	TextDrawFont(EXPBackground,3);
	TextDrawLetterSize(EXPBackground,-0.000000,1.700000);
	TextDrawFont(EXPBar,3);
	TextDrawLetterSize(EXPBar,-0.000000,1.100000);
	TextDrawColor(EXPBackground,0xffffffff);
	TextDrawColor(EXPBar,0xffffffff);
	TextDrawSetOutline(EXPBackground,1);
	TextDrawSetOutline(EXPBar,1);
	TextDrawSetProportional(EXPBackground,1);
	TextDrawSetProportional(EXPBar,1);
	TextDrawSetShadow(EXPBackground,1);
	TextDrawSetShadow(EXPBar,1);
	forex(i,MAX_PLAYERS)
	{
	    EXPText[i] = TextDrawCreate(229.000000,433.000000,"EXP: 5000/5000");
    	TextDrawAlignment(EXPText[i],0);
    	TextDrawBackgroundColor(EXPText[i],0x000000ff);
    	TextDrawFont(EXPText[i],3);
		TextDrawLetterSize(EXPText[i],0.599999,1.300000);
		TextDrawColor(EXPText[i],0xffffffff);
		TextDrawSetOutline(EXPText[i],1);
		TextDrawSetProportional(EXPText[i],1);
		TextDrawSetShadow(EXPText[i],1);
		
		DamageText[i] = TextDrawCreate(150.000000,405.000000,"Damage Created:~n~131");
		TextDrawUseBox(DamageText[i],1);
		TextDrawBoxColor(DamageText[i],0x00000066);
		TextDrawTextSize(DamageText[i],254.000000,0.000000);
		TextDrawAlignment(DamageText[i],0);
		TextDrawBackgroundColor(DamageText[i],0x000000ff);
		TextDrawFont(DamageText[i],3);
		TextDrawLetterSize(DamageText[i],0.299999,1.300000);
		TextDrawColor(DamageText[i],0xffffffff);
		TextDrawSetOutline(DamageText[i],1);
		TextDrawSetProportional(DamageText[i],1);
		TextDrawSetShadow(DamageText[i],1);
	}
	
	// Others
	SafeZone = CreateDynamicCube(-1979.94335938,108.25485992,26.99804306,-1960.76696777,168.99935913,35.43316269,0);
	mysql_tquery(Database,"SELECT * FROM `clans`","Clan_Load","d",-1);
	SetTeamCount(20);
	UsePlayerPedAnims();
	DisableInteriorEnterExits();
	DisableNameTagLOS();
	EnableStuntBonusForAll(false);
	Iter_Init(ClanMembers);
	forex(i,MAX_PLAYERS)
	{
	    ResetPlayerData(i);
	}
	printf("Gamemode Loaded in %d milisecond",(GetTickCount()-timestamp));
	return 0;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid)
{
    if(amount < 1.0 || amount > 200.0 || issuerid == INVALID_PLAYER_ID) return 1;
    if(PlayerInfo[playerid][Clan] != NO_TEAM)
	{
	    if(PlayerInfo[playerid][Clan] == PlayerInfo[issuerid][Clan]) return 1;
	}
    if((IsInSafeZone[issuerid] == false) && (IsInSafeZone[playerid] == false))
    {
        new string[64];
        if(DamageTimer[issuerid] == 0)
        {
			TextDrawShowForPlayer(issuerid,DamageText[issuerid]);
			DamageCreated[issuerid] += amount;
			format(string,sizeof(string),"Damage Created:~n~%d",floatround(DamageCreated[issuerid]));
			TextDrawSetString(DamageText[issuerid],string);
			DamageTimer[issuerid] = 8;
        }
        else
        {
            DamageCreated[issuerid] += amount;
			format(string,sizeof(string),"Damage Created:~n~%d",floatround(DamageCreated[issuerid]));
			TextDrawSetString(DamageText[issuerid],string);
			DamageTimer[issuerid] = 8;
        }
    }
    return 1;
}

task ServerTimer[1000]()
{
	gTimestamp = gettime(gHour,gMinute,gSecond);
	if(gSecond == 0)
	{
	    new string[128];
	    foreach(new playerid : Player)
	    {
	        if(PlayerInfo[playerid][Jailed] > 0)
            {
                if(PlayerInfo[playerid][JailTime] > 0)
                {
                    PlayerInfo[playerid][JailTime]--;
                    format(string,sizeof(string),"~n~~n~~n~~n~~n~~n~~n~~w~Waktu Tersisa: ~y~%d~w~ menit",PlayerInfo[playerid][JailTime]);
                    GameTextForPlayer(playerid,string,59500,5);
                }
                else
                {
                    PlayerInfo[playerid][Jailed] = 0;
                    SEM(playerid,"JAIL: Anda telah bebas dari penjara.");
                    GameTextForPlayer(playerid,"~g~Anda Bebas!~n~~w~Jadilah DMer yang baik",5000,1);
                    SpawnPlayer(playerid);
                }
			}
	    }
	}
	return 1;
}
ptask PlayerTimer[1000](playerid)
{
	if(PlayerLogged[playerid] && PlayerInfo[playerid][Level])
	{
	    PlayerInfo[playerid][Played][2]++;
	    if(PlayerInfo[playerid][Played][2] == 60)
	    {
	        PlayerInfo[playerid][Played][2] = 0;
	        PlayerInfo[playerid][Played][1]++;
	        if(PlayerInfo[playerid][Played][1] == 60)
	        {
	            PlayerInfo[playerid][Played][1] = 0;
	            PlayerInfo[playerid][Played][0]++;
			}
		}
		new string[128];
		if(EnteringSafeZone[playerid] > 0)
		{
		    if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT && IsPlayerInDynamicArea(playerid,SafeZone))
		    {
			    EnteringSafeZone[playerid]--;
				if(EnteringSafeZone[playerid] == 0)
				{
				    EnteringSafeZone[playerid] = -1;
				    GameTextForPlayer(playerid,"Successfully entered~n~Safezone",2000,5);
				    IsInSafeZone[playerid] = true;
				    if(PlayerLabel[playerid] != INVALID_3DTEXT_ID)
				    {
				        Delete3DTextLabel(PlayerLabel[playerid]);
				    }
				    PlayerLabel[playerid] = Create3DTextLabel("[Safezone protected]",COLOR_LIME,0.0,0.0,0.0,20.0,0,1);
					Attach3DTextLabelToPlayer(PlayerLabel[playerid],playerid,0.0,0.0,0.3);
				}
				else
				{
				    format(string,sizeof(string),"Entering Safezone~n~%d",EnteringSafeZone[playerid]);
					GameTextForPlayer(playerid,string,950,5);
				}
			}
			else
			{
			    EnteringSafeZone[playerid] = -1;
			}
		}
	    if(DamageTimer[playerid] > 0)
	    {
            DamageTimer[playerid]--;
            if(DamageTimer[playerid] == 3)
            {
                new damage = floatround(DamageCreated[playerid]);
                DamageCreated[playerid] = 0.0;
                PlayerInfo[playerid][EXP] += (damage/5);
                UpdatePlayerEXP(playerid);
                format(string,128,"Bonus EXP:~n~%d EXP",(damage/5));
				TextDrawSetString(DamageText[playerid],string);
            }
            else if(DamageTimer[playerid] == 0)
            {
           	 	TextDrawHideForPlayer(playerid,DamageText[playerid]);
            }
	    }
	    new Float:pHealth;
	    GetPlayerHealth(playerid,pHealth);
	    if((floatround(pHealth) > 0 && floatround(pHealth) < 50) && PlayerInfo[playerid][Perks][Regeneration] > 0)
	    {
	        new regtimer = (6-PlayerInfo[playerid][Perks][Regeneration]);
	        Regenerating[playerid]++;
	        if(Regenerating[playerid] == regtimer)
	        {
	            SetPlayerHealth(playerid,(pHealth+1));
	            Regenerating[playerid] = 0;
	        }
	    }
	}
	return 1;
}
public OnPlayerEnterDynamicArea(playerid,areaid)
{
	if(areaid == SafeZone)
	{
        EnteringSafeZone[playerid] = 5;
        if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
        {
            SetVehicleToRespawn(GetPlayerVehicleID(playerid));
        }
		GameTextForPlayer(playerid,"Entering Safezone\n5",950,5);
	}
	return 1;
}
public OnPlayerLeaveDynamicArea(playerid,areaid)
{
    if(areaid == SafeZone)
	{
	    IsInSafeZone[playerid] = false;
	    GameTextForPlayer(playerid,"Leaving Safezone",2000,5);
	    if(PlayerLabel[playerid] != INVALID_3DTEXT_ID)
	    {
	        Delete3DTextLabel(PlayerLabel[playerid]);
	        PlayerLabel[playerid] = INVALID_3DTEXT_ID;
	    }
	}
	return 1;
}
stock ShowRegisterDialog(playerid)
{
    ShowPlayerDialog(playerid,DIALOG_REGISTER,DIALOG_STYLE_PASSWORD,"Daftar di "SERVER_NAME"","{FFFFFF}Harap ketik password di kotak bawah ini untuk mendaftar account baru.\n{FFFF00}Catatan: Password harus lebih dari 5 character","Daftar","Keluar");
	return 1;
}
stock ShowLoginDialog(playerid)
{
	new string[256],playername[MAX_PLAYER_NAME];
	GetPlayerName(playerid,playername,sizeof(playername));
	if(LogAttempts[playerid] == 0)
	{
		format(string,sizeof(string),"{FFFFFF}Harap ketik password di kotak bawah ini untuk login ke server\nAccount: %s",playername);
	}
	else
	{
	    if(LogAttempts[playerid] == 5)
		{
		    SEM(playerid,"ERROR: You've been kicked because you entered the wrong password 5 times!");
			return Kick(playerid);
		}
	    else
	    {
	        format(string,sizeof(string),"{FFFFFF}Harap ketik password di kotak bawah ini untuk login ke server\nAccount: %s\nLogin attempt: %d/5",playername,LogAttempts[playerid]);
	    }
	}
	ShowPlayerDialog(playerid,DIALOG_LOGIN,DIALOG_STYLE_PASSWORD,"Login ke "SERVER_NAME"",string,"Login","Keluar");
	return 1;
}

function Player_GetPassword(playerid)
{
	new rows,fields,data[130];
	cache_get_data(rows,fields,Database);
	if(rows == 1)
	{
	    new tempid = cache_get_row_int(0,0,Database);
		SetPVarInt(playerid,"TempID",tempid);
		cache_get_row(0,1,data,Database,sizeof(data)); SetPVarString(playerid,"TempPass",data);
		ShowLoginDialog(playerid);
	}
	else
	{
	    ShowRegisterDialog(playerid);
	}
	return 1;
}
function Player_Register(playerid,password[])
{
	if(mysql_affected_rows(Database) == 1)
	{
	    SetPVarInt(playerid,"TempID",mysql_insert_id(Database));
	    SetPVarString(playerid,"TempPass",password);
	    ShowLoginDialog(playerid);
	}
	else
	{
	    SEM(playerid,"ERROR: Gagal untuk mendaftarkan account anda!");
		Kick(playerid);
	}
	return 1;
}
function Player_Login(playerid)
{
    new rows,fields;
	cache_get_data(rows,fields,Database);
	if(rows == 1)
	{
        PlayerInfo[playerid][ID] = cache_get_row_int(0,0,Database);
		PlayerInfo[playerid][Registered] = cache_get_row_int(0,4,Database);
		PlayerInfo[playerid][LastLogin] = cache_get_row_int(0,5,Database);
		PlayerInfo[playerid][Played][0] = cache_get_row_int(0,6,Database);
		PlayerInfo[playerid][Played][1] = cache_get_row_int(0,7,Database);
		PlayerInfo[playerid][Played][2] = cache_get_row_int(0,8,Database);
		PlayerInfo[playerid][Admin] = cache_get_row_int(0,9,Database);
		PlayerInfo[playerid][Skin] = cache_get_row_int(0,10,Database);
		PlayerInfo[playerid][Clan] = cache_get_row_int(0,11,Database);
		PlayerInfo[playerid][Money] = cache_get_row_int(0,12,Database);
		PlayerInfo[playerid][Bank] = cache_get_row_int(0,13,Database);
		PlayerInfo[playerid][Level] = cache_get_row_int(0,14,Database);
		PlayerInfo[playerid][EXP] = cache_get_row_int(0,15,Database);
		PlayerInfo[playerid][Kills] = cache_get_row_int(0,16,Database);
		PlayerInfo[playerid][Deaths] = cache_get_row_int(0,17,Database);
		PlayerInfo[playerid][UpgradePoint] = cache_get_row_int(0,18,Database);
		PlayerInfo[playerid][Achievements][Killsteak] = cache_get_row_int(0,19,Database);
		PlayerInfo[playerid][Achievements][DriveBy] = cache_get_row_int(0,20,Database);
		PlayerInfo[playerid][Achievements][DriverDriveBy] = cache_get_row_int(0,21,Database);
		PlayerInfo[playerid][Achievements][CarPark] = cache_get_row_int(0,22,Database);
		PlayerInfo[playerid][Achievements][AssaultKill] = cache_get_row_int(0,23,Database);
		PlayerInfo[playerid][Achievements][SMGKill] = cache_get_row_int(0,24,Database);
		PlayerInfo[playerid][Achievements][PistolKill] = cache_get_row_int(0,25,Database);
		PlayerInfo[playerid][Achievements][ShotgunKill] = cache_get_row_int(0,26,Database);
		PlayerInfo[playerid][Achievements][NadeKill] = cache_get_row_int(0,27,Database);
		PlayerInfo[playerid][Achievements][DamageProjected] = cache_get_row_int(0,28,Database);
		PlayerInfo[playerid][Perks][ArmourSpawn] = cache_get_row_int(0,29,Database);
		PlayerInfo[playerid][Perks][Regeneration] = cache_get_row_int(0,30,Database);
		PlayerInfo[playerid][Perks][NadeSpawn] = cache_get_row_int(0,31,Database);
		PlayerInfo[playerid][Perks][ExtraAmmo] = cache_get_row_int(0,32,Database);
		PlayerInfo[playerid][Perks][FastLearner] = cache_get_row_int(0,33,Database);
		forex(i,11)
		{
			PlayerInfo[playerid][GunSkills][i] = cache_get_row_int(0,(34+i),Database);
		}
		forex(i,13)
		{
		    PlayerInfo[playerid][WeaponsPurchased][i] = bool:cache_get_row_int(0,(45+i),Database);
		}
		PlayerInfo[playerid][SpawnPlace] = cache_get_row_int(0,58,Database);
		PlayerInfo[playerid][House] = cache_get_row_int(0,59,Database);
		PlayerInfo[playerid][Jailed] = cache_get_row_int(0,60,Database);
		PlayerInfo[playerid][JailTime] = cache_get_row_int(0,61,Database);
		PlayerInfo[playerid][LastLogin] = gTimestamp;
		PlayerLogged[playerid] = true;
		if(PlayerInfo[playerid][Clan] != NO_TEAM)
		{
		    new clan = PlayerInfo[playerid][Clan];
		    Iter_Add(ClanMembers[clan],playerid);
		}
		GetPlayerIp(playerid,PlayerIP[playerid],20);
		TogglePlayerSpectating(playerid,0);
		TogglePlayerControllable(playerid,1);
		SpawnPlayer(playerid);
	}
	else
	{
	    SEM(playerid,"ERROR: Something went wrong!");
		Kick(playerid);
	}
	return 1;
}
function Player_Save(playerid)
{
    ResetPlayerData(playerid);
	return 1;
}
function Player_CheckName(playerid,newname[])
{
	new rows,fields;
	cache_get_data(rows,fields,Database);
	if(rows == 0)
	{
	    new query[128];
	    format(query,sizeof(query),"UPDATE `users` SET `name`='%s' WHERE `id`='%d'",newname,PlayerInfo[playerid][ID]);
	    mysql_tquery(Database,query,"Player_ChangeName","ds",playerid,newname);
	}
	else SEM(playerid,"ERROR: Name already exists!");
	return 1;
}
function Player_ChangeName(playerid,newname[])
{
	if(mysql_affected_rows(Database) > 0)
	{
	    new string[128],oldname[MAX_PLAYER_NAME];
		GivePlayerCash(playerid,-25000);
		PlayerInfo[playerid][UpgradePoint]--;
		GetPlayerName(playerid,oldname,sizeof(oldname));
		format(string,sizeof(string),"INFO: You've changed your name from '%s' to '%s'",oldname,newname);
		SetPlayerName(playerid,newname);
		SendClientMessage(playerid,COLOR_WHITE,string);
	}
	else SEM(playerid,"ERROR: Something went wrong, try again!");
	return 1;
}
function Clan_Load(clanid)
{
	new rows,fields;
	cache_get_data(rows,fields,Database);
	if(rows > 0)
	{
	    new id = 0,loaded = 0;
	    forex(row,rows)
	    {
	        id = cache_get_row_int(row,0,Database);
	        if(id > MAX_CLAN) continue;
	        cache_get_row(row,1,ClanInfo[id][Name],Database,32);
			cache_get_row(row,2,ClanInfo[id][Leader],Database,MAX_PLAYER_NAME);
			ClanInfo[id][Color] = cache_get_row_int(row,3,Database);
			ClanInfo[id][Kills] = cache_get_row_int(row,4,Database);
			ClanInfo[id][Deaths] = cache_get_row_int(row,5,Database);
			ClanInfo[id][Spawn][0] = cache_get_row_float(row,6,Database);
			ClanInfo[id][Spawn][1] = cache_get_row_float(row,7,Database);
			ClanInfo[id][Spawn][2] = cache_get_row_float(row,8,Database);
			ClanInfo[id][Spawn][3] = cache_get_row_float(row,9,Database);
			ClanInfo[id][IsPublic] = bool:cache_get_row_int(row,10,Database);
			Iter_Add(Clans,id);
			loaded++;
	    }
	    if(clanid == -1) printf("%d Clans loaded!",loaded);
	}
	rows = LoadZones();
	printf("%d Zones loaded!",rows);
	return 1;
}
function Clan_Create(creator,leaderid,clanid)
{
	if(mysql_affected_rows(Database) > 0)
	{
	    new sendername[MAX_PLAYER_NAME],playername[MAX_PLAYER_NAME],string[128];
		GetPlayerName(creator,sendername,sizeof(sendername));
		GetPlayerName(leaderid,playername,sizeof(playername));
		format(string,sizeof(string),"CLAN: You've created clan with id %d for player %s",clanid,playername);
		SendClientMessage(creator,COLOR_YELLOW,string);
		format(string,sizeof(string),"CLAN: Admin %s have created you a clan with id %d",sendername,clanid);
		SendClientMessage(leaderid,COLOR_YELLOW,string);
		PlayerInfo[leaderid][Clan] = clanid;
		Iter_Add(ClanMembers[clanid],leaderid);
		UpdatePlayerInfo(leaderid,"clan",clanid);
		format(string,sizeof(string),"SELECT * FROM `clans` WHERE `id`='%d'",clanid);
		mysql_tquery(Database,string,"Clan_Load","d",clanid);
	}
	else SEM(creator,"ERROR: Failed to create clan, try again!");
	return 1;
}
function Clan_Delete(playerid,clanid)
{
	if(mysql_affected_rows(Database) > 0)
	{
	    new string[128];
	    foreach(new member : ClanMembers[clanid])
	    {
	        PlayerInfo[member][Clan] = NO_TEAM;
	        UpdatePlayerInfo(member,"clan",NO_TEAM);
	        SetPlayerColor(member,RGBAToInt(random(256),random(256),random(256),255));
	    }
        forex(i,MAX_ZONES)
        {
            if(ZoneInfo[i][Permanent] && (ZoneInfo[i][Owner] == clanid))
            {
                ZoneInfo[i][Permanent] = 0;
                ZoneInfo[i][Owner] = NO_TEAM;
            }
        }
        SaveZones();
        foreachplayer(i)
        {
            if(PlayerInfo[i][Clan] != NO_TEAM)
            {
				HideZones(i);
				ShowZones(i);
            }
        }
	    Iter_Clear(ClanMembers[clanid]);
	    Iter_Remove(Clans,clanid);
	    format(string,sizeof(string),"UPDATE `users` SET `clan`='%d' WHERE `clan`='%d'",NO_TEAM,clanid);
	    mysql_tquery(Database,string,"","");
	}
	else SEM(playerid,"ERROR: Failed to delete clan, try again!");
	return 1;
}
function ShowTop5(playerid)
{
	new rows,fields;
	cache_get_data(rows,fields,Database);
	SendClientMessage(playerid,COLOR_YELLOW,"Top 5 DMer:");
	if(rows > 0)
	{
	    new string[64],name[24],kills,deaths;
	    forex(row,rows)
	    {
			cache_get_row(row,0,name,Database,MAX_PLAYER_NAME);
			kills = cache_get_row_int(row,1,Database);
			deaths = cache_get_row_int(row,2,Database);
			format(string,sizeof(string),"#%d: %s with %d kills and %d deaths",(row+1),name,kills,deaths);
			SendClientMessage(playerid,COLOR_WHITE,string);
	    }
	}
	return 1;
}
public OnPlayerConnect(playerid)
{
    TextDrawShowForPlayer(playerid,Promo);
    TextDrawShowForPlayer(playerid,Website);
    SendDeathMessage(INVALID_PLAYER_ID, playerid, 200);
	return 1;
}
public OnPlayerRequestClass(playerid)
{
	if(PlayerLogged[playerid] == false)
	{
	    SetSpawnInfo(playerid,NO_TEAM,299,0.0,0.0,3.0,0.0,0,0,0,0,0,0);
	    if(IsValidName(GetName(playerid)))
	    {
	        SpawnPlayer(playerid);
		}
		else
		{
		    SEM(playerid,"ERROR: Nama tidak valid, hanya karakter yang diperbolehkan: ( a-z,A-Z, '_' , '[' , ']' )");
		    Kick(playerid);
		}
	}
	else
	{
	    SpawnPlayer(playerid);
	}
	return 1;
}
stock RandomSpawnPlayer(playerid)
{
    new rand = random(sizeof(RandomSpawns_SanFierro));
    SetPlayerWantedLevel(playerid,0);
	SetPlayerPos(playerid,RandomSpawns_SanFierro[rand][0],RandomSpawns_SanFierro[rand][1],RandomSpawns_SanFierro[rand][2]);
	SetPlayerFacingAngle(playerid,RandomSpawns_SanFierro[rand][3]);
	return 1;
}
public OnPlayerSpawn(playerid)
{
	if(PlayerLogged[playerid])
	{
	    new clan = PlayerInfo[playerid][Clan];
	    ShowPlayerEXP(playerid);
	    SetPlayerSkin(playerid,PlayerInfo[playerid][Skin]);
		SetPlayerMoney(playerid,PlayerInfo[playerid][Money]);
		SetPlayerScore(playerid,PlayerInfo[playerid][Level]);
		SetPlayerInterior(playerid,0);
		SetPlayerVirtualWorld(playerid,0);
		if(PlayerInfo[playerid][Jailed] > 0)
		{
		    new randspawn = random(sizeof(Jailspawns));
		    SetPlayerPos(playerid,Jailspawns[randspawn][0],Jailspawns[randspawn][1],Jailspawns[randspawn][2]);
		    SetPlayerFacingAngle(playerid,Jailspawns[randspawn][3]);
		    SetCameraBehindPlayer(playerid);
		    SetPlayerHealth(playerid,100.0);
		    SetPlayerColor(playerid,COLOR_WHITE);
		    return 1;
		}
	    else if(SafeZoneKilled[playerid])
	    {
	        SafeZoneKilled[playerid] = false;
	    	SetPlayerPos(playerid,-1969.2181,137.8882,27.6875);
	    	SetPlayerFacingAngle(playerid,90.4003);
	    	SetCameraBehindPlayer(playerid);
	    }
		else
		{
			if(clan != NO_TEAM)
			{
			    if(Iter_Contains(Clans,clan))
			    {
			        SetPlayerTeam(playerid,clan);
				    SetPlayerColor(playerid,ClanInfo[clan][Color]);
				    if(!ZoneShown[playerid]) ShowZones(playerid);
			        if(PlayerInfo[playerid][SpawnPlace] == 1)
			        {
						SetPlayerPos(playerid,ClanInfo[clan][Spawn][0],ClanInfo[clan][Spawn][1],ClanInfo[clan][Spawn][2]);
						SetPlayerFacingAngle(playerid,ClanInfo[clan][Spawn][3]);
					}
					else
					{
					    PlayerInfo[playerid][SpawnPlace] = 0;
					    UpdatePlayerInfo(playerid,"spawn",0);
					    RandomSpawnPlayer(playerid);
					}
				}
				else
				{
				    SetPlayerColor(playerid,RGBAToInt(random(256),random(256),random(256),255));
				    PlayerInfo[playerid][Clan] = NO_TEAM;
				    UpdatePlayerInfo(playerid,"clan",NO_TEAM);
        			SetPlayerTeam(playerid,NO_TEAM);
				    SEM(playerid,"WARNING: Your clan has been deleted!");
				    RandomSpawnPlayer(playerid);
				}
			}
			else
			{
			    SetPlayerColor(playerid,RGBAToInt(random(256),random(256),random(256),255));
				SetPlayerTeam(playerid,NO_TEAM);
			    RandomSpawnPlayer(playerid);
			}
	    	SetCameraBehindPlayer(playerid);
		}
		if(!IsValidSkin(PlayerInfo[playerid][Skin]))
		{
	   	    ChooseSkinForPlayer(playerid);
		}
		else
		{
			SetSpawnWeapons(playerid);
			SetPlayerHealth(playerid,100.0);
			if(PlayerInfo[playerid][Perks][ArmourSpawn] > 0)
			{
			    SetPlayerArmour(playerid,(PlayerInfo[playerid][Perks][ArmourSpawn]*5.0));
			}
			forex(skill,11)
			{
			    SetPlayerSkillLevel(playerid,skill,PlayerInfo[playerid][GunSkills][skill]);
			}
		}
	}
	else
	{
	    new query[128],playername[MAX_PLAYER_NAME];
    	GetPlayerName(playerid,playername,sizeof(playername));
    	strToLower(playername);
    	format(query,sizeof(query),"SELECT `id`,`password` FROM `users` WHERE `name`='%s'",playername);
	    TogglePlayerControllable(playerid,0);
	    TogglePlayerSpectating(playerid,1);
	    mysql_tquery(Database,query,"Player_GetPassword","d",playerid);
	}
	return 1;
}
public OnPlayerDisconnect(playerid,reason)
{
    SendDeathMessage(INVALID_PLAYER_ID, playerid, 201);
	if(PlayerLogged[playerid])
	{
	    if(PlayerInfo[playerid][Clan] != NO_TEAM)
		{
		    new clan = PlayerInfo[playerid][Clan];
		    Iter_Remove(ClanMembers[clan],playerid);
		}
		if(PlayerLabel[playerid] != INVALID_3DTEXT_ID)
	    {
	        Delete3DTextLabel(PlayerLabel[playerid]);
	        PlayerLabel[playerid] = INVALID_3DTEXT_ID;
	    }
	    SavePlayer(playerid);
	}
	else ResetPlayerData(playerid);
	return 1;
}
public OnGameModeExit()
{
	return 1;
}
public OnPlayerDeath(playerid,killerid,reason)
{
	if(PlayerInfo[playerid][Jailed]) return 1;
    SendDeathMessage(killerid,playerid,reason);
	if(IsInSafeZone[playerid] == true)
	{
	    SafeZoneKilled[playerid] = true;
	    if(killerid != INVALID_PLAYER_ID)
	    {
	        SetPlayerHealth(killerid,0.0);
	        PlayerInfo[killerid][Deaths]++;
	        if(PlayerInfo[killerid][Clan] != NO_TEAM)
			{
		    	ClanInfo[PlayerInfo[killerid][Clan]][Deaths]++;
			}
	    }
	}
	else
	{
    	PlayerInfo[playerid][Deaths]++;
    	KillSteak[playerid] = 0;
    	if(PlayerInfo[playerid][Clan] != NO_TEAM)
		{
		    ClanInfo[PlayerInfo[playerid][Clan]][Deaths]++;
		}
    	if(killerid != INVALID_PLAYER_ID)
    	{
    	    LogKill(playerid,killerid,reason);
    	    if(GetPlayerState(killerid) != PLAYER_STATE_DRIVER)
    	    {
    	        new string[144];
				PlayerInfo[killerid][EXP] += 100;
				switch(KillSteak[killerid])
				{
				    case 0:
					{
						GameTextForPlayer(killerid,"Solid Kill~n~+100 EXP",2000,6);
						SetPlayerWantedLevel(killerid,1);
					}
				    case 1:
					{
						GameTextForPlayer(killerid,"Double Kill~n~+120 EXP",2000,6);
						SetPlayerWantedLevel(killerid,2);
				    }
				    case 2:
					{
						GameTextForPlayer(killerid,"Triple Kill~n~+140 EXP",2000,6);
						SetPlayerWantedLevel(killerid,3);
					}
				    case 3:
					{
						GameTextForPlayer(killerid,"Chain Killer~n~+160 EXP",2000,6);
						SetPlayerWantedLevel(killerid,4);
					}
				    case 4:
					{
						GameTextForPlayer(killerid,"RAMPAGE!~n~+180 EXP",2000,6);
						SetPlayerWantedLevel(killerid,5);
					}
				    case 5:
					{
						GameTextForPlayer(killerid,"6th Kill!~n~+200 EXP",2000,6);
						SetPlayerWantedLevel(killerid,6);
						KillingSpree[killerid] = true;
						format(string,sizeof(string),"WARNING: {ffff00}%s {ffffff}is on killing spree, %s",GetName(killerid),KillSpreeMessage[random(sizeof(KillSpreeMessage))]);
						SendClientMessageToAll(COLOR_RED,string);
					}
				    case 6: GameTextForPlayer(killerid,"Hitman!~n~+220 EXP",2000,6);
				    case 7: GameTextForPlayer(killerid,"It is 8!~n~+240 EXP",2000,6);
				    case 8: GameTextForPlayer(killerid,"Then 9!~n~+260 EXP",2000,6);
				    case 9: GameTextForPlayer(killerid,"Professional Killer~n~+280 EXP",2000,6);
				    case 19: GameTextForPlayer(killerid,"You are a Cheater~n~+380 EXP",2000,6);
				    default:
				    {
				        format(string,64,"Kill NR %d~n~+%d EXP",(KillSteak[killerid]+1),(100+(KillSteak[killerid]*20)));
				        GameTextForPlayer(killerid,string,2000,6);
				    }
				}
				ConfirmKill(killerid,reason);
				if(GetPlayerState(killerid) == PLAYER_STATE_PASSENGER)
				{
				    PlayerInfo[killerid][Achievements][DriveBy]++;
				    if(PlayerInfo[killerid][Achievements][DriveBy] == 5)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Drive-by kill 5 peoples, Reward: 500EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 500;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
                    else if(PlayerInfo[killerid][Achievements][DriveBy] == 20)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Drive-by kill 20 peoples, Reward: 1000EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 1000;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
                    else if(PlayerInfo[killerid][Achievements][DriveBy] == 50)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Drive-by kill 50 peoples, Reward: 2000EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 2000;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
                    else if(PlayerInfo[killerid][Achievements][DriveBy] == 100)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Drive-by kill 100 peoples, Reward: 3000EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 3000;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
                    else if(PlayerInfo[killerid][Achievements][DriveBy] == 150)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Drive-by kill 150 peoples, Reward: 5000EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 5000;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
				}
				PlayerInfo[killerid][EXP] += (100+(KillSteak[killerid]*20));
				KillSteak[killerid]++;
				if(KillingSpree[playerid])
				{
				    KillingSpree[playerid] = false;
				    SendClientMessage(killerid,COLOR_WHITE,"BONUS: You've killed a madmen, you gained 250 bonus EXP!");
				    PlayerInfo[killerid][EXP] += 250;
				}
				if(PlayerInfo[killerid][Clan] != NO_TEAM)
				{
					SendBonusEXP(killerid,25);
					ClanInfo[PlayerInfo[killerid][Clan]][Kills]++;
				}
				UpdatePlayerEXP(killerid);
			}
			else
			{
			    if(reason == 49 || reason == 50)
			    {
                    PlayerInfo[killerid][Achievements][CarPark]++;
                    if(PlayerInfo[killerid][Achievements][CarPark] == 5)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Carpark/heliblade 5 peoples, Reward: 500EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 500;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
                    else if(PlayerInfo[killerid][Achievements][CarPark] == 20)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Carpark/heliblade 20 peoples, Reward: 1000EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 1000;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
                    else if(PlayerInfo[killerid][Achievements][CarPark] == 50)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Carpark/heliblade 50 peoples, Reward: 2000EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 2000;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
                    else if(PlayerInfo[killerid][Achievements][CarPark] == 100)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Carpark/heliblade 100 peoples, Reward: 3000EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 3000;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
                    else if(PlayerInfo[killerid][Achievements][CarPark] == 150)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Carpark/heliblade 150 peoples, Reward: 5000EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 5000;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
			    }
			    else
			    {
			        PlayerInfo[killerid][Achievements][DriverDriveBy]++;
			        if(PlayerInfo[killerid][Achievements][DriverDriveBy] == 10)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: n00b DDBer (DDB 10 people), Reward: 500EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 500;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
                    else if(PlayerInfo[killerid][Achievements][DriverDriveBy] == 30)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Rookie DDBer (DDB 30 people), Reward: 1000EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 1000;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
                    else if(PlayerInfo[killerid][Achievements][DriverDriveBy] == 75)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Amateur DDBer (DDB 75 people), Reward: 2000EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 2000;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
                    else if(PlayerInfo[killerid][Achievements][DriverDriveBy] == 150)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: Professional DDBer (DDB 150 people), Reward: 3000EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 3000;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
                    else if(PlayerInfo[killerid][Achievements][DriverDriveBy] == 300)
                    {
                        SendClientMessage(killerid,COLOR_WHITE,"ACHIEVEMENT: Achievement get: King of DDB (DDB 300 people), Reward: 10000EXP & 1UP");
        				PlayerInfo[killerid][EXP] += 10000;
        				PlayerInfo[killerid][UpgradePoint]++;
                    }
			    }
			    GameTextForPlayer(killerid,"Lame Kill~n~+25 EXP",2000,6);
			    PlayerInfo[killerid][EXP] += 25;
				UpdatePlayerEXP(killerid);
			}
    	    PlayerInfo[killerid][Kills]++;
			GivePlayerCash(killerid,1000);
    	}
    	else
    	{
    	    KillingSpree[playerid] = false;
    	}
	}
	return 1;
}
stock ChooseSkinForPlayer(playerid)
{
	TogglePlayerControllable(playerid,0);
    TextDrawShowForPlayer(playerid,SkinChoose);
	IsSelectingSkin[playerid] = true;
	DelayChoose[playerid] = false;
	SelectedSkin[playerid] = 0;
	SetPlayerSkin(playerid,Skins[0]);
	return 1;
}
function OnPlayerCBug(playerid)
{
	SetPlayerArmedWeapon(playerid,0);
	return 1;
}
public OnPlayerStateChange(playerid,newstate,oldstate)
{
	if(newstate == PLAYER_STATE_PASSENGER)
	{
		switch(GetPlayerWeapon(playerid))
		{
		    case 24,27: SetPlayerArmedWeapon(playerid,0);
		}
	}
	else if(newstate == PLAYER_STATE_DRIVER)
	{
	    if((gHour >= 8 && gHour <= 10) || (gHour >= 16 && gHour <= 19))
	    {
	        SetPlayerArmedWeapon(playerid,0);
	    }
	}
	return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}
public OnPlayerUpdate(playerid)
{
    if(IsInSafeZone[playerid])
    {
        if(GetPlayerWeapon(playerid) != 0)
        {
            SetPlayerArmedWeapon(playerid,0);
        }
    }
    if(GetPlayerCash(playerid) != GetPlayerMoney(playerid))
    {
        SetPlayerMoney(playerid,GetPlayerCash(playerid));
    }
	if(IsSelectingSkin[playerid] && (!DelayChoose[playerid]))
    {
        new keys,updo,lefrig;
        GetPlayerKeys(playerid,keys,updo,lefrig);
        if((keys == 0) && (updo == 0) && (lefrig == 0)) { }
        else
        {
            if(lefrig == 128)
            {
                SelectedSkin[playerid]++;
                if(SelectedSkin[playerid] >= 285)
                {
                    SelectedSkin[playerid] = 0;
                }
                SetPlayerSkin(playerid,Skins[SelectedSkin[playerid]]);
                DelayChoose[playerid] = true;
                SetTimerEx("Delay",100,0,"d",playerid);
            }
            else if(lefrig == -128)
            {
       	    	SelectedSkin[playerid]--;
				if(SelectedSkin[playerid] == -1)
				{
           	    	SelectedSkin[playerid] = 284;
				}
				SetPlayerSkin(playerid,Skins[SelectedSkin[playerid]]);
               	DelayChoose[playerid] = true;
                SetTimerEx("Delay",100,0,"d",playerid);
            }
            else if(keys == 32)
            {
                PlayerInfo[playerid][Skin] = GetPlayerSkin(playerid);
                SelectedSkin[playerid] = 0;
                IsSelectingSkin[playerid] = false;
                TogglePlayerControllable(playerid,1);
                TextDrawHideForPlayer(playerid,SkinChoose);
                UpdatePlayerInfo(playerid,"skin",PlayerInfo[playerid][Skin]);
                SpawnPlayer(playerid);
            }
        }
	}
	return 1;
}
forward Delay(playerid);
public Delay(playerid)
{
	if(DelayChoose[playerid])
	{
        DelayChoose[playerid] = false;
	}
	else if(DelayChat[playerid])
	{
	    DelayChat[playerid] = false;
	}
	return 0;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
	    case DIALOG_REGISTER:
	    {
	        if(response)
	        {
	            if(IsNull(inputtext)) return ShowRegisterDialog(playerid);
	            if(strlen(inputtext) < 5) return ShowRegisterDialog(playerid);
	        	new playername[MAX_PLAYER_NAME],password[130],query[256];
	        	GetPlayerName(playerid,playername,sizeof(playername));
	        	strToLower(playername);
	        	WP_Hash(password,129,inputtext);
				format(query,sizeof(query),"INSERT INTO `users`(`name`,`password`,`registered`) VALUES('%s','%s','%d')",playername,password,gTimestamp);
				mysql_tquery(Database,query,"Player_Register","ds",playerid,password);
			}
			else
			{
			    SEM(playerid,"You've been kicked!");
			    Kick(playerid);
			}
	    }
	    case DIALOG_LOGIN:
		{
		    if(response)
	        {
		    	new string[130],password[130];
		    	GetPVarString(playerid,"TempPass",password,sizeof(password));
				WP_Hash(string,129,inputtext);
				if(!strcmp(string,password,true))
				{
				    format(string,sizeof(string),"SELECT * FROM `users` WHERE `id`='%d'",GetPVarInt(playerid,"TempID"));
				    DeletePVar(playerid,"TempPass");
				    DeletePVar(playerid,"TempID");
				    mysql_tquery(Database,string,"Player_Login","d",playerid);
				}
				else
				{
				    LogAttempts[playerid]++;
				    ShowLoginDialog(playerid);
				}
            }
			else
			{
			    SEM(playerid,"You've been kicked!");
			    Kick(playerid);
			}
		}
		case DIALOG_BUYGUN:
		{
		    if(response)
		    {
		        if(PlayerInfo[playerid][WeaponsPurchased][listitem] == false)
		        {
					new price = SelledGun[listitem][Price];
					new weaponid = SelledGun[listitem][Weaponid];
					if(GetPlayerCash(playerid) >= price && (PlayerInfo[playerid][UpgradePoint] > 0))
					{
					    new string[128];
						PlayerInfo[playerid][WeaponsPurchased][listitem] = true;
						format(string,16,"gun%d",(listitem+1));
						UpdatePlayerInfo(playerid,string,1);
						PlayerInfo[playerid][UpgradePoint]--;
						GivePlayerCash(playerid,-price);
						format(string,128,"GUNINFO: Anda telah membeli senjata %s dengan harga $%d",GunNames[weaponid],price);
						SendClientMessage(playerid,COLOR_WHITE,string);
					}
					else SEM(playerid,"ERROR: Anda tidak mempunyai cukup uang atau upgrade point!");
				}
				else SEM(playerid,"ERROR: Anda sudah membeli senjata tersebut!");
		    }
		}
        case DIALOG_CHOOSECLASS:
        {
            if(listitem >= 0 && listitem < 4)
            {
				if(ChoosenClass[playerid] != -1)
				{
            	    ChoosenClass[playerid] = listitem;
            	    SendClientMessage(playerid,COLOR_WHITE,"CLASS: Class anda akan diganti setelah spawn berikutnya!");
				}
				else
				{
				    ChoosenClass[playerid] = listitem;
				    SetSpawnWeapons(playerid);
				}
			}
			else
			{
			    if(CountPlayerOwnedWeapons(playerid) > 0)
			    {
			    	ShowPlayerDialog(playerid,DIALOG_CLASS_OPTION,DIALOG_STYLE_LIST,"Custom Class","Use class\nEdit class","Select","Back");
				}
				else
				{
					SEM(playerid,"ERROR: Anda harus minimal memiliki minimal 1 senjata");
					ShowPlayerDialog(playerid,DIALOG_CHOOSECLASS,DIALOG_STYLE_LIST,"Choose class","Assault (AK47,Mac10,Deagle)\nHeavy Assault (SPAS12,MP5,9MM)\nClose Range (SawnOff,Tec9,9MM)\nScout (Sniper,Shotgun,SD Pistol)\nCustom Class","Pilih","");
				}
			}
        }
        case DIALOG_CLASS_OPTION:
        {
            if(response)
            {
                if(listitem == 0)
                {
                    if(ChoosenClass[playerid] == -1)
					{
					    ChoosenClass[playerid] = 4;
					    SetSpawnWeapons(playerid);
					}
                    else
                    {
                        ChoosenClass[playerid] = 4;
                        SendClientMessage(playerid,COLOR_WHITE,"CLASS: Class anda akan diganti setelah spawn berikutnya!");
                    }
                }
                else
                {
                    new listtext[200],substr[50],soldid;
                    forex(i,4)
                    {
                        soldid = CustomClass[playerid][i];
						if(soldid != -1)
						{
							new weaponid = SelledGun[soldid][Weaponid];
						    format(substr,50,"Weapon %d: {33AA33}%s\n",(i+1),GunNames[weaponid]);
						}
						else
						{
						    format(substr,50,"Weapon %d: {FF0000}None\n",(i+1));
						}
						strcat(listtext,substr,200);
                    }
                    ShowPlayerDialog(playerid,DIALOG_CLASS_EDITOR,DIALOG_STYLE_LIST,"Class Editor",listtext,"Edit","Back");
                }
            }
            else ShowPlayerDialog(playerid,DIALOG_CHOOSECLASS,DIALOG_STYLE_LIST,"Choose class","Assault (AK47,Mac10,Deagle)\nHeavy Assault (SPAS12,MP5,9MM)\nClose Range (SawnOff,Tec9,9MM)\nScout (Sniper,Shotgun,SD Pistol)\nCustom Class","Pilih","");
        }
        case DIALOG_CLASS_EDITOR:
        {
            if(response)
            {
                new listtext[256];
                forex(i,14)
                {
                    if(i < 13)
                    {
                    	if(PlayerInfo[playerid][WeaponsPurchased][i])
                    	{
                    	    new weaponid = SelledGun[i][Weaponid];
							strcat(listtext,GunNames[weaponid],256);
							strcat(listtext,"\n",256);
                    	}
					}
					else
					{
					    strcat(listtext,"None",256);
					}
                }
                SetPVarInt(playerid,"SelectedWeaponSlot",listitem);
                ShowPlayerDialog(playerid,DIALOG_CLASS_WEAPONSELECT,DIALOG_STYLE_LIST,"Edit Weapons",listtext,"Select","");
			}
			else ShowPlayerDialog(playerid,DIALOG_CLASS_OPTION,DIALOG_STYLE_LIST,"Custom Class","Use class\nEdit class","Select","Back");
		}
		case DIALOG_CLASS_WEAPONSELECT:
		{
		    new list=0;
		    forex(i,14)
		    {
		        if(i < 13)
                {
                   	if(PlayerInfo[playerid][WeaponsPurchased][i])
                   	{
                   	    if(list == listitem)
                   	    {
							new selectedweapon = GetPVarInt(playerid,"SelectedWeaponSlot");
							CustomClass[playerid][selectedweapon] = i;
							break;
                   	    }
                   	    list++;
                   	}
				}
				else
				{
				    new selectedweapon = GetPVarInt(playerid,"SelectedWeaponSlot");
				    CustomClass[playerid][selectedweapon] = -1;
				}
		    }
		    new listtext[200],substr[50],soldid;
      		forex(i,4)
            {
                soldid = CustomClass[playerid][i];
				if(soldid != -1)
				{
					new weaponid = SelledGun[soldid][Weaponid];
				    format(substr,50,"Weapon %d: {33AA33}%s\n",(i+1),GunNames[weaponid]);
				}
				else
				{
				    format(substr,50,"Weapon %d: {FF0000}None\n",(i+1));
				}
				strcat(listtext,substr,200);
            }
            ShowPlayerDialog(playerid,DIALOG_CLASS_EDITOR,DIALOG_STYLE_LIST,"Class Editor",listtext,"Edit","Back");
		}
        case DIALOG_UPGRADE_MENU:
        {
            if(!response) { return 1; }
            new level = PlayerInfo[playerid][Level];
            new string[256];
			if(listitem == 0)
			{
			    if(PlayerInfo[playerid][Perks][ArmourSpawn] < level && PlayerInfo[playerid][Perks][ArmourSpawn] < 10)
			    {
			        new perklevel = PlayerInfo[playerid][Perks][ArmourSpawn];
			        format(string,256,"Apakah anda ingin menaikkan level perk ini?\nLevel sekarang:\t%d Armour\nLevel berikutnya:\t%d Armour\nBiaya upgrade:\t2 UP & $%d",
					(perklevel*5),((perklevel+1)*5),((perklevel+1)*10000));
			        ShowPlayerDialog(playerid,DIALOG_UPGRADE_ARMOUR,DIALOG_STYLE_MSGBOX,"Armour Spawn",string,"Level up!","Gagal");
			    }
			    else
			    {
			        SEM(playerid,"ERROR: Anda harus level up character anda untuk membuka perk level berikutnya!");
			    }
			}
			else if(listitem == 1)
			{
			    if(PlayerInfo[playerid][Perks][NadeSpawn] < level && PlayerInfo[playerid][Perks][NadeSpawn] < 10)
			    {
			        new perklevel = PlayerInfo[playerid][Perks][NadeSpawn];
			        format(string,256,"Apakah anda ingin menaikkan level perk ini?\nLevel sekarang:\t%d Grenade(s)\nLevel berikutnya:\t%d Grenade(s)\nBiaya upgrade:\t2 UP & $%d",
					perklevel,(perklevel+1),((perklevel+1)*10000));
			        ShowPlayerDialog(playerid,DIALOG_UPGRADE_GRENADE,DIALOG_STYLE_MSGBOX,"Grenade Spawn",string,"Level up!","Gagal");
			    }
			    else
			    {
			        SEM(playerid,"ERROR: Anda harus level up character anda untuk membuka perk level berikutnya!");
			    }
			}
			else if(listitem == 2)
			{
			    if(PlayerInfo[playerid][Perks][Regeneration] < level && PlayerInfo[playerid][Perks][Regeneration] < 5)
			    {
			        new perklevel = PlayerInfo[playerid][Perks][Regeneration];
			        if(perklevel == 0)
			        {
			        	format(string,256,"Apakah anda ingin menaikkan level perk ini?\nLevel sekarang:\tTidak ada\nLevel berikutnya:\t1HP/%d detik\nBiaya upgrade:\t2 UP & $%d",
						(6-(perklevel+1)),((perklevel+1)*10000));
					}
					else
					{
					    format(string,256,"Apakah anda ingin menaikkan level perk ini?\nLevel sekarang:\t1HP/%d detik\nLevel berikutnya:\t1HP/%d detik\nBiaya upgrade:\t2 UP & $%d",
						(6-perklevel),(6-(perklevel+1)),((perklevel+1)*10000));
					}
			        ShowPlayerDialog(playerid,DIALOG_UPGRADE_REGENERATION,DIALOG_STYLE_MSGBOX,"Regeneration",string,"Level up!","Gagal");
			    }
			    else
			    {
			        SEM(playerid,"ERROR: Anda harus level up character anda untuk membuka perk level berikutnya!");
			    }
			}
			else if(listitem == 3)
			{
			    if(PlayerInfo[playerid][Perks][ExtraAmmo] < level && PlayerInfo[playerid][Perks][ExtraAmmo] < 10)
			    {
			        new perklevel = PlayerInfo[playerid][Perks][ExtraAmmo];
			        format(string,256,"Apakah anda ingin menaikkan level perk ini?\nLevel sekarang:\t+%d persen ammo\nLevel berikutnya:\t+%d persen ammo\nBiaya upgrade:\t2 UP & $%d",
					(perklevel*5),((perklevel+1)*5),((perklevel+1)*10000));
			        ShowPlayerDialog(playerid,DIALOG_UPGRADE_EXTRAAMMO,DIALOG_STYLE_MSGBOX,"Extra Ammo",string,"Level up!","Gagal");
			    }
			    else
			    {
			        SEM(playerid,"ERROR: Anda harus level up character anda untuk membuka perk level berikutnya!");
			    }
			}
			else if(listitem == 4)
			{
       			if(PlayerInfo[playerid][Perks][FastLearner] < level && PlayerInfo[playerid][Perks][FastLearner] < 5)
			    {
			        new perklevel = PlayerInfo[playerid][Perks][FastLearner];
			        format(string,256,"Apakah anda ingin menaikkan level perk ini?\nLevel sekarang:\t%d skill gain\nLevel berikutnya:\t%d skill gain\nBiaya upgrade:\t2 UP & $%d",
					(1+(perklevel*2)),1+((perklevel+1)*2),((perklevel+1)*10000));
			        ShowPlayerDialog(playerid,DIALOG_UPGRADE_FASTLEARNER,DIALOG_STYLE_MSGBOX,"Fast Learner",string,"Level up!","Gagal");
			    }
			    else
			    {
			        SEM(playerid,"ERROR: Anda harus level up character anda untuk membuka perk level berikutnya!");
			    }
			}
			return 1;
        }
        case DIALOG_UPGRADE_ARMOUR:
        {
            if(response)
            {
                new price = ((PlayerInfo[playerid][Perks][ArmourSpawn]+1)*10000);
                if(GetPlayerCash(playerid) < price) return SEM(playerid,"ERROR: Anda tidak mempunyai cukup uang!");
                GivePlayerCash(playerid,-price);
                PlayerInfo[playerid][Perks][ArmourSpawn]++;
                PlayerInfo[playerid][UpgradePoint] -= 2;
                SendClientMessage(playerid,COLOR_WHITE,"PERKINFO: Anda telah menaikkan level perk Armour Spawn!");
            }
        }
		case DIALOG_UPGRADE_GRENADE:
		{
		    if(response)
            {
                new price = ((PlayerInfo[playerid][Perks][NadeSpawn]+1)*10000);
                if(GetPlayerCash(playerid) < price) return SEM(playerid,"ERROR: Anda tidak mempunyai cukup uang!");
                GivePlayerCash(playerid,-price);
                PlayerInfo[playerid][Perks][NadeSpawn]++;
                PlayerInfo[playerid][UpgradePoint] -= 2;
                SendClientMessage(playerid,COLOR_WHITE,"PERKINFO: Anda telah menaikkan level perk Grenade Spawn!");
            }
		}
		case DIALOG_UPGRADE_REGENERATION:
		{
		    if(response)
            {
                new price = ((PlayerInfo[playerid][Perks][Regeneration]+1)*10000);
                if(GetPlayerCash(playerid) < price) return SEM(playerid,"ERROR: Anda tidak mempunyai cukup uang!");
                GivePlayerCash(playerid,-price);
                PlayerInfo[playerid][Perks][Regeneration]++;
                PlayerInfo[playerid][UpgradePoint] -= 2;
                SendClientMessage(playerid,COLOR_WHITE,"PERKINFO: Anda telah menaikkan level perk Regeneration!");
            }
		}
		case DIALOG_UPGRADE_EXTRAAMMO:
		{
		    if(response)
            {
                new price = ((PlayerInfo[playerid][Perks][ExtraAmmo]+1)*10000);
                if(GetPlayerCash(playerid) < price) return SEM(playerid,"ERROR: Anda tidak mempunyai cukup uang!");
                GivePlayerCash(playerid,-price);
                PlayerInfo[playerid][Perks][ExtraAmmo]++;
                PlayerInfo[playerid][UpgradePoint] -= 2;
                SendClientMessage(playerid,COLOR_WHITE,"PERKINFO: Anda telah menaikkan level perk Extra Ammo!");
            }
		}
		case DIALOG_UPGRADE_FASTLEARNER:
		{
		    if(response)
            {
                new price = ((PlayerInfo[playerid][Perks][FastLearner]+1)*10000);
                if(GetPlayerCash(playerid) < price) return SEM(playerid,"ERROR: Anda tidak mempunyai cukup uang!");
                GivePlayerCash(playerid,-price);
                PlayerInfo[playerid][Perks][FastLearner]++;
                PlayerInfo[playerid][UpgradePoint] -= 2;
                SendClientMessage(playerid,COLOR_WHITE,"PERKINFO: Anda telah menaikkan level perk Fast Learner!");
            }
		}
		case DIALOG_CHOOSE_SPAWN:
		{
		    if(response)
		    {
				if(listitem == 0)
				{
				    PlayerInfo[playerid][SpawnPlace] = 0;
				    UpdatePlayerInfo(playerid,"spawn",0);
				    SendClientMessage(playerid,COLOR_WHITE,"SPAWNINFO: Anda akan spawn random!");
				}
				else if(listitem == 1)
				{
				    new clan = PlayerInfo[playerid][Clan];
					if(clan != NO_TEAM)
					{
					    if(floatround(ClanInfo[clan][Spawn][0]) != 0)
					    {
					        PlayerInfo[playerid][SpawnPlace] = 1;
					        UpdatePlayerInfo(playerid,"spawn",1);
					        SendClientMessage(playerid,COLOR_WHITE,"SPAWNINFO: Anda akan spawn di tempat spawn clan!");
					    }
					    else SEM(playerid,"ERROR: Clan anda belum menetapkan tepat spawn!");
					}
					else SEM(playerid,"ERROR: Anda harus di dalam clan!");
				}
				else if(listitem == 2)
				{
				    SEM(playerid,"WARNING: NYI");
				}
		    }
		}
		case DIALOG_JOIN_PUBLIC_CLAN:
		{
			if(response)
			{
			    new list = 0;
			    foreach(new clan : Clans)
			    {
			        if(ClanInfo[clan][IsPublic])
			        {
			            if(list == listitem)
			            {
			                new string[128];
						    ClanInvite[playerid] = NO_TEAM;
							PlayerInfo[playerid][Clan] = clan;
							UpdatePlayerInfo(playerid,"clan",clan);
							Iter_Add(ClanMembers[clan],playerid);
							SetPlayerTeam(playerid,clan);
							SetPlayerColor(playerid,ClanInfo[clan][Color]);
							format(string,128,"CLAN: Anda telah bergabung dengan clan %s",ClanInfo[clan][Name]);
							SendClientMessage(playerid,COLOR_WHITE,string);
			                if(!ZoneShown[playerid])
							{
							    ShowZones(playerid);
							}
			                break;
			            }
			            list++;
			        }
			    }
			}
		}
		default: return 1;
	}
	return 1;
}
public OnPlayerText(playerid, text[])
{
	new string[128];
	if(text[0] == '!')
	{
	    if(PlayerInfo[playerid][Clan] != NO_TEAM)
	    {
			strmid(string,text,1,strlen(text),128);
	        SendClanChat(playerid,string);
	        return 0;
	    }
	}
 	if(DelayChat[playerid])
  	{
        SEM(playerid,"ANTI-SPAM: harap tunggu beberapa saat!");
        return 0;
    }
	DelayChat[playerid] = true;
	SetTimerEx("Delay",1000,0,"d",playerid);
	format(string,128,"%s: {FFFFFF}%s",GetName(playerid),text);
	SendClientMessageToAll(GetPlayerColor(playerid),string);
	format(string,128,"%s: %s",GetName(playerid),text);
	Log(string,"logs/ChatLog.log");
	return 0;
}

// ============================================================================================================================
// ===================================================[ Commands Using YCMD ]==================================================
// ============================================================================================================================

public OnPlayerCommandReceived(playerid, cmdtext[], e_COMMAND_ERRORS:success)
{
	if(!PlayerLogged[playerid])
	{
	    SEM(playerid,"ERROR: Anda harus login untuk menggunakan command!");
		return 0;
	}
	if(success != COMMAND_OK)
	{
	    SEM(playerid,"ERROR: Unknown command, see command '/help'");
	}
	return 1;
}
timer GMX[5000](step)
{
	if(step == 2)
	{
    	SaveClans();
    	foreach(new i : Player)
    	{
    	    if(PlayerLogged[i])
    	    {
    	        TogglePlayerControllable(i,0);
    	    	SavePlayer(i);
			}
    	}
    	defer GMX(1);
	}
	else if(step == 1)
	{
	    mysql_close(Database);
		GameModeExit();
	}
	return 1;
}

// Admin Commands
YCMD:gmx(playerid,params[],help)
{
	if(PlayerInfo[playerid][Admin] >= 6)
	{
	    SendClientMessageToAll(COLOR_YELLOW,"SERVER: Server restarting in 10 seconds!");
	    SendClientMessageToAll(COLOR_RED,"WARNING: {ffff00}It is recommended not to logout!");
	    forex(i,MAX_PLAYERS)
    	{
    	    if((IsPlayerConnected(i)) && (PlayerLogged[i] == false))
    	    {
    	    	Kick(i);
			}
    	}
	    defer GMX(2);
	}
	return 1;
}
YCMD:setadmin(playerid,params[],help)
{
	if(PlayerInfo[playerid][Admin] >= 6 || IsPlayerAdmin(playerid))
	{
	    new giveplayerid,level,string[128];
	    if(sscanf(params,"ud",giveplayerid,level)) { return SEM(playerid,"KEGUNAAN: /setadmin [player] [level 0-6]"); }
	    if(level >= 0 && level < 7)
	    {
	        if(IsPlayerConnected(playerid))
	        {
	            format(string,128,"Anda telah set player %s menjadi admin level %d",GetName(giveplayerid),level);
	            SendClientMessage(playerid,COLOR_WHITE,string);
	            format(string,128,"Anda telah diset untuk menjadi admin level %d oleh admin %s",level,GetName(playerid));
	            SendClientMessage(giveplayerid,COLOR_WHITE,string);
				PlayerInfo[giveplayerid][Admin] = level;
				UpdatePlayerInfo(giveplayerid,"admin",level);
			}
			else
			{
			    SEM(playerid,"ERROR: Player tersebut tidak terkoneksi");
			}
	    }
	    else
	    {
            SEM(playerid,"KEGUNAAN: /setadmin [player] [level 1-6]");
		}
	}
	return 1;
}
YCMD:a(playerid,params[],help)
{
	if(PlayerInfo[playerid][Admin] > 0)
	{
	    if(IsNull(params)) { return SEM(playerid,"KEGUNAAN: /a [admin chat]"); }
		new string[128];
	    format(string,128,"Admin[%d] %s: %s",PlayerInfo[playerid][Admin],GetName(playerid),params);
	    SendAdminMessage(string,COLOR_LIME);
	}
	return 1;
}
YCMD:ban(playerid,params[],help)
{
	if(PlayerInfo[playerid][Admin] > 0)
	{
		new giveplayerid,reason[128],string[128];
		if(sscanf(params,"us[128]",giveplayerid,reason)) { return SEM(playerid,"KEGUNAAN: /ban [player] [alasan]"); }
		if(PlayerInfo[playerid][Admin] > PlayerInfo[giveplayerid][Admin])
		{
		    if(IsPlayerConnected(giveplayerid))
		    {
				format(string,128,"Admin Command: %s telah dibanned oleh Admin %s",GetName(giveplayerid),GetName(playerid));
				SendClientMessageToAll(COLOR_LIGHTRED,string);
				format(string,128,"Alasan: %s",reason);
				SendClientMessageToAll(COLOR_LIGHTRED,string);
				SavePlayer(giveplayerid);
				PlayerLogged[giveplayerid] = false;
				Ban(giveplayerid);
			}
			else
			{
			    SEM(playerid,"ERROR: Player tersebut tidak terkoneksi");
			}
		}
	}
	return 1;
}
YCMD:kick(playerid,params[],help)
{
	if(PlayerInfo[playerid][Admin] > 0)
	{
		new giveplayerid,reason[128],string[128];
		if(sscanf(params,"us[128]",giveplayerid,reason)) { return SEM(playerid,"KEGUNAAN: /kick [player] [alasan]"); }
		if(PlayerInfo[playerid][Admin] > PlayerInfo[giveplayerid][Admin])
		{
		    if(IsPlayerConnected(giveplayerid))
		    {
				format(string,128,"Admin Command: %s telah dikick oleh Admin %s",GetName(giveplayerid),GetName(playerid));
				SendClientMessageToAll(COLOR_LIGHTRED,string);
				format(string,128,"Alasan: %s",reason);
				SendClientMessageToAll(COLOR_LIGHTRED,string);
				SavePlayer(giveplayerid);
				PlayerLogged[giveplayerid] = false;
				Kick(giveplayerid);
			}
			else
			{
			    SEM(playerid,"ERROR: Player tersebut tidak terkoneksi");
			}
		}
	}
	return 1;
}

// END
YCMD:help(playerid,params[],help)
{
	if(!IsNull(params))
	{
	    new cmd[32];
	    strmid(cmd,params,0,strlen(params),sizeof(cmd));
	    if(Command_GetID(cmd) != -1)
	    {
	        Command_ReProcess(playerid,cmd,1);
	    }
	    else SEM(playerid,"ERROR: Invalid command!");
	    return 1;
	}
	if(help)
	{
	    SEM(playerid,"KEGUNAAN: Menampilkan command yang tersedia");
	    SEM(playerid,"SYNTAX: /help [command]");
	    SEM(playerid,"CONTOH: /help stats");
	    return 1;
	}
	SEM(playerid,"GENERAL COMMANDS: /stats /changeskin /givecash /changeclass /pm /rules /credits");
	SEM(playerid,"GENERAL COMMANDS: /perks /upgrade /buygun /skills /changename");
	SEM(playerid,"CLAN COMMANDS: /clan /c /switchspawn");
	SEM(playerid,"HOUSE COMMANDS: /house /switchspawn");
	if(PlayerInfo[playerid][Admin] >= 1)
    {
        SEM(playerid,"ADMIN LEVEL 1: /ah /a /goto /gethere /ban /kick /ip");
    }
    if(PlayerInfo[playerid][Admin] >= 2)
    {
        SEM(playerid,"ADMIN LEVEL 2: /unbanip");
    }
    if(PlayerInfo[playerid][Admin] == 6)
    {
        SEM(playerid,"ADMIN LEVEL 6: /setadmin /setcash");
    }
	return 1;
}
YCMD:stats(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Menampilkan status character anda!");
	    return 1;
	}
	new string[128];
	format(string,sizeof(string),"Account: [%s] Tipe Account: [Regular] Terdaftar sejak: [%s]",GetName(playerid),ConvertTimestamp(PlayerInfo[playerid][Registered]));
	SendClientMessage(playerid,COLOR_WHITE,string);
	new level,exp,expneeded,kills,deaths,Float:ratio,clan[32];
	level = PlayerInfo[playerid][Level];
	exp = PlayerInfo[playerid][EXP];
	expneeded = ((1000*level)-exp);
	kills = PlayerInfo[playerid][Kills];
	deaths = PlayerInfo[playerid][Deaths];
	if(kills == 0 || deaths == 0)
	{
	    ratio = 0;
	}
	else
	{
	    new Float:ks,Float:ds;
	    ks = kills;
	    ds = deaths;
		ratio = ((ks/ds)*100);
	}
	if(PlayerInfo[playerid][Clan] == NO_TEAM)
	{
	    clan = "None";
	}
	else
	{
	    new clanid = PlayerInfo[playerid][Clan];
		strmid(clan,ClanInfo[clanid][Name],0,ClanInfo[clanid][Name],sizeof(clan));
	}
	format(string,sizeof(string),"Level: [%d] EXP: [%d] EXP Needed: [%d] Kills: [%d] Deaths: [%d] Ratio: [%.3f%%]",level,exp,expneeded,kills,deaths,ratio);
	SendClientMessage(playerid,COLOR_WHITE,string);
	format(string,sizeof(string),"Lama Main: [%d jam %d menit %d detik] Upgrade Point: [%d point(s)] Clan: [%s]",PlayerInfo[playerid][Played][0],PlayerInfo[playerid][Played][1],PlayerInfo[playerid][Played][2],PlayerInfo[playerid][UpgradePoint],clan);
	SendClientMessage(playerid,COLOR_WHITE,string);
	format(string,sizeof(string),"House: [None]");
	SendClientMessage(playerid,COLOR_WHITE,string);
	return 1;
}
YCMD:switchspawn(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Mengubah tempat tempat spawn");
	    return 1;
	}
	ShowPlayerDialog(playerid,DIALOG_CHOOSE_SPAWN,DIALOG_STYLE_LIST,"Choose Spawn:","Random\nClan spawn","Select","Cancel");
	return 1;
}
YCMD:top5(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Menampilkan 5 orang yang memiliki selisih kill dan death tertinggi");
	    return 1;
	}
	mysql_tquery(Database,"SELECT `name`,`kills`,`deaths` FROM `users` ORDER BY `kills`-`deaths` DESC LIMIT 5","ShowTop5","d",playerid);
	return 1;
}
YCMD:clan(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Mengatur settingan clan");
	    return 1;
	}
	new item[10],subparam[96],string[128];
	if(sscanf(params,"s[10]S()[96]",item,subparam))
	{
		return SEM(playerid,"KEGUNAAN: /clan [create/delete/invite/colour/name/leader/accept/quit/list/kick/givezone/spawn/setpublic/join]");
	}
	else
	{
		if(!strcmp(item,"create",true))
		{
		    if(PlayerInfo[playerid][Admin] < 3) return SEM(playerid,"ERROR: Anda bukan admin!");
		    new giveplayerid,names[32];
		    if(sscanf(subparam,"us[32]",giveplayerid,names))
		    {
		        return SEM(playerid,"KEGUNAAN: /clan create [leaderid] [name]");
		    }
		    if(giveplayerid == INVALID_PLAYER_ID) return SEM(playerid,"ERROR: Invalid playerid!");
		    new clanid = Iter_Free(Clans);
		    if(clanid == -1) return SEM(playerid,"ERROR: There are no clan slot left!");
	        new playername[MAX_PLAYER_NAME];
	        GetPlayerName(giveplayerid,playername,sizeof(playername));
        	format(string,sizeof(string),"INSERT INTO `clans`(`id`,`name`,`leader`) VALUES('%d','%s','%s')",clanid,names,playername);
        	mysql_tquery(Database,string,"Clan_Create","ddd",playerid,giveplayerid,clanid);
			return 1;
		}
		else if(!strcmp(item,"delete",true))
		{
		    if(PlayerInfo[playerid][Admin] < 3) return SEM(playerid,"ERROR: Anda bukan admin!");
			if(IsNull(subparam)) return SEM(playerid,"KEGUNAAN: /clan delete [clanid]");
			new clan = strval(subparam);
			if(!Iter_Contains(Clans,clan)) return SEM(playerid,"ERROR: Invalid clanid!");
			format(string,sizeof(string),"DELETE FROM `clans` WHERE `id`='%d'",clan);
			mysql_tquery(Database,string,"Clan_Delete","dd",playerid,clan);
		    return 1;
		}
		else if(!strcmp(item,"givezone",true))
		{
		    if(PlayerInfo[playerid][Admin] < 3)
		    {
		        SEM(playerid,"ERROR: Anda bukan admin!");
		        return 1;
		    }
			if(!strcmp(subparam,"none"))
			{
			    return SEM(playerid,"KEGUNAAN: /clan givezone [clanid]");
			}
			new clan = strval(subparam);
			if(clan < 0 || clan > 19)
		    {
				SEM(playerid,"ERROR: Clanid cannot go under 0 and over 19!");
		    }
		    if(Iter_Contains(Clans,clan))
		    {
		        new zoneid = GetPlayerZone(playerid);
		        if(zoneid == -1)
		        {
					return SEM(playerid,"ERROR: Anda bukan di dalam turf yang valid!");
		        }
		        forex(i,MAX_ZONES)
		        {
		            if(ZoneInfo[i][Permanent] && (ZoneInfo[i][Owner] == clan))
		            {
		                ZoneInfo[i][Permanent] = 0;
		                ZoneInfo[i][Owner] = NO_TEAM;
		            }
		        }
		        ZoneInfo[zoneid][Permanent] = 1;
		        ZoneInfo[zoneid][Owner] = clan;
		        SaveZones();
		        foreachplayer(i)
		        {
		            if(PlayerInfo[i][Clan] != NO_TEAM)
		            {
						HideZones(i);
						ShowZones(i);
		            }
		        }
		    }
		    else
		    {
		        SEM(playerid,"ERROR: no clan present in the slot");
		    }
		    return 1;
		}
		else if(!strcmp(item,"invite",true))
		{
		    new clan = PlayerInfo[playerid][Clan];
		    if(clan != NO_TEAM)
		    {
		        if(!strcmp(ClanInfo[clan][Leader],GetName(playerid)))
		        {
		            new giveplayerid;
     				if(sscanf(subparam,"u",giveplayerid)) return SEM(playerid,"KEGUNAAN: /clan invite [playerid]");
					if(giveplayerid != INVALID_PLAYER_ID)
					{
					    if(ClanInvite[giveplayerid] == NO_TEAM && PlayerInfo[giveplayerid][Clan] == NO_TEAM)
					    {
					        format(string,128,"CLAN: Anda telah mengundang player %s ke dalam clan!",GetName(giveplayerid));
					        SendClientMessage(playerid,COLOR_WHITE,string);
					        format(string,128,"CLAN: Player %s telah mengundang anda untuk masuk clan ( /clan accept ) untuk menerima undangan!",GetName(playerid));
					        SendClientMessage(giveplayerid,COLOR_WHITE,string);
					        ClanInvite[giveplayerid] = clan;
					    }
					    else return SEM(playerid,"ERROR: Player tersebut sudah memiliki undangan atau sudah punya clan!");
					}
					else return SEM(playerid,"ERROR: Player tersebut tidak online!");
		        }
		        else return SEM(playerid,"ERROR: Anda bukan ketua di suatu Clan!");
		    }
		    else return SEM(playerid,"ERROR: Anda bukan anggota Clan!");
		}
		else if(!strcmp(item,"colour",true))
		{
		    new clan = PlayerInfo[playerid][Clan];
		    if(clan != NO_TEAM)
		    {
		        if(!strcmp(ClanInfo[clan][Leader],GetName(playerid)))
		        {
		            if(GetPlayerCash(playerid) < 10000)
		            {
		                return SEM(playerid,"ERROR: Anda perlu $10000 untuk mengganti warna clan!");
		            }
		            new red,green,blue;
					if(sscanf(subparam,"ddd",red,green,blue))
					{
					    return SEM(playerid,"KEGUNAAN: /clan colour [red] [green] [blue]");
					}
					if((red >= 0 && red <= 255) && (green >= 0 && green <= 255) && (blue >= 0 && blue <= 255))
					{
					    SetClanColour(clan,red,green,blue);
						GivePlayerCash(playerid,-10000);
					    SendClientMessage(playerid,COLOR_WHITE,"CLAN: Anda telah mengganti warna clan!");
					    foreachplayer(i)
		        		{
		         		   	if(PlayerInfo[i][Clan] != NO_TEAM)
    			    		{
								HideZones(i);
								ShowZones(i);
		            		}
		        		}
					}
		        }
		        else
		        {
					return SEM(playerid,"ERROR: Anda bukan ketua di suatu Clan!");
		        }
		    }
		    else
      		{
				return SEM(playerid,"ERROR: Anda bukan anggota Clan!");
	        }
		}
		else if(!strcmp(item,"name",true))
		{
		    new clan = PlayerInfo[playerid][Clan];
		    if(clan != NO_TEAM)
		    {
		        if(!strcmp(ClanInfo[clan][Leader],GetName(playerid)))
		        {
		            if(GetPlayerCash(playerid) < 5000)
		            {
		                return SEM(playerid,"ERROR: Anda perlu $5000 untuk mengganti nama clan!");
		            }
                    if(!strcmp(subparam,"none",false))
					{
					    return SEM(playerid,"KEGUNAAN: /clan name [newname]");
					}
					GivePlayerCash(playerid,-5000);
					format(string,128,"CLAN: Nama clan telah diganti menjadi '%s' ",subparam);
					SendClientMessage(playerid,COLOR_WHITE,string);
					SetClanName(clan,subparam);
		        }
		        else return SEM(playerid,"ERROR: Anda bukan ketua di suatu Clan!");
		    }
		    else return SEM(playerid,"ERROR: Anda bukan anggota Clan!");
		}
		else if(!strcmp(item,"leader",true))
		{
		    new clan = PlayerInfo[playerid][Clan];
		    if(clan != NO_TEAM)
		    {
		        if(!strcmp(ClanInfo[clan][Leader],GetName(playerid)) || PlayerInfo[playerid][Admin] == 6)
		        {
		            new giveplayerid;
		            if(sscanf(subparam,"u",giveplayerid))
					{
					    return SEM(playerid,"KEGUNAAN: /clan leader [new leaderid]");
					}
					if(giveplayerid != INVALID_PLAYER_ID)
					{
					    if(clan != PlayerInfo[giveplayerid][Clan]) return SEM(playerid,"ERROR: That player is not in the same clan as you!");
						format(string,128,"CLAN: Ketua clan telah diberikan kepada player %s",GetName(giveplayerid));
						SendClientMessage(playerid,COLOR_WHITE,string);
						SetClanLeader(clan,GetName(giveplayerid));
					}
		        }
		        else return SEM(playerid,"ERROR: Anda bukan ketua di suatu Clan!");
		    }
		    else return SEM(playerid,"ERROR: Anda bukan anggota Clan!");
		}
		else if(!strcmp(item,"accept",true))
		{
			if(ClanInvite[playerid] != NO_TEAM)
			{
			    new clan = ClanInvite[playerid];
			    ClanInvite[playerid] = NO_TEAM;
				PlayerInfo[playerid][Clan] = clan;
				UpdatePlayerInfo(playerid,"clan",clan);
				Iter_Add(ClanMembers[clan],playerid);
				SetPlayerTeam(playerid,clan);
				SetPlayerColor(playerid,ClanInfo[clan][Color]);
				format(string,128,"CLAN: Anda telah bergabung dengan clan %s",ClanInfo[clan][Name]);
				SendClientMessage(playerid,COLOR_WHITE,string);
                if(!ZoneShown[playerid])
				{
				    ShowZones(playerid);
				}
			}
			else return SEM(playerid,"ERROR: Anda tidak mempunyai undangan untuk masuk Clan!");
		}
		else if(!strcmp(item,"kick",true))
		{
		    new clan = PlayerInfo[playerid][Clan];
		    if(clan != NO_TEAM)
		    {
		        if(!strcmp(ClanInfo[clan][Leader],GetName(playerid)))
		        {
		            new giveplayerid;
		            if(sscanf(subparam,"u",giveplayerid))
					{
					    return SEM(playerid,"KEGUNAAN: /clan kick [playerid]");
					}
					if(giveplayerid != INVALID_PLAYER_ID)
					{
						if(PlayerInfo[playerid][Clan] == PlayerInfo[giveplayerid][Clan])
						{
						    PlayerInfo[giveplayerid][Clan] = NO_TEAM;
						    UpdatePlayerInfo(giveplayerid,"clan",NO_TEAM);
						    Iter_Remove(ClanMembers[clan],giveplayerid);
		        			SetPlayerTeam(giveplayerid,NO_TEAM);
		        			new red,green,blue;
		        			red = random(255);
		        			green = random(255);
		        			blue = random(255);
		        			SetPlayerColor(giveplayerid,RGBAToInt(red,green,blue,255));
							SendClientMessage(giveplayerid,COLOR_WHITE,"CLAN: Anda telah dikeluarkan dari clan!");
							if(ZoneShown[giveplayerid])
							{
							    HideZones(giveplayerid);
							}
						}
						else return SEM(playerid,"ERROR: player yang dipilih tidak ada di clan anda!");
					}
		        }
		        else return SEM(playerid,"ERROR: Anda bukan ketua di suatu Clan!");
		    }
		    else return SEM(playerid,"ERROR: Anda bukan anggota Clan!");
		}
		else if(!strcmp(item,"quit",true))
		{
		    if(PlayerInfo[playerid][Clan] != NO_TEAM)
		    {
		        new clan = PlayerInfo[playerid][Clan];
		        PlayerInfo[playerid][Clan] = NO_TEAM;
		        UpdatePlayerInfo(playerid,"clan",NO_TEAM);
		        Iter_Remove(ClanMembers[clan],playerid);
		        SetPlayerTeam(playerid,NO_TEAM);
		        SetPlayerColor(playerid,RGBAToInt(random(256),random(256),random(256),255));
				SendClientMessage(playerid,COLOR_WHITE,"CLAN: Anda telah keluar dari clan!");
				if(ZoneShown[playerid])
				{
				    HideZones(playerid);
				}
		    }
		    else return SEM(playerid,"ERROR: Anda bukan anggota clan!");
		}
		else if(!strcmp(item,"list",true))
		{
		    SendClientMessage(playerid,COLOR_WHITE,"___________[Clan Official List]___________");
		    foreach(new i : Clans)
		    {
		        if(ClanInfo[i][IsPublic])
		        {
		            format(string,sizeof(string),"{FF0000}Public Clan %d: {FFFFFF}Name: [%s] Kills: [%d] Deaths: [%d]",i,ClanInfo[i][Name],ClanInfo[i][Kills],ClanInfo[i][Deaths]);
		        }
		        else
		        {
	            	format(string,sizeof(string),"{FF0000}Private Clan %d: {FFFFFF}Name: [%s] Leader: [%s] Kills: [%d] Deaths: [%d]",i,ClanInfo[i][Name],ClanInfo[i][Leader],ClanInfo[i][Kills],ClanInfo[i][Deaths]);
				}
				SendClientMessage(playerid,COLOR_WHITE,string);
		    }
		}
		else if(!strcmp(item,"spawn",true))
		{
		    new clan = PlayerInfo[playerid][Clan];
		    if(clan != NO_TEAM)
		    {
		        if(!strcmp(ClanInfo[clan][Leader],GetName(playerid)))
		        {
		            new zoneid = GetPlayerZone(playerid);
		            if(ZoneInfo[zoneid][Permanent] && (ZoneInfo[zoneid][Owner] == clan))
		            {
		                if(GetPlayerCash(playerid) >= 10000)
		                {
		                	GetPlayerPos(playerid,ClanInfo[clan][Spawn][0],ClanInfo[clan][Spawn][1],ClanInfo[clan][Spawn][2]);
		                	GetPlayerFacingAngle(playerid,ClanInfo[clan][Spawn][3]);
		                	SendClientMessage(playerid,COLOR_WHITE,"CLANINFO: Anda telah menentukan tempat spawn clan!");
		                	GivePlayerCash(playerid,-10000);
						}
						else SEM(playerid,"ERROR: Anda perlu $10000 untuk menentukan tempat spawn clan!");
		            }
		            else SEM(playerid,"ERROR: Anda harus di daerah milik anda untuk menentukan spawn!");
		        }
		        else SEM(playerid,"ERROR: Anda bukan ketua di suatu Clan!");
		    }
		    else SEM(playerid,"ERROR: Anda bukan anggota Clan!");
		}
		else if(!strcmp(item,"setpublic",true))
		{
		    new clan = PlayerInfo[playerid][Clan];
		    if(clan != NO_TEAM)
		    {
		        if(PlayerInfo[playerid][Admin] == 6)
		        {
		            ClanInfo[clan][IsPublic] = true;
					SetClanLeader(clan,"Public");
		        }
		        else return SEM(playerid,"ERROR: Anda bukan admin level 6!");
		    }
		    else return SEM(playerid,"ERROR: Anda bukan anggota Clan!");
		}
		else if(!strcmp(item,"join",true))
		{
		    if(PlayerInfo[playerid][Clan] == NO_TEAM)
		    {
		        new clanlist[256];
				foreach(new clan : Clans)
				{
				    if(ClanInfo[clan][IsPublic])
				    {
				        strcat(clanlist,ClanInfo[clan][Name],sizeof(clanlist));
				        strcat(clanlist,"\n",sizeof(clanlist));
				    }
				}
				if(!IsNull(clanlist))
				{
				    ShowPlayerDialog(playerid,DIALOG_JOIN_PUBLIC_CLAN,DIALOG_STYLE_LIST,"Choose public clan",clanlist,"Join","Cancel");
				}
				else return SEM(playerid,"ERROR: Tidak ada clan public!");
		    }
		    else return SEM(playerid,"ERROR: Anda sudah mempunyai clan!");
		}
		else SEM(playerid,"KEGUNAAN: /clan [create/delete/invite/colour/name/leader/accept/quit/list/kick/givezone/spawn/setpublic/join]");
	}
	return 1;
}
YCMD:c(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Chat untuk clan");
	    SEM(playerid,"SYNTAX: /c [text]");
	    SEM(playerid,"CONTOH: /c hai!");
		SEM(playerid,"ALTERNATIVE: ! [text]");
	    return 1;
	}
	if(PlayerInfo[playerid][Clan] != NO_TEAM)
	{
		if(IsNull(params)) return SEM(playerid,"KEGUNAAN: /c [clan chat]");
		SendClanChat(playerid,params);
	}
	else return SEM(playerid,"ERROR: Anda bukan anggota clan!");
	return 1;
}
YCMD:changeskin(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Mengubah skin ke skinid yang dituju");
		SEM(playerid,"SYNTAX: /changeskin [skinid]");
		SEM(playerid,"PRICE: $1000");
		SEM(playerid,"CONTOH: /changeskin 299");
	    return 1;
	}
    if(GetPlayerCash(playerid) < 1000)
    {
        return SEM(playerid,"ERROR: anda perlu uang $1000 untuk mengganti skin!");
    }
    new skins;
	if(IsNull(params)) return SEM(playerid,"KEGUNAAN: /changeskin [skinid]");
	skins = strval(params);
	if(IsValidSkin(skins))
	{
	    SetPlayerSkin(playerid,skins);
	    PlayerInfo[playerid][Skin] = skins;
	    UpdatePlayerInfo(playerid,"skin",skins);
	    GivePlayerCash(playerid,-1000);
	}
	else SEM(playerid,"ERROR: Invalid skinid!");
	return 1;
}
YCMD:givecash(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Memberikan sejumlah uang yang ditentukan kepada player yang dituju");
	    SEM(playerid,"SYNTAX: /givecash [playerid/name] [amount]");
	    SEM(playerid,"CONTOH: /givecash tianmetal 10000");
	    return 1;
	}
	new giveplayerid,amount;
	if(sscanf(params,"ud",giveplayerid,amount)) return SEM(playerid,"KEGUNAAN: /givecash [playerid] [amount]");
	if(giveplayerid == INVALID_PLAYER_ID || PlayerLogged[giveplayerid] == false) return SEM(playerid,"ERROR: Invalid playerid!");
	if((GetPlayerCash(playerid) >= amount) && (amount > 0))
	{
	    GivePlayerCash(giveplayerid,amount);
	    GivePlayerCash(playerid,-amount);
	}
	else SEM(playerid,"ERROR: anda tidak punya uang sebanyak itu!");
	return 1;
}
YCMD:pm(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Mengirim pesan privat ke player yang dituju");
		SEM(playerid,"SYNTAX: /pm [playerid/name] [message]");
		SEM(playerid,"CONTOH: /pm tianmetal Hello!");
	    return 1;
	}
    new giveplayerid,msg[96],string[128];
    if(sscanf(params,"us[96]",giveplayerid,msg)) return SEM(playerid,"KEGUNAAN: /pm [playerid] [pesan]");
	if((giveplayerid != INVALID_PLAYER_ID) && (playerid != giveplayerid) && (PlayerLogged[giveplayerid]))
	{
	    format(string,128,"[PM] from %s: %s",GetName(playerid),msg);
	    SendClientMessage(giveplayerid,COLOR_YELLOW,string);
	    format(string,128,"[PM] to %s: %s",GetName(giveplayerid),msg);
	    SendClientMessage(playerid,COLOR_YELLOW,string);
	    PlayerPlaySound(giveplayerid, 1056, 0.0, 0.0, 0.0);
		PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);
	}
	else SEM(playerid,"ERROR: Invalid playerid!");
	return 1;
}
YCMD:credits(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Menampilkan semua pihak/orang yang sudah mengkontribusi/membantu ke server ini");
	    return 1;
	}
    SendClientMessage(playerid,COLOR_YELLOW,"Terima kasih untuk:");
    SendClientMessage(playerid,COLOR_WHITE,"{00ffff}SA:MP Team{FFFFFF}, {00ffff}SA:MP Forum{FFFFFF}, dan {00ffff}SA:MP Wiki{FFFFFF} untuk membatu scripting.");
    SendClientMessage(playerid,COLOR_WHITE,"{00ffff}BlueG{FFFFFF} untuk MySQL Plugin.");
    SendClientMessage(playerid,COLOR_WHITE,"{00ffff}RyDeR{FFFFFF} untuk CTime Library Plugin dan beberapa function.");
    SendClientMessage(playerid,COLOR_WHITE,"{00ffff}Y_Less{FFFFFF} untuk sscanf2 dan YSI.");
    SendClientMessage(playerid,COLOR_WHITE,"{00ffff}Incognito{FFFFFF} untuk Streamer Plugin.");
    SendClientMessage(playerid,COLOR_WHITE,"{00ffff}Dracoblue{FFFFFF} untuk TidyPawn.");
    SendClientMessage(playerid,COLOR_WHITE,"{00ffff}Tianmetal{FFFFFF} untuk membuat script ini.");
	return 1;
}
YCMD:setcash(playerid,params[],help)
{
    if(PlayerInfo[playerid][Admin] == 6)
    {
		new giveplayerid,amount;
		if(sscanf(params,"ud",giveplayerid,amount))
		{
		    return SEM(playerid,"KEGUNAAN: /setcash [playerid] [amount]");
		}
		if(IsPlayerConnected(giveplayerid) && PlayerLogged[giveplayerid])
		{
			SetPlayerCash(giveplayerid,amount);
		}
    }
	return 1;
}
YCMD:ip(playerid,params[],help)
{
    new giveplayerid;
    if(!sscanf(params,"u",giveplayerid))
	{
	    if(IsPlayerConnected(giveplayerid))
	    {
			new pIP[20],string[64];
			GetPlayerIp(giveplayerid,pIP,20);
			format(string,64,"[IP] %s's IP: %s",GetName(giveplayerid),pIP);
			SendClientMessage(playerid,COLOR_WHITE,string);
		}
		else
		{
			SEM(playerid,"ERROR: player tidak terkoneksi!");
		}
	}
	else
	{
	    SEM(playerid,"KEGUNAAN: /ip [playerid/nama]");
	}
	return 1;
}
YCMD:goto(playerid,params[],help)
{
    new giveplayerid,Float:pPos[3],string[64];
	if(PlayerInfo[playerid][Admin] != 0)
	{
		if(!sscanf(params,"u",giveplayerid))
		{
		    if(giveplayerid != INVALID_PLAYER_ID)
		    {
		        GetPlayerPos(giveplayerid,pPos[0],pPos[1],pPos[2]);
		        SetPlayerPos(playerid,pPos[0],pPos[1],(pPos[2]+1.0));
		        SetPlayerInterior(playerid,GetPlayerInterior(giveplayerid));
				format(string,64,"TPINFO: Anda telah teleport ke player %s.",GetName(giveplayerid));
				SendClientMessage(playerid,COLOR_WHITE,string);
				format(string,64,"TPINFO: Player %s telah meneleport ke anda!",GetName(playerid));
				SendClientMessage(giveplayerid,COLOR_WHITE,string);
		    }
		    else
		    {
		        SEM(playerid,"ERROR: player tersebut tidak terkoneksi atau berada di mode yang berbeda!");
		    }
		}
		else
		{
		    SEM(playerid,"KEGUNAAN: /goto [playerid/nama]");
		}
	}
	else
	{
	    SEM(playerid,"ERROR: Admin only!");
	}
	return 1;
}
YCMD:gethere(playerid,params[],help)
{
    if(PlayerInfo[playerid][Admin] != 0)
	{
	    new giveplayerid,Float:pPos[3],string[64];
        if(!sscanf(params,"u",giveplayerid))
		{
		    if(giveplayerid != INVALID_PLAYER_ID)
			{
			    GetPlayerPos(playerid,pPos[0],pPos[1],pPos[2]);
				SetPlayerPos(giveplayerid,pPos[0],pPos[1],(pPos[2]+1.0));
       			SetPlayerInterior(giveplayerid,GetPlayerInterior(playerid));
				format(string,64,"TPINFO: Anda telah meneleport player %s ke posisi anda.",GetName(giveplayerid));
				SendClientMessage(playerid,COLOR_WHITE,string);
				format(string,64,"TPINFO: Anda telah diteleport oleh %s!",GetName(playerid));
				SendClientMessage(giveplayerid,COLOR_WHITE,string);
			}
			else
  			{
		        SEM(playerid,"ERROR: player tersebut tidak terkoneksi atau berada di mode yang berbeda!");
		    }
		}
		else
		{
		    SEM(playerid,"KEGUNAAN: /gethere [playerid/name]");
		}
	}
	return 1;
}
YCMD:unbanip(playerid,params[],help)
{
	if(PlayerInfo[playerid][Admin] > 1)
	{
	    if(IsNull(params))
	    {
	        return SEM(playerid,"KEGUNAAN: /unbanip [ip]");
	    }
	    else
	    {
	        new string[64];
	        format(string,64,"unbanip %s",params);
	        SendRconCommand(string);
	        SendRconCommand("reloadbans");
	        format(string,64,"UNBANINFO: IP %s telah di-unban!",params);
	        SendClientMessage(playerid,COLOR_WHITE,string);
	    }
	}
	return 1;
}
YCMD:jail(playerid,params[],help)
{
	if(PlayerInfo[playerid][Admin] > 0)
	{
	    new giveplayerid,jailtime,reason[64];
        if(!sscanf(params,"uds[64]",giveplayerid,jailtime,reason))
		{
		    if(giveplayerid != INVALID_PLAYER_ID)
			{
			    new string[128];
				PlayerInfo[giveplayerid][Jailed] = 1;
				PlayerInfo[giveplayerid][JailTime] = jailtime;
				format(string,sizeof(string),"JAIL: You've jailed %s for %d minutes",GetName(giveplayerid),jailtime);
				SendClientMessage(playerid,COLOR_WHITE,string);
				format(string,sizeof(string),"JAIL: You've been jailed by %s for %d minutes",GetName(playerid),jailtime);
				SendClientMessage(giveplayerid,COLOR_WHITE,string);
				format(string,sizeof(string),"Admin Command: %s telah dijail oleh Admin %s selama %d menit",GetName(giveplayerid),GetName(playerid),jailtime);
				SendClientMessageToAll(COLOR_LIGHTRED,string);
				format(string,sizeof(string),"Alasan: %s",reason);
				SendClientMessageToAll(COLOR_LIGHTRED,string);
				SpawnPlayer(giveplayerid);
			}
			else SEM(playerid,"ERROR: player tersebut tidak terkoneksi!");
		}
		else SEM(playerid,"KEGUNAAN: /jail [playerid/name] [time (minute)] [reason]");
	}
	return 1;
}
YCMD:changeclass(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Membuka dialog yang menampilkan class yang tersedia");
	    return 1;
	}
	ShowPlayerDialog(playerid,DIALOG_CHOOSECLASS,DIALOG_STYLE_LIST,"Choose class","Assault (AK47,Mac10,Deagle)\nHeavy Assault (SPAS12,MP5,9MM)\nClose Range (SawnOff,Tec9,9MM)\nScout (Sniper,Shotgun,SD Pistol)\nCustom Class","Pilih","");
	return 1;
}
YCMD:changename(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Mengubah nama ke yang sudah ditentukan");
	    SEM(playerid,"SYNTAX: /changename [newname]");
	    SEM(playerid,"CONTOH: /changename Bedjo_Putro");
	    return 1;
	}
	if(PlayerLogged[playerid])
	{
		if(!IsNull(params))
		{
		    if(IsValidName(params))
		    {
		        if(!(24 > strlen(params) > 2)) return SEM(playerid,"ERROR: Panjang nama tidak bisa kurang dari 3 atau lebih dari 23!");
		        if(GetPlayerCash(playerid) < 25000 && PlayerInfo[playerid][UpgradePoint] == 0) return SEM(playerid,"ERROR: Anda perlu $25000 dan 1 UP untuk penggantian nama!");
		        new query[128],newname[MAX_PLAYER_NAME];
		        strmid(newname,params,0,strlen(params),MAX_PLAYER_NAME);
		        strToLower(newname);
		        format(query,sizeof(query),"SELECT `id` FROM `users` WHERE `name`='%s'",newname);
		        mysql_tquery(Database,query,"Player_CheckName","ds",playerid,newname);
		    }
		    else SEM(playerid,"ERROR: Nama tidak valid, hanya karakter yang diperbolehkan: ( a-z,A-Z, '_' , '[' , ']' )");
		}
		else
		{
		    SEM(playerid,"KEGUNAAN: /changename [nama yang diinginkan]");
		    SEM(playerid,"INFO: Anda perlu membayar $25000 untuk penggantian nama!");
		}
	}
	return 1;
}
YCMD:upgrade(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Membuka dialog yang menampilkan informasi upgrade yang tersedia");
	    return 1;
	}
    if(PlayerInfo[playerid][UpgradePoint] > 1)
    {
    	new string[128];
    	format(string,128,"Armour Spawn - level %d\nGrenade Spawn - level %d\nRegeneration - level %d\nExtra Ammo - level %d\nFast Learner - level %d",PlayerInfo[playerid][Perks][ArmourSpawn],PlayerInfo[playerid][Perks][NadeSpawn],PlayerInfo[playerid][Perks][Regeneration],PlayerInfo[playerid][Perks][ExtraAmmo],PlayerInfo[playerid][Perks][FastLearner]);
    	ShowPlayerDialog(playerid,DIALOG_UPGRADE_MENU,DIALOG_STYLE_LIST,"Upgrading perk",string,"Pilih","Gagal");
	}
	else
	{
	    SEM(playerid,"ERROR: Anda perlu minimal 2 upgrade point untuk menambah level perk");
	}
	return 1;
}
YCMD:perks(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Menampilkan status perk yang ada");
	    return 1;
	}
    new string[64];
    SendClientMessage(playerid,COLOR_WHITE,"- Perks -");
    format(string,sizeof(string),"Armour Spawn - level %d",PlayerInfo[playerid][Perks][ArmourSpawn]);
    SendClientMessage(playerid,COLOR_WHITE,string);
    format(string,sizeof(string),"Grenade Spawn - level %d",PlayerInfo[playerid][Perks][NadeSpawn]);
    SendClientMessage(playerid,COLOR_WHITE,string);
    format(string,sizeof(string),"Regeneration - level %d",PlayerInfo[playerid][Perks][Regeneration]);
    SendClientMessage(playerid,COLOR_WHITE,string);
    format(string,sizeof(string),"Extra Ammo - level %d",PlayerInfo[playerid][Perks][ExtraAmmo]);
    SendClientMessage(playerid,COLOR_WHITE,string);
	return 1;
}
YCMD:skills(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Menampilkan skill senjata anda");
	    return 1;
	}
	new gunskillname[][] = {"9mm Pistol","Silenced Pistol","Desert Eagle","Pump Shotgun","Sawnoff Shotgun","SPAS-12","Uzi","MP5","AK47","M4","Sniper Rifle"};
	new string[64];
	SendClientMessage(playerid,COLOR_WHITE,"Weapon skills:");
	forex(i,11)
	{
		if(PlayerInfo[playerid][GunSkills][i] > 1000) PlayerInfo[playerid][GunSkills][i] = 1000;
	    format(string,sizeof(string),"{ffff00}%s: {33AA33}%d/1000",gunskillname[i],PlayerInfo[playerid][GunSkills][i]);
	    SendClientMessage(playerid,COLOR_WHITE,string);
	}
	return 1;
}
YCMD:buygun(playerid,params[],help)
{
    if(help)
	{
	    SEM(playerid,"KEGUNAAN: Membuka dialog yang menampilkan senjata yang dapat dibeli");
	    return 1;
	}
    new listtext[512],substr[40];
	forex(i,13)
	{
	    if(PlayerInfo[playerid][WeaponsPurchased][i])
	    {
	        format(substr,sizeof(substr),"%s - {33AA33}PURCHASED\n",GunNames[SelledGun[i][Weaponid]]);
	    }
	    else
	    {
            format(substr,sizeof(substr),"%s - $%d + 1UP\n",GunNames[SelledGun[i][Weaponid]],SelledGun[i][Price]);
	    }
	    strcat(listtext,substr,sizeof(listtext));
	}
	ShowPlayerDialog(playerid,DIALOG_BUYGUN,DIALOG_STYLE_LIST,"Buying guns",listtext,"Buy","Exit");
	return 1;
}
YCMD:rules(playerid,params[],help)
{
	if(help)
	{
	    SEM(playerid,"KEGUNAAN: Menampilkan peraturan yang berlaku di server ini");
	    return 1;
	}
	new string[2048];
	format(string,sizeof(string),"1. Dilarang menggunakan program yang bersifat cheat atau hack");
	format(string,sizeof(string),"%s\n2. Dilarang memanfaatkan bug server, bug SA:MP, atau bug GTA",string);
	format(string,sizeof(string),"%s\n3. Dilarang menghina atau mengejek player lain",string);
	format(string,sizeof(string),"%s\n4. Selalu hormati admin dan player lain",string);
	format(string,sizeof(string),"%s\n5. Dilarang menjelek-jelekan nama baik %s",string,SERVER_NAME);
	format(string,sizeof(string),"%s\n6. Selalu bersikap DM dalam situasi apapun",string);
	format(string,sizeof(string),"%s\n7. Dilarang DB tanpa driver",string);
	format(string,sizeof(string),"%s\n8. Dilarang GB (memanfaatkan user lain agar cepat naik level)",string);
	format(string,sizeof(string),"%s\n9. Dilarang Car-DM (DM orang lain dengan menabrakkan kendaraan)",string);
	format(string,sizeof(string),"%s\n10. Hanya clan yang boleh bekerja-sama, selain itu dilarang berteman",string);
	format(string,sizeof(string),"%s\n\nUntuk informasi lebih lanjut, silahkan cek forum di: %s",string,SERVER_WEBSITE);
	ShowPlayerDialog(playerid,DIALOG_NONE,DIALOG_STYLE_MSGBOX,"Server Rules",string,"Tutup","");
	return 1;
}

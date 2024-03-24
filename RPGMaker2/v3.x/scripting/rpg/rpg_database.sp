/* put the line below after all of the includes!
#pragma newdecls required
*/

void MySQL_Init()
{
	if (hDatabase != INVALID_HANDLE) return;	// already connected.
	//hDatabase														=	INVALID_HANDLE;

	GetConfigValue(TheDBPrefix, sizeof(TheDBPrefix), "database prefix?");
	GetConfigValue(Hostname, sizeof(Hostname), "server name?");
	if (GetConfigValueInt("friendly fire enabled?") == 1) ReplaceString(Hostname, sizeof(Hostname), "{FF}", "FF ON");
	else ReplaceString(Hostname, sizeof(Hostname), "{FF}", "FF OFF");
	if (StrContains(Hostname, "{V}", true) != -1) ReplaceString(Hostname, sizeof(Hostname), "{V}", PLUGIN_VERSION);

	iServerLevelRequirement		= GetConfigValueInt("server level requirement?");
	RatingPerLevel				= GetConfigValueInt("rating level multiplier?");
	RatingPerAugmentLevel		= GetConfigValueInt("rating per augment level multiplier?", 1);
	RatingPerLevelSurvivorBots	= GetConfigValueInt("rating level multiplier survivor bots?");
	InfectedTalentLevel			= GetConfigValueInt("talent level multiplier?");
	fEnrageModifier				= GetConfigValueFloat("enrage modifier?");

	if (iServerLevelRequirement > 0) {

		if (StrContains(Hostname, "{RS}", true) != -1) {

			char HostLevels[64];
			//Format(HostLevels, sizeof(HostLevels), "Lv%s(TruR%s)", AddCommasToString(iServerLevelRequirement), AddCommasToString(iServerLevelRequirement * RatingPerLevel));
			Format(HostLevels, sizeof(HostLevels), "[%d+]", iServerLevelRequirement);
			ReplaceString(Hostname, sizeof(Hostname), "{RS}", HostLevels);
		}
	}
	//Format(sHostname, sizeof(sHostname), "%s", Hostname);

	GetConfigValue(RatingType, sizeof(RatingType), "db record?");
	if (StrEqual(RatingType, "-1")) {

		if (ReadyUp_GetGameMode() == 3) Format(RatingType, sizeof(RatingType), "%s", SURVRECORD_DB);
		else Format(RatingType, sizeof(RatingType), "%s", COOPRECORD_DB);
	}

	//LogMessage("Setting hostname %s", Hostname);
	ServerCommand("hostname %s", Hostname);
	//SetSurvivorsAliveHostname();
	SQL_TConnect(DBConnect, TheDBPrefix);
}

stock void SetSurvivorsAliveHostname() {
	static char Newhost[64];
	Format(Newhost, sizeof(Newhost), "%s", Hostname);
	if (b_IsActiveRound) Format(Newhost, sizeof(Newhost), "%s(%d alive)", Hostname, LivingSurvivors());
	ServerCommand("hostname %s", Newhost);
}

public int ReadyUp_GroupMemberStatus(int client, int groupStatus) {

	if (IsLegitimateClient(client)) {
		if (HasCommandAccess(client, "donator package flag?") || groupStatus == 1) IsGroupMember[client] = true;
		else IsGroupMember[client] = false;

		CheckGroupStatus(client);
	}
	return 0;
}

public void DBConnect(Handle owner, Handle hndl, const char[] error, any data)
{
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("Unable to connect to database: %s", error);
		SetFailState("%s", error);
	}
	LogMessage("Connected to RPG Database!");

	hDatabase = hndl;

	int GenerateDB = GetConfigValueInt("generate database?");
	
	char tquery[PLATFORM_MAX_PATH];
	char text[64];
	
	if (GenerateDB == 1) {

		//Format(tquery, sizeof(tquery), "SET NAMES 'UTF8';");
		//SQL_TQuery(hDatabase, QueryResults, tquery);
		//Format(tquery, sizeof(tquery), "SET CHARACTER SET utf8;");
		//SQL_TQuery(hDatabase, QueryResults, tquery);

		//Format(tquery, sizeof(tquery), "CREATE TABLE IF NOT EXISTS `%s_maps` (`mapname` varchar(64) NOT NULL, PRIMARY KEY (`mapname`)) ENGINE=MyISAM;", TheDBPrefix);
		//SQL_TQuery(hDatabase, QueryResults, tquery);

		Format(tquery, sizeof(tquery), "CREATE TABLE IF NOT EXISTS `%s` (`steam_id` varchar(64) NOT NULL, PRIMARY KEY (`steam_id`)) ENGINE=InnoDB;", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` CHARACTER SET utf8 COLLATE utf8_general_ci;", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `primarywep` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `secondwep` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `exp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `expov` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `upgrade cost` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `level` int(32) NOT NULL DEFAULT '1';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `skylevel` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `augmentparts` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `dismantlescore` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `dismantleminor` int(4) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);

		GetConfigValue(text, sizeof(text), "sky points menu name?");
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `time played` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `talent points` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `total upgrades` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `free upgrades` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `restt` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `restexp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `lpl` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `resr` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `survpoints` varchar(32) NOT NULL DEFAULT '0.0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `bec` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `rem` varchar(32) NOT NULL DEFAULT '0.0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, COOPRECORD_DB);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, SURVRECORD_DB);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		GetConfigValue(text, sizeof(text), "db record?");
		if (!StrEqual(text, "-1")) {

			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			SQL_TQuery(hDatabase, QueryResults, tquery);
		}
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `myrating %s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, RatingType);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `handicaplevel %s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, RatingType);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `pri` int(32) NOT NULL DEFAULT '1';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `tname` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		//Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `mapname` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		//SQL_TQuery(hDatabase, QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `xpdebt` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `upav` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `upawarded` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `companionname` varchar(32) NOT NULL DEFAULT 'survivor';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `companionowner` varchar(32) NOT NULL DEFAULT 'survivor';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `lastserver` varchar(64) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `myseason` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `lvlpaused` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `itrails` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);

		/*
			weapon levels
			\\rewarding players who use a specific weapon category with increased proficiency in that category.
		*/
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `pistol_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `melee_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `uzi_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		/*
			has both pump and auto shotgun tiers
		*/
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `shotgun_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `sniper_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `assault_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);

		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `medic_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `grenade_xp` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);


		Format(tquery, sizeof(tquery), "CREATE TABLE IF NOT EXISTS `%s_loot` (`itemid` varchar(64) NOT NULL, PRIMARY KEY (`itemid`)) ENGINE=InnoDB;", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` CHARACTER SET utf8 COLLATE utf8_general_ci;", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `steam_id` varchar(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `firstowner` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `rating` int(32) NOT NULL DEFAULT '1';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `category` varchar(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `price` int(32) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `isforsale` int(4) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `isequipped` int(4) NOT NULL DEFAULT '-1';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `acteffects` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `actrating` int(32) NOT NULL DEFAULT '-1';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `tareffects` varchar(32) NOT NULL DEFAULT 'none';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s_loot` ADD `tarrating` int(4) NOT NULL DEFAULT '-1';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);
		
		int counter = iActionBarSlots;
		for (int i = 0; i < counter; i++) {
			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `aslot%d` VARCHAR(32) NOT NULL DEFAULT 'None';", TheDBPrefix, i+1);
			SQL_TQuery(hDatabase, QueryResults, tquery);
		}
		Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `disab` INT(4) NOT NULL DEFAULT '0';", TheDBPrefix);
		SQL_TQuery(hDatabase, QueryResults, tquery);

		/*new size			=	GetArraySize(a_Database_Talents);

		for (new i = 0; i < size; i++) {

			GetArrayString(Handle:a_Database_Talents, i, text, sizeof(text));
			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			SQL_TQuery(hDatabase, QueryResults, tquery);
		}*/
	}

	ClearArray(a_Database_Talents_Defaults);
	ClearArray(a_Database_Talents_Defaults_Name);
	//ClearArray(Handle:a_ClassNames);

	char NewValue[64];

	int size			=	GetArraySize(a_Menu_Talents);
	for (int i = 0; i < size; i++) {

		DatabaseKeys			=	GetArrayCell(a_Menu_Talents, i, 0);
		DatabaseValues			=	GetArrayCell(a_Menu_Talents, i, 1);
		if (GetArrayCell(DatabaseValues, IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue;

		DatabaseSection			=	GetArrayCell(a_Menu_Talents, i, 2);

		GetArrayString(DatabaseSection, 0, text, sizeof(text));
		PushArrayString(a_Database_Talents_Defaults_Name, text);
		if (GenerateDB == 1) {

			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			//else Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '-1';", TheDBPrefix, text);
			SQL_TQuery(hDatabase, QueryResults, tquery);
		}

		//if (StringToInt(NewValue) < 0) Format(NewValue, sizeof(NewValue), "0");
		PushArrayString(a_Database_Talents_Defaults, NewValue);
	}

	if (GenerateDB == 1) {

		GenerateDB = 0;

		size				=	GetArraySize(a_DirectorActions);

		for (int i = 0; i < size; i++) {

			DatabaseSection			=	GetArrayCell(a_DirectorActions, i, 2);
			GetArrayString(DatabaseSection, 0, text, sizeof(text));
			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			SQL_TQuery(hDatabase, QueryResults, tquery);
		}

		size				=	GetArraySize(a_Store);

		for (int i = 0; i < size; i++) {

			DatabaseSection			=	GetArrayCell(a_Store, i, 2);
			GetArrayString(DatabaseSection, 0, text, sizeof(text));
			Format(tquery, sizeof(tquery), "ALTER TABLE `%s` ADD `%s` int(32) NOT NULL DEFAULT '0';", TheDBPrefix, text);
			SQL_TQuery(hDatabase, QueryResults, tquery);
		}
	}

	size = GetArraySize(a_Database_Talents);

	ResizeArray(a_Database_PlayerTalents_Bots, size);
	ResizeArray(PlayerAbilitiesCooldown_Bots, size);
	ResizeArray(PlayerAbilitiesImmune_Bots, size);

	GetNodesInExistence();
}

public void QuerySaveNewPlayer(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QuerySaveNewPlayer Error %s", error);
		return;
	}
	if (IsLegitimateClient(client)) SavePlayerData(client, _, true);
}

public void QueryResults(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults Error %s", error);
		return;
	}
}

public void QueryResults1(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults1 Error %s", error);
		return;
	}
}

public void QueryResults2(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults2 Error %s", error);
		return;
	}
}

public void QueryResults3(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults3 Error %s", error);
		return;
	}
}

public void QueryResults4(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults4 Error %s", error);
		return;
	}
}

public void QueryResults5(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults5 Error %s", error);
		return;
	}
}

public void QueryResults6(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults6 Error %s", error);
		return;
	}
}

public void QueryResults7(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults7 Error %s", error);
		return;
	}
}

public void QueryResults8(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		if (StrContains(error, "Duplicate column name", false) == -1) LogMessage("QueryResults8 Error %s", error);
		return;
	}
}

stock void LoadLeaderboards(int client, int count) {

	if (count == 0) {

		if (TheLeaderboardsPageSize[client] >= leaderboardPageCount) {
			TheLeaderboardsPage[client] -= leaderboardPageCount;
			if (TheLeaderboardsPage[client] < 0) TheLeaderboardsPage[client] = 0;
		}
		else TheLeaderboardsPage[client] = 0;
	}
	else if (TheLeaderboardsPageSize[client] >= leaderboardPageCount) {		// if a page didn't load 10 entries, we don't increment. If a page exactly 10 entries, the next page will be empty and only have a return option.

		TheLeaderboardsPage[client] += leaderboardPageCount;
	}
	char tquery[1024];
	char Mapname[64];
	GetCurrentMap(Mapname, sizeof(Mapname));

	Format(tquery, sizeof(tquery), "SELECT `tname`, `steam_id`, `%s` FROM `%s` ORDER BY `%s` DESC;", RatingType, TheDBPrefix, RatingType);
	SQL_TQuery(hDatabase, LoadLeaderboardsQuery, tquery, client);
}

public void LoadLeaderboardsQuery(Handle owner, Handle hndl, const char[] error, any data)
{
	if (!IsLegitimateClient(data)) return;
	if (hndl == INVALID_HANDLE)
	{
		LogMessage("[LoadLeaderboardsQuery] %s", error);
		return;
	}
	int i = 0;
	//new count = 0;
	int counter = 0;
	Handle LeadName = CreateArray(16);
	Handle LeadRating = CreateArray(16);

	if (!bIsMyRanking[data]) {

		ResizeArray(LeadName, leaderboardPageCount);
		ResizeArray(LeadRating, leaderboardPageCount);
	}
	else {

		ResizeArray(LeadName, 1);
		ResizeArray(LeadRating, 1);
	}
	char text[64];
	//decl String:tquery[1024];
	int Pint = 0;
	int IgnoreRating = scoreRequiredForLeaderboard;
	char SteamID[64];
	//GetClientAuthId(data, AuthId_Steam2, SteamID, sizeof(SteamID));
	GetClientAuthId(data, AuthId_Steam2, SteamID, sizeof(SteamID));
	if (!StrEqual(serverKey, "-1")) Format(SteamID, sizeof(SteamID), "%s%s", serverKey, SteamID);
	ClearArray(TheLeaderboards[data]);		// reset the data held when a page is loaded.

	while (i < leaderboardPageCount && SQL_FetchRow(hndl))
	{	// bots don't have STEAM_ in their authIDs, so this will prevent bots from showing on the leaderboard.
		SQL_FetchString(hndl, 1, text, sizeof(text));
		if (StrContains(text, "STEAM_", true) == -1) continue;
		if (bIsMyRanking[data] && !StrEqual(text, SteamID, false)) {

			counter++;
			continue;
		}

		//count++;
		counter++;
		// +1 prevents every nth being a duplicate on the following page
		if (counter < TheLeaderboardsPage[data]+1) continue;

		Pint = SQL_FetchInt(hndl, 2);
		if (Pint < IgnoreRating || Pint < 2) {

			//count--;
			counter--;
			continue;	// players can un-set their name to hide themselves on the leaderboards.
		}

		/*SQL_FetchString(hndl, 2, text, sizeof(text));
		if (bIsMyRanking[data] && !StrEqual(text, SteamID, false)) {// ||
			//StrContains(text, "STEAM_", true) == -1) {

			count--;
			//if (StrContains(text, "STEAM_", true) == -1)
			//counter--;
			continue;	// will not display bots rating in the leaderboards.
		}*/

		SQL_FetchString(hndl, 0, text, sizeof(text));
		if (strlen(text) < 16) {

			if (strlen(text) > 12) Format(text,sizeof(text), "%s\t", text);
			else if (strlen(text) > 8) Format(text,sizeof(text), "%s\t\t\t", text);
			else if (strlen(text) > 4) Format(text,sizeof(text), "%s\t\t\t\t\t\t", text);
			else Format(text,sizeof(text), "%s\t\t\t\t\t\t\t", text);
		}
		Format(text, sizeof(text), "#%d %s", counter, text);

		SetArrayString(LeadName, i, text);

		Pint = SQL_FetchInt(hndl, 2);
		Format(text, sizeof(text), "%d", Pint);
		SetArrayString(LeadRating, i, text);

		i++;
		if (bIsMyRanking[data]) break;
	}
	//bIsMyRanking[data] = false;

	//new size = GetArraySize(TheLeaderboards[data]);

	if (!bIsMyRanking[data]) {

		ResizeArray(LeadName, i);
		ResizeArray(LeadRating, i);
	}
	TheLeaderboardsPageSize[data] = i;

	ResizeArray(TheLeaderboards[data], 1);
	SetArrayCell(TheLeaderboards[data], 0, LeadName, 0);
	SetArrayCell(TheLeaderboards[data], 0, LeadRating, 1);

	if (GetArraySize(TheLeaderboards[data]) > 0) SendPanelToClientAndClose(DisplayTheLeaderboards(data), data, DisplayTheLeaderboards_Init, MENU_TIME_FOREVER);
	else BuildMenu(data);

	CloseHandle(LeadName);
	CloseHandle(LeadRating);
}

stock void ResetData(int client) {

	RefreshSurvivor(client);
	ResetContributionTracker(client);
	HealingContribution[client] = 0;
	TankingContribution[client] = 0;
	DamageContribution[client] = 0;
	PointsContribution[client] = 0.0;
	HexingContribution[client] = 0;
	BuffingContribution[client] = 0;
	bIsCrushCooldown[client]		= false;
	//Points[client]					= 0.0;
	//SlatePoints[client]				= 0;
	//FreeUpgrades[client]			= 0;
	b_IsDirectorTalents[client]		= false;
	b_IsJumping[client]				= false;
	ModifyGravity(client);
	ResetCoveredInBile(client);
	SpeedMultiplierBase[client]		= 1.0;
	if (IsLegitimateClientAlive(client) && !IsGhost(client)) SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", SpeedMultiplierBase[client]);
	//TimePlayed[client]				= 0;
	t_Distance[client]				= 0;
	t_Healing[client]				= 0;
	b_IsBlind[client]				= false;
	b_IsImmune[client]				= false;
	GravityBase[client]				= 1.0;
	CommonKills[client]				= 0;
	CommonKillsHeadshot[client]		= 0;
	bIsMeleeCooldown[client]		= false;
	shotgunCooldown[client]			= false;
	ClearArray(InfectedHealth[client]);
	ClearArray(PlayerActiveAmmo[client]);
	ClearArray(PlayActiveAbilities[client]);
	ClearArray(ApplyDebuffCooldowns[client]);
	if (ISFROZEN[client] != INVALID_HANDLE) {
		KillTimer(ISFROZEN[client]);
		ISFROZEN[client] = INVALID_HANDLE;
	}
	StrugglePower[client] = 0;
}

stock void ClearAndLoad(int client, bool IgnoreLoad = false) {

	if (hDatabase == INVALID_HANDLE) return;
	//new client = FindClientWithAuthString(key, true);
	if (client < 1) return;
	if (b_IsLoading[client] && !IgnoreLoad) return;
	ClearArray(possibleLootPool[client]);
	b_IsLoading[client] = true;

	char key[64];
	GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
	if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);

	//if (StrContains(key, "BOT", false) != -1) {
	if (IsFakeClient(client)) {
		char TheName[64];
		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, 64, "%s%s", sBotTeam, TheName);
	}
	SQL_EscapeString(hDatabase, key, key, sizeof(key));
	ClearArray(hWeaponList[client]);
	ResizeArray(hWeaponList[client], 2);
	
	ClearArray(myAugmentIDCodes[client]);
	ClearArray(myAugmentCategories[client]);
	ClearArray(myAugmentOwners[client]);
	ClearArray(myAugmentInfo[client]);
	ClearArray(myAugmentActivatorEffects[client]);
	ClearArray(myAugmentTargetEffects[client]);

	char text[64];
	Format(text, sizeof(text), "none");
	SetArrayString(hWeaponList[client], 0, text);
	SetArrayString(hWeaponList[client], 1, text);
	ResetData(client);
	LoadPos[client] = 0;
	bIsMeleeCooldown[client] = false;
	if (!b_IsArraysCreated[client]) {
		b_IsArraysCreated[client]			= true;
	}
	if (GetArraySize(a_Store_Player[client]) != GetArraySize(a_Store)) {
		ResizeArray(a_Store_Player[client], GetArraySize(a_Store));
	}

	for (int i = 0; i < GetArraySize(a_Store); i++) {

		SetArrayString(a_Store_Player[client], i, "0");				// We clear all players arrays for the store.
	}
	char tquery[2048];
	//LogMessage("Loading %N data", client);
	char themenu[64];
	GetConfigValue(themenu, sizeof(themenu), "sky points menu name?");
	Format(tquery, sizeof(tquery), "SELECT `steam_id`, `exp`, `expov`, `upgrade cost`, `level`, `skylevel`, `%s`, `time played`, `talent points`, `total upgrades`, `free upgrades`, `restt`, `restexp`, `lpl`, `resr`, `survpoints`, `bec`, `rem`, `pri`, `xpdebt`, `upav`, `upawarded`, `%s`, `myrating %s`, `handicaplevel %s`, `lastserver`, `myseason`, `lvlpaused`, `itrails`, `pistol_xp`, `melee_xp`, `uzi_xp`, `shotgun_xp`, `sniper_xp`, `assault_xp`, `medic_xp`, `grenade_xp`, `augmentparts`, `dismantlescore`, `dismantleminor` FROM `%s` WHERE (`steam_id` = '%s');", themenu, RatingType, RatingType, RatingType, TheDBPrefix, key);
	// maybe set a value equal to the users steamid integer only, so if steam:0:1:23456, set the value of "client" equal to 23456 and then set the client equal to whatever client's steamid contains 23456?
	SQL_TQuery(hDatabase, QueryResults_Load, tquery, client);
}

public void Query_CheckIfProfileLimit(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE || !IsClientConnected(client)) {

		LogMessage("Query_CheckIfProfileLimit Error: %s", error);
		return;
	}
	int ProfileCountLimit = GetConfigValueInt("profile editor limit?");
	char thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "donator package flag?");
	if (IsGroupMember[client] || HasCommandAccess(client, thetext)) ProfileCountLimit = RoundToCeil(ProfileCountLimit * 2.0);
	char tquery[1024];
	char key[128];

	while (SQL_FetchRow(hndl)) {

		if (SQL_FetchInt(hndl, 0) < ProfileCountLimit) {

			GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
			if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
			Format(key, sizeof(key), "%s%s+%s", key, PROFILE_VERSION, LoadoutName[client]);

			Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE (`steam_id` = '%s');", TheDBPrefix, key);
			SQL_TQuery(hDatabase, Query_CheckIfProfileExists, tquery, client);
		}
		else PrintToChat(client, "%T", "profile editor limit reached", client, orange);
	}
}

public void Query_CheckCompanionCount(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_CheckCompanionCount Error: %s", error);
		return;
	}
	while (SQL_FetchRow(hndl)) {

		if (SQL_FetchInt(hndl, 0) >= GetConfigValueInt("max unique companions?")) {

			PrintToChat(client, "companion limit %d exceeded", GetConfigValueInt("max unique companions?"));
			return;
		}
		else {

			PrintToChat(client, "Your party is not full, adding %s to the party!", CompanionNameQueue[client]);

			char tquery[1024];
			Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE `companionname` = '%s';", TheDBPrefix, CompanionNameQueue[client]);
			SQL_TQuery(hDatabase, Query_CheckIfCompanionExists, tquery, client);
		}
	}
}

public void Query_CheckIfCompanionExists(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_CheckIfCompanionExists Error: %s", error);
		return;
	}
	while (SQL_FetchRow(hndl)) {

		if (SQL_FetchInt(hndl, 0) < 1) {

			ReadyUp_NtvCreateCompanion(client, CompanionNameQueue[client]);		// The companion of this name doesn't exist, so we allow the player to create it.
			CreateTimer(1.0, Timer_SaveCompanion, client, TIMER_FLAG_NO_MAPCHANGE);		// now we save the companion to the database so no one else can use this name.
		}
		else {

			PrintToChat(client, "companion name taken, please pick another");
			return;
		}
	}
}

public void Query_CheckIfProfileExists(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_CheckIfProfileExists Error: %s", error);
		return;
	}
	while (SQL_FetchRow(hndl)) {

		if (SQL_FetchInt(hndl, 0) < 1) {

			SaveProfile(client, 1);		// 1 for saving a new profile.
		}
		else SaveProfile(client, 2);	// 2 for overwriting an existing profile.
	}
}

stock void ModifyCartelValue(int client, char[] thetalent, int thevalue) {

	int size = GetArraySize(a_Menu_Talents);
	char text[512];

	for (int i = 0; i < size; i++) {

		CartelValueKeys[client]			= GetArrayCell(a_Menu_Talents, i, 0);
		CartelValueValues[client]		= GetArrayCell(a_Menu_Talents, i, 1);

		if (GetArrayCell(CartelValueValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue;
		if (GetArrayCell(CartelValueValues[client], IS_TALENT_TYPE) <= 0) continue;

		GetArrayString(a_Database_Talents, i, text, sizeof(text));
		if (!StrEqual(text, thetalent, false)) continue;
		
		SetArrayCell(a_Database_PlayerTalents[client], i, thevalue);
		SetArrayCell(a_Database_PlayerTalents_Experience[client], i, 0);
	}
}

stock void CreateNewPlayerEx(int client) {

	char tquery[1024];
	char TagName[64];
	int size = GetArraySize(a_Database_Talents);

	char key[512];
	char TheName[64];
	if (IsFakeClient(client)) {
		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
	}
	else {
		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
		if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
	}

	LogMessage("No data rows for %N with steamid: %s, could be found, creating new player data.", client, key);
	char oldName[64];
	GetClientName(client, oldName, 64);
	if (IsFakeClient(client)) PlayerLevel[client] = iBotPlayerStartingLevel;
	else PlayerLevel[client]				=	iPlayerStartingLevel;
	SetTotalExperienceByLevel(client, PlayerLevel[client]);
	ChallengeEverything(client);
	//FormatPlayerName(client);

	bIsNewPlayer[client]			= true;
	b_IsLoading[client]				= false;
	bIsTalentTwo[client]			= false;
	b_IsLoadingStore[client]		= false;
	b_IsLoadingTrees[client]		= false;
	LoadTarget[client]				=	-1;
	Rating[client]					=	0;
	ExperienceDebt[client]			=	0;
	//ExperienceLevel[client]			=	1;
	//ExperienceOverall[client]		=	1;
	PlayerLevelUpgrades[client]		=	0;
	SkyPoints[client]				=	0;
	TotalTalentPoints[client]		=	0;
	TimePlayed[client]				=	0;
	PlayerUpgradesTotal[client]		=	0;
	UpgradesAvailable[client]		= MaximumPlayerUpgrades(client);
	FreeUpgrades[client]			=	0;
	if (!IsFakeClient(client)) DefaultHealth[client]			=	iSurvivorBaseHealth;
	else DefaultHealth[client]			= iSurvivorBotBaseHealth;
	//PrintToChatAll("Setting %N to %d", client, PlayerLevel[client]);
	GiveMaximumHealth(client);
	Format(ActiveSpecialAmmo[client], sizeof(ActiveSpecialAmmo[]), "none");


	//for (new i = 1; i <= MAXPLAYERS; i++) ResizeArray(PlayerAbilitiesImmune[client][i], size);
	//ResizeArray(PlayerAbilitiesImmune[client], size);
	ResizeArray(a_Database_PlayerTalents[client], size);
	ResizeArray(a_Database_PlayerTalents_Experience[client], size);
	for (int i = 0; i < size; i++) {

		/*

			We used to set defaults here, instead we set everything to 0, and just don't allow a player to insert a point if it is locked.
		*/

		//GetArrayString(a_Database_Talents_Defaults, i, text, sizeof(text));
		//Format(text, sizeof(text), "%d", StringToInt(text) - 1);
		SetArrayCell(a_Database_PlayerTalents[client], i, 0);
		SetArrayCell(a_Database_PlayerTalents_Experience[client], i, 0);
	}
	if (GetArraySize(a_Store_Player[client]) != GetArraySize(a_Store)) {

		ResizeArray(a_Store_Player[client], GetArraySize(a_Store));
	}

	for (int i = 0; i < GetArraySize(a_Store); i++) {

		SetArrayString(a_Store_Player[client], i, "0");				// We clear all players arrays for the store.
	}
	BuildMenu(client);
	FormatPlayerName(client);
	Format(TagName, sizeof(TagName), "%s", baseName[client]);
	SQL_EscapeString(hDatabase, TagName, TagName, sizeof(TagName));
	//Format(tquery, sizeof(tquery), "INSERT INTO `%s` (`steam_id`, `exp`, `expov`, `upgrade cost`, `level`, `%s`, `time played`, `talent points`, `total upgrades`, `free upgrades`, `tcolour`, `tname`, `ccolour`) VALUES ('%s', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%d', '%s', '%s', '%s');", TheDBPrefix, spmn, key, ExperienceLevel[client], ExperienceOverall[client], PlayerLevelUpgrades[client], PlayerLevel[client], SkyPoints[client], TimePlayed[client], TotalTalentPoints[client], PlayerUpgradesTotal[client], FreeUpgrades[client], TagColour, TagName, ChatColour);
	Format(tquery, sizeof(tquery), "INSERT INTO `%s` (`steam_id`, `tname`) VALUES ('%s', '%s');", TheDBPrefix, key, TagName);
	//SQL_EscapeString(hDatabase, tquery, tquery, sizeof(tquery));
	SQL_TQuery(hDatabase, QuerySaveNewPlayer, tquery, client);

	CreateTimer(1.0, Timer_LoggedUsers, client, TIMER_FLAG_NO_MAPCHANGE);
}

public void Query_FindDataAndApplyChange(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_FindDataAndApplyChange Error: %s", error);
		return;
	}
	int count	= 0;
	if (!IsLegitimateClient(client)) return;
	while (SQL_FetchRow(hndl)) count	= SQL_FetchInt(hndl, 0);
	if (count < 1) PrintToChat(client, "no data for %s exists.", steamIdSearch[client]);
	else {
		int expToSet = GetTotalExperienceByLevel(levelToSet[client]);
		char sExp[64];
		AddCommasToString(expToSet, sExp, sizeof(sExp));
		PrintToChat(client, "data for %s found. setting level to %d and xp to %s", steamIdSearch[client], levelToSet[client], sExp);
		char tquery[512];
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `exp` = '%d', `expov` = '%d', `level` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, expToSet, expToSet, levelToSet[client], steamIdSearch[client]);
		SQL_TQuery(hDatabase, QueryResults1, tquery, client);
	}
}

public void Query_CheckIfDataExists(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl == INVALID_HANDLE) {

		LogMessage("Query_ChecKIfDataExists Error: %s", error);
		return;
	}
	char key[512];
	char TheName[64];
	int count	= 0;
	if (!IsLegitimateClient(client)) return;
	if (IsFakeClient(client)) {

		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
	}
	else {

		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
		if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
	}
	LogMessage("Does data exist for %N?", client);
	while (SQL_FetchRow(hndl)) {

		//SQL_FetchString(hndl, 0, key, sizeof(key));
		count	= SQL_FetchInt(hndl, 0);
	}
	if (count < 1) {

		if (!CheckServerLevelRequirements(client)) return;	// client was kicked.

		CreateNewPlayerEx(client);

			//decl String:DefaultProfileName[512];
			//GetConfigValue(DefaultProfileName, sizeof(DefaultProfileName), "new player profile?");
			//if (StrContains(DefaultProfileName, "-1", false) == -1) LoadProfileEx(client, DefaultProfileName);
	}
	else {

		LogMessage("%d Data rows found for %N with steamid: %s, loading player data.", count, client, key);
		//b_IsLoading[client] = false;
		ClearAndLoad(client, true);
		//if (!IsFakeClient(client)) CheckServerLevelRequirements(client);
	}
}

stock void CheckGroupStatus(int client) {

	char pct[4];
	Format(pct, sizeof(pct), "%");

	if (IsLegitimateClient(client) && !IsFakeClient(client) && GroupMemberBonus > 0.0) {

		if (IsGroupMember[client]) PrintToChat(client, "%T", "group member bonus", client, blue, GroupMemberBonus * 100.0, pct, green, orange);
		else PrintToChat(client, "%T", "group member benefit", client, orange, blue, GroupMemberBonus * 100.0, pct, green, blue);
	}
}

stock void SaveCompanionData(int client, bool DontTell = false) {

	/*if (StrEqual(ActiveCompanion[client], "none")) return;
	if (!DontTell) PrintToChat(client, "%T", "saving companion data", orange, green, ActiveCompanion[client]);

	decl String:tquery[1024];
	decl String:text[64];
	GetClientAuthString(client, text, sizeof(text));
	Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE (`companion` = '%s');", TheDBPrefix, ActiveCompanion[client]);
	SQL_TQuery(hDatabase, Query_SaveCompanionData)*/
}

public Action Timer_LoadDelay(Handle timer, any client) {

	if (IsLegitimateClient(client)) {

		LoadDelay[client] = false;
	}
	return Plugin_Stop;
}

stock void CreateNewPlayer(int client) {
	if (hDatabase == INVALID_HANDLE) {

		LogMessage("cannot create data because the database is still loading. %N", client);
		return;
	}
	//if (LoadDelay[client]) return;	// prevent constant loading (bots, specifically.)
	//LoadDelay[client] = true;
	//CreateTimer(3.0, Timer_LoadDelay, client, TIMER_FLAG_NO_MAPCHANGE);
	char tquery[1024];
	char key[512];
	char TheName[64];
	if (b_IsLoading[client]) return;	// should stop bots (and players) from looping indefinitely.
	b_IsLoading[client] = true;
	if (IsFakeClient(client)) {
		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
	}
	else if (IsLegitimateClient(client) && !IsFakeClient(client)) {
		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
		if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
	}
	else {
		//LogMessage("Infected bots do not create unique data (%N)", client);
		b_IsLoading[client] = false;
		return;
	}
	LogMessage("Looking up player %N (%s) in Database before creating new data.", client, key);
	Format(tquery, sizeof(tquery), "SELECT COUNT(*) FROM `%s` WHERE (`steam_id` = '%s');", TheDBPrefix, key);
	SQL_TQuery(hDatabase, Query_CheckIfDataExists, tquery, client);
}

public Action Timer_SaveCompanion(Handle timer, any client) {

	//new companion = MySurvivorCompanion(client);
	//SaveAndClear(companion);
	return Plugin_Stop;
}

stock void SaveInfectedData(int client) {

	//return;
}

stock SavePlayerData(int client, bool b_IsTrueDisconnect = false, bool IsNewPlayer = false) {
	if (!IsLegitimateClient(client)) return;
	bool IsLoadingData = b_IsLoading[client];
	if (!IsLoadingData && !IsNewPlayer) {
		LogMessage("Player Data saved for %N", client);
		//IsLoadingData = bIsTalentTwo[client];
		//return;
	}

	// if the database isn't connected, we don't try to save data, because that'll just throw errors.
	// If the player didn't participate, or if they are currently saving data, we don't save as well.
	// It's possible (but not likely) for a player to try to save data while saving, due to their ability to call the function at any time through commands.
	if (hDatabase == INVALID_HANDLE) {

		LogMessage("Database couldn't be found, cannot save for %N", client);
		return;
	}
	if (!b_IsLoaded[client]) return;
	//if (GetClientTeam(client) == TEAM_SPECTATOR) return;
	if (GetClientTeam(client) == TEAM_INFECTED) {

		SaveInfectedData(client);
		return;
	}
	if (GetArraySize(a_Database_PlayerTalents[client]) < 1) {

		// This is probably a survivor bot, or a human player who is simply playing vanilla.
		// I thought I had checks in place to make sure they didn't get this far, but it looks like something is still getting through.
		// Oh well, now it's not.
		return;
	}
	if (IsNewPlayer) {
		LogMessage("Saving %N's player data for the first time.", client);
	}
	if (b_IsTrueDisconnect) {
		if (b_IsActiveRound) {
			RoundExperienceMultiplier[client] = 0.0;
			BonusContainer[client] = 0;
		}
		HealImmunity[client] = false;
		b_IsLoading[client] = false;
		bIsTalentTwo[client] = false;

		resr[client] = 1;
		WipeDebuffs(_, client, true);
		bIsDisconnecting[client] = true;
	}
	else resr[client] = 0;

	b_IsDirectorTalents[client] = false;

	if (IsLoadingData) {
		LogMessage("Client is loading Data, cannot save. %N", client);
		return;
	}
	//bSaveData[client] = true;

	char tquery[1024];
	char key[512];
	char text[512];
	//decl String:text2[512];
	int talentlevel = 0;

	PreviousRoundIncaps[client] = RoundIncaps[client];

	int size = GetArraySize(a_Database_Talents);

	char thesp[64];
	char TheName[64];
	//decl String:Name[64];
	GetConfigValue(thesp, sizeof(thesp), "sky points menu name?");

	if (IsFakeClient(client)) {

		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
	}
	else {

		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
		if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
	}
	/*if (PlayerUpgradesTotal[client] == 0 && FreeUpgrades[client] == 0 && PlayerLevel[client] <= 1) {

		Format(tquery, sizeof(tquery), "DELETE FROM `%s` WHERE `steam_id` = '%s';", TheDBPrefix, key);
		SQL_TQuery(hDatabase, QueryResults, tquery, client);
		bSaveData[client] = false;
		return;
	}*/
	if (PlayerLevel[client] < iPlayerStartingLevel) return;
	PrintToChat(client, "\x04saving data...\nrefrain from turning off the power or resetting...");

	char sPoints[64];
	Format(sPoints, sizeof(sPoints), "%3.3f", Points[client]);

	//if (PlayerLevel[client] < 1) return;		// Clearly, their data hasn't loaded, so we don't save.
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `exp` = '%d', `expov` = '%d', `upgrade cost` = '%d', `level` = '%d', `%s` = '%d', `time played` = '%d', `talent points` = '%d', `total upgrades` = '%d', `free upgrades` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, ExperienceLevel[client], ExperienceOverall[client], PlayerLevelUpgrades[client], PlayerLevel[client], thesp, SkyPoints[client], TimePlayed[client], TotalTalentPoints[client], PlayerUpgradesTotal[client], FreeUpgrades[client], key);
	SQL_TQuery(hDatabase, QueryResults1, tquery, client);
	
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `upav` = '%d', `upawarded` = '%d', `lvlpaused` = '%d', `itrails` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, UpgradesAvailable[client], UpgradesAwarded[client], iIsLevelingPaused[client], iIsBulletTrails[client], key);
	SQL_TQuery(hDatabase, QueryResults2, tquery, client);

	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `pistol_xp` = '%d', `melee_xp` = '%d', `uzi_xp` = '%d', `shotgun_xp` = '%d', `sniper_xp` = '%d', `assault_xp` = '%d', `medic_xp` = '%d', `grenade_xp` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, pistolXP[client], meleeXP[client], uziXP[client], shotgunXP[client], sniperXP[client], assaultXP[client], medicXP[client], grenadeXP[client], key);
	SQL_TQuery(hDatabase, QueryResults3, tquery, client);

	char bonusMult[64];
	Format(bonusMult, sizeof(bonusMult), "%3.3f", RoundExperienceMultiplier[client]);

	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `myseason` = '%s', `rem` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, RatingType, bonusMult, key);
	SQL_TQuery(hDatabase, QueryResults1, tquery, client);

	SQL_EscapeString(hDatabase, Hostname, text, sizeof(text));
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `lastserver` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, text, key);
	SQL_TQuery(hDatabase, QueryResults1, tquery, client);

	char TagName[64];
	Format(TagName, sizeof(TagName), "%s", baseName[client]);
	SQL_EscapeString(hDatabase, TagName, TagName, sizeof(TagName));
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `skylevel` = '%d', `tname` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, SkyLevel[client], TagName, key);
	SQL_TQuery(hDatabase, QueryResults1, tquery, client);
	//if (!IsFakeClient(client)) LogMessage(tquery);

	if (Rating[client] > BestRating[client]) BestRating[client] = Rating[client];
	int minimumRating = RoundToCeil(BestRating[client] * fRatingFloor);
	if (Rating[client] < minimumRating) Rating[client] = minimumRating;

	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `restt` = '%d', `restexp` = '%d', `lpl` = '%d', `resr` = '%d', `pri` = '%d', `survpoints` = '%s', `bec` = '%d', `%s` = '%d', `myrating %s` = '%d', `handicaplevel %s` = '%d', `augmentparts` = '%d', `dismantlescore` = '%d', `dismantleminor` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, GetTime(), RestedExperience[client], LastPlayLength[client], resr[client], PreviousRoundIncaps[client], sPoints, BonusContainer[client], RatingType, BestRating[client], RatingType, Rating[client], RatingType, handicapLevel[client], augmentParts[client], iplayerSettingAutoDismantleScore[client], iplayerDismantleMinorAugments[client], key);
	SQL_TQuery(hDatabase, QueryResults4, tquery, client);

	for (int i = 0; i < size; i++) {
		//TalentTreeKeys[client]			= GetArrayCell(a_Menu_Talents, i, 0);
		TalentTreeValues[client]		= GetArrayCell(a_Menu_Talents, i, 1);
		if (GetArrayCell(TalentTreeValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue;
		//if (GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "is survivor class role?") == 1) continue;	// class roles aren't stored in the database in the same way that talents/CARTEL are.
		GetArrayString(a_Database_Talents, i, text, sizeof(text));
		talentlevel = GetArrayCell(a_Database_PlayerTalents[client], i);// GetArrayString(a_Database_PlayerTalents[client], i, text2, sizeof(text2));
		// if (GetKeyValueInt(TalentTreeKeys[client], TalentTreeValues[client], "talent type?") == 1) {

		// 	talentexperience = GetArrayCell(a_Database_PlayerTalents_Experience[client], i);
		// 	//GetArrayString(a_Database_PlayerTalents_Experience[client], i, text3, sizeof(text3));
		
		// 	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `%s` = '%d', `%s xp` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, text, talentlevel, text, talentexperience, key);
		// 	SQL_TQuery(hDatabase, QueryResults5, tquery, client);
		// }
		// else {
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `%s` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, text, talentlevel, key);
		SQL_TQuery(hDatabase, QueryResults6, tquery, client);
		//}
	}
	int ActionSlotSize = iActionBarSlots;
	if (GetArraySize(ActionBar[client]) != ActionSlotSize) ResizeArray(ActionBar[client], ActionSlotSize);
	char ActionBarText[64];
	for (int i = 0; i < ActionSlotSize; i++) {	// isnt looping?

		GetArrayString(ActionBar[client], i, ActionBarText, sizeof(ActionBarText));
		//if (StrEqual(ActionBarText, "none")) continue;
		if (!IsAbilityTalent(client, ActionBarText) && (!IsTalentExists(ActionBarText) || GetTalentStrength(client, ActionBarText) < 1)) Format(ActionBarText, sizeof(ActionBarText), "none");
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `aslot%d` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, i+1, ActionBarText, key);
		SQL_TQuery(hDatabase, QueryResults, tquery);
	}
	if (!IsFakeClient(client)) {
		int numAugmentsClientOwns = GetArraySize(myAugmentIDCodes[client]);
		for (int i = 0; i < numAugmentsClientOwns; i++) {
			char itemCode[64];
			GetArrayString(myAugmentIDCodes[client], i, itemCode, 64);
			int itemCost = GetArrayCell(myAugmentInfo[client], i, 1);
			int bSelling = GetArrayCell(myAugmentInfo[client], i, 2);
			int equipped = GetArrayCell(myAugmentInfo[client], i, 3);

			Format(tquery, sizeof(tquery), "UPDATE `%s_loot` SET `price` = '%d', `steam_id` = '%s', `isequipped` = '%d', `isforsale` = '%d' WHERE (`itemid` = '%s');", TheDBPrefix, itemCost, key, equipped, bSelling, itemCode);
			SQL_TQuery(hDatabase, QueryResults, tquery);
		}
	}
	int isDisab = 0;
	if (DisplayActionBar[client]) isDisab = 1;
	Format(tquery, sizeof(tquery), "UPDATE `%s` SET `disab` = '%d' WHERE (`steam_id` = '%s');", TheDBPrefix, isDisab, key);
	SQL_TQuery(hDatabase, QueryResults, tquery);
	if (GetClientTeam(client) == TEAM_SURVIVOR) {
		if (GetArraySize(hWeaponList[client]) < 2) {
			ResizeArray(hWeaponList[client], 2);
			int wepid = GetPlayerWeaponSlot(client, 0);
			if (IsValidEntity(wepid)) {
				GetEntityClassname(wepid, text, sizeof(text));
				SetArrayString(hWeaponList[client], 0, text);
			}
			else Format(text, sizeof(text), "%s", defaultLoadoutWeaponPrimary);
			Format(tquery, sizeof(tquery), "UPDATE `%s` SET `primarywep` = '%s'", TheDBPrefix, text);

			GetMeleeWeapon(client, text, sizeof(text));
			if (StrEqual(text, "null")) {	// if the secondary is not a melee weapon
				wepid = GetPlayerWeaponSlot(client, 1);
				if (IsValidEntity(wepid)) GetEntityClassname(wepid, text, sizeof(text));
				else Format(text, sizeof(text), "%s", defaultLoadoutWeaponSecondary);
			}
			SetArrayString(hWeaponList[client], 1, text);
			Format(tquery, sizeof(tquery), "%s, `secondwep` = '%s' WHERE (`steam_id` = '%s');", tquery, text, key);
		}
		else {
			GetArrayString(hWeaponList[client], 0, text, sizeof(text));
			Format(tquery, sizeof(tquery), "UPDATE `%s` SET `primarywep` = '%s'", TheDBPrefix, text);

			GetArrayString(hWeaponList[client], 1, text, sizeof(text));
			Format(tquery, sizeof(tquery), "%s, `secondwep` = '%s' WHERE (`steam_id` = '%s');", tquery, text, key);
		}
		SQL_TQuery(hDatabase, QueryResults, tquery);
	}
	if (b_IsTrueDisconnect) {
		SetClientInfo(client, "name", baseName[client]);
		Format(baseName[client], sizeof(baseName[]), "[RPG DISCO]");
		Format(ProfileLoadQueue[client], sizeof(ProfileLoadQueue[]), "none");
		Format(BuildingStack[client], sizeof(BuildingStack[]), "none");
		Format(LoadoutName[client], sizeof(LoadoutName[]), "none");

		ClearEquippedAugmentData(client);
		ClearLocalClientAugmentData(client);
	}

	/*size				=	GetArraySize(a_Store);

	for (new i = 0; i < size; i++) {

		SaveSection[client]			=	GetArrayCell(a_Store, i, 2);
		GetArrayString(Handle:SaveSection[client], 0, text, sizeof(text));
		GetArrayString(a_Store_Player[client], i, text2, sizeof(text2));
		Format(tquery, sizeof(tquery), "UPDATE `%s` SET `%s` = '%s' WHERE (`steam_id` = '%s');", TheDBPrefix, text, text2, key);
		SQL_TQuery(hDatabase, QueryResults7, tquery, client);
	}*/
	if (IsNewPlayer) {
		CreateTimer(1.0, Timer_LoadNewPlayer, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action Timer_LoadNewPlayer(Handle timer, any client) {
	if (!IsLegitimateClient(client)) return Plugin_Stop;
	if (forceProfileOnNewPlayers != 1) b_IsLoading[client] = false;
	else {
		b_IsLoading[client] = true;
		LoadTarget[client] = -1;
		if (IsFakeClient(client) && GetClientTeam(client) == TEAM_SURVIVOR && !StrEqual(DefaultBotProfileName, "-1")) LoadProfileEx(client, DefaultBotProfileName);
		else if (GetClientTeam(client) == TEAM_INFECTED && !StrEqual(DefaultInfectedProfileName, "-1")) LoadProfileEx(client, DefaultInfectedProfileName);
		else if (GetClientTeam(client) == TEAM_SURVIVOR && !StrEqual(DefaultProfileName, "-1")) LoadProfileEx(client, DefaultProfileName);
		else b_IsLoading[client] = false;
	}
	if (b_IsLoading[client]) LogMessage("Loading profile for new player %N", client);
	return Plugin_Stop;
}

stock LoadDirectorActions() {

	if (hDatabase == INVALID_HANDLE) return;
	char key[64];
	char section_t[64];
	char tquery[1024];
	GetConfigValue(key, sizeof(key), "director steam id?");
	LoadPos_Director = 0;

	LoadDirectorSection					=	GetArrayCell(a_DirectorActions, LoadPos_Director, 2);
	GetArrayString(LoadDirectorSection, 0, section_t, sizeof(section_t));

	//decl String:thevalue[64];
	//GetConfigValue(thevalue, sizeof(thevalue), "database prefix?");

	Format(tquery, sizeof(tquery), "SELECT `%s` FROM `%s` WHERE (`steam_id` = '%s');", section_t, TheDBPrefix, key);
	//LogMessage("Loading Director Priorities: %s", tquery);
	SQL_TQuery(hDatabase, QueryResults_LoadDirector, tquery, -1);
}

public void QueryResults_LoadDirector(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl != INVALID_HANDLE) {

		char text[64];
		char key[64];
		char key_t[64];
		char value_t[64];
		char section_t[64];
		char tquery[1024];

		bool NoLoad						=	false;

		GetConfigValue(key, sizeof(key), "director steam id?");
		//decl String:dbpref[64];
		//GetConfigValue(dbpref, sizeof(dbpref), "database prefix?");
		int size = 0;

		while (SQL_FetchRow(hndl)) {

			SQL_FetchString(hndl, 0, text, sizeof(text));

			if (StrEqual(text, "0")) NoLoad = true;
			if (LoadPos_Director < GetArraySize(a_DirectorActions)) {

				QueryDirectorSection						=	GetArrayCell(a_DirectorActions, LoadPos_Director, 2);
				GetArrayString(QueryDirectorSection, 0, section_t, sizeof(section_t));

				QueryDirectorKeys							=	GetArrayCell(a_DirectorActions, LoadPos_Director, 0);
				QueryDirectorValues							=	GetArrayCell(a_DirectorActions, LoadPos_Director, 1);

				size							=	GetArraySize(QueryDirectorKeys);

				for (int i = 0; i < size && !NoLoad; i++) {

					GetArrayString(QueryDirectorKeys, i, key_t, sizeof(key_t));
					GetArrayString(QueryDirectorValues, i, value_t, sizeof(value_t));

					if (StrEqual(key_t, "priority?")) {

						SetArrayString(QueryDirectorValues, i, text);
						SetArrayCell(a_DirectorActions, LoadPos_Director, QueryDirectorValues, 1);
						break;
					}
				}
				LoadPos_Director++;
				if (LoadPos_Director < GetArraySize(a_DirectorActions) && !NoLoad) {

					QueryDirectorSection						=	GetArrayCell(a_DirectorActions, LoadPos_Director, 2);
					GetArrayString(QueryDirectorSection, 0, section_t, sizeof(section_t));

					Format(tquery, sizeof(tquery), "SELECT `%s` FROM `%s` WHERE (`steam_id` = '%s');", section_t, TheDBPrefix, key);
					SQL_TQuery(hDatabase, QueryResults_LoadDirector, tquery, -1);
				}
				else if (NoLoad) FirstUserDirectorPriority();
			}
		}
	}
}

stock FirstUserDirectorPriority() {

	int size						=	GetArraySize(a_Points);

	int sizer						=	0;

	char s_key[64];
	char s_value[64];

	for (int i = 0; i < size; i++) {

		FirstDirectorKeys						=	GetArrayCell(a_Points, i, 0);
		FirstDirectorValues						=	GetArrayCell(a_Points, i, 1);
		FirstDirectorSection					=	GetArrayCell(a_Points, i, 2);

		int size2					=	GetArraySize(FirstDirectorKeys);
		for (int ii = 0; ii < size2; ii++) {

			GetArrayString(FirstDirectorKeys, ii, s_key, sizeof(s_key));
			GetArrayString(FirstDirectorValues, ii, s_value, sizeof(s_value));

			if (StrEqual(s_key, "model?")) PrecacheModel(s_value, false);
			else if (StrEqual(s_key, "director option?") && StrEqual(s_value, "1")) {

				sizer				=	GetArraySize(a_DirectorActions);

				ResizeArray(a_DirectorActions, sizer + 1);
				SetArrayCell(a_DirectorActions, sizer, FirstDirectorKeys, 0);
				SetArrayCell(a_DirectorActions, sizer, FirstDirectorValues, 1);
				SetArrayCell(a_DirectorActions, sizer, FirstDirectorSection, 2);

				ResizeArray(a_DirectorActions_Cooldown, sizer + 1);
				SetArrayString(a_DirectorActions_Cooldown, sizer, "0");						// 0 means not on cooldown. 1 means on cooldown. This resets every map.
			}
		}
	}
}

stock FindClientByIdNumber(searchId) {
	char AuthId[64];
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i)) continue;
		GetClientAuthId(i, AuthId_Steam2, AuthId, sizeof(AuthId));
		if (searchId == StringToInt(AuthId[10])) return i;
	}
	return -1;
}

stock FindClientWithAuthString(char[] key, bool MustBeExact = false) {

	char AuthId[512];
	char TheName[64];
	for (int i = 1; i <= MaxClients; i++) {

		if (IsLegitimateClient(i)) {

			if (IsFakeClient(i)) {

				GetSurvivorBotName(i, TheName, sizeof(TheName));
				Format(AuthId, sizeof(AuthId), "%s%s", sBotTeam, TheName);
			}
			else {

				GetClientAuthId(i, AuthId_Steam2, AuthId, sizeof(AuthId));
				if (!StrEqual(serverKey, "-1")) Format(AuthId, sizeof(AuthId), "%s%s", serverKey, AuthId);
			}
			if (MustBeExact && StrEqual(key, AuthId, false) || !MustBeExact && StrContains(key, AuthId, false) != -1) return i;
		}
	}
	return -1;
}

stock bool IsReserve(client) {

	char thevalue[64];
	GetConfigValue(thevalue, sizeof(thevalue), "donator package flag?");

	if (IsGroupMember[client] || HasCommandAccess(client, thevalue)) return true;
	return false;
}

stock bool HasCommandAccess(client, char[] accessflags) {

	char flagpos[2];

	// We loop through the access flags passed to this function to see if the player has any of them and return the result.
	// This means flexibility for anything in RPG that allows custom flags, such as reserve player access or director menu access.
	for (int i = 0; i < strlen(accessflags); i++) {

		flagpos[0] = accessflags[i];
		flagpos[1] = 0;
		if (HasCommandAccessEx(client, flagpos)) return true;
	}
	// Old Method -> if (HasCommandAccess(client, "z") || HasCommandAccess(client, "a")) return true;
	return false;
}

public ReadProfiles_Generate(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl != INVALID_HANDLE) {

		char text[128];
		char result[2][128];
		char VersionNumber[64];
		Format(VersionNumber, sizeof(VersionNumber), "SavedProfile%s", PROFILE_VERSION);

		while (SQL_FetchRow(hndl)) {

			SQL_FetchString(hndl, 0, text, sizeof(text));
			ExplodeString(text, "+", result, 2, 128);
			if (strlen(result[1]) >= 8 && StrContains(text, VersionNumber, true) != -1) {

				PushArrayString(PlayerProfiles[client], text);
			}
			if (SQL_MoreRows(hndl)) SQL_FetchMoreResults(hndl);
		}
		ReadProfilesEx(client);
	}
}

public ReadProfiles_GenerateAll(Handle owner, Handle hndl, const char[] error, any client) {

	if (hndl != INVALID_HANDLE) {

		char text[128];
		char result[2][128];
		char VersionNumber[64];
		Format(VersionNumber, sizeof(VersionNumber), "SavedProfile%s", PROFILE_VERSION);

		while (SQL_FetchRow(hndl)) {

			SQL_FetchString(hndl, 0, text, sizeof(text));
			ExplodeString(text, "+", result, 2, 128);
			if (StrContains(text, "default", false) == -1 && strlen(result[1]) >= 8 && StrContains(text, VersionNumber, true) != -1) {

				PushArrayString(PlayerProfiles[client], text);
			}
			if (SQL_MoreRows(hndl)) SQL_FetchMoreResults(hndl);
		}
		ReadProfilesEx(client);
	}
}

public void QueryResults_Load(Handle owner, Handle hndl, const char[] error, any client) {
	if ( hndl != INVALID_HANDLE ) {
		char key[64];
		char text[64];
		//decl String:tquery[512];
		char t_Hostname[64];
		char CurrentSeason[64];
		int RestedTime		= 0;
		int iLevel = 0;
		//decl String:t_Class[64];
		if (!IsLegitimateClient(client)) {
			if (client > 0) b_IsLoading[client] = false;
			return;
		}

		while (SQL_FetchRow(hndl)) {
			SQL_FetchString(hndl, 0, key, sizeof(key));
			//client = FindClientWithAuthString(key, true);
			if (client == -1) return;
			ExperienceLevel[client]		=	SQL_FetchInt(hndl, 1);
			ExperienceOverall[client]	=	SQL_FetchInt(hndl, 2);
			PlayerLevelUpgrades[client]	=	SQL_FetchInt(hndl, 3);
			PlayerLevel[client]			=	SQL_FetchInt(hndl, 4);
			SkyLevel[client]			=	SQL_FetchInt(hndl, 5);
			SkyPoints[client]			=	SQL_FetchInt(hndl, 6);
			TimePlayed[client]			=	SQL_FetchInt(hndl, 7);
			TotalTalentPoints[client]	=	SQL_FetchInt(hndl, 8);
			PlayerUpgradesTotal[client]	=	SQL_FetchInt(hndl, 9);
			FreeUpgrades[client]		=	SQL_FetchInt(hndl, 10);
			RestedTime					=	SQL_FetchInt(hndl, 11);
			RestedExperience[client]	=	SQL_FetchInt(hndl, 12);
			LastPlayLength[client]		=	SQL_FetchInt(hndl, 13);
			resr[client]				=	SQL_FetchInt(hndl, 14);
			SQL_FetchString(hndl, 15, text, sizeof(text));
			Points[client] = StringToFloat(text);
			BonusContainer[client] = SQL_FetchInt(hndl, 16);
			SQL_FetchString(hndl, 17, text, sizeof(text));
			RoundExperienceMultiplier[client] = StringToFloat(text);
			PreviousRoundIncaps[client]	=	SQL_FetchInt(hndl, 18);
			ExperienceDebt[client]		=	SQL_FetchInt(hndl, 19);
			UpgradesAvailable[client]	=	SQL_FetchInt(hndl, 20);
			UpgradesAwarded[client]		=	SQL_FetchInt(hndl, 21);
			BestRating[client] =	SQL_FetchInt(hndl, 22);
			Rating[client] = SQL_FetchInt(hndl, 23);
			handicapLevel[client] = SQL_FetchInt(hndl, 24);
			SQL_FetchString(hndl, 25, t_Hostname, sizeof(t_Hostname));
			SQL_FetchString(hndl, 26, CurrentSeason, sizeof(CurrentSeason));
			iIsLevelingPaused[client]	= SQL_FetchInt(hndl, 27);
			iIsBulletTrails[client]		= SQL_FetchInt(hndl, 28);
			pistolXP[client] = SQL_FetchInt(hndl, 29);
			meleeXP[client] = SQL_FetchInt(hndl, 30);
			uziXP[client] = SQL_FetchInt(hndl, 31);
			shotgunXP[client] = SQL_FetchInt(hndl, 32);
			sniperXP[client] = SQL_FetchInt(hndl, 33);
			assaultXP[client] = SQL_FetchInt(hndl, 34);
			medicXP[client] = SQL_FetchInt(hndl, 35);
			grenadeXP[client] = SQL_FetchInt(hndl, 36);
			augmentParts[client] = SQL_FetchInt(hndl, 37);
			iplayerSettingAutoDismantleScore[client] = SQL_FetchInt(hndl, 38);
			iplayerDismantleMinorAugments[client] = SQL_FetchInt(hndl, 39);
		}
		LogMessage("%N has finished loading.", client);
		if (PlayerLevel[client] > 0) {
			if (CurrentMapPosition == 0) {
				BonusContainer[client] = 0;
				RoundExperienceMultiplier[client] = 0.0;
				Points[client] = 0.0;
				LogMessage("%N Bonus multiplier is reset.", client);
			}
			if (Rating[client] < 0) Rating[client] = 0;
			if (!CheckServerLevelRequirements(client)) {
				b_IsLoading[client] = false;
				bIsTalentTwo[client] = false;
				ResetData(client);
				return;	// client was kicked.
			}
			// Set player level in accordance with the server experience requirements. Level is set dynamically.
			// This means you could have a different level on different servers with the same total earned experience.
			iLevel = GetPlayerLevel(client);
			if (SkyLevel[client] < 1 && iLevel < iPlayerStartingLevel) iLevel = iPlayerStartingLevel;
			PlayerLevel[client] = iLevel;
			// If the player has loaded a profile that is too high of a level for the server.
			if (IsProfileLevelTooHigh(client)) {
				b_IsLoading[client] = false;
				bIsTalentTwo[client] = false;
				ChallengeEverything(client);
				return;
			}
			if (!IsFakeClient(client)) AwardExperience(client, -1);
			//	"experience start?" can be modified at any time in the config.
			//	In order to properly adjust player levels, we use this to check.

			if (resr[client] == 1) {	// they're loading in after previous leaving so does not accrue for a player whose disconnect is not from leaving (re: map changes)

				if (RestedTime > 0) {

					RestedTime					=	GetTime() - RestedTime;
					if (RestedTime > LastPlayLength[client]) RestedTime = LastPlayLength[client];

					while (RestedTime >= iRestedSecondsRequired) {

						RestedTime -= iRestedSecondsRequired;
						if (IsGroupMember[client]) RestedExperience[client] += iRestedDonator;
						else RestedExperience[client] += iRestedRegular;
					}
					int RestedExperienceMaximum = iRestedMaximum;
					if (RestedExperienceMaximum < 1) RestedExperienceMaximum = CheckExperienceRequirement(client);
					if (RestedExperience[client] > RestedExperienceMaximum) {

						RestedExperience[client] = RestedExperienceMaximum;
					}
				}
				LastPlayLength[client] = 0;
				Points[client] = 0.0;
			}
			else {		// Player did not leave the match - so a map transition occurred.

				if (iFriendlyFire == 1 || IsPvP[client] != 0) {

					PrintToChat(client, "%T", "PvP Enabled", client, white, blue);
				}
				//if (PlayerLevel[client] != iLevel) SetTotalExperienceByLevel(client, iLevel);
			}
			SetClientHandicapValues(client);
			SetSpeedMultiplierBase(client);
			LoadPos[client] = 0;
			b_IsLoadingTrees[client] = false;
			LoadTalentTrees(client, key);
		}
		else {
			ResetData(client);
			b_IsLoading[client] = false;
			CreateNewPlayer(client);
		}
		if (iRPGMode < 1) {
			b_IsLoading[client] = false;
			bIsTalentTwo[client] = false;
			//VerifyAllActionBars(client);
		}
		//if (b_IsLoading[client] && !IsFakeClient(client)) CheckServerLevelRequirements(client);
		/*b_IsLoading[client] = false;
		bIsTalentTwo[client] = false;
		VerifyAllActionBars(client);*/
		//if (!bFound && IsLegitimateClient(client)) {
	}
	else
	{
		//decl String:err[64];
		//GetConfigValue(err, sizeof(err), "database prefix?");
		//SetFailState("Error: %s PREFIX IS: %s", error, TheDBPrefix);
		b_IsLoading[client] = false;
		return;
	}
}

/*stock bool:IsClassLoading(String:key[]) {

	decl String:text[64];
	new size = GetArraySize(a_ClassNames);
	for (new i = 0; i < size; i++) {

		GetArrayString(a_ClassNames, i, text, sizeof(text));
		if (StrContains(key, text, false) != -1) return true;
	}
	return false;
}*/

public void QueryResults_LoadTalentTrees(Handle owner, Handle hndl, const char[] error, any client) {
	if (hndl == null) {
		LogMessage("QueryResults_LoadTalentTrees is null!");
		return;
	}
	char text[512];
	char tquery[1024];

	//decl String:newplay[64];
	//GetConfigValue(newplay, sizeof(newplay), "new player profile?");

	//TalentTreeKeys[client]			= GetArrayCell(a_Menu_Talents, LoadPos[client], 0);
	//TalentTreeValues[client]		= GetArrayCell(a_Menu_Talents, LoadPos[client], 1);

	int talentlevel = 0;
	char key[512];
	char TheName[64];
	//new iLevel			= 0;
	if (client == -1 || !IsLegitimateClient(client) || IsLegitimateClient(client) && GetClientTeam(client) != TEAM_SURVIVOR && IsFakeClient(client)) {
		if (IsLegitimateClient(client)) {
			bIsTalentTwo[client] = false;
			b_IsLoading[client] = false;
		}
		return;
	}
	if (IsFakeClient(client)) {
		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
	}
	else {
		GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
		if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
	}
	int size = GetArraySize(a_Database_Talents);
	if (GetArraySize(a_Database_PlayerTalents[client]) != size) {
		ResizeArray(a_Database_PlayerTalents[client], size);
		ResizeArray(a_Database_PlayerTalents_Experience[client], size);
	}
	if (SQL_FetchRow(hndl)) {
		SQL_FetchString(hndl, 0, key, sizeof(key));
		//if (!IsClassLoading(key)) client = FindClientWithAuthString(key, true);
		//else client = FindClientWithAuthString(key);
		if (LoadPos[client] < size) {

			talentlevel = SQL_FetchInt(hndl, 1);
			if (talentlevel == 1) {
				// The player has a point in this talent, so we push it onto the loot pool.
				PushArrayCell(possibleLootPool[client], LoadPos[client]);
			}
			//if (bIsTalentTwo[client]) PrintToChat(client, "talent level %d", talentlevel);
			if (talentlevel < 0) talentlevel = 0;
			SetArrayCell(a_Database_PlayerTalents[client], LoadPos[client], talentlevel);
			SetArrayCell(a_Database_PlayerTalents_Experience[client], LoadPos[client], 0);		// overwritten by actual value if
			LoadPos[client]++;	// otherwise it'll just loop the same request
		}
	}
	//else LoadPos[client]++;
	for (int i = LoadPos[client]; i < size; i++) {
		TalentTreeValues[client]		= GetArrayCell(a_Menu_Talents, i, 1);
		if (GetArrayCell(TalentTreeValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue; //||
		LoadPos[client] = i;
		break;
	}
	if (LoadPos[client] < size) {
		GetArrayString(a_Database_Talents, LoadPos[client], text, sizeof(text));
		Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s` FROM `%s` WHERE (`steam_id` = '%s');", text, TheDBPrefix, key);
		//LogMessage("%d / %d pos, %s", LoadPos[client], size, tquery);
		SQL_TQuery(hDatabase, QueryResults_LoadTalentTrees, tquery, client);

		return;
	}
	b_IsLoadingTrees[client] = false;
	LoadStoreData(client, key);
	LoadPos[client] = 0;
	LoadTalentTrees(client, key, true);

	CreateTimer(1.0, Timer_LoggedUsers, client, TIMER_FLAG_NO_MAPCHANGE);
}

stock void LoadTalentTrees(client, char[] key, bool IsTalentTwo = false, char[] profilekey = "none") {

	//client = FindClientWithAuthString(key, true);
	if (!IsLegitimateClient(client) || b_IsLoadingTrees[client]) return;

	b_IsLoadingTrees[client] = true;
	int size = GetArraySize(a_Menu_Talents);
	int theresult = 0;

	if (!IsTalentTwo) bIsTalentTwo[client] = false;
	else bIsTalentTwo[client] = true;

	char text[64];
	char tquery[1024];
	//decl String:key[64];
	GetClientAuthId(client, AuthId_Steam2, key, 64);
	if (!StrEqual(serverKey, "-1")) Format(key, 64, "%s%s", serverKey, key);

	if (!IsTalentTwo) {
		for (int i = LoadPos[client]; i < size; i++) {
			TalentTreeValues[client]		= GetArrayCell(a_Menu_Talents, i, 1);
			if (GetArrayCell(TalentTreeValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue;// ||
			LoadPos[client] = i;
			break;
		}
		if (LoadPos[client] < size) {
			GetArrayString(a_Database_Talents, LoadPos[client], text, sizeof(text));
			// !bIsTalentTwo[client]
			if (!IsTalentTwo) Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s` FROM `%s` WHERE (`steam_id` = '%s');", text, TheDBPrefix, key);
			else Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s`, `%s xp` FROM `%s` WHERE (`steam_id` = '%s');", text, text, TheDBPrefix, key);
			//LogMessage("%d / %d pos, %s", LoadPos[client], size, tquery);
			//PrintToChat(client, "FULL STOP %s", tquery);
			SQL_TQuery(hDatabase, QueryResults_LoadTalentTrees, tquery, client);
		}
	}
	else {
		SurvivorStamina[client] = GetPlayerStamina(client);
		int ActionSlots = iActionBarSlots;
		Format(tquery, sizeof(tquery), "SELECT `steam_id`");
		for (int i = 0; i < ActionSlots; i++) {
			Format(tquery, sizeof(tquery), "%s, `aslot%d`", tquery, i+1);
		}
		Format(tquery, sizeof(tquery), "%s, `disab`, `primarywep`, `secondwep`", tquery);

		if (StrEqual(profilekey, "none")) Format(tquery, sizeof(tquery), "%s FROM `%s` WHERE (`steam_id` = '%s');", tquery, TheDBPrefix, key);
		else Format(tquery, sizeof(tquery), "%s FROM `%s` WHERE (`steam_id` = '%s');", tquery, TheDBPrefix, profilekey);
		SQL_TQuery(hDatabase, QueryResults_LoadActionBar, tquery, client);
		LoadClientAugments(client);
		LoadPos[client] = 0;
	}
	return;
}

stock void LoadClientAugments(client) {
	char key[64];
	char tquery[512];
	GetClientAuthId(client, AuthId_Steam2, key, 64);
	if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
	Format(tquery, sizeof(tquery), "SELECT `steam_id`, `itemid`, `rating`, `category`, `price`, `isforsale`, `isequipped`, `acteffects`, `actrating`, `tareffects`, `tarrating` FROM `%s_loot` WHERE (`steam_id` = '%s');", TheDBPrefix, key);
	SQL_TQuery(hDatabase, QueryResults_LoadAugments, tquery, client);
}

stock void ClearLocalClientAugmentData(client) {
	ClearArray(myAugmentIDCodes[client]);
	ClearArray(myAugmentCategories[client]);
	ClearArray(myAugmentOwners[client]);
	ClearArray(myAugmentInfo[client]);
	ClearArray(myAugmentActivatorEffects[client]);
	ClearArray(myAugmentTargetEffects[client]);
}

stock ClearEquippedAugmentData(int client) {
	// clear
	ClearArray(equippedAugments[client]);
	ClearArray(equippedAugmentsCategory[client]);
	ClearArray(equippedAugmentsActivator[client]);
	ClearArray(equippedAugmentsTarget[client]);
	ClearArray(equippedAugmentsIDCodes[client]);
	// reset
	ResizeArray(equippedAugments[client], iNumAugments);
	ResizeArray(equippedAugmentsCategory[client], iNumAugments);
	ResizeArray(equippedAugmentsActivator[client], iNumAugments);
	ResizeArray(equippedAugmentsTarget[client], iNumAugments);
	ResizeArray(equippedAugmentsIDCodes[client], iNumAugments);
	// fill
	for (int i = 0; i < iNumAugments; i++) {
		SetArrayString(equippedAugmentsCategory[client], i, "none");
		SetArrayString(equippedAugmentsActivator[client], i, "none");
		SetArrayString(equippedAugmentsTarget[client], i, "none");
		SetArrayString(equippedAugmentsIDCodes[client], i, "none");
		SetArrayCell(equippedAugments[client], i, 0);
		SetArrayCell(equippedAugments[client], i, 0, 1);
		SetArrayCell(equippedAugments[client], i, 0, 2);
		SetArrayCell(equippedAugments[client], i, 0, 3);
		SetArrayCell(equippedAugments[client], i, 0, 4);
		SetArrayCell(equippedAugments[client], i, 0, 5);
	}
}

public void QueryResults_LoadAugments(Handle owner, Handle hndl, const char[] error, any client) {
	if (hndl != null) {
		char text[512];
		char key[64];

		if (client == -1 || !IsLegitimateClient(client) || IsLegitimateClient(client) && GetClientTeam(client) != TEAM_SURVIVOR && IsFakeClient(client)) return;
		ClearEquippedAugmentData(client);
		ClearLocalClientAugmentData(client);
		while (SQL_FetchRow(hndl)) {
			SQL_FetchString(hndl, 0, key, sizeof(key));
			int size = GetArraySize(myAugmentIDCodes[client]);
			ResizeArray(myAugmentIDCodes[client], size+1);
			ResizeArray(myAugmentCategories[client], size+1);
			ResizeArray(myAugmentOwners[client], size+1);
			ResizeArray(myAugmentInfo[client], size+1);
			ResizeArray(myAugmentTargetEffects[client], size+1);
			ResizeArray(myAugmentActivatorEffects[client], size+1);
			char itemCode[64];
			SQL_FetchString(hndl, 1, itemCode, 64);
			SetArrayString(myAugmentIDCodes[client], size, itemCode);
			int itemRating = SQL_FetchInt(hndl, 2);
			SetArrayCell(myAugmentInfo[client], size, itemRating);
			SQL_FetchString(hndl, 3, text, sizeof(text));
			SetArrayString(myAugmentCategories[client], size, text);
			int itemCost = SQL_FetchInt(hndl, 4);
			SetArrayCell(myAugmentInfo[client], size, itemCost, 1);
			SetArrayCell(myAugmentInfo[client], size, SQL_FetchInt(hndl, 5), 2);
			int isEquipped = SQL_FetchInt(hndl, 6);
			SetArrayCell(myAugmentInfo[client], size, isEquipped, 3);

			char activatorEffects[64];
			SQL_FetchString(hndl, 7, activatorEffects, 64);
			int activatorEffectRating = SQL_FetchInt(hndl, 8);
			SetArrayCell(myAugmentInfo[client], size, activatorEffectRating, 4);
			SetArrayString(myAugmentActivatorEffects[client], size, activatorEffects);

			char targetEffects[64];
			SQL_FetchString(hndl, 9, targetEffects, 64);
			int targetEffectRating = SQL_FetchInt(hndl, 10);
			SetArrayCell(myAugmentInfo[client], size, targetEffectRating, 5);
			SetArrayString(myAugmentTargetEffects[client], size, targetEffects);

			if (isEquipped >= 0) {
				SetArrayString(equippedAugmentsIDCodes[client], isEquipped, itemCode);
				SetArrayCell(equippedAugments[client], isEquipped, itemCost, 1);
				SetArrayCell(equippedAugments[client], isEquipped, itemRating, 2);
				SetArrayString(equippedAugmentsCategory[client], isEquipped, text);

				SetArrayString(equippedAugmentsActivator[client], isEquipped, activatorEffects);
				SetArrayCell(equippedAugments[client], isEquipped, activatorEffectRating, 4);

				SetArrayString(equippedAugmentsTarget[client], isEquipped, targetEffects);
				SetArrayCell(equippedAugments[client], isEquipped, targetEffectRating, 5);
			}
			
			//client = FindClientWithAuthString(key);
			//if (client == -1 || IsLegitimateClient(client) && GetClientTeam(client) != TEAM_SURVIVOR && IsFakeClient(client)) return;
		}
	}
	GiveProfileItems(client);
	SetClientTalentStrength(client);
	LogMessage("Loaded data for %N", client);
	PrintToChatAll("\x03%N's \x04data is \x03loaded.", client);
	//ChangeHook(client, true);

	// b_IsLoaded[client] = true;
	// b_IsLoading[client] = false;
	b_IsLoadingTrees[client] = false;
	bIsTalentTwo[client] = false;
	FreeUpgrades[client]		=	MaximumPlayerUpgrades(client) - TotalPointsAssigned(client);
	UpgradesAvailable[client]	=	0;
	VerifyClientUnlockedTalentEligibility(client);
	FormatPlayerName(client);
	SetMaximumHealth(client);
	GiveMaximumHealth(client);
	return;
}


public void QueryResults_LoadActionBar(Handle owner, Handle hndl, const char[] error, any client) {
	if (hndl == null) {
		LogMessage("QueryResults_LoadActionBar hndl not found.");
		return;
	}
	char text[512];
	char key[64];
	int IsDisab = 0;
	int ActionSlots = iActionBarSlots;
	// bool IsFound = false;

	if (client == -1 || !IsLegitimateClient(client) || IsLegitimateClient(client) && GetClientTeam(client) != TEAM_SURVIVOR && IsFakeClient(client)) return;
	if (GetArraySize(ActionBar[client]) != ActionSlots) ResizeArray(ActionBar[client], ActionSlots);

	if (GetArraySize(hWeaponList[client]) != 2) ResizeArray(hWeaponList[client], 2);
	while (SQL_FetchRow(hndl)) {
		SQL_FetchString(hndl, 0, key, sizeof(key));
		//client = FindClientWithAuthString(key);
		//if (client == -1 || IsLegitimateClient(client) && GetClientTeam(client) != TEAM_SURVIVOR && IsFakeClient(client)) return;
		for (int i = 0; i < ActionSlots; i++) {
			SQL_FetchString(hndl, i+1, text, sizeof(text));
			SetArrayString(ActionBar[client], i, text);
		}
		IsDisab = SQL_FetchInt(hndl, ActionSlots+1);
		if (IsDisab == 0) DisplayActionBar[client] = false;
		else DisplayActionBar[client] = true;

		SQL_FetchString(hndl, ActionSlots+2, text, sizeof(text));
		SetArrayString(hWeaponList[client], 0, text);
			
		SQL_FetchString(hndl, ActionSlots+3, text, sizeof(text));
		SetArrayString(hWeaponList[client], 1, text);
		// IsFound = true;
	}

	// if (IsFound) {
		// SetMaximumHealth(client);
		// GiveMaximumHealth(client);
		// LogMessage("Loaded data for %N", client);
		// PrintToChatAll("\x03%N's \x04data is \x03loaded.", client);
	// }
	// b_IsLoaded[client] = true;
	// b_IsLoading[client] = false;
	// b_IsLoadingTrees[client] = false;
	// bIsTalentTwo[client] = false;
	// FreeUpgrades[client]		=	MaximumPlayerUpgrades(client) - TotalPointsAssigned(client);
	// UpgradesAvailable[client]	=	0;
	// VerifyClientUnlockedTalentEligibility(client);
	// SetClientTalentStrength(client);
	// FormatPlayerName(client);
	// SetMaximumHealth(client);
	// GiveMaximumHealth(client);
	return;
}

stock SetClientTalentStrength(client, bool giveAccessToAllTalents = false) {
	b_IsLoaded[client] = false;
	b_IsLoading[client] = true;
	int ASize = GetArraySize(a_Menu_Talents);
	ResizeArray(MyTalentStrength[client], ASize);
	ResizeArray(MyTalentStrengths[client], ASize);
	char TalentName[64];
	for (int i = 0; i < ASize; i++) {
		PreloadTalentSection[client]	= GetArrayCell(a_Menu_Talents, i, 2);
		GetArrayString(PreloadTalentSection[client], 0, TalentName, sizeof(TalentName));
		if (!giveAccessToAllTalents && GetTalentStrength(client, TalentName) < 1) {
			SetArrayCell(MyTalentStrengths[client], i, 0.0);
			SetArrayCell(MyTalentStrengths[client], i, 0.0, 1);
			SetArrayCell(MyTalentStrengths[client], i, 0.0, 2);
			SetArrayCell(MyTalentStrength[client], i, 0);
			continue;
		}
		PreloadTalentValues[client]	= GetArrayCell(a_Menu_Talents, i, 1);
		float f_EachPoint	= GetTalentInfo(client, PreloadTalentValues[client], _, _, TalentName, _, 1, true);
		float f_Time		= GetTalentInfo(client, PreloadTalentValues[client], 2, _, TalentName, _, 1, true);
		float f_Cooldown	= GetTalentInfo(client, PreloadTalentValues[client], 3, _, TalentName, _, 1, true);
		SetArrayCell(MyTalentStrengths[client], i, f_EachPoint);
		SetArrayCell(MyTalentStrengths[client], i, f_Time, 1);
		SetArrayCell(MyTalentStrengths[client], i, f_Cooldown, 2);
		SetArrayCell(MyTalentStrength[client], i, 1);
	}
	int iCurrentAugmentLevel = 0;
	if (GetArraySize(equippedAugments[client]) != iNumAugments) ClearEquippedAugmentData(client);
	else {
		for (int i = 0; i < iNumAugments; i++) {
			int iCur = GetArrayCell(equippedAugments[client], i, 2);
			if (iCur > 0) iCurrentAugmentLevel += iCur;
		}
		playerCurrentAugmentLevel[client] = (iCurrentAugmentLevel / iAugmentLevelDivisor);
		SetLootDropCategories(client);
	}
	b_IsLoaded[client] = true;
	b_IsLoading[client] = false;
}

stock FormatPlayerName(client) {
	char playerNameFormatted[512];
	Format(playerNameFormatted, 512, "[%d] %s", PlayerLevel[client], baseName[client]);
	SetClientInfo(client, "name", playerNameFormatted);
}

public Action TextMsg(UserMsg msg_id, Handle bf, const players[], playersNum, bool reliable, bool init)
{
    BfReadByte(bf); // Skip first parameter
    BfReadByte(bf); // Skip second parameter

    char buffer[100];
    buffer[0] = '\0';
    BfReadString(bf, buffer, sizeof(buffer), false);


    // In Cs:s, look file ...orangebox\cstrike\resource\cstrike_english.txt, you found "Cstrike_Name_Change"
    if(StrContains(buffer, "_Name_Change") != -1)
    {
        return Plugin_Handled;
    }

    return Plugin_Continue;
} 

stock TotalPointsAssigned(client) {

	int count = 0;
	int MaxTalents = MaximumPlayerUpgrades(client);
	int currentValue = 0;
	//decl String:TalentName[64];

	int size = GetArraySize(a_Database_PlayerTalents[client]);
	for (int i = 0; i < size; i++) {

		//TalentsAssignedKeys[client]		= GetArrayCell(a_Menu_Talents, i, 0);
		TalentsAssignedValues[client]	= GetArrayCell(a_Menu_Talents, i, 1);

		if (GetArrayCell(TalentsAssignedValues[client], IS_TALENT_TYPE) == 1) continue;
		//if (GetKeyValueInt(TalentsAssignedKeys[client], TalentsAssignedValues[client], "is survivor class role?") == 1) continue;
		if (GetArrayCell(TalentsAssignedValues[client], IS_SUB_MENU_OF_TALENTCONFIG) == 1) continue;
		currentValue = GetArrayCell(a_Database_PlayerTalents[client], i);
		if (currentValue > 0) count += currentValue;
	}
	if (count > MaxTalents) ChallengeEverything(client);
	else return count;
	return 0;
}

stock LoadStoreData(client, char[] key) {

	/*client = FindClientWithAuthString(key, true);
	if (!IsLegitimateClient(client)) return;

	if (GetArraySize(a_Store_Player[client]) != GetArraySize(a_Store)) ResizeArray(a_Store_Player[client], GetArraySize(a_Store));

	decl String:text[64];
	decl String:tquery[1024];

	decl String:dbpref[64];
	GetConfigValue(dbpref, sizeof(dbpref), "database prefix?");
	//decl String:key[64];
	//GetClientAuthString(client, key, sizeof(key));

	b_IsLoadingStore[client] = true;
	LoadPosStore[client] = 0;

	LoadStoreSection[client]		=	GetArrayCell(a_Store, 0, 2);
	GetArrayString(Handle:LoadStoreSection[client], 0, text, sizeof(text));
	Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s` FROM `%s` WHERE (`steam_id` = '%s');", text, dbpref, key);
	SQL_TQuery(hDatabase, QueryResults_LoadStoreData, tquery, client);*/
}

/*public void QueryResults_LoadStoreData(Handle:owner, Handle:hndl, const String:error[], any:client) {

	if (hndl != INVALID_HANDLE) {

		decl String:text[512];
		decl String:tquery[1024];
		decl String:dbpref[64];
		decl String:key[64];
		GetConfigValue(dbpref, sizeof(dbpref), "database prefix?");

		while (SQL_FetchRow(hndl)) {

			SQL_FetchString(hndl, 0, key, sizeof(key));
			client = FindClientWithAuthString(key, true);
			if (!IsLegitimateClient(client)) return;

			if (LoadPosStore[client] == 0) {

				for (new i = 0; i < GetArraySize(a_Store); i++) {

					SetArrayString(a_Store_Player[client], i, "0");
				}
			}

			if (LoadPosStore[client] < GetArraySize(a_Store)) {

				SQL_FetchString(hndl, 1, text, sizeof(text));
				SetArrayString(a_Store_Player[client], LoadPosStore[client], text);

				LoadPosStore[client]++;
				if (LoadPosStore[client] < GetArraySize(a_Store)) {

					LoadStoreSection[client]		=	GetArrayCell(a_Store, LoadPosStore[client], 2);
					GetArrayString(Handle:LoadStoreSection[client], 0, text, sizeof(text));
					Format(tquery, sizeof(tquery), "SELECT `steam_id`, `%s` FROM `%s` WHERE (`steam_id` = '%s');", text, dbpref, key);
					SQL_TQuery(hDatabase, QueryResults_LoadStoreData, tquery, client);
				}
				else {

					b_IsLoadingStore[client] = false;
				}
			}
			else {

				b_IsLoadingStore[client] = false;
			}
		}
	}
	else {
		
		SetFailState("Error: %s", error);
		return;
	}
}*/

public OnClientDisconnect(client)
{
	if (IsClientInGame(client)) {
		// if (IsFakeClient(client)) {
		// 	//LogMessage("bot removed, setting to not loaded.");
		// 	b_IsLoaded[client] = false;
		// }

		if (ISEXPLODE[client] != INVALID_HANDLE) {

			KillTimer(ISEXPLODE[client]);
			ISEXPLODE[client] = INVALID_HANDLE;
		}
		fOnFireDebuff[client] = 0.0;
		IsGroupMemberTime[client] = 0;
		if (ZoomcheckDelayer[client] != INVALID_HANDLE) {
			KillTimer(ZoomcheckDelayer[client]);
			ZoomcheckDelayer[client] = INVALID_HANDLE;
		}
		ChangeHook(client);
		ClearArray(playerLootOnGround[client]);
		if(iChaseEnt[client] > 0 && IsValidEntity(iChaseEnt[client])) AcceptEntityInput(iChaseEnt[client], "Kill");
		iChaseEnt[client] = -1;
		iThreatLevel[client] = 0;
		bRushingNotified[client] = false;
		ClientActiveStance[client] = 0;
		b_IsLoadingTrees[client] = false;
		b_IsLoadingStore[client] = false;
		b_IsLoading[client] = false;
		bIsTalentTwo[client] = false;
		bTimersRunning[client] = false;
		bIsMeleeCooldown[client] = false;
		shotgunCooldown[client] = false;
		b_IsInSaferoom[client] = false;
		bIsInCheckpoint[client] = false;
		ResetData(client);
		Format(ProfileLoadQueue[client], sizeof(ProfileLoadQueue[]), "none");
		//Format(ClassLoadQueue[client], sizeof(ClassLoadQueue[]), "none");
		//IsGroupMember[client] = false;
		if (IsPlayerAlive(client) && eBackpack[client] > 0 && IsValidEntity(eBackpack[client])) {

			AcceptEntityInput(eBackpack[client], "Kill");
			eBackpack[client] = 0;
		}
		//ToggleTank(client, true);
	}
}

public ReadyUp_IsClientLoaded(client) {

	//ChangeHook(client, true);	// we re-hook new players to the server.
	HealingContribution[client] = 0;
	TankingContribution[client] = 0;
	DamageContribution[client] = 0;
	PointsContribution[client] = 0.0;
	HexingContribution[client] = 0;
	BuffingContribution[client] = 0;
	bTimersRunning[client] = false;
	ResetContributionTracker(client);
	RUP_IsClientLoaded(client);
	CheckDifficulty();
}

stock RUP_IsClientLoaded(client) {

	CreateTimer(1.0, Timer_InitializeClientLoad, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action Timer_InitializeClientLoad(Handle timer, any client) {
	if (!IsLegitimateClient(client)) return Plugin_Stop;
	//ChangeHook(client, true);
	float teleportIntoSaferoom[3];
	if (StrEqual(TheCurrentMap, "zerowarn_1r", false)) {
		teleportIntoSaferoom[0] = 4087.998291;
		teleportIntoSaferoom[1] = 11974.557617;
		teleportIntoSaferoom[2] = -300.968750;
		TeleportEntity(client, teleportIntoSaferoom, NULL_VECTOR, NULL_VECTOR);
	}
	if (!IsLoadingClientBaseNameDefault(client) && b_IsLoaded[client] && (IsFakeClient(client) || StrContains(baseName[client], "[BOT]", true) == -1)) {
		FormatPlayerName(client);
		SetMaximumHealth(client);
		GiveMaximumHealth(client);
		return Plugin_Stop;
	}
	ImmuneToAllDamage[client] = false;
	//ToggleTank(client, true);
	//ChangeHook(client);
	bTimersRunning[client] = false;
	b_IsInSaferoom[client] = true;
	bIsInCheckpoint[client] = false;
	eBackpack[client] = 0;
	ClientActiveStance[client] = 0;
	//bIsNewClass[client] = false;
	bIsNewPlayer[client] = false;
	IsPvP[client] = 0;
	b_IsLoadingTrees[client] = false;
	b_IsLoadingStore[client] = false;
	b_IsLoading[client] = false;
	bIsInCombat[client] = false;
	DisplayActionBar[client] = false;
	bRushingNotified[client] = false;
	MyBirthday[client] = 0;
	//IsLoadingClassData[client] = false;
	Format(ProfileLoadQueue[client], sizeof(ProfileLoadQueue[]), "none");
	//Format(ClassLoadQueue[client], sizeof(ClassLoadQueue[]), "none");
	ClearArray(InfectedHealth[client]);
	ResizeArray(ActionBar[client], iActionBarSlots);
	IsClientLoadedEx(client);
	return Plugin_Stop;
}

stock IsClientLoadedEx(client) {

	/*decl String:ClientName[64];
	GetClientName(client, ClientName, sizeof(ClientName));*/
	if (GetClientTeam(client) == TEAM_INFECTED && IsFakeClient(client)) return;	// only human players.
	//LogToFile(LogPathDirectory, "%N is loaded.", client);

	/*if (!b_IsHooked[client] && GetClientTeam(client) == TEAM_SURVIVOR) {

		b_IsHooked[client] = true;
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}*/
	//ChangeHook(client, true);
	OnClientLoaded(client);
}

stock bool IsLoadingClientBaseNameDefault(client) {
	if (StrContains(baseName[client], "[RPG DISCO]", true) != -1) return true;
	return false;
}

stock OnClientLoaded(client, bool IsHooked = false) {

	//if (!IsClientConnected(client)) return;
	if (!IsLoadingClientBaseNameDefault(client) && b_IsLoaded[client]) {//&& (IsFakeClient(client) || StrContains(baseName[client], "[BOT]", true) == -1)) {
		return;
	}
	bTimersRunning[client] = false;
	GetClientName(client, baseName[client], 64);
	// we do this because some players roleplay and use bot names, and we need to know when to overrided loaded players here
	// this will also conveniently tell apart the humans and bots of the same names.
	if (IsFakeClient(client)) Format(baseName[client], sizeof(baseName[]), "[BOT] %s", baseName[client]);
	else if (StrContains(baseName[client], "[BOT]", true) != -1) {
		// if a human player tries to be cheeky and put this special key in their names, we remove it.
		ReplaceString(baseName[client], sizeof(baseName[]), "[BOT]", "");
	}
	b_IsLoaded[client] = true;
	bIsGiveProfileItems[client] = false;

	IsGroupMemberTime[client] = 0;
	Format(ProfileLoadQueue[client], sizeof(ProfileLoadQueue[]), "none");
	/*if (!b_IsHooked[client]) {

		b_IsHooked[client] = true;
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}*/
	ClearEquippedAugmentData(client);
	ClearLocalClientAugmentData(client);
	ClearArray(ApplyDebuffCooldowns[client]);
	if (ISFROZEN[client] != INVALID_HANDLE) {
		KillTimer(ISFROZEN[client]);
		ISFROZEN[client] = INVALID_HANDLE;
	}
	FreeUpgrades[client] = 0;
	bIsHideThreat[client] = true;
	iThreatLevel[client] = 0;
	iChaseEnt[client] = -1;
	MyStatusEffects[client] = 0;
	ExperienceLevel[client] = 0;
	ExperienceOverall[client] = 0;
	iIsLevelingPaused[client] = 0;
	iIsBulletTrails[client] = 0;
	Rating[client] = 0;
	BestRating[client] = 0;
	bIsDisconnecting[client] = false;
	bJetpack[client] = false;
	bEquipSpells[client] = false;
	IsPvP[client] = 0;
	//ToggleTank(client, true);
	//bIsClassAbilities[client] = false;
	LoadTarget[client] = -1;
	bIsTalentTwo[client] = false;
	//CheckGamemode();
	LoadDelay[client] = false;
	b_IsLoading[client] = false;
	b_IsLoadingStore[client] = false;
	b_IsLoadingTrees[client] = false;
	HealImmunity[client] = false;
	LastAttackedUser[client] = -1;
	if (b_IsActiveRound) b_IsInSaferoom[client] = false;
	else b_IsInSaferoom[client] = true;
	bIsSurvivorFatigue[client] = true;
	//b_ActiveThisRound[client] = false;
	PreviousRoundIncaps[client] = 1;
	Points[client] = 0.0;
	b_HasDeathLocation[client] = false;
	PlayerLevel[client] = 0;
	UpgradesAvailable[client] = 0;
	UpgradesAwarded[client] = 0;
	SurvivorStamina[client] = 0;
	SurvivorStaminaTime[client] = 0.0;
	CombatTime[client] = 0.0;
	bIsInCombat[client] = false;
	MovementSpeed[client] = 1.0;
	UseItemTime[client] = 0.0;
	AmmoTriggerCooldown[client] = false;
	ExplosionCounter[client][0] = 0.0;
	ExplosionCounter[client][1] = 0.0;
	HealingContribution[client] = 0;
	TankingContribution[client] = 0;
	DamageContribution[client] = 0;
	PointsContribution[client] = 0.0;
	HexingContribution[client] = 0;
	BuffingContribution[client] = 0;
	RespawnImmunity[client] = false;
	b_IsFloating[client] = false;
	ISDAZED[client] = 0.0;
	bIsCrushCooldown[client] = false;
	bIsBurnCooldown[client] = false;
	b_IsInSaferoom[client] = true;
	ResetContributionTracker(client);

	Format(ActiveSpecialAmmo[client], sizeof(ActiveSpecialAmmo[]), "none");
	if (!b_IsCheckpointDoorStartOpened) {

		bIsEligibleMapAward[client] = false;
	}
	else {

		bIsEligibleMapAward[client] = true;
	}
	CreateTimer(1.0, Timer_LoadData, client, TIMER_FLAG_NO_MAPCHANGE);
	char thetext[64];
	GetConfigValue(thetext, sizeof(thetext), "enter server flags?");

	if (StrContains(thetext, "-", false) == -1) {

		if (!HasCommandAccess(client, thetext)) KickClient(client, "\nYou do not have the privileges\nto access this server.\n");
	}
	/*if (StrEqual(TheCurrentMap, "zerowarn_1r", false)) {
		new Float:teleportIntoSaferoom[3];
		teleportIntoSaferoom[0] = 4087.998291;
		teleportIntoSaferoom[1] = 11974.557617;
		teleportIntoSaferoom[2] = -269.968750;
		TeleportEntity(client, teleportIntoSaferoom, NULL_VECTOR, NULL_VECTOR);
	}*/
}

public Action Timer_LoadData(Handle timer, any client) {

	if (IsClientInGame(client)) {

		ResetData(client);
		char key[512];
		char TheName[64];

		//ChangeHook(client, true);

		if (IsFakeClient(client)) {

			GetSurvivorBotName(client, TheName, sizeof(TheName));
			Format(key, sizeof(key), "%s%s", sBotTeam, TheName);
		}
		else {
			GetClientAuthId(client, AuthId_Steam2, key, sizeof(key));
			if (!StrEqual(serverKey, "-1")) Format(key, sizeof(key), "%s%s", serverKey, key);
		}
		LogMessage("Client is loaded, %N of %s", client, key);
		SetPlayerDatabaseArray(client, true);
		b_IsLoading[client] = false;
		CreateNewPlayer(client);	// it only creates a new player if one doesn't exist.
	}
	else if (IsClientConnected(client)) return Plugin_Continue;
	return Plugin_Stop;
}

public Action Timer_LoggedUsers(Handle timer, any client) {

	if (!IsLegitimateClient(client)) return Plugin_Stop;
	
	//CheckGroupStatus(client);
	if (IsPlayerAlive(client) && GetClientTeam(client) == TEAM_SURVIVOR) {

		//VerifyAllActionBars(client);	// in case they don't have the gear anymore to support it?
		//IsLogged(client, true);		// Only log them if the player isn't alive.
		return Plugin_Stop;
	}
	if (IsLogged(client)) {

		if (!IsFakeClient(client)) {

			if (ReadyUp_GetGameMode() != 3) PrintToChat(client, "%T", "rejoining too fast", client, orange);
			else PrintToChat(client, "%T", "rejoining too fast survival", client, orange);
		}
		return Plugin_Stop;
	}
	IsLogged(client, true);
	return Plugin_Stop;
}

stock bool IsLogged(client, bool InsertID = false) {

	char SteamID[512];
	char TheName[64];
	char text[64];
	if (IsFakeClient(client)) {

		GetSurvivorBotName(client, TheName, sizeof(TheName));
		Format(SteamID, sizeof(SteamID), "%s%s", sBotTeam, TheName);
	}
	else {

		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	}
	//if (IsLegitimateClientAlive(client) && GetClientTeam(client) == TEAM_SURVIVOR) return true;
	if (!InsertID) {

		int size = GetArraySize(LoggedUsers);
		for (int i = 0; i < size; i++) {

			GetArrayString(LoggedUsers, i, text, sizeof(text));
			if (StrEqual(SteamID, text)) return true;
		}
		return false;
	}
	PushArrayString(LoggedUsers, SteamID);
	FindARespawnTarget(client);
	return true;
}

public Action CMD_RespawnYumYum(client, args) {

	if (GetClientTeam(client) == TEAM_SURVIVOR && !IsPlayerAlive(client)) {

		for (int i = 1; i <= MaxClients; i++) {

			if (IsLegitimateClient(i) && IsFakeClient(i) && IsPlayerAlive(i)) {

				FindARespawnTarget(client, i);
				break;
			}
		}
	}
	return Plugin_Handled;
}

stock FindARespawnTarget(client, sacrifice = -1) {

	if (!IsPlayerAlive(client)) {

		SDKCall(hRoundRespawn, client);
		if (!IsLegitimateClient(sacrifice)) {
			for (int i = 1; i <= MaxClients; i++) {
				if (!IsLegitimateClientAlive(i) || GetClientTeam(i) != TEAM_SURVIVOR || i == client) continue;
				MyRespawnTarget[client] = i;
				break;
			}
		}
		else {
			char MyName[64];
			GetClientName(client, MyName, sizeof(MyName));
			PrintToChatAll("%t", "sacrificed a bot to respawn", white, blue, MyName, orange);
			MyRespawnTarget[client] = sacrifice+100;
		}
		CreateTimer(0.1, TeleportToMyTarget, client, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action TeleportToMyTarget(Handle timer, any client) {
	if (!IsLegitimateClientAlive(client)) return Plugin_Stop;

	bool isSacrifice = false;
	if (MyRespawnTarget[client] > 100) {	// sacrifice found
		MyRespawnTarget[client] -= 100;
		isSacrifice = true;
	}
	if (!IsLegitimateClientAlive(MyRespawnTarget[client])) return Plugin_Stop;
	float TeleportPos[3];
	GetClientAbsOrigin(MyRespawnTarget[client], TeleportPos);
	TeleportEntity(client, TeleportPos, NULL_VECTOR, NULL_VECTOR);
	if (isSacrifice) IncapacitateOrKill(MyRespawnTarget[client], _, _, true);
	return Plugin_Stop;
}

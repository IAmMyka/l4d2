#define TEAM_SPECTATOR		1
#define TEAM_SURVIVOR		2
#define TEAM_INFECTED		3

#define MAX_ENTITIES		2048
#define PLUGIN_VERSION		"9.1"
#define PLUGIN_AUTHOR		"skyy"
#define PLUGIN_NAME			"ReadyUp!"
#define PLUGIN_DESCRIPTION	"Pregame plugin that adds many natives and forwards"
#define PLUGIN_LIBRARY		"readyup"
#define CHECKPOINT_DOOR_CLOSED	0
#define CHECKPOINT_DOOR_OPENED	2
#define CHECKPOINT_DOOR_MOVING	3
#define CHECKPOINTDOOR_MDL	"models/props_doors/checkpoint_door_01.mdl"
#define ENT_WORLDSPAWN 0
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

public Plugin:myinfo = {

	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESCRIPTION,
	version = PLUGIN_VERSION,
	url = PLUGIN_AUTHOR,
};

// sometimes readyup calls forwards twice... we're going to temporarily fix that with bools.
int botsToSkip = 0;
bool deleteSaferoomDoorOnStart;
char doorAngles[64];
char doorAxis[64];
bool b_IsSaferoomDoorOpened;
bool b_IsReadyUpOver;
bool b_IsReadyUpStart;
int survivorInCheckpoint[MAXPLAYERS+1];
int DeleteTheDoors;
int iForceCampaign;
static Handle g_SurvivorEnteredCheckpoint = INVALID_HANDLE;
static Handle g_IsGroupMemberStatus = INVALID_HANDLE;
static Handle g_IsSaferoomDoorDestroyed	= INVALID_HANDLE;
static Handle g_IsFirstClientLoaded	= INVALID_HANDLE;
static Handle g_IsAllClientsLoaded = INVALID_HANDLE;
static Handle g_IsReadyUpStart = INVALID_HANDLE;
static Handle g_IsReadyUpEnd = INVALID_HANDLE;
static Handle g_IsRoundEnd = INVALID_HANDLE;
static Handle g_IsCheckpointDoorOpened = INVALID_HANDLE;
static Handle g_IsMapTransition	= INVALID_HANDLE;
static Handle g_IsFinaleWon	= INVALID_HANDLE;
static Handle g_IsRoundEndFailed = INVALID_HANDLE;
static Handle g_IsSaferoomLocked = INVALID_HANDLE;
static Handle g_IsClientLoaded = INVALID_HANDLE;
static Handle g_IsLoadConfig = INVALID_HANDLE;
static Handle g_IsLoadConfigEx = INVALID_HANDLE;
static Handle g_ParseConfigFailed = INVALID_HANDLE;
static Handle g_CommandTriggered = INVALID_HANDLE;
static Handle g_SendCommands = INVALID_HANDLE;
static Handle g_IsTrueDisconnect = INVALID_HANDLE;
static Handle g_SlotChange = INVALID_HANDLE;
static Handle g_EntryDenied = INVALID_HANDLE;
static Handle g_EntryAllowed = INVALID_HANDLE;
static Handle g_TeamAssigned = INVALID_HANDLE;
static Handle g_SurvivorControl = INVALID_HANDLE;
static Handle g_TeamChange = INVALID_HANDLE;
static Handle g_Header = INVALID_HANDLE;
static Handle g_GetCampaignName = INVALID_HANDLE;
static Handle g_FirstClientSpawn = INVALID_HANDLE;
static Handle g_CallModule = INVALID_HANDLE;
static Handle g_MapList = INVALID_HANDLE;
static Handle g_FriendlyFire = INVALID_HANDLE;
static Handle g_EntityStatistics = INVALID_HANDLE;
static OFFSET_LOCKED = 0;
Handle g_IsFreezeTimer = INVALID_HANDLE;
Handle g_ForceReadyUpStartTimer	= INVALID_HANDLE;
Handle Match_Countdown = INVALID_HANDLE;
Handle g_GetMaxSurvivorCount = INVALID_HANDLE;
Handle g_IsAllTalk;
Handle g_IsGameMode;
char s_IsGameMode[64];
char white[4];
char green[4];
char blue[4];
char orange[4];
char s_Log[PLATFORM_MAX_PATH];
char s_Config[PLATFORM_MAX_PATH];
char s_Path[PLATFORM_MAX_PATH];
bool IsReadyUpLoaded;
bool bIsReadyUpEligible;
bool b_ReadyUpOver;
bool b_IsMapComplete;
bool b_IsFirstClientSpawn;
bool b_IsTransition;
bool b_IsReadyUp;
bool b_IsFirstClientLoaded;
bool b_IsAllClientsLoaded;
bool b_IsRoundOver;
bool b_IsFinaleWon;
bool b_IsTeamsFlipped;
bool b_IsIntermission;
bool b_IsFirstRound;
bool b_IsInStartArea[MAXPLAYERS + 1];
bool b_IsExitedStartArea;
bool b_IsFirstHumanSpawn;
bool b_IsHideHud[MAXPLAYERS + 1];
bool b_IsReady[MAXPLAYERS + 1];
bool b_IsParseConfig;
int StoreKeys;
int KeyCount;
char lastClient[64];
int i_RoundCount;
int SaferoomDoor;
int EndOfMapDoor;
int i_IsReadyUpHalftime;
int i_IsReadyUpIgnored;
int i_ReadyUpTime;
int i_IsHudDisabled;
int i_IsWarmupAllTalk;
int i_IsFreeze;
int i_IsDisplayLoading;
int i_IsPeriodicCountdown;
int i_CoopMapRounds;
int i_SurvivalMapRounds;
char GamemodeSurvival[512];
char GamemodeCoop[512];
char GamemodeVersus[512];
char GamemodeScavenge[512];
int i_IsLoadedMessage;
int i_IsConnectionTimeout;
int i_IsPeriodicTime;
int i_IsMajority;
int i_IsMajorityTimer;
char s_Cmd_ForceStart[64];
char s_Cmd_ToggleHud[64];
char s_Cmd_ToggleReady[64];
char s_Cmd_ToggleBots[64];
char CurrentCampaignName[64];
char s_rup[32];
Handle a_FirstMap;
Handle a_FinalMap;
Handle a_CampaignMapDescriptionKey;
Handle a_CampaignMapDescriptionValue;
Handle a_SurvivalMap;
Handle a_SurvivalMapNext;
Handle a_SurvivalMapDescriptionKey;
Handle a_SurvivalMapDescriptionValue;
Handle a_KeyConfig;
Handle a_ValueConfig;
char s_SectionConfig[64];
char s_ActiveConfig[64];
Handle a_SectionConfig;
Handle a_PluginLoadQueue;
Handle a_PluginLoadQueue_Count;
Handle a_RegisteredCommands;
Handle a_RegisteredCommands_Description;
Handle a_RegisteredCommands_Flags;
int iMaxSurvivorsAllowed;
int iMinSurvivorsAllowed;
Handle g_InfectedBotLimit	= INVALID_HANDLE;
Handle g_CampaignStatus		= INVALID_HANDLE;
Handle g_MinimumSurvivors	= INVALID_HANDLE;
Handle g_CreateCompanion	= INVALID_HANDLE;
Handle g_IsEmptyOnDisconnect = INVALID_HANDLE;
Handle StructuresToBuild_Models;
Handle StructuresToBuild_Angles;
Handle StructuresToBuild_Axis;
Handle StructuresToBuild_Delete;
Handle StructuresToDelete;
Handle StructuresToDelete_Names;
Handle StructuresToDelete_Class;

int iMaxSurvivorBotsAllowed;
int iStartingSurvivors;
int iBotCountdownTime;
int iBotIntervalTime;
int iMinSurvivors = -1;
bool bNoBots[MAXPLAYERS + 1];
Handle t_SetBotTimer = INVALID_HANDLE;
float endPos[3];

public APLRes AskPluginLoad2(Handle g_Me, bool b_IsLate, char[] s_Error, int s_ErrorMaxSize) {
	if (LibraryExists(PLUGIN_LIBRARY)) {
		strcopy(s_Error, s_ErrorMaxSize, "Plugin Already Loaded");
		return APLRes_SilentFailure;
	}

	char s_GameFolder[32];
	GetGameFolderName(s_GameFolder, sizeof(s_GameFolder));
	if (!StrEqual(s_GameFolder, "left4dead2", false)) {
		strcopy(s_Error, s_ErrorMaxSize, "Game Not Supported");
		return APLRes_Failure;
	}


	RegPluginLibrary(PLUGIN_LIBRARY);
	g_IsFirstClientLoaded = CreateGlobalForward("ReadyUp_FirstClientLoaded", ET_Ignore);
	g_FirstClientSpawn = CreateGlobalForward("ReadyUp_FirstClientSpawn", ET_Ignore);
	g_IsAllClientsLoaded = CreateGlobalForward("ReadyUp_AllClientsLoaded", ET_Ignore);
	g_IsReadyUpStart = CreateGlobalForward("ReadyUp_ReadyUpStart", ET_Ignore);
	g_IsReadyUpEnd = CreateGlobalForward("ReadyUp_ReadyUpEnd", ET_Ignore);
	g_IsRoundEnd = CreateGlobalForward("ReadyUp_RoundIsOver", ET_Event, Param_Cell)
	g_IsCheckpointDoorOpened = CreateGlobalForward("ReadyUp_CheckpointDoorStartOpened", ET_Ignore);
	g_IsMapTransition = CreateGlobalForward("ReadyUp_CoopMapEnd", ET_Ignore);
	g_IsFinaleWon = CreateGlobalForward("ReadyUp_CampaignComplete", ET_Ignore);
	g_IsRoundEndFailed = CreateGlobalForward("ReadyUp_CoopMapFailed", ET_Event, Param_Cell);
	g_IsSaferoomLocked = CreateGlobalForward("ReadyUp_SaferoomLocked", ET_Ignore);
	g_IsClientLoaded = CreateGlobalForward("ReadyUp_IsClientLoaded", ET_Event, Param_Cell);
	g_IsLoadConfig = CreateGlobalForward("ReadyUp_LoadFromConfig", ET_Event, Param_Cell, Param_Cell);
	g_IsLoadConfigEx = CreateGlobalForward("ReadyUp_LoadFromConfigEx", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_String, Param_Cell);
	g_ParseConfigFailed = CreateGlobalForward("ReadyUp_ParseConfigFailed", ET_Event, Param_String, Param_String);
	g_CommandTriggered = CreateGlobalForward("ReadyUp_Command", ET_Event, Param_Cell, Param_String);
	g_SendCommands = CreateGlobalForward("ReadyUp_ListCommands", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_IsTrueDisconnect = CreateGlobalForward("ReadyUp_TrueDisconnect", ET_Event, Param_Cell);
	g_SlotChange = CreateGlobalForward("ReadyUp_SlotChangeNotice", ET_Ignore);
	g_EntryDenied = CreateGlobalForward("ReadyUp_FwdEntryDenied", ET_Ignore);
	g_EntryAllowed = CreateGlobalForward("ReadyUp_FwdEntryAllowed", ET_Event, Param_Cell);
	g_TeamAssigned = CreateGlobalForward("ReadyUp_FwdTeamAssigned", ET_Event, Param_Cell, Param_Cell);
	g_SurvivorControl = CreateGlobalForward("ReadyUp_FwdSurvivorControl", ET_Event, Param_Cell);
	g_TeamChange = CreateGlobalForward("ReadyUp_FwdChangeTeam", ET_Event, Param_Cell, Param_Cell);
	g_Header = CreateGlobalForward("ReadyUp_FwdGetHeader", ET_Event, Param_String);
	g_GetCampaignName = CreateGlobalForward("ReadyUp_FwdGetCampaignName", ET_Event, Param_String);
	g_CallModule = CreateGlobalForward("ReadyUp_FwdCallModule", ET_Event, Param_String, Param_String, Param_Cell);
	g_MapList = CreateGlobalForward("ReadyUp_FwdGetMapList", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_FriendlyFire = CreateGlobalForward("ReadyUp_FwdFriendlyFire", ET_Event, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
	g_IsSaferoomDoorDestroyed = CreateGlobalForward("ReadyUp_SaferoomDoorDestroyed", ET_Ignore);
	g_GetMaxSurvivorCount = CreateGlobalForward("ReadyUp_GetMaxSurvivorCount", ET_Event, Param_Cell);
	g_InfectedBotLimit = CreateGlobalForward("ReadyUp_SetInfectedBotLimit", ET_Event, Param_Cell);
	g_CampaignStatus = CreateGlobalForward("ReadyUp_GetCampaignStatus", ET_Event, Param_Cell);
	g_MinimumSurvivors = CreateGlobalForward("ReadyUp_SetSurvivorMinimum", ET_Event, Param_Cell);
	g_CreateCompanion = CreateGlobalForward("ReadyUp_CreateCompanion", ET_Event, Param_Cell, Param_String);
	g_IsGroupMemberStatus = CreateGlobalForward("ReadyUp_GroupMemberStatus", ET_Event, Param_Cell, Param_Cell);
	g_IsEmptyOnDisconnect = CreateGlobalForward("ReadyUp_IsEmptyOnDisconnect", ET_Ignore);
	g_EntityStatistics = CreateGlobalForward("ReadyUp_FwdStatistics", ET_Event, Param_Cell, Param_Cell, Param_Cell);
	g_SurvivorEnteredCheckpoint = CreateGlobalForward("ReadyUp_SurvivorEnteredCheckpoint", ET_Event, Param_Cell);

	CreateNative("ReadyUp_RoundRestartedByVote", Native_RoundRestartedByVote);
	CreateNative("ReadyUp_IsTeamsFlipped", Native_IsTeamsFlipped);
	CreateNative("ReadyUp_ParseConfig", Native_ParseConfig);
	CreateNative("ReadyUp_ParseConfigEx", Native_ParseConfigEx);
	CreateNative("ReadyUp_GetGameMode", Native_GetGameMode);
	CreateNative("ReadyUp_RegisterCommand", Native_RegisterCommand);
	CreateNative("ReadyUp_RemoveCommand", Native_RemoveCommand);
	CreateNative("ReadyUp_GetCommands", Native_GetCommands);
	CreateNative("ReadyUp_SlotChangeSuccess", Native_SlotChange);
	CreateNative("ReadyUp_NtvEntryDenied", Native_EntryDenied);
	CreateNative("ReadyUp_NtvEntryAllowed", Native_EntryAllowed);
	CreateNative("ReadyUp_NtvTeamAssigned", Native_TeamAssigned);
	CreateNative("ReadyUp_NtvChangeTeam", Native_ChangeTeam);
	CreateNative("ReadyUp_NtvSurvivorControl", Native_SurvivorControl);
	CreateNative("ReadyUp_NtvGetHeader", Native_GetHeader);
	CreateNative("ReadyUp_NtvGetCampaignName", Native_GetCampaignName);
	CreateNative("ReadyUp_NtvCallModule", Native_CallModule);
	CreateNative("ReadyUp_NtvGetMapList", Native_GetMapList);
	CreateNative("ReadyUp_NtvConfigProcessing", Native_ConfigProcessing);
	CreateNative("ReadyUp_NtvFriendlyFire", Native_FriendlyFire);
	CreateNative("ReadyUp_NtvIsCampaignFinale", Native_IsCampaignFinale);
	CreateNative("ReadyUp_NtvHandicapChanged", Native_HandicapChanged);
	CreateNative("ReadyUp_NtvCreateCompanion", Native_CreateCompanion);
	CreateNative("ReadyUp_NtvGroupMemberStatus", Native_GroupMemberStatus);
	CreateNative("ReadyUp_NtvIsEmptyOnDisconnect", Native_IsEmptyOnDisconnect);
	CreateNative("ReadyUp_NtvStatistics", Native_Statistics);
	return APLRes_Success;
}

stock Now_IsLoadConfigForward() {
	if (b_IsParseConfig) {
		Call_StartForward(g_IsLoadConfig);
		Call_PushCell(a_KeyConfig);
		Call_PushCell(a_ValueConfig);
		Call_Finish();

		Call_StartForward(g_IsLoadConfigEx);
		Call_PushCell(a_KeyConfig);
		Call_PushCell(a_ValueConfig);
		Call_PushCell(a_SectionConfig);
		Call_PushString(s_ActiveConfig);
		Call_PushCell(KeyCount);
		Call_Finish();
		int a_Size = GetArraySize(a_PluginLoadQueue);
		if (a_Size > 0) {
			char p_config[PLATFORM_MAX_PATH];
			GetArrayString(a_PluginLoadQueue, 0, p_config, sizeof(p_config));
			char path[PLATFORM_MAX_PATH];
			GetArrayString(a_PluginLoadQueue, 0, path, sizeof(path));
			RemoveFromArray(a_PluginLoadQueue, 0);
			BuildPath(Path_SM, path, sizeof(path), "configs/readyup/%s", path);
			if (!FileExists(path)) {
				char error[PLATFORM_MAX_PATH];
				Format(error, sizeof(error), "File not found: %s", path);
				SetFailState("%s", path);
				Call_StartForward(g_ParseConfigFailed);
				Call_PushString(p_config);
				Call_PushString(error);
				Call_Finish();
				return;
			}
			strcopy(s_ActiveConfig, sizeof(s_ActiveConfig), p_config);
			StoreKeys = GetArrayCell(a_PluginLoadQueue_Count, 0);
			RemoveFromArray(a_PluginLoadQueue_Count, 0);
			ClearArray(a_SectionConfig);

			KeyCount = 0;
			ProcessConfigFile(path);
			return;
		}
		else {
			ClearArray(a_PluginLoadQueue);
			ClearArray(a_PluginLoadQueue_Count);

			FirstMapSaferoomStuff();
		}

		b_IsParseConfig								= false;
	}
}

stock void FirstMapSaferoomStuff() {
	if (GetGamemodeType() != 3) {
		CheckIfWeCreateSaferoomDoor();
	}
	DeleteTheStructuresWeDontWantInTheMap();
	if (GetArraySize(StructuresToBuild_Models) > 0) {
		buildCustomStructures();
	}
}

public OnPluginStart() {
	CreateConVar("readyup_version", PLUGIN_VERSION, "version header");
	SetConVarString(FindConVar("readyup_version"), PLUGIN_VERSION);
	OFFSET_LOCKED = FindSendPropInfo("CPropDoorRotatingCheckpoint", "m_bLocked");
	g_IsAllTalk = FindConVar("sv_alltalk");
	g_IsGameMode = FindConVar("mp_gamemode");
	GetConVarString(g_IsGameMode, s_IsGameMode, sizeof(s_IsGameMode));
	BuildPath(Path_SM, s_Log, sizeof(s_Log), "logs/");
	Format(s_Log, sizeof(s_Log), "%sreadyup.log", s_Log);
	HookEvent("map_transition", Event_MapTransition);
	HookEvent("mission_lost", Event_MissionLost);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_left_start_area", Event_PlayerLeftStartArea);
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("door_open", Event_StartDoorOpened);
	HookEvent("finale_win", Event_FinaleWin);
	HookEvent("survival_round_start", Event_SurvivalRoundStart);
	HookEvent("scavenge_round_start", Event_ScavengeRoundStart);
	HookEvent("scavenge_round_finished", Event_ScavengeRoundEnd);
	HookEvent("player_disconnect", Event_PlayerDisconnect);
	HookEvent("player_team", Event_PlayerTeam);
	HookEvent("player_entered_checkpoint", Event_PlayerEnteredCheckpoint);
	HookEvent("player_left_checkpoint", Event_PlayerLeftCheckpoint);
	HookEvent("player_death", Event_PlayerDeath);
	Format(white, sizeof(white), "\x01");
	Format(orange, sizeof(orange), "\x04");
	Format(green, sizeof(green), "\x05");
	Format(blue, sizeof(blue), "\x03");
	LoadTranslations("common.phrases");
	LoadTranslations("readyup.phrases");
	a_FirstMap										= CreateArray(8);
	a_FinalMap										= CreateArray(8);
	a_SurvivalMap									= CreateArray(8);
	a_SurvivalMapNext								= CreateArray(8);
	a_CampaignMapDescriptionKey						= CreateArray(8);
	a_CampaignMapDescriptionValue					= CreateArray(8);
	a_SurvivalMapDescriptionKey						= CreateArray(8);
	a_SurvivalMapDescriptionValue					= CreateArray(8);
	a_KeyConfig										= CreateArray(16);
	a_ValueConfig									= CreateArray(16);
	a_PluginLoadQueue								= CreateArray(8);
	a_PluginLoadQueue_Count							= CreateArray(8);
	a_SectionConfig									= CreateArray(16);
	a_RegisteredCommands							= CreateArray(8);
	a_RegisteredCommands_Description				= CreateArray(8);
	a_RegisteredCommands_Flags						= CreateArray(8);

	StructuresToBuild_Models = CreateArray(16);
	StructuresToBuild_Axis = CreateArray(16);
	StructuresToBuild_Angles = CreateArray(16);
	StructuresToBuild_Delete = CreateArray(16);
	StructuresToDelete = CreateArray(8);
	StructuresToDelete_Names = CreateArray(16);
	StructuresToDelete_Class = CreateArray(16);

	AddCommandListener(CommandListener, "say");
	AddCommandListener(CommandListener, "say_team");
	RegConsoleCmd("survivors", CMD_SetBotMinimum);
	if (!IsReadyUpLoaded) {
		LogMessage("ReadyUp! has loaded successfully.");
		IsReadyUpLoaded = true;
		bIsReadyUpEligible = true;
	}
}

public Action CommandListener(int client, char[] command, int argc) {
	char a_command[128];
	char sBuffer[128];
	GetCmdArg(1, sBuffer, sizeof(sBuffer));
	StripQuotes(sBuffer);
	if (sBuffer[0] != '!' && sBuffer[0] != '/') return Plugin_Continue;
	int a_Size = GetArraySize(a_RegisteredCommands);
	int flags = GetUserFlagBits(client);
	for (int i = 0; i < a_Size; i++) {
		GetArrayString(a_RegisteredCommands, i, a_command, sizeof(a_command));
		if (StrContains(sBuffer, a_command) == -1) continue;
		int a_flags = GetArrayCell(a_RegisteredCommands_Flags, i);
		if (a_flags == 0 || (flags & a_flags) || (flags & ADMFLAG_ROOT)) {
			Call_StartForward(g_CommandTriggered);
			Call_PushCell(client);
			Call_PushString(a_command);
			Call_Finish();
		}
		break;
	}
	return Plugin_Continue;
}

stock Now_RegisterCommands() {
	PushArrayString(a_RegisteredCommands, s_Cmd_ForceStart);
	PushArrayString(a_RegisteredCommands_Description, "Forces the ready up period to end.");
	PushArrayCell(a_RegisteredCommands_Flags, ADMFLAG_KICK);
	PushArrayString(a_RegisteredCommands, s_Cmd_ToggleHud);
	PushArrayString(a_RegisteredCommands_Description, "Toggles the hud on/off.");
	PushArrayCell(a_RegisteredCommands_Flags, 0);
	PushArrayString(a_RegisteredCommands, s_Cmd_ToggleReady);
	PushArrayString(a_RegisteredCommands_Description, "Toggles ready/not ready.");
	PushArrayCell(a_RegisteredCommands_Flags, 0);
	PushArrayString(a_RegisteredCommands, s_Cmd_ToggleBots);
	PushArrayString(a_RegisteredCommands_Description, "Votes for bot adjustments.");
	PushArrayCell(a_RegisteredCommands_Flags, 0);
}

public ReadyUp_Command(int client, char[] command) {

	if (StrEqual(command, s_Cmd_ForceStart)) Cmd_ForceStart(client);
	else if (StrEqual(command, s_Cmd_ToggleHud)) Cmd_ToggleHud(client);
	else if (StrEqual(command, s_Cmd_ToggleReady)) Cmd_ToggleReady(client);
	else if (StrEqual(command, s_Cmd_ToggleBots)) {
		if (t_SetBotTimer != INVALID_HANDLE) Cmd_ToggleBots(client);
	}
}

public Native_Statistics(Handle plugin, params) {
	int targetPlayer = GetNativeCell(1);
	int resultType = GetNativeCell(2);
	int amount = GetNativeCell(3);

	Call_StartForward(g_EntityStatistics);
	Call_PushCell(targetPlayer);
	Call_PushCell(resultType);
	Call_PushCell(amount);
	Call_Finish();
}

public Native_GetMapList(Handle plugin, params) {
	Call_StartForward(g_MapList);
	if (GetGamemodeType() == 3) {
		Call_PushCell(a_SurvivalMap);
		Call_PushCell(a_SurvivalMapNext);
		Call_PushCell(a_SurvivalMapDescriptionKey);
		Call_PushCell(a_SurvivalMapDescriptionValue);
	}
	else {
		Call_PushCell(a_FirstMap);
		Call_PushCell(a_FinalMap);
		Call_PushCell(a_CampaignMapDescriptionKey);
		Call_PushCell(a_CampaignMapDescriptionValue);
	}
	Call_Finish();
}

public Native_CreateCompanion(Handle plugin, params) {
	int client = GetNativeCell(1);
	char CompanionName[64];
	GetNativeString(2, CompanionName, sizeof(CompanionName));

	Call_StartForward(g_CreateCompanion);
	Call_PushCell(client);
	Call_PushString(CompanionName);
	Call_Finish();
}

public Native_CallModule(Handle plugin, params) {
	char s_command1[128];
	GetNativeString(1, s_command1, sizeof(s_command1));
	char s_command2[128];
	GetNativeString(2, s_command2, sizeof(s_command2));
	int i_command = GetNativeCell(3);

	Call_StartForward(g_CallModule);
	Call_PushString(s_command1);
	Call_PushString(s_command2);
	Call_PushCell(i_command);
	Call_Finish();
}

public Native_GetHeader(Handle plugin, params) {
	Call_StartForward(g_Header);
	Call_PushString(s_rup);
	Call_Finish();
}

public Native_GetCampaignName(Handle plugin, params) {
	TellPluginsTheCampaignName();
}

public Native_IsCampaignFinale(Handle plugin, params) {
	TellPluginsTheMapPosition();
}

void TellPluginsTheCampaignName() {
	Call_StartForward(g_GetCampaignName);
	Call_PushString(CurrentCampaignName);
	Call_Finish();
}

void TellPluginsTheMapPosition() {
	Call_StartForward(g_CampaignStatus);
	if (IsEligibleMap(1)) Call_PushCell(1);	// finale
	else if (IsEligibleMap(0)) Call_PushCell(0);	// first map
	else Call_PushCell(-1);	// all other maps
	Call_Finish();
}

public Native_GroupMemberStatus(Handle plugin, params) {
	int client		= GetNativeCell(1);
	int groupStatus = GetNativeCell(2);
	Call_StartForward(g_IsGroupMemberStatus);
	Call_PushCell(client);
	Call_PushCell(groupStatus);
	Call_Finish();
}

public Native_IsEmptyOnDisconnect(Handle plugin, params) {
	Call_StartForward(g_IsEmptyOnDisconnect);
	Call_Finish();
}

public Native_HandicapChanged(Handle plugin, params) {
	int handicaplevel = GetNativeCell(1);
	if (handicaplevel < 1) handicaplevel = 1;
	Call_StartForward(g_InfectedBotLimit);
	Call_PushCell(handicaplevel);
	Call_Finish();
}

public Native_ConfigProcessing(Handle plugin, params) {
	if (b_IsParseConfig) return 1;
	else return 0;
}

public Native_SurvivorControl(Handle plugin, params) {
	int client = GetNativeCell(1);

	Call_StartForward(g_SurvivorControl);
	Call_PushCell(client);
	Call_Finish();
}

public Native_TeamAssigned(Handle plugin, params) {

	int client = GetNativeCell(1);
	int team = GetNativeCell(2);

	Call_StartForward(g_TeamAssigned);
	Call_PushCell(client);
	Call_PushCell(team);
	Call_Finish();
}

public Action Timer_CheckIfKickBots(Handle timer) {
	if (!ClientsExist()) {
		KickSurvivorBots();
	}
	return Plugin_Stop;
}

public Action Timer_RemoveBotHold(Handle timer) {
	botsToSkip--;
	return Plugin_Stop;
}

public Native_ChangeTeam(Handle plugin, params) {
	int client = GetNativeCell(1);
	int team = GetNativeCell(2);
	if (team != TEAM_SURVIVOR) {
		CreateTimer(1.5, Timer_CheckIfKickBots, _, TIMER_FLAG_NO_MAPCHANGE);
	} else {
		botsToSkip++;
		CreateTimer(3.0, Timer_RemoveBotHold, _, TIMER_FLAG_NO_MAPCHANGE);
	}
	Call_StartForward(g_TeamChange);
	Call_PushCell(client);
	Call_PushCell(team);
	Call_Finish();
}

public Native_FriendlyFire(Handle plugin, params) {
	int client										= GetNativeCell(1);
	int victim										= GetNativeCell(2);
	int amount										= GetNativeCell(3);
	int health										= GetNativeCell(4);
	int isfire										= GetNativeCell(5);
	int bonusDamage									= GetNativeCell(6);
	Call_StartForward(g_FriendlyFire);
	Call_PushCell(client);
	Call_PushCell(victim);
	Call_PushCell(amount);
	Call_PushCell(health);
	Call_PushCell(isfire);
	Call_PushCell(bonusDamage);
	Call_Finish();
}

public Native_RegisterCommand(Handle plugin, params) {
	char command[128];
	char description[128];
	int len;
	GetNativeStringLength(1, len);
	if (len <= 0) return false;
	GetNativeString(1, command, sizeof(command));
	GetNativeString(2, description, sizeof(description));
	int flags = GetNativeCell(3);
	int a_Size = GetArraySize(a_RegisteredCommands);
	char a_command[128];
	for (int i = 0; i < a_Size; i++) {
		GetArrayString(a_RegisteredCommands, i, a_command, sizeof(a_command));
		if (StrEqual(command, a_command)) return false;
	}
	PushArrayString(a_RegisteredCommands, command);
	PushArrayString(a_RegisteredCommands_Description, description);
	PushArrayCell(a_RegisteredCommands_Flags, flags);
	AddCommandListener(CommandListener, command);
	return true;
}

public Native_EntryDenied(Handle plugin, params) {
	Call_StartForward(g_EntryDenied);
	Call_Finish();
}

public Native_EntryAllowed(Handle plugin, params) {
	int client										= GetNativeCell(1);
	Call_StartForward(g_EntryAllowed);
	Call_PushCell(client);
	Call_Finish();
}

public Native_GetCommands(Handle plugin, params) {
	int client										= GetNativeCell(1);
	Call_StartForward(g_SendCommands);
	Call_PushCell(client);
	Call_PushCell(a_RegisteredCommands);
	Call_PushCell(a_RegisteredCommands_Description);
	Call_PushCell(a_RegisteredCommands_Flags);
	Call_Finish();
}

public Native_SlotChange(Handle plugin, params) {
	Call_StartForward(g_SlotChange);
	Call_Finish();
}

public Native_RemoveCommand(Handle plugin, params) {
	char command[128];
	GetNativeString(1, command, sizeof(command));
	int a_Size = GetArraySize(a_RegisteredCommands);
	char a_command[128];
	for (int i = 0; i < a_Size; i++) {
		GetArrayString(a_RegisteredCommands, i, a_command, sizeof(a_command));
		if (!StrEqual(command, a_command)) continue;
		RemoveFromArray(a_RegisteredCommands, i);
		RemoveFromArray(a_RegisteredCommands_Description, i);
		RemoveFromArray(a_RegisteredCommands_Flags, i);
		return true;
	}
	return false;
}

public ClearRegisteredCommands() {
	ClearArray(a_RegisteredCommands);
	ClearArray(a_RegisteredCommands_Description);
	ClearArray(a_RegisteredCommands_Flags);
}

stock Cmd_ForceStart(client) {
	Now_OpenSaferoomDoor();
	if (i_IsReadyUpIgnored > 0) return;
	if (!b_IsReadyUp && client > 0) {
		PrintToChat(client, "%T", "command sm_forcestart is unavailable", client, s_rup);
	}
	else {
		b_IsReadyUp = false;
		Now_OnReadyUpEnd();
		if (client == 0) {
			Now_OpenSaferoomDoor();
			//DeleteSaferoomDoors();
		}
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsClientInGame(i) || !IsValidEntity(i)) continue;
			if (!IsClientActual(i)) continue;
			SetEntityMoveType(i, MOVETYPE_WALK);
			b_IsReady[i] = true;
		}
	}
}

stock Cmd_ToggleHud(client) {
	if (i_IsReadyUpIgnored > 0) return;
	if (!i_IsHudDisabled) {
		if (b_IsHideHud[client]) {
			PrintToChat(client, "%T", "hud enabled", client, s_rup, blue);
			b_IsHideHud[client]							= false;
		}
		else {
			PrintToChat(client, "%T", "hud disabled", client, s_rup, orange);
			b_IsHideHud[client]							= true;
		}
	}
}

stock Cmd_ToggleReady(client) {
	if (i_IsReadyUpIgnored > 0 || !b_IsAllClientsLoaded) return;
	if (b_IsReadyUp && !i_IsHudDisabled) {
		if (b_IsReady[client]) {
			PrintToChat(client, "%T", "not ready", client, s_rup, orange);
			b_IsReady[client]							= false;
		}
		else {
			PrintToChat(client, "%T", "ready", client, s_rup, blue);
			b_IsReady[client]							= true;
			if (IsMajorityCounter()) {
				if (Match_Countdown == INVALID_HANDLE) Match_Countdown = CreateTimer(1.0, Timer_Match_Countdown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
}

stock Cmd_ToggleBots(client) {
	if (t_SetBotTimer == INVALID_HANDLE) {
		PrintToChat(client, "%T", "no bot vote in progress", client, white, orange, white);
	}
	else {
		if (bNoBots[client]) {
			bNoBots[client] = false;
			PrintToChat(client, "%T", "bot vote: yes", client, white, blue);
		}
		else {
			bNoBots[client] = true;
			PrintToChat(client, "%T", "bot vote: no", client, white, orange);
		}
	}
}

stock bool IsBotVoteIgnored(bool breset = false) {
	int votes_for = 0;
	int votes_ags = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == TEAM_SURVIVOR) {
			if (breset) bNoBots[i] = false;
			else {
				if (bNoBots[i]) votes_ags++;
				else votes_for++;
			}
		}
	}
	if (votes_ags > votes_for) return true;
	return false;
}

stock bool IsMajorityCounter() {
	if (i_IsMajority == 1) {
		int num_Ready =	0;
		int num_NotReady = 0;
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) == TEAM_SPECTATOR) continue;
			if (b_IsReady[i]) num_Ready++;
			else num_NotReady++;
		}
		if (num_Ready > num_NotReady) return true;
	}
	return false;
}

public Action Timer_Match_Countdown(Handle timer) {
	static int i_CountdownTimer = -1;
	if (i_CountdownTimer == -1) {
		i_CountdownTimer = i_IsMajorityTimer;
	}
	if (!ClientsExist()) {
		i_CountdownTimer = i_IsMajorityTimer;
		return Plugin_Continue;
	}
	i_CountdownTimer--;
	if (i_CountdownTimer < 1 || b_ReadyUpOver) {
		if (!b_ReadyUpOver) Now_OnReadyUpEnd();
		Match_Countdown = INVALID_HANDLE;
		i_CountdownTimer = -1;
		return Plugin_Stop;
	}
	if (!IsMajorityCounter()) {
		PrintToChatAll("%t", "timer match countdown aborted", orange);
		Match_Countdown = INVALID_HANDLE;
		i_CountdownTimer = -1;
		return Plugin_Stop;
	}

	PrintHintTextToAll("%t", "timer match countdown", i_CountdownTimer);
	return Plugin_Continue;
}

stock Now_ChangeAllTalk(bool b_IsEnabled) {
	if (i_IsReadyUpIgnored > 0) return;
	SetConVarFlags(g_IsAllTalk, GetConVarFlags(g_IsAllTalk) & ~FCVAR_NOTIFY);
	SetConVarBool(g_IsAllTalk, b_IsEnabled);
	if (b_IsEnabled) PrintToChatAll("%t", "alltalk enabled", s_rup, green);
	else PrintToChatAll("%t", "alltalk disabled", s_rup, orange);
	SetConVarFlags(g_IsAllTalk, GetConVarFlags(g_IsAllTalk) & FCVAR_NOTIFY);
}

public Action Event_PlayerTeam(Handle event, const char[] event_name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsClientHuman(client)) return Plugin_Continue;
	char AuthId[64];
	GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));
	if (StrEqual(lastClient, AuthId)) return Plugin_Continue;
	strcopy(lastClient, sizeof(lastClient), AuthId);
	CreateTimer(1.0, Timer_ClearAuthId, client, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}

public Action Timer_ClearAuthId(Handle timer, any client) {
	if (IsClientHuman(client)) {
		char AuthId[64];
		GetClientAuthId(client, AuthId_Steam2, AuthId, sizeof(AuthId));
		if (StrEqual(lastClient, AuthId)) lastClient = "";
	}
	return Plugin_Stop;
}

public Action Event_PlayerDisconnect(Handle event, const char[] event_name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!client || !IsClientAuthorized(client) || !IsClientInGame(client) || !IsClientHuman(client)) return Plugin_Continue;
	LogMessage("%N has left the server.", client);
	bNoBots[client] = false;
	Call_StartForward(g_IsTrueDisconnect);
	Call_PushCell(client);
	Call_Finish();
	return Plugin_Continue;
}

public Action Event_SurvivalRoundStart(Handle event, char[] event_name, bool dontBroadcast) {
	if (GetGamemodeType() == 3) Now_OpenSaferoomDoor();
	return Plugin_Continue;
}

public Action Event_ScavengeRoundStart(Handle event, char[] event_name, bool dontBroadcast) {
	if (GetGamemodeType() == 4) Now_OpenSaferoomDoor();
	return Plugin_Continue;
}

public Action Event_FinaleWin(Handle event, char[] event_name, bool dontBroadcast) {
	if (GetGamemodeType() != 2) {
		b_IsFinaleWon									= true;
		Call_StartForward(g_IsFinaleWon);
		Call_Finish();
	}
	return Plugin_Continue;
}

public GetGamemodeType() {
	char CurrentGamemode[64];
	GetConVarString(FindConVar("mp_gamemode"), CurrentGamemode, sizeof(CurrentGamemode));
	if (StrContains(GamemodeCoop, CurrentGamemode, false) != -1) return 1;
	else if (StrContains(GamemodeVersus, CurrentGamemode, false) != -1) return 2;
	else if (StrContains(GamemodeSurvival, CurrentGamemode, false) != -1) return 3;
	else if (StrContains(GamemodeScavenge, CurrentGamemode, false) != -1) return 4;
	return 0;
}

public Action Event_MapTransition(Handle event, char[] event_name, bool dontBroadcast) {
	if (GetGamemodeType() != 2 && !b_IsRoundOver) {
		Call_StartForward(g_IsMapTransition);
		Call_Finish();
		int i_Temp = GetGamemodeType();
		if (i_Temp == 0) SetFailState("Current gamemode not supported. Please add this gamemode to the configs/readyup/readyup.cfg");
		Call_StartForward(g_IsRoundEnd);
		Call_PushCell(i_Temp);
		Call_Finish();
		bIsReadyUpEligible							= true;
		b_IsRoundOver								= true;
		b_IsTransition								= true;
		SaferoomDoor = -1;
	}
	return Plugin_Continue;
}

stock bool IsEligibleMap(int i_Type = 0) {
	char s_Map[32];
	GetCurrentMap(s_Map, sizeof(s_Map));
	LowerString(s_Map);
	int  a_Size = GetArraySize(a_FirstMap);
	char a_Map[32];
	bool isSurvival = (GetGamemodeType() == 3) ? true : false;
	for (int i = 0; i < a_Size; i++) {
		if (isSurvival) GetArrayString(a_SurvivalMap, i, a_Map, sizeof(a_Map));
		else {
			if (i_Type == 0) GetArrayString(a_FirstMap, i, a_Map, sizeof(a_Map));
			else GetArrayString(a_FinalMap, i, a_Map, sizeof(a_Map));
		}
		if (StrEqual(s_Map, a_Map)) return true;
	}
	return false;
}

stock void GetCurrentCampaignName() {
	char mapname[64];
	GetCurrentMap(mapname, sizeof(mapname));
	LowerString(mapname);
	int size = 0;
	if (iForceCampaign == 1) { 
		bool isSurvival = (GetGamemodeType() == 3) ? true : false;
		if (!isSurvival) {
			/*
				Only campaigns in the list are eligible.
			*/
			size = GetArraySize(a_FirstMap) - 1;
			char mapcheck[64];
			for (int i = 0; i <= size; i++) {
				GetArrayString(a_FirstMap, i, mapcheck, sizeof(mapcheck));
				if (StrEqual(mapname, mapcheck, false)) {
					// We need to store the campaign description so that if we're on a map in the campaign that isn't
					// the first map, we don't change the map on players.

					// to make code easier, map descriptions must line-up with their campaign counterpart.
					GetArrayString(a_CampaignMapDescriptionValue, i, CurrentCampaignName, sizeof(CurrentCampaignName));
					return;	// starter map is found in the list, so we don't rotate the map.
				}
			}
			// If we've made it this far, the map in play is either the first map of a campaign NOT in the rotation or its a map in an eligible campaign
			// We need to discern which that is, because we only force a campaign change if the map isn't part of a campaign in the rotation.
			size = GetArraySize(a_CampaignMapDescriptionValue);
			for (int i = 0; i < size; i++) {
				GetArrayString(a_CampaignMapDescriptionValue, i, mapname, sizeof(mapname));	// recycle the string since we don't need its stored value anymore
				if (StrEqual(mapname, CurrentCampaignName, false)) return;	// the current map is part of an eligible campaign, so we don't force a campaign change.
			}
			//size--;	// see line 1029;
			if (size > 0) size = GetRandomInt(0, size-1);
			GetArrayString(a_FirstMap, size, mapname, sizeof(mapname));
		}
		else if (!IsEligibleMap(0)) {
			size = GetRandomInt(0, GetArraySize(a_SurvivalMap) - 1);
			GetArrayString(a_SurvivalMap, size, mapname, sizeof(mapname));
		}
		else return;
		ServerCommand("changelevel %s", mapname);
		return;
	}

	size = GetArraySize(a_CampaignMapDescriptionKey);
	char s_MapDescription[64];
	for (int i = 0; i < size; i++) {
		GetArrayString(a_CampaignMapDescriptionKey, i, s_MapDescription, sizeof(s_MapDescription));
		if (StrEqual(mapname, s_MapDescription, false)) {
			GetArrayString(a_CampaignMapDescriptionValue, i, CurrentCampaignName, sizeof(CurrentCampaignName));
			return;
		}
	}
}

public Action Event_StartDoorOpened(Handle event, char[] event_name, bool dontBroadcast) {
	if (b_IsExitedStartArea || SaferoomDoor == -1) return Plugin_Continue;
	if (i_IsReadyUpIgnored == 1) b_IsExitedStartArea = true;
	bool b_IsCheckpointDoor = GetEventBool(event, "checkpoint");
	Now_StartDoorOpened(b_IsCheckpointDoor, false);
	if (b_IsCheckpointDoor) {
		DispatchKeyValue(SaferoomDoor, "spawnflags", "32768");
		if (deleteSaferoomDoorOnStart) {
			if (IsValidEntity(SaferoomDoor)) AcceptEntityInput(SaferoomDoor, "Kill");
		}
		if (GetArraySize(StructuresToDelete) > 0) deleteCustomStructures();
	}
	return Plugin_Continue;
}

bool IsThereADoorToLock() {
	if (!IsEligibleMap(0) || !StrEqual(doorAxis, "-1")) return true;
	return false;
}

void CheckIfWeCreateSaferoomDoor() {
	if (IsThereADoorToLock()) {
		ToggleSaferoomDoor(false);	// true to lock.
	}
}

public Action Event_PlayerSpawn(Handle event, char[] event_name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (GetGamemodeType() == 2) return Plugin_Continue;
	if (!IsClientActual(client) || GetClientTeam(client) != TEAM_SURVIVOR) return Plugin_Continue;
	if (!b_IsFirstClientSpawn) {
		b_IsFirstClientSpawn = true;
		Call_StartForward(g_FirstClientSpawn);
		Call_Finish();
	}
	if (b_IsRoundOver && !b_IsFirstHumanSpawn && !b_IsFirstRound && !b_IsTransition) {
		CheckIfWeCreateSaferoomDoor();
		// if (i_IsReadyUpHalftime == 1) b_IsIntermission = true;
		// else b_IsIntermission = false;
		b_IsFirstHumanSpawn = true;
		// bIsReadyUpEligible = true;
		// Now_OnReadyUpStart();
	}
	return Plugin_Continue;
}

public Action Timer_StartReadyUp(Handle timer) {
	b_IsIntermission = true;
	bIsReadyUpEligible = true;
	Now_OnReadyUpStart();
	return Plugin_Stop;
}

public Action Event_MissionLost(Handle event, char[] event_name, bool dontBroadcast) {
	Call_MissionLost();
	return Plugin_Continue;
}

stock void Call_MissionLost() {
	if (GetGamemodeType() == 2) return;
	int i_Temp = GetGamemodeType();
	if (i_Temp == 0) SetFailState("Current gamemode not supported. Please add this gamemode to the configs/readyup/readyup.cfg");
	Call_StartForward(g_IsRoundEndFailed);
	Call_PushCell(i_Temp);
	Call_Finish();
	SaferoomDoor = -1;
	if (!b_IsRoundOver) {
		Call_StartForward(g_IsRoundEnd);
		Call_PushCell(i_Temp);
		Call_Finish();
		if (i_IsReadyUpHalftime == 1) b_IsIntermission = true;
		else b_IsIntermission						= false;
		b_IsRoundOver								= true;
		bIsReadyUpEligible							= true;
		i_RoundCount++;
		if (!IsEligibleMap(1)) {
			CreateTimer(10.0, Timer_StartReadyUp, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		Now_CheckIsMapComplete();
	}
}

stock void Now_CheckIsMapComplete() {
	int i_Temp			= GetGamemodeType();
	if (i_Temp == 1 && i_RoundCount >= i_CoopMapRounds && IsEligibleMap(1) || i_Temp == 2 && i_RoundCount >= 2 || i_Temp == 3 && i_RoundCount >= i_SurvivalMapRounds) {
		b_IsMapComplete								= true;
	}
}

public Native_RoundRestartedByVote(Handle plugin, params) {
	Call_MissionLost();
	return;
}

public Native_IsTeamsFlipped(Handle plugin, params) {
	b_IsTeamsFlipped = !!GameRules_GetProp("m_bAreTeamsFlipped", 4, 0);
	return _:b_IsTeamsFlipped;
}

public Native_ParseConfig(Handle plugin, params) {
	char p_config[PLATFORM_MAX_PATH];
	int len;
	GetNativeStringLength(1, len);
	if (len <= 0) return;

	GetNativeString(1, p_config, sizeof(p_config));
	NtvCall_ParseConfig(p_config, 0);
}

public Native_ParseConfigEx(Handle plugin, params) {
	char p_config[PLATFORM_MAX_PATH];
	int len;
	GetNativeStringLength(1, len);
	if (len <= 0) return;

	GetNativeString(1, p_config, sizeof(p_config));
	int i_StoreKeyCount	= GetNativeCell(2);
	NtvCall_ParseConfig(p_config, i_StoreKeyCount);
}

public NtvCall_ParseConfig(char[] p_config, int storeKey) {
	char error[PLATFORM_MAX_PATH];
	char path[PLATFORM_MAX_PATH];
	strcopy(path, sizeof(path), p_config);
	BuildPath(Path_SM, path, sizeof(path), "configs/readyup/%s", path);
	if (!FileExists(path)) {
		Format(error, sizeof(error), "%s", path);
		Call_StartForward(g_ParseConfigFailed);
		Call_PushString(p_config);
		Call_PushString(error);
		Call_Finish();
		return;
	}
	if (b_IsParseConfig) {
		PushArrayString(a_PluginLoadQueue, p_config);
		PushArrayCell(a_PluginLoadQueue_Count, storeKey);
		return;
	}
	b_IsParseConfig = true;
	strcopy(s_ActiveConfig, sizeof(s_ActiveConfig), p_config);
	StoreKeys = storeKey;
	ClearArray(a_SectionConfig);

	ProcessConfigFile(path);
}

public Native_GetGameMode(Handle plugin, params) {
	return GetGamemodeType();
}

public Action Event_ScavengeRoundEnd(Handle event, char[] event_name, bool dontBroadcast) {
	int i_Temp = GetGamemodeType();
	if (i_Temp != 4) return Plugin_Continue;
	if (!b_IsRoundOver) {
		b_IsRoundOver = true;
		bIsReadyUpEligible = true;
		i_RoundCount++;
		Now_CheckIsMapComplete();
		Call_StartForward(g_IsRoundEnd);
		Call_PushCell(i_Temp);
		Call_Finish();
		if (b_IsIntermission) b_IsTransition = true;
		if (i_IsReadyUpHalftime == 1) b_IsIntermission = true;
		else b_IsIntermission = false;
		b_IsTeamsFlipped = !!GameRules_GetProp("m_bAreTeamsFlipped", 4, 0);
		if (!b_IsMapComplete) CreateTimer(1.0, Timer_IsNewRound, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		if (i_IsWarmupAllTalk == 1) Now_ChangeAllTalk(true);
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsClientActual(i)) continue;
			b_IsReady[i]						= false;
			b_IsHideHud[i]						= false;
		}
	}
	return Plugin_Continue;
}

public Action Event_RoundEnd(Handle event, char[] event_name, bool dontBroadcast) {
	int i_Temp = GetGamemodeType();
	if (i_Temp == 1) return Plugin_Continue;
	SaferoomDoor = -1;
	if (!b_IsRoundOver && !b_IsFinaleWon) {
		b_IsRoundOver = true;
		bIsReadyUpEligible = true;
		i_RoundCount++;
		Now_CheckIsMapComplete();
		Call_StartForward(g_IsRoundEnd);
		Call_PushCell(i_Temp);
		Call_Finish();

		if (b_IsIntermission) b_IsTransition = true;
		if (i_IsReadyUpHalftime == 1) b_IsIntermission = true;
		else b_IsIntermission = false;
		b_IsTeamsFlipped = !!GameRules_GetProp("m_bAreTeamsFlipped", 4, 0);
		if (!b_IsMapComplete) CreateTimer(1.0, Timer_IsNewRound, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		if (i_IsWarmupAllTalk == 1) Now_ChangeAllTalk(true);
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i)) continue;
			b_IsReady[i] = false;
			b_IsHideHud[i] = false;
		}
	}
	return Plugin_Continue;
}

public Action Event_PlayerLeftStartArea(Handle event, char[] event_name, bool dontBroadcast) {
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsClientHuman(client) || GetClientTeam(client) != TEAM_SURVIVOR) return Plugin_Continue;
	b_IsInStartArea[client] = false;
	return Plugin_Continue;
}

public Action Timer_IsNewRound(Handle timer) {
	if (!b_IsTransition && !b_IsMapComplete) {
		bool b_tIsTeamsFlipped = !!GameRules_GetProp("m_bAreTeamsFlipped", 4, 0);
		if (b_IsTeamsFlipped == b_tIsTeamsFlipped) return Plugin_Continue;
		Now_OnReadyUpStart();
	}
	return Plugin_Stop;
}

public OnConfigsExecuted() {
	SetConVarInt(FindConVar("versus_force_start_time"), 99999);
	BuildPath(Path_SM, s_Path, sizeof(s_Path), "configs/readyup/");
	if (!DirExists(s_Path)) CreateDirectory(s_Path, 511);
	BuildPath(Path_SM, s_Config, sizeof(s_Config), "configs/readyup/readyup.cfg");
	if(!FileExists(s_Config)) {
		SetFailState("File not found: %s", s_Config);
	}
	char s_MapList[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, s_MapList, sizeof(s_MapList), "configs/readyup/maplist.cfg");
	if (!FileExists(s_MapList)) {
		SetFailState("File not found: %s", s_MapList);
	}
	char sStructures[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sStructures, sizeof(sStructures), "configs/readyup/structures.cfg");
	if (!FileExists(sStructures)) {
		SetFailState("File not found: %s", sStructures);
	}
	bIsReadyUpEligible = true;
	b_ReadyUpOver = false;
	ClearRegisteredCommands();
	ClearArray(a_FirstMap);
	ClearArray(a_FinalMap);
	ClearArray(a_SurvivalMap);
	ClearArray(a_SurvivalMapNext);
	ClearArray(a_CampaignMapDescriptionKey);
	ClearArray(a_CampaignMapDescriptionValue);
	ClearArray(a_SurvivalMapDescriptionKey);
	ClearArray(a_SurvivalMapDescriptionValue);
	Format(doorAxis, sizeof(doorAxis), "-1");
	Format(doorAngles, sizeof(doorAngles), "-1");
	deleteSaferoomDoorOnStart = false;
	ClearArray(StructuresToBuild_Models);
	ClearArray(StructuresToBuild_Angles);
	ClearArray(StructuresToBuild_Axis);
	ClearArray(StructuresToBuild_Delete);
	ClearArray(StructuresToDelete);
	ClearArray(StructuresToDelete_Names);
	ClearArray(StructuresToDelete_Class);
	b_IsParseConfig									= false;
	ProcessConfigFile(s_Config);
	ProcessConfigFile(s_MapList);
	ProcessConfigFile(sStructures);
	GetCurrentCampaignName();
}

public OnMapStart() {
	b_IsExitedStartArea = false;
	b_IsFirstClientSpawn = false;
	g_IsFreezeTimer = INVALID_HANDLE;
	g_ForceReadyUpStartTimer = INVALID_HANDLE;
	t_SetBotTimer = INVALID_HANDLE;
	i_RoundCount = 0;
	b_IsMapComplete = false;
	b_IsTransition = false;
	b_IsFirstClientLoaded = false;
	b_IsFirstRound = true;
	b_IsAllClientsLoaded = false;
	bIsReadyUpEligible = true;
	b_ReadyUpOver = false;
	IsReadyUpLoaded = false;
	b_IsReadyUp = false;
	b_IsRoundOver = false;
	b_IsFinaleWon = false;
	b_IsTeamsFlipped = false;
	b_IsIntermission = false;
	b_IsSaferoomDoorOpened = false;
	b_IsReadyUpOver = false;
	b_IsReadyUpStart = false;
	SaferoomDoor = -1;
	EndOfMapDoor = -1;
	if (!IsModelPrecached(CHECKPOINTDOOR_MDL)) PrecacheModel(CHECKPOINTDOOR_MDL, true);
}

stock Now_SetAllClientsToNotReady() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientConnected(i) || !IsClientActual(i)) continue;
		b_IsHideHud[i]								= false;
		b_IsReady[i]								= false;
	}
}

stock bool IsClientsFound() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i)) return true;
	}
	return false;
}

stock Now_OnReadyUpStart() {
	if (b_IsReadyUpStart) return;
	b_IsReadyUpStart = true;
	b_IsReadyUpOver = false;
	b_IsSaferoomDoorOpened = false;
	TellPluginsTheMapPosition();
	TellPluginsTheCampaignName();
	if (!IsValidEntity(SaferoomDoor)) SaferoomDoor = -1;
	Call_StartForward(g_MinimumSurvivors);
	Call_PushCell(iMinSurvivors);
	Call_Finish();
	CreateTimer(1.0, Timer_FreezeSurvivorBots, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	if (b_IsMapComplete || b_IsTransition || !bIsReadyUpEligible) return; // || i_IsReadyUpIgnored == 1) return;
	b_ReadyUpOver = false;
	Now_SetAllClientsToNotReady();
	b_IsExitedStartArea	= false;
	b_IsFinaleWon = false;
	EndOfMapDoor = -1;
	UnlockEndOfMapCheckpointDoor();

	char theMap[64];
	GetCurrentMap(theMap, sizeof(theMap));
	if (iMaxSurvivorBotsAllowed > 1 && iMaxSurvivorBotsAllowed != iMinSurvivors) PrintToChatAll("%t", "bot adjustment vote offer", blue, green, iMinSurvivors, orange, green, orange);
	if (i_IsHudDisabled == 1 && i_IsDisplayLoading == 0 && i_IsPeriodicCountdown == 1 && i_ReadyUpTime > 0 && i_IsReadyUpIgnored == 0) {
		int seconds = i_ReadyUpTime;
		int minutes = 0;
		while (seconds >= 60) {
			seconds			-= 60;
			minutes++;
		}
		PrintToChatAll("%t", "ready up time remaining", s_rup, orange, minutes, green, orange, seconds, green);
	}

	if (b_IsFirstRound) {
		Call_StartForward(g_IsAllClientsLoaded);
		Call_Finish();
	}
	ToggleSaferoomDoor(false);	// true to unlock.
	if (b_IsIntermission) {
		FirstMapSaferoomStuff();
	}
	if (GetGamemodeType() != 3) {
		Call_StartForward(g_IsSaferoomLocked);
		Call_Finish();
	}
	Call_StartForward(g_IsReadyUpStart);
	Call_Finish();

	b_IsAllClientsLoaded = true;
	b_IsReadyUp = true;
	if (g_IsFreezeTimer == INVALID_HANDLE) {
		g_IsFreezeTimer									= CreateTimer(1.0, Timer_IsFreeze, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	}
	if (i_IsReadyUpIgnored == 2) {
		Now_OnReadyUpEnd();
		return;
	}
	else if (i_IsReadyUpIgnored == 0 && (!b_IsReadyUp || (b_IsIntermission || b_IsFirstRound))) {
		if (i_ReadyUpTime > 0) {
			CreateTimer(1.0, Timer_IsMatchStart, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			PrintToChatAll("%t", "match ready up", s_rup, blue);
			LogMessage("Ready Up has started...");
		}
		else Now_OnReadyUpEnd();
	}
	else Now_OnReadyUpEnd();
	DeleteTheStructuresWeDontWantInTheMap();
	if (!ClientsExist()) {
		KickSurvivorBots();
	}
}

stock void DeleteTheStructuresWeDontWantInTheMap() {
	int size = GetArraySize(StructuresToDelete_Class);
	for (int i = 0; i < size; i++) {
		char classname[64];
		GetArrayString(StructuresToDelete_Class, i, classname, sizeof(classname));
		int ent = -1;
		char targetname[64];
		GetArrayString(StructuresToDelete_Names, i, targetname, sizeof(targetname));
		while ((ent = FindEntityByClassname(ent, classname)) != -1) {
			char entityname[64];
			GetEntPropString(ent, Prop_Data, "m_iName", entityname, sizeof(entityname));
			if (!StrEqual(targetname, entityname, false)) continue;
			if (!AcceptEntityInput(ent, "Kill")) RemoveEdict(ent);
			break;
		}
	}
}

stock Spectators() {
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientConnected(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SPECTATOR) continue;
		count++;
	}
	return count;
}

stock Survivors() {

	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientConnected(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		count++;
	}
	return count;
}

stock Infected() {
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientConnected(i) || !IsClientInGame(i) || IsFakeClient(i) || GetClientTeam(i) != TEAM_INFECTED) continue;
		count++;
	}
	return count;
}

stock Now_OpenSaferoomDoor(bool deletedoor = true) {
	if (b_IsSaferoomDoorOpened) return;
	LogMessage("Saferoom door has \"opened\" - Match start.");
	b_IsSaferoomDoorOpened = true;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR) continue;
		SetEntityMoveType(i, MOVETYPE_WALK);
	}
	b_IsExitedStartArea = true;
	Call_StartForward(g_IsCheckpointDoorOpened);
	Call_Finish();
	if (deletedoor && IsThereADoorToLock()) {
		if (IsValidEntity(SaferoomDoor)) {
			AcceptEntityInput(SaferoomDoor, "Kill");
			SaferoomDoor = -1;
		}
		Call_StartForward(g_IsSaferoomDoorDestroyed);
		Call_Finish();
	}
}

stock Now_OnReadyUpEnd() {
	if (b_IsReadyUpOver) return;
	b_IsReadyUpOver = true;
	b_IsReadyUpStart = false;
	bIsReadyUpEligible = false;
	b_ReadyUpOver = true;
	b_IsFirstHumanSpawn = false;

	Call_StartForward(g_IsReadyUpEnd);
	Call_Finish();

	if (i_IsWarmupAllTalk == 1) Now_ChangeAllTalk(false);
	char theMap[64];
	GetCurrentMap(theMap, sizeof(theMap));

	bool saferoomDoorExists = IsThereADoorToLock();
	if (!saferoomDoorExists && GetGamemodeType() != 3) { //} && i_IsReadyUpIgnored == 0) {
		Now_OpenSaferoomDoor();
	}
	if (i_IsReadyUpIgnored == 0) PrintToChatAll("%t", "match is live", s_rup, blue);
	LogMessage("Ready Up has ended...");
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientConnected(i) || !IsClientInGame(i) || !IsClientActual(i)) continue;
		b_IsReady[i]								= false;
		if (GetClientTeam(i) != TEAM_SURVIVOR) continue;
		b_IsInStartArea[i]							= true;
	}
	b_IsFirstRound									= false;
	b_IsRoundOver									= false;
	b_IsReadyUp										= false;
	if (saferoomDoorExists) {
		ToggleSaferoomDoor(true);	// true to unlock.
	}
	Now_SetAllClientsToNotReady();
	Call_StartForward(g_MinimumSurvivors);
	Call_PushCell(iMinSurvivors);
	Call_Finish();
	if (i_IsReadyUpHalftime == 1 && i_IsReadyUpIgnored == 0) PrintToChatAll("%t", "intermission", s_rup);
	b_IsIntermission								= false;
}

stock Now_StartDoorOpened(bool checkpoint, bool deletedoor = true) {
	if (GetGamemodeType() == 3) return;
	if (checkpoint) {
		Now_OpenSaferoomDoor(deletedoor);
	}
}

public OnClientConnected(int client) {
	if (!IsClientInGame(client) && !IsFakeClient(client)) {
		// if (!b_IsFirstClientLoaded) {
		// 	if (IsThereADoorToLock() && i_IsFreeze == 0 && b_IsIntermission) { //} && i_IsReadyUpIgnored == 0) {
		// 		ToggleSaferoomDoor(false);	// true to unlock.
		// 	}
		// }
		char Name[MAX_NAME_LENGTH];
		GetClientName(client, Name, sizeof(Name));
		PrintToChatAll("%t", "client connected", s_rup, green, Name, white);
		Call_StartForward(g_MinimumSurvivors);
		Call_PushCell(iMinSurvivorsAllowed);
		Call_Finish();
	}
}

public Action CMD_SetBotMinimum(int client, args) {
	char countReq[64];
	GetCmdArg(1, countReq, sizeof(countReq));
	int iCount = StringToInt(countReq);
	if (iMaxSurvivorBotsAllowed <= 1 || iMaxSurvivorBotsAllowed == iMinSurvivors) return Plugin_Handled;
	if (b_IsSaferoomDoorOpened && iCount >= iMinSurvivors) {	// can call votes to lower player count at any time.
		PrintToChat(client, "%T", "bot count restricted", client, white, orange);
		return Plugin_Handled;
	}
	if (iCount > iMaxSurvivorBotsAllowed) iCount = iMaxSurvivorBotsAllowed;
	else if (iCount < iMinSurvivorsAllowed) iCount = iMinSurvivorsAllowed;
	//if (t_SetBotTimer == INVALID_HANDLE && iCount <= iMaxSurvivorBotsAllowed && iCount >= iMinSurvivorsAllowed) {
	if (t_SetBotTimer == INVALID_HANDLE) {
		PrintToChatAll("%t", "bot adjustment vote called", orange, blue, iMinSurvivors, orange, green, iCount, blue, orange, s_Cmd_ToggleBots, blue);
		Handle thepackage;
		t_SetBotTimer = CreateDataTimer(1.0, Timer_SetBotTimer, thepackage, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		WritePackCell(thepackage, iCount);
	}

	return Plugin_Handled;
}

public Action Timer_SetBotTimer(Handle timer, Handle thepackage) {
	ResetPack(thepackage);
	int iCount = ReadPackCell(thepackage);
	static int CountdownTimer = -1;
	if (CountdownTimer == -1) CountdownTimer = iBotCountdownTime;
	if (b_IsRoundOver) {
		CountdownTimer = -1;
		t_SetBotTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	CountdownTimer--;
	if (CountdownTimer < 1) {
		CountdownTimer = -1;
		PrintToChatAll("%t", "bot count adjusted", blue, white, green, iCount);
		iMinSurvivors = iCount;
		Call_StartForward(g_MinimumSurvivors);
		Call_PushCell(iMinSurvivors);
		Call_Finish();
		t_SetBotTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	else {
		if (iBotIntervalTime < 1) iBotIntervalTime = 1;
		if (IsBotVoteIgnored()) {
			IsBotVoteIgnored(true);
			PrintToChatAll("%t", "bot adjustment aborted", blue, orange);
			CountdownTimer = -1;
			t_SetBotTimer = INVALID_HANDLE;
			return Plugin_Stop;
		}
		else if (CountdownTimer % iBotIntervalTime == 0) PrintToChatAll("%t", "adjust bot count", blue, white, green, iCount, white, orange, CountdownTimer, white);
	}
	return Plugin_Continue;
}

public OnClientPostAdminCheck(int client) {
	if (IsClientInGame(client)) {
		b_IsReady[client]	= false;
		survivorInCheckpoint[client] = false;
	}
	if (IsClientHuman(client)) {
		Call_StartForward(g_MinimumSurvivors);
		Call_PushCell(iMinSurvivors);
		Call_Finish();
		Call_StartForward(g_IsClientLoaded);
		Call_PushCell(client);
		Call_Finish();
		char Name[MAX_NAME_LENGTH];
		GetClientName(client, Name, sizeof(Name));
		if (i_IsLoadedMessage == 1 && i_IsReadyUpIgnored == 0) PrintToChatAll("%t", "client loaded", s_rup, green, Name, white);
		if (i_IsHudDisabled == 0 && b_IsHideHud[client]) b_IsHideHud[client] = false;
		if (!b_IsTransition) {
			if (!b_IsFirstClientLoaded) {
				// if (GetGamemodeType() != 3) {
				// 	CheckIfWeCreateSaferoomDoor();
				// }
				if (i_IsWarmupAllTalk == 1 && i_IsReadyUpIgnored == 0) Now_ChangeAllTalk(true);
				Now_RegisterCommands();
				Call_StartForward(g_IsFirstClientLoaded);
				Call_Finish();
				//DeleteTheStructuresWeDontWantInTheMap();
				Call_StartForward(g_GetMaxSurvivorCount);
				Call_PushCell(iMaxSurvivorsAllowed);
				Call_Finish();
				b_IsFirstClientLoaded = true;
				b_IsReadyUp = true;
				b_IsAllClientsLoaded = false;
				//if (GetArraySize(StructuresToBuild_Models) > 0) {
				//	buildCustomStructures();
				//}
				if (g_IsFreezeTimer == INVALID_HANDLE) {
					g_IsFreezeTimer					= CreateTimer(1.0, Timer_IsFreeze, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				if (i_IsConnectionTimeout > 0 && !b_IsAllClientsLoaded && g_ForceReadyUpStartTimer == INVALID_HANDLE) {
					g_ForceReadyUpStartTimer		= CreateTimer(1.0, Timer_ForceReadyUpStart, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			if (i_IsReadyUpIgnored == 1) {
				b_IsExitedStartArea = true;
				Cmd_ForceStart(0);
			}
			if (!IsClientsLoading() && !b_IsAllClientsLoaded && bIsReadyUpEligible) {
				b_IsIntermission					= false;
				b_IsFirstRound						= true;
				Now_OnReadyUpStart();
			}
		}
	}
}

public Action Timer_ForceReadyUpStart(Handle timer) {
	static int i_TimeoutCounter = 0;
	i_TimeoutCounter = i_IsConnectionTimeout;
	if (!IsClientsLoading()) {
		g_ForceReadyUpStartTimer = INVALID_HANDLE;
		i_IsConnectionTimeout = i_TimeoutCounter;
		return Plugin_Stop;
	}
	if (i_IsConnectionTimeout > 0) {
		i_IsConnectionTimeout--;
		if (i_IsHudDisabled == 1 && i_IsDisplayLoading == 0 && i_IsPeriodicCountdown == 0 && i_IsReadyUpIgnored < 2) {
			if (IsClientsLoading() && !b_IsAllClientsLoaded || IsClientsLoading() && b_IsAllClientsLoaded && i_IsConnectionTimeout > 0) {
				int seconds = i_TimeoutCounter;
				int minutes = 0;
				while (seconds >= 60) {
					seconds -= 60;
					minutes++;
				}
				if (i_IsConnectionTimeout > 0) PrintHintTextToAll("%t", "connection timeout", minutes, seconds);
			}
		}
		return Plugin_Continue;
	}
	else if (!b_IsAllClientsLoaded) {
		b_IsAllClientsLoaded = true;
		b_IsIntermission = false;
		b_IsFirstRound = true;
		Now_OnReadyUpStart();
	}
	g_ForceReadyUpStartTimer = INVALID_HANDLE;
	i_IsConnectionTimeout = i_TimeoutCounter;
	return Plugin_Stop;
}

public Action Timer_IsFreeze(Handle timer) {
	if (b_IsMapComplete || !StrEqual(doorAxis, "-1")) {
		g_IsFreezeTimer	= INVALID_HANDLE;
		return Plugin_Stop;
	}
	if (!b_IsReadyUp) {
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
			SetEntityMoveType(i, MOVETYPE_WALK);
		}
		g_IsFreezeTimer = INVALID_HANDLE;
		return Plugin_Stop;
	}
	int gamemodeType = GetGamemodeType();
	bool doesASaferoomDoorExist = IsThereADoorToLock();
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i)) continue;
		if (b_IsReadyUp) {
			if (gamemodeType != 3 && (IsFakeClient(i) || GetClientTeam(i) == TEAM_SURVIVOR && !doesASaferoomDoorExist)) {
				SetEntityMoveType(i, MOVETYPE_NONE);
			}
			else {
				SetEntityMoveType(i, MOVETYPE_WALK);
			}
		}
		if (IsFakeClient(i)) continue;
		if ((IsClientsLoading() && i_IsHudDisabled == 1) || i_IsHudDisabled == 0) {
			if (i_IsHudDisabled == 1 && i_IsDisplayLoading == 1 || i_IsHudDisabled == 0) {
				if (!b_IsHideHud[i]) SendPanelToClientAndClose(ReadyUpMenu(i), i, ReadyUpMenu_Init, 1);
			}
		}
	}
	return Plugin_Continue;
}

stock bool HasIdlePlayer(int bot) {
	int userid = GetEntData(bot, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID"));
	int client = GetClientOfUserId(userid);
	if (IsLegitimateClient(client) && !IsFakeClient(client) && GetClientTeam(client) != TEAM_SURVIVOR) return true;
	return false;
}

void KickSurvivorBots() {
	int b = botsToSkip;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || !IsFakeClient(i) || HasIdlePlayer(i)) continue;
		if (b > 0) b--;
		else KickClient(i);
	}
}

public Action Timer_FreezeSurvivorBots(Handle timer) {
	if (b_IsSaferoomDoorOpened || !IsThereADoorToLock()) {
		return Plugin_Stop;
	}
	int gamemodeType = GetGamemodeType();
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i)) continue;
		if (IsFakeClient(i)) {
			if (gamemodeType != 3) {
				SetEntityMoveType(i, MOVETYPE_NONE);
			}
		}
		else {
			SetEntityMoveType(i, MOVETYPE_WALK);
		}
	}
	return Plugin_Continue;
}

public Action Timer_IsMatchStart(Handle timer) {
	static int i_TimeoutCounter = 0;
	if (i_TimeoutCounter == 0) {
		i_TimeoutCounter = i_ReadyUpTime;
	}
	static int i_PeriodicCounter	= 0;
	if (i_PeriodicCounter == 0) i_PeriodicCounter = i_IsPeriodicTime;

	if (b_IsMapComplete || !b_IsReadyUp) {
		i_ReadyUpTime = i_TimeoutCounter;
		i_IsPeriodicTime = i_PeriodicCounter;
		return Plugin_Stop;
	}
	// pause the timer if there are no human non-spectators.
	if (!ClientsExist()) {
		i_ReadyUpTime = i_TimeoutCounter;
		KickSurvivorBots();
		return Plugin_Continue;
	}
	if (i_ReadyUpTime < 1) {
		Now_OnReadyUpEnd();
		i_ReadyUpTime = i_TimeoutCounter;
		i_IsPeriodicTime = i_PeriodicCounter;
		return Plugin_Stop;
	}
	if (i_ReadyUpTime > 0) {
		bool clientsAreStillLoading = IsClientsLoading();
		i_IsPeriodicTime--;
		if (!clientsAreStillLoading || b_IsAllClientsLoaded && g_ForceReadyUpStartTimer == INVALID_HANDLE) {
			i_ReadyUpTime--;
		}
		int seconds = i_ReadyUpTime;
		int minutes	= 0;
		while (seconds >= 60) {
			seconds	-= 60;
			minutes++;
		}
		for (int i = 1; i <= MaxClients; i++) {
			if (!IsLegitimateClient(i) || IsFakeClient(i)) continue;
			if (i_IsHudDisabled == 0 && !b_IsHideHud[i]) SendPanelToClientAndClose(ReadyUpMenu(i), i, ReadyUpMenu_Init, 1);
			else if (i_IsHudDisabled == 1 && i_IsDisplayLoading == 0) {
				if (!clientsAreStillLoading || b_IsAllClientsLoaded && g_ForceReadyUpStartTimer == INVALID_HANDLE) {
					if (i_IsPeriodicCountdown == 0 || i_IsPeriodicTime < 1) PrintHintTextToAll("%t", "warmup time remaining", minutes, seconds);
					if (i_IsPeriodicTime < 1) i_IsPeriodicTime = i_PeriodicCounter;
				}
			}
		}
	}
	return Plugin_Continue;
}

stock bool ClientsExist() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsClientHuman(i) && GetClientTeam(i) != TEAM_SPECTATOR) return true;
	}
	return false;
}

stock bool IsSpectators() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i) && IsClientHuman(i) && GetClientTeam(i) == TEAM_SPECTATOR) return true;
	}
	return false;
}

stock bool IsClientsLoading() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientConnected(i) && !IsClientInGame(i) && !IsFakeClient(i)) return true;
	}
	return false;
}

stock NumClientsLoading() {
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientConnected(i) && !IsClientInGame(i) && !IsFakeClient(i)) count++;
	}
	return count;
}

public Handle ReadyUpMenu(client) {
	Handle menu = CreatePanel();
	char text[1024];
	if (i_IsReadyUpIgnored == 0) {
		if (IsClientsLoading() && !b_IsAllClientsLoaded && g_ForceReadyUpStartTimer != INVALID_HANDLE) {
			int seconds = i_IsConnectionTimeout;
			int minutes = 0;
			while (seconds >= 60) {
				seconds -= 60;
				minutes++;
			}
			Format(text, sizeof(text), "%T", "menu clients loading", client, minutes, seconds, NumClientsLoading());
			DrawPanelText(menu, text);
		}
		else if (IsClientsLoading() && g_ForceReadyUpStartTimer == INVALID_HANDLE || !IsClientsLoading()) {
			int seconds = i_ReadyUpTime;
			int minutes = 0;
			while (seconds >= 60) {
				seconds -= 60;
				minutes++;
			}
			Format(text, sizeof(text), "%T", "ready up countdown", client, minutes, seconds);
			DrawPanelText(menu, text);
		}
	}
	else {
		Format(text, sizeof(text), "%T", "match begin notice", client, NumClientsLoading());
		DrawPanelText(menu, text);
	}
	if (i_IsReadyUpIgnored == 0) {
		char ClientName[64];
		if (i_IsHudDisabled == 0) {
			if (IsClientsLoading() && g_ForceReadyUpStartTimer == INVALID_HANDLE || !IsClientsLoading()) {
				Format(text, sizeof(text), "%T", "readyup panel info", client, PLUGIN_VERSION, iMinSurvivorsAllowed, GetCurrentSurvivorCount(), iMaxSurvivorsAllowed, GetReadyPlayerCount());
				DrawPanelText(menu, text);
				if (b_IsReady[client]) Format(text, sizeof(text), "%T", "i am ready", client);
				else Format(text, sizeof(text), "%T", "i am not ready", client);
				DrawPanelItem(menu, text);
				for (int i = 1; i <= MaxClients; i++) {
					if (!IsClientConnected(i) || !IsClientInGame(i) || !IsClientHuman(i) || GetClientTeam(i) == TEAM_SPECTATOR) continue;
					GetClientName(i, ClientName, sizeof(ClientName));
					if (!b_IsReady[i]) Format(text, sizeof(text), "□");
					else Format(text, sizeof(text), "⛝");
					Format(text, sizeof(text), "%s %s", text, ClientName);
					DrawPanelText(menu, text);
				}
			}
			else {
				Format(text, sizeof(text), "%T", "players loading", client);
				for (int i = 1; i <= MaxClients; i++) {
					if (!IsClientConnected(i) || IsClientInGame(i) || !IsClientHuman(i)) continue;
					Format(text, sizeof(text), "%s \n %N", text, i);
				}
				DrawPanelItem(menu, text);
				Format(text, sizeof(text), "%T", "players waiting", client);
				for (int i = 1; i <= MaxClients; i++) {
					if (!IsClientConnected(i) || !IsClientInGame(i) || !IsClientHuman(i)) continue;
					Format(text, sizeof(text), "%s\n%N", text, i);
				}
				DrawPanelItem(menu, text);
			}
			Format(text, sizeof(text), "%T", "hide hud", client);
			DrawPanelItem(menu, text);
		}
	}
	return menu;
}

GetCurrentSurvivorCount(bool bInfectedInstead = false) {
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientConnected(i) || !IsClientInGame(i)) continue;
		if (!bInfectedInstead && GetClientTeam(i) != TEAM_SURVIVOR) continue;
		if (bInfectedInstead && GetClientTeam(i) == TEAM_SURVIVOR) continue;
		count++;
	}
	return count;
}

GetReadyPlayerCount() {
	int count = 0;
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsClientConnected(i) || !IsClientInGame(i) || GetClientTeam(i) == TEAM_SPECTATOR) continue;
		if (b_IsReady[i]) count++;
	}
	return count;
}

public ReadyUpMenu_Init(Handle topmenu, MenuAction action, int client, param2) {
	if (action == MenuAction_Select) {
		switch(param2) {
			case 1: {
				if (b_IsAllClientsLoaded) {
					Cmd_ToggleReady(client);
					if (IsMajorityCounter()) {
						if (Match_Countdown == INVALID_HANDLE) Match_Countdown = CreateTimer(1.0, Timer_Match_Countdown, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
					}
				}
				SendPanelToClientAndClose(ReadyUpMenu(client), client, ReadyUpMenu_Init, 1);
			}
			case 2: {
				if (b_IsHideHud[client]) b_IsHideHud[client]	= false;
				else b_IsHideHud[client]						= true;
				SendPanelToClientAndClose(ReadyUpMenu(client), client, ReadyUpMenu_Init, 1);
			}
			default: {
				SendPanelToClientAndClose(ReadyUpMenu(client), client, ReadyUpMenu_Init, 1);
			}
		}
	}
	if (topmenu != INVALID_HANDLE) {
		CloseHandle(topmenu);
	}
}

stock ForceCommand(int client, const char[] command) {
	int iFlags = GetCommandFlags(command);
	SetCommandFlags(command,iFlags & ~FCVAR_CHEAT);
	FakeClientCommand(client,"%s",command);
	SetCommandFlags(command,iFlags);
	SetCommandFlags(command,iFlags|FCVAR_CHEAT);
}

stock FindClient() {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientConnected(i) && IsClientInGame(i)) return i;
	}
	return 0;
}

stock bool IsClientActual(int client) {
	if (client < 1 || client > MaxClients) return false;
	return true;
}

stock bool IsClientHuman(int client) {
	if (client > 0 && IsClientConnected(client) && IsClientActual(client) && !IsFakeClient(client)) return true;
	return false;
}

stock bool IsLegitimateClient(int client) {
	if (!IsClientActual(client) || !IsClientInGame(client)) return false;
	return true;
}

stock bool AllSurvivorsInCheckpoint() {
	for (int i = 1; i <= MaxClients; i++) {
		if (!IsLegitimateClient(i) || GetClientTeam(i) != TEAM_SURVIVOR || !IsPlayerAlive(i)) continue;
		if (!survivorInCheckpoint[i]) return false;
	}
	return true;
}

stock ForceServerCommand(const char[] command) {
	int iFlags = GetCommandFlags(command);
	SetCommandFlags(command, iFlags & ~FCVAR_CHEAT);
	ServerCommand("%s", command);
	ServerExecute();
	SetCommandFlags(command, iFlags);
	SetCommandFlags(command, iFlags | FCVAR_CHEAT);
}

stock bool IsClientInCheckpoint(int client) {
	float endCheckpointPos[3];
	if (EndOfMapDoor == -1 || !IsValidEntity(EndOfMapDoor)) return false;
	GetEntPropVector(EndOfMapDoor, Prop_Send, "m_vecOrigin", endCheckpointPos);
	float clientPos[3];
	GetClientAbsOrigin(client, clientPos);
	if (GetVectorDistance(clientPos, endCheckpointPos) <= 128.0) return true;
	return false;
}

public Action Event_PlayerEnteredCheckpoint(Handle event, char[] event_name, bool dontBroadcast) {
	if (!b_IsRoundOver && b_IsSaferoomDoorOpened) {
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (!IsClientActual(client) || !IsClientInGame(client) || IsValidZombieClass(client)) return Plugin_Continue;
		if (!survivorInCheckpoint[client]) {
			if (AllSurvivorsInCheckpoint()) UnlockEndOfMapCheckpointDoor(true);
			else UnlockEndOfMapCheckpointDoor();
			if (IsClientInCheckpoint(client)) {
				survivorInCheckpoint[client] = true;
				Call_StartForward(g_SurvivorEnteredCheckpoint);
				Call_PushCell(client);
				Call_Finish();
			}
		}
	}
	return Plugin_Continue;
}

public Action Event_PlayerDeath(Handle event, char[] event_name, bool dontBroadcast) {
	if (!b_IsRoundOver && b_IsSaferoomDoorOpened) {
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (!IsClientActual(client) || !IsClientInGame(client) || IsValidZombieClass(client)) return Plugin_Continue;
		if (AllSurvivorsInCheckpoint()) UnlockEndOfMapCheckpointDoor(true);
		else UnlockEndOfMapCheckpointDoor();
	}
	return Plugin_Continue;
}

// we need to check the zombie class since the way I create special infected, they have the same team as survivors.
bool IsValidZombieClass(client) {	// 9 for survivor
	int zombieclass = GetEntProp(client, Prop_Send, "m_zombieClass");
	if (zombieclass >= 1 && zombieclass <= 8) return true;
	return false;
}

public Action Event_PlayerLeftCheckpoint(Handle event, char[] event_name, bool dontBroadcast) {
	if (!b_IsRoundOver && b_IsSaferoomDoorOpened) {
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		if (!IsClientActual(client) || !IsClientInGame(client) || IsValidZombieClass(client) || !IsPlayerAlive(client)) return Plugin_Continue;
		if (survivorInCheckpoint[client] && EndOfMapDoor != -1) {
			//PrintToChatAll("%N (%d) left the checkpoint.", client, GetEntProp(client, Prop_Send, "m_zombieClass"));
			// float survPos[3];
			// GetClientAbsOrigin(client, survPos);
			// if (GetVectorDistance(survPos, endPos) > 64.0) {
			survivorInCheckpoint[client] = false;
			UnlockEndOfMapCheckpointDoor();
		}
	}
	return Plugin_Continue;
}

stock DeleteSaferoomDoors() {
	int ent = -1;
	while ((ent = FindEntityByClassname(ent, "prop_door_rotating_checkpoint")) != -1) {
		AcceptEntityInput(ent, "Kill");
	}
}

stock void UnlockEndOfMapCheckpointDoor(bool unlockDoor = false) {
	//if (Survivors() < 1) return;
	if (EndOfMapDoor == -1) {
		int ent = -1;
		while ((ent = FindEntityByClassname(ent, "prop_door_rotating_checkpoint")) != -1) {
			if (ent == SaferoomDoor) continue;
			if (GetEntProp(ent, Prop_Send, "m_eDoorState") == CHECKPOINT_DOOR_OPENED) {	// the end of map door is the only checkpoint door that is open.
				EndOfMapDoor = ent;
				GetEntPropVector(ent, Prop_Send, "m_vecOrigin", endPos);
				if (DeleteTheDoors >= 3) DispatchKeyValue(EndOfMapDoor, "spawnflags", "32768");
				return;
			}
		}
	}
	else if (DeleteTheDoors >= 3 && EndOfMapDoor >= 0) {
		// If the end of map door exists.
		if (unlockDoor) {
			DispatchKeyValue(EndOfMapDoor, "spawnflags", "8192");
			// If set to 4, once the door unlocks, it never locks again.
			if (DeleteTheDoors == 4) EndOfMapDoor = -2;
		}
		else {
			DispatchKeyValue(EndOfMapDoor, "spawnflags", "32768");
		}
	}
	return;
}
stock ToggleSaferoomDoor(bool UnlockDoor) {
	if (IsValidEntity(SaferoomDoor) && UnlockDoor) {
		DispatchKeyValue(SaferoomDoor, "spawnflags", "8192");
		return;
	}
	if (!IsEligibleMap(0)) {
		int ent = -1;
		if (!UnlockDoor) {
			while ((ent = FindEntityByClassname(ent, "prop_door_rotating_checkpoint")) != -1) {
				if (!IsValidEntity(ent)) continue;
				if (bool:GetEntData(ent, OFFSET_LOCKED, 1)) {
					DispatchKeyValue(ent, "spawnflags", "32768");
					SaferoomDoor = ent;
					Call_StartForward(g_IsSaferoomLocked);
					Call_Finish();
					return;
				}
			}
		}
	}
	else if (SaferoomDoor == -1 && !StrEqual(doorAxis, "-1")) {
		// first map.
		int entity = CreateEntityByName("prop_door_rotating_checkpoint");
		DispatchKeyValue(entity, "spawnflags", "32768");
		DispatchKeyValue(entity, "model", CHECKPOINTDOOR_MDL);
		DispatchKeyValue(entity, "distance", "90");
		DispatchKeyValue(entity, "speed", "200");
		DispatchKeyValue(entity, "soundcloseoverride", "Doors.Checkpoint.FullClose1");
		DispatchKeyValue(entity, "soundunlockedoverride", "Doors.Checkpoint.Unlock");
		DispatchKeyValue(entity, "soundmoveoverride", "Doors.Checkpoint.Move1");
		DispatchKeyValue(entity, "soundopenoverride", "Doors.Checkpoint.FullOpen1");
		DispatchKeyValue(entity, "soundlockedoverride", "DoorHandles.Locked1");
		DispatchKeyValue(entity, "ajarangles", "0 90 0");
		DispatchSpawn(entity);
		float origin[3];
		char sOrigin[3][10];
		ExplodeString(doorAxis, " ", sOrigin, 3, 10);
		origin[0] = StringToFloat(sOrigin[0]);
		origin[1] = StringToFloat(sOrigin[1]);
		origin[2] = StringToFloat(sOrigin[2]);

		float angles[3];
		char sAngles[3][10];
		ExplodeString(doorAngles, " ", sAngles, 3, 10);
		angles[0] = StringToFloat(sAngles[0]);
		angles[1] = StringToFloat(sAngles[1]);
		angles[2] = StringToFloat(sAngles[2]);
		TeleportEntity(entity, origin, angles, NULL_VECTOR);
		SaferoomDoor = entity;
		Call_StartForward(g_IsSaferoomLocked);
		Call_Finish();
		LogMessage("new saferoom door created.");
	}
	return;
}

stock void buildCustomStructures() {
	int size = GetArraySize(StructuresToBuild_Models);
	for (int i = 0; i < size; i++) {
		char val[64];
		char sAxis[64];
		char sAngs[64];
		new entity = CreateEntityByName("prop_dynamic_override");
		GetArrayString(StructuresToBuild_Models, i, val, sizeof(val));
		DispatchKeyValue(entity, "model", val);
		DispatchKeyValue(entity, "solid", "6");
		DispatchSpawn(entity);
		GetArrayString(StructuresToBuild_Axis, i, sAxis, sizeof(sAxis));
		GetArrayString(StructuresToBuild_Angles, i, sAngs, sizeof(sAngs));
		float origin[3];
		char sOrigin[3][10];
		ExplodeString(sAxis, " ", sOrigin, 3, 10);
		origin[0] = StringToFloat(sOrigin[0]);
		origin[1] = StringToFloat(sOrigin[1]);
		origin[2] = StringToFloat(sOrigin[2]);
		float angles[3];
		char sAngles[3][10];
		ExplodeString(sAngs, " ", sAngles, 3, 10);
		angles[0] = StringToFloat(sAngles[0]);
		angles[1] = StringToFloat(sAngles[1]);
		angles[2] = StringToFloat(sAngles[2]);
		TeleportEntity(entity, origin, angles, NULL_VECTOR);

		GetArrayString(StructuresToBuild_Delete, i, val, sizeof(val));
		if (StrEqual(val, "1")) PushArrayCell(StructuresToDelete, entity);
		LogMessage("Custom structure built.");
	}
}

stock void deleteCustomStructures() {
	int size = GetArraySize(StructuresToDelete);
	while (size > 0) {
		int entity = GetArrayCell(StructuresToDelete, 0);
		if (entity == SaferoomDoor) SaferoomDoor = -1;
		if (IsValidEntity(entity) && entity != ENT_WORLDSPAWN) {
			AcceptEntityInput(entity, "Kill");
		}
		// we have to remove it from this array as this array is repopulated at the start of every round on failed attempts.
		RemoveFromArray(StructuresToDelete, 0);
		size--;
	}
	LogMessage("Custom structures deleted.");
}

stock int FindEntityByClassnameEx(int startEnt, const char[] classname) {
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}

public Action Timer_DeleteSaferoomDoor(Handle timer) {
	if (IsThereADoorToLock() && SaferoomDoor >= 0 && IsValidEntity(SaferoomDoor)) {
		AcceptEntityInput(SaferoomDoor, "Kill");
	}
	Call_StartForward(g_IsSaferoomDoorDestroyed);
	Call_Finish();
	return Plugin_Stop;
}

stock SendPanelToClientAndClose(Handle panel, int client, MenuHandler handler, int time) {
	SendPanelToClient(panel, client, handler, time);
	CloseHandle(panel);
}

stock ProcessConfigFile(const char[] file) {
	if (!FileExists(file)) {
		SetFailState("File not found: %s", file);
	}
	if (!ParseConfigFile(file)) {
		SetFailState("File formatted incorrectly: %s", file);
	}
}

stock bool ParseConfigFile(const char[] file) {
	Handle hParser = SMC_CreateParser();
	char error[128];
	int line = 0;
	int col = 0;
	ClearArray(a_KeyConfig);
	ClearArray(a_ValueConfig);

	SMC_SetReaders(hParser, Config_NewSection, Config_KeyValue, Config_EndSection);
	SMC_SetParseEnd(hParser, Config_End);

	SMCError result = SMC_ParseFile(hParser, file, line, col);
	CloseHandle(hParser);

	if (result != SMCError_Okay) {
		SMC_GetErrorString(result, error, sizeof(error));
		LogToFile(s_Log, "Problem reading %s, line %d, col %d - error: %s", file, line, col, error);
	}
	Now_IsLoadConfigForward();
	return (result == SMCError_Okay);
}

public SMCResult Config_NewSection(Handle parser, const char[] section, bool quotes) {
	strcopy(s_SectionConfig, sizeof(s_SectionConfig), section);
	if (StoreKeys == 1) KeyCount++;
	return SMCParse_Continue;
}

public SMCResult Config_KeyValue(Handle parser, const char[] key, const char[] value, bool ley_quotes, bool value_quotes) {
	char lower[64];
	// Parse Modules
	if (b_IsParseConfig) {
		PushArrayString(a_KeyConfig, key);
		PushArrayString(a_ValueConfig, value);
		PushArrayString(a_SectionConfig, s_SectionConfig);
		return SMCParse_Continue;
	}
	char currMap[64];
	GetCurrentMap(currMap, sizeof(currMap));
	if (StrEqual(s_SectionConfig, currMap)) {
		if (StrEqual(key, "axis")) Format(doorAxis, sizeof(doorAxis), "%s", value);
		if (StrEqual(key, "angles")) Format(doorAngles, sizeof(doorAxis), "%s", value);
		if (StrEqual(key, "delete") && StrEqual(value, "1")) {
			deleteSaferoomDoorOnStart = true;
		}
	}
	char structures[64];
	Format(structures, sizeof(structures), "structures_%s", currMap);
	if (StrEqual(s_SectionConfig, structures)) {
		if (StrEqual(key, "model")) {
			PushArrayString(StructuresToBuild_Models, value);
			if (!IsModelPrecached(value)) PrecacheModel(value, true);
		}
		if (StrEqual(key, "axis")) PushArrayString(StructuresToBuild_Axis, value);
		if (StrEqual(key, "angles")) PushArrayString(StructuresToBuild_Angles, value);
		if (StrEqual(key, "delete")) PushArrayString(StructuresToBuild_Delete, value);
	}
	Format(structures, sizeof(structures), "delete_%s", currMap);
	if (StrEqual(s_SectionConfig, structures)) {
		PushArrayString(StructuresToDelete_Class, key);
		PushArrayString(StructuresToDelete_Names, value);
	}
	if (StrEqual(s_SectionConfig, "config")) {
		if (StrEqual(key, "halftime warmup?")) i_IsReadyUpHalftime = StringToInt(value);
		else if (StrEqual(key, "skip readyup period?")) i_IsReadyUpIgnored = StringToInt(value);
		else if (StrEqual(key, "disable hud?")) i_IsHudDisabled = StringToInt(value);
		else if (StrEqual(key, "preround alltalk?")) i_IsWarmupAllTalk = StringToInt(value);
		else if (StrEqual(key, "freeze players?")) i_IsFreeze = StringToInt(value);
		else if (StrEqual(key, "show loading?")) i_IsDisplayLoading = StringToInt(value);
		else if (StrEqual(key, "periodic countdown?")) i_IsPeriodicCountdown = StringToInt(value);
		else if (StrEqual(key, "coop finale rounds?")) i_CoopMapRounds = StringToInt(value);
		else if (StrEqual(key, "ready up time?")) i_ReadyUpTime = StringToInt(value);
		else if (StrEqual(key, "survival game modes?")) Format(GamemodeSurvival, sizeof(GamemodeSurvival), "%s", value);
		else if (StrEqual(key, "coop game modes?")) Format(GamemodeCoop, sizeof(GamemodeCoop), "%s", value);
		else if (StrEqual(key, "versus game modes?")) Format(GamemodeVersus, sizeof(GamemodeVersus), "%s", value);
		else if (StrEqual(key, "scavenge game modes?")) Format(GamemodeScavenge, sizeof(GamemodeScavenge), "%s", value);
		else if (StrEqual(key, "load message?")) i_IsLoadedMessage = StringToInt(value);
		else if (StrEqual(key, "connection timeout delay?")) i_IsConnectionTimeout = StringToInt(value);
		else if (StrEqual(key, "periodic countdown time?")) i_IsPeriodicTime = StringToInt(value);
		else if (StrEqual(key, "forcestart command?")) strcopy(s_Cmd_ForceStart, sizeof(s_Cmd_ForceStart), value);
		else if (StrEqual(key, "togglehud command?")) strcopy(s_Cmd_ToggleHud, sizeof(s_Cmd_ToggleHud), value);
		else if (StrEqual(key, "toggleready command?")) strcopy(s_Cmd_ToggleReady, sizeof(s_Cmd_ToggleReady), value);
		else if (StrEqual(key, "togglebots command?")) strcopy(s_Cmd_ToggleBots, sizeof(s_Cmd_ToggleBots), value);
		else if (StrEqual(key, "majority ready enabled?")) i_IsMajority = StringToInt(value);
		else if (StrEqual(key, "majority ready timer?")) i_IsMajorityTimer = StringToInt(value);
		else if (StrEqual(key, "max survivors?")) iMaxSurvivorsAllowed = StringToInt(value);
		else if (StrEqual(key, "min survivors?")) iMinSurvivorsAllowed = StringToInt(value);
		else if (StrEqual(key, "force campaign?")) iForceCampaign = StringToInt(value);
		else if (StrEqual(key, "delete all doors?")) DeleteTheDoors = StringToInt(value);
		else if (StrEqual(key, "max survivor bots?")) iMaxSurvivorBotsAllowed = StringToInt(value);
		else if (StrEqual(key, "starting survivors?")) {
			iStartingSurvivors = StringToInt(value);
			if (iMinSurvivors < 1) iMinSurvivors = iStartingSurvivors;
		}
		else if (StrEqual(key, "bot toggle timer?")) iBotCountdownTime = StringToInt(value);
		else if (StrEqual(key, "bot vote advertisement?")) iBotIntervalTime = StringToInt(value);
		else if (StrEqual(key, "header?")) {
			strcopy(s_rup, sizeof(s_rup), value);
			Format(s_rup, sizeof(s_rup), "\x04[\x03%s\x04] \x01", s_rup);
		}
	}
	else {
		// Parse the maplist.cfg
		if (StrEqual(s_SectionConfig, "campaign")) {
			Format(lower, sizeof(lower), "%s", key);
			LowerString(lower);
			PushArrayString(a_FirstMap, lower);
			Format(lower, sizeof(lower), "%s", value);
			LowerString(lower);
			PushArrayString(a_FinalMap, lower);
		}
		else if (StrEqual(s_SectionConfig, "campaign description")) {
			Format(lower, sizeof(lower), "%s", key);
			LowerString(lower);
			PushArrayString(a_CampaignMapDescriptionKey, lower);
			Format(lower, sizeof(lower), "%s", value);
			LowerString(lower);
			PushArrayString(a_CampaignMapDescriptionValue, lower);
		}
		else if (StrEqual(s_SectionConfig, "survival")) {
			Format(lower, sizeof(lower), "%s", key);
			LowerString(lower);
			PushArrayString(a_SurvivalMap, lower);
			Format(lower, sizeof(lower), "%s", value);
			LowerString(lower);
			PushArrayString(a_SurvivalMapNext, lower);
		}
		else if (StrEqual(s_SectionConfig, "survival description")) {
			Format(lower, sizeof(lower), "%s", key);
			LowerString(lower);
			PushArrayString(a_SurvivalMapDescriptionKey, lower);
			Format(lower, sizeof(lower), "%s", value);
			LowerString(lower);
			PushArrayString(a_SurvivalMapDescriptionValue, lower);
		}
	}

	return SMCParse_Continue;
}

stock LowerString(char[] s) {
	for (int i = 0; i <= strlen(s); i++) {
		if (!IsCharLower(s[i])) s[i] = CharToLower(s[i]);
	}
}

public SMCResult Config_EndSection(Handle parser) {
	return SMCParse_Continue;
}

public Config_End(Handle parser, bool halted, bool failed) {
	if (failed) {
		SetFailState("Plugin configuration error");
	}
}

#define NICK_MODEL				"models/survivors/survivor_gambler.mdl"
#define ROCHELLE_MODEL			"models/survivors/survivor_producer.mdl"
#define COACH_MODEL				"models/survivors/survivor_coach.mdl"
#define ELLIS_MODEL				"models/survivors/survivor_mechanic.mdl"
#define ZOEY_MODEL				"models/survivors/survivor_teenangst.mdl"
#define FRANCIS_MODEL			"models/survivors/survivor_biker.mdl"
#define LOUIS_MODEL				"models/survivors/survivor_manager.mdl"
#define BILL_MODEL				"models/survivors/survivor_namvet.mdl"

stock bool IsSurvivorBot(int client) {
	char TheModel[64];
	GetClientModel(client, TheModel, sizeof(TheModel));	// helms deep creates bots that aren't necessarily on the survivor team.
	if (StrEqual(TheModel, NICK_MODEL) ||
		StrEqual(TheModel, ROCHELLE_MODEL) ||
		StrEqual(TheModel, COACH_MODEL) ||
		StrEqual(TheModel, ELLIS_MODEL) ||
		StrEqual(TheModel, ZOEY_MODEL) ||
		StrEqual(TheModel, FRANCIS_MODEL) ||
		StrEqual(TheModel, LOUIS_MODEL) ||
		StrEqual(TheModel, BILL_MODEL)) return true;
	return false;
}
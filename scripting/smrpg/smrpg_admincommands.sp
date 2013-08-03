#pragma semicolon 1
#include <sourcemod>

RegisterAdminCommands()
{
	RegAdminCmd("smrpg_player", Cmd_PlayerInfo, ADMFLAG_ROOT, "Get info about a certain player. Usage smrpg_player <player name | userid | steamid>", "smrpg");
	RegAdminCmd("smrpg_resetstats", Cmd_ResetStats, ADMFLAG_ROOT, "Reset a player's Level, Credits, Experience, and Upgrades (this cannot be undone!). Usage smrpg_resetstats <player name | userid | steamid>", "smrpg");
	RegAdminCmd("smrpg_resetexp", Cmd_ResetExp, ADMFLAG_ROOT, "Reset a player's Experience. Usage smrpg_resetexp <player name | userid | steamid>", "smrpg");
	RegAdminCmd("smrpg_setlvl", Cmd_SetLvl, ADMFLAG_ROOT, "Set a player's Level. Usage smrpg_setlvl <player name | userid | steamid> <new level>", "smrpg");
	RegAdminCmd("smrpg_addlvl", Cmd_AddLvl, ADMFLAG_ROOT, "Add Level(s) to a player's current Level. Usage smrpg_addlvl <player name | userid | steamid> <levels>", "smrpg");
	RegAdminCmd("smrpg_setexp", Cmd_SetExp, ADMFLAG_ROOT, "Set a player's Experience. Usage smrpg_setexp <player name | userid | steamid> <new exp>", "smrpg");
	RegAdminCmd("smrpg_addexp", Cmd_AddExp, ADMFLAG_ROOT, "Give a player Experience. Usage smrpg_addexp <player name | userid | steamid> <exp>", "smrpg");
	RegAdminCmd("smrpg_setcredits", Cmd_SetCredits, ADMFLAG_ROOT, "Set a player's Credits. Usage smrpg_setcredits <player name | userid | steamid> <new credits>", "smrpg");
	RegAdminCmd("smrpg_addcredits", Cmd_AddCredits, ADMFLAG_ROOT, "Add to player's Credits. Usage smrpg_addcredits <player name | userid | steamid> <credits>", "smrpg");
	RegAdminCmd("smrpg_listupgrades", Cmd_ListUpgrades, ADMFLAG_ROOT, "List all available upgrades.", "smrpg");
	RegAdminCmd("smrpg_setupgradelvl", Cmd_SetUpgradeLvl, ADMFLAG_ROOT, "Set a player's Upgrade Level. Usage smrpg_setupgradelvl <player name | userid | steamid> <upgrade> <level|max>", "smrpg");
	RegAdminCmd("smrpg_giveupgrade", Cmd_GiveUpgrade, ADMFLAG_ROOT, "Give a player an Upgrade (increment). Usage smrpg_giveupgrade <player name | userid | steamid> <upgrade>", "smrpg");
	RegAdminCmd("smrpg_giveall", Cmd_GiveAll, ADMFLAG_ROOT, "Give a player all the Upgrades available. Usage smrpg_giveall <player name | userid | steamid>", "smrpg");
	RegAdminCmd("smrpg_takeupgrade", Cmd_TakeUpgrade, ADMFLAG_ROOT, "Take an Upgrade from a player (decrement). Usage smrpg_takeupgrade <player name | userid | steamid> <upgrade>", "smrpg");
	RegAdminCmd("smrpg_buyupgrade", Cmd_BuyUpgrade, ADMFLAG_ROOT, "Force a player to buy an Upgrade. Usage smrpg_buyupgrade <player name | userid | steamid> <upgrade>", "smrpg");
	RegAdminCmd("smrpg_sellupgrade", Cmd_SellUpgrade, ADMFLAG_ROOT, "Force a player to sell an Upgrade (full refund). Usage smrpg_sellupgrade <player name | userid | steamid> <upgrade>", "smrpg");
	RegAdminCmd("smrpg_sellall", Cmd_SellAll, ADMFLAG_ROOT, "Force a player to sell all their Upgrades (full refund). Usage smrpg_sellall <player name | userid | steamid>", "smrpg");
	RegAdminCmd("smrpg_db_delplayer", Cmd_DBDelPlayer, ADMFLAG_ROOT, "Delete a player entry from both tables in the database (this cannot be undone!). Usage: smrpg_db_delplayer <full name | player db id | steamid>", "smrpg");
	RegAdminCmd("smrpg_db_mass_sell", Cmd_DBMassSell, ADMFLAG_ROOT, "Force everyone in the database (and playing) to sell a specific upgrade. Usage: smrpg_db_mass_sell <upgrade>", "smrpg");
	RegAdminCmd("smrpg_db_write", Cmd_DBWrite, ADMFLAG_ROOT, "Write current player data to the database", "smrpg");
	
	RegAdminCmd("smrpg_debug_playerlist", Cmd_DebugPlayerlist, ADMFLAG_ROOT, "List all RPG players", "smrpg");
}

public Action:Cmd_PlayerInfo(client, args)
{
	decl String:sText[256];
	GetCmdArgString(sText, sizeof(sText));
	TrimString(sText);
	new iTarget = FindTarget(client, sText, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	ReplyToCommand(client, "SM:RPG: ----------");
	ReplyToCommand(client, "SM:RPG %N: ", iTarget);
	
	new playerInfo[PlayerInfo];
	GetClientRPGInfo(iTarget, playerInfo);
	
	decl String:sSteamID[32];
	GetClientAuthString(iTarget, sSteamID, sizeof(sSteamID));
	ReplyToCommand(client, "SM:RPG Info: Index: %d, UserID: %d, SteamID: %s, Database ID: %d:%d", iTarget, GetClientUserId(iTarget), sSteamID, playerInfo[PLR_dbId], playerInfo[PLR_dbUpgradeId]);
	
	ReplyToCommand(client, "SM:RPG Stats: Level: %d, Experience: %d/%d, Credits: %d, Rank: %d/%d", GetClientLevel(iTarget), GetClientExperience(iTarget), Stats_LvlToExp(GetClientLevel(iTarget)), GetClientCredits(iTarget), GetClientRank(iTarget), GetRankCount());
	
	ReplyToCommand(client, "SM:RPG Upgrades: ");
	new iSize = GetUpgradeCount();
	new upgrade[InternalUpgradeInfo];
	for(new i=0;i<iSize;i++)
	{
		GetUpgradeByIndex(i, upgrade);
		ReplyToCommand(client, "SM:RPG -: %s Level %d", upgrade[UPGR_name], GetClientUpgradeLevel(iTarget, i));
	}
	ReplyToCommand(client, "SM:RPG: ----------");
	
	return Plugin_Handled;
}

public Action:Cmd_ResetStats(client, args)
{
	decl String:sText[256];
	GetCmdArgString(sText, sizeof(sText));
	TrimString(sText);
	new iTarget = FindTarget(client, sText, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	ResetStats(iTarget);
	
	ReplyToCommand(client, "SM:RPG resetstats: %N's stats have been permanently reset", iTarget);
	
	return Plugin_Handled;
}

public Action:Cmd_ResetExp(client, args)
{
	decl String:sText[256];
	GetCmdArgString(sText, sizeof(sText));
	TrimString(sText);
	new iTarget = FindTarget(client, sText, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	if(SetClientExperience(iTarget, 0))
		ReplyToCommand(client, "SM:RPG resetexp: %N's experience has been reset", iTarget);
	else
		ReplyToCommand(client, "SM:RPG resetexp: Can't reset %N's experience. Some other plugin doesn't want this to happen.");
	
	return Plugin_Handled;
}

public Action:Cmd_SetLvl(client, args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "CSS:RPG: Usage: smrpg_setlvl <player name | #userid | steamid> <new level>");
		return Plugin_Handled;
	}
	
	decl String:sPlayer[64];
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	TrimString(sPlayer);
	new iTarget = FindTarget(client, sPlayer, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	decl String:sLevel[16];
	GetCmdArg(2, sLevel, sizeof(sLevel));
	new iLevel = StringToInt(sLevel);
	
	if(iLevel < 1)
	{
		ReplyToCommand(client, "SM:RPG: Minimum level is 1!");
		return Plugin_Handled;
	}
	
	new iOldLevel = GetClientLevel(iTarget);
	
	// Do a proper level up
	if(iLevel > iOldLevel)
	{
		Stats_PlayerNewLevel(iTarget, iLevel-iOldLevel);
	}
	// Decrease level manually, don't touch the credits/items
	else
	{
		SetClientLevel(iTarget, iLevel);
		SetClientExperience(iTarget, 0);
		
		if(GetConVarBool(g_hCVAnnounceNewLvl))
			PrintToChatAll("%t", "new_lvl1", iTarget, GetClientLevel(iTarget));
	}
	
	ReplyToCommand(client, "SM:RPG setlvl: %N has been set to Level %d (previously Level %d)", iTarget, GetClientLevel(iTarget), iOldLevel);
	
	return Plugin_Handled;
}

public Action:Cmd_AddLvl(client, args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "SM:RPG: Usage: smrpg_addlvl <player name | #userid | steamid> <levels>");
		return Plugin_Handled;
	}
	
	decl String:sPlayer[64];
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	TrimString(sPlayer);
	new iTarget = FindTarget(client, sPlayer, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	decl String:sLevel[16];
	GetCmdArg(2, sLevel, sizeof(sLevel));
	new iLevelIncrease = StringToInt(sLevel);
	
	if(iLevelIncrease < 1)
	{
		ReplyToCommand(client, "SM:RPG: You have to add at least 1 level!");
		return Plugin_Handled;
	}
	
	new iOldLevel = GetClientLevel(iTarget);
	
	Stats_PlayerNewLevel(iTarget, iLevelIncrease);
	
	ReplyToCommand(client, "SM:RPG addlvl: %N has been set to Level %d (previously Level %d)", iTarget, GetClientLevel(iTarget), iOldLevel);
	
	return Plugin_Handled;
}

public Action:Cmd_SetExp(client, args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "SM:RPG: Usage: smrpg_setexp <player name | #userid | steamid> <new exp>");
		return Plugin_Handled;
	}
	
	decl String:sPlayer[64];
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	TrimString(sPlayer);
	new iTarget = FindTarget(client, sPlayer, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	decl String:sExperience[16];
	GetCmdArg(2, sExperience, sizeof(sExperience));
	new iExperience = StringToInt(sExperience);
	
	if(iExperience < 0)
	{
		ReplyToCommand(client, "SM:RPG: Experience must be >= 0!");
		return Plugin_Handled;
	}
	
	new iOldLevel = GetClientLevel(iTarget);
	new iOldExperience = GetClientExperience(iTarget);
	
	if(iExperience > iOldExperience)
		Stats_AddExperience(iTarget, iExperience-iOldExperience, false);
	else
		SetClientExperience(iTarget, iExperience);
	
	ReplyToCommand(client, "SM:RPG setexp: %N is now Level %d and has %d/%d Experience (previously Level %d with %d/%d Experience)", iTarget, GetClientLevel(iTarget), GetClientExperience(iTarget), Stats_LvlToExp(GetClientLevel(iTarget)), iOldLevel, iOldExperience, Stats_LvlToExp(iOldLevel));
	
	return Plugin_Handled;
}

public Action:Cmd_AddExp(client, args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "SM:RPG: Usage: smrpg_addexp <player name | #userid | steamid> <exp>");
		return Plugin_Handled;
	}
	
	decl String:sPlayer[64];
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	TrimString(sPlayer);
	new iTarget = FindTarget(client, sPlayer, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	decl String:sExperienceIncrease[16];
	GetCmdArg(2, sExperienceIncrease, sizeof(sExperienceIncrease));
	new iExperienceIncrease = StringToInt(sExperienceIncrease);
	
	if(iExperienceIncrease < 1)
	{
		ReplyToCommand(client, "SM:RPG: You have to add at least 1 experience!");
		return Plugin_Handled;
	}
	
	new iOldLevel = GetClientLevel(iTarget);
	new iOldExperience = GetClientExperience(iTarget);
	
	Stats_AddExperience(iTarget, iExperienceIncrease, false);
	
	ReplyToCommand(client, "SM:RPG setexp: %N is now Level %d and has %d/%d Experience (previously Level %d with %d/%d Experience)", iTarget, GetClientLevel(iTarget), GetClientExperience(iTarget), Stats_LvlToExp(GetClientLevel(iTarget)), iOldLevel, iOldExperience, Stats_LvlToExp(iOldLevel));
	
	return Plugin_Handled;
}

public Action:Cmd_SetCredits(client, args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "SM:RPG: Usage: smrpg_setcredits <player name | #userid | steamid> <new credits>");
		return Plugin_Handled;
	}
	
	decl String:sPlayer[64];
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	TrimString(sPlayer);
	new iTarget = FindTarget(client, sPlayer, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	decl String:sCredits[16];
	GetCmdArg(2, sCredits, sizeof(sCredits));
	new iCredits = StringToInt(sCredits);
	
	if(iCredits < 0)
	{
		ReplyToCommand(client, "SM:RPG: Credits have to be >= 0!");
		return Plugin_Handled;
	}
	
	new iOldCredits = GetClientCredits(iTarget);
	
	SetClientCredits(iTarget, iCredits);
	
	ReplyToCommand(client, "SM:RPG setcredits: %N now has %d Credits (previously had %d Credits)", iTarget, GetClientCredits(iTarget), iOldCredits);
	
	return Plugin_Handled;
}

public Action:Cmd_AddCredits(client, args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "SM:RPG: Usage: smrpg_addcredits <player name | #userid | steamid> <credits>");
		return Plugin_Handled;
	}
	
	decl String:sPlayer[64];
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	TrimString(sPlayer);
	new iTarget = FindTarget(client, sPlayer, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	decl String:sCredits[16];
	GetCmdArg(2, sCredits, sizeof(sCredits));
	new iCredits = StringToInt(sCredits);
	
	if(iCredits < 1)
	{
		ReplyToCommand(client, "SM:RPG: You have to add at least 1 credit!");
		return Plugin_Handled;
	}
	
	new iOldCredits = GetClientCredits(iTarget);
	
	SetClientCredits(iTarget, iOldCredits+iCredits);
	
	ReplyToCommand(client, "SM:RPG addcredits: %N now has %d Credits (previously had %d Credits)", iTarget, GetClientCredits(iTarget), iOldCredits);
	
	return Plugin_Handled;
}

public Action:Cmd_ListUpgrades(client, args)
{
	new iSize = GetUpgradeCount();
	ReplyToCommand(client, "There are %d upgrades registered.", iSize);
	new upgrade[InternalUpgradeInfo];
	new iUnavailableCount, String:sPluginFile[64];
	for(new i=0;i<iSize;i++)
	{
		GetUpgradeByIndex(i, upgrade);
		if(!IsValidUpgrade(upgrade))
		{
			iUnavailableCount++;
			continue;
		}
		
		GetPluginFilename(upgrade[UPGR_plugin], sPluginFile, sizeof(sPluginFile));
		
		ReplyToCommand(client, "%d. [%s] %s (%s). Maxlevel: %d, maxlevel barrier: %d, start cost: %d, increasing cost: %d, plugin: %s", i-iUnavailableCount, (upgrade[UPGR_enabled] ? "ON" : "OFF"), upgrade[UPGR_name], upgrade[UPGR_shortName], upgrade[UPGR_maxLevel], upgrade[UPGR_maxLevelBarrier], upgrade[UPGR_startCost], upgrade[UPGR_incCost], sPluginFile);
	}
	if(iUnavailableCount > 0)
	{
		ReplyToCommand(client, "----------------");
		ReplyToCommand(client, "%d upgrades are unavailable. The plugin providing that upgrade might have been unloaded.", iUnavailableCount);
	}
	
	return Plugin_Handled;
}

public Action:Cmd_SetUpgradeLvl(client, args)
{
	if(args < 3)
	{
		ReplyToCommand(client, "SM:RPG: Usage: smrpg_setupgradelvl <player name | #userid | steamid> <upgrade shortname> <level|max>");
		return Plugin_Handled;
	}
	
	decl String:sPlayer[64];
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	TrimString(sPlayer);
	new iTarget = FindTarget(client, sPlayer, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	decl String:sUpgrade[MAX_UPGRADE_SHORTNAME_LENGTH];
	GetCmdArg(2, sUpgrade, sizeof(sUpgrade));
	TrimString(sUpgrade);
	StripQuotes(sUpgrade);
	new upgrade[InternalUpgradeInfo];
	if(!GetUpgradeByShortname(sUpgrade, upgrade) || !IsValidUpgrade(upgrade))
	{
		ReplyToCommand(client, "SM:RPG: There is no upgrade with name \"%s\".", sUpgrade);
		return Plugin_Handled;
	}
	
	decl String:sLevel[16];
	GetCmdArg(3, sLevel, sizeof(sLevel));
	StripQuotes(sLevel);
	
	// Make sure we're not over the maxlevel
	new iLevel = StringToInt(sLevel);
	if(StrEqual(sLevel, "max", false) || iLevel > upgrade[UPGR_maxLevel])
		iLevel = upgrade[UPGR_maxLevel];
	
	if(iLevel < 0)
	{
		ReplyToCommand(client, "SM:RPG: Upgrade levels start at 0!");
		return Plugin_Handled;
	}
	
	new iIndex = upgrade[UPGR_index];
	new iOldLevel = GetClientUpgradeLevel(iTarget, iIndex);
	
	// Item level increased
	if(iOldLevel < iLevel)
	{
		while(GetClientUpgradeLevel(iTarget, iIndex) < iLevel)
		{
			// If some plugin doesn't want any more upgrade levels, stop trying.
			if(!GiveClientUpgrade(iTarget, iIndex))
				break;
		}
	}
	// Item level decreased..
	else
	{
		while(GetClientUpgradeLevel(iTarget, iIndex) > iLevel)
		{
			// If some plugin doesn't want any less upgrade levels, stop trying.
			if(!TakeClientUpgrade(iTarget, iIndex))
				break;
		}
	}
	
	ReplyToCommand(client, "SM:RPG setupgradelvl: %N now has %s Level %d (previously Level %d)", iTarget, upgrade[UPGR_name], GetClientUpgradeLevel(iTarget, iIndex), iOldLevel);
	
	return Plugin_Handled;
}

public Action:Cmd_GiveUpgrade(client, args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "SM:RPG: Usage: smrpg_giveupgrade <player name | #userid | steamid> <upgrade shortname>");
		return Plugin_Handled;
	}
	
	decl String:sPlayer[64];
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	TrimString(sPlayer);
	new iTarget = FindTarget(client, sPlayer, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	decl String:sUpgrade[MAX_UPGRADE_SHORTNAME_LENGTH];
	GetCmdArg(2, sUpgrade, sizeof(sUpgrade));
	TrimString(sUpgrade);
	StripQuotes(sUpgrade);
	new upgrade[InternalUpgradeInfo];
	if(!GetUpgradeByShortname(sUpgrade, upgrade) || !IsValidUpgrade(upgrade))
	{
		ReplyToCommand(client, "SM:RPG: There is no upgrade with name \"%s\".", sUpgrade);
		return Plugin_Handled;
	}
	
	new iIndex = upgrade[UPGR_index];
	new iOldLevel = GetClientUpgradeLevel(iTarget, iIndex);
	
	if(iOldLevel >= upgrade[UPGR_maxLevel])
	{
		ReplyToCommand(client, "SM:RPG giveupgrade: %N has the maximum Level for %s (Level %d)", iTarget, upgrade[UPGR_name], iOldLevel);
		return Plugin_Handled;
	}
	
	if(!GiveClientUpgrade(iTarget, iIndex))
	{
		ReplyToCommand(client, "SM:RPG giveupgrade: Upgrade refused to upgrade.");
		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "SM:RPG giveupgrade: %N now has %s Level %d (previously Level %d)", iTarget, upgrade[UPGR_name], GetClientUpgradeLevel(iTarget, iIndex), iOldLevel);
	
	return Plugin_Handled;
}

public Action:Cmd_GiveAll(client, args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "SM:RPG: Usage: smrpg_giveall <player name | #userid | steamid>");
		return Plugin_Handled;
	}
	
	decl String:sPlayer[64];
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	TrimString(sPlayer);
	new iTarget = FindTarget(client, sPlayer, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	new iSize = GetUpgradeCount();
	new upgrade[InternalUpgradeInfo];
	for(new i=0;i<iSize;i++)
	{
		GetUpgradeByIndex(i, upgrade);
		if(!IsValidUpgrade(upgrade) || !upgrade[UPGR_enabled])
			continue;
		
		SetClientUpgradeLevel(iTarget, i, upgrade[UPGR_maxLevel]);
	}
	
	ReplyToCommand(client, "SM:RPG giveall: %N now has all Upgrades on max.", iTarget);
	
	return Plugin_Handled;
}

public Action:Cmd_TakeUpgrade(client, args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "SM:RPG: Usage: smrpg_takeupgrade <player name | #userid | steamid> <upgrade shortname>");
		return Plugin_Handled;
	}
	
	decl String:sPlayer[64];
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	TrimString(sPlayer);
	new iTarget = FindTarget(client, sPlayer, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	decl String:sUpgrade[MAX_UPGRADE_SHORTNAME_LENGTH];
	GetCmdArg(2, sUpgrade, sizeof(sUpgrade));
	TrimString(sUpgrade);
	StripQuotes(sUpgrade);
	new upgrade[InternalUpgradeInfo];
	if(!GetUpgradeByShortname(sUpgrade, upgrade) || !IsValidUpgrade(upgrade))
	{
		ReplyToCommand(client, "SM:RPG: There is no upgrade with name \"%s\".", sUpgrade);
		return Plugin_Handled;
	}
	
	new iIndex = upgrade[UPGR_index];
	new iOldLevel = GetClientUpgradeLevel(iTarget, iIndex);
	
	if(iOldLevel <= 0)
	{
		ReplyToCommand(client, "SM:RPG takeupgrade: %N doesn't have %s", iTarget, upgrade[UPGR_name]);
		return Plugin_Handled;
	}
	
	if(!TakeClientUpgrade(iTarget, iIndex))
	{
		ReplyToCommand(client, "SM:RPG takeupgrade: Upgrade refused to downgrade.");
		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "SM:RPG takeupgrade: %N now has %s Level %d (previously Level %d)", iTarget, upgrade[UPGR_name], GetClientUpgradeLevel(iTarget, iIndex), iOldLevel);
	
	return Plugin_Handled;
}

public Action:Cmd_BuyUpgrade(client, args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "SM:RPG: Usage: smrpg_buyupgrade <player name | #userid | steamid> <upgrade shortname>");
		return Plugin_Handled;
	}
	
	decl String:sPlayer[64];
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	TrimString(sPlayer);
	new iTarget = FindTarget(client, sPlayer, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	decl String:sUpgrade[MAX_UPGRADE_SHORTNAME_LENGTH];
	GetCmdArg(2, sUpgrade, sizeof(sUpgrade));
	TrimString(sUpgrade);
	StripQuotes(sUpgrade);
	new upgrade[InternalUpgradeInfo];
	if(!GetUpgradeByShortname(sUpgrade, upgrade) || !IsValidUpgrade(upgrade))
	{
		ReplyToCommand(client, "SM:RPG: There is no upgrade with name \"%s\".", sUpgrade);
		return Plugin_Handled;
	}
	
	new iIndex = upgrade[UPGR_index];
	new iOldLevel = GetClientUpgradeLevel(iTarget, iIndex);
	
	if(iOldLevel >= upgrade[UPGR_maxLevel])
	{
		ReplyToCommand(client, "SM:RPG buyupgrade: %N has the maximum Level for %s (Level %d)", iTarget, upgrade[UPGR_name], iOldLevel);
		return Plugin_Handled;
	}
	
	new iCost = GetUpgradeCost(iIndex, iOldLevel);
	if(iCost > GetClientCredits(iTarget))
	{
		ReplyToCommand(client, "SM:RPG buyupgrade: %N doesn't have enough credits to purchase %s (%d/%d)", iTarget, upgrade[UPGR_name], GetClientCredits(iTarget), iCost);
		return Plugin_Handled;
	}
	
	if(!BuyClientUpgrade(iTarget, iIndex))
	{
		ReplyToCommand(client, "SM:RPG buyupgrade: Upgrade refused to upgrade.");
		return Plugin_Handled;
	}
	
	ReplyToCommand(client, "SM:RPG buyupgrade: %N now has %s Level %d (previously Level %d)", iTarget, upgrade[UPGR_name], GetClientUpgradeLevel(iTarget, iIndex), iOldLevel);
	
	return Plugin_Handled;
}

public Action:Cmd_SellUpgrade(client, args)
{
	if(args < 2)
	{
		ReplyToCommand(client, "SM:RPG: Usage: smrpg_sellupgrade <player name | #userid | steamid> <upgrade shortname>");
		return Plugin_Handled;
	}
	
	decl String:sPlayer[64];
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	TrimString(sPlayer);
	new iTarget = FindTarget(client, sPlayer, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	decl String:sUpgrade[MAX_UPGRADE_SHORTNAME_LENGTH];
	GetCmdArg(2, sUpgrade, sizeof(sUpgrade));
	TrimString(sUpgrade);
	StripQuotes(sUpgrade);
	new upgrade[InternalUpgradeInfo];
	if(!GetUpgradeByShortname(sUpgrade, upgrade) || !IsValidUpgrade(upgrade))
	{
		ReplyToCommand(client, "SM:RPG: There is no upgrade with name \"%s\".", sUpgrade);
		return Plugin_Handled;
	}
	
	new iIndex = upgrade[UPGR_index];
	new iOldLevel = GetClientUpgradeLevel(iTarget, iIndex);
	
	if(iOldLevel <= 0)
	{
		ReplyToCommand(client, "SM:RPG sellupgrade: %N doesn't have %s", iTarget, upgrade[UPGR_name]);
		return Plugin_Handled;
	}
	
	if(!TakeClientUpgrade(iTarget, iIndex))
	{
		ReplyToCommand(client, "SM:RPG sellupgrade: Upgrade refused to downgrade.");
		return Plugin_Handled;
	}
	
	// Full refund!
	SetClientCredits(iTarget, GetClientCredits(iTarget) + GetUpgradeCost(iIndex, iOldLevel));
	
	ReplyToCommand(client, "SM:RPG sellupgrade: %N now has %s Level %d (previously Level %d)", iTarget, upgrade[UPGR_name], GetClientUpgradeLevel(iTarget, iIndex), iOldLevel);
	
	return Plugin_Handled;
}

public Action:Cmd_SellAll(client, args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "SM:RPG: Usage: smrpg_sellall <player name | #userid | steamid>");
		return Plugin_Handled;
	}
	
	decl String:sPlayer[64];
	GetCmdArg(1, sPlayer, sizeof(sPlayer));
	TrimString(sPlayer);
	new iTarget = FindTarget(client, sPlayer, false, false);
	if(iTarget == -1)
		return Plugin_Handled;
	
	new iSize = GetUpgradeCount();
	new upgrade[InternalUpgradeInfo];
	for(new i=0;i<iSize;i++)
	{
		GetUpgradeByIndex(i, upgrade);
		if(!IsValidUpgrade(upgrade) || !upgrade[UPGR_enabled])
			continue;
		
		while(GetClientUpgradeLevel(iTarget, i) > 0)
		{
			if(TakeClientUpgrade(iTarget, i))
				break;
			SetClientCredits(iTarget, GetClientCredits(iTarget) + GetUpgradeCost(i, GetClientUpgradeLevel(iTarget, i)));
		}
	}
	
	ReplyToCommand(client, "CSS:RPG sellall: %N has sold all Upgrades and has %d Credits", iTarget, GetClientCredits(iTarget));
	
	return Plugin_Handled;
}

public Action:Cmd_DBDelPlayer(client, args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "SM:RPG: Usage: smrpg_db_delplayer <full name | player db id | steamid>");
		return Plugin_Handled;
	}
	
	decl String:sTarget[64];
	GetCmdArgString(sTarget, sizeof(sTarget));
	TrimString(sTarget);
	StripQuotes(sTarget);
	
	decl String:sQuery[128], iPlayerID;
	// Match as steamid
	if(IsValidSteamID(sTarget))
	{
		new iTarget = FindClientBySteamID(sTarget);
		if(iTarget != -1)
			RemovePlayer(iTarget);
		
		Format(sQuery, sizeof(sQuery), "SELECT upgrades_id, name FROM %s WHERE steamid = '%s'", TBL_PLAYERS, sTarget);
		SQL_TQuery(g_hDatabase, SQL_CheckDeletePlayer, sQuery, client);
	}
	// Match as playerid
	else if(StringToIntEx(sTarget, iPlayerID) && iPlayerID > 0)
	{
		new iTarget = GetClientByPlayerID(iPlayerID);
		if(iTarget != -1)
			RemovePlayer(iTarget);
		
		Format(sQuery, sizeof(sQuery), "SELECT upgrades_id, name FROM %s WHERE player_id = '%d'", TBL_PLAYERS, iPlayerID);
		SQL_TQuery(g_hDatabase, SQL_CheckDeletePlayer, sQuery, client);
	}
	// Match as name
	else
	{
		new iTarget = FindClientByExactName(sTarget);
		if(iTarget != -1)
			RemovePlayer(iTarget);
		
		Format(sQuery, sizeof(sQuery), "SELECT upgrades_id, name FROM %s WHERE name = '%s'", TBL_PLAYERS, sTarget);
		SQL_TQuery(g_hDatabase, SQL_CheckDeletePlayer, sQuery, client);
	}
	return Plugin_Handled;
}

public Action:Cmd_DBMassSell(client, args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "SM:RPG: Usage: smrpg_db_mass_sell <upgrade shortname>");
		return Plugin_Handled;
	}
	
	// TODO: check database for column instead of only currently loaded upgrades?
	decl String:sUpgrade[MAX_UPGRADE_SHORTNAME_LENGTH];
	GetCmdArg(2, sUpgrade, sizeof(sUpgrade));
	TrimString(sUpgrade);
	StripQuotes(sUpgrade);
	new upgrade[InternalUpgradeInfo];
	if(!GetUpgradeByShortname(sUpgrade, upgrade) || !IsValidUpgrade(upgrade))
	{
		ReplyToCommand(client, "SM:RPG: There is no upgrade with name \"%s\".", sUpgrade);
		return Plugin_Handled;
	}
	
	new iIndex = upgrade[UPGR_index];
	
	// Handle players ingame
	new iOldLevel;
	for(new i=1;i<=MaxClients;i++)
	{
		if(!IsClientInGame(i) || !IsClientAuthorized(i))
			continue;
		
		iOldLevel = GetClientUpgradeLevel(i, iIndex);
		if(iOldLevel <= 0)
			continue;
		
		while(iOldLevel > 0)
		{
			if(!TakeClientUpgrade(i, iIndex))
				break;
			SetClientCredits(i, GetClientCredits(i) + GetUpgradeCost(iIndex, iOldLevel--));
		}
	}
	
	// Update all other players in the database
	new Handle:hData = CreateDataPack();
	WritePackCell(hData, client);
	WritePackCell(hData, iIndex);
	
	decl String:sQuery[128];
	Format(sQuery, sizeof(sQuery), "SELECT items_id, %s FROM %s WHERE %s > '0'", upgrade[UPGR_shortName], TBL_UPGRADES, upgrade[UPGR_shortName]);
	SQL_TQuery(g_hDatabase, SQL_MassDeleteItem, sQuery, hData);
	
	return Plugin_Handled;
}

public Action:Cmd_DebugPlayerlist(client, args)
{
	for(new i=1;i<=MaxClients;i++)
	{
		if(!IsClientInGame(i))
			continue;
		
		ReplyToCommand(client, "Player: %N, UserID: %d, Level: %d, Experience: %d/%d", i, GetClientUserId(i), GetClientLevel(i), GetClientExperience(i), Stats_LvlToExp(GetClientLevel(i)));
	}
}

public Action:Cmd_DBWrite(client, args)
{
	SaveAllPlayers();
	ReplyToCommand(client, "SM:RPG db_write: All player data has been saved to the database.");
	return Plugin_Handled;
}

/**
 * SQL callbacks
 */
public SQL_CheckDeletePlayer(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	if(hndl == INVALID_HANDLE || strlen(error) > 0)
	{
		LogError("Error while trying to find player for deletion (%s)", error);
		return;
	}
	
	if(!SQL_GetRowCount(hndl))
	{
		if(client == 0 || IsClientInGame(client))
			ReplyToCommand(client, "SM:RPG db_delplayer: Unable to find the specified player in the database.");
		return;
	}
	
	new iUpgradeID = SQL_FetchInt(hndl, 0);
	if(GetConVarBool(g_hCVSaveData))
	{
		decl String:sQuery[128];
		Format(sQuery, sizeof(sQuery), "DELETE FROM %s WHERE upgrades_id = '%d'", TBL_UPGRADES, iUpgradeID);
		SQL_TQuery(g_hDatabase, SQL_DoNothing, sQuery);
		Format(sQuery, sizeof(sQuery), "DELETE FROM %s WHERE upgrades_id = '%d'", TBL_PLAYERS, iUpgradeID);
		SQL_TQuery(g_hDatabase, SQL_DoNothing, sQuery);
	}
	else
	{
		if(client == 0 || IsClientInGame(client))
		{
			ReplyToCommand(client, "SM:RPG db_delplayer: Notice: smrpg_save_data is set to '0', command had no effect.");
			ReplyToCommand(client, "SM:RPG db_delplayer: Ignore the proceeding message.");
		}
	}
	
	decl String:sName[64];
	SQL_FetchString(hndl, 1, sName, sizeof(sName));
	if(client == 0 || IsClientInGame(client))
		ReplyToCommand(client, "SM:RPG db_delplayer: Player '%s' has been deleted from the database.", sName);
}

public SQL_MassDeleteItem(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	ResetPack(data);
	new client = ReadPackCell(data);
	new iIndex = ReadPackCell(data);
	CloseHandle(data);
	
	if(hndl == INVALID_HANDLE || strlen(error) > 0)
	{
		LogError("Error during mass deletion of item (%s)", error);
		return;
	}
	
	new upgrade[InternalUpgradeInfo];
	GetUpgradeByIndex(iIndex, upgrade);
	
	if(SQL_GetRowCount(hndl) == 0)
	{
		if(client == 0 || IsClientInGame(client))
			ReplyToCommand(client, "SM:RPG db_mass_sell: Nobody has the Upgrade '%s' purchased at any level.", upgrade[UPGR_name]);
		return;
	}
	
	if(GetConVarBool(g_hCVSaveData))
	{
		new iOldLevel, iAddCredits, iItemsID;
		decl String:sQuery[128];
		while(SQL_MoreRows(hndl))
		{
			SQL_FetchRow(hndl);
			
			iItemsID = SQL_FetchInt(hndl, 1);
			
			iOldLevel = SQL_FetchInt(hndl, 2);
			if(iOldLevel < 0)
			{
				DebugMsg("Negative level for upgrade %s in database at itemid %d!", upgrade[UPGR_name], iItemsID);
				iOldLevel = 0;
			}
			if(iOldLevel > upgrade[UPGR_maxLevel])
			{
				DebugMsg("Upgrade level higher than max level of upgrade %s at itemid %d!", upgrade[UPGR_name], iItemsID);
				iOldLevel = upgrade[UPGR_maxLevel];
			}
			
			iAddCredits = 0;
			while(iOldLevel)
				iAddCredits += GetUpgradeCost(iIndex, iOldLevel--);
			
			Format(sQuery, sizeof(sQuery), "UPDATE %s SET %s = '0' WHERE items_id = '%d'", TBL_UPGRADES, upgrade[UPGR_shortName], iItemsID);
			SQL_TQuery(g_hDatabase, SQL_DoNothing, sQuery);
			Format(sQuery, sizeof(sQuery), "UPDATE %s SET credits = (credits + %d) WHERE items_id = '%d'", TBL_UPGRADES, iAddCredits, iItemsID);
			SQL_TQuery(g_hDatabase, SQL_DoNothing, sQuery);
		}
	}
	else
	{
		if(client == 0 || IsClientInGame(client))
			ReplyToCommand(client, "SM:RPG db_mass_sell: Notice: smrpg_save_data is set to '0', command had no effect");
	}
	
	if(client == 0 || IsClientInGame(client))
		ReplyToCommand(client, "SM:RPG db_mass_sell: All (%d) players in the database with Upgrade '%s' have been refunded their credits", SQL_GetRowCount(hndl), upgrade[UPGR_name]);
}

/**
 * Helpers
 */
stock bool:IsValidSteamID(String:sSteamID[])
{
	if(strlen(sSteamID) < 10)
		return false;
	
	if(StrContains(sSteamID, "STEAM_") != 0)
		return false;
	
	new iOffset = 6, bool:bSHITSOURCEPAWN = true;
	for(new repeats=0;repeats<3;repeats++)
	{
		while(bSHITSOURCEPAWN)
		{
			if(!sSteamID[iOffset])
			{
				if(repeats != 2)
					return false;
				else
					break;
			}
			else if(IsCharNumeric(sSteamID[iOffset]))
			{
				iOffset++;
				continue;
			}
			else if(sSteamID[iOffset] == ':')
			{
				iOffset++;
				break;
			}
			else
			{
				return false;
			}
		}
	}
	return true;
}

stock FindClientBySteamID(const String:sSteamID[])
{
	decl String:sTemp[MAX_NAME_LENGTH];
	for(new i=1;i<=MaxClients;i++)
	{
		if(IsClientInGame(i) && IsClientAuthorized(i) && GetClientAuthString(i, sTemp, sizeof(sTemp)))
		{
			if(StrEqual(sSteamID, sTemp))
				return i;
		}
	}
	return -1;
}

stock FindClientByExactName(const String:sName[])
{
	decl String:sTemp[MAX_NAME_LENGTH];
	for(new i=1;i<=MaxClients;i++)
	{
		if(IsClientInGame(i))
		{
			GetClientName(i, sTemp, sizeof(sTemp));
			if(StrEqual(sName, sTemp))
				return i;
		}
	}
	return -1;
}
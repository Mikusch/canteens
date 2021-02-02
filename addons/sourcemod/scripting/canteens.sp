#include <sourcemod>
#include <sdktools>
#include <tf2attributes>

#pragma semicolon 1
#pragma newdecls required

#define DEFAULT_POWERUP_CHARGES	3

enum PowerupBottleType
{
	POWERUP_BOTTLE_NONE, 
	
	POWERUP_BOTTLE_CRITBOOST, 
	POWERUP_BOTTLE_UBERCHARGE, 
	POWERUP_BOTTLE_RECALL, 
	POWERUP_BOTTLE_REFILL_AMMO, 
	POWERUP_BOTTLE_BUILDINGS_INSTANT_UPGRADE, 
	POWERUP_BOTTLE_RADIUS_STEALTH, 
	POWERUP_BOTTLE_SEE_CASH_THROUGH_WALL, 
	
	POWERUP_BOTTLE_TOTAL
};

public Plugin myinfo = 
{
	name = "Set Power Up Canteen Charges", 
	author = "Mikusch", 
	description = "Sets charges on your Power Up Canteen", 
	version = "1.0.0", 
	url = "https://github.com/Mikusch/canteens"
};

public void OnPluginStart()
{
	LoadTranslations("common.phrases.txt");
	LoadTranslations("canteens.phrases.txt");
	
	RegAdminCmd("sm_canteen", ConCmd_SetPowerupBottleCharges, ADMFLAG_ROOT);
}

public Action ConCmd_SetPowerupBottleCharges(int client, int args)
{
	if (client == 0)
	{
		ReplyToCommand(client, "%t", "Command is in-game only");
		return Plugin_Handled;
	}
	
	if (args < 1)
	{
		ReplyToCommand(client, "%t", "SetPowerupBottleCharges_Usage");
		return Plugin_Handled;
	}
	
	PowerupBottleType type;
	int charges = DEFAULT_POWERUP_CHARGES;
	
	char arg[64];
	if (GetCmdArg(1, arg, sizeof(arg)) > 0)
		type = view_as<PowerupBottleType>(StringToInt(arg));
	if (GetCmdArg(2, arg, sizeof(arg)) > 0)
		charges = StringToInt(arg);
	
	int bottle = MaxClients + 1;
	while ((bottle = FindEntityByClassname(bottle, "tf_powerup_bottle*")) != -1)
	{
		if (GetEntPropEnt(bottle, Prop_Send, "m_hOwnerEntity") == client)
		{
			//Clear old powerup(s)
			for (PowerupBottleType i = POWERUP_BOTTLE_NONE; i < POWERUP_BOTTLE_TOTAL; i++)
			{
				char attrib[64];
				if (GetAttributeNameForPowerupType(i, attrib, sizeof(attrib)))
				{
					TF2Attrib_RemoveByName(client, attrib);
				}
			}
			
			if (type == POWERUP_BOTTLE_NONE)
			{
				SetEntProp(bottle, Prop_Send, "m_usNumCharges", 0);
			}
			else
			{
				//Apply powerup
				char attrib[64];
				if (GetAttributeNameForPowerupType(type, attrib, sizeof(attrib)))
				{
					TF2Attrib_SetByName(client, attrib, 1.0);
				}
				else
				{
					ReplyToCommand(client, "%t", "Unknown_Powerup_Type", type);
					return Plugin_Handled;
				}
				
				SetEntProp(bottle, Prop_Send, "m_usNumCharges", charges);
			}
			
			return Plugin_Handled;
		}
	}
	
	ReplyToCommand(client, "%t", "No_PowerupBottle_Equipped");
	return Plugin_Handled;
}

bool GetAttributeNameForPowerupType(PowerupBottleType type, char[] buffer, int maxlen)
{
	switch (type)
	{
		case POWERUP_BOTTLE_CRITBOOST:
		{
			return strcopy(buffer, maxlen, "critboost") > 0;
		}
		case POWERUP_BOTTLE_UBERCHARGE:
		{
			return strcopy(buffer, maxlen, "ubercharge") > 0;
		}
		case POWERUP_BOTTLE_RECALL:
		{
			return strcopy(buffer, maxlen, "recall") > 0;
		}
		case POWERUP_BOTTLE_REFILL_AMMO:
		{
			return strcopy(buffer, maxlen, "refill_ammo") > 0;
		}
		case POWERUP_BOTTLE_BUILDINGS_INSTANT_UPGRADE:
		{
			return strcopy(buffer, maxlen, "building instant upgrade") > 0;
		}
		default:
		{
			return false;
		}
	}
}

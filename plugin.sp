#include <sourcemod>
#include <sdktools>
#include <colors_csgo>

#pragma semicolon 1

#define DEBUG


bool viewadverts[MAXPLAYERS +1];
bool removenextmap[MAXPLAYERS +1];
bool HasUseMenu[MAXPLAYERS +1];
bool canusemenu[MAXPLAYERS +1];

Database g_db;
ConVar g_bonnusmenutype;

const int iHealth = 115;

#define PLUGIN_AUTHOR "DiogoOnAir"
#define PLUGIN_VERSION "1.7"

public Plugin myinfo =
{
	name = "Money Adverts",
	author = PLUGIN_AUTHOR,
	description = "SHOW ADVERTS TO CLIENTS TO WIN MONEY",
	version = PLUGIN_VERSION,
	url = ""
};

public void OnPluginStart()
{
	ConnectToDatabase();
	g_bonnusmenutype = CreateConVar("sm_bonusmenu_type", "1", "Menu Gamemod. AWP = 1 / SURF = 2 OR 0 FOR NO MENU");

	RegConsoleCmd("sm_bonusmenu", Cmd_BonusMenu);
	HookEvent("decoy_firing", OnDecoyFiring);
	HookEvent("round_start", OnRoundStart);
}

public Action OnRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if(g_db == null)
		return;
		
	char Query[255];
	char sIP[16];

	for(int i = 1; i <= MaxClients; i++) if(IsClientInGame(i) && !IsFakeClient(i))
	{
		GetClientIP(i, sIP, 16);
		g_db.Format(Query, sizeof(Query), "SELECT * FROM iplogs WHERE ip = '%s'", sIP);
		g_db.Query(Query_CallBack, Query, GetClientUserId(i));

		continue;
	}
}
public void Query_CallBack(Database db, DBResultSet results, const char[] error, any data)
{
	if (results.RowCount < 1)
		return;
	
	int client = GetClientOfUserId(data);
	if (!client)
		return;
	
	viewadverts[client] = true;
	canusemenu[client] = true;
	removenextmap[client] = true;
	CPrintToChat(client, "{lightgreen}[BONUSMENU]{olive}Thanks for help us!Now you can use the bonusmenu!!Good Luck");
}

public OnMapLoad(int client)
{
	if(removenextmap[client])
    {
          canusemenu[client] = false;
          removenextmap[client] = false;
          viewadverts[client] = false;
    }     
}

public Action Cmd_BonusMenu(int client, int args)
{
	if(canusemenu[client])
	{
		if(HasUseMenu[client])
	    {
		CPrintToChat(client, "{lightgreen}[BONUSMENU]{red}You already used the bonusmenu this round");
        }
		if(g_bonnusmenutype.IntValue == 1)
		{
			if(!HasUseMenu[client] )
			{
				HasUseMenu[client] = true;
				Menu menu = new Menu(AWPMenu);

				menu.SetTitle("BonusMenu");
				menu.AddItem("Grenade", "Grenade Pack");
				menu.AddItem("Health", "+15HP");
				menu.AddItem("Teleport", "Teleport Grenade");
				menu.ExitButton = false;
				menu.Display(client, 15);
			}
		}
		if(g_bonnusmenutype.IntValue == 2)
		{
			if(!HasUseMenu[client])
			{
				HasUseMenu[client] = true;
				Menu menu = new Menu(SurfMenu);

				menu.SetTitle("BonusMenu");
				menu.AddItem("AKDEAG", "AK+DEAGLE");
				menu.AddItem("AWDEAG", "AWP+DEAGLE");
				menu.ExitButton = false;
				menu.Display(client, 15);
			}
		}
	}
	else
	{
		CReplyToCommand(client, "{lightgreen}[BONUSMENU]{olive}To use this command open server website");
	}
	return Plugin_Handled;
}

public int AWPMenu(Menu menu, MenuAction action, int client, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(param2, info, sizeof(info));

			if (StrEqual(info, "Grenade"))
			{
				CPrintToChat( client, "{lightgreen}[BONUSMENU]{olive} You Choosed Bonus Grenades.");
				GivePlayerItem(client, "weapon_flashbang");
				GivePlayerItem(client, "weapon_hegrenade");
				GivePlayerItem(client, "weapon_smokegrenade");
				GivePlayerItem(client, "weapon_molotov");
			}
			else if (StrEqual(info, "Health"))
			{
				SetEntityHealth(client, iHealth);
                //SetEntProp(client, PropType:0, "m_iHealth", iHealth, 4, 0);
				CPrintToChat( client, "{lightgreen}[BONUSMENU]{olive} You choosed more life bonus.");
			}
			else if (StrEqual(info, "Teleport"))
			{
				CPrintToChat( client, "{lightgreen}[BONUSMENU]{olive} You choosed teleport grenade bonus.");
				GivePlayerItem(client, "weapon_decoy");
			}
		}

		case MenuAction_End:{delete menu;}
	}

	return 0;
}

public int SurfMenu(Menu menu, MenuAction action, int client, int param2)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			char info[32];
			menu.GetItem(param2, info, sizeof(info));

			if (StrEqual(info, "AKDEAG"))
			{
				CPrintToChat(client, "{lightgreen}[BONUSMENU]{olive}You Choosed Bonus WeaponPack.");
				GivePlayerItem(client, "weapon_awp");
				GivePlayerItem(client, "weapon_deagle");
			}
			else if (StrEqual(info, "AWDEAG"))
			{
				GivePlayerItem(client, "weapon_ak47");
				GivePlayerItem(client, "weapon_deagle");
				CPrintToChat( client, "{lightgreen}[BONUSMENU]{olive} You choosed bonus WeaponPack.");
			}
		}

		case MenuAction_End:{delete menu;}
	}

	return 0;
}

void ConnectToDatabase()
{
	if(SQL_CheckConfig("advertslog"))
		Database.Connect(CallbackConnect, "advertslog");
	else
		Database.Connect(CallbackConnect, "default");
}

public void CallbackConnect(Database db, char[] error, any data)
{
	if(db == null)
		LogError("Can't connect to server. Error: %s", error);
		
	g_db = db;
}

public void OnDecoyFiring(Event event, const char[] name, bool dontBroadcast)
{
	int userid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(userid);

	float f_Pos[3];
	int entityid = GetEventInt(event, "entityid");
	f_Pos[0] = GetEventFloat(event, "x");
	f_Pos[1] = GetEventFloat(event, "y");
	f_Pos[2] = GetEventFloat(event, "z");

	TeleportEntity(client, f_Pos, NULL_VECTOR, NULL_VECTOR);
	RemoveEdict(entityid);
}
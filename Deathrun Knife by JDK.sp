#include <sourcemod>  
#include <sdktools>  
#include <sdktools_sound>  
#include <cstrike>  
#include <sdkhooks>  
#include <clientprefs>  

#pragma semicolon 1  

#define VERSION "1.0"  

bool option1[MAXPLAYERS+1] = false;
bool option2[MAXPLAYERS+1] = false;
bool option3[MAXPLAYERS+1] = false;
bool option4[MAXPLAYERS+1] = false;

public Plugin:myinfo =  
{  
    name = "Deathrun Knife",  
    author = "Ghostery + SniperHero",  
    description = "Deathrun Knife menu",  
    version = VERSION,  
    url = ""  
};  

public OnPluginStart()  
{  
    LoadTranslations("common.phrases");  

    RegConsoleCmd("sm_cutit", KnifeMenu);  
    RegConsoleCmd("buy", KnifeMenu);  
    RegConsoleCmd("buymenu", KnifeMenu);  
    RegConsoleCmd("autobuy", KnifeMenu);  
    RegConsoleCmd("rebuy", KnifeMenu);  

    // ======================================================================  

    HookEvent( "player_spawn", OnPlayerSpawn );  

}  

public Action:OnPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)  
{  
    new client = GetClientOfUserId( GetEventInt( event, "userid" ));  
    if ( IsValidPlayer( client ))  
    {  
        if(GetClientTeam(client) == CS_TEAM_CT)  
        {  
            new iWeapon = GetPlayerWeaponSlot(client, 2);  
            PrintToChat(client, "\x05[Knife]\x01You spawned with the Default Knife.");  
            SetEntityGravity(client, 1.0);  
            SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);  
            RemovePlayerItem(client, iWeapon), RemoveEdict(iWeapon);  
            new knife = GivePlayerItem(client, "weapon_knife");  
            EquipPlayerWeapon(client, knife);
            option1[client] = true;
            option2[client] = false;
            option3[client] = false;
            option4[client] = false;
            SDKHook(client, SDKHook_WeaponSwitchPost, OnWeaponSwitched);
            KCM(client);  
        }  
    }  
}  

public Action:KnifeMenu(client,args)  
{  
    if(client == 0)  
    {  
        PrintToServer("%t","Command is in-game only");  
        return Plugin_Handled;  
    }  
    else if ( IsPlayerAlive( client ))  
    {  
        if(GetClientTeam(client) == CS_TEAM_CT)  
        {  
            KCM(client);  
        }  
    }  
    else  
    {  
        PrintToChat(client, "\x05[Knife]\x01You can't choose Knife.");  
    }  
    return Plugin_Handled;  
}  

public Action:KCM(clientId)   
{  
    new Handle:menu = CreateMenu(KCMenuHandler);  
    SetMenuTitle(menu, "Deathrun - Knife Menu");  
    AddMenuItem(menu, "option1", "Default [Normal]");  
    AddMenuItem(menu, "option2", "Butcher [Low Gravity]");  
    AddMenuItem(menu, "option3", "Pocket [High Speed]");  
    AddMenuItem(menu, "option4", "VIP [Only vips]");  
    SetMenuExitButton(menu, true);  
    DisplayMenu(menu, clientId, MENU_TIME_FOREVER);  

    return Plugin_Handled;  
}  

public KCMenuHandler(Handle:menu, MenuAction:action, client, itemNum)   
{  
    if ( action == MenuAction_Select )   
    {  
        new String:info[32];  
        new iWeapon = GetPlayerWeaponSlot(client, 2);  
        GetMenuItem(menu, itemNum, info, sizeof(info));  

        if ( strcmp(info,"option1") == 0 )   
        {  
            {  
              PrintToChat(client, "\x05[Knife]\x01You now have Default Knife.");  
              SetEntityGravity(client, 1.0);  
              SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);  
              RemovePlayerItem(client, iWeapon), RemoveEdict(iWeapon);  
              new knife = GivePlayerItem(client, "weapon_knife");  
              EquipPlayerWeapon(client, knife);
              option1[client] = true;
              option2[client] = false;
              option3[client] = false;
              option4[client] = false;
            }  
        }  
        else if ( strcmp(info,"option2") == 0 )   
        {  
            {  
              PrintToChat(client, "\x05[Knife]\x01You now have Butcher Knife.");  
              SetEntityGravity(client, 0.58);  
              SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);  
              RemovePlayerItem(client, iWeapon), RemoveEdict(iWeapon);  
              new knife = GivePlayerItem(client, "weapon_knife");  
              EquipPlayerWeapon(client, knife);
              option1[client] = false;
              option2[client] = true;
              option3[client] = false;
              option4[client] = false;
            }  
        }  
        else if ( strcmp(info,"option3") == 0 )   
        {  
            {  
              PrintToChat(client, "\x05[Knife]\x01You now have Pocket Knife.");  
              SetEntityGravity(client, 1.0);  
              SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.8);  
              RemovePlayerItem(client, iWeapon), RemoveEdict(iWeapon);  
              new knife = GivePlayerItem(client, "weapon_knife");  
              EquipPlayerWeapon(client, knife);  
              option1[client] = false;
              option2[client] = false;
              option3[client] = true;
              option4[client] = false;
            }  
        }  
        else if ( strcmp(info,"option4") == 0 )   
        {  
            {  
              if (IsPlayerVip(client))  
              {  
                PrintToChat(client, "\x05[Knife]\x01You now have VIP Knife.");  
                SetEntityGravity(client, 0.3);  
                SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.8);  
                RemovePlayerItem(client, iWeapon), RemoveEdict(iWeapon);  
                new knife = GivePlayerItem(client, "weapon_knife");  
                EquipPlayerWeapon(client, knife);  
                option1[client] = false;
                option2[client] = false;
                option3[client] = false;
                option4[client] = true;
              }  
              else  
              {  
               PrintToChat(client, "\x05[Knife]\x01 You are not VIP.");  
               KCM(client);  
              }  
            }  
        }  
    }  
}  

public Action:OnWeaponSwitched(client, weapon)  
{  
    decl String:sWeapon[32];  
    GetEdictClassname(weapon, sWeapon, sizeof(sWeapon));  
      
    if( StrEqual(sWeapon, "weapon_knife"))  
    {  
        if(option1[client])
        {
            SetEntityGravity(client, 1.0);  
            SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
        }
        if(option2[client])
        {
            SetEntityGravity(client, 0.58);  
            SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
        }
        if(option3[client])
        {
            SetEntityGravity(client, 1.0);  
            SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.8);
        }
        if(option4[client])
        {
            SetEntityGravity(client, 0.4);  
            SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.5);
        }
    }  
    else
    {
        SetEntityGravity(client, 1.0);  
        SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
    }
      
    return Plugin_Continue;  
}  

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)  
{  
  new client = GetClientOfUserId(GetEventInt(event, "userid"));  

  if (GetClientTeam(client) == 1 && !IsPlayerAlive(client))  
  {  
         return;  
  }  
}  

bool:IsPlayerVip(client)  
{  
    return CheckCommandAccess(client, "flag_vip", ADMFLAG_CUSTOM6, false);  
}  

bool:IsValidPlayer( client )  
{  
    if ( client < 1 || client > MaxClients )  return false;  
    if ( !IsClientConnected( client ))  return false;  
    if ( !IsClientInGame( client ))  return false;  
    if ( IsFakeClient( client ))  return false;  
    return true;  
} 
/************************************************************************
*************************************************************************
[ZPS] Infection Stocks
Description:
	Include for infection-based stocks/natives that can be used to infect,
    disinfect, and/or check player infection status. This include uses
    zpsinfect.gamedata.txt which houses infection-based gamedata for ZPS.
    
Author:
    Mr. Silence
    
*************************************************************************
*************************************************************************
This plugin is free software: you can redistribute 
it and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, either version 3 of the License, or
later version. 

This plugin is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this plugin.  If not, see <http://www.gnu.org/licenses/>.
*************************************************************************
*************************************************************************/
#pragma newdecls required

// Handles for our in-game functions calls that we will use later
Handle g_hInfectPlayerCall = INVALID_HANDLE;
Handle g_hForceInfectPlayerCall = INVALID_HANDLE;
Handle g_hUnInfectPlayerCall = INVALID_HANDLE;

// Setup all of our SDK calls for in-game infection functions. 
// THIS MUST BE CALLED IN ORDER TO INITIALIZE ALL INFECTION CALLS!!!!!
stock bool ZPSInfectionInit()
{
    // Get our gamedata for use in the SDKCalls
    Handle InfectionGameData = LoadGameConfigFile("zpsinfection.gamedata");
    if(InfectionGameData == INVALID_HANDLE)
    {
        SetFailState("Could not read zpsinfection.gamedata gamedata. Please make sure the file exists!");
        return false;
    }

    // Call for ZPS game function CHL2MP_Player::InfectPlayer(float)
    StartPrepSDKCall(SDKCall_Player);
    PrepSDKCall_SetFromConf(InfectionGameData, SDKConf_Virtual, "CHL2MP_Player::InfectPlayer");
    PrepSDKCall_AddParameter(SDKType_Float, SDKPass_ByValue);
    g_hInfectPlayerCall = EndPrepSDKCall();
    if(g_hInfectPlayerCall == INVALID_HANDLE)
    {
        SetFailState("Failed to initalize call: CHL2MP_Player::InfectPlayer!");
        return false;
    }

    // Call for ZPS game function CHL2MP_Player::ForceInfectPlayer(float)
    StartPrepSDKCall(SDKCall_Player);
    PrepSDKCall_SetFromConf(InfectionGameData, SDKConf_Virtual, "CHL2MP_Player::ForceInfectPlayer");
    PrepSDKCall_AddParameter(SDKType_Float, SDKPass_ByValue);
    g_hForceInfectPlayerCall = EndPrepSDKCall();
    if(g_hForceInfectPlayerCall == INVALID_HANDLE)
    {
        SetFailState("Failed to initalize call: CHL2MP_Player::ForceInfectPlayer!");
        return false;
    }

    // Call for ZPS game function CHL2MP_Player::UnInfectPlayer()
    StartPrepSDKCall(SDKCall_Player);
    PrepSDKCall_SetFromConf(InfectionGameData, SDKConf_Virtual, "CHL2MP_Player::UnInfectPlayer");
    g_hUnInfectPlayerCall = EndPrepSDKCall();
    if(g_hUnInfectPlayerCall == INVALID_HANDLE)
    {
        SetFailState("Failed to initalize call: CHL2MP_Player::UnInfectPlayer!");
        return false;
    }
    
    // Close gamedata handle
    CloseHandle(InfectionGameData);
    return true;
}

// Player will be infected, turning into a zombie after <seconds> time.
stock void InfectPlayer(int client, float seconds)
{
    if(!IsPlayerValid(client))
    {
        return;
    }

    SDKCall(g_hInfectPlayerCall, client, seconds);
}

// Player will be forcibly infected, turning into a zombie after <seconds> time.
stock void ForceInfectPlayer(int client, float seconds) 
{
    if(!IsPlayerValid(client))
    {
        return;
    }
    
    SDKCall(g_hForceInfectPlayerCall, client, seconds);
}

// Removes infection from our player.
stock void UnInfectPlayer(int client) 
{
    if(!IsPlayerValid(client))
    {
        return;
    }
    
    SDKCall(g_hUnInfectPlayerCall, client);
}

// Is the player actually infected or not?
stock bool IsPlayerInfected(int client)
{
    return 0 < GetEntData(client, FindSendPropInfo("CHL2MP_Player","m_IsInfected"), 4);
}

// Checks to make sure our player is actually valid or not.
stock bool IsPlayerValid(int client)
{
    // Are they connected, in game, and alive? 
    if (IsClientInGame(client) && IsClientConnected(client) && IsPlayerAlive(client))
    {
        return true;
    }
    
    return false;
}

stock bool IsCarrierZombie(int client) 
{
    if(!IsPlayerValid(client))
    {
        return false;
    }
	
    char weaponName[32];
    GetClientWeapon(client, weaponName, sizeof(weaponName));
    return 0 == strcmp(weaponName, "weapon_carrierarms");
}
/************************************************************************
*************************************************************************
[ZPS] Infection Tookit (used in Pukefection)
Description:
	Gives zombies the ability to puke all over survivors.
    Puke can damage and/or infect survivors (can be set in the configs).
    Binds range between q, c, mouse3, and mouse4 (can be changed in an
    in-game menu available for each player).
    
Original Author:
    Dr. Rambone Murdoch PHD
    http://rambonemurdoch.blogspot.com/

Updated by:
    Kana and Mr. Silence
    
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

// Player will immediately become infected, turning into a zombie after <seconds> time
stock Float:InfectPlayerInXSeconds(ent, Float:seconds) 
{
    if(!(IsClientInGame(ent) && IsPlayerAlive(ent)))
        return 0.0;
    
    new INFECTION_TIME_OFFSET = FindDataMapOffs(ent,"m_tbiPrev");
    
    new Float:turnTime = GetGameTime() + seconds; // time of zombification
    SetEntData(ent, INFECTION_TIME_OFFSET, turnTime)
    SetEntData(ent, FindSendPropInfo("CHL2MP_Player","m_IsInfected"), 1); 
    return turnTime;
}

stock DisinfectPlayer(ent) 
{
    if(!(IsClientInGame(ent) && IsPlayerAlive(ent)))
        return;
    
    SetEntData(ent,FindSendPropInfo("CHL2MP_Player","m_IsInfected"),0);
}

stock bool:PlayerIsInfected(player) 
{
    return 0 < GetEntData(player,FindSendPropInfo("CHL2MP_Player","m_IsInfected"));
}

stock Float:GetPlayerTurnTime(player) 
{
    new INFECTION_TIME_OFFSET = FindDataMapOffs(player,"m_tbiPrev");
    return GetEntDataFloat(player, INFECTION_TIME_OFFSET);
}

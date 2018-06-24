/************************************************************************
*************************************************************************
[ZPS] Pukefection
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
#include <sourcemod>
#include <sdktools>
#include <zpsinfection_stocks>

#define TEAM_HUMAN 2
#define TEAM_ZOMBIE 3
#define PLUGIN_VERSION "3.0"
#define MSG_YOU_CAN_PUKE "** Infectious zombie puke attack! Say /puke to bind a key to pukefection_puke **"

#define PUKE_SOUND_COUNT 6
new String:g_PukeSounds[PUKE_SOUND_COUNT][128] = 
{
	"Zombies/Z_Carrier_Speech/Pain/Zcarrier_Pain-04.wav",
	"Zombies/Z_Carrier_Speech/Pain/Zcarrier_Pain-06.wav",
	"Zombies/Z_Cop/Pain/Pain-01.wav",
	"Zombies/Z_Cop/Pain/Pain-05.wav",
	"Zombies/Z_Male1Speech/Pain/ZMale_Pain2.wav",
	"Zombies/Z_Male1Speech/Pain/ZMale_Pain6.wav"
};

// AirRough-03 had some weird distortion or something
#define WATER_SOUND_COUNT 7
new String:g_WaterSounds[WATER_SOUND_COUNT][128] = 
{
	"Humans/HM_Water/HM_AirRough-01.wav",
	"Humans/HM_Water/HM_AirRough-02.wav",
	"Humans/HM_Water/HM_AirRough-04.wav",
	"Humans/HM_Water/HM_Air-01.wav",
	"Humans/HM_Water/HM_Air-02.wav",
	"Humans/HM_Water/HM_Air-03.wav",
	"Humans/HM_Water/HM_Air-04.wav"
};
		
// cvars
new Handle:g_cvPukefectionEnabled       = INVALID_HANDLE;
new Handle:g_cvPukefectionCarrierOnly   = INVALID_HANDLE;
new Handle:g_cvPukefectionChance        = INVALID_HANDLE;
new Handle:g_cvPukefectionTurnTimeLow   = INVALID_HANDLE;
new Handle:g_cvPukefectionTurnTimeHigh  = INVALID_HANDLE;
new Handle:g_cvPukefectionPukeTime      = INVALID_HANDLE;
new Handle:g_cvPukefectionPukeDelay     = INVALID_HANDLE;
new Handle:g_cvPukefectionPukeRate      = INVALID_HANDLE;
new Handle:g_cvPukefectionPukeRange     = INVALID_HANDLE;
new Handle:g_cvPukefectionParticle      = INVALID_HANDLE;
new Handle:g_cvPukefectionDamage        = INVALID_HANDLE;

// Puke timers
new g_MaxClients;
new Float:g_LastPukeTime[MAXPLAYERS+1];
new Handle:g_PukeTimer[MAXPLAYERS+1];
new g_PukeParticles[MAXPLAYERS+1];

// Menus
new Handle:g_BindMenu = INVALID_HANDLE;

public Plugin:myinfo = 
{
    name = "[ZPS] Pukefection",
    author = "Original: Dr. Rambone Murdoch PhD, Updated by: Kana, Mr.Silence",
    description = "Infectious vomit for zps.",
    version = PLUGIN_VERSION,
    url = "http://rambonemurdoch.blogspot.com/"
}	

///////////////////////////////////
//===============================//
//=====[ EVENTS ]================//
//===============================//
///////////////////////////////////
public OnPluginStart() 
{
    // Create convars. Everything but the plugin convar will be recorded into a config file.
    CreateConVar("pukefection_version", PLUGIN_VERSION, "Pukefection",FCVAR_DONTRECORD|FCVAR_NOTIFY|FCVAR_REPLICATED|FCVAR_SPONLY);
    g_cvPukefectionEnabled = CreateConVar("pukefection_enabled", "1", "Turn on Pukefection.",FCVAR_NOTIFY|FCVAR_REPLICATED);
    g_cvPukefectionCarrierOnly = CreateConVar("pukefection_carrier_only", "0", "Only the carrier zombie may puke.",FCVAR_NOTIFY|FCVAR_REPLICATED);
    g_cvPukefectionChance = CreateConVar("pukefection_chance", "0.1", "Probability a puke hit will infect the survivor.", FCVAR_NOTIFY|FCVAR_REPLICATED, true, 0.0, true, 1.0);
    g_cvPukefectionTurnTimeLow = CreateConVar("pukefection_turn_time_low", "10", "If infected by puke, lower bound on seconds until player turns zombie.", FCVAR_NOTIFY|FCVAR_REPLICATED, true, 0.0);
    g_cvPukefectionTurnTimeHigh = CreateConVar("pukefection_turn_time_high", "45", "If infected by puke, upper bound on seconds until player turns zombie.",FCVAR_NOTIFY|FCVAR_REPLICATED);
    g_cvPukefectionParticle = CreateConVar("pukefection_particle", "blood_advisor_shrapnel_spurt_2", "puke particle effect.",FCVAR_NOTIFY|FCVAR_REPLICATED); 
    g_cvPukefectionPukeTime = CreateConVar("pukefection_time", "5.5", "How long each puke lasts.",FCVAR_NOTIFY|FCVAR_REPLICATED); 
    g_cvPukefectionPukeDelay = CreateConVar("pukefection_delay", "6.0", "Delay between pukes.",FCVAR_NOTIFY|FCVAR_REPLICATED); 
    g_cvPukefectionPukeRate = CreateConVar("pukefection_rate", "0.3", "Interval between infection attacks while puking.",FCVAR_NOTIFY|FCVAR_REPLICATED);
    g_cvPukefectionPukeRange = CreateConVar("pukefection_range", "85.0", "How far the infect attack reaches.",FCVAR_NOTIFY|FCVAR_REPLICATED); 
    g_cvPukefectionDamage = CreateConVar("pukefection_damage", "5.0", "Damage done per hit.",FCVAR_NOTIFY|FCVAR_REPLICATED); 
   
    // Initialize infection info!
    ZPSInfectionInit();
    
    // Create a config file for the plugin
    AutoExecConfig(true, "plugin.pukefection");
    
    // Hook player spawn/death
    HookEvent("player_spawn", Event_PFPlayerSpawn);
    HookEvent("player_death", Event_PFPlayerKilled);
	
    // Precache our sounds
    if(!PrecacheSounds())
    {
        LogMessage("Pukefection couldn't precache all puking sounds");
    }
	
    // Register our commands
    RegConsoleCmd("pukefection_puke", Command_PukefectionPuke);
    RegConsoleCmd("say", OnPukeCmdSay);
    RegConsoleCmd("say_team", OnPukeCmdSay);
}

public OnPluginEnd() 
{
    UnhookEvent("player_spawn", Event_PFPlayerSpawn);
    UnhookEvent("player_death", Event_PFPlayerKilled);
}

public OnMapStart() 
{
    g_MaxClients = GetMaxClients();
    for(new i=1; i <= g_MaxClients; i++) 
    {
        g_LastPukeTime[i] = 0.0;
        g_PukeParticles[i] = -1;
        g_PukeTimer[i] = INVALID_HANDLE;
        if(IsClientInGame(i))
        {
            InitPlayerPukeState(i);
        }
    }
    g_BindMenu = CreatePFKeyBindMenu();
}

public OnMapEnd() 
{
    if(INVALID_HANDLE != g_BindMenu) 
    {
        CloseHandle(g_BindMenu);
        g_BindMenu = INVALID_HANDLE;
    }	
}

public OnClientDisconnect(client) 
{
    // Stop puking and effects.
    StopPlayerPuking(client);
    DeletePukeParticles(client);
    g_LastPukeTime[client] = 0.0;
}

// On player spawn, initialize  our puke state and puke times. 
public Event_PFPlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast) 
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    
    if (client > 0)
    {
        InitPlayerPukeState(client);
        g_LastPukeTime[client] = 0.0; // allow puke attack immediately 
        if(GetConVarBool(g_cvPukefectionEnabled) && GetClientTeam(client) == TEAM_ZOMBIE)
        {
            PrintToChat(client, MSG_YOU_CAN_PUKE);
        }
    }
}

public Event_PFPlayerKilled(Handle:event, const String:name[], bool:dontBroadcast) 
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    StopPlayerPuking(client);
    DeletePukeParticles(client);
}

/////////////////////////////////
//=============================//
//=====[ Actions ]=============//
//=============================//
/////////////////////////////////
public Action:Command_PukefectionPuke(client, args) 
{
    // quit if not enabled
    if(!GetConVarBool(g_cvPukefectionEnabled))
    {
        return Plugin_Handled;
    }
	
    // quit if not zombie or dead
    if(!IsPlayerAlive(client) || GetClientTeam(client) != TEAM_ZOMBIE)
    {    
        return Plugin_Handled;
    }
	
    // quit if in carrier only mode and client isn't the carrier
    if(GetConVarBool(g_cvPukefectionCarrierOnly) && !IsCarrierZombie(client))
    {
        return Plugin_Handled;
    }
	
    new Float:curTime = GetGameTime();
    
    // quit if not enough time has elapsed since last puke
    if(curTime < g_LastPukeTime[client] + GetConVarFloat(g_cvPukefectionPukeDelay))
    {
        return Plugin_Handled;
    }
    
    // quit if already puking
    if(g_PukeTimer[client] != INVALID_HANDLE)
    {
        return Plugin_Handled;
    }
    
    // drop loads
    g_LastPukeTime[client] = curTime;
    StartPlayerPuking(client);
    return Plugin_Handled;
}

public Action:ControlPukefectionAttack(Handle:timer, any:client) 
{
    if(!CanPuke(client)) 
    {
        StopPlayerPuking(client);
        return;
    }
    
    PukefectionAttack(client);
    
    // has the puking gone on long enough?
    new Float:curTime = GetGameTime();
    if(curTime - g_LastPukeTime[client] > GetConVarFloat(g_cvPukefectionPukeTime)) 
    {
        StopPlayerPuking(client);
    }
}

public Action:OnPukeCmdSay(client, args) 
{ 
    decl String:text[192];
    GetCmdArg(1, text, sizeof(text));
    TrimString(text);
    if(!StrEqual(text, "/puke")) 
    {
        return Plugin_Continue;
    }
    
    // they want pukefection info
    DisplayMenu(g_BindMenu, client, 30);
    return Plugin_Handled;
}


///////////////////////////////////
//===============================//
//=====[ FUNCTIONS ]=============//
//===============================//
///////////////////////////////////
/**************
* Puke States *
***************/
InitPlayerPukeState(client) 
{
    AttachPukeParticles(client);
    g_LastPukeTime[client] = 0.0; // allow puke attack immediately 
}

StartPlayerPuking(client) 
{
    EmitPukeSoundRandom(client);
    g_PukeTimer[client] = CreateTimer(GetConVarFloat(g_cvPukefectionPukeRate), ControlPukefectionAttack, client, TIMER_REPEAT);
    if(!AcceptEntityInput(g_PukeParticles[client], "start"))
    {
        PrintToConsole(client, "Couldn't start particles");
    }
    g_LastPukeTime[client] = GetGameTime();
}

StopPlayerPuking(client) 
{
    new Handle:timer = g_PukeTimer[client];
    if(g_PukeParticles[client] != -1) 
    {
        AcceptEntityInput(g_PukeParticles[client], "stop");
    }
    if(timer != INVALID_HANDLE) 
    {
        KillTimer(timer);
        g_PukeTimer[client] = INVALID_HANDLE;
    }
}

bool:CanPuke(client) 
{
    if(!IsPlayerValid(client))
    {
        return false;
    }
	
    new team = GetClientTeam(client);
    if(team != TEAM_ZOMBIE)
    {
        return false;
    }
        
    return true;
}

/*****************
* Sound Emittion *
******************/
EmitPukeSoundRandom(client) 
{
    if(GetClientTeam(client) == TEAM_HUMAN) 
    {
        EmitWaterSoundRandom(client)
    } 
    else 
    {
        EmitSoundToAll(g_PukeSounds[GetRandomInt(0, PUKE_SOUND_COUNT - 1)], client);
    }
}

EmitWaterSoundRandom(client) 
{
    EmitSoundToAll(g_WaterSounds[GetRandomInt(0, WATER_SOUND_COUNT - 1)], client);
}

bool:PrecacheSounds() 
{
    new bool:bCleanLoad = true;
    for(new i=0; i < PUKE_SOUND_COUNT; i++) 
    {
        bCleanLoad = bCleanLoad && PrecacheSound(g_PukeSounds[i]);
    }
    for(new i=0; i < WATER_SOUND_COUNT; i++) 
    {
        bCleanLoad = bCleanLoad && PrecacheSound(g_WaterSounds[i]);
    }
    return bCleanLoad;
}

/*****************
* Puke Particles *
******************/
// Derived from code by "L. Duke" at http://forums.alliedmods.net/showthread.php?t=75102
AttachPukeParticles(ent) 
{
    new particle = CreateEntityByName("info_particle_system");
    decl String:tName[32];
    decl String:sysName[32];
    decl String:particleName[128];
    if (IsValidEdict(particle))
    {
        new Float:pos[3];
        new Float:eyeAngles[3];
        GetClientEyeAngles(ent, eyeAngles);
        GetEntPropVector(ent, Prop_Send, "m_vecOrigin", pos);
        TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
        GetConVarString(g_cvPukefectionParticle, particleName, sizeof(particleName));
        Format(sysName, sizeof(sysName), "pukefection%d", ent);
        GetEntPropString(ent, Prop_Data, "m_iName", tName, sizeof(tName));
        
        if(StrEqual(tName, "")) 
        {
            Format(tName, sizeof(tName), "pukeplayerent%d", ent);
            DispatchKeyValue(ent, "targetname", tName);
        }

        DispatchKeyValue(particle, "targetname", sysName);
        DispatchKeyValue(particle, "parentname", tName);
        DispatchKeyValue(particle, "scale", "1000");
        DispatchKeyValue(particle, "effect_name", particleName);
        eyeAngles[1] += 90; // rotate for the spurt effect
        eyeAngles[0] += 90; 
        eyeAngles[2] += 180;	
        DispatchKeyValueVector(particle, "angles", eyeAngles);
        
        DispatchSpawn(particle);
        SetVariantString(tName);
        AcceptEntityInput(particle, "SetParent", particle, particle, 0);
        GetEntPropVector(particle, Prop_Send, "m_vecOrigin", pos);
        pos[2] -= 6.5; // move the particle emitter to the mouth, subjective
        SetEntPropVector(particle, Prop_Send, "m_vecOrigin", pos);
        SetVariantString("anim_attachment_head");
        AcceptEntityInput(particle, "SetParentAttachmentMaintainOffset", particle, particle, 0);
        ActivateEntity(particle);
        g_PukeParticles[ent] = particle;
    } 
    else 
    {
        LogError("AttachPukeParticles: could not create info_particle_system");
    }
}

DeletePukeParticles(client) 
{
    new particle = g_PukeParticles[client];
    if(g_PukeParticles[client] != -1 && IsValidEntity(particle)) 
    {
        RemoveEdict(particle);
    }
    g_PukeParticles[client] = -1;
}

GivePukeDamagePlayer(victim) 
{
    new health = GetClientHealth(victim);
    health -= GetConVarInt(g_cvPukefectionDamage);
    health = health >= 1 ? health : 1; // don't allow death by puke?
    SetEntityHealth(victim, health);
}

/**************
* Puke Attack *
***************/
public PukefectionAttack(attacker) 
{
    //PrintToConsole(attacker, "Pukefection - Puke attack!");
    new Float:vStart[3];
    new Float:vAng[3];
    new Float:vEnd[3];
    GetClientEyePosition(attacker, vStart);
    GetClientEyeAngles(attacker, vAng);
    GetAngleVectors(vAng, vEnd, NULL_VECTOR, NULL_VECTOR);
    ScaleVector(vEnd, GetConVarFloat(g_cvPukefectionPukeRange));
    AddVectors(vStart, vEnd, vEnd);
    TR_TraceRayFilter(vStart, vEnd, MASK_SHOT, RayType_EndPoint, TraceRayDontHitSelf, attacker);
    if(!TR_DidHit()) 
    {
        return; // no one to potentially infect
    }
    
    new victim = TR_GetEntityIndex();
	
    // return if not human
    if(victim==0 || victim > GetMaxClients() || GetClientTeam(victim) != TEAM_HUMAN)
    {
        return;
    }

    // Close enough?
    new Float:hitPos[3];
    TR_GetEndPosition(hitPos);
    SubtractVectors(hitPos, vStart, hitPos);
    new Float:hitDist = GetVectorLength(hitPos);
    if(hitDist > GetConVarFloat(g_cvPukefectionPukeRange))
    {
        return;
    }
	
    // They're hit!
    GivePukeDamagePlayer(victim);
	
    // Quit if they're already infected
    if(IsPlayerInfected(victim))
    {
        return;
    }
    
    // If the chance to become infected is less than to what we generated randomly, we escape infection
    if(GetConVarFloat(g_cvPukefectionChance) < GetRandomFloat(0.0, 1.0))
    {
        return;
    }
	
    // Make our puking sounds
    EmitWaterSoundRandom(victim); // glub glub 	
    
    // Infect target based on high/low time intervals
    new Float:turnTime = GetRandomFloat(GetConVarFloat(g_cvPukefectionTurnTimeLow),GetConVarFloat(g_cvPukefectionTurnTimeHigh));
    InfectPlayer(victim, turnTime);
	
    // Possibly give the infected a chance to escape zombies so they might join up with a group of survivors
    SetEntDataFloat(victim, FindSendPropInfo("CHL2MP_Player", "m_fFatigue"), 0.0);
}

// Check our data to check that the entity we "hit" is not itself
public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
    if(entity == data)
    {
        return false;
    }
    return true;
}

/*****************
* Key Bind Menus *
******************/
public Handle:CreatePFKeyBindMenu() 
{
    // TODO: created binderhelper which generalizes this, leave anyways?
    new Handle:bindMenu = CreateMenu(Menu_PFSelectKeyBind);
    SetMenuTitle(bindMenu, "Select a key for Pukefection:");
    AddMenuItem(bindMenu, "q", "q");
    AddMenuItem(bindMenu, "c", "c");
    AddMenuItem(bindMenu, "MOUSE3", "Middle mouse button");
    AddMenuItem(bindMenu, "MOUSE4", "Side mouse button (thumb)");
    return bindMenu;
}

public Menu_PFSelectKeyBind(Handle:menu, MenuAction:action, param1, param2) 
{
    if(action == MenuAction_Select) 
    {
        decl String:choice[32];
        GetMenuItem(menu, param2, choice, sizeof(choice));
        PrintToChat(param1, "Binding puke to %s", choice);
        ClientCommand(param1, "bind %s pukefection_puke", choice);
    } 
}
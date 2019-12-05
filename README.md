# Pukefection
This is an updated/modified version of the Pukefection/Pukemod plugin for ZPS originally created by Dr. Rambone Murdoch, PhD. This version of the plugin has been updated for ZPS 3.1 and uses the same ZPS infection stocks/gamedata found here: https://github.com/Silenci0/ZPSInfectionStocks

# Cvars
These are the cvars present in the plugin and can be edited from the configuration file:

- `pukefection_version` - Pukefection Version.
- `pukefection_enabled` - Enables Pukefection. Default value: "1"
- `pukefection_carrier_only` - Only allow puking for the carrier zombie. Default value: "0"
- `pukefection_chance"` - Probability a puke hit will infect the survivor. Default value: "0.1" (10% chance)
- `pukefection_turn_time_low` - If infected by puke, lower bound on seconds until player turns zombie. Default value: "10"
- `pukefection_turn_time_high` - If infected by puke, upper bound on seconds until player turns zombie. Default value: "45"
- `pukefection_particle` - Puke particle effect. Default value: "blood_advisor_shrapnel_spurt_2"
- `pukefection_time` - How long each puke lasts. Default value: "5.5"
- `pukefection_delay` - "Delay between pukes. Default value: "6.0"
- `pukefection_rate` - Interval between infection attacks while puking. Default value: "0.3" (30% chance)
- `pukefection_range` - How far the infect attack reaches in hammer units. Default value: "85.0"  
- `pukefection_damage` - Damage done per hit. Default value: "5.0"

# Changelog
3.1.0 Update (12-05-2019)
------------------------------------
- Updated plugin code to use the new syntax.
- Updated the zpsinfection_stocks include.
- Updated descriptions of some of the cvars in the configuration file.
- Compiled plugins for SM 1.10


3.0 Update (06-22-2018)
-----------------
- All code updated to SM 1.8 (current stable version). It will work with SM 1.8 and later versions.
- Updated code to be compatible with ZPS 3.0
- Updated code to utilize ZPS Infection Stocks instead of the zpsinfect include.
- Fixed a condition where the plugin would check to see if the world was capable of puking (that would be hilarious if it could).
- Fixed an issue with pukefection's infection chance not properly being used to determine if infection would occur or not as a result of puking.
- Removed pre-transform puking feature from the plugin due to buggy behavior. Since the feature relied upon the ability to get a user's infection time (requiring another timer) and did not do anything other than indicate when a user was about to transform, it was not necessary.
- Plugin is compatible with the cure infection plugin.
- Minor fixes and syntax changes. 


2.2 Initial Commit (09-03-2016)
-----------------
- All code based on Dr. Rambone Murdoch PHD's pukefection code
- Fixed the issue with some of the crashes that were prevailent in the old code.
- Fixed the issue with infection not working correctly.
- Made the plugin create its own configuration file with all the editable cvars.
- Re-tabbed all code. 1 Tab = 4 whitespaces.
- General clean up of code.
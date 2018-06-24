# Pukefection
Pukefection/Pukemod for ZPS.

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
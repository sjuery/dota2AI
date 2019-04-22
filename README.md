# Dota 2 AI

A simple dota 2 bot we wrote for a school tournament. Tournament will be hosted on twitch next week (Ill post the link later).

## Description

Just a bot we decided to build for fun. The main idea of the bot was to go with starts other bots wouldn't expect. We began by looking at Meme strats like pushing people on top of rocks so they wouldn't be able to escape unless they had hardcoded something to escape that very niche situation. But then opted for an extreme push start. Where our bots would push so hard on both sides that the opponents wouldn't be able to kill both our lanes without abandoning one. We would then get mega creeps and end early. This lead to some very interesting matches where we would win a game with 100 deaths and 0 kills. Later we slightly improved the combat so the results wouldn't be so embarassing.

## Process

1) Learnt some of the basics of LUA
2) Started off by learning the [dota2 API](https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting)
3) Learnt more advanced LUA by messing around with the API
4) Implemented a priority system getting each bot to access its situation and decide what they needed to do
5) Improved the priority system into a state-machine to improve performance
6) Implemented specific priorities for specific heroes (Such as abilities, item builds...)
7) General improvements to the combat and pushing mechanics as well as tweaks to the priority values

### Installing

Install Dota 2
Head over to:
'/c/Program Files (x86)/Steam/steamapps/common/dota 2 beta/game/dota/scripts/vscripts' on windows
'~/.steam/steam/steamapps/common/dota 2 beta/game/dota/scripts/vscripts' on linux/mac
And clone the repo making sure to call it 'bots'

## Running the bots

In steam go right click dota 2 and select properties.
Press launch options and type in -console.
This will allow you to access the console using '\'
All console commands can be found [here](https://dota2.gamepedia.com/List_of_Console_Commands)
Launch dota.
Create a custom lobby and advanced settings.
Set both sides difficult to unfair.
Change one of the sides bot to Local Dev Script
Select fill all empty slots with bots.
And begin.

## Authors

* **Stanislas Juery** - (https://github.com/sjuery)
* **Logan Kaser** - (https://github.com/logankaser)
* **Eliot vanHeumen** - (https://github.com/eliotv)

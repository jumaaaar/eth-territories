# TERRITORIES / TURFWAR SCRIPT FOR ESX
Enhance your server with a dynamic Turf War system! This script integrates seamlessly with ESX and OX Lib Zones to offer competitive turf capture gameplay.

# Requirements
* [ox_lib](https://github.com/overextended/ox_lib)
* [eth-gangs](https://github.com/jumaaaar/eth-gangs) - OPTIONAL(You can still use your own gang script)

# Features

* Multiple Territories Configuration: Configure multiple territories for gangs to capture and defend, with specific attributes for each territory.
* Custom Capture Times and Rewards: Set custom capture times and rewards for each territory to create unique challenges and incentives.
* Dynamic Gang Defense System: Territories track the number of gang members within, with the largest gang presence controlling the turf if already owned. You can customize how gangs will receive rewards in sv_functions.lua.
* Free-for-All Capture Mode: When a territory capture is triggered, any gang can join the conflict. There are no restrictions on gang participation, allowing for intense battles for control.
* Winner Determination: The winner of the territory will be based on which gang has the most members inside the zone at the end of the capture event. This dynamic encourages collaboration and strategy among gang members.
* Vehicle Restrictions: Vehicles are not allowed within the territory during capture attempts. If a player enters the territory while in a vehicle, they will be automatically kicked out to ensure fairness and maintain the competitive environment.


# Installation
1. Download and Install: Download the eth-territories resource and place it in your server's resources folder.
2. Database Setup: Execute the included SQL file to set up the necessary database tables.
3. Server Configuration: Add start eth-territories to your server.cfg file.
4. Launch: Start your server to load the new Turf War system.

# [SHOWCASE](https://www.youtube.com/watch?v=s-kTywBlCdA)

With this script, players can battle for territory control and enjoy exciting turf-based rewards. Enjoy!
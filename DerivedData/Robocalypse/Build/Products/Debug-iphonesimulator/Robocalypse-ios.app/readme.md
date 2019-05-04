#Robocalypse

Robocalypse is a Swift5+SpriteKit implementation of the classic game "Chase", better known to (older) Mac users as "Daleks" and to Unix users as "robots". This app is purely an experiment to learn Swift and SpriteKit in modern XCode.

It is licensed under the MIT License.

##Gameplay

The game is turn-based, with an option to force turns in a given time ('realtime" mode). During each turn, the user can normally move in one of eight directions. After the player moves, the enemies on the screen will move towards the player. If the player touches any object, they lose the game.

The game is won by manuvering around the screen so that the ever-approaching enemies collide with other objects first. Depending on the selected options, the collisions can be with the other enemies on the map, other objects, or both.

There are two optional "hail mary" moves. Teleport will move the player to a random location on the board, but that may be next to or on top of a deadly object. Additionally, the optional Screwdriver can be used to kill any enemies within one space of the player.

If the player destroys all the enemies on the map, the game moves onto a new map, normally with more enemies on it.

##Options

Robocalypse traces its history to an early 1970s game known as "Chase" written in BASIC on the DTSS operating system on the GE-635 mainframe. It was on this platform that BASIC was first created, and many of the mainframe games that survive to this day came from the early experiments on this machine. The original author remains unknown, but it was quickly ported to other BASIC platforms and began to spread. Over time, dozens of new versions of were spawned. Robocalypse provides options that allow you to closely match many of these historical versions.

###There are some purely display-related options:

Icons - allows the user to select among several sets of icons.

Show grid - turns on a background grid, which is normally on.

Fence - places an electrified fence around the outside of the map. This has no real effect on gameplay, besides making the available movement area slightly smaller. This option is included to match the layout of some versions of the game.

###There are also a number of options that have an effect on the gameplay:

Grid size - the number of spaces in X and Y for the grid, normally set when selecting a game mode.

Piles - places a number of deadly objects on the map at the start of the game.

Collisions - sets whether the enemies will die when they collide with each other.

Tank - a single unkillable enemy. If present, the game ends when this is the only enemy remaining.

Teleport - whether the user can teleport or not, and how many times per round.

Screwdriver - whether or not the user can use the Screwdriver as a last-ditch defense.

Realtime - forces turns in a selected time by entering a "do nothing" move for the user if they do not move on their own.

##Modes
The game has four pre-rolled sets of options that match various historical versions of the game:

Chase - ASCII icons, Grid 20x10, Fence on, Piles on, Collisions off, Tank off, Teleport on, Screwdriver off, Realtime off
Escape! - Soldier icons, Grid 30x15, Fence on, Piles on, Collisions on, Tank on, Teleport on, Screwdriver off, Realtime on
robots  - Robot icons, Grid 60x22, Fence off, Piles off, Collisions on, Tank off, Teleport on, Screwdriver off, Realtime off
Daleks  - Robot icons, Grid 32x18, Fence off, Piles off, Collisions on, Tank off, Teleport on, Screwdriver on, Realtime off

Each version tracks high-scores separately. If any of the options are changed after selecting one of the pre-rolled sets, the game type changes to "Custom" and saves the high-score separetely.

##Design notes

The original game stores all of the objects 2D array, a string array on most platforms, but numerical on those that don't have string arrays like the early TRS-80. The map is redrawn by printing out this array.

However, cannonical SpriteKit programs generally use the SKScene itself as the container. That is, instead of having an object collection somewhere in your own code, instead, you put the objects in the SKScene and then use enumerateChildNodes to find them. I believe this is a way to reduce the chance that you have an unreleased pointer somewhere, I haven't seen an explaination about why you should do this.

As the primary aim of this program was to learn SceneKit, I originally wrote it to store all the objects in the Scene. However, this made the program logic almost unrecognizable compared to the original. For someone who's looking to port the code to another platform, it made it a lot less useful. I then rewrote it using a 2D array similar to the original BASIC versions, but then found it was difficult to track objects from turn to turn to animate their motion - is the robot now at 2,2 the one originally at 1,1 or 1,3?

The system presented here thus separates the logic from the display, so the core logic no longer looks like the original BASIC code in that it lacks anything like a map. The map is up to the UI to provide. For instance, in the CLI version the various objects in the game are translated into a 2D array which is printed, while the SpriteKit version creates permanent sprites and moves them from turn to turn.

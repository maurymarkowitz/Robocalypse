# Robocalypse
Swift+SpriteKit version of the classic game Chase!

[Chase!](https://en.wikipedia.org/wiki/Chase_(video_game)) has been around since the early to mid-1970s - I've spend more than a little time trying to track down the original author without luck but I can trace it to at least January 1976 when a port to the Honeywell 6000 was published in *Creative Compuing*. It's been ported to hundreds of platforms since and continues to appear to this day.

Play is simple: you will be placed in a grid-based board along with a number of robots and "piles". Every turn you can move in one of the eight cardinal directions, indicated by the arrows around the player's position. After every move, the robots will also move one of these directions, always toward you. If one touches you, game over. If they run into each other, or a pile, they are destroyed. Try to move so they collide to stay alive.

Once per round you can teleport to a random location. That might be right beside a robot, so use this only when absolutely required. If it is clear you have manuvered so that all the remaining robots will collide, you can use the last stand to fast forward through the round.

I wrote this just to teach myself some basic Swift programming with SpriteKit, its not meant to be polished!

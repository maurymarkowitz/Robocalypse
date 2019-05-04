/**
 * Game.swift
 * Robocalypse
 *
 * Copyright (c) 2018 Maury Markowitz
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

//References for various options

//Chase
//https://archive.org/details/Creative_Computing_v02n01_Jan-Feb1976
//https://www.atariarchives.org/morebasicgames/showpage.php?page=26

//Escape!
//https://archive.org/details/creativecomputing-1982-08
//http://macintoshgarden.org/games/escape

//Daleks forever
//https://www.emaculation.com/forum/viewtopic.php?t=7255
//http://www.nonanone.com/Daleks/About%20Daleks.html

//robots
//https://arp242.net/robots/#

// grid sizes:
// Chase! in More Computer Games = 20,10
// Escape! in TRS-80 = 30,15
// Robots in JS = 59,22
// Daleks original = 31,18

/// Game contains the code related to the overall game state and rules. This includes
/// the player, the enemies, piles, the score, and the various options that change
/// depending on the version of the game selected by the user.
class Game {
  /// Basic struct for X,Y locations
  //typealias Location = (x:Int,y:Int)
  struct Location {
    var x: Int
    var y: Int
    init(_ x:Int, _ y:Int) {
      self.x = x
      self.y = y
    }
  }
  
  /// This follows the TRS-80 concept that used ints for the objects, and the
  /// map was drawn by looping over the array and converting each int to a
  /// string. in contrast, most implementations used a string array and printed
  /// it out directly. Here we use the int-based concept but add an enum to
  /// improve the readability.
  enum Types: String {
    case empty = "empty"
    case player = "player"
    case robot = "robot"
    case tank = "tank"
    case pile = "pile"
    case fence = "fence"
  }
  
  /// Likewise, this uses the TRS-80 directional compass expressed as an enum.
  /// It starts with 1 on the right and proceeds counter-clockwise to 8, with
  /// teleport being 9 and do-nothing 0. We add 10 for the screwdriver and 11
  /// for last-stand.
  enum Move: String {
    case dontmove = "dontmove"
    case right = "right"
    case upright = "upright"
    case up = "up"
    case upleft = "upleft"
    case left = "left"
    case downleft = "downleft"
    case down = "down"
    case downright = "downright"
    case teleport = "teleport"
    case laststand = "laststand"
    case screwdriver = "screwdriver"
  }

  /// Generic in-game object, which tracks its current and previous location,
  /// an id number, a type (tank, fence, etc.).
  class Object {
    var id: Int = -1
    var type: Types = .empty
    var isDead: Bool = false  // is this object dead? start off alive
    var killedBy: Types = .empty  // what killed us? FIXME: do we need this?
    var location: Location = Location(0,0)
    
    convenience init(x:Int, y:Int) {
      self.init()
      self.location.x = x
      self.location.y = y
    }
  }
  class Player: Object {
    override init() {
      super.init()
      id = 0 // there's always only one player
      type = .player
    }
  }
  class Robot: Object {
    // add a class var for the current max id, starts at 1 because the tank is 0
    static var serial: Int = 1

    // and set the class var on creation
    override init() {
      super.init()
      id = Robot.serial
      Robot.serial += 1
      type = .robot
    }
  }
  class Tank: Object {
    override init() {
      super.init()
      id = 0 // the tank is always 0 if it is present, robots start at 1
      type = .tank
    }
  }
  class Pile: Object {
    // add a class var for the current max id
    static var serial: Int = 1

    // and set the class var on creation
    override init() {
      super.init()
      id = Pile.serial
      Pile.serial += 1
      type = .pile
    }
  }
  class Fence: Pile {
    override init() {
      super.init()
      type = .fence
    }
  }

  /// Struct to organize various start-of-game options.
  struct Options {
    var startingRobots = 5    // the number of robots in level 1
    var levelRobots = 2       // how many more robots are added at each level
    var robotsTeleport = false// when robots collide, do they explode or teleport to new locations
    
    var startingPiles = -1    // if heaps are on, how many should there be? 0 = no piles at the start, -1 means random
    var levelPiles = 0        // how many more piles are added per level?
    
    var hasFence = true       // should the playfield be surrounded by a fence?
    var hasTank = true        // is there a tank on the field?
    
    var timePerMove = 10.0    // how often should they move on their own?
    var realtime = false      // does the user want the game to proceed on its own?
    
    var hasTeleport = true    // if this is true, the user can teleport
    var autoTeleport = false  // if this is true, the player will automatically teleport on contact
    var safeTeleport = false  // is teleport always safe (true)? or can you land on bad things (false)
    var startingTeleports = 2 // how many drivers do you start with
    var levelTeleports = 0    // how many more drivers do you get per level?
    
    var hasScrewdriver = true     // can the user use the screwdriver defense?
    var startingScrewdrivers = 1  // how many drivers do you start with
    var levelScrewdrivers = 0     // how many more drivers do you get per level?
  }
  
  /// Struct to organize current game state.
  struct State {
    var isDead = false        // is the player dead?
    var lastStand = false     // has the user triggered last-stand?

    var timeOfStart = 0.0     // used to display an elapsed time clock
    var timeOfLastMove = 0.0  // when did the robots last move?
    var isPaused = false      // whether or not the game is currently paused

    var teleports = 0         // the number of teleports remaining for this level
    var screwdrivers = 1          // how many sonic screwdrivers are left?
  }

  // details about the game layout, the number of tiles and the size of the map
  var player: Object
  var enemies: [Object]
  var piles: [Object]
  
  //var map: [[Types]] = [[]]      // the game map
  var cols: Int = 30        // these are default values, changed in the prefs
  var rows: Int = 15
  
  // various gamestate related vars
  var level = 1             // the current level
  var score = 0             // current score
  var lastStand = false     // has the user triggered last-stand?
  
  var startingRobots = 5    // the number of robots in level 1
  var levelRobots = 2       // how many more robots are added at each level
  var robotsTeleport = false// when robots collide, do they explode or teleport to new locations
  
  var startingPiles = -1    // if heaps are on, how many should there be? 0 = no piles at the start, -1 means random
  var levelPiles = 0        // how many more piles are added per level?
  
  var hasFence = true       // should the playfield be surrounded by a fence?
  var hasTank = true        // is there a tank on the field?

  var timeOfStart = 0.0     // used to display an elapsed time clock
  var timeOfLastMove = 0.0  // when did the robots last move?
  var timePerMove = 10.0    // how often should they move on their own?
  var realtime = false      // does the user want the game to proceed on its own?
  var isPaused = false      // whether or not the game is currently paused
  
  var hasTeleport = true    // if this is true, the user can teleport
  var autoTeleport = false  // if this is true, the player will automatically teleport on contact
  var safeTeleport = false  // is teleport always safe (true)? or can you land on bad things (false)
  var teleports = 0         // the number of teleports remaining for this level
  var startingTeleports = 2 // how many drivers do you start with
  var levelTeleports = 0    // how many more drivers do you get per level?

  var hasScrewdriver = true     // can the user use the screwdriver defense?
  var screwdrivers = 1          // how many sonic screwdrivers are left?
  var startingScrewdrivers = 1  // how many drivers do you start with
  var levelScrewdrivers = 0     // how many more drivers do you get per level?
  
  var robotPoints = 20      // how many points for killing a robot?
  var movePoints = 1        // how many points for each turn the player survives?
  
  /// Sets up the collections so we don't need to constantly unwrap them
  init() {
    player = Player()
    enemies = [Object]()  // this syntax still gives me the willies
    piles = [Object]()
  }
  
  /// creates the playfield grid, zeros it out, and adds the game objects
  func createMap() {
    // reset level-based counters
    teleports = startingTeleports + ((level - 1) * levelTeleports)
    
    // add the various in-game objects. note the order, the fence and piles are
    // added early so that other objects can be placed around them in safe locations
    //createFence() // the fence can be simulated, it doesn't actually need objects
    createPiles()
    createTank()    // create the tank first so that it's at the front of the enemies list
    createRobots()  // ... and then the rest of the enemies will follow it
    createPlayer()
  }
  
  /// Main logic for the game, called after processing user input. Moves the
  /// player and looks for possible own-goal collision, then moves the enemies
  /// toward the player, testing for collisions with other objects on the map.
  func runGame(input: Move) {
    // player moves first so everyone else knows where to go
    movePlayer(direction: input)
    // if they killed themselves, exit now to prevent other movement
    if player.isDead { return }
    
    // otherwise move everyone else and check again
    moveEnemies()
    if player.isDead { return }
    
    // if they're still not dead, they get points for moving
    score += movePoints
  }
  
  /// Checks whether any of the robot-type enemies are still alive.
  func hasWon() -> Bool {
    // if you died this move, you lose
    if player.isDead { return false }
    
    // otherwise check all the robots
    var isAlive: Bool = false
    for enemy in enemies {
      if enemy.type == .tank { continue } // the tank is always alive, skip it
      if !enemy.isDead { isAlive = true; break }
    }
    return !isAlive
  }
  
  /// Returns an array containing Move values for the directions
  /// that are safe for the player to move in. Useful in GUI-based
  /// versions that want to display which directions are safe and/or
  /// allowed at al.
  // FIXME: these values are in *game coordinates* with 0,0 in the upper
  //    left corner. This matches the layout on macOS, but not iOS where
  //    0,0 is the lower left corner. Thus the code that is calling this
  //    method has to be aware of this and do the appropirate flipping
  func safeMoves() -> [Move] {
    // add all the directions, we'll remove those that are not save
    var safe: Set<Move> = [.up, .down, .left, .right, .upright, .downright, .upleft, .downleft]
    
    // now remove any direction where there's a pile beside the player
    for pile in piles {
      if pile.isDead { continue } // don't check dead piles
      let dx = pile.location.x - player.location.x
      let dy = pile.location.y - player.location.y
      switch (dx, dy) {
      // so for instance, if the X values are the same but the Y is +1, then the
      // pile is one square below the user and that direction is filled
      case (0,1): safe.remove(.down)
      case (0,-1): safe.remove(.up)
      case (1,0): safe.remove(.right)
      case (1,1): safe.remove(.downright)
      case (1,-1): safe.remove(.upright)
      case (-1,0): safe.remove(.left)
      case (-1,1): safe.remove(.downleft)
      case (-1,-1): safe.remove(.upleft)
      default: break // anything else is safe
      }
    }
    
    // now do the same for the enemies, which will start with the tank if present
    for enemy in enemies {
      if enemy.isDead { continue }
      let dx = enemy.location.x - player.location.x
      let dy = enemy.location.y - player.location.y
      switch (dx, dy) {
        // so for instance, if the X values are the same but the Y is +1, then the
      // pile is one square below the user and that direction is filled
      case (0,1): safe.remove(.down)
      case (0,-1): safe.remove(.up)
      case (1,0): safe.remove(.right)
      case (1,1): safe.remove(.downright)
      case (1,-1): safe.remove(.upright)
      case (-1,0): safe.remove(.left)
      case (-1,1): safe.remove(.downleft)
      case (-1,-1): safe.remove(.downright)
      default: break // anything else is safe
      }
    }
    
    // and finally, the fence
    if hasFence {
      if player.location.x == 1 { safe.remove(.left); safe.remove(.upleft); safe.remove(.downleft) }
      if player.location.x == cols - 2  { safe.remove(.right); safe.remove(.upright); safe.remove(.downright) }
      if player.location.y == 1 { safe.remove(.up); safe.remove(.upleft); safe.remove(.upright) }
      if player.location.y == rows - 2 { safe.remove(.down); safe.remove(.downleft); safe.remove(.downright) }
    }

    // all done, convert to an array
    return Array(safe)
}
  
  /// Returns a random location on the map, normally empty.
  func randomLocation(emptyOnly: Bool = true) -> Location {
    // the piles have to be inside the fence if that's turned on
    let Xmin = (hasFence ? 1 : 0)
    let Xmax = (hasFence ? cols-2 : cols-1)
    let Ymin = (hasFence ? 1 : 0)
    let Ymax = (hasFence ? rows-2 : rows-1)
    
    // now loop until you get an empty location inside those bounds and return it
    var X, Y: Int
    if !emptyOnly {
      X = Int.random(in:Xmin...Xmax)
      Y = Int.random(in:Ymin...Ymax)
      return Location(X,Y)
    } else {
      tryagain: while true {
        X = Int.random(in:Xmin...Xmax)
        Y = Int.random(in:Ymin...Ymax)
        // see if the player is at that location, and try again if they're there
        if player.location.x == X && player.location.y == Y {
          continue tryagain // don't NEED a labeled continue here, but for clarity in the following cases...
        }
        // now check all the enemies the same way
        for enemy in enemies {
          if !enemy.isDead && enemy.location.x == X && enemy.location.y == Y {
            continue tryagain // have to use the labeled continue here and below
          }
        }
        // and finally, the piles
        for pile in piles {
          if !pile.isDead && pile.location.x == X && pile.location.y == Y {
            continue tryagain
          }
        }
        // if we make it here, the location is empty
        return Location(X,Y)
      }
    }
  }

  /// Creates a ring of objects around the outside of the map if the fence option is turned on.
  func createFence() {
    if hasFence {
      // draw the lines along the top and bottom across X
      for X in 0..<cols {
        piles.append(Fence(x:X, y:0))
        piles.append(Fence(x:X, y:rows - 1))
      }
      // and then down the sides in Y
      for Y in 0..<rows {
        piles.append(Fence(x:0, y:Y))
        piles.append(Fence(x:cols - 1, y:Y))
      }
    }
  }
  
  /// Creates a number of collision piles at the start of the game
  /// if that option is turned on. this may be represented in-game as
  /// piles, electric pylons, mines, etc. There are two ways this is
  /// laid out, in the orignal Chase and Escape, it's a random layout
  /// with a 1-in-10 chance of being drawn in any location (Chase) or
  /// 1-in-30 (Escape). In later versions it's typicaly a fixed number
  /// of piles, randomly distributed.
  func createPiles() {
    // see if this is a random layout or fixed-number...
    if startingPiles == -1 {
      // this is the random-layout version
      let Xmin = (hasFence ? 1 : 0)
      let Xmax = (hasFence ? cols-2 : cols-1)
      let Ymin = (hasFence ? 1 : 0)
      let Ymax = (hasFence ? rows-2 : rows-1)

      var test: Int
      for Y in Ymin...Ymax {
          for X in Xmin...Xmax {
            // this is the test from Escape, which is really just
            // "did you pick 5 when randomly selecting 0..30"
            // which is equivalent to 1-in-30. Why 5? No idea.
            test = Int.random(in:Xmin...Xmax)
            if test == 5 {
              piles.append(Pile(x:X, y:Y))
          }
        }
      }
    } else {
      // this is the specified-number-of-piles case, which places
      // that many items randomly on the map. the number of piles
      // is based on the start amount and the level amount
      let numPiles = startingPiles + ((level - 1) * levelPiles)
      
      // now add that many piles, being careful to avoid any objects already on the map
      // at this point the only objects are the fence, if present, and other piles
      for _ in 1...numPiles {
        let loc = randomLocation()
        piles.append(Pile(x:loc.x, y:loc.y))
      }
    }
  }
  
  /// Creates a number of "standard" enemies on the map, based on
  /// the user options and level.
  func createRobots() {
    // the number of robots is based on the start amount and the level amount
    let numRobots = startingRobots + ((level - 1) * levelRobots)

    // and add them at random empty locations
    for _ in 1...numRobots {
      let loc = randomLocation()
      enemies.append(Robot(x:loc.x, y:loc.y)) // the convinience init will automatically set the id properly
    }
  }
  
  /// Creates the tank, if that option is turned on.
  func createTank() {
    if hasTank {
      // there's only ever one tank
      let loc = randomLocation()
      enemies.append(Tank(x:loc.x, y:loc.y))
    }
  }
  
  /// Creates the player and places them in a safe location.
  func createPlayer() {
    // and there's only ever one player
    let loc = randomLocation()
    player.location = loc
  }
  
  /// This calculates the new location for the user, and looks to see if there
  /// was a collision with another object.
  func movePlayer(direction: Move) {
    // get the current location of the player
    let oldX = player.location.x
    let oldY = player.location.y
    //let (X,Y) = playerLocation()
    
    // no real need to set these values, but the compiler complains below if you don't
    var newX = oldX
    var newY = oldY
    
    // now calculate the location after the move
    switch direction {
      case .right : newX += 1
      case .upright : newX += 1; newY -= 1
      case .up : newY -= 1
      case .upleft : newX -= 1; newY -= 1
      case .left : newX -= 1
      case .downleft : newX -= 1; newY += 1
      case .down : newY += 1
      case .downright : newX += 1; newY += 1
      case .teleport :
        // first see if they can still do it, otherwise it's a no-move
        if teleports > 0 {
          teleports -= 1
          // select an entirely new location, even on mines and robots
          let tele = randomLocation(emptyOnly: safeTeleport)
          newX = tele.x
          newY = tele.y
        }
        // the next three don't move the user
      case .dontmove : break
      case .screwdriver : break
    case .laststand : lastStand = true; break
    }
    
    // now force the move back to the map limits if it went too far
    if newX <= 0 { newX = 0 }
    if newX >= cols { newX = cols - 1 }
    if newY <= 0 { newY = 0 }
    if newY >= rows { newY = rows - 1 }
    
    // move the player to that location
    player.location.x = newX
    player.location.y = newY

    // now check if this move landed the player on any object
    if hasFence {
      if (newX == 0 || newX == cols - 1) || (newY == 0 || newY == rows - 1) {
        if !player.isDead { player.killedBy = .fence }
        player.isDead = true
      }
    }
    for pile in piles {
      if pile.location.x == newX && pile.location.y == newY {
        if !player.isDead { player.killedBy = .pile }
        player.isDead = true
      }
    }
    for enemy in enemies {
      if !enemy.isDead && enemy.location.x == newX && enemy.location.y == newY {
        if !player.isDead { player.killedBy = enemy.type }
        player.isDead = true
      }
    }
  }
  
  /// Moves all of the robots one step toward the player, and destroys them
  /// if the step on something, or kills the player if they touch it.
  func moveEnemies() {
    // move the robots first
    for enemy in enemies {
      // get the current location for this robot
      let oldX = enemy.location.x
      let oldY = enemy.location.y
      var newX = oldX
      var newY = oldY
      
      // ignore dead robots
      if enemy.isDead { continue }

      // move them one step in the direction of the user, or leave
      // them alone if they're already in the right row/col
      if oldX > player.location.x {
        newX -= 1
      }
      if oldX < player.location.x {
        newX += 1
      }
      if oldY > player.location.y {
        newY -= 1
      }
      if oldY < player.location.y {
        newY += 1
      }
      
      // now force the move back to the map limits if it went too far
      // NOTE: this should never happen, because the robots always move
      //   toward the user and the player can't move off the board. but
      //   better safe than sorry...
      if newX <= 0 { newX = 0 }
      if newX >= cols { newX = cols - 1 }
      if newY <= 0 { newY = 0 }
      if newY >= rows { newY = rows - 1 }
      
      // move the enemy to the new location
      enemy.location.x = newX
      enemy.location.y = newY
    } // move the next one
    
    // now that they have all moved, check for collisions
    for enemy in enemies {
      // if we're dead, there's nothing to test
      if enemy.isDead { continue }
      
      // see if we landed on the player
      if enemy.location.x == player.location.x && enemy.location.y == player.location.y {
        if !player.isDead { player.killedBy = enemy.type } // first one wins
        player.isDead = true
        // don't break, we want the other enemies to collide to animate add to the score
      }
      
      // see if we landed on a pile, if you're the tank you kill the pile,
      // if you're not, the pile killed you
      for pile in piles {
        // deal piles don't kill anything
        if pile.isDead { continue }
        if enemy.location.x == pile.location.x && enemy.location.y == pile.location.y {
          if enemy.type == .tank {
            pile.isDead = true
            break // we can only hit one pile
          } else {
            enemy.isDead = true
            score += robotPoints
            break
          }
        }
      }
      
      // if we're the tank, exit at this point, nothing can kill us
      if enemy.type == .tank { continue }

      // if you're not the tank, see if you landed on another object and decide what to do
      for otherenemy in enemies {
        // skip over ourseleves
        if enemy.id == otherenemy.id { continue }
        // and anything that's already dead
        if otherenemy.isDead { continue }
        
        // see if we collided with the otherenemy
        if enemy.location.x == otherenemy.location.x && enemy.location.y == otherenemy.location.y {
          // what happens now depends on the other enemy type and this flag...
          // the tank always kills you, don't teleport in that case
          if robotsTeleport && otherenemy.type != .tank {
            enemy.location = randomLocation()
            otherenemy.location = randomLocation()
            break
          } else {
            // if the otherenemy was the tank, or we don't teleport, we're dead and turn into a pile
            enemy.isDead = true
            if otherenemy.type != .tank {
              piles.append(Pile(x:enemy.location.x, y:enemy.location.y)) // in this case we make a new pile, even if its on the same location
            }
            score += robotPoints
            break
          }
        } // had collision
      } // otherenemy loop
    } // enemy loop
  } // moveEnemies
} // Game class

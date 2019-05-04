/**
 * Main.swift
 * Robocalypse
 *
 * Provides a simple Foundation-based app to play Robocalypse from the command line.
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

import Foundation

/// Prints rules to the console. Used at the start of the game.
func printRules() {
  print("You are the * on the map, and are being chased by soldiers ($) and the")
  print("tank (&).")
  print("")
  print("You win by causing the soldiers to collide with other objects on the map,")
  print("while avoiding touching any objects including the walls (!) and mines (X).")
  print("")
  print("You move by typing a number from 1 to 8:")
  print("")
  print("4,3,2")
  print("5,*,1")
  print("6,7,8")
  print("")
  print("Typing 0 will leave you where you are for one move.")
  print("As a last resort, you can type 9 to teleport, but this may land you")
  print("on one of the objects and kill you immediately. You can only use the")
  print("jump twice per game.")
  print("If you think you're in a safe location, you can type 11 to run out")
  print("the game.")
  print("")
  print("Press ? to see a short version of these instructions.")
  print("Good luck!")
  print("")
}

/// Prints out a short list of the possible inputs.
func printMoves() {
  print("4,3,2")
  print("5,*,1")
  print("6,7,8")
  print("0=stand,9=teleport,10=last stand")
}

/// Prints out the map to the console using character graphics.
func printMap(_: Game) {
  // make an array to hold all the items and then clear it out
  var map: [[Game.Types]]
  map = Array(repeating: Array(repeating: .empty, count: game.rows), count: game.cols)
  
  // put in the fence
  if game.hasFence {
    // draw the lines along the top and bottom across X
    for X in 0..<game.cols {
      map[X][0] = .fence
      map[X][game.rows - 1] = .fence
    }
    // and then down the sides in Y
    for Y in 0..<game.rows {
      map[0][Y] = .fence
      map[game.cols - 1][Y] = .fence
    }
  }
  
  // and then the piles
  for pile in game.piles {
    map[pile.location.x][pile.location.y] = .pile
  }
  
  // put the player on the map, do this first so the enemies will cover him
  map[game.player.location.x][game.player.location.y] = .player
  
  // now the living enemies
  for enemy in game.enemies {
    if !enemy.isDead {
        map[enemy.location.x][enemy.location.y] = enemy.type
    }
  }
  
  // and then print it out
  for Y in 0..<game.rows {
    print() //add a newline
    for X in 0..<game.cols {
      switch map[X][Y] {
      case .empty: print(" ", terminator: "")
      case .player: print("*", terminator: "")
      case .pile: print("X", terminator: "")
      case .fence: print("!", terminator: "")
      case .tank: print("&", terminator: "")
      case .robot: print("$", terminator: "")
      }
    }
  }
  print() //add a newline
}

// start the game and set up the map
var game = Game()
game.createMap()
printRules()
printMap(game)

// this is the main processing loop
while !game.player.isDead && !game.hasWon() {
  // get the user input and make sure its good
  var move: Game.Move = Game.Move.dontmove
  var goodInput: Bool = false
  while !goodInput {
    print("Your move> ", terminator:"")
    if let typed = readLine() {
      if typed == "?" {
        printMoves()
        continue
      }
      if let num = Int(typed) {
        goodInput = true
        switch num {
        case 0: move = Game.Move.dontmove
        case 1: move = Game.Move.right
        case 2: move = Game.Move.upright
        case 3: move = Game.Move.up
        case 4: move = Game.Move.upleft
        case 5: move = Game.Move.left
        case 6: move = Game.Move.downleft
        case 7: move = Game.Move.down
        case 8: move = Game.Move.downright
        case 9: move = Game.Move.teleport
        case 10: move = Game.Move.laststand
        case 11: move = Game.Move.screwdriver
        default: goodInput = false
        }
      } else {
        print("Bad input, use 0 to 11")
      }
    } // got a line
  } // input is valid
  
  // see if the user selected last-stand, if so, repeatedly press "dontmove"
  if move == Game.Move.laststand {
    print("Running out the game...")
    while !game.hasWon() && !game.player.isDead {
      game.runGame(input: Game.Move.dontmove)
      printMap(game)
    }
  }
  // if its a teleport, see if it's possible
  else if move == Game.Move.teleport {
    if game.teleports == 0 {
      print("No teleports left!")
      game.runGame(input:Game.Move.dontmove)
    } else {
      game.runGame(input:move)
    }
  }
  // otherwise do the move
  else {
    game.runGame(input:move)
  }
  printMap(game)
} // end of main loop

// and print everything one last time
printMap(game)

if game.player.isDead {
  switch game.player.killedBy {
  case .robot: print("A soldier caught you! Your score was", game.score)
  case .tank: print("The tank ran you over! Your score was", game.score)
  case .pile: print("BLAM! You hit a mine. Your score was", game.score)
  case .fence: print("ZAP! You jumped onto the fence! Your score was", game.score)
  default: print("You lose! Your score was", game.score)
  }
  exit(EXIT_SUCCESS)
} else {
  print("You win! Your score was", game.score)
  exit(EXIT_SUCCESS)
}

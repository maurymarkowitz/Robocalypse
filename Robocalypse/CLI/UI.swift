/**
 * UI.swift
 * Robocalypse
 *
 * Contains methods that create the UI for the command-line version of the
 * game. This includes instructions.
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
//
///// Prints rules to the console. Used at the start of the game.
//func printRules() {
//  print("You are the * on the map, and are being chased by soldiers ($) and the")
//  print("tank (&).")
//  print("")
//  print("You win by causing the soldiers to collide with other objects on the map,")
//  print("while avoiding touching any objects including the walls (!) and mines (X).")
//  print("")
//  print("You move by typing a number from 1 to 8:")
//  print("")
//  print("4,3,2")
//  print("5,*,1")
//  print("6,7,8")
//  print("")
//  print("Typing 0 will leave you where you are for one move.")
//  print("As a last resort, you can type 9 to teleport, but this may land you")
//  print("on one of the objects and kill you immediately. You can only use the")
//  print("jump twice per game.")
//  print("If you think you're in a safe location, you can type 11 to run out the game.")
//  print("Press ? to see a short version of these instructions.")
//  print("")
//  print("Good luck!")
//  print("")
//}
//
///// Prints out a short list of the possible inputs.
//func printMoves() {
//  print("4,3,2")
//  print("5,*,1")
//  print("6,7,8")
//  print("0=stand,9=teleport,10=last stand")
//}
//
///// Prints out the map to the console using character graphics. Primarily
///// intended for debugging, but could be used for a "retro mode" or in
///// a playground.
//func printMap(_: Game) {
//  for Y in 0..<game.rows {
//    print() //add a newline
//    for X in 0..<game.cols {
//      switch game.map[X][Y] {
//      case .empty: print(" ", terminator: "")
//      case .player: print("*", terminator: "")
//      case .robot: print("$", terminator: "")
//      case .pile: print("X", terminator: "")
//      case .fence: print("!", terminator: "")
//      case .tank: print("&", terminator: "")
//      }
//    }
//  }
//  print() //add a newline
//}

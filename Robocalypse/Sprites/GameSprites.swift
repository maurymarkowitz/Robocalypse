/**
 * GameSprites.swift
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

import SpriteKit

/// Base class for the various sprites that link to underlying Game objects.
class ObjectSprite: SKSpriteNode {
  static let kSpriteSize = CGSize(width: 16, height: 16)

  // Swift 5 does not support class variables, although static vars
  // are supported. Unfortunately, static vars cannot be overriden
  // in subclasses, which seriously limits their utility. So, instead,
  // we have to us a class method (property) which we can then override
  func kSpriteName() -> String {
    return "nothing"
  }
//  func kSpriteSize() -> CGSize {
//    return CGSize(width: 16, height: 16)
//  }
  func kSpriteSpeed() -> Double {
    return 0.5
  }
  
  // instance var pointing to the Game.Object we represent on-screen,
  // weak so that we don't hold onto it, that's the Game's job
  weak var object: Game.Object?
}

/// Subclass of ObjectSprite that represents the player.
class PlayerSprite : ObjectSprite {
  // override the base methods to customize this subclass
  override func kSpriteName() -> String {
    return "player"
  }
  override func kSpriteSpeed() -> Double {
    return 0.2  // this is the time taken to move, the player moves faster
  }

  init(player:Game.Object, size:CGSize) {
    super.init(texture:SKTexture(imageNamed:"player"), color:SKColor.green, size:size)
    object = player
    name = "player"
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

class RobotSprite : ObjectSprite {
  // override the base methods to customize this subclass
  override func kSpriteName() -> String {
    return "robot" + String(object!.id)
  }
  
  init(robot:Game.Object, size:CGSize) {
    super.init(texture:SKTexture(imageNamed:"soldier"), color:SKColor.gray, size:size)
    object = robot
    name = "robot" + String(object!.id)
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
class TankSprite : ObjectSprite {
  // nothing much changes here
  override func kSpriteName() -> String {
    return "tank"
  }
  init(robot:Game.Object, size:CGSize) {
    super.init(texture: SKTexture(imageNamed:"tank"), color:SKColor.darkGray, size:size)
    object = robot
    name = kSpriteName()
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

/// Subclass of ObjectSprite that represents piles.
class PileSprite : ObjectSprite {
  override func kSpriteName() -> String {
    return "pile" + String(object!.id)
  }
  override func kSpriteSpeed() -> Double {
    return 0.0  // piles don't move
  }
  init(pile: Game.Object?, size: CGSize) {
    super.init(texture: SKTexture(imageNamed:"nuke"), color:SKColor.yellow, size: size)
    object = pile
    name = kSpriteName()
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
/// Subclass of PileSprite for the fence.
class FenceSprite : ObjectSprite {
  override func kSpriteName() -> String {
    return "fence"
  }
  // fences don't have game objects
  init(size: CGSize) {
    super.init(texture: SKTexture(imageNamed:"fence"), color:SKColor.blue, size:size)
    name = kSpriteName()
  }
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}

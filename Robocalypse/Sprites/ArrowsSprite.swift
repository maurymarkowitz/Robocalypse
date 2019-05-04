/**
 * ArrowsSprite.swift
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

/// Creates a compound sprite that displays directional arrows around the
/// player indicating directions.

// FIXME: the buttons are currently positioned using explicit offsets,
//   but these are different on macOS and iOS so there should be a
//   better solution

/// Builds a single sprite from eight ArrowSprites and handles the
/// interaction by (easily) translating the touch to a Game.Move
class ArrowsSprite: SKSpriteNode {
  // this is fairly simple, we make a new sprite, rotate it to point
  // in the right direction, and move it to the right offset
  
  override init(texture:SKTexture!, color:SKColor?, size:CGSize) {
    super.init(texture:nil, color:color!, size:size)
  }
  
  /// Main init() for the compass rose, creates the parent sprite and adds the
  /// arrows to it. Pass in the grid size from the main sprite view, the size
  /// of this spite is 3x that in both directions
  convenience init(size: CGSize) {
    let threex = CGSize(width: size.width * 3.0, height: size.height * 3.0)
    self.init(texture:nil, color:SKColor.clear, size:threex)
    
    self.name = "arrows"
    let arrowsize = CGSize(width: size.width * 2/3, height: size.height * 2/3)
    let offsetx = CGPoint(x:arrowsize.width * 2,y:0)
    let offsety = CGPoint(x:0,y:arrowsize.height * 2)
    let arrowTexture = SKTexture(imageNamed:"Green_Arrow_Up")
    let degtorad:CGFloat = .pi / 180

    // for instance, the up arrow
    let up = SKSpriteNode(texture:arrowTexture)
    up.name = "up"
    up.alpha = 1.0
    up.size = arrowsize
    //up.zRotation = 180 * degtorad
    up.position = self.position + offsety
    self.addChild(up)
    // and then for the down arrow, simply rotate it 180 degrees
    let down = SKSpriteNode(texture:arrowTexture)
    down.name = "down"
    down.size = arrowsize
    down.zRotation = 180 * degtorad
    down.position = self.position - offsety
    self.addChild(down)
    // and so on...
    let left = SKSpriteNode(texture:arrowTexture)
    left.name = "left"
    left.size = arrowsize
    left.zRotation = 90 * degtorad
    left.position = self.position - offsetx
    self.addChild(left)
    let right = SKSpriteNode(texture:arrowTexture)
    right.name = "right"
    right.size = arrowsize
    right.zRotation = -90 * degtorad
    right.position = self.position + offsetx
    self.addChild(right)
    let upleft = SKSpriteNode(texture:arrowTexture)
    upleft.name = "upleft"
    upleft.size = arrowsize
    upleft.zRotation = 45 * degtorad
    upleft.position = self.position - offsetx + offsety
    self.addChild(upleft)
    let upright = SKSpriteNode(texture:arrowTexture)
    upright.name = "upright"
    upright.size = arrowsize
    upright.zRotation = -45 * degtorad
    upright.position = self.position + offsetx + offsety
    self.addChild(upright)
    let downleft = SKSpriteNode(texture:arrowTexture)
    downleft.name = "downleft"
    downleft.size = arrowsize
    downleft.zRotation = 135 * degtorad
    downleft.position = self.position - offsetx - offsety
    self.addChild(downleft)
    let downright = SKSpriteNode(texture:arrowTexture)
    downright.name = "downright"
    downright.size = arrowsize
    downright.zRotation = -135 * degtorad
    downright.position = self.position + offsetx - offsety
    self.addChild(downright)
  }
  // and this just because it's required
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  /// Called in the game loop before the compass is displayed, takes a [Move] and then
  /// changes the textures of the arrows to show which are safe and which aren't.
  //
  // NOTE: the "safe" moves are returned in game coordinates with 0,0 in the upper left,
  //    however, iOS has 0,0 in the lower left. so this has to map them by reversing the
  //    sence of the directions on iOS, which is very annoying
  func update(withMoves: [Game.Move]) {
    let greenTexture = SKTexture(imageNamed:"Green_Arrow_Up")
    let redTexture = SKTexture(imageNamed:"Red_Arrow_Up")

    // here is an example of the inverted test - this should really be
    // turning on and off the up arrow, but on iOS that's on t

    // find the up arrow and then change it as needed
    if let up = childNode(withName: "up") as? SKSpriteNode {
      if withMoves.contains(Game.Move.down) {
        up.texture = greenTexture
        up.alpha = 1
      } else {
        up.texture = redTexture
        up.alpha = 0.75
      }
    }
    // the rest are the same logic
    if let down = childNode(withName: "down") as? SKSpriteNode {
      if withMoves.contains(Game.Move.up) {
        down.texture = greenTexture
        down.alpha = 1
      } else {
        down.texture = redTexture
        down.alpha = 0.75
      }
    }
    if let left = childNode(withName: "left") as? SKSpriteNode {
      if withMoves.contains(Game.Move.left) {
        left.texture = greenTexture
        left.alpha = 1
      } else {
        left.texture = redTexture
        left.alpha = 0.75
      }
    }
    if let right = childNode(withName: "right") as? SKSpriteNode {
      if withMoves.contains(Game.Move.right) {
        right.texture = greenTexture
        right.alpha = 1
      } else {
        right.texture = redTexture
        right.alpha = 0.75
      }
    }
    if let upleft = childNode(withName: "upleft") as? SKSpriteNode {
      if withMoves.contains(Game.Move.downleft) {
        upleft.texture = greenTexture
        upleft.alpha = 1
      } else {
        upleft.texture = redTexture
        upleft.alpha = 0.75
      }
    }
    if let upright = childNode(withName: "upright") as? SKSpriteNode {
      if withMoves.contains(Game.Move.downright) {
        upright.texture = greenTexture
        upright.alpha = 1
      } else {
        upright.texture = redTexture
        upright.alpha = 0.75
      }
    }
    if let downleft = childNode(withName: "downleft") as? SKSpriteNode {
      if withMoves.contains(Game.Move.upleft) {
        downleft.texture = greenTexture
        downleft.alpha = 1
      } else {
        downleft.texture = redTexture
        downleft.alpha = 0.75
      }
    }
    if let downleft = childNode(withName: "downright") as? SKSpriteNode {
      if withMoves.contains(Game.Move.upright) {
        downleft.texture = greenTexture
        downleft.alpha = 1
      } else {
        downleft.texture = redTexture
        downleft.alpha = 0.75
      }
    }
  }
}

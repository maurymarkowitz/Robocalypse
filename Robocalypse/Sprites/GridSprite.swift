/**
 * GridSprite.swift
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

/// Contains the code for drawing the background grid, and converting coordinates
/// to and from the underlying game map to CG coords.
@available(iOS 9, *)
class GridSprite:SKSpriteNode {
  static let kSpriteName = "grid"

  // actual playfield size, set when the game starts
  var rows:Int!
  var cols:Int!
  
  // the size of one side of the square in a grid,
  // set to a default value here but changed on setup
  //var gridSize:CGFloat =  CGFloat(16)

  convenience init?(size:CGSize, rows:Int, cols:Int) {
    // calculate the length of the side of a square that will properly tile
    // the size of the display passed in in gridSize, normally the view's size
    let maxx = size.width / CGFloat(cols)
    let maxy = size.height / CGFloat(rows)
    // now we pick the smaller of those two values to be our grid size
    let length = min(maxx, maxy)

    // set up a texture with that size
    guard let texture = GridSprite.gridTexture(blockSize: length, rows: rows, cols:cols) else {
      return nil
    }
    self.init(texture: texture, color:SKColor.green, size: texture.size())
    
    // and then write it all down
    self.name = GridSprite.kSpriteName
    //self.gridSize = length
    self.rows = rows
    self.cols = cols
  }
  
  class func gridTexture(blockSize:CGFloat, rows:Int, cols:Int) -> SKTexture? {
    // Add 1 to the height and width to ensure the borders are within the sprite
    let size = CGSize(width: CGFloat(cols)*blockSize+1.0, height: CGFloat(rows)*blockSize+1.0)
    UIGraphicsBeginImageContext(size)
    
    guard let context = UIGraphicsGetCurrentContext() else {
      return nil
    }
    let bezierPath = UIBezierPath()
    let offset:CGFloat = 0.5
    // Draw vertical lines
    for i in 0...cols {
      let x = CGFloat(i)*blockSize + offset
      bezierPath.move(to: CGPoint(x: x, y: 0))
      bezierPath.addLine(to: CGPoint(x: x, y: size.height))
    }
    // Draw horizontal lines
    for i in 0...rows {
      let y = CGFloat(i)*blockSize + offset
      bezierPath.move(to: CGPoint(x: 0, y: y))
      bezierPath.addLine(to: CGPoint(x: size.width, y: y))
    }
    SKColor.lightGray.withAlphaComponent(0.5).setStroke()
    bezierPath.lineWidth = 1.0
    bezierPath.stroke()
    context.addPath(bezierPath.cgPath)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return SKTexture(image: image!)
  }
}

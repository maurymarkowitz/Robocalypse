/**
 * GameScene.swift
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

/// Contains most of the UI for the SpriteKit version of the game, handling
/// conversion between the on-screen and in-game coordinates, building and
/// removing sprites as the game progresses, and displaying the score and
/// clocks. The UI outside this class has to handle the conversion of user
/// actions like touches or mouse clicks into CGPoints, but that's about
/// it.
class GameScene: SKScene {
  // this is the game this scene is presenting
  var game: Game!
  
  // keep this as an ivar so we can talk to it easily, it has most of the state
  var viewController: GameViewController!
  
  // tracks whether the game is portrait or landscape so
  // the coordinates can be rotated if need be
  var isLandscape: Bool = true
  
  var contentCreated = false                // has this level been set up?
  var timeOfStart: CFTimeInterval = 0.0     // used to display an elapsed time clock
  var timeOfLastMove: CFTimeInterval = 0.0  // when did the robots last move?
  var timePerMove: CFTimeInterval = 5.0     // how often should they move on their own?
  var dopaused = false                      // whether or not the game is currently paused
  var realtime = false                      // does the user want the game to proceed on its own?
  
  let kScoreName = "score"
  let kTimerName = "timer"
  
  /// Returns the maximum length of the side of a square that will tile out the grid
  /// when filled out to rows and columns. Pass in the view's size. This is used to
  /// set up the basic layout based on the Game's rows and cols.
  func gridSize(_ size: CGSize) -> CGFloat {
    // the screen is broken up into a grid of rows and columns, so first we
    // see how big those would be if they filled the size we were handed
    var maxx, maxy: CGFloat
    if isLandscape {
      maxx = size.width / CGFloat(game.cols)
      maxy = size.height / CGFloat(game.rows)
    } else {
      maxx = size.width / CGFloat(game.rows)
      maxy = size.height / CGFloat(game.cols)
    }
    
    // now we pick the smaller of those two values to be our grid size
    return min(maxx, maxy)
  }

  /// Converts an in-game (x,y) into an on-screen CGPoint centered in the grid cell.
  func gridPosition(_ col:Int, _ row:Int) -> CGPoint {
    let gridsize = gridSize(self.size)
    // see if we want to rotate the original coordinates
    if isLandscape {
      // for landscape orientations, like the mac, do not rotate it
      let offsetx = (gridsize / 2.0) + ((self.size.width - gridsize * CGFloat(game.cols))  / 2.0)
      let offsety = (gridsize / 2.0) + (self.frame.maxY - (gridsize * CGFloat(game.rows)))
      let x = (CGFloat(col) * gridsize) + offsetx
      let y = (CGFloat(row) * gridsize) + offsety
      return CGPoint(x:x, y:y)
    } else {
      // for portrait orientation, we want to rotate the coordinates
      let offsetx = (gridsize / 2.0) + ((self.size.width - gridsize * CGFloat(game.rows)) / 2.0)
      let offsety = (gridsize / 2.0) + (self.frame.maxY - (gridsize * CGFloat(game.cols)))
      let x = (CGFloat(row) * gridsize) + offsetx
      let y = (CGFloat(col) * gridsize) + offsety
      return CGPoint(x:x, y:y)
    }
  }
  /// Convinience method using Game.Location instead of X and Y
  func gridPosition(_ loc:Game.Location) -> CGPoint {
    return gridPosition(loc.x, loc.y)
  }

//  /// Converts a CGPoint on the screen to a Game.Location
//  func gridLocation(_ point:CGPoint) -> Game.Location {
//    let x = Int(point.x + 0.5) / 2
//    let y = Int(point.y + 0.5) / 2
//    return Game.Location(x,y)
//  }
  
  // scene setup routine, called when the view is first created
  override func didMove(to view: SKView) {
    // create the board if this is the first time through
    if (!contentCreated) {
      createContent()
      contentCreated = true
    }
  }
  
  /// Creates sprites for any objects in the Game at the start of the level.
  func createContent() {
    // set the background
    self.backgroundColor = SKColor.white
    
    // remove everything that might be on the screen already
    // which happens when you restart the game
    self.removeAllChildren()
    
    // and then add the various objects to the screen
    setupButtons()
    setupGrid()
    setupPiles()
    setupEnemies()
    setupPlayer()
    setupArrows()
    setupFence()
    setupScore()
    //setupClock()
  }
  
  // adds the teleport, last stand, etc.
  func setupButtons() {
    let teleText = SKLabelNode(fontNamed: "Courier")
    teleText.name = "teleport"
    teleText.text = "teleport"
    teleText.fontSize = 12
    teleText.fontColor = SKColor.black
    let teleBack = SKSpriteNode(color: SKColor.white, size: CGSize(width:75, height:35))
    teleBack.name = "teleback"
    teleBack.position = CGPoint(x: self.frame.midX - 150 ,y: self.frame.minY + 10)
    teleBack.addChild(teleText)
    addChild(teleBack)

    let lastText = SKLabelNode(fontNamed: "Courier")
    lastText.name = "laststand"
    lastText.text = "last stand"
    lastText.fontSize = 12
    lastText.fontColor = SKColor.black
    let lastBack = SKSpriteNode(color: SKColor.white, size: CGSize(width:75, height:35))
    lastBack.name = "lastback"
    lastBack.position = CGPoint(x: self.frame.midX + 150 ,y: self.frame.minY + 10)
    lastBack.addChild(lastText)
    addChild(lastBack)
  }
  
  // draws the backround grid
  func setupGrid() {
    // add the grid
    if isLandscape {
      if let grid = GridSprite(size: self.size, rows:game.rows, cols:game.cols) {
        grid.position = CGPoint(x:frame.midX, y:frame.maxY - (grid.size.height / 2)) //center horizontally and pin to the top
        grid.alpha = 0.5
        addChild(grid)
      }
    } else {
      if let grid = GridSprite(size: self.size, rows:game.cols, cols:game.rows) {
        grid.position = CGPoint(x:frame.midX, y:frame.maxY - (grid.size.height / 2))
        grid.alpha = 0.5
        addChild(grid)
      }
    }
  }

  /// Adds icons around the outside of the playfield if the hasFence option is turned on.
  func setupFence() {
    let gridsize = CGSize(width:gridSize(self.size), height:gridSize(self.size))

    if game.hasFence {
      var f: FenceSprite
      // draw the lines of sprites along the top and bottom across x
      for x in 0..<game.cols {
        f = FenceSprite(size:gridsize)
        f.position = gridPosition(x, 0)
        addChild(f)
        f = FenceSprite(size:gridsize)
        f.position = gridPosition(x, game.rows - 1)
        addChild(f)
      }
      // and then down the sides in y
      for y in 0..<game.rows {
        f = FenceSprite(size:gridsize)
        f.position = gridPosition(0, y)
        addChild(f)
        f = FenceSprite(size:gridsize)
        f.position = gridPosition(game.cols - 1, y)
        addChild(f)
      }
    } //hasFence
  }
    
  /// Adds any pre-rolled piles to the map.
  func setupPiles() {
    let gridsize = CGSize(width:gridSize(self.size), height:gridSize(self.size))
    for pile in game.piles {
      let p = PileSprite(pile:pile, size:gridsize)
      p.position = gridPosition(pile.location)
      addChild(p)
    }
  }
    
  /// Adds the enemies to the map.
  func setupEnemies() {
    let gridsize = CGSize(width:gridSize(self.size), height:gridSize(self.size))
    for enemy in game.enemies {
      if enemy.type == Game.Types.tank {
        let t = TankSprite(robot:enemy, size:gridsize)
        t.position = gridPosition(enemy.location)
        addChild(t)
      } else {
        let r = RobotSprite(robot:enemy, size:gridsize)
        r.position = gridPosition(enemy.location)
        addChild(r)
      }
    }
  }
    
  /// Adds the player to the map.
  func setupPlayer() {
    let gridsize = CGSize(width:gridSize(self.size), height:gridSize(self.size))
    let p = PlayerSprite(player:game.player, size:gridsize)
    p.position = gridPosition(game.player.location)
    addChild(p)
  }
  
  /// Adds the directional arrows to the screen, and makes them visible.
  func setupArrows() {
    let gridsize = gridSize(self.size)

    let arrows = ArrowsSprite(size:CGSize(width:gridsize, height:gridsize))
    arrows.position = gridPosition(game.player.location)
    arrows.alpha = 0.5
    addChild(arrows)
    
    // now call the update function on them to set the initial state
    arrows.update(withMoves:game.safeMoves())
  }
  
  /// Adds the score display to the map.
  func setupScore() {
    let scoreLabel = SKLabelNode(fontNamed: "Courier")
    scoreLabel.name = kScoreName
    scoreLabel.fontSize = 16
    scoreLabel.fontColor = SKColor.green
    scoreLabel.text = "Score: 0"
    scoreLabel.position = CGPoint(x: frame.size.width / 2, y: 5 + scoreLabel.frame.size.height/2)
    addChild(scoreLabel)
  }
  
  /// Translates the touchlocation from the scene into a Game.Move value, while also
  /// handling the buttons. Ignores touches outside those areas.
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    // get the touch location
    let touch = touches.first!
    let touchPosition = touch.location(in: self)
    
    // if the newbutton is up, see if they clicked it
    // FIXME: this will be replaced by the game-over scene
    if let newbutton = childNode(withName: "startover") {
      if newbutton.contains(touchPosition) {
        // make a new game
        let newgame = Game()
        newgame.createMap()
        self.game = newgame
        createContent()
        return
        //refreshDisplay(move: Game.Move.dontmove)
      }
    }

    // otherwise if the game is done don't do anything
    if game.player.isDead || game.hasWon() { return }
    
    // start by seeing if they touched one of the buttons
    if let telebutton = childNode(withName: "teleback") {
      if telebutton.contains(touchPosition) {
        doMove(Game.Move.teleport)
        return // then exit here because the move is complete
      }
    }
    if let lastbutton = childNode(withName: "lastback") {
      if lastbutton.contains(touchPosition) {
        doMove(Game.Move.laststand)
        return
      }
    }
    
    // and finally, if the click wasn't on any of the buttons,
    // only continue if it is somewhere in the grid
    if let grid = childNode(withName: "grid") {
      if !grid.contains(touchPosition) { return }
    }

    // the touch was in the grid area, so compare it to the player location
    let size = gridSize(self.size)
    let playerPosition = gridPosition(game.player.location)
    var xmove = 0
    var ymove = 0
    if touchPosition.x > playerPosition.x + CGFloat(size / 2) {
      xmove = 1
    }
    else if touchPosition.x < playerPosition.x - CGFloat(size / 2) {
      xmove = -1
    }
    if touchPosition.y > playerPosition.y + CGFloat(size / 2) {
      ymove = 1
    }
    else if touchPosition.y < playerPosition.y - CGFloat(size / 2) {
      ymove = -1
    }
    // if we're rotated, rotate the directions
    if !isLandscape {
      let temp = ymove
      ymove = xmove
      xmove = temp
    }
    // now translate that into a Move
    var move: Game.Move
    switch (xmove, ymove) {
    case (0, 1) : move = Game.Move.down
    case (0, 0) : move = Game.Move.dontmove
    case (0, -1) : move = Game.Move.up
    case (1, 1) : move = Game.Move.downright
    case (1, 0) : move = Game.Move.right
    case (1, -1) : move = Game.Move.upright
    case (-1, 1) : move = Game.Move.downleft
    case (-1, 0) : move = Game.Move.left
    case (-1, -1) : move = Game.Move.upleft
    default: move = Game.Move.dontmove // very annoying, I'm not going to make an enum just for this
    }
    // and call the move routine
    doMove(move)
  }
  
  /// Handles the updating of the screen after the player has moved or the timer expired.
  func doMove(_ direction: Game.Move) {
    // fade out the directional arrows if they're visible
    let arrows = childNode(withName: "arrows") as! ArrowsSprite
    let fade = SKAction.fadeAlpha(to: 0.0, duration: 0.2)
    arrows.run(fade)

    // run the game one move
    game.runGame(input: direction)
    
    // and then update the display
    refreshDisplay(move: direction)
    
    // check if the player was killed
    let player = childNode(withName: "player") as! PlayerSprite
    if game.hasWon() || player.object!.isDead {
      showEndgame()
      return
    }

    // if it's not game over, update the arrows and move them to the new location
    if !game.hasWon() && !player.object!.isDead {
      arrows.update(withMoves:game.safeMoves())
      arrows.position = gridPosition(game.player.location)
      let move = SKAction.move(to:gridPosition(player.object!.location), duration:player.kSpriteSpeed())
      arrows.run(move)
      let unfade = SKAction.fadeAlpha(to: 0.5, duration: 0.2)
      arrows.run(unfade)
    }
    
    // update the score, but not if the end-game display is up
    if !game.hasWon() && !player.object!.isDead {
      let score = childNode(withName: kScoreName) as! SKLabelNode
      score.text = "Score: \(game.score)"
    }
    
    // if the user has selected last stand, just keep looping through here,
    // eventually one of the cases above will fire and exit
    if game.lastStand {
      let pause = SKAction.wait(forDuration: 0.2)
      run(pause)
      doMove(Game.Move.laststand)
    }
  }
  
  /// Adds the end-game message and displays the start-over button
  func showEndgame() {
    // start by displaying a end-game score in the middle of the screen
    let endLabel = SKLabelNode(fontNamed: "Courier")
    endLabel.name = "endgame"
    endLabel.fontSize = 15
    endLabel.fontColor = SKColor.red
    if game.hasWon() {
      endLabel.text = "You won!\nYour score was \(game.score)"
    } else {
      switch game.player.killedBy {
      case .robot: endLabel.text = "A soldier caught you!\nYour score was \(game.score)"
      case .tank: endLabel.text = "The tank ran you over!\nYour score was \(game.score)"
      case .pile: endLabel.text = "BLAM! You stepped on a mine!\nYour score was \(game.score)"
      case .fence: endLabel.text = "ZAP! You jumped onto the fence!\nYour score was \(game.score)"
      default: endLabel.text = "You lose!\nYour score was \(game.score)"
      }
    }
    endLabel.numberOfLines = 2
    endLabel.position = CGPoint(x: frame.midX, y: frame.midY)
    endLabel.zPosition = 1001  // on top of all other nodes
    addChild(endLabel)

    // now remove the original score label at the bottom
    if let score = childNode(withName: kScoreName) {
      removeChildren(in: [score])
    }
    
    // and replace it with a start-over button
    let startText = SKLabelNode(fontNamed: "Courier")
    startText.name = "startover"
    startText.text = "New Game"
    startText.alpha = 1
    startText.fontSize = 15
    startText.fontColor = SKColor.green
    startText.position = CGPoint(x: frame.midX, y: frame.minY + 10)
    startText.zPosition = 1001  // On top of all other nodes
    addChild(startText)

    // and turn off the teleport and last stand buttons
    guard let telebutton = childNode(withName: "teleback") else { return }
    telebutton.alpha = 0.5
    let teletext = telebutton.childNode(withName: "teleport") as! SKLabelNode
    teletext.fontColor = SKColor.lightGray
    guard let lastbutton = childNode(withName: "lastback")  else { return }
    lastbutton.alpha = 0.5
    let lasttext = lastbutton.childNode(withName: "laststand") as! SKLabelNode
    lasttext.fontColor = SKColor.lightGray
  }

  /// Updates the position and display of the game objects after each turn.
  func refreshDisplay(move: Game.Move) {
    // find the player sprite
    let player = childNode(withName: "player") as! PlayerSprite
    
    // move it to its new location, using an appropriate animation
    var items = [SKAction]()
    if move == Game.Move.teleport {
      let teleout = SKAction.fadeAlpha(to:0.0, duration:0.2)
      let move = SKAction.move(to:gridPosition(player.object!.location), duration:0) // you're teleporting, not moving!
      let telein = SKAction.fadeAlpha(to:1.0, duration:0.2)
      items.append(teleout)
      items.append(move)
      items.append(telein)
    } else {
      let move = SKAction.move(to:gridPosition(player.object!.location), duration:player.kSpriteSpeed())
      items.append(move)
    }
    let sequence = SKAction.sequence(items)
    player.run(sequence)

    // move all the enemies, and fade the ones that died
    for enemy in game.enemies {
      var n: String
      if enemy.type == .tank {
        n = "tank"
      } else {
        n = "robot" + String(enemy.id)
      }
      let e = childNode(withName: n) as! ObjectSprite
      let move = SKAction.move(to:gridPosition(e.object!.location), duration:e.kSpriteSpeed())
      e.run(move)
      if enemy.isDead {
        let fade = SKAction.fadeAlpha(to:0.0, duration:e.kSpriteSpeed())
        e.run(fade)
      } else {
        let move = SKAction.move(to:gridPosition(e.object!.location), duration:e.kSpriteSpeed())
        e.run(move)
      }
    }
    
    // do the piles last, because we may have removed or added ones
    // that should appear/disappear after the enemies move
    for pile in game.piles {
      // look for the sprite for this pile, which might not exist if it's new
      if let p = childNode(withName: "pile" + String(pile.id)) as! ObjectSprite? {
        if pile.isDead {
          if p.alpha != 0.0 {
            let fade = SKAction.fadeAlpha(to: 0.0, duration: p.kSpriteSpeed())
            p.run(fade)
            //FIXME: we want to animate here
          }
        }
      } else {
        // if we didn't find the sprite, it's new and we need to add it
        let gridsize = CGSize(width:gridSize(self.size), height:gridSize(self.size))
        let p = PileSprite(pile:pile, size:gridsize)
        p.position = gridPosition(pile.location)
        addChild(p)
      }
    }
    
    // and now dim out the teleport button if they're out of them
    if game.teleports <= 0 {
      guard let telebutton = childNode(withName: "teleback") else { return }
      telebutton.alpha = 0.5
      let teletext = telebutton.childNode(withName: "teleport") as! SKLabelNode
      teletext.fontColor = SKColor.lightGray
    }
  }

  /// Updates the animations of the various icons and advances the timer if it's
  /// turned on. If the timer reaches zero, it issues a "don't move" so the game
  /// advances one turn.
  override func update(_ currentTime: TimeInterval) {
    // set up the timers if this is the first time in
    if timeOfStart == 0.0 {
      timeOfStart = currentTime
      timeOfLastMove = currentTime
    }
    
    // don't update if the game is over
    if !game.hasWon() && !game.player.isDead {
      return
    }

    // if realtime is on, check the time against the last move and move them if it expired
    if realtime {
      // update the timer bar in the hud
      //updateTimer(currentTime)

      // if the timer expired, do a "dontmove" move
      if (currentTime - timeOfLastMove > timePerMove) {
        doMove(Game.Move.dontmove)
        timeOfLastMove = currentTime
      }
    }
  }
  
} // end of class

extension CGPoint {
  static func +(p1:CGPoint, p2:CGPoint) -> CGPoint {
    return CGPoint(x:p1.x + p2.x, y:p1.y + p2.y)
  }
  static func -(p1:CGPoint, p2:CGPoint) -> CGPoint {
    return CGPoint(x:p1.x - p2.x, y:p1.y - p2.y)
  }
}

extension SKLabelNode {
  func multilined() -> SKLabelNode {
    let substrings: [String] = self.text!.components(separatedBy: "\n")
    return substrings.enumerated().reduce(SKLabelNode()) {
      let label = SKLabelNode(fontNamed: self.fontName)
      label.text = $1.element
      label.fontColor = self.fontColor
      label.fontSize = self.fontSize
      label.position = self.position
      label.horizontalAlignmentMode = self.horizontalAlignmentMode
      label.verticalAlignmentMode = self.verticalAlignmentMode
      let y = CGFloat($1.offset - substrings.count / 2) * self.fontSize
      label.position = CGPoint(x: 0, y: -y)
      label.zPosition = 5.0
      $0.addChild(label)
      return $0
    }
  }
}

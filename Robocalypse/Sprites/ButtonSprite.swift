/**
 * ButtonSprite.swift
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

/// Draws a button with the selected background pattern and text.
class ButtonSprite: SKSpriteNode {
  var label: SKLabelNode
  
  var defaultTexture: SKTexture?
  var selectedTexture: SKTexture?
  var disabledTexture: SKTexture?
  
  let defaultSize = CGSize(width: 50.0, height: 50.0)
  
  var actionTouchUpInside: Selector?
  var actionTouchUp: Selector?
  var actionTouchDown: Selector?
  
  weak var targetTouchUpInside: AnyObject?
  weak var targetTouchUp: AnyObject?
  weak var targetTouchDown: AnyObject?
  
  enum ButtonActionType: Int {
    case TouchUpInside = 1,
    TouchDown, TouchUp
  }
  
  var isEnabled: Bool = true {
    didSet {
      if (disabledTexture != nil) {
        texture = isEnabled ? defaultTexture : disabledTexture
      }
    }
  }
  var isSelected: Bool = false {
    didSet {
      texture = isSelected ? selectedTexture : defaultTexture
    }
  }
  
  required init(coder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
  init(normalTexture defaultTexture: SKTexture?, selectedTexture:SKTexture?, disabledTexture: SKTexture?, defaultSize:CGSize?) {
    let size: CGSize = defaultTexture?.size() ?? defaultSize ?? CGSize(width: 50.0, height: 50.0)

    // basic setup
    self.defaultTexture = defaultTexture
    self.selectedTexture = selectedTexture
    self.disabledTexture = disabledTexture
    self.label = SKLabelNode(fontNamed: "Helvetica");

    // call super.init
    super.init(texture: self.defaultTexture, color: UIColor.white, size: size)
    isUserInteractionEnabled = true
    
    // add a blank label centered on the button
    label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.center;
    label.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.center;
    addChild(self.label)
    
    // add an empty layer on top, which enables the touch features to be captured
    let bugFixLayerNode = SKSpriteNode(texture: nil, color: UIColor.clear, size: size)
    bugFixLayerNode.position = self.position
    addChild(bugFixLayerNode)
  }
  
  /// Convenience version used when the size is not provided
//  convenience init(normalTexture defaultTexture: SKTexture?, selectedTexture:SKTexture?, disabledTexture: SKTexture?) {
//    self.init(normalTexture, defaultTexture: defaultTexture, selectedTexture:selectedTexture, disabledTexture:disabledTexture, defaultSize:nil)
//  }

  /// Set the action for this button.
  func setButtonAction(target: AnyObject, triggerEvent event:ButtonActionType, action:Selector) {
    switch (event) {
    case .TouchUpInside:
      targetTouchUpInside = target
      actionTouchUpInside = action
    case .TouchDown:
      targetTouchDown = target
      actionTouchDown = action
    case .TouchUp:
      targetTouchUp = target
      actionTouchUp = action
    }
  }
  
  /// Set the button text.
  func setButtonLabel(title: NSString, font: String, fontSize: CGFloat) {
    self.label.text = title as String
    self.label.fontSize = fontSize
    self.label.fontName = font
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if (!isEnabled) {
      return
    }
    isSelected = true
    if (targetTouchDown != nil && targetTouchDown!.responds(to: actionTouchDown!)) {
      UIApplication.shared.sendAction(actionTouchDown!, to: targetTouchDown, from: self, for: nil)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if (!isEnabled) {
      return
    }
    let touch: AnyObject! = touches.first
    let touchLocation = touch.location(in: self)
    if (frame.contains(touchLocation)) {
      isSelected = true
    } else {
      isSelected = false
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if (!isEnabled) {
      return
    }
    isSelected = false
    if (targetTouchUpInside != nil && targetTouchUpInside!.responds(to: actionTouchUpInside!)) {
      let touch: AnyObject! = touches.first
      let touchLocation = touch.location(in: parent!)
      
      if (frame.contains(touchLocation) ) {
        UIApplication.shared.sendAction(actionTouchUpInside!, to: targetTouchUpInside, from: self, for: nil)
      }
    }
    if (targetTouchUp != nil && targetTouchUp!.responds(to: actionTouchUp!)) {
      UIApplication.shared.sendAction(actionTouchUp!, to: targetTouchUp, from: self, for: nil)
    }
  }
}

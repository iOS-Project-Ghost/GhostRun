//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/30/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import SpriteKit

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
#endif
 
extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
}

struct PhysicsCategory {
  static let None      : UInt32 = 0
  static let All       : UInt32 = UInt32.max
  static let Ghost     : UInt32 = 0b1       // 1
  static let Flashlight: UInt32 = 0b10      // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
  
  // 1
  let player = SKSpriteNode(imageNamed: "ghost")
    var count = 0;

  override func didMove(to view: SKView) {
    // 2
    backgroundColor = SKColor.darkGray
    // 3
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.165)
    
    player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
    player.physicsBody?.isDynamic = true
    player.physicsBody?.categoryBitMask = PhysicsCategory.Ghost
    player.physicsBody?.contactTestBitMask = PhysicsCategory.Flashlight
    player.physicsBody?.collisionBitMask = PhysicsCategory.None
    player.physicsBody?.usesPreciseCollisionDetection = true
    player.setScale(0.3)
    
    // 4
    addChild(player)
    
    physicsWorld.gravity = CGVector.zero
    physicsWorld.contactDelegate = self
    
    run(SKAction.repeatForever(
      SKAction.sequence([
        SKAction.run(addFlashlight),
        SKAction.wait(forDuration: 2)
      ])
    ))
    
    //music for the game
    /*let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
    backgroundMusic.autoplayLooped = true
    addChild(backgroundMusic)*/
    
  }
  
  func random() -> CGFloat {
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
  }
   
  func random(min: CGFloat, max: CGFloat) -> CGFloat {
    return random() * (max - min) + min
  }
   
  func addFlashlight() {
    
    // Create sprite
    let flashlight = SKSpriteNode(imageNamed: "flashlight")
   
    flashlight.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: flashlight.size.width - 195,
                                                               height: flashlight.size.height - 150))
    flashlight.setScale(0.1)
    flashlight.physicsBody?.isDynamic = true // 2
    flashlight.physicsBody?.categoryBitMask = PhysicsCategory.Flashlight // 3
    flashlight.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost // 4
    flashlight.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
   
    // Determine where to spawn the monster along the Y axis
    //let actualY = random(min: flashlight.size.height/2, max: size.height - flashlight.size.height/2)
    let actualY = size.height * 0.125
   
    // Position the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    flashlight.position = CGPoint(x: size.width + flashlight.size.width/2, y: actualY)
   
    // Add the monster to the scene
    addChild(flashlight)
   
    // Determine speed of the monster
    let actualDuration = random(min: CGFloat(1.5), max: CGFloat(3.5))
   
    // Create the actions
    let actionMove = SKAction.move(to: CGPoint(x: -flashlight.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
    let actionMoveDone = SKAction.removeFromParent()
    flashlight.run(SKAction.sequence([actionMove, actionMoveDone]))
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
  
    
    // 1 - Choose one of the touches to work with
    guard let touch = touches.first else {
      return
    }
    _ = touch.location(in: self)
 
    

        // move up 20
        let jumpUpAction = SKAction.moveBy(x:0, y:120, duration:0.25)
        // move down 20
        let jumpDownAction = SKAction.moveBy(x:0 , y:-120, duration:0.25)
        // sequence of move yup then down
        let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction])
        // make player run sequence
        
        player.run(_:jumpSequence)

}
  
  func ghostDidCollideWithFlashlight(ghost: SKSpriteNode, flashlight: SKSpriteNode) {
    print("Ghost collided with light")
    
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let gameOverScene = GameOverScene(size: self.size, won: false)
      self.view?.presentScene(gameOverScene, transition: reveal)
  }
  
 func didBegin(_ contact: SKPhysicsContact) {

    // 1
   var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    } else {
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
   
    // 2
    if ((firstBody.categoryBitMask & PhysicsCategory.Ghost != 0) &&
        (secondBody.categoryBitMask & PhysicsCategory.Flashlight != 0)) {
      if let ghost = firstBody.node as? SKSpriteNode, let
        flashlight = secondBody.node as? SKSpriteNode {
        ghostDidCollideWithFlashlight(ghost: ghost, flashlight: flashlight)
      }
    }
   
  }

}

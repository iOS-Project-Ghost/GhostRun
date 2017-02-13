//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by Main Account on 9/30/16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import SpriteKit

func + (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
 
func - (left: CGPoint, right: CGPoint) -> CGPoint {
  return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
 
func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x * scalar, y: point.y * scalar)
}
 
func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
  return CGPoint(x: point.x / scalar, y: point.y / scalar)
}
 
#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
  return CGFloat(sqrtf(Float(a)))
}
#endif
 
extension CGPoint {
  func length() -> CGFloat {
    return sqrt(x*x + y*y)
  }
 
  func normalized() -> CGPoint {
    return self / length()
  }
}

struct PhysicsCategory {
  static let None      : UInt32 = 0
  static let All       : UInt32 = UInt32.max
  static let Ghost   : UInt32 = 0b1       // 1
  static let Flashlight: UInt32 = 0b10      // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  // 1
  let player = SKSpriteNode(imageNamed: "ghost")

  override func didMove(to view: SKView) {
    // 2
    backgroundColor = SKColor.black
    // 3
    player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
    
    player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2)
    player.physicsBody?.isDynamic = true
    player.physicsBody?.categoryBitMask = PhysicsCategory.Ghost
    player.physicsBody?.contactTestBitMask = PhysicsCategory.Flashlight
    player.physicsBody?.collisionBitMask = PhysicsCategory.None
    player.physicsBody?.usesPreciseCollisionDetection = true
    
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
    
    
    let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
    backgroundMusic.autoplayLooped = true
    addChild(backgroundMusic)
    
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
    flashlight.physicsBody?.isDynamic = true // 2
    flashlight.physicsBody?.categoryBitMask = PhysicsCategory.Flashlight // 3
    flashlight.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost // 4
    flashlight.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
   
    // Determine where to spawn the monster along the Y axis
    //let actualY = random(min: flashlight.size.height/2, max: size.height - flashlight.size.height/2)
    let actualY = size.height * 0.6
   
    // Position the monster slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    flashlight.position = CGPoint(x: size.width + flashlight.size.width/2, y: actualY)
   
    // Add the monster to the scene
    addChild(flashlight)
   
    // Determine speed of the monster
    let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
   
    // Create the actions
    let actionMove = SKAction.move(to: CGPoint(x: -flashlight.size.width/2, y: actualY), duration: TimeInterval(actualDuration))
    let actionMoveDone = SKAction.removeFromParent()
    
    /*
    let loseAction = SKAction.run() {
      let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
      let gameOverScene = GameOverScene(size: self.size, won: false)
      self.view?.presentScene(gameOverScene, transition: reveal)
    }*/
    //flashlight.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    flashlight.run(SKAction.sequence([actionMove, actionMoveDone]))
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
  
    //run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
    
    
    // 1 - Choose one of the touches to work with
    guard let touch = touches.first else {
      return
    }
    let _touchLocation = touch.location(in: self)
    /*
     Uncomment for projectile functionality
    // 2 - Set up initial location of projectile
    let projectile = SKSpriteNode(imageNamed: "projectile")
    projectile.position = player.position
   
    projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
    projectile.physicsBody?.isDynamic = true
    projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
    projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
    projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
    projectile.physicsBody?.usesPreciseCollisionDetection = true
   
    // 3 - Determine offset of location to projectile
    let offset = touchLocation - projectile.position
   
    // 4 - Bail out if you are shooting down or backwards
    if (offset.x < 0) { return }
   
    // 5 - OK to add now - you've double checked position
    addChild(projectile)
   
    // 6 - Get the direction of where to shoot
    let direction = offset.normalized()
   
    // 7 - Make it shoot far enough to be guaranteed off screen
    let shootAmount = direction * 1000
   
    // 8 - Add the shoot amount to the current position
    let realDest = shootAmount + projectile.position
   
    // 9 - Create the actions
    let actionMove = SKAction.move(to: realDest, duration: 2.0)
    let actionMoveDone = SKAction.removeFromParent()
    projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
     */
    
    // move up 20
    let jumpUpAction = SKAction.moveBy(x:0, y:87, duration:0.2)
    // move down 20
    let jumpDownAction = SKAction.moveBy(x:0 , y:-87, duration:2)
    // sequence of move yup then down
    let jumpSequence = SKAction.sequence([jumpUpAction, jumpDownAction])
    
    // make player run sequence
    player.run(_:jumpSequence)
  }
  
  func ghostDidCollideWithFlashlight(ghost: SKSpriteNode, flashlight: SKSpriteNode) {
    print("Ghost collided with flashlight")
    
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

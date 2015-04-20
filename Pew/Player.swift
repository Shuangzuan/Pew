//
//  Player.swift
//  Pew
//
//  Created by Shuangzuan He on 4/16/15.
//  Copyright (c) 2015 Pretty Seven. All rights reserved.
//

import SpriteKit

class Player: Entity {
    
    var invincible = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init() {
        super.init(imageNamed: "SpaceFlier_sm_1", maxHp: 10)
        
        setupAnimation()
        setupCollisionBody()
    }
    
    private func setupAnimation() {
        runAction(SKAction.repeatActionForever(SKAction.animateWithTextures([
            SKTexture(imageNamed: "SpaceFlier_sm_1"),
            SKTexture(imageNamed: "SpaceFlier_sm_2")
        ], timePerFrame: 0.2)))
    }
    
    private func setupCollisionBody() {
        let offset = CGPoint(x: size.width * anchorPoint.x, y: size.height * anchorPoint.y)
        let path = CGPathCreateMutable()
        moveToPoint(CGPoint(x: 70, y: 51), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 83, y: 50), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 102, y: 32), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 95, y: 16), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 73, y: 9), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 45, y: 16), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 46, y: 36), path: path, offset: offset)
        CGPathCloseSubpath(path)
        
        physicsBody = SKPhysicsBody(polygonFromPath: path)
        physicsBody?.categoryBitMask = PhysicsCategory.Player
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = PhysicsCategory.Asteroid | PhysicsCategory.AlienLaser | PhysicsCategory.Powerup | PhysicsCategory.Alien
    }
    
    private func contactObstacle(contact: SKPhysicsContact) {
        if let scene = scene as? GameScene {
            if !invincible {
                takeHit()
            }
            
            if isDead() {
                scene.spawnExplosionAtPosition(contact.contactPoint, scale: 1, large: true)
                scene.endScene(false)
            } else {
                scene.spawnExplosionAtPosition(contact.contactPoint, scale: 0.5, large: true)
            }
        }
    }
    
    override func collideBody(body: SKPhysicsBody, contact: SKPhysicsContact) {
        if let other = body.node as? Entity {
            other.destroy()
        }
        
        if body.categoryBitMask == PhysicsCategory.Asteroid ||
            body.categoryBitMask == PhysicsCategory.AlienLaser ||
            body.categoryBitMask == PhysicsCategory.Alien {
            contactObstacle(contact)
        } else if body.categoryBitMask == PhysicsCategory.Powerup {
            if let scene = scene as? GameScene {
                scene.applyPowerup()
            }
        }
    }
}

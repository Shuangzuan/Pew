//
//  Alien.swift
//  Pew
//
//  Created by Shuangzuan He on 4/20/15.
//  Copyright (c) 2015 Pretty Seven. All rights reserved.
//

import SpriteKit

class Alien: Entity {
   
    private var timeSinceLastLaserShot = NSTimeInterval(CGFloat.random(min: 0.1, max: 4))
    private var timeForNextLaserShot: NSTimeInterval = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(imageNamed: "enemy_spaceship", maxHp: 1, healthBarType: .Red)
        
        setupCollisionBody()
    }
    
    private func setupCollisionBody() {
        let offset = CGPoint(x: size.width * anchorPoint.x, y: size.height * anchorPoint.y)
        let path = CGPathCreateMutable()
        moveToPoint(CGPoint(x: 11, y: 25), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 42, y: 40), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 86, y: 40), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 114, y: 25), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 79, y: 11), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 44, y: 11), path: path, offset: offset)
        CGPathCloseSubpath(path)
        
        physicsBody = SKPhysicsBody(polygonFromPath: path)
        physicsBody?.categoryBitMask = PhysicsCategory.Alien
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = PhysicsCategory.PlayerLaser
    }
    
    override func collideBody(body: SKPhysicsBody, contact: SKPhysicsContact) {
        if body.categoryBitMask == PhysicsCategory.PlayerLaser {
            if let other = body.node as? Entity {
                other.destroy()
                takeHit()
                
                if let scene = scene as? GameScene {
                    if isDead() {
                        scene.spawnExplosionAtPosition(contact.contactPoint, scale: xScale, large: true)
                    } else {
                        scene.spawnExplosionAtPosition(contact.contactPoint, scale: xScale, large: false)
                    }
                }
            }
        }
    }
    
    override func update(dt: CFTimeInterval) {
        super.update(dt)
        
        timeSinceLastLaserShot += dt
        if timeSinceLastLaserShot > timeForNextLaserShot {
            timeSinceLastLaserShot = 0
            timeForNextLaserShot = NSTimeInterval(CGFloat.random(min: 0.1, max: 4))
            
            if let scene = scene as? GameScene {
                scene.spawnAlienLaserAtPosition(position)
            }
        }
    }
}

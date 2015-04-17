//
//  Asteroid.swift
//  Pew
//
//  Created by Shuangzuan He on 4/16/15.
//  Copyright (c) 2015 Pretty Seven. All rights reserved.
//

import SpriteKit

enum AsteroidType: UInt32 {
    case Small = 0
    case Medium
    case Large
    case NumAsteroidTypes
}

class Asteroid: Entity {

    private var asteroidType = AsteroidType.Small
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(asteroidType: AsteroidType) {
        var maxHp = 0
        var scale: CGFloat = 0
        
        switch asteroidType {
        case .Small:
            maxHp = 1
            scale = 0.25
        case .Medium:
            maxHp = 2
            scale = 0.5
        case .Large:
            maxHp = 4
            scale = 1.0
        case .NumAsteroidTypes:
            println("AsteroidType.NumAsteroidTypes")
        }
        
        self.asteroidType = asteroidType
        super.init(imageNamed: "asteroid", maxHp: maxHp)
        
        setupCollisionBody()
        setScale(scale)
    }
    
    private func setupCollisionBody() {
        let offset = CGPoint(x: size.width * anchorPoint.x, y: size.height * anchorPoint.y)
        let path = CGPathCreateMutable()
        moveToPoint(CGPoint(x: 30, y: 105), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 47, y: 119), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 78, y: 123), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 105, y: 112), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 123, y: 83), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 119, y: 47), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 99, y: 24), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 46, y: 22), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 25, y: 45), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 16, y: 79), path: path, offset: offset)
        CGPathCloseSubpath(path)
        
        physicsBody = SKPhysicsBody(polygonFromPath: path)
        physicsBody?.categoryBitMask = PhysicsCategory.Asteroid
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = PhysicsCategory.PlayerLaser | PhysicsCategory.Player
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
}

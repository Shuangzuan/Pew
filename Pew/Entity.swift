//
//  Entity.swift
//  Pew
//
//  Created by Shuangzuan He on 4/16/15.
//  Copyright (c) 2015 Pretty Seven. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let Player:      UInt32 = 0b1
    static let Asteroid:    UInt32 = 0b10
    static let Alien:       UInt32 = 0b100
    static let PlayerLaser: UInt32 = 0b1000
    static let AlienLaser:  UInt32 = 0b10000
    static let Powerup:     UInt32 = 0b100000
}

class Entity: SKSpriteNode {
    
    var hp = 0
    var maxHp = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(imageNamed name: String, maxHp: Int) {
        let texture = SKTexture(imageNamed: name)
        super.init(texture: texture, color: nil, size: texture.size())
        
        self.maxHp = maxHp
        hp = maxHp
    }
    
    func moveToPoint(point: CGPoint, path: CGMutablePathRef, offset: CGPoint) {
        CGPathMoveToPoint(path, nil, point.x - offset.x, point.y - offset.y)
    }
    
    func addLineToPoint(point: CGPoint, path: CGMutablePathRef, offset: CGPoint) {
        CGPathAddLineToPoint(path, nil, point.x - offset.x, point.y - offset.y)
    }
    
    func collideBody(body: SKPhysicsBody, contact: SKPhysicsContact) {
        
    }
    
    func isDead() -> Bool {
        return hp <= 0
    }
    
    func cleanup() {
        removeFromParent()
    }
    
    func destroy() {
        hp = 0
        physicsBody = nil
        removeAllActions()
        runAction(SKAction.sequence([
            SKAction.fadeAlphaTo(0, duration: 0.2),
            SKAction.runBlock {
                self.cleanup()
            }
        ]))
    }
    
    func takeHit() {
        if hp > 0 {
            --hp
        }
        if isDead() {
            destroy()
        }
    }
    
    func update(dt: CFTimeInterval) {
        
    }
}

//
//  Powerup.swift
//  Pew
//
//  Created by Shuangzuan He on 4/20/15.
//  Copyright (c) 2015 Pretty Seven. All rights reserved.
//

import SpriteKit

class Powerup: Entity {
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(imageNamed: "powerup", maxHp: 1)
        
        setupCollisionBody()
    }
    
    private func setupCollisionBody() {
        let offset = CGPoint(x: size.width * anchorPoint.x, y: size.height * anchorPoint.y)
        let path = CGPathCreateMutable()
        moveToPoint(CGPoint(x: 9, y: 30), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 54, y: 29), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 54, y: 8), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 8, y: 9), path: path, offset: offset)
        CGPathCloseSubpath(path)
        
        physicsBody = SKPhysicsBody(polygonFromPath: path)
        physicsBody?.categoryBitMask = PhysicsCategory.Powerup
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = PhysicsCategory.Player
    }
}

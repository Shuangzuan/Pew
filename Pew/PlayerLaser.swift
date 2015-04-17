//
//  PlayerLaser.swift
//  Pew
//
//  Created by Shuangzuan He on 4/16/15.
//  Copyright (c) 2015 Pretty Seven. All rights reserved.
//

import SpriteKit

class PlayerLaser: Entity {

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(imageNamed: "laserbeam_blue", maxHp: 1)
        
        setupCollisionBody()
    }
    
    private func setupCollisionBody() {
        let offset = CGPoint(x: size.width * anchorPoint.x, y: size.height * anchorPoint.y)
        let path = CGPathCreateMutable()
        moveToPoint(CGPoint(x: 7, y: 12), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 53, y: 11), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 53, y: 5), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 7, y: 6), path: path, offset: offset)
        CGPathCloseSubpath(path)
        
        physicsBody = SKPhysicsBody(polygonFromPath: path)
        physicsBody?.categoryBitMask = PhysicsCategory.PlayerLaser
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = PhysicsCategory.Asteroid | PhysicsCategory.Alien
    }
}

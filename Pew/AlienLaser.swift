//
//  AlienLaser.swift
//  Pew
//
//  Created by Shuangzuan He on 4/20/15.
//  Copyright (c) 2015 Pretty Seven. All rights reserved.
//

import SpriteKit

class AlienLaser: Entity {
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(imageNamed: "laserbeam_red", maxHp: 1, healthBarType: .None)
        
        setupCollisionBody()
    }
    
    private func setupCollisionBody() {
        let offset = CGPoint(x: size.width * anchorPoint.x, y: size.height * anchorPoint.y)
        let path = CGPathCreateMutable()
        moveToPoint(CGPoint(x: 4, y: 8), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 24, y: 8), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 24, y: 3), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 4, y: 3), path: path, offset: offset)
        CGPathCloseSubpath(path)
        
        physicsBody = SKPhysicsBody(polygonFromPath: path)
        physicsBody?.categoryBitMask = PhysicsCategory.AlienLaser
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = PhysicsCategory.Player
    }
}

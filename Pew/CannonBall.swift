//
//  CannonBall.swift
//  Pew
//
//  Created by Shuangzuan He on 4/21/15.
//  Copyright (c) 2015 Pretty Seven. All rights reserved.
//

import SpriteKit

class CannonBall: Entity {
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(imageNamed: "Boss_cannon_ball", maxHp: 1, healthBarType: .None)
        
        setupCollisionBody()
    }
    
    private func setupCollisionBody() {
        let offset = CGPoint(x: size.width * anchorPoint.x, y: size.height * anchorPoint.y)
        let path = CGPathCreateMutable()
        moveToPoint(CGPoint(x: 9, y: 18), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 12, y: 24), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 19, y: 25), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 26, y: 18), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 25, y: 12), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 19, y: 7), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 11, y: 8), path: path, offset: offset)
        CGPathCloseSubpath(path)
        
        physicsBody = SKPhysicsBody(polygonFromPath: path)
        physicsBody?.categoryBitMask = PhysicsCategory.AlienLaser
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = PhysicsCategory.Player
    }
}

//
//  ParallaxNode.swift
//  Pew
//
//  Created by Shuangzuan He on 4/17/15.
//  Copyright (c) 2015 Pretty Seven. All rights reserved.
//

import SpriteKit

class ParallaxNode: SKNode {
    
    private let velocity: CGPoint
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(velocity: CGPoint) {
        self.velocity = velocity
        
        super.init()
    }
    
    func addChild(node: SKSpriteNode, parallaxRatio: CGFloat) {
        node.userData = NSMutableDictionary(object: parallaxRatio, forKey: "ParallaxRatio")
        
        super.addChild(node)
    }
    
    func update(deltaTime: NSTimeInterval) {
        for (idx, node) in enumerate(children) {
            if let node = node as? SKSpriteNode {
                if let userData = node.userData {
                    if let parallaxRatio = userData.objectForKey("ParallaxRatio") as? CGFloat {
                        let childVelocity = velocity * parallaxRatio
                        let offset = childVelocity * CGFloat(deltaTime)
                        node.position = node.position + offset
                    }
                }
            }
            
        }
    }
}

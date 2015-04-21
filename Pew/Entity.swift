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

enum HealthBarType {
    case None
    case Green
    case Red
}

class Entity: SKSpriteNode {
    
    var hp = 0
    var maxHp = 0
    
    var healthBarType = HealthBarType.None
    var healthBarBg: SKSpriteNode!
    var healthBarProgress: SKSpriteNode!
    var fullWidth: CGFloat = 0
    var displayedWidth: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(imageNamed name: String, maxHp: Int, healthBarType: HealthBarType) {
        let texture = SKTexture(imageNamed: name)
        
        super.init(texture: texture, color: nil, size: texture.size())
        
        self.maxHp = maxHp
        hp = maxHp
        self.healthBarType = healthBarType
        
        setupHealthBar()
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
        if healthBarType == .None {
            return
        }
        
        var percentage = CGFloat(hp) / CGFloat(maxHp)
        percentage = min(percentage, 1)
        percentage = max(percentage, 0)
        
        let desiredWidth = fullWidth * percentage
        
        let POINTS_PER_SEC: CGFloat = 50
        if desiredWidth < displayedWidth {
            displayedWidth = max(desiredWidth, displayedWidth - POINTS_PER_SEC * CGFloat(dt))
        } else {
            displayedWidth = min(desiredWidth, displayedWidth + POINTS_PER_SEC * CGFloat(dt))
        }
        
        healthBarProgress.size = CGSize(width: displayedWidth, height: healthBarProgress.size.height)
        
        // Auto fading the health bar
        if desiredWidth != displayedWidth {
            for sprite in [healthBarBg, healthBarProgress] {
                sprite.hidden = false
                sprite.removeAllActions()
                sprite.runAction(SKAction.sequence([
                    SKAction.fadeInWithDuration(0.25),
                    SKAction.waitForDuration(2),
                    SKAction.fadeOutWithDuration(0.25),
                    SKAction.runBlock {
                        sprite.hidden = true
                    }
                ]))
            }
        }
    }
    
    func setupHealthBar() {
        if healthBarType == .None {
            return
        }
        
        healthBarBg = SKSpriteNode(imageNamed: "healthbar_bg")
        healthBarBg.position = CGPoint(x: 0, y: 0.5*size.height)
        addChild(healthBarBg)
        
        var progressSpriteName: String
        if healthBarType == .Green {
            progressSpriteName = "healthbar_green"
        } else {
            progressSpriteName = "healthbar_red"
        }
        
        healthBarProgress = SKSpriteNode(imageNamed: progressSpriteName)
        healthBarProgress.anchorPoint = CGPointZero
        healthBarProgress.position = healthBarBg.position
        healthBarProgress.position = CGPoint(
            x: healthBarBg.position.x - healthBarProgress.size.width/2,
            y: healthBarBg.position.y - healthBarProgress.size.height/2
        )
        addChild(healthBarProgress)
        
        fullWidth = healthBarBg.size.width
        displayedWidth = fullWidth
        
        healthBarProgress.hidden = true
        healthBarBg.hidden = true
    }
}

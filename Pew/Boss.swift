//
//  Boss.swift
//  Pew
//
//  Created by Shuangzuan He on 4/21/15.
//  Copyright (c) 2015 Pretty Seven. All rights reserved.
//

import SpriteKit

class Boss: Entity {
   
    private var initialMove = false
    
    private var shooter1: SKSpriteNode!
    private var shooter2: SKSpriteNode!
    private var cannon: SKSpriteNode!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(imageNamed: "Boss_ship", maxHp: 50, healthBarType: .Red)
        
        setupCollisionBody()
        setupWeapons()
    }
    
    private func setupCollisionBody() {
        let offset = CGPoint(x: size.width * anchorPoint.x, y: size.height * anchorPoint.y)
        let path = CGPathCreateMutable()
        moveToPoint(CGPoint(x: 60, y: 98), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 142, y: 107), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 175, y: 42), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 155, y: 14), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 39, y: 9), path: path, offset: offset)
        addLineToPoint(CGPoint(x: 6, y: 27), path: path, offset: offset)
        CGPathCloseSubpath(path)
        
        physicsBody = SKPhysicsBody(polygonFromPath: path)
        physicsBody?.categoryBitMask = PhysicsCategory.Alien
        physicsBody?.collisionBitMask = 0
        physicsBody?.contactTestBitMask = PhysicsCategory.PlayerLaser
    }
    
    private func setupWeapons() {
        shooter1 = SKSpriteNode(imageNamed: "Boss_shooter")
        shooter1.position = CGPoint(x: 0.15*size.width, y: 0)
        addChild(shooter1)
        
        shooter2 = SKSpriteNode(imageNamed: "Boss_shooter")
        shooter2.position = CGPoint(x: 0.05*size.width, y: -0.4*size.height)
        addChild(shooter2)
        
        cannon = SKSpriteNode(imageNamed: "Boss_cannon")
        cannon.position = CGPoint(x: 0, y: 0.45*size.height)
        addChild(cannon)
    }
    
    private func performRandomAction() {
        let randomAction = arc4random() % 5
        var action: SKAction!
        
        if randomAction == 0 || !initialMove {
            initialMove = true
            
            let randWidth = CGFloat.random(min: 0.6*scene!.size.width, max: 1*scene!.size.width)
            let randHeight = CGFloat.random(min: 0.1*scene!.size.height, max: 0.9*scene!.size.height)
            let randDest = CGPoint(x: randWidth, y: randHeight)
            
            let offset = position - randDest
            let length = offset.length()
            let BOSS_POINTS_PER_SEC: CGFloat = 100
            let duration = NSTimeInterval(length / BOSS_POINTS_PER_SEC)
            
            println("Moving to \(randDest) over \(duration)")
            
            action = SKAction.moveTo(randDest, duration: duration)
        } else if randomAction == 1 {
            action = SKAction.waitForDuration(0.2)
        } else if randomAction >= 2 && randomAction < 4 {
            if let scene = scene as? GameScene {
                scene.spawnAlienLaserAtPosition(convertPoint(shooter1.position, toNode: parent!))
                scene.spawnAlienLaserAtPosition(convertPoint(shooter2.position, toNode: parent!))
                action = SKAction.waitForDuration(0.2)
            }
        } else if randomAction == 4 {
            if let scene = scene as? GameScene {
                scene.shootCannonBallAtPlayerFromPosition(convertPoint(cannon.position, toNode: parent!))
                action = SKAction.waitForDuration(0.2)
            }
        }
        
        runAction(SKAction.sequence([
            action,
            SKAction.runBlock {
                self.performRandomAction()
            }
        ]))
    }
    
    private func updateCannon() {
        if let scene = scene as? GameScene {
            let cannonWorld = convertPoint(cannon.position, toNode: parent!)
            let offsetToPlayer = cannonWorld - scene.player.position
            let cannonAngle = offsetToPlayer.angle
            cannon.zRotation = cannonAngle
        }
    }
    
    override func update(dt: CFTimeInterval) {
        super.update(dt)
        
        if !initialMove {
            performRandomAction()
        }
        
        updateCannon()
    }
    
    override func collideBody(body: SKPhysicsBody, contact: SKPhysicsContact) {
        if body.categoryBitMask == PhysicsCategory.PlayerLaser {
            if let other = body.node as? Entity {
                other.destroy()
                takeHit()
                
                if let scene = scene as? GameScene {
                    if isDead() {
                        scene.spawnExplosionAtPosition(contact.contactPoint, scale: xScale, large: true)
                        scene.nextStage()
                    } else {
                        scene.spawnExplosionAtPosition(contact.contactPoint, scale: xScale, large: false)
                    }
                }
            }
        }
    }
}

//
//  GameScene.swift
//  Pew
//
//  Created by Shuangzuan He on 4/16/15.
//  Copyright (c) 2015 Pretty Seven. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Layer
    private let gameLayer = SKNode()
    private let hudLayer = SKNode()
    
    // Title
    private var titleLabel1: SKLabelNode!
    private var titleLabel2: SKLabelNode!
    private var playLabel: SKLabelNode!
    private var levelIntroLabel1: SKLabelNode!
    private var levelIntroLabel2: SKLabelNode!
    
    // Sound
    private let soundExplosionLarge = SKAction.playSoundFileNamed("explosion_large.caf", waitForCompletion: false)
    private let soundExplosionSmall = SKAction.playSoundFileNamed("explosion_small.caf", waitForCompletion: false)
    private let soundLaserEnemy = SKAction.playSoundFileNamed("laser_enemy.caf", waitForCompletion: false)
    private let soundLaserShip = SKAction.playSoundFileNamed("laser_ship.caf", waitForCompletion: false)
    private let soundShake = SKAction.playSoundFileNamed("shake.caf", waitForCompletion: false)
    private let soundPowerup = SKAction.playSoundFileNamed("powerup.caf", waitForCompletion: false)
    private let soundBoss = SKAction.playSoundFileNamed("boss.caf", waitForCompletion: false)
    private let soundCannon = SKAction.playSoundFileNamed("cannon.caf", waitForCompletion: false)
    private let soundTitle = SKAction.playSoundFileNamed("title.caf", waitForCompletion: false)
    
    // Level manager
    private let levelManager = LevelManager()
    private var okToRestart = false
    // private var timeSinceGameStarted: NSTimeInterval = 0
    // private var timeForGameWon: NSTimeInterval = 30
    
    // Player
    let player = Player()
    
    // Motion
    private let motionManager = CMMotionManager()
    
    // Update time
    private var lastUpdateTime: NSTimeInterval = 0
    private var deltaTime: NSTimeInterval = 0
    
    // Asteroid
    private var timeSinceLastAsteroidSpawn: NSTimeInterval = 0
    private var timeForNextAsteroidSpawn: NSTimeInterval = 0
    
    // Parallax node
    private var parallaxNode: ParallaxNode!
    private var spacedust1: SKSpriteNode!
    private var spacedust2: SKSpriteNode!
    private var planetsunrise: SKSpriteNode!
    private var galaxy: SKSpriteNode!
    private var spatialanomaly: SKSpriteNode!
    private var spatialanomaly2: SKSpriteNode!
    
    // Alien
    private var numAlienSpawns = 0
    private var timeSinceLastAlienSpawn: NSTimeInterval = 0
    private var timeForNextAlienSpawn: NSTimeInterval = 0
    private var alienPath: UIBezierPath!
    
    // Powerup
    private var timeSinceLastPowerup: NSTimeInterval = 0
    private var timeForNextPowerup: NSTimeInterval = 0
    
    // Boss
    private var boss: Boss!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        backgroundColor = SKColor.blackColor()
        
        setupSound()
        setupLayers()
        setupTitle()
        setupStars()
        setupLevelManager()
        setupPlayer()
        setupMotionManager()
        setupPhysics()
        setupBackground()
    }

    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        switch levelManager.gameState {
        case .MainMenu:
            startSpawn()
        case .Play:
            spawnPlayerLaser()
        case .Done:
            println("Done")
        case .Over:
            if okToRestart {
                let gameScene = GameScene(size: size)
                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                view?.presentScene(gameScene, transition: reveal)
                return
            }
        }
        
        /*
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
            
        } */
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if lastUpdateTime != 0 {
            deltaTime = currentTime - lastUpdateTime
        } else {
            deltaTime = 0
        }
        lastUpdateTime = currentTime
        
        updateBg()
        
        if levelManager.gameState != .Play {
            return
        }
        
        updatePlayer()
        updateAsteroids()
        
        // timeSinceGameStarted += deltaTime
        // if timeSinceGameStarted > timeForGameWon {
        //     endScene(true)
        // }
        
        updateLevel()
        updateAliens()
        updateChildren()
        updatePowerups()
    }
    
    // MARK: - Public methods
    
    func playExplosionLargeSound() {
        runAction(soundExplosionLarge)
    }
    
    func spawnExplosionAtPosition(position: CGPoint, scale: CGFloat, large: Bool) {
        var myEmitter: SKEmitterNode!
        
        if large {
            if let path = NSBundle.mainBundle().pathForResource("Explosion", ofType: "sks") {
                if let emitter = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? SKEmitterNode {
                    myEmitter = emitter
                }
            }
        } else {
            if let path = NSBundle.mainBundle().pathForResource("SmallExplosion", ofType: "sks") {
                if let emitter = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? SKEmitterNode {
                    myEmitter = emitter
                }
            }
        }
        
        myEmitter.position = position
        myEmitter.particleScale = scale
        myEmitter.numParticlesToEmit = Int(CGFloat(myEmitter.numParticlesToEmit) * scale)
        myEmitter.particleLifetime /= scale
        myEmitter.particlePositionRange = CGVector(
            dx: myEmitter.particlePositionRange.dx * scale,
            dy: myEmitter.particlePositionRange.dy * scale
        );
        myEmitter.runAction(SKAction.removeFromParentAfterDelay(1))
        gameLayer.addChild(myEmitter)
        
        if large {
            runAction(soundExplosionLarge)
            shakeScreen(Int(10 * scale))
        } else {
            runAction(soundExplosionSmall)
        }
    }
    
    func endScene(win: Bool) {
        if levelManager.gameState == .Over {
            return
        }
        
        levelManager.gameState = .Over
        
        let fontName = "Avenir-Light"
        var message: String
        if win {
            message = "You win!"
        } else {
            message = "You lose!"
        }
        
        // Message label
        let messageLabel = SKLabelNode(fontNamed: fontName)
        messageLabel.text = message
        messageLabel.fontSize = 72
        messageLabel.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        messageLabel.position = CGPoint(x: size.width / 2, y: 0.6 * size.height)
        messageLabel.verticalAlignmentMode = .Center
        hudLayer.addChild(messageLabel)
        
        messageLabel.setScale(0)
        let scaleAction = SKAction.scaleTo(1, duration: 0.5)
        scaleAction.timingMode = .EaseOut
        messageLabel.runAction(scaleAction)
        
        // Restart label
        let restartLabel = SKLabelNode(fontNamed: fontName)
        restartLabel.text = "Tap to Restart"
        restartLabel.fontSize = 32
        restartLabel.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        restartLabel.position = CGPoint(x: size.width / 2, y: 0.3 * size.height)
        restartLabel.verticalAlignmentMode = .Center
        hudLayer.addChild(restartLabel)
        
        restartLabel.setScale(0)
        let scaleUpAction = SKAction.scaleTo(1.1, duration: 0.5)
        scaleUpAction.timingMode = .EaseOut
        let scaleDownAction = SKAction.scaleTo(0.9, duration: 0.5)
        scaleDownAction.timingMode = .EaseOut
        let okToRestartAction = SKAction.runBlock { () -> Void in
            self.okToRestart = true
        }
        restartLabel.runAction(SKAction.sequence([
            SKAction.waitForDuration(1.5),
            scaleAction,
            okToRestartAction,
            SKAction.repeatActionForever(SKAction.sequence([
                scaleUpAction,
                scaleDownAction
                ]))
            ]))
    }
    
    // MARK: - Private methods
    
    private func setupLayers() {
        addChild(gameLayer)
        addChild(hudLayer)
    }
    
    private func setupTitle() {
        let fontName = "Avenir-Light"
        
        // Configure
        
        titleLabel1 = SKLabelNode(fontNamed: fontName)
        titleLabel1.text = "Pew Pew Pew"
        titleLabel1.fontSize = 48
        titleLabel1.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        titleLabel1.position = CGPoint(x: size.width/2, y: 0.8*size.height)
        titleLabel1.verticalAlignmentMode = .Center
        hudLayer.addChild(titleLabel1)
        
        titleLabel2 = SKLabelNode(fontNamed: fontName)
        titleLabel2.text = "Keep Firing"
        titleLabel2.fontSize = 72
        titleLabel2.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        titleLabel2.position = CGPoint(x: size.width/2, y: 0.5*size.height)
        titleLabel2.verticalAlignmentMode = .Center
        hudLayer.addChild(titleLabel2)
        
        playLabel = SKLabelNode(fontNamed: fontName)
        playLabel.text = "Tap to Play"
        playLabel.fontSize = 32
        playLabel.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        playLabel.position = CGPoint(x: size.width/2, y: 0.2*size.height)
        playLabel.verticalAlignmentMode = .Center
        hudLayer.addChild(playLabel)
        
        // Animation
        
        titleLabel1.setScale(0)
        let waitAction1 = SKAction.waitForDuration(1)
        let scaleAction1 = SKAction.scaleTo(1, duration: 0.5)
        scaleAction1.timingMode = .EaseOut
        titleLabel1.runAction(SKAction.sequence([
            waitAction1,
            soundTitle,
            scaleAction1
        ]))
        
        titleLabel2.setScale(0)
        let waitAction2 = SKAction.waitForDuration(2)
        let scaleAction2 = SKAction.scaleTo(1, duration: 1)
        scaleAction2.timingMode = .EaseOut
        titleLabel2.runAction(SKAction.sequence([
            waitAction2,
            scaleAction2
        ]))
        
        playLabel.setScale(0)
        let waitAction3 = SKAction.waitForDuration(3)
        let scaleAction3 = SKAction.scaleTo(1, duration: 0.5)
        scaleAction3.timingMode = .EaseOut
        let scaleUpAction = SKAction.scaleTo(1.1, duration: 0.5)
        scaleUpAction.timingMode = .EaseOut
        let scaleDownAction = SKAction.scaleTo(0.9, duration: 0.5)
        scaleDownAction.timingMode = .EaseOut
        let throbAction = SKAction.repeatActionForever(SKAction.sequence([scaleUpAction, scaleDownAction]))
        playLabel.runAction(SKAction.sequence([
            waitAction3,
            scaleAction3,
            throbAction
        ]))
    }
    
    private func setupSound() {
        SKTAudio.sharedInstance().playBackgroundMusic("SpaceGame.caf")
    }
    
    private func setupStars() {
        for stars in ["Stars1.sks", "Stars2.sks", "Stars3.sks"] {
            if let path = NSBundle.mainBundle().pathForResource(stars, ofType: nil) {
                if let emitter = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? SKEmitterNode {
                    emitter.position = CGPoint(x: size.width, y: size.height/2)
                    emitter.particlePositionRange = CGVector(dx: emitter.particlePositionRange.dx, dy: size.height)
                    emitter.zPosition = -1
                    gameLayer.addChild(emitter)
                }
            }
        }
    }
    
    private func setupLevelManager() {
        
    }
    
    private func setupPlayer() {
        player.position = CGPoint(x: -player.size.width/2, y: 0.5*size.height)
        player.zPosition = 1
        player.name = "player"
        gameLayer.addChild(player)
    }
    
    private func setupMotionManager() {
        motionManager.accelerometerUpdateInterval = 0.05
        motionManager.startAccelerometerUpdates()
    }
    
    private func setupPhysics() {
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    private func setupBackground() {
        spacedust1 = SKSpriteNode(imageNamed: "bg_front_spacedust")
        spacedust1.position = CGPoint(x: 0, y: size.height/2)
        spacedust2 = SKSpriteNode(imageNamed: "bg_front_spacedust")
        spacedust2.position = CGPoint(x: spacedust2.size.width, y: size.height/2)
        planetsunrise = SKSpriteNode(imageNamed: "bg_planetsunrise")
        planetsunrise.position = CGPoint(x: 600, y: 0)
        galaxy = SKSpriteNode(imageNamed: "bg_galaxy")
        galaxy.position = CGPoint(x: 0, y: 0.7 * size.height)
        spatialanomaly = SKSpriteNode(imageNamed: "bg_spacialanomaly")
        spatialanomaly.position = CGPoint(x: 900, y: 0.3 * size.height)
        spatialanomaly2 = SKSpriteNode(imageNamed: "bg_spacialanomaly2")
        spatialanomaly2.position = CGPoint(x: 1500, y: 0.9 * size.height)
        
        parallaxNode = ParallaxNode(velocity: CGPoint(x: -100, y: 0))
        parallaxNode.position = CGPointZero
        parallaxNode.addChild(spacedust1, parallaxRatio: 1)
        parallaxNode.addChild(spacedust2, parallaxRatio: 1)
        parallaxNode.addChild(planetsunrise, parallaxRatio: 0.5)
        parallaxNode.addChild(galaxy, parallaxRatio: 0.5)
        parallaxNode.addChild(spatialanomaly, parallaxRatio: 0.5)
        parallaxNode.addChild(spatialanomaly2, parallaxRatio: 0.5)
        parallaxNode.zPosition = -1
        gameLayer.addChild(parallaxNode)
    }
    
    private func shakeScreen(oscillations: Int) {
        let action = SKAction.screenShakeWithNode(gameLayer, amount: CGPoint(x: 0, y: 10), oscillations: oscillations, duration: 0.1 * Double(oscillations))
        gameLayer.runAction(action)
    }
    
    func nextStage() {
        levelManager.nextStage()
        newStageStarted()
    }
    
    private func newStageStarted() {
        if levelManager.gameState == .Done {
            endScene(true)
        } else if let x = levelManager.boolForProp("SpawnLevelIntro") {
            if x {
                doLevelIntro()
            }
        } else if levelManager.hasProp("SpawnBoss") {
            spawnBoss()
        }
    }
    
    private func doLevelIntro() {
        let fontName = "Avenir-Light"
        
        let message1 = "Level \(levelManager.curLevelIdx+1)"
        let message2 = levelManager.stringForProp("LText")!
        
        // Level intro label 1
        levelIntroLabel1 = SKLabelNode(fontNamed: fontName)
        levelIntroLabel1.text = message1
        levelIntroLabel1.fontSize = 48
        levelIntroLabel1.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        levelIntroLabel1.position = CGPoint(x: size.width/2, y: 0.6*size.height)
        levelIntroLabel1.verticalAlignmentMode = .Center
        hudLayer.addChild(levelIntroLabel1)
        
        levelIntroLabel1.setScale(0)
        let scaleUpAction1 = SKAction.scaleTo(1, duration: 0.5)
        scaleUpAction1.timingMode = .EaseOut
        let delayAction1 = SKAction.waitForDuration(3)
        let scaleDownAction1 = SKAction.scaleTo(0, duration: 0.5)
        scaleDownAction1.timingMode = .EaseOut
        let removeAction = SKAction.removeFromParent()
        let scaleUpDown = SKAction.sequence([
            scaleUpAction1,
            delayAction1,
            scaleDownAction1,
            removeAction
        ])
        levelIntroLabel1.runAction(scaleUpDown)
        
        // Level intro label 2
        levelIntroLabel2 = SKLabelNode(fontNamed: fontName)
        levelIntroLabel2.text = message2
        levelIntroLabel2.fontSize = 48
        levelIntroLabel2.fontColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
        levelIntroLabel2.position = CGPoint(x: size.width/2, y: 0.4*size.height)
        levelIntroLabel2.verticalAlignmentMode = .Center
        hudLayer.addChild(levelIntroLabel2)
        
        levelIntroLabel2.setScale(0)
        levelIntroLabel2.runAction(scaleUpDown)
    }
    
    func applyPowerup() {
        runAction(soundPowerup)
        
        if let path = NSBundle.mainBundle().pathForResource("Boost", ofType: "sks") {
            if let emitter = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? SKEmitterNode {
                emitter.zPosition = -1
                player.addChild(emitter)
                
                let scaleDuration = 1.0
                let waitDuration = 5.0
                
                player.invincible = true
                let moveForwardAction = SKAction.moveByX(0.6*size.width, y: 0, duration: scaleDuration)
                let waitAction = SKAction.waitForDuration(waitDuration)
                let moveBackAction = moveForwardAction.reversedAction()
                let boostDoneAction = SKAction.runBlock {
                    self.player.invincible = false
                    emitter.removeFromParent()
                }
                player.runAction(SKAction.sequence([
                    moveForwardAction,
                    waitAction,
                    moveBackAction,
                    boostDoneAction
                ]))
                
                let scale: CGFloat = 0.9 // 0.75
                
                let diffX = (spacedust1.size.width - spacedust1.size.width * scale) / 2
                let diffY = (spacedust1.size.height - spacedust1.size.height * scale) / 2
                let moveOutAction = SKAction.moveByX(diffX, y: diffY, duration: scaleDuration)
                let moveInAction = moveOutAction.reversedAction()
                let scaleOutAction = SKAction.scaleTo(scale, duration: scaleDuration)
                let scaleInAction = SKAction.scaleTo(1, duration: scaleDuration)
                let outAction = SKAction.group([moveOutAction, scaleOutAction])
                let inAction = SKAction.group([moveInAction, scaleInAction])
                gameLayer.runAction(SKAction.sequence([outAction, waitAction, inAction]))
            }
        }

    }
    
    // MARK: Transitions
    
    private func startSpawn() {
        levelManager.gameState = .Play
        runAction(soundPowerup)
        
        for node in [titleLabel1, titleLabel2, playLabel] {
            let scaleAction = SKAction.scaleTo(0, duration: 0.5)
            scaleAction.timingMode = .EaseOut
            node.runAction(SKAction.sequence([
                scaleAction,
                SKAction.removeFromParent()
            ]))
        }
        
        spawnPlayer()
        
        // timeSinceGameStarted = 0
        // timeForGameWon = 30
        
        nextStage()
    }
    
    private func spawnPlayer() {
        let moveAction1 = SKAction.moveBy(CGVector(dx: player.size.width/2 + 0.3*size.width, dy: 0), duration: 0.5)
        moveAction1.timingMode = .EaseOut
        let moveAction2 = SKAction.moveBy(CGVector(dx: -0.2*size.width, dy: 0), duration: 0.5)
        moveAction2.timingMode = .EaseOut
        player.runAction(SKAction.sequence([moveAction1, moveAction2]))
    }
    
    // MARK: Update methods
    
    private func updatePlayer() {
        let kFilteringFactor = 0.75
        struct Rolling {
            static var x = 0.0
            static var y = 0.0
            static var z = 0.0
        }
        
        if let accelerometerData = motionManager.accelerometerData {
            Rolling.x = accelerometerData.acceleration.x * kFilteringFactor + Rolling.x * (1 - kFilteringFactor)
            Rolling.y = accelerometerData.acceleration.y * kFilteringFactor + Rolling.y * (1 - kFilteringFactor)
            Rolling.z = accelerometerData.acceleration.z * kFilteringFactor + Rolling.z * (1 - kFilteringFactor)
            
            let accelX = CGFloat(Rolling.x)
            let accelY = CGFloat(Rolling.y)
            let accelZ = CGFloat(Rolling.z)
            
            // println("accelX: \(accelX), accelY: \(accelY), accelZ: \(accelZ)")
            
            let kRestAccelX: CGFloat = 0.6
            let kPlayerMaxPointsPerSec = 0.5 * size.height
            let kMaxDiffX: CGFloat = 0.2
            
            let accelDiffX = kRestAccelX - abs(accelX)
            let accelFractionX = accelDiffX / kMaxDiffX
            let pointsPerSecX = kPlayerMaxPointsPerSec * accelFractionX
            
            let playerPointsPerSecY = pointsPerSecX
            let maxY = size.height - player.size.height/2
            let minY = player.size.height / 2
            
            var newY = player.position.y + playerPointsPerSecY * CGFloat(deltaTime)
            newY = min(max(newY, minY), maxY)
            
            player.position = CGPoint(x: player.position.x, y: newY)
        }
    }
    
    private func updateAsteroids() {
        if let x = levelManager.boolForProp("SpawnAsteroids") {
            
        } else {
            return
        }
        
        let spawnSecsLow = NSTimeInterval(levelManager.floatForProp("ASpawnSecsLow")!)
        let spawnSecsHigh = NSTimeInterval(levelManager.floatForProp("ASpawnSecsHigh")!)
        
        timeSinceLastAsteroidSpawn += deltaTime
        if timeSinceLastAsteroidSpawn > timeForNextAsteroidSpawn {
            timeSinceLastAsteroidSpawn = 0
            timeForNextAsteroidSpawn = NSTimeInterval(CGFloat.random(min: CGFloat(spawnSecsLow), max: CGFloat(spawnSecsHigh)))
            
            spawnAsteroid()
        }
    }
    
    private func updateBg() {
        parallaxNode.update(deltaTime)
        
        for bg in [spacedust1, spacedust2, planetsunrise, galaxy, spatialanomaly, spatialanomaly2] {
            let scenePos = bg.convertPoint(bg.position, toNode: self)
            if scenePos.x < -bg.size.width {
                bg.position = bg.position + CGPoint(x: 2 * spacedust1.size.width, y: 0)
            }
        }
    }
    
    private func updateLevel() {
        let newStage = levelManager.update()
        if newStage {
            newStageStarted()
        }
    }
    
    private func updateAliens() {
        if let x = levelManager.boolForProp("SpawnAlienSwarm") {
            if !x {
                return
            }
        } else {
            return
        }
        
        timeSinceLastAlienSpawn += deltaTime
        if timeSinceLastAlienSpawn > timeForNextAlienSpawn {
            timeSinceLastAlienSpawn = 0
            timeForNextAlienSpawn = 0.3
            spawnAlien()
        }
    }
    
    private func updateChildren() {
        for obj in gameLayer.children {
            if let obj = obj as? Entity {
                obj.update(deltaTime)
            }
        }
    }
    
    private func updatePowerups() {
        if let x = levelManager.boolForProp("SpawnPowerups") {
            if !x {
                return
            }
        } else {
            return
        }
        
        timeSinceLastPowerup += deltaTime
        if timeSinceLastPowerup > timeForNextPowerup {
            timeSinceLastPowerup = 0
            timeForNextPowerup = NSTimeInterval(levelManager.floatForProp("PSpawnSecs")!)
            spawnPowerup()
        }
    }
    
    // MARK: Asteroids
    
    private func spawnAsteroid() {
        let moveDurationLow = CGFloat(levelManager.floatForProp("AMoveDurationLow")!)
        let moveDurationHigh = CGFloat(levelManager.floatForProp("AMoveDurationHigh")!)
        
        let asteroid = Asteroid(asteroidType: AsteroidType(rawValue: arc4random_uniform(AsteroidType.NumAsteroidTypes.rawValue))!)
        asteroid.name = "asteroid"
        asteroid.position = CGPoint(x: size.width + asteroid.size.width/2, y: CGFloat.random(min: 0, max: size.height))
        gameLayer.addChild(asteroid)
        
        asteroid.runAction(SKAction.sequence([
            SKAction.moveBy(CGVector(dx: -1.5 * size.width, dy: 0), duration: Double(CGFloat.random(min: moveDurationLow, max: moveDurationHigh))),
            SKAction.removeFromParent()
        ]))
    }
    
    // MARK: Aliens
    
    private func spawnAlien() {
        if numAlienSpawns == 0 {
            let alienPosStart = CGPoint(x: 1.3*size.width, y: CGFloat.random(min: 0.9*size.height, max: 1*size.height))
            let cp1 = CGPoint(
                x: CGFloat.random(min: -0.1*size.width, max: 0.6*size.height),
                y: CGFloat.random(min: 0.7*size.height, max: 1*size.height)
            )
            
            let alienPosEnd = CGPoint(x: 1.3*size.width, y: CGFloat.random(min: 0, max: 0.1*size.height))
            let cp2 = CGPoint(
                x: CGFloat.random(min: -0.1*size.width, max: 0.6*size.height),
                y: CGFloat.random(min: 0, max: 0.3*size.height)
            )
            
            alienPath = UIBezierPath()
            alienPath.moveToPoint(alienPosStart)
            alienPath.addCurveToPoint(alienPosEnd, controlPoint1: cp1, controlPoint2: cp2)
            
            numAlienSpawns = Int.random(min: 1, max: 20)
            timeForNextAlienSpawn = 1
        } else {
            --numAlienSpawns
            
            let alien = Alien()
            alien.name = "alien"
            let pathAction = SKAction.followPath(alienPath.CGPath, asOffset: false, orientToPath: false, duration: 3)
            let removeAction = SKAction.removeFromParent()
            alien.runAction(SKAction.sequence([pathAction, removeAction]))
            gameLayer.addChild(alien)
        }
    }
    
    // MARK: Lasers and Cannons
    
    private func spawnPlayerLaser() {
        let laser = PlayerLaser()
        laser.position = CGPoint(x: player.position.x + 6, y: player.position.y - 4)
        laser.name = "laser"
        gameLayer.addChild(laser)
        
        laser.alpha = 0
        laser.runAction(SKAction.fadeAlphaTo(1, duration: 0.1))
        laser.runAction(SKAction.sequence([
            SKAction.moveToX(size.width + laser.size.width/2, duration: 0.75),
            SKAction.removeFromParent()
        ]))
        
        runAction(soundLaserShip)
    }
    
    func spawnAlienLaserAtPosition(position: CGPoint) {
        let laser = AlienLaser()
        laser.position = position
        gameLayer.addChild(laser)
        
        let moveAction = SKAction.moveBy(CGVector(dx: -size.width, dy: 0), duration: 2)
        let removeAction = SKAction.removeFromParent()
        laser.runAction(SKAction.sequence([moveAction, removeAction]))
        runAction(soundLaserEnemy)
    }
    
    func shootCannonBallAtPlayerFromPosition(position: CGPoint) {
        let cannonBall = CannonBall()
        cannonBall.position = position
        gameLayer.addChild(cannonBall)
        
        let offset = player.position - cannonBall.position
        let shootVector = offset.normalized()
        let shootTarget = shootVector * (2*size.width)
        
        cannonBall.runAction(SKAction.sequence([
            SKAction.moveByX(shootTarget.x, y: shootTarget.y, duration: 5),
            SKAction.removeFromParent()
        ]))
    }
    
    // MARK: Powerups
    
    private func spawnPowerup() {
        let powerup = Powerup()
        powerup.position = CGPoint(x: size.width, y: CGFloat.random(min: 0, max: size.height))
        
        let moveAction = SKAction.moveByX(-size.width, y: 0, duration: 5)
        let removeAction = SKAction.removeFromParent()
        powerup.runAction(SKAction.sequence([moveAction, removeAction]))
        gameLayer.addChild(powerup)
    }
    
    // MARK: Boss
    
    private func spawnBoss() {
        boss = Boss()
        boss.position = CGPoint(x: 1.2*size.width, y: 1.2*size.height)
        gameLayer.addChild(boss)
        
        shakeScreen(100)
        runAction(soundBoss)
    }
    
    // MARK: - Physics contact delegate
    
    func didBeginContact(contact: SKPhysicsContact) {
        if let node = contact.bodyA.node as? Entity {
            node.collideBody(contact.bodyB, contact: contact)
        }
        
        if let node = contact.bodyB.node as? Entity {
            node.collideBody(contact.bodyA, contact: contact)
        }
    }
}

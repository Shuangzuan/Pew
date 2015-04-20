//
//  LevelManager.swift
//  Pew
//
//  Created by Shuangzuan He on 4/16/15.
//  Copyright (c) 2015 Pretty Seven. All rights reserved.
//

import Foundation
import QuartzCore

enum GameState {
    case MainMenu
    case Play
    case Done
    case Over
}

class LevelManager {
    
    var gameState = GameState.MainMenu
    
    private var stageStart: NSTimeInterval = 0
    private var stageDuration: NSTimeInterval = 0
    
    private var data = NSDictionary()
    private var levels = NSArray()
    
    var curLevelIdx = -1
    private var curStages = NSArray()
    private var curStageIdx = -1
    private var curStage = NSDictionary()
    
    init() {
        if let levelDefsFile = NSBundle.mainBundle().pathForResource("Levels", ofType: "plist") {
            if let data = NSDictionary(contentsOfFile: levelDefsFile) {
                self.data = data
                
                if let levels = data["Levels"] as? NSArray {
                    self.levels = levels
                }
            }
        }
    }
    
    func hasProp(prop: String) -> Bool {
        if let retval: AnyObject = curStage[prop] {
            return true
        } else {
            return false
        }
    }
    
    func stringForProp(prop: String) -> String? {
        if let retval = curStage[prop] as? String {
            return retval
        } else {
            return nil
        }
    }
    
    func floatForProp(prop: String) -> Float? {
        if let retval = curStage[prop] as? NSNumber {
            return retval.floatValue
        } else {
            return nil
        }
    }
    
    func boolForProp(prop: String) -> Bool? {
        if let retval = curStage[prop] as? NSNumber {
            return retval.boolValue
        } else {
            return nil
        }
    }
    
    func nextLevel() {
        ++curLevelIdx
        
        if curLevelIdx >= levels.count {
            gameState = .Done
            return
        }
        
        if let curStages = levels[curLevelIdx] as? NSArray {
            self.curStages = curStages
            
            nextStage()
        }
    }
    
    func nextStage() {
        ++curStageIdx
        
        if curStageIdx >= curStages.count {
            curStageIdx = -1
            nextLevel()
            return
        }
        
        gameState = .Play
        curStage = curStages[curStageIdx] as! NSDictionary
        
        stageDuration = NSTimeInterval(floatForProp("Duration")!)
        stageStart = CACurrentMediaTime()
        
        println("Stage ending in: \(stageDuration)")
    }
    
    func update() -> Bool {
        if gameState != .Play {
            return false
        }
        
        if stageDuration == -1 {
            return false
        }
        
        let curTime = NSTimeInterval(CACurrentMediaTime())
        if curTime > stageStart + stageDuration {
            nextStage()
            return true
        }
        
        return false
    }
}
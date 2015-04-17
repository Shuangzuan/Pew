//
//  LevelManager.swift
//  Pew
//
//  Created by Shuangzuan He on 4/16/15.
//  Copyright (c) 2015 Pretty Seven. All rights reserved.
//

import Foundation

enum GameState {
    case MainMenu
    case Play
    case Done
    case Over
}

class LevelManager {
    
    var gameState = GameState.MainMenu
}
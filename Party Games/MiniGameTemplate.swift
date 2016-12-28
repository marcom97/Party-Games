//
//  MiniGameTemplate.swift
//  Party Games
//
//  Created by Marco Matamoros on 2016-12-27.
//  Copyright © 2016 Blue Stars. All rights reserved.
//

import SpriteKit
import GameKit

class MiniGameTemplate: MiniGame {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
    }
    
    override func start() {
        
    }
    
// Data Received
    override func receivedData(_ data: Data, fromPlayer player: GKPlayer) {

    }
}

// Messages
private enum MessageType: DataConvertible {
    case type
}

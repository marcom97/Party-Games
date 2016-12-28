//
//  TouchTargets.swift
//  Party Games
//
//  Created by Marco Matamoros on 2016-12-05.
//  Copyright © 2016 Blue Stars. All rights reserved.
//

import SpriteKit
import GameKit

class TouchTargets: MiniGame {
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        start()
    }
    
    override func start() {
        let label = SKLabelNode(text: "Start")
        label.fontSize = 100

        self.addChild(label)
    }
    
// Data Received
    override func receivedData(_ data: Data, fromPlayer player: GKPlayer) {

    }
}

// Messages
private enum MessageType: DataConvertible {
    case touchedTarget
}

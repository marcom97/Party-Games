//
//  MiniGame.swift
//  Party Games
//
//  Created by Marco Matamoros on 2016-12-06.
//  Copyright © 2016 Blue Stars. All rights reserved.
//

import SpriteKit
import GameKit

class MiniGame: SKScene, GKManagerDataDelegate {
    let sharedInstance = GKManager.sharedInstance
    var completion: (([String : Int]) -> Void)?
    var previousScene: SKScene?
    var rankings: [String : Int]?
    var scores: [String: Int]?
    var isHost: Bool {
        return GKManager.sharedInstance.host?.playerID == GKManager.sharedInstance.localPlayer?.playerID ? true : false
    }
    
    override func didMove(to view: SKView) {
        sharedInstance.dataDelegate = self
    }
    
    func receivedData(_ data: Data, fromPlayer player: GKPlayer) {

    }
    
    func start() {
        
    }
}

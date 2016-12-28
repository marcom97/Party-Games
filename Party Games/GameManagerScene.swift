//
//  GameManagerScene.swift
//  Party Games
//
//  Created by Marco Matamoros on 2016-11-02.
//  Copyright © 2016 Blue Stars. All rights reserved.
//

import SpriteKit
import GameKit

class GameManagerScene: SKScene, GKManagerConnectionDelegate, GKManagerDataDelegate {
    let sharedInstance = GKManager.sharedInstance
    var isHost: Bool {
        return GKManager.sharedInstance.host?.playerID == GKManager.sharedInstance.localPlayer?.playerID ? true : false
    }
    var label: SKLabelNode!
    var generator: GKShuffledDistribution?
    var scores: [String: Int]?
    var rankings: [String]?
    var miniGames: [String]! = ["TouchTargets"]
    var miniGame: MiniGame?
    
// DidMove
    override func didMove(to view: SKView) {
        sharedInstance.connectionDelegate = self
        sharedInstance.dataDelegate = self
        
        label = SKLabelNode(text: "Loading")
        label.fontSize = 100
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        self.addChild(label!)
        
        if (generator != nil) {
            nextMiniGame()
        }
        
    }
    
// Scene Functions
    func nextMiniGame() {
        miniGame = SKScene(fileNamed: miniGames[generator!.nextInt()]) as? MiniGame
        
        miniGame?.completion = {
            let MGRankings = $0
            
            for player in self.rankings! {
                var points: Int
                
                switch MGRankings[player]! {
                case 1:
                    points = 3
                case 2:
                    points = 2
                case 3:
                    points = 1
                default:
                    points = 0
                }
                
                self.scores?[player]! += points
            }
        }
        
        miniGame?.previousScene = self
        
        label.text = miniGame?.name
        
        run(SKAction.wait(forDuration: 2)) {
            self.view?.presentScene(self.miniGame)
        }
    }
    
// Connection Handling
    func player(_ player: GKPlayer, stateChanged state: GKPlayerConnectionState) {
        
    }
    
    func receivedData(_ data: Data, fromPlayer player: GKPlayer) {
        if let messageType = MessageType(data: data) {
            switch messageType {
            case .gameStart:
                if let message = GameStartMessage(data: data) {
                    let source = GKARC4RandomSource(seed: message.seed)
                    generator = GKShuffledDistribution(randomSource: source, lowestValue: 0, highestValue: miniGames.count - 1)
                }
                
                nextMiniGame()
            }
        }
    }
    
    func hostFound() {
        for player in (sharedInstance.match?.players)! {
            scores?[player.playerID!] = 0
        }
        
        if isHost {
            let source = GKARC4RandomSource()
            sharedInstance.send(GameStartMessage(seed: source.seed).data, mode: .reliable)
            
            generator = GKShuffledDistribution(randomSource: source, lowestValue: 0, highestValue: miniGames.count - 1)
            
            nextMiniGame()
        }
    }
}

// Messages
private enum MessageType: DataConvertible {
    case gameStart
}

private struct GameStartMessage {
    let type = MessageType.gameStart
    let seed: Data
}

extension GameStartMessage: DataConvertible {
    init?(data: Data) {
        seed = data.subdata(in: MemoryLayout<MessageType>.size..<data.endIndex)
    }
    
    var data: Data {
        var data = type.data
        data.append(self.seed)
        
        return data
    }
}

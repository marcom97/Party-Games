//
//  GameManagerScene.swift
//  Party Games
//
//  Created by Marco Matamoros on 2016-11-02.
//  Copyright © 2016 Blue Stars. All rights reserved.
//

import SpriteKit
import GameKit

class GameManagerScene: SKScene, GKManagerDelegate {
    let sharedInstance = GKManager.sharedInstance
    var isHost: Bool {
        return GKManager.sharedInstance.host?.playerID == GKManager.sharedInstance.localPlayer?.playerID ? true : false
    }
    var label: SKLabelNode!
    var generator: GKShuffledDistribution!
    var scores: [GKPlayer: Int]?
    var rankings: [GKPlayer]?
    var miniGames: [String]!
    
// DidMove
    override func didMove(to view: SKView) {
        sharedInstance.delegate = self
        
        label = SKLabelNode(text: "Waiting for other players")
        label.fontSize = 100
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        self.addChild(label!)
    }
    
    func player(_ player: GKPlayer, stateChanged state: GKPlayerConnectionState) {
        
    }
    
    func receivedData(_ data: Data, fromPlayer player: GKPlayer) {
        if let messageType = MessageType(data: data) {
            switch messageType {
            case .gameStart:
                if let message = GameStartMessage(data: data)
                {
                    let source = GKARC4RandomSource(seed: message.seed)
                    generator = GKShuffledDistribution(randomSource: source, lowestValue: 1, highestValue: 5)
                    readyToStart()
                }
            case .nextNumber:
                label.text = "\(generator.nextInt())"
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        label.text = "\(generator.nextInt())"
        sharedInstance.sendMessage(MessageType.nextNumber.data, mode: .reliable)
    }
    
    func hostFound() {
        for player in (sharedInstance.match?.players)! {
            scores?[player] = 0
        }
        if isHost {
            let source = GKARC4RandomSource()
            generator = GKShuffledDistribution(randomSource: source, lowestValue: 1, highestValue: 5)
            sharedInstance.sendMessage(GameStartMessage(seed: source.seed).data, mode: .reliable)
            readyToStart()
        }
    }
    
    func readyToStart() {
        print("Game ready to start")
        label.text = "\(generator.nextInt())"
    }
}

// MessageType
enum MessageType {
    case gameStart, nextNumber
}

extension MessageType: DataConvertible {
    init?(data: Data) {
        self = data.subdata(in: 0..<MemoryLayout<MessageType>.size).withUnsafeBytes {
            $0.pointee
        }
    }
}

// Messages
struct GameStartMessage {
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

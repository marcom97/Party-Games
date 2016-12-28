//
//  GameScene.swift
//  Party Games
//
//  Created by Marco Matamoros on 2016-10-17.
//  Copyright © 2016 Blue Stars. All rights reserved.
//

import SpriteKit
import GameplayKit

class MenuScene: SKScene, GKMatchFinderDelegate {
    private let sharedInstance = GKManager.sharedInstance
    private var playText: SKLabelNode?
    private var startingTouch : UITouch?
    
    override func didMove(to view: SKView) {
        playText = SKLabelNode(text: "Play")
        playText?.fontSize = 100
        playText?.position = CGPoint(x: size.width/2, y: size.height/2)
        self.addChild(playText!)
    }
    
    func touchDown(atPoint pos : CGPoint, withTouch touch: UITouch) {
        if playText!.contains(pos) {
            startingTouch = touch
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {

    }
    
    func touchUp(atPoint pos : CGPoint, withTouch touch: UITouch) {
        if playText!.contains(pos), touch == startingTouch {
            GKManager.sharedInstance.findMatch(minPlayers: 2, maxPlayers: 4)
            sharedInstance.matchFinderDelegate = self
        }
    }
    
    func matchFound() {
        let scene = GameManagerScene(size: self.size)
        scene.scaleMode = .aspectFill
        
        self.view?.presentScene(scene)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self), withTouch: t) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self), withTouch: t) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

//
//  GKManager.swift
//  Party Games
//
//  Created by Marco Matamoros on 2016-10-22.
//  Copyright © 2016 Blue Stars. All rights reserved.
//

import UIKit
import GameKit

final class GKManager: NSObject, GKMatchDelegate, GKMatchmakerViewControllerDelegate {
    static let sharedInstance = GKManager()
    
    var delegate: GKManagerDelegate?
    var matchFinderDelegate: GKMatchFinderDelegate?
    var match: GKMatch?
    var host: GKPlayer?
    var presentingViewController: UIViewController?
    var authenticationViewController: UIViewController?
    var localPlayer: GKLocalPlayer?
    
    private override init() {
        
    }
    
// User Authentication
    func authenticateLocalPlayer() {
        localPlayer = GKLocalPlayer.localPlayer()
                
        localPlayer!.authenticateHandler = {
            if let viewController = $0 {
                self.authenticationViewController = viewController
                
                UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true, completion: nil)
            }
            
            if let error = $1 as? NSError{
                NSLog("Authentication error: ", error.localizedDescription)
            }
        }
    }
    
// Matchmaking Functions
    func findMatch(minPlayers min: Int, maxPlayers max: Int) {
        guard localPlayer!.isAuthenticated else {
            if let viewController = authenticationViewController {
                UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true, completion: nil)
            }
            
            return
        }
        
        let request = GKMatchRequest()
        
        request.minPlayers = min
        request.maxPlayers = max
        request.defaultNumberOfPlayers = min
        
        let matchMakerViewController = GKMatchmakerViewController(matchRequest: request)
        matchMakerViewController!.matchmakerDelegate = self
        
        presentingViewController = UIApplication.shared.keyWindow?.rootViewController
        
        self.presentingViewController?.present(matchMakerViewController!, animated: true, completion: nil)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
        if let mfDelegate = self.matchFinderDelegate {
            mfDelegate.matchFound()
        }
        
        match.delegate = self
        self.match = match
        
        if match.expectedPlayerCount == 0 {
            match.chooseBestHostingPlayer() {
                self.host = $0
                self.delegate?.hostFound()
            }
            
        }
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
        NSLog("MatchMaking Error: ", (error as NSError).description)
    }
    
// MatchDelegate Functions
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        guard self.match == match else {
            return
        }
        if match.expectedPlayerCount == 0 {
            switch state {
            case .stateConnected:
                match.chooseBestHostingPlayer() {
                    self.host = $0
                    self.delegate?.hostFound()
                }
                
            case .stateDisconnected:
                if player.playerID == host?.playerID {
                    match.chooseBestHostingPlayer() {
                        self.host = $0
                        self.delegate?.hostFound()
                    }
                }
            default:
                break
            }
            
            delegate?.player(player, stateChanged: state)
        }
    }
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        guard self.match == match else {
            return
        }
        
        delegate?.receivedData(data, fromPlayer: player)
    }
    
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        guard self.match == match else {
            return
        }
        if let error = error as? NSError{
            NSLog("Match failed with error: ", error.description)
        }
    }
    
    func sendMessage(_ message: Data, mode: GKMatchSendDataMode) {
        do {
            try match?.sendData(toAllPlayers: message, with: mode)
        }
        catch {
            print("Could not send data with error: ", error.localizedDescription)
        }
    }
    
// Data Encoding Functions
    private func encode<T>(_ value: T) -> Data {
        var value = value
        
        
        
        return withUnsafePointer(to: &value) {
            Data(buffer: UnsafeBufferPointer<T>(start: $0, count: 1))
        }
    }
    
    private func decode<T>(_ data: Data) -> T {
        let message: T = data.withUnsafeBytes {
            $0.pointee
        }
        
        return message
    }
}

// Protocols
protocol GKManagerDelegate {
    func player(_ player: GKPlayer, stateChanged state: GKPlayerConnectionState)
    func receivedData(_ data: Data, fromPlayer player: GKPlayer)
    func hostFound()
}

protocol GKMatchFinderDelegate {
    func matchFound()
}

protocol DataConvertible {
    init?(data: Data)
    var data: Data { get }
}

// Extensions
extension DataConvertible {
    
    init?(data: Data) {
        guard data.count == MemoryLayout<Self>.size else { return nil }
        self = data.withUnsafeBytes { $0.pointee }
    }
    
    var data: Data {
        var value = self
        return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
}

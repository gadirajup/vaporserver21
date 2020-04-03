//
//  MessageHandler.swift
//  App
//
//  Created by Prudhvi Gadiraju on 4/2/20.
//

import Foundation
import shared
import Vapor

struct MessageHandler {
    
    enum MessageError: Error {
        case UnknownMessage
    }
    
    static func process(_ message: Message, with socket: WebSocket) throws {
                switch message.type {
        case .join:
            guard let player = message.player else {
                return print("missing player in join message")
            }
            
            //try Game.shared.handleJoin(player: player, socket: socket)
        case .hit:
            guard let player = message.player else {
                return print("missing player in hit message")
            }
            
            //try Game.shared.handleHit(player: player)
        case .stand:
                    print("Stand")
            //try Game.shared.handleTurn()
        default:
            throw MessageError.UnknownMessage
        }
    }
}

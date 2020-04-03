//
//  MessageController.swift
//  App
//
//  Created by Prudhvi Gadiraju on 4/2/20.
//

import Foundation
//import shared
import Vapor

struct MessageController{
    
    enum MessageError: Error {
        case UnknownMessage
    }
    
    static func process(_ message: Message, with socket: WebSocket) throws {
        switch message.type {
        case .join  : try GamesController.standard.handleJoin(with: message, and: socket)
        case .hit   : try GamesController.standard.handleHit(with: message)
        case .stand : try GamesController.standard.handleStand(with: message)
        default     : throw MessageError.UnknownMessage
        }
    }
    
    static func processClose(_ socket: WebSocket) throws {
        try GamesController.standard.handleClose(socket)
    }
}

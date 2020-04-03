//
//  Message.swift
//  shared
//
//  Created by Prudhvi Gadiraju on 4/1/20.
//

import Foundation

public enum MessageType: String, Codable {
    case join = "join"
    case turn = "turn"
    case finish = "finish"
    case stop = "stop"
    case hit = "hit"
    case stand = "stand"
    case deal = "deal"
}

public class Message: Codable {
    public let type: MessageType
    public let player: Player?
    public let cardInfo: [Player: [Int]]?
    public let card: Int?
    public let gameId: UUID?

    private init(type: MessageType, gameId: UUID? = nil, player: Player? = nil) {
        self.type = type
        self.player = player
        self.gameId = gameId
        self.cardInfo = nil
        self.card = nil
    }
    
    private init(type: MessageType, cardInfo: [Player: [Int]]?, gameId: UUID? = nil, card: Int? = nil, player: Player? = nil) {
        self.type = type
        self.cardInfo = cardInfo
        self.player = player
        self.card = card
        self.gameId = gameId
    }

    public static func join(player: Player) -> Message {
        return Message(type: .join, player: player)
    }

    public static func stop() -> Message {
        return Message(type: .stop)
    }

    public static func turn(player: Player) -> Message {
        return Message(type: .turn, player: player)
    }
    
    public static func turn(cardInfo: [Player: [Int]], player: Player, gameId: UUID) -> Message {
        return Message(type: .turn, cardInfo: cardInfo, gameId: gameId, player: player)
    }

    public static func finish(winningPlayer: Player?) -> Message {
        return Message(type: .finish, player: winningPlayer)
    }
    
    public static func hit(player: Player, gameId: UUID) -> Message {
        return Message(type: .hit, gameId: gameId, player: player)
    }
    
    public static func stand(player: Player, gameId: UUID) -> Message {
        return Message(type: .stand, gameId: gameId, player: player)
    }
    
    public static func deal(player: Player, cardInfo: [Player: [Int]], card: Int) -> Message {
        return Message(type: .deal, cardInfo: cardInfo, card: card, player: player)
    }
}

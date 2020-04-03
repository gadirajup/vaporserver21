//
//  GameController.swift
//  App
//
//  Created by Prudhvi Gadiraju on 4/2/20.
//

import Foundation
//import shared
import Vapor

class GameController {
    
    enum GameError: Error {
        case failedToSerializeMessageToJsonString(message: Message)
        case failedToFindPlayer
    }
    
    // MARK: - Properties
    
    var id: UUID!
    private var maxPlayers = 2
    private var activePlayer: Player?
    private var playerSocketInfo: [Player: WebSocket] = [:]
    private var playerCardInfo: [Player: [Int]] = [:]
    
    var didFinish: (() -> ())?
    
    var isFull: Bool { return players.count == maxPlayers }
    private var players: [Player] { return Array(self.playerSocketInfo.keys) }
    
    // MARK: - Lifecycle
    
    init() { self.id = UUID() }
    
    // MARK: - Handlers
    
    func handleJoin(with message: Message, and socket: WebSocket) throws {
        guard let player = message.player else { print("Error: No Player"); return }
        self.playerSocketInfo[player] = socket
        print("Player Joined")
        if self.playerSocketInfo.count == maxPlayers {
            try startGame()
        }
    }
    
    func handleTurn() throws {
        print("Turn")
        self.activePlayer = nextActivePlayer()!
        
        if !self.activePlayer!.hasPlayed {
            self.activePlayer!.hasPlayed = true
            let message = Message.turn(cardInfo: playerCardInfo, player: self.activePlayer!, gameId: id)
            try notifyPlayers(message: message)
        } else {
            print("Game Over: \(id!)")
            let totals = playerCardInfo.map { key, value in value.reduce(0, +) }
            let max = totals.max()
            let winnerIndex = totals.firstIndex(of: max!)!
            let players = Array(playerCardInfo.keys)
            let winner = players[winnerIndex]
            let message = Message.finish(winningPlayer: winner)
            try notifyPlayers(message: message)
            didFinish?()
        }
    }
    
    func handleHit(player: Player) throws {
        print("Hit")
        guard var cards = playerCardInfo[player] else {
            throw GameError.failedToFindPlayer
        }
        
        // Give card
        let card = Int.random(in: 1...13)
        cards.append(card)
        print("New Card: \(card)")
        
        playerCardInfo[player] = cards

        let message = Message.deal(player: self.activePlayer!, cardInfo: self.playerCardInfo, card: card)
        try notifyPlayers(message: message)
        
        // check if 21
        let total = cards.reduce(0, +)
        if total == 21 {
            print("Game Over: \(id!)")
            let message = Message.finish(winningPlayer: self.activePlayer!)
            try notifyPlayers(message: message)
            didFinish?()
        } else if total > 21 {
            print("Game Over: \(id!)")
            let message = Message.finish(winningPlayer: nextActivePlayer()!)
            try notifyPlayers(message: message)
            didFinish?()
        }
    }
    
    // MARK: - Helpers
    
    private func startGame() throws {
        print("Starting Game")
        players.forEach { player in
            let card1 = Int.random(in: 1...13)
            let card2 = Int.random(in: 1...13)
            playerCardInfo[player] = [card1, card2]
        }
        
        self.activePlayer = players.randomElement()
        self.activePlayer!.hasPlayed = true
        let message = Message.turn(cardInfo: self.playerCardInfo, player: self.activePlayer!, gameId: id)
        try notifyPlayers(message: message)
    }
    
    private func notifyPlayers(message: Message) throws {
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(message)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw GameError.failedToSerializeMessageToJsonString(message: message)
        }
        
        self.playerSocketInfo.values.forEach({
            $0.send(jsonString)
        })
    }
    
    private func nextActivePlayer() -> Player? {
        return self.players.filter({ $0 != self.activePlayer }).first
    }
}

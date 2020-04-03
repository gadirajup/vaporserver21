//
//  GamesController.swift
//  App
//
//  Created by Prudhvi Gadiraju on 4/2/20.
//

import Foundation
import Vapor
//import shared

class GamesController {
    
    enum GamesError: Error {
        case gameIdError
        case playerError
    }
    
    static let standard = GamesController()
    private init() {}
    
    private let maxGames = 1
    private var games: [GameController] = []
    
    private var noCurrentGames: Bool { games.isEmpty }
    private var gamesFull: Bool { false }
    
    func handleJoin(with message: Message, and socket: WebSocket) throws {
        if noCurrentGames || gamesFull { createGame() }
        let game = games.last
        try game?.handleJoin(with: message, and: socket)
    }
    
    func handleClose(_ socket: WebSocket) throws {
        
    }
    
    func handleHit(with message: Message) throws {
        guard let id = message.gameId else { throw GamesError.gameIdError }
        guard let player = message.player else { throw GamesError.playerError }
        
        if let game = games.first(where: { game -> Bool in
            game.id == id
        }) {
            try game.handleHit(player: player)
        }
    }
    
    func handleStand(with message: Message) throws {
        guard let id = message.gameId else { throw GamesError.gameIdError }
        
        if let game = games.first(where: { game -> Bool in
            game.id == id
        }) {
            try game.handleTurn()
        }
    }
    
    // MARK: - Helpers
    
    func createGame() {
        print("Creating new Game")
        let game = GameController()
        game.didFinish = { [weak self] in
            guard let self = self else { return }
            self.games.removeAll { (gameController) -> Bool in
                gameController.id == game.id
            }
        }
        games.append(game)
    }
    
    func game(_ id: UUID) -> GameController? {
        if let game = games.firstIndex(where: { (controller) -> Bool in
            controller.id == id
        }) {
            return games[game]
        }
        return nil
    }
}

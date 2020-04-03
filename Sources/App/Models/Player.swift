//
//  Player.swift
//  shared
//
//  Created by Prudhvi Gadiraju on 4/1/20.
//

import Foundation

public enum PlayerError: Error {
    case creationFailed
}

public class Player: Hashable, Codable {
    public let id: String
    public var hasPlayed: Bool = false
    
    public init() {
        self.id = NSUUID().uuidString
    }
    
    public init(json: [String: Any]) throws {
        guard let id = json["id"] as? String else {
            throw PlayerError.creationFailed
        }
        
        self.id = id
    }
    
    // MARK: - Hashable
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Player, rhs: Player) -> Bool {
        return lhs.id == rhs.id
    }
}

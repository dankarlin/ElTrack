//
//  ElevatorEntry.swift
//  ElTrack
//
//  Created by Daniel Karlin on 10/23/25.
//

import Foundation

struct ElevatorEntry: Identifiable, Codable {
    let id = UUID()
    let startingFloor: String
    let endingFloor: String
    let elevator: ElevatorType
    let timestamp: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }
}

enum ElevatorType: String, CaseIterable, Codable {
    case h1 = "H1"
    case h2 = "H2"
    case h3 = "H3"
    case se1 = "SE1"
}

enum FloorOption: String, CaseIterable, Codable {
    case floor75 = "75"
    case floor48 = "48"
    case floor16 = "16"
    case floor14 = "14"
    case floor8 = "8"
    case floor7 = "7"
    case lobby = "L"
    case other = "Other"
    
    var displayName: String {
        switch self {
        case .lobby:
            return "Lobby (L)"
        case .other:
            return "Other"
        default:
            return "Floor \(rawValue)"
        }
    }
}
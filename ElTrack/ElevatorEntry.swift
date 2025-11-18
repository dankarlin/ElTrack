//
//  ElevatorEntry.swift
//  ElTrack
//
//  Created by Daniel Karlin on 10/23/25.
//

import Foundation

struct ElevatorEntry: Identifiable, Codable {
    let id: UUID
    let startingFloor: String
    let endingFloor: String
    let elevator: ElevatorType
    let timestamp: Date
    
    init(startingFloor: String, endingFloor: String, elevator: ElevatorType, timestamp: Date) {
        self.id = UUID()
        self.startingFloor = startingFloor
        self.endingFloor = endingFloor
        self.elevator = elevator
        self.timestamp = timestamp
    }
    
    init(id: UUID, startingFloor: String, endingFloor: String, elevator: ElevatorType, timestamp: Date) {
        self.id = id
        self.startingFloor = startingFloor
        self.endingFloor = endingFloor
        self.elevator = elevator
        self.timestamp = timestamp
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: timestamp)
    }
    
    var formattedDateWithDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
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
    case l1 = "L1"
    case l2 = "L2"
    case l3 = "L3"
    case l4 = "L4"
    
    var isFrequentlyUsed: Bool {
        switch self {
        case .h1, .h2, .h3, .se1:
            return true
        case .l1, .l2, .l3, .l4:
            return false
        }
    }
    
    static var frequentElevators: [ElevatorType] {
        return [.h1, .h2, .h3, .se1]
    }
    
    static var lessFrequentElevators: [ElevatorType] {
        return [.l1, .l2, .l3, .l4]
    }
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
    
    var iconName: String {
        switch self {
        case .floor75:
            return "house.fill"
        case .floor48:
            return "cup.and.saucer.fill"
        case .floor16:
            return "figure.pool.swim"
        case .floor14:
            return "dumbbell.fill"
        case .floor8:
            return "archivebox.fill"
        case .floor7:
            return "car.fill"
        case .lobby:
            return "building.fill"
        case .other:
            return "ellipsis.circle.fill"
        }
    }
}
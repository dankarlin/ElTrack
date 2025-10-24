//
//  ElevatorDataManager.swift
//  ElTrack
//
//  Created by Daniel Karlin on 10/23/25.
//

import Foundation

@MainActor
class ElevatorDataManager: ObservableObject {
    @Published var entries: [ElevatorEntry] = []
    
    private let userDefaults = UserDefaults.standard
    private let entriesKey = "ElevatorEntries"
    
    init() {
        loadEntries()
    }
    
    func addEntry(startingFloor: String, endingFloor: String, elevator: ElevatorType) {
        let entry = ElevatorEntry(
            startingFloor: startingFloor,
            endingFloor: endingFloor,
            elevator: elevator,
            timestamp: Date()
        )
        entries.insert(entry, at: 0) // Add to beginning for newest first
        saveEntries()
    }
    
    func deleteEntry(_ entry: ElevatorEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            userDefaults.set(encoded, forKey: entriesKey)
        }
    }
    
    private func loadEntries() {
        if let data = userDefaults.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([ElevatorEntry].self, from: data) {
            entries = decoded
        }
    }
    
    func exportToCSV() -> String {
        var csvContent = "Date,Time,Starting Floor,Ending Floor,Elevator\n"
        
        for entry in entries.reversed() { // Export chronologically
            let date = entry.formattedDate
            let time = entry.formattedTime
            let startFloor = entry.startingFloor
            let endFloor = entry.endingFloor
            let elevator = entry.elevator.rawValue
            
            csvContent += "\"\(date)\",\"\(time)\",\"\(startFloor)\",\"\(endFloor)\",\"\(elevator)\"\n"
        }
        
        return csvContent
    }
    
    func clearAllEntries() {
        entries.removeAll()
        saveEntries()
    }
}
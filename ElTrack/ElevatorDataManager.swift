//
//  ElevatorDataManager.swift
//  ElTrack
//
//  Created by Daniel Karlin on 10/23/25.
//

import Foundation
import Combine
import CloudKit

@MainActor
class ElevatorDataManager: ObservableObject {
    @Published var entries: [ElevatorEntry] = []
    @Published var isLoading = false
    @Published var cloudKitStatus: String = "Unknown"
    
    private let container = CKContainer(identifier: "iCloud.ElTrackCloudKit")
    private let recordType = "ElevatorEntry"
    
    // Fallback to UserDefaults for offline storage
    private let userDefaults = UserDefaults.standard
    private let entriesKey = "ElevatorEntries"
    
    init() {
        loadFromUserDefaults()
        checkCloudKitStatus()
        
        // Delay CloudKit fetch to allow container setup
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
            await fetchFromCloudKit()
        }
    }
    
    func addEntry(startingFloor: String, endingFloor: String, elevator: ElevatorType) {
        let entry = ElevatorEntry(
            startingFloor: startingFloor,
            endingFloor: endingFloor,
            elevator: elevator,
            timestamp: Date()
        )
        entries.insert(entry, at: 0) // Add to beginning for newest first
        
        Task {
            await saveToCloudKit(entry)
            saveToUserDefaults() // Backup locally
        }
    }
    
    func deleteEntry(_ entry: ElevatorEntry) {
        entries.removeAll { $0.id == entry.id }
        
        Task {
            await deleteFromCloudKit(entry)
            saveToUserDefaults() // Update local backup
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
        
        // Ensure we always return something even if no entries
        if entries.isEmpty {
            csvContent += "No rides recorded yet\n"
        }
        
        return csvContent
    }
    
    func generateExportFilename() -> String {
        guard !entries.isEmpty else {
            return "ElTrack_Export.csv"
        }
        
        // Sort entries by timestamp to get the earliest and latest
        let sortedEntries = entries.sorted { $0.timestamp < $1.timestamp }
        let earliest = sortedEntries.first!
        let latest = sortedEntries.last!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM-d-yyyy"
        
        let earliestDate = formatter.string(from: earliest.timestamp)
        let latestDate = formatter.string(from: latest.timestamp)
        
        if earliestDate == latestDate {
            // Same date range
            return "ElTrack_\(earliestDate).csv"
        } else {
            // Date range
            return "ElTrack_\(earliestDate)_to_\(latestDate).csv"
        }
    }
    
    // MARK: - CloudKit Methods
    
    private func checkCloudKitStatus() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.cloudKitStatus = "Available"
                case .noAccount:
                    self?.cloudKitStatus = "No Account"
                case .restricted:
                    self?.cloudKitStatus = "Restricted"
                case .couldNotDetermine:
                    self?.cloudKitStatus = "Could Not Determine"
                case .temporarilyUnavailable:
                    self?.cloudKitStatus = "Temporarily Unavailable"
                @unknown default:
                    self?.cloudKitStatus = "Unknown"
                }
            }
        }
    }
    
    private func fetchFromCloudKit() async {
        await MainActor.run {
            self.isLoading = true
        }
        
        // For now, disable CloudKit fetching during export to avoid the query issue
        // The app will work with local data, and sync when CloudKit is properly set up
        print("CloudKit fetch temporarily disabled to avoid query issues. Using local data.")
        
        await MainActor.run {
            self.isLoading = false
        }
        
        // TODO: Implement proper CloudKit schema setup in CloudKit Console
        // Once the schema is properly configured, this can be re-enabled
    }
    
    private func saveToCloudKit(_ entry: ElevatorEntry) async {
        let database = container.privateCloudDatabase
        let record = convertEntryToRecord(entry)
        
        do {
            _ = try await database.save(record)
            print("Successfully saved to CloudKit")
        } catch let error as CKError {
            if error.code == .badContainer {
                print("CloudKit container not set up yet. Entry saved locally.")
            } else if error.code == .quotaExceeded {
                print("CloudKit storage quota exceeded")
            } else {
                print("Failed to save to CloudKit: \(error.localizedDescription)")
            }
        } catch {
            print("Failed to save to CloudKit: \(error)")
        }
    }
    
    private func deleteFromCloudKit(_ entry: ElevatorEntry) async {
        let database = container.privateCloudDatabase
        let recordID = CKRecord.ID(recordName: entry.id.uuidString)
        
        do {
            _ = try await database.deleteRecord(withID: recordID)
            print("Successfully deleted from CloudKit")
        } catch let error as CKError {
            if error.code == .unknownItem {
                print("Record not found in CloudKit (may have been already deleted)")
            } else {
                print("Failed to delete from CloudKit: \(error.localizedDescription)")
            }
        } catch {
            print("Failed to delete from CloudKit: \(error)")
        }
    }
    
    private func convertEntryToRecord(_ entry: ElevatorEntry) -> CKRecord {
        let recordID = CKRecord.ID(recordName: entry.id.uuidString)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        record["startingFloor"] = entry.startingFloor
        record["endingFloor"] = entry.endingFloor
        record["elevator"] = entry.elevator.rawValue
        record["timestamp"] = entry.timestamp
        
        return record
    }
    
    private func convertRecordToEntry(_ record: CKRecord) -> ElevatorEntry? {
        guard let startingFloor = record["startingFloor"] as? String,
              let endingFloor = record["endingFloor"] as? String,
              let elevatorString = record["elevator"] as? String,
              let elevator = ElevatorType(rawValue: elevatorString),
              let timestamp = record["timestamp"] as? Date,
              let id = UUID(uuidString: record.recordID.recordName) else {
            return nil
        }
        
        return ElevatorEntry(
            id: id,
            startingFloor: startingFloor,
            endingFloor: endingFloor,
            elevator: elevator,
            timestamp: timestamp
        )
    }
    
    // MARK: - UserDefaults Methods
    
    private func saveToUserDefaults() {
        do {
            let data = try JSONEncoder().encode(entries)
            userDefaults.set(data, forKey: entriesKey)
        } catch {
            print("Failed to save to UserDefaults: \(error)")
        }
    }
    
    private func loadFromUserDefaults() {
        guard let data = userDefaults.data(forKey: entriesKey) else { return }
        
        do {
            entries = try JSONDecoder().decode([ElevatorEntry].self, from: data)
        } catch {
            print("Failed to load from UserDefaults: \(error)")
        }
    }
    
    func syncWithCloudKit() {
        Task {
            await fetchFromCloudKit()
        }
    }
    
    // Method to help initialize CloudKit schema by saving a test record
    func initializeCloudKitSchema() {
        Task {
            // Create a temporary entry to help initialize the schema
            let testEntry = ElevatorEntry(
                startingFloor: "1",
                endingFloor: "2", 
                elevator: .h1,
                timestamp: Date()
            )
            
            let database = container.privateCloudDatabase
            let record = convertEntryToRecord(testEntry)
            
            do {
                _ = try await database.save(record)
                print("CloudKit schema initialized successfully")
                
                // Delete the test record
                try await database.deleteRecord(withID: record.recordID)
                print("Test record cleaned up")
                
            } catch {
                print("Schema initialization attempt: \(error)")
            }
        }
    }
}

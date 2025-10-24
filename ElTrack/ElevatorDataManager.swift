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
        
        do {
            let _ = try await fetchFromCloudKitWithErrorHandling()
        } catch let error as CKError {
            print("CloudKit fetch error: \(error.localizedDescription)")
            
            // Try a fallback approach for first-time schema setup
            if error.code == .unknownItem || error.code == .invalidArguments {
                print("Attempting to initialize CloudKit schema...")
                await initializeCloudKitSchemaIfNeeded()
            }
        } catch {
            print("Unexpected fetch error: \(error)")
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    private func initializeCloudKitSchemaIfNeeded() async {
        // Try to save a sample record to initialize the schema
        let testEntry = ElevatorEntry(
            startingFloor: "1",
            endingFloor: "2",
            elevator: .h1,
            timestamp: Date()
        )
        
        await saveToCloudKit(testEntry)
        
        // Then try to delete it
        await deleteFromCloudKit(testEntry)
        print("Schema initialization attempt completed")
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
    
    // Manual sync with completion handler to avoid publishing conflicts
    func performManualSync(completion: @escaping (String) -> Void) {
        print("=== Manual sync started ===")
        
        // Set loading state
        isLoading = true
        
        Task {
            let initialCount = entries.count
            print("Initial entry count: \(initialCount)")
            
            do {
                let syncResult = try await fetchFromCloudKitWithErrorHandling()
                print("Fetch completed successfully")
                
                let finalCount = entries.count
                print("Final entry count: \(finalCount)")
                print("Downloaded: \(syncResult.downloaded), Duplicates removed: \(syncResult.duplicatesRemoved)")
                
                let message: String
                if syncResult.downloaded > 0 && syncResult.duplicatesRemoved > 0 {
                    message = "Sync complete! Downloaded \(syncResult.downloaded) new record\(syncResult.downloaded == 1 ? "" : "s") and removed \(syncResult.duplicatesRemoved) duplicate\(syncResult.duplicatesRemoved == 1 ? "" : "s")."
                } else if syncResult.downloaded > 0 {
                    message = "Sync complete! Downloaded \(syncResult.downloaded) new record\(syncResult.downloaded == 1 ? "" : "s")."
                } else if syncResult.duplicatesRemoved > 0 {
                    message = "Sync complete! Removed \(syncResult.duplicatesRemoved) duplicate record\(syncResult.duplicatesRemoved == 1 ? "" : "s")."
                } else {
                    let totalRecords = entries.count
                    message = "Sync complete! Everything is up to date (\(totalRecords) record\(totalRecords == 1 ? "" : "s") total)."
                }
                
                print("Sync completed: \(message)")
                await MainActor.run {
                    self.isLoading = false
                    completion(message)
                }
                
            } catch {
                print("Sync error: \(error)")
                let errorMessage = "Sync failed: \(error.localizedDescription)"
                await MainActor.run {
                    self.isLoading = false
                    completion(errorMessage)
                }
            }
        }
    }
    
    // Separate method that can throw errors for better error handling
    private func fetchFromCloudKitWithErrorHandling() async throws -> (downloaded: Int, duplicatesRemoved: Int) {
        let database = container.privateCloudDatabase
        
        // Use a simple query without sort descriptors to avoid queryable field issues
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        
        let (matchResults, _) = try await database.records(matching: query)
        
        let records = matchResults.compactMap { (recordID, result) -> CKRecord? in
            switch result {
            case .success(let record):
                return record
            case .failure(let error):
                print("Failed to fetch record \(recordID): \(error)")
                return nil
            }
        }
        
        let cloudEntries = records.compactMap { record in
            self.convertRecordToEntry(record)
        }
        
        return await MainActor.run {
            let initialCount = self.entries.count
            
            // Create sets for comparison
            let localIds = Set(self.entries.map { $0.id })
            let cloudIds = Set(cloudEntries.map { $0.id })
            
            // Find new entries from cloud that we don't have locally
            let newCloudEntries = cloudEntries.filter { !localIds.contains($0.id) }
            
            // Find entries we have locally that aren't in cloud (shouldn't happen normally)
            let localOnlyEntries = self.entries.filter { !cloudIds.contains($0.id) }
            
            // Add new entries from cloud
            self.entries.append(contentsOf: newCloudEntries)
            
            // Remove any entries that were deleted from cloud (if any)
            let duplicatesRemoved = self.entries.count - (initialCount + newCloudEntries.count)
            
            // Sort by timestamp (most recent first)
            self.entries.sort { $0.timestamp > $1.timestamp }
            self.saveToUserDefaults()
            
            let downloaded = newCloudEntries.count
            
            if downloaded > 0 {
                print("Successfully synced \(downloaded) new entries from CloudKit")
            }
            if localOnlyEntries.count > 0 {
                print("Found \(localOnlyEntries.count) local-only entries")
            }
            
            return (downloaded: downloaded, duplicatesRemoved: duplicatesRemoved)
        }
    }
    
    // Method to help initialize CloudKit schema by saving a test record
    func initializeCloudKitSchema() {
        Task {
            await initializeCloudKitSchemaIfNeeded()
        }
    }
    
    // Debug method to check CloudKit status
    func debugCloudKitStatus() {
        print("=== CloudKit Debug Info ===")
        print("Container ID: \(container.containerIdentifier ?? "nil")")
        print("Record Type: \(recordType)")
        print("Local entries count: \(entries.count)")
        
        Task {
            let database = container.privateCloudDatabase
            do {
                // Try a simple record count query
                let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
                let (results, _) = try await database.records(matching: query)
                print("CloudKit records found: \(results.count)")
            } catch {
                print("CloudKit debug query failed: \(error)")
            }
        }
    }
}

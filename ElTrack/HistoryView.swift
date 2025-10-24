//
//  HistoryView.swift
//  ElTrack
//
//  Created by Daniel Karlin on 10/23/25.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var dataManager: ElevatorDataManager
    @State private var showingExportSheet = false
    @State private var showingClearAlert = false
    @State private var csvContent = ""
    
    var body: some View {
        NavigationView {
            List {
                if dataManager.entries.isEmpty {
                    ContentUnavailableView(
                        "No Rides Recorded",
                        systemImage: "elevator",
                        description: Text("Start tracking your elevator rides to see them here.")
                    )
                } else {
                    ForEach(dataManager.entries) { entry in
                        ElevatorEntryRow(entry: entry)
                    }
                    .onDelete(perform: deleteEntries)
                }
            }
            .navigationTitle("Ride History")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !dataManager.entries.isEmpty {
                        Button("Clear All") {
                            showingClearAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !dataManager.entries.isEmpty {
                        Button("Export") {
                            csvContent = dataManager.exportToCSV()
                            showingExportSheet = true
                        }
                    }
                }
            }
            .alert("Clear All Entries", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    dataManager.clearAllEntries()
                }
            } message: {
                Text("This will permanently delete all elevator ride entries. This action cannot be undone.")
            }
            .sheet(isPresented: $showingExportSheet) {
                ActivityViewController(activityItems: [csvContent])
            }
        }
    }
    
    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            dataManager.deleteEntry(dataManager.entries[index])
        }
    }
}

struct ElevatorEntryRow: View {
    let entry: ElevatorEntry
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text(entry.startingFloor)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                        .font(.caption2)
                    
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text(entry.endingFloor)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text(entry.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(entry.formattedTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack {
                Image(systemName: "elevator")
                    .font(.caption)
                    .foregroundColor(.green)
                Text(entry.elevator.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.green.opacity(0.1))
            )
        }
        .padding(.vertical, 2)
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    HistoryView(dataManager: ElevatorDataManager())
}
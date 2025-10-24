//
//  HistoryView.swift
//  ElTrack
//
//  Created by Daniel Karlin on 10/23/25.
//

import SwiftUI
import Combine

class ExportManager: ObservableObject {
    @Published var isShowingSheet = false
    @Published var fileURL: URL?
    @Published var errorMessage = ""
    @Published var showingError = false
    
    func exportData(from dataManager: ElevatorDataManager) {
        // Reset state
        fileURL = nil
        
        let csvContent = dataManager.exportToCSV()
        let filename = dataManager.generateExportFilename()
        
        // Create temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let createdFileURL = tempDir.appendingPathComponent(filename)
        
        do {
            try csvContent.write(to: createdFileURL, atomically: true, encoding: .utf8)
            
            if FileManager.default.fileExists(atPath: createdFileURL.path) {
                // Update state directly (we're already on main thread from button tap)
                self.fileURL = createdFileURL
                self.isShowingSheet = true
            } else {
                self.errorMessage = "File verification failed"
                self.showingError = true
            }
        } catch {
            self.errorMessage = "Failed to create file: \(error.localizedDescription)"
            self.showingError = true
        }
    }
}

struct HistoryView: View {
    @ObservedObject var dataManager: ElevatorDataManager
    @StateObject private var exportManager = ExportManager()
    
    var body: some View {
        NavigationView {
            List {
                if dataManager.entries.isEmpty {
                    ContentUnavailableView(
                        "No Rides Recorded",
                        systemImage: "arrow.up.arrow.down.square",
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
                        Button("Delete Last") {
                            if let lastEntry = dataManager.entries.first {
                                dataManager.deleteEntry(lastEntry)
                            }
                        }
                        .foregroundColor(.red)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !dataManager.entries.isEmpty {
                        Button("Export") {
                            exportManager.exportData(from: dataManager)
                        }
                    }
                }
            }
            .sheet(isPresented: $exportManager.isShowingSheet) {
                if let fileURL = exportManager.fileURL {
                    ShareSheet(fileURL: fileURL)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        
                        Text("Export Failed")
                            .font(.headline)
                        
                        Text("Unable to create export file")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Dismiss") {
                            exportManager.isShowingSheet = false
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .alert("Export Error", isPresented: $exportManager.showingError) {
                Button("OK") { }
            } message: {
                Text(exportManager.errorMessage)
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
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text(entry.startingFloor)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Image(systemName: "arrow.right")
                        .foregroundColor(.secondary)
                        .font(.caption2)
                    
                    Image(systemName: "stop.circle.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                    Text(entry.endingFloor)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
                
                HStack {
                    Text(entry.formattedDateWithDay)
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
                Image(systemName: "arrow.up.arrow.down.square")
                    .font(.caption)
                    .foregroundColor(entry.elevator.isFrequentlyUsed ? .blue : .orange)
                Text(entry.elevator.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(entry.elevator.isFrequentlyUsed ? .blue : .orange)
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
        controller.setValue("ElTrack Elevator Data Export", forKey: "subject")
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let fileURL: URL
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: [fileURL], 
            applicationActivities: nil
        )
        
        // Minimal configuration to reduce console noise
        if let popover = controller.popoverPresentationController {
            popover.sourceView = context.coordinator.sourceView
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        let sourceView = UIView()
    }
}

struct ExportSheet: View {
    let fileURL: URL?
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            Group {
                if let fileURL = fileURL {
                    ActivityViewController(activityItems: [fileURL])
                        .ignoresSafeArea(.all)
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        
                        Text("Export Failed")
                            .font(.headline)
                        
                        Text("Unable to create export file")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Dismiss") {
                            onDismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    HistoryView(dataManager: ElevatorDataManager())
}
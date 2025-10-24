//
//  ContentView.swift
//  ElTrack
//
//  Created by Daniel Karlin on 10/23/25.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var dataManager = ElevatorDataManager()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ElevatorTrackingView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Track Ride")
                }
                .tag(0)
            
            HistoryView(dataManager: dataManager)
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("History")
                }
                .tag(1)
        }
        .tint(.blue)
    }
}

struct ElevatorTrackingView: View {
    @ObservedObject var dataManager: ElevatorDataManager
    @State private var startingFloor = ""
    @State private var endingFloor = ""
    @State private var selectedElevator: ElevatorType?
    @State private var showingSuccessAlert = false
    @State private var lastRecordedRide: (from: String, to: String, elevator: String) = ("", "", "")
    
    private var canSubmit: Bool {
        !startingFloor.isEmpty && !endingFloor.isEmpty && selectedElevator != nil && startingFloor != endingFloor
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Header - Just the icon
                    Image(systemName: "building.2")
                        .font(.system(size: 36))
                        .foregroundColor(.blue)
                        .padding(.top, 4)
                    
                    VStack(spacing: 16) {
                        // Starting Floor Selection
                        FloorSelectionView(
                            title: "Starting Floor",
                            selectedFloor: $startingFloor
                        )
                        
                        // Ending Floor Selection
                        FloorSelectionView(
                            title: "Ending Floor",
                            selectedFloor: $endingFloor
                        )
                        
                        // Elevator Selection
                        ElevatorSelectionView(selectedElevator: $selectedElevator)
                        
                        // Submit Button
                        Button(action: submitRide) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Record Ride")
                                    .fontWeight(.semibold)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(canSubmit ? Color.blue : Color.gray)
                            )
                        }
                        .disabled(!canSubmit)
                        .buttonStyle(PlainButtonStyle())
                        
                        // Warning if same floor selected
                        if !startingFloor.isEmpty && !endingFloor.isEmpty && startingFloor == endingFloor {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Starting and ending floors cannot be the same")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer(minLength: 12)
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Ride Recorded!", isPresented: $showingSuccessAlert) {
            Button("OK") { }
        } message: {
            Text("Your elevator ride from \(lastRecordedRide.from) to \(lastRecordedRide.to) in elevator \(lastRecordedRide.elevator) has been recorded.")
        }
    }
    
    private func submitRide() {
        guard let elevator = selectedElevator else { return }
        
        // Store the values for the alert before clearing them
        lastRecordedRide = (from: startingFloor, to: endingFloor, elevator: elevator.rawValue)
        
        dataManager.addEntry(
            startingFloor: startingFloor,
            endingFloor: endingFloor,
            elevator: elevator
        )
        
        // Reset form
        startingFloor = ""
        endingFloor = ""
        selectedElevator = nil
        
        showingSuccessAlert = true
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
}

#Preview {
    ContentView()
}

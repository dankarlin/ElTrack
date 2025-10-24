//
//  ElevatorSelectionView.swift
//  ElTrack
//
//  Created by Daniel Karlin on 10/23/25.
//

import SwiftUI

struct ElevatorSelectionView: View {
    @Binding var selectedElevator: ElevatorType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Elevator")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                ForEach(ElevatorType.allCases, id: \.self) { elevator in
                    ElevatorButton(
                        elevator: elevator,
                        selectedElevator: $selectedElevator
                    )
                }
            }
        }
    }
}

struct ElevatorButton: View {
    let elevator: ElevatorType
    @Binding var selectedElevator: ElevatorType?
    
    var isSelected: Bool {
        selectedElevator == elevator
    }
    
    var body: some View {
        Button(action: {
            selectedElevator = elevator
        }) {
            VStack {
                Image(systemName: "elevator")
                    .font(.title)
                    .foregroundColor(isSelected ? .white : .green)
                
                Text(elevator.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : .green)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.green : Color.green.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.green, lineWidth: isSelected ? 0 : 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ElevatorSelectionView(selectedElevator: .constant(nil))
}
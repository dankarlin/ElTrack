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
            
            VStack(spacing: 8) {
                // Frequently used elevators - larger row
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
                    ForEach(ElevatorType.frequentElevators, id: \.self) { elevator in
                        ElevatorButton(
                            elevator: elevator,
                            selectedElevator: $selectedElevator,
                            isFrequentlyUsed: true
                        )
                    }
                }
                
                // Less frequently used elevators - smaller row
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 6) {
                    ForEach(ElevatorType.lessFrequentElevators, id: \.self) { elevator in
                        ElevatorButton(
                            elevator: elevator,
                            selectedElevator: $selectedElevator,
                            isFrequentlyUsed: false
                        )
                    }
                }
            }
        }
    }
}

struct ElevatorButton: View {
    let elevator: ElevatorType
    @Binding var selectedElevator: ElevatorType?
    let isFrequentlyUsed: Bool
    
    var isSelected: Bool {
        selectedElevator == elevator
    }
    
    var buttonColor: Color {
        if isFrequentlyUsed {
            return .blue
        } else {
            return .orange
        }
    }
    
    var buttonHeight: CGFloat {
        isFrequentlyUsed ? 60 : 50
    }
    
    var iconSize: Font {
        isFrequentlyUsed ? .title2 : .title3
    }
    
    var textSize: Font {
        isFrequentlyUsed ? .subheadline : .caption
    }
    
    var body: some View {
        Button(action: {
            selectedElevator = elevator
        }) {
            VStack {
                Image(systemName: "arrow.up.arrow.down.square")
                    .font(iconSize)
                    .foregroundColor(isSelected ? .white : buttonColor)
                
                Text(elevator.rawValue)
                    .font(textSize)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? .white : buttonColor)
            }
            .frame(height: buttonHeight)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? buttonColor : buttonColor.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(buttonColor, lineWidth: isSelected ? 0 : 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ElevatorSelectionView(selectedElevator: .constant(nil))
}
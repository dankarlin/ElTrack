//
//  FloorSelectionView.swift
//  ElTrack
//
//  Created by Daniel Karlin on 10/23/25.
//

import SwiftUI

struct FloorSelectionView: View {
    let title: String
    @Binding var selectedFloor: String
    @State private var showingOtherFloorInput = false
    @State private var otherFloorText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(FloorOption.allCases, id: \.self) { floor in
                    FloorButton(
                        floor: floor,
                        selectedFloor: $selectedFloor,
                        showingOtherFloorInput: $showingOtherFloorInput
                    )
                }
            }
        }
        .sheet(isPresented: $showingOtherFloorInput) {
            OtherFloorInputView(
                otherFloorText: $otherFloorText,
                selectedFloor: $selectedFloor,
                isPresented: $showingOtherFloorInput
            )
        }
    }
}

struct FloorButton: View {
    let floor: FloorOption
    @Binding var selectedFloor: String
    @Binding var showingOtherFloorInput: Bool
    
    var isSelected: Bool {
        if floor == .other {
            return !FloorOption.allCases.dropLast().map(\.rawValue).contains(selectedFloor) && !selectedFloor.isEmpty
        }
        return selectedFloor == floor.rawValue
    }
    
    var body: some View {
        Button(action: {
            if floor == .other {
                showingOtherFloorInput = true
            } else {
                selectedFloor = floor.rawValue
            }
        }) {
            VStack {
                Image(systemName: floor == .lobby ? "building" : "rectangle.grid.1x2")
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .blue)
                
                Text(floor == .other ? (selectedFloor.isEmpty || FloorOption.allCases.dropLast().map(\.rawValue).contains(selectedFloor) ? "Other" : selectedFloor) : floor.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .blue)
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct OtherFloorInputView: View {
    @Binding var otherFloorText: String
    @Binding var selectedFloor: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Enter Floor Number")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                TextField("Floor number", text: $otherFloorText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .font(.title3)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if !otherFloorText.isEmpty {
                            selectedFloor = otherFloorText
                        }
                        isPresented = false
                    }
                    .fontWeight(.semibold)
                    .disabled(otherFloorText.isEmpty)
                }
            }
        }
    }
}

#Preview {
    FloorSelectionView(title: "Starting Floor", selectedFloor: .constant(""))
}
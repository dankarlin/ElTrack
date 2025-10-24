//
//  AppIconPreview.swift
//  ElTrack
//
//  Created by Daniel Karlin on 10/23/25.
//

import SwiftUI

// This view shows what the app icon design could look like
// You can use this as a reference when creating the actual icon assets
struct AppIconPreview: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("ElTrack App Icon Design")
                .font(.title)
                .fontWeight(.bold)
            
            // Main icon design
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                // Building outline
                VStack(spacing: 2) {
                    // Top floors
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 60, height: 8)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 65, height: 8)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 60, height: 8)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 65, height: 8)
                    
                    // Elevator shaft in center
                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 70, height: 40)
                        
                        // Elevator car
                        VStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.yellow.opacity(0.9))
                                .frame(width: 20, height: 12)
                            
                            // Arrow indicating movement
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 2)
            
            Text("Design Elements:")
                .font(.headline)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .indigo], startPoint: .top, endPoint: .bottom))
                        .frame(width: 20, height: 20)
                    Text("Blue gradient background representing a modern building")
                }
                
                HStack {
                    Rectangle()
                        .fill(Color.white.opacity(0.8))
                        .frame(width: 20, height: 4)
                    Text("White lines representing building floors")
                }
                
                HStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.yellow)
                        .frame(width: 20, height: 8)
                    Text("Yellow elevator car with up/down arrows")
                }
            }
            .font(.caption)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Text("Create this design in your preferred image editor\nwith the following sizes for iOS:")
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("• 1024x1024 (App Store)")
                Text("• 180x180 (iPhone @3x)")
                Text("• 120x120 (iPhone @2x)")
                Text("• 167x167 (iPad Pro @2x)")
                Text("• 152x152 (iPad @2x)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    AppIconPreview()
}
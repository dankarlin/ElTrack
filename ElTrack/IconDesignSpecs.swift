//
//  IconDesignSpecs.swift
//  ElTrack - Design Specifications for App Icon
//
//  Created by Daniel Karlin on 10/23/25.
//

/*
 ELTRACK APP ICON DESIGN SPECIFICATIONS
 =====================================
 
 OVERALL DIMENSIONS: 1024x1024px (scale down for other sizes)
 CORNER RADIUS: 227px (22.3% of width - iOS standard)
 
 BACKGROUND:
 -----------
 - Linear gradient from top-left to bottom-right
 - Start color: #007AFF (iOS Blue)
 - End color: #5856D6 (iOS Purple)
 
 BUILDING STRUCTURE:
 ------------------
 - Container: 600x700px, centered horizontally, positioned at y=200
 - Background: Semi-transparent white (#FFFFFF, 10% opacity)
 - Corner radius: 20px
 
 FLOOR LINES (from top to bottom):
 ---------------------------------
 Each line: 500px wide, 12px tall, centered, rounded corners (6px radius)
 Spacing between lines: 16px
 Colors alternate between 90% and 80% white opacity
 
 Line 1: y=250, #FFFFFF 90% opacity (Floor 75)
 Line 2: y=278, #FFFFFF 80% opacity (Floor 48) - wider: 520px
 Line 3: y=306, #FFFFFF 90% opacity (Floor 16)
 Line 4: y=334, #FFFFFF 80% opacity (Floor 14) - wider: 520px
 Line 5: y=362, #FFFFFF 90% opacity (Floor 8)
 Line 6: y=390, #FFFFFF 80% opacity (Floor 7) - wider: 520px
 Line 7: y=418, #FFFFFF 90% opacity (Lobby)
 
 ELEVATOR SHAFT:
 ---------------
 - Position: Center of building, y=450
 - Size: 540x180px
 - Background: #FFFFFF 30% opacity
 - Corner radius: 15px
 
 ELEVATOR CAR:
 -------------
 - Position: Center of shaft
 - Size: 160x80px
 - Background: Linear gradient #FF9500 to #FF6B00 (Orange)
 - Corner radius: 10px
 - Drop shadow: 0px 4px 8px #000000 20% opacity
 
 ELEVATOR ARROWS:
 ----------------
 - Two arrows stacked vertically in center of elevator car
 - Up arrow: ↑ (Unicode: U+2191)
 - Down arrow: ↓ (Unicode: U+2193)
 - Color: #FFFFFF
 - Font: System Bold, 24px
 - Spacing: 4px between arrows
 
 SHADOW EFFECTS:
 ---------------
 - Main building shadow: 0px 8px 20px #000000 15% opacity
 - Elevator car shadow: 0px 4px 8px #000000 20% opacity
 
 EXPORT SIZES:
 =============
 1024x1024 (App Store Connect)
 180x180   (iPhone @3x)
 120x120   (iPhone @2x)
 167x167   (iPad Pro @2x)
 152x152   (iPad @2x)
 76x76     (iPad @1x)
 
 NAMING CONVENTION:
 ==================
 AppIcon-1024.png
 AppIcon-180.png
 AppIcon-120.png
 AppIcon-167.png
 AppIcon-152.png
 AppIcon-76.png
 
 COLOR VALUES FOR COPY/PASTE:
 ============================
 Background Gradient Start: #007AFF
 Background Gradient End:   #5856D6
 Elevator Car Gradient:     #FF9500 to #FF6B00
 White Elements:            #FFFFFF
 
 TOOLS RECOMMENDED:
 ==================
 - Sketch (Mac)
 - Figma (Web/Mac)
 - Adobe Illustrator
 - Canva Pro
 - Affinity Designer
 
 DESIGN TIPS:
 ============
 1. Start with 1024x1024 and scale down
 2. Use vector shapes for clean scaling
 3. Test legibility at 60x60 (home screen size)
 4. Ensure contrast meets accessibility standards
 5. Export with transparent background, iOS adds corner radius automatically
 
*/

import SwiftUI

// This is a SwiftUI representation matching the specs above
struct AppIconDesignReference: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0/255, green: 122/255, blue: 255/255),  // #007AFF
                    Color(red: 88/255, green: 86/255, blue: 214/255)   // #5856D6
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Building container
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .frame(width: 600, height: 700)
            
            VStack(spacing: 16) {
                // Floor lines
                FloorLine(width: 500, opacity: 0.9)  // Floor 75
                FloorLine(width: 520, opacity: 0.8)  // Floor 48
                FloorLine(width: 500, opacity: 0.9)  // Floor 16
                FloorLine(width: 520, opacity: 0.8)  // Floor 14
                FloorLine(width: 500, opacity: 0.9)  // Floor 8
                FloorLine(width: 520, opacity: 0.8)  // Floor 7
                FloorLine(width: 500, opacity: 0.9)  // Lobby
                
                Spacer().frame(height: 20)
                
                // Elevator shaft and car
                ZStack {
                    // Shaft
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 540, height: 180)
                    
                    // Elevator car
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(
                                colors: [
                                    Color(red: 255/255, green: 149/255, blue: 0/255),
                                    Color(red: 255/255, green: 107/255, blue: 0/255)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            .frame(width: 160, height: 80)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 4)
                        
                        // Arrows
                        VStack(spacing: 4) {
                            Text("↑")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("↓")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
        }
        .frame(width: 1024, height: 1024)
        .clipShape(RoundedRectangle(cornerRadius: 227))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 8)
    }
}

struct FloorLine: View {
    let width: CGFloat
    let opacity: Double
    
    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.white.opacity(opacity))
            .frame(width: width, height: 12)
    }
}

#Preview {
    AppIconDesignReference()
        .scaleEffect(0.2) // Scale down to fit preview
}
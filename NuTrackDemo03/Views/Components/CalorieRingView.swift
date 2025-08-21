//
//  CalorieRingView.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI

struct CalorieRingView: View {
    let nutritionData: NutritionData
    @State private var animationProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                .frame(width: 200, height: 200)
            
            // Three-segment nutrition ring based on intake progress
            ZStack {
                // Carbs segment (green) - 0° to 120° (starting at -90°)
                NutritionSegmentShape(
                    startAngle: .degrees(-90),
                    endAngle: .degrees(-90 + carbsProgressAngle * animationProgress)
                )
                .stroke(colorForNutrient(nutritionData.carbs.progress, baseColor: .carbsColor), 
                       style: StrokeStyle(lineWidth: 20, lineCap: .round))
                
                // Protein segment (blue) - 120° to 240° (starting at 30°)
                NutritionSegmentShape(
                    startAngle: .degrees(30),
                    endAngle: .degrees(30 + proteinProgressAngle * animationProgress)
                )
                .stroke(colorForNutrient(nutritionData.protein.progress, baseColor: .proteinColor), 
                       style: StrokeStyle(lineWidth: 20, lineCap: .round))
                
                // Fat segment (pink) - 240° to 360° (starting at 150°)
                NutritionSegmentShape(
                    startAngle: .degrees(150),
                    endAngle: .degrees(150 + fatProgressAngle * animationProgress)
                )
                .stroke(colorForNutrient(nutritionData.fat.progress, baseColor: .fatColor), 
                       style: StrokeStyle(lineWidth: 20, lineCap: .round))
            }
            .frame(width: 200, height: 200)
            
            // Center content displaying nutrition balance
            VStack(spacing: 6) {
                Text("\(Int(overallNutritionBalance * 100))%")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryBlue)
                    .scaleEffect(animationProgress)
                
                Text("營養平衡")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .opacity(animationProgress)
                
                Text("三大營養素進度")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .opacity(animationProgress)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5)) {
                animationProgress = 1.0
            }
        }
    }
    
    // Calculate angles for each nutrition segment based on intake progress
    // Each segment gets 120 degrees, filled based on progress (0-100% = 0-120 degrees)
    private var carbsProgressAngle: Double {
        min(nutritionData.carbs.progress, 1.0) * 120
    }
    
    private var proteinProgressAngle: Double {
        min(nutritionData.protein.progress, 1.0) * 120
    }
    
    private var fatProgressAngle: Double {
        min(nutritionData.fat.progress, 1.0) * 120
    }
    
    // Overall nutrition balance for center display
    private var overallNutritionBalance: Double {
        nutritionData.totalNutrientProgress
    }
    
    // Visual feedback colors based on progress state
    private func colorForNutrient(_ progress: Double, baseColor: Color) -> Color {
        if progress >= 1.5 {
            // Over 150% - warning state
            return Color.red.opacity(0.8)
        } else if progress >= 1.0 {
            // 100%+ - achievement state (brighter)
            return baseColor.opacity(1.0)
        } else {
            // Under 100% - normal state
            return baseColor.opacity(0.8)
        }
    }
}

/// 營養素圓環片段 Shape
struct NutritionSegmentShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2 - 10
        
        if startAngle != endAngle {
            path.addArc(
                center: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: false
            )
        }
        
        return path
    }
}

extension Angle {
    var radians: Double {
        return self.degrees * .pi / 180
    }
}

#Preview {
    CalorieRingView(nutritionData: .sample)
        .padding()
}

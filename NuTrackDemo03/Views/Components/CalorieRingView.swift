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
            
            // Multi-color nutrition segments based on actual calories
            ZStack {
                // Carbs segment (green) - based on calorie percentage
                NutritionSegmentShape(
                    startAngle: .degrees(-90),
                    endAngle: .degrees(-90 + carbsCalorieAngle * animationProgress)
                )
                .stroke(Color.carbsColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                
                // Protein segment (blue) - based on calorie percentage  
                NutritionSegmentShape(
                    startAngle: .degrees(-90 + carbsCalorieAngle * animationProgress),
                    endAngle: .degrees(-90 + (carbsCalorieAngle + proteinCalorieAngle) * animationProgress)
                )
                .stroke(Color.proteinColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                
                // Fat segment (pink) - based on calorie percentage
                NutritionSegmentShape(
                    startAngle: .degrees(-90 + (carbsCalorieAngle + proteinCalorieAngle) * animationProgress),
                    endAngle: .degrees(-90 + (carbsCalorieAngle + proteinCalorieAngle + fatCalorieAngle) * animationProgress)
                )
                .stroke(Color.fatColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
            }
            .frame(width: 200, height: 200)
            
            // Center content displaying remaining calories
            VStack(spacing: 6) {
                Text("\(nutritionData.remainingCalories)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryBlue)
                    .scaleEffect(animationProgress)
                
                Text("KCAL LEFT")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .opacity(animationProgress)
                
                Text("目標 \(nutritionData.caloriesGoal)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .opacity(animationProgress)
                
                // Nutrition status indicator
                Text(nutritionData.nutritionStatus.description)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(nutritionData.nutritionStatus.color)
                    .multilineTextAlignment(.center)
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
    
    // Calculate angles for each nutrition segment based on calorie distribution
    private var carbsCalorieAngle: Double {
        let percentages = nutritionData.macronutrientPercentages
        return percentages.carbs * 360  // Full circle distribution
    }
    
    private var proteinCalorieAngle: Double {
        let percentages = nutritionData.macronutrientPercentages
        return percentages.protein * 360  // Full circle distribution
    }
    
    private var fatCalorieAngle: Double {
        let percentages = nutritionData.macronutrientPercentages
        return percentages.fat * 360  // Full circle distribution
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

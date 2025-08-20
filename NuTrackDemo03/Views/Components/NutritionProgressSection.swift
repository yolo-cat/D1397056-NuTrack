//
//  NutritionProgressSection.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI

struct NutritionProgressSection: View {
    let nutritionData: NutritionData
    @State private var animationDelays: [Double] = [0, 0.2, 0.4]
    @State private var showProgress = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("營養素追蹤")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Show calorie distribution percentages
                Text("熱量分佈")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                // Carbohydrates progress bar with enhanced info
                NutritionProgressBar(
                    title: "碳水化合物",
                    nutrientData: nutritionData.carbs,
                    calorieInfo: nutritionData.macronutrientCaloriesDistribution.carbs,
                    percentage: nutritionData.macronutrientPercentages.carbs,
                    color: .carbsColor,
                    showProgress: showProgress
                )
                .opacity(showProgress ? 1 : 0)
                .animation(.easeInOut(duration: 0.8).delay(animationDelays[0]), value: showProgress)
                
                // Protein progress bar with enhanced info
                NutritionProgressBar(
                    title: "蛋白質",
                    nutrientData: nutritionData.protein,
                    calorieInfo: nutritionData.macronutrientCaloriesDistribution.protein,
                    percentage: nutritionData.macronutrientPercentages.protein,
                    color: .proteinColor,
                    showProgress: showProgress
                )
                .opacity(showProgress ? 1 : 0)
                .animation(.easeInOut(duration: 0.8).delay(animationDelays[1]), value: showProgress)
                
                // Fat progress bar with enhanced info
                NutritionProgressBar(
                    title: "脂肪",
                    nutrientData: nutritionData.fat,
                    calorieInfo: nutritionData.macronutrientCaloriesDistribution.fat,
                    percentage: nutritionData.macronutrientPercentages.fat,
                    color: .fatColor,
                    showProgress: showProgress
                )
                .opacity(showProgress ? 1 : 0)
                .animation(.easeInOut(duration: 0.8).delay(animationDelays[2]), value: showProgress)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.backgroundGray.opacity(0.5))
        .cornerRadius(16)
        .onAppear {
            showProgress = true
        }
    }
}

struct NutritionProgressBar: View {
    let title: String
    let nutrientData: NutrientData
    let calorieInfo: Int
    let percentage: Double
    let color: Color
    let showProgress: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(nutrientData.percentage)%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                    
                    Text("\(Int(percentage * 100))% 熱量")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("\(nutrientData.current)\(nutrientData.unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("\(calorieInfo) 卡")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("目標 \(nutrientData.goal)\(nutrientData.unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Enhanced progress bar with gradient
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    // Progress fill with gradient
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.7), color]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: showProgress ? geometry.size.width * min(nutrientData.progress, 1.0) : 0,
                            height: 12
                        )
                        .animation(.easeInOut(duration: 1.0), value: showProgress)
                    
                    // Progress indicator dot
                    if showProgress && nutrientData.progress > 0 {
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                            .position(
                                x: min(geometry.size.width * nutrientData.progress, geometry.size.width - 3),
                                y: 6
                            )
                            .animation(.easeInOut(duration: 1.0).delay(0.5), value: showProgress)
                    }
                }
            }
            .frame(height: 12)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    VStack {
        NutritionProgressSection(nutritionData: .sample)
            .padding()
        
        Spacer()
    }
}
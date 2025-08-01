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
            }
            
            VStack(spacing: 16) {
                // Carbohydrates progress bar
                NutritionProgressBar(
                    title: "碳水化合物",
                    nutrientData: nutritionData.carbs,
                    color: .carbsColor,
                    showProgress: showProgress
                )
                .opacity(showProgress ? 1 : 0)
                .animation(.easeInOut(duration: 0.8).delay(animationDelays[0]), value: showProgress)
                
                // Protein progress bar
                NutritionProgressBar(
                    title: "蛋白質",
                    nutrientData: nutritionData.protein,
                    color: .proteinColor,
                    showProgress: showProgress
                )
                .opacity(showProgress ? 1 : 0)
                .animation(.easeInOut(duration: 0.8).delay(animationDelays[1]), value: showProgress)
                
                // Fat progress bar
                NutritionProgressBar(
                    title: "脂肪",
                    nutrientData: nutritionData.fat,
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
    let color: Color
    let showProgress: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(nutrientData.percentage)%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            HStack {
                Text("\(nutrientData.current)\(nutrientData.unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(nutrientData.goal)\(nutrientData.unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar with smooth animation
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(
                            width: showProgress ? geometry.size.width * min(nutrientData.progress, 1.0) : 0,
                            height: 8
                        )
                        .animation(.easeInOut(duration: 1.0), value: showProgress)
                }
            }
            .frame(height: 8)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack {
        NutritionProgressSection(nutritionData: .sample)
            .padding()
        
        Spacer()
    }
}
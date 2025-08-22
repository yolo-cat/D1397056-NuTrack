//
//  NutritionTrackerView.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI

struct NewNutritionTrackerView: View {
    @ObservedObject var userManager: SimpleUserManager
    @State private var nutritionData = NutritionData.sample
    @State private var foodEntries = FoodLogEntry.todayEntries
    @State private var showAddNutrition = false
    
    var body: some View {
        NavigationView {
            ZStack {
                mainNutritionView
                
                // Bottom floating add button
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showAddNutrition = true
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.primaryBlue)
                                    .frame(width: 60, height: 60)
                                    .shadow(color: Color.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 10)
                }
            }
        }
        .sheet(isPresented: $showAddNutrition) {
            AddNutritionView { nutritionInfo in
                addNutritionEntry(nutritionInfo)
            }
        }
        .onAppear {
            updateNutritionData()
        }
    }
    
    // MARK: - Main Nutrition Tracking View
    
    private var mainNutritionView: some View {
        ZStack {
            Color.backgroundGray.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with navigation, title, and user avatar
                HeaderView(username: userManager.currentUsername, userManager: userManager)
                
                // Main scrollable content
                ScrollView {
                    VStack(spacing: 24) {
                        // Nutrition progress bars (carbs, protein, fat)
                        NutritionProgressSection(nutritionData: nutritionData)
                        
                        // Today's food entries
                        TodayFoodLogView(foodEntries: foodEntries)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Helper Functions
    
    private func addNutritionEntry(_ nutritionInfo: NutritionInfo) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            let currentTime = timeFormatter.string(from: Date())
            let simplifiedEntry = FoodLogEntry(
                time: currentTime,
                nutrition: nutritionInfo
            )
            foodEntries.append(simplifiedEntry)
            updateNutritionData()
        }
    }
    
    private func updateNutritionData() {
        let totalCalories = foodEntries.reduce(0) { $0 + $1.totalCalories }
        let totalCarbs = foodEntries.reduce(0) { sum, entry in
            sum + entry.totalCarbs
        }
        let totalProtein = foodEntries.reduce(0) { sum, entry in
            sum + entry.totalProtein
        }
        let totalFat = foodEntries.reduce(0) { sum, entry in
            sum + entry.totalFat
        }
        
        // 使用動態營養目標而非靜態目標
        let goal = userManager.getCurrentNutritionGoals()
        
        nutritionData = NutritionData(
            caloriesConsumed: totalCalories,
            caloriesBurned: nutritionData.caloriesBurned,
            caloriesGoal: goal.calories,
            carbs: NutrientData(current: totalCarbs, goal: goal.carbs, unit: "g"),
            protein: NutrientData(current: totalProtein, goal: goal.protein, unit: "g"),
            fat: NutrientData(current: totalFat, goal: goal.fat, unit: "g")
        )
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}

#Preview {
    NewNutritionTrackerView(userManager: SimpleUserManager())
}

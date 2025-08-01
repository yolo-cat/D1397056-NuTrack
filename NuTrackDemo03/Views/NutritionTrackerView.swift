//
//  NutritionTrackerView.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI

struct NewNutritionTrackerView: View {
    @State private var nutritionData = NutritionData.sample
    @State private var foodEntries = FoodLogEntry.todayEntries
    @State private var selectedTab = 0
    @State private var showAddMeal = false
    
    var body: some View {
        ZStack {
                    // 根據 selectedTab 切換不同內容
                    Group {
                        switch selectedTab {
                        case 0:
                            NavigationView { mainNutritionView }
                        case 1:
                            DiaryView()
                        case 2:
                            AddMealView { newEntry in addMealEntry(newEntry) }
                        case 3:
                            TrendsView()
                        case 4:
                            SettingsView()
                        default:
                            EmptyView()
                        }
                    }
                    .ignoresSafeArea(.keyboard) // 避免鍵盤遮擋

                    // AlternativeCustomTabBar 疊加在底部
                    VStack {
                        Spacer()
                        AlternativeCustomTabBar(selectedTab: $selectedTab) {
                            // 按下加號時的行為
                            selectedTab = 2
                        }
                        .padding(.bottom, -35) // 可視需求調整
                    }
                }
// 簡單圖標底部導航列
//        TabView(selection: $selectedTab) {
//            // Home Tab
//            NavigationView {
//                mainNutritionView
//            }
//            .tabItem {
//                Image(systemName: "house.fill")
//                Text("Home")
//            }
//            .tag(0)
//            
//            // Diary Tab
//            DiaryView()
//                .tabItem {
//                    Image(systemName: "book.fill")
//                    Text("Diary")
//                }
//                .tag(1)
//            
//            // Add Tab (Center with larger icon)
//            AddMealView { newEntry in
//                addMealEntry(newEntry)
//            }
//            .tabItem {
//                Image(systemName: "plus.circle.fill")
//                Text("Add")
//            }
//            .tag(2)
//            
//            // Trends Tab
//            TrendsView()
//                .tabItem {
//                    Image(systemName: "chart.line.uptrend.xyaxis")
//                    Text("Trends")
//                }
//                .tag(3)
//            
//            // Settings Tab
//            SettingsView()
//                .tabItem {
//                    Image(systemName: "gearshape.fill")
//                    Text("Settings")
//                }
//                .tag(4)
//        }
//        .accentColor(.primaryBlue)
    }
    
    // MARK: - Main Nutrition Tracking View
    
    private var mainNutritionView: some View {
        ZStack {
            Color.backgroundGray.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with navigation, title, and user avatar
                HeaderView()
                
                // Main scrollable content
                ScrollView {
                    VStack(spacing: 24) {
                        // Central nutrition ring and calorie tracking
                        calorieTrackingSection
                        
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
    
    // MARK: - Calorie Tracking Section
    
    private var calorieTrackingSection: some View {
        VStack(spacing: 20) {
            // Central nutrition ring showing calorie progress
            CalorieRingView(nutritionData: nutritionData)
            
            // Consumed vs Burned display
            HStack(spacing: 40) {
                VStack {
                    Text("\(nutritionData.caloriesConsumed)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryBlue)
                    
                    Text("已攝取")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(nutritionData.caloriesBurned)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.carbsColor)
                    
                    Text("已燃燒")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Helper Functions
    
    private func addMealEntry(_ entry: FoodLogEntry) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            foodEntries.append(entry)
            updateNutritionData()
        }
    }
    
    private func updateNutritionData() {
        let totalCalories = foodEntries.reduce(0) { $0 + $1.totalCalories }
        let totalCarbs = foodEntries.reduce(0) { sum, entry in
            sum + entry.meals.reduce(0) { $0 + $1.nutrition.carbs }
        }
        let totalProtein = foodEntries.reduce(0) { sum, entry in
            sum + entry.meals.reduce(0) { $0 + $1.nutrition.protein }
        }
        let totalFat = foodEntries.reduce(0) { sum, entry in
            sum + entry.meals.reduce(0) { $0 + $1.nutrition.fat }
        }
        
        let goal = DailyGoal.standard
        
        nutritionData = NutritionData(
            caloriesConsumed: totalCalories,
            caloriesBurned: nutritionData.caloriesBurned,
            caloriesGoal: goal.calories,
            carbs: NutrientData(current: totalCarbs, goal: goal.carbs, unit: "g"),
            protein: NutrientData(current: totalProtein, goal: goal.protein, unit: "g"),
            fat: NutrientData(current: totalFat, goal: goal.fat, unit: "g")
        )
    }
}

#Preview {
    NewNutritionTrackerView()
}

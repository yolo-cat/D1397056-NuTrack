//
//  NewNutritionTrackerView.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI
import SwiftData

struct NewNutritionTrackerView: View {
    let user: UserProfile
    
    @Environment(\.modelContext) private var modelContext
    @Query private var mealEntries: [MealEntry]
    
    @State private var showAddNutrition = false
    
    init(user: UserProfile) {
        self.user = user
        // 動態設定查詢謂詞，只抓取當前使用者今天的餐點紀錄
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        let userID = user.id
        
        self._mealEntries = Query(filter: #Predicate<MealEntry> {
            $0.user?.id == userID && $0.timestamp >= startOfToday && $0.timestamp < endOfToday
        }, sort: \.timestamp, order: .reverse)
    }
    
    // MARK: - Computed Properties
    
    private var nutritionData: NutritionData {
        let totalCarbs = mealEntries.reduce(0) { $0 + $1.carbs }
        let totalProtein = mealEntries.reduce(0) { $0 + $1.protein }
        let totalFat = mealEntries.reduce(0) { $0 + $1.fat }
        let totalCalories = mealEntries.reduce(0) { $0 + $1.calories }
        
        return NutritionData(
            caloriesConsumed: totalCalories,
            caloriesGoal: user.dailyCalorieGoal,
            carbs: .init(current: totalCarbs, goal: user.dailyCarbsGoal, unit: "g"),
            protein: .init(current: totalProtein, goal: user.dailyProteinGoal, unit: "g"),
            fat: .init(current: totalFat, goal: user.dailyFatGoal, unit: "g")
        )
    }
    
    private var foodLogEntries: [FoodLogEntry] {
        mealEntries.map { FoodLogEntry(mealEntry: $0) }
    }
    
    // MARK: - Main Body
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                mainNutritionView
                addMealButton
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddNutrition) {
            AddNutritionView { nutritionInfo in
                addNutritionEntry(nutritionInfo)
            }
        }
    }
    
    // MARK: - View Components
    
    private var mainNutritionView: some View {
        ZStack {
            Color.backgroundGray.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 0) {
                HeaderView(user: user)
                ScrollView {
                    VStack(spacing: 24) {
                        NutritionProgressSection(nutritionData: nutritionData)
                        TodayFoodLogView(foodEntries: foodLogEntries)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 80) // Add padding for floating button
                }
            }
        }
    }
    
    private var addMealButton: some View {
        Button(action: { showAddNutrition = true }) {
            ZStack {
                Circle().fill(Color.primaryBlue).frame(width: 60, height: 60)
                    .shadow(color: .primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                Image(systemName: "plus").font(.title2).fontWeight(.bold).foregroundColor(.white)
            }
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - Helper Functions
    
    private func addNutritionEntry(_ nutritionInfo: NutritionInfo) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            let newEntry = MealEntry(
                carbs: nutritionInfo.carbs,
                protein: nutritionInfo.protein,
                fat: nutritionInfo.fat
            )
            newEntry.user = user
            modelContext.insert(newEntry)
        }
    }
}

// MARK: - FoodLogEntry Extension
// 讓 FoodLogEntry 可以直接從 MealEntry 初始化，作為一個轉接層
extension FoodLogEntry {
    init(mealEntry: MealEntry) {
        self.init(
            timestamp: Int64(mealEntry.timestamp.timeIntervalSince1970 * 1000),
            nutrition: .init(
                carbsGrams: mealEntry.carbs,
                proteinGrams: mealEntry.protein,
                fatGrams: mealEntry.fat
            )
        )
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, MealEntry.self, configurations: config)
    
    let sampleUser = UserProfile(name: "預覽用戶", weightInKg: 72.5)
    container.mainContext.insert(sampleUser)
    
    // Create some sample meal entries for the preview
    let sampleMeal1 = MealEntry(carbs: 50, protein: 25, fat: 10)
    sampleMeal1.user = sampleUser
    container.mainContext.insert(sampleMeal1)
    
    let sampleMeal2 = MealEntry(carbs: 30, protein: 15, fat: 5)
    sampleMeal2.user = sampleUser
    container.mainContext.insert(sampleMeal2)
    
    return NewNutritionTrackerView(user: sampleUser)
        .modelContainer(container)
}

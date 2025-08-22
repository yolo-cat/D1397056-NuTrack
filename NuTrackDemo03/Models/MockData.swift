//
//  MockData.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import Foundation

extension MealItem {
    /// 簡化的 Mock 餐點資料 - 僅包含時間和營養素
    static let mockMeals: [MealItem] = [
        // 早餐類別 - 6項
        MealItem(
            name: "",
            type: .breakfast,
            time: "07:30",
            nutrition: NutritionInfo(carbsGrams: 45, proteinGrams: 12, fatGrams: 8)
        ),
        MealItem(
            name: "",
            type: .breakfast,
            time: "07:45",
            nutrition: NutritionInfo(carbsGrams: 35, proteinGrams: 8, fatGrams: 5)
        ),
        MealItem(
            name: "",
            type: .breakfast,
            time: "08:00",
            nutrition: NutritionInfo(carbsGrams: 50, proteinGrams: 10, fatGrams: 6)
        ),
        MealItem(
            name: "",
            type: .breakfast,
            time: "08:15",
            nutrition: NutritionInfo(carbsGrams: 25, proteinGrams: 2, fatGrams: 1)
        ),
        MealItem(
            name: "",
            type: .breakfast,
            time: "08:30",
            nutrition: NutritionInfo(carbsGrams: 20, proteinGrams: 15, fatGrams: 12)
        ),
        MealItem(
            name: "",
            type: .breakfast,
            time: "08:45",
            nutrition: NutritionInfo(carbsGrams: 30, proteinGrams: 6, fatGrams: 3)
        ),
        
        // 午餐類別 - 8項
        MealItem(
            name: "",
            type: .lunch,
            time: "12:00",
            nutrition: NutritionInfo(carbsGrams: 25, proteinGrams: 35, fatGrams: 15)
        ),
        MealItem(
            name: "",
            type: .lunch,
            time: "12:15",
            nutrition: NutritionInfo(carbsGrams: 55, proteinGrams: 18, fatGrams: 20)
        ),
        MealItem(
            name: "",
            type: .lunch,
            time: "12:30",
            nutrition: NutritionInfo(carbsGrams: 40, proteinGrams: 22, fatGrams: 12)
        ),
        MealItem(
            name: "",
            type: .lunch,
            time: "12:45",
            nutrition: NutritionInfo(carbsGrams: 45, proteinGrams: 20, fatGrams: 10)
        ),
        MealItem(
            name: "",
            type: .lunch,
            time: "13:00",
            nutrition: NutritionInfo(carbsGrams: 60, proteinGrams: 25, fatGrams: 18)
        ),
        MealItem(
            name: "",
            type: .lunch,
            time: "13:15",
            nutrition: NutritionInfo(carbsGrams: 50, proteinGrams: 12, fatGrams: 15)
        ),
        MealItem(
            name: "",
            type: .lunch,
            time: "13:30",
            nutrition: NutritionInfo(carbsGrams: 15, proteinGrams: 30, fatGrams: 12)
        ),
        MealItem(
            name: "",
            type: .lunch,
            time: "13:45",
            nutrition: NutritionInfo(carbsGrams: 70, proteinGrams: 22, fatGrams: 16)
        ),
        
        // 晚餐類別 - 8項
        MealItem(
            name: "",
            type: .dinner,
            time: "18:00",
            nutrition: NutritionInfo(carbsGrams: 8, proteinGrams: 40, fatGrams: 22)
        ),
        MealItem(
            name: "",
            type: .dinner,
            time: "18:15",
            nutrition: NutritionInfo(carbsGrams: 15, proteinGrams: 45, fatGrams: 28)
        ),
        MealItem(
            name: "",
            type: .dinner,
            time: "18:30",
            nutrition: NutritionInfo(carbsGrams: 5, proteinGrams: 18, fatGrams: 14)
        ),
        MealItem(
            name: "",
            type: .dinner,
            time: "18:45",
            nutrition: NutritionInfo(carbsGrams: 2, proteinGrams: 38, fatGrams: 20)
        ),
        MealItem(
            name: "",
            type: .dinner,
            time: "19:00",
            nutrition: NutritionInfo(carbsGrams: 20, proteinGrams: 6, fatGrams: 2)
        ),
        MealItem(
            name: "",
            type: .dinner,
            time: "19:15",
            nutrition: NutritionInfo(carbsGrams: 8, proteinGrams: 5, fatGrams: 1)
        ),
        MealItem(
            name: "",
            type: .dinner,
            time: "19:30",
            nutrition: NutritionInfo(carbsGrams: 6, proteinGrams: 20, fatGrams: 12)
        ),
        MealItem(
            name: "",
            type: .dinner,
            time: "19:45",
            nutrition: NutritionInfo(carbsGrams: 10, proteinGrams: 28, fatGrams: 9)
        )
    ]
}

extension NutritionData {
    /// 基於 Mock 餐點資料計算的範例營養資料
    static let sample: NutritionData = {
        let meals = MealItem.mockMeals.prefix(5) // 使用前5個餐點作為今日攝取
        
        let totalCalories = meals.reduce(0) { $0 + $1.nutrition.calories }
        let totalCarbs = meals.reduce(0) { $0 + $1.nutrition.carbs }
        let totalProtein = meals.reduce(0) { $0 + $1.nutrition.protein }
        let totalFat = meals.reduce(0) { $0 + $1.nutrition.fat }
        
        let goal = DailyGoal.standard
        
        return NutritionData(
            caloriesConsumed: totalCalories,
            caloriesBurned: 320,
            caloriesGoal: goal.calories,
            carbs: NutrientData(current: totalCarbs, goal: goal.carbs, unit: "g"),
            protein: NutrientData(current: totalProtein, goal: goal.protein, unit: "g"),
            fat: NutrientData(current: totalFat, goal: goal.fat, unit: "g")
        )
    }()
}

// MARK: - FoodLogEntry Mock Data
extension FoodLogEntry {
    /// 今日飲食記錄範例資料
    static let todayEntries: [FoodLogEntry] = [
        FoodLogEntry(
            time: "07:30",
            meals: Array(MealItem.mockMeals.filter { $0.type == .breakfast }.prefix(2)),
            type: .breakfast
        ),
        FoodLogEntry(
            time: "12:30",
            meals: Array(MealItem.mockMeals.filter { $0.type == .lunch }.prefix(2)),
            type: .lunch
        ),
        FoodLogEntry(
            time: "18:30",
            meals: Array(MealItem.mockMeals.filter { $0.type == .dinner }.prefix(1)),
            type: .dinner
        )
    ]
}

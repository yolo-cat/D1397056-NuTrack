//
//  MockData.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import Foundation

extension MealItem {
    /// 10 份真實的 Mock 餐點資料
    static let mockMeals: [MealItem] = [
        // 早餐
        MealItem(
            name: "煎蛋",
            type: .breakfast,
            time: "07:30",
            nutrition: NutritionInfo(calories: 155, carbs: 1, protein: 13, fat: 11)
        ),
        MealItem(
            name: "全麥吐司",
            type: .breakfast,
            time: "07:35",
            nutrition: NutritionInfo(calories: 120, carbs: 22, protein: 4, fat: 2)
        ),
        MealItem(
            name: "燕麥粥",
            type: .breakfast,
            time: "08:00",
            nutrition: NutritionInfo(calories: 150, carbs: 27, protein: 5, fat: 3)
        ),
        MealItem(
            name: "無糖豆漿",
            type: .breakfast,
            time: "08:00",
            nutrition: NutritionInfo(calories: 80, carbs: 4, protein: 7, fat: 4)
        ),
        
        // 午餐
        MealItem(
            name: "雞胸肉沙拉",
            type: .lunch,
            time: "12:30",
            nutrition: NutritionInfo(calories: 300, carbs: 15, protein: 35, fat: 12)
        ),
        MealItem(
            name: "蘑菇義大利麵",
            type: .lunch,
            time: "13:00",
            nutrition: NutritionInfo(calories: 380, carbs: 45, protein: 15, fat: 16)
        ),
        MealItem(
            name: "鮭魚壽司",
            type: .lunch,
            time: "12:45",
            nutrition: NutritionInfo(calories: 250, carbs: 30, protein: 18, fat: 8)
        ),
        MealItem(
            name: "火腿三明治",
            type: .lunch,
            time: "12:15",
            nutrition: NutritionInfo(calories: 320, carbs: 35, protein: 20, fat: 12)
        ),
        
        // 晚餐
        MealItem(
            name: "香煎鮭魚",
            type: .dinner,
            time: "18:30",
            nutrition: NutritionInfo(calories: 350, carbs: 2, protein: 40, fat: 20)
        ),
        MealItem(
            name: "牛排配蔬菜",
            type: .dinner,
            time: "19:00",
            nutrition: NutritionInfo(calories: 450, carbs: 12, protein: 45, fat: 25)
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

/// 今日食物記錄條目
struct FoodLogEntry: Identifiable {
    let id = UUID()
    let time: String
    let meals: [MealItem]
    let type: MealType
    
    var totalCalories: Int {
        meals.reduce(0) { $0 + $1.nutrition.calories }
    }
    
    var caloriePercentage: Int {
        Int(Double(totalCalories) / Double(DailyGoal.standard.calories) * 100)
    }
    
    var description: String {
        meals.map { $0.name }.joined(separator: " + ")
    }
}

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
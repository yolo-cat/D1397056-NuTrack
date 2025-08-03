//
//  MockData.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import Foundation

extension MealItem {
    /// 豐富多樣的 Mock 餐點資料
    static let mockMeals: [MealItem] = [
        // 早餐類別 - 6項
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
        MealItem(
            name: "希臘優格",
            type: .breakfast,
            time: "07:45",
            nutrition: NutritionInfo(calories: 130, carbs: 9, protein: 15, fat: 6)
        ),
        MealItem(
            name: "香蕉",
            type: .breakfast,
            time: "08:15",
            nutrition: NutritionInfo(calories: 105, carbs: 27, protein: 1, fat: 0)
        ),
        
        // 午餐類別 - 8項
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
        MealItem(
            name: "牛肉麵",
            type: .lunch,
            time: "12:00",
            nutrition: NutritionInfo(calories: 420, carbs: 50, protein: 25, fat: 18)
        ),
        MealItem(
            name: "蔬菜咖哩",
            type: .lunch,
            time: "12:30",
            nutrition: NutritionInfo(calories: 280, carbs: 40, protein: 8, fat: 12)
        ),
        MealItem(
            name: "鮪魚沙拉",
            type: .lunch,
            time: "12:45",
            nutrition: NutritionInfo(calories: 220, carbs: 8, protein: 25, fat: 10)
        ),
        MealItem(
            name: "糙米便當",
            type: .lunch,
            time: "13:15",
            nutrition: NutritionInfo(calories: 450, carbs: 65, protein: 20, fat: 15)
        ),
        
        // 晚餐類別 - 8項
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
        ),
        MealItem(
            name: "蒸蛋",
            type: .dinner,
            time: "18:15",
            nutrition: NutritionInfo(calories: 180, carbs: 3, protein: 15, fat: 12)
        ),
        MealItem(
            name: "烤雞腿",
            type: .dinner,
            time: "19:30",
            nutrition: NutritionInfo(calories: 320, carbs: 0, protein: 35, fat: 18)
        ),
        MealItem(
            name: "蒸蔬菜",
            type: .dinner,
            time: "18:45",
            nutrition: NutritionInfo(calories: 80, carbs: 15, protein: 3, fat: 1)
        ),
        MealItem(
            name: "味噌湯",
            type: .dinner,
            time: "19:15",
            nutrition: NutritionInfo(calories: 45, carbs: 5, protein: 3, fat: 1)
        ),
        MealItem(
            name: "烤豆腐",
            type: .dinner,
            time: "18:00",
            nutrition: NutritionInfo(calories: 180, carbs: 4, protein: 18, fat: 10)
        ),
        MealItem(
            name: "海鮮湯",
            type: .dinner,
            time: "19:45",
            nutrition: NutritionInfo(calories: 200, carbs: 8, protein: 25, fat: 8)
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
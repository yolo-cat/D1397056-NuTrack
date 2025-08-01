//
//  NutritionModels.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import Foundation

// MARK: - Core Data Models

/// 營養資訊結構
struct NutritionInfo {
    let calories: Int
    let carbs: Int
    let protein: Int
    let fat: Int
    
    init(calories: Int, carbs: Int, protein: Int, fat: Int) {
        self.calories = calories
        self.carbs = carbs
        self.protein = protein
        self.fat = fat
    }
}

/// 餐點類型列舉
enum MealType: String, CaseIterable {
    case breakfast = "早餐"
    case lunch = "午餐"
    case dinner = "晚餐"
    
    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        }
    }
}

/// 餐點資訊結構
struct MealItem: Identifiable {
    let id = UUID()
    let name: String
    let type: MealType
    let time: String
    let nutrition: NutritionInfo
    
    init(name: String, type: MealType, time: String, nutrition: NutritionInfo) {
        self.name = name
        self.type = type
        self.time = time
        self.nutrition = nutrition
    }
}

/// 每日營養目標結構
struct DailyGoal {
    let calories: Int
    let carbs: Int
    let protein: Int
    let fat: Int
    
    static let standard = DailyGoal(
        calories: 1973,
        carbs: 120,
        protein: 180,
        fat: 179
    )
}

/// 營養素資料結構
struct NutrientData {
    var current: Int
    var goal: Int
    var unit: String
    
    var progress: Double {
        Double(current) / Double(goal)
    }
    
    var percentage: Int {
        Int(progress * 100)
    }
}

/// 主要營養資料結構
struct NutritionData {
    var caloriesConsumed: Int
    var caloriesBurned: Int
    var caloriesGoal: Int
    var carbs: NutrientData
    var protein: NutrientData
    var fat: NutrientData
    
    var remainingCalories: Int {
        caloriesGoal - caloriesConsumed + caloriesBurned
    }
    
    var calorieProgress: Double {
        Double(caloriesConsumed) / Double(caloriesGoal)
    }
    
    /// 計算總營養素攝取百分比用於圓環顯示
    var totalNutrientProgress: Double {
        let carbsPercent = carbs.progress
        let proteinPercent = protein.progress
        let fatPercent = fat.progress
        return (carbsPercent + proteinPercent + fatPercent) / 3.0
    }
}
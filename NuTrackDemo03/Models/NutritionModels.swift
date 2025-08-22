//
//  NutritionModels.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI
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
    
    /// 從三大營養素重量自動計算熱量的便利建構子
    init(carbsGrams: Int, proteinGrams: Int, fatGrams: Int) {
        self.carbs = carbsGrams
        self.protein = proteinGrams
        self.fat = fatGrams
        // 自動計算熱量：碳水 4kcal/g + 蛋白質 4kcal/g + 脂肪 9kcal/g
        self.calories = (carbsGrams * 4) + (proteinGrams * 4) + (fatGrams * 9)
    }
}

/// 基於時間的餐點分類列舉
enum TimeBasedMealCategory: String, CaseIterable {
    case lateNight = "凌晨"        // 00:00-04:59
    case breakfast = "早餐時段"    // 05:00-10:59
    case lunch = "午餐時段"        // 11:00-15:59
    case dinner = "晚餐時段"       // 16:00-22:59
    case midnightSnack = "夜宵時段" // 23:00-23:59
    
    var icon: String {
        switch self {
        case .lateNight: return "moon.stars.fill"
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "sunset.fill"
        case .midnightSnack: return "moon.fill"
        }
    }
    
    var color: String {
        switch self {
        case .lateNight: return "purple"
        case .breakfast: return "accentOrange"
        case .lunch: return "primaryBlue"
        case .dinner: return "fatColor"
        case .midnightSnack: return "indigo"
        }
    }
    
    /// 從時間字串 (HH:mm 格式) 解析出對應的餐點分類
    static func category(from timeString: String) -> TimeBasedMealCategory {
        // 解析時間字串，期待 "HH:mm" 格式
        let components = timeString.split(separator: ":")
        guard components.count == 2,
              let hour = Int(components[0]),
              hour >= 0 && hour <= 23 else {
            // 預設返回早餐時段
            return .breakfast
        }
        
        switch hour {
        case 0...4:
            return .lateNight
        case 5...10:
            return .breakfast
        case 11...15:
            return .lunch
        case 16...22:
            return .dinner
        case 23:
            return .midnightSnack
        default:
            return .breakfast
        }
    }
}

/// 餐點資訊結構
struct MealItem: Identifiable {
    let id = UUID()
    let name: String
    let time: String
    let nutrition: NutritionInfo
    
    init(name: String, time: String, nutrition: NutritionInfo) {
        self.name = name
        self.time = time
        self.nutrition = nutrition
    }
    
    /// 基於時間自動分類的餐點類型
    var timeBasedCategory: TimeBasedMealCategory {
        return TimeBasedMealCategory.category(from: time)
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
        guard goal > 0 else { return 0.0 }
        return Double(current) / Double(goal)
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
    
    /// 計算三大營養素的熱量分佈
    var macronutrientCaloriesDistribution: (carbs: Int, protein: Int, fat: Int) {
        let carbsCalories = carbs.current * 4  // 1g 碳水化合物 = 4 卡路里
        let proteinCalories = protein.current * 4  // 1g 蛋白質 = 4 卡路里
        let fatCalories = fat.current * 9  // 1g 脂肪 = 9 卡路里
        return (carbsCalories, proteinCalories, fatCalories)
    }
    
    /// 計算三大營養素的理想熱量分佈百分比
    var macronutrientPercentages: (carbs: Double, protein: Double, fat: Double) {
        let distribution = macronutrientCaloriesDistribution
        let totalMacroCalories = distribution.carbs + distribution.protein + distribution.fat
        
        guard totalMacroCalories > 0 else {
            return (0, 0, 0)
        }
        
        let carbsPercent = Double(distribution.carbs) / Double(totalMacroCalories)
        let proteinPercent = Double(distribution.protein) / Double(totalMacroCalories)
        let fatPercent = Double(distribution.fat) / Double(totalMacroCalories)
        
        return (carbsPercent, proteinPercent, fatPercent)
    }
    
    }

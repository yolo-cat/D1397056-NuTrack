//
//  NutritionModels.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI
import Foundation

// MARK: - 時段分類枚舉
enum TimeBasedCategory: String, CaseIterable {
    case lateNight = "深夜"      // 00:00 - 05:59
    case breakfast = "早餐"      // 06:00 - 10:59
    case lunch = "午餐"          // 11:00 - 15:59
    case dinner = "晚餐"         // 16:00 - 21:59
    case midnightSnack = "宵夜"  // 22:00 - 23:59
    
    var icon: String {
        switch self {
        case .lateNight: return "moon.zzz.fill"
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "sunset.fill"
        case .midnightSnack: return "moon.fill"
        }
    }
    
    /// 統一的時間分類方法
    static func categorize(from timestamp: Int64) -> TimeBasedCategory {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
        let hour = Calendar.current.component(.hour, from: date)
        
        switch hour {
        case 0..<6:
            return .lateNight
        case 6..<11:
            return .breakfast
        case 11..<16:
            return .lunch
        case 16..<22:
            return .dinner
        default:
            return .midnightSnack
        }
    }
}

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

/// 餐點資訊結構
struct MealItem: Identifiable {
    let id: String
    let name: String
    let timestamp: Int64
    let nutrition: NutritionInfo
    
    init(id: String, name: String, timestamp: Int64, nutrition: NutritionInfo) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
        self.nutrition = nutrition
    }
    
    /// 顯示名稱：優先使用記錄時間，而不是餐點名稱
    var displayName: String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
        return DateFormatter.HHmm.string(from: date)
    }
    
    /// 時段分類的計算屬性 - 使用統一方法
    var timeBasedCategory: TimeBasedCategory {
        return TimeBasedCategory.categorize(from: timestamp)
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

/// 今日食物記錄條目
struct FoodLogEntry: Identifiable {
    let id = UUID()
    let timestamp: Int64
    let meals: [MealItem]?
    let nutrition: NutritionInfo?
    
    // 新版建構子：直接營養記錄
    init(timestamp: Int64, nutrition: NutritionInfo) {
        self.timestamp = timestamp
        self.meals = nil
        self.nutrition = nutrition
    }
    
    var totalCalories: Int {
        if let nutrition = nutrition {
            return nutrition.calories
        } else if let meals = meals {
            return meals.reduce(0) { $0 + $1.nutrition.calories }
        }
        return 0
    }
    
    var totalCarbs: Int {
        if let nutrition = nutrition {
            return nutrition.carbs
        } else if let meals = meals {
            return meals.reduce(0) { $0 + $1.nutrition.carbs }
        }
        return 0
    }
    
    var totalProtein: Int {
        if let nutrition = nutrition {
            return nutrition.protein
        } else if let meals = meals {
            return meals.reduce(0) { $0 + $1.nutrition.protein }
        }
        return 0
    }
    
    var totalFat: Int {
        if let nutrition = nutrition {
            return nutrition.fat
        } else if let meals = meals {
            return meals.reduce(0) { $0 + $1.nutrition.fat }
        }
        return 0
    }
    
    /// 使用統一的時段分類方法
    var timeBasedCategory: TimeBasedCategory {
        return TimeBasedCategory.categorize(from: timestamp)
    }
}

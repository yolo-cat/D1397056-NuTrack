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
    static func categorize(time: String) -> TimeBasedCategory {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        guard let mealTime = formatter.date(from: time) else {
            return .breakfast // 無法解析時間時預設為早餐
        }
        
        formatter.dateFormat = "HH"
        let hourString = formatter.string(from: mealTime)
        guard let hour = Int(hourString) else {
            return .breakfast
        }
        
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
    let id: String // 使用精確到毫秒的時間戳作為唯一識別
    let name: String
    let type: MealType
    let time: String
    let nutrition: NutritionInfo
    private let createdAt: Date // 記錄創建的精確時間
    
    init(name: String, type: MealType, time: String, nutrition: NutritionInfo) {
        self.createdAt = Date()
        // 使用精確到毫秒的時間戳作為唯一識別
        let timeInterval = self.createdAt.timeIntervalSince1970
        let milliseconds = Int(timeInterval * 1000)
        self.id = "\(time)_\(milliseconds)"
        
        self.name = name
        self.type = type
        self.time = time
        self.nutrition = nutrition
    }
    
    /// 顯示名稱：優先使用記錄時間，而不是餐點名稱
    var displayName: String {
        return "記錄於 \(time)"
    }
    
    /// 時段分類的計算屬性 - 使用統一方法
    var timeBasedCategory: TimeBasedCategory {
        return TimeBasedCategory.categorize(time: time)
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

/// 今日食物記錄條目
struct FoodLogEntry: Identifiable {
    let id = UUID()
    let time: String
    let meals: [MealItem]?
    let type: MealType?
    let nutrition: NutritionInfo?
    
    // 舊版建構子：基於餐點
    init(time: String, meals: [MealItem], type: MealType) {
        self.time = time
        self.meals = meals
        self.type = type
        self.nutrition = nil
    }
    
    // 新版建構子：直接營養記錄
    init(time: String, nutrition: NutritionInfo) {
        self.time = time
        self.meals = nil
        self.type = nil
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
    
    var caloriePercentage: Int {
        Int(Double(totalCalories) / Double(DailyGoal.standard.calories) * 100)
    }
    
    var description: String {
        if let meals = meals {
            return meals.map { $0.displayName }.joined(separator: " + ")
        } else if let nutrition = nutrition {
            return "營養記錄"
        }
        return "未知記錄"
    }
    
    /// 使用統一的時段分類方法
    var timeBasedCategory: TimeBasedCategory {
        return TimeBasedCategory.categorize(time: time)
    }
}

//
//  WeightCalculations.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2025/1/15.
//

import Foundation

// MARK: - Weight-based Nutrition Calculations Extension

extension Double {
    /// 驗證體重範圍是否有效
    var isValidWeight: Bool {
        return self >= 30.0 && self <= 300.0
    }
    
    /// 格式化體重顯示（保留一位小數）
    var formattedWeight: String {
        return String(format: "%.1f", self)
    }
}

// MARK: - Weight-based Nutrition Goal Calculations

struct WeightBasedNutrition {
    
    /// 根據體重計算基礎營養目標
    /// - Parameter weight: 體重（公斤）
    /// - Returns: 計算出的營養目標（碳水、蛋白質、脂肪的公克數）
    static func calculateBaseNutritionGoals(for weight: Double) -> (carbs: Int, protein: Int, fat: Int) {
        guard weight.isValidWeight else {
            return (carbs: 120, protein: 180, fat: 179) // 返回預設值
        }
        
        // 營養計算公式
        let carbs = Int(weight * 3.0)      // 3g/kg 體重
        let protein = Int(weight * 1.5)    // 1.5g/kg 體重  
        let fat = Int(weight * 0.9)        // 0.9g/kg 體重
        
        return (carbs: carbs, protein: protein, fat: fat)
    }
    
    /// 計算營養素建議範圍
    /// - Parameter weight: 體重（公斤）
    /// - Returns: 各營養素的最小值和最大值範圍
    static func calculateNutrientRanges(for weight: Double) -> (carbsRange: ClosedRange<Double>, proteinRange: ClosedRange<Double>, fatRange: ClosedRange<Double>) {
        guard weight.isValidWeight else {
            return (
                carbsRange: 60.0...360.0,
                proteinRange: 48.0...132.0,
                fatRange: 48.0...60.0
            )
        }
        
        let carbsRange = (weight * 1.0)...(weight * 6.0)      // 1-6g/kg
        let proteinRange = (weight * 0.8)...(weight * 2.2)    // 0.8-2.2g/kg
        let fatRange = (weight * 0.8)...(weight * 1.0)        // 0.8-1g/kg
        
        return (carbsRange: carbsRange, proteinRange: proteinRange, fatRange: fatRange)
    }
    
    /// 計算總熱量
    /// - Parameters:
    ///   - carbs: 碳水化合物（公克）
    ///   - protein: 蛋白質（公克）
    ///   - fat: 脂肪（公克）
    /// - Returns: 總熱量（卡路里）
    static func calculateTotalCalories(carbs: Int, protein: Int, fat: Int) -> Int {
        return (carbs * 4) + (protein * 4) + (fat * 9)
    }
    
    /// 驗證營養素數值是否在合理範圍內
    /// - Parameters:
    ///   - carbs: 碳水化合物（公克）
    ///   - protein: 蛋白質（公克）
    ///   - fat: 脂肪（公克）
    ///   - weight: 體重（公斤）
    /// - Returns: 是否在建議範圍內
    static func validateNutrientValues(carbs: Int, protein: Int, fat: Int, for weight: Double) -> Bool {
        let ranges = calculateNutrientRanges(for: weight)
        
        let carbsValid = ranges.carbsRange.contains(Double(carbs))
        let proteinValid = ranges.proteinRange.contains(Double(protein))
        let fatValid = ranges.fatRange.contains(Double(fat))
        
        return carbsValid && proteinValid && fatValid
    }
}

// MARK: - Nutrition Goal Extensions

extension DailyGoal {
    /// 根據體重創建個人化營養目標
    /// - Parameter weight: 體重（公斤）
    /// - Returns: 個人化的每日營養目標
    static func personalized(for weight: Double) -> DailyGoal {
        let nutrition = WeightBasedNutrition.calculateBaseNutritionGoals(for: weight)
        let calories = WeightBasedNutrition.calculateTotalCalories(
            carbs: nutrition.carbs,
            protein: nutrition.protein,
            fat: nutrition.fat
        )
        
        return DailyGoal(
            calories: calories,
            carbs: nutrition.carbs,
            protein: nutrition.protein,
            fat: nutrition.fat
        )
    }
    
    /// 根據自定義營養素創建目標
    /// - Parameters:
    ///   - carbs: 碳水化合物目標（公克）
    ///   - protein: 蛋白質目標（公克）
    ///   - fat: 脂肪目標（公克）
    /// - Returns: 自定義的每日營養目標
    static func custom(carbs: Int, protein: Int, fat: Int) -> DailyGoal {
        let calories = WeightBasedNutrition.calculateTotalCalories(
            carbs: carbs,
            protein: protein,
            fat: fat
        )
        
        return DailyGoal(
            calories: calories,
            carbs: carbs,
            protein: protein,
            fat: fat
        )
    }
}
// /Services/NutritionCalculatorService.swift

import Foundation

/// 表示營養素建議範圍（最小值、最大值、建議值）
struct RecommendationRange {
    let min: Int
    let max: Int
    let suggested: Int
}

/// 營養計算服務，提供營養素建議與熱量計算相關功能
struct NutritionCalculatorService {
    /// 每克碳水化合物的熱量（kcal）
    static let carbsCaloriesPerGram = 4
    /// 每克蛋白質的熱量（kcal）
    static let proteinCaloriesPerGram = 4
    /// 每克脂肪的熱量（kcal）
    static let fatCaloriesPerGram = 9

    /// 根據體重計算蛋白質攝取建議範圍（克）
    /// - Parameter weightInKg: 使用者體重（公斤）
    /// - Returns: RecommendationRange（最小、最大、建議值）
    static func getProteinRecommendation(weightInKg: Double) -> RecommendationRange {
        guard (30.0...300.0).contains(weightInKg) else {
            return RecommendationRange(min: 0, max: 0, suggested: 0)
        }

        let minGramsPerKg = 0.8
        let maxGramsPerKg = 2.2
        let suggestedGramsPerKg = 1.5

        return RecommendationRange(
            min: Int(weightInKg * minGramsPerKg),
            max: Int(weightInKg * maxGramsPerKg),
            suggested: Int(weightInKg * suggestedGramsPerKg)
        )
    }

    /// 根據體重計算脂肪攝取建議範圍（克）
    /// - Parameter weightInKg: 使用者體重（公斤）
    /// - Returns: RecommendationRange（最小、最大、建議值）
    static func getFatRecommendation(weightInKg: Double) -> RecommendationRange {
        guard (30.0...300.0).contains(weightInKg) else {
            return RecommendationRange(min: 0, max: 0, suggested: 0)
        }

        let minGramsPerKg = 0.3
        let maxGramsPerKg = 0.8
        let suggestedGramsPerKg = 0.5

        return RecommendationRange(
            min: Int(weightInKg * minGramsPerKg),
            max: Int(weightInKg * maxGramsPerKg),
            suggested: Int(weightInKg * suggestedGramsPerKg)
        )
    }
    
    /// 根據體重計算碳水化合物攝取建議範圍（克）
    /// - Parameter weightInKg: 使用者體重（公斤）
    /// - Returns: RecommendationRange（最小、最大、建議值）
    static func getCarbsRecommendation(weightInKg: Double) -> RecommendationRange {
        guard (30.0...300.0).contains(weightInKg) else {
            return RecommendationRange(min: 0, max: 0, suggested: 0)
        }

        let minGramsPerKg = 3.0
        let maxGramsPerKg = 10.0
        let suggestedGramsPerKg = 5.0

        return RecommendationRange(
            min: Int(weightInKg * minGramsPerKg),
            max: Int(weightInKg * maxGramsPerKg),
            suggested: Int(weightInKg * suggestedGramsPerKg)
        )
    }

    /// 計算三大營養素總熱量（kcal）
    /// - Parameters:
    ///   - carbs: 碳水化合物攝取量（克）
    ///   - protein: 蛋白質攝取量（克）
    ///   - fat: 脂肪攝取量（克）
    /// - Returns: 總熱量（kcal）
    static func calculateTotalCalories(carbs: Double, protein: Double, fat: Double) -> Int {
        return Int((carbs * Double(carbsCaloriesPerGram)) + (protein * Double(proteinCaloriesPerGram)) + (fat * Double(fatCaloriesPerGram)))
    }
}

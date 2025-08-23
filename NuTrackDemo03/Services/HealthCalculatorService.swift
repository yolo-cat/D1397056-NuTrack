// /Services/HealthCalculatorService.swift

import Foundation

// 資料結構與服務邏輯整合在同一個檔案中
struct RecommendationRange {
    let min: Int
    let max: Int
    let suggested: Int
}

struct HealthCalculatorService {

    static func getProteinRecommendation(weightInKg: Double) -> RecommendationRange {
        let minGramsPerKg = 1.6
        let maxGramsPerKg = 2.2
        let suggestedGramsPerKg = 1.8

        return RecommendationRange(
            min: Int(weightInKg * minGramsPerKg),
            max: Int(weightInKg * maxGramsPerKg),
            suggested: Int(weightInKg * suggestedGramsPerKg)
        )
    }

    static func getFatRecommendation(weightInKg: Double) -> RecommendationRange {
        let minGramsPerKg = 0.8
        let maxGramsPerKg = 1.2
        let suggestedGramsPerKg = 1.0

        return RecommendationRange(
            min: Int(weightInKg * minGramsPerKg),
            max: Int(weightInKg * maxGramsPerKg),
            suggested: Int(weightInKg * suggestedGramsPerKg)
        )
    }
    
    static func getCarbsRecommendation(proteinGoal: Int, fatGoal: Int, calorieGoal: Int) -> RecommendationRange {
        let proteinCalories = proteinGoal * 4
        let fatCalories = fatGoal * 9
        let carbsCalories = calorieGoal - proteinCalories - fatCalories
        let suggestedCarbs = max(0, carbsCalories / 4)
        
        return RecommendationRange(
            min: Int(Double(suggestedCarbs) * 0.9),
            max: Int(Double(suggestedCarbs) * 1.1),
            suggested: suggestedCarbs
        )
    }
    
    /// 基於體重計算碳水化合物建議（用於滑桿範圍）
    static func getCarbsRecommendation(weightInKg: Double) -> RecommendationRange {
        let minGramsPerKg = 1.0
        let maxGramsPerKg = 6.0
        let suggestedGramsPerKg = 3.0

        return RecommendationRange(
            min: Int(weightInKg * minGramsPerKg),
            max: Int(weightInKg * maxGramsPerKg),
            suggested: Int(weightInKg * suggestedGramsPerKg)
        )
    }

    static func calculateTotalCalories(carbs: Double, protein: Double, fat: Double) -> Int {
        return Int((carbs * 4) + (protein * 4) + (fat * 9))
    }
}


import Foundation

/// A structure to hold detailed nutrition data for display.
struct NutritionData {
    let carbs: Nutrient
    let protein: Nutrient
    let fat: Nutrient
    let macronutrientCaloriesDistribution: CalorieDistribution

    /// Represents a single nutrient's data.
    struct Nutrient {
        var current: Int
        var goal: Int
        var unit: String
        
        var progress: Double {
            guard goal > 0 else { return 0 }
            return Double(current) / Double(goal)
        }
        
        var percentage: Int {
            Int(progress * 100)
        }
    }

    /// Represents the calorie distribution among macronutrients.
    struct CalorieDistribution {
        let carbs: Int
        let protein: Int
        let fat: Int
    }

    /// Provides sample data for previews and testing.
    static var sample: NutritionData {
        NutritionData(
            carbs: .init(current: 150, goal: 300, unit: "g"),
            protein: .init(current: 80, goal: 150, unit: "g"),
            fat: .init(current: 50, goal: 70, unit: "g"),
            macronutrientCaloriesDistribution: .init(carbs: 600, protein: 320, fat: 450)
        )
    }
}

import Foundation

/// A structure that processes raw data models into a format ready for display in a view.
/// Acts as a ViewModel for the nutrition summary.
struct NutritionSummaryViewModel {
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
            if goal <= 0 { return 0 } // If goal is 0 or negative, progress is 0.
            let progressValue = Double(current) / Double(goal)
            // If the calculation results in NaN (e.g., 0/0), return 0.
            return progressValue.isNaN ? 0 : progressValue
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

    /// Initializes the ViewModel with a user's profile and their meal entries for a specific day.
    init(user: UserProfile, meals: [MealEntry]) {
        let totalCarbs = meals.reduce(0) { $0 + $1.carbs }
        let totalProtein = meals.reduce(0) { $0 + $1.protein }
        let totalFat = meals.reduce(0) { $0 + $1.fat }

        self.carbs = .init(current: totalCarbs, goal: user.dailyCarbsGoal, unit: "g")
        self.protein = .init(current: totalProtein, goal: user.dailyProteinGoal, unit: "g")
        self.fat = .init(current: totalFat, goal: user.dailyFatGoal, unit: "g")

        self.macronutrientCaloriesDistribution = .init(
            carbs: totalCarbs * NutritionCalculatorService.carbsCaloriesPerGram,
            protein: totalProtein * NutritionCalculatorService.proteinCaloriesPerGram,
            fat: totalFat * NutritionCalculatorService.fatCaloriesPerGram
        )
    }

    /// Provides sample data for previews and testing.
    static var sample: NutritionSummaryViewModel {
        // Create sample user and meals for preview
        let sampleUser = UserProfile(name: "Sample User", weightInKg: 70.0)
        let sampleMeals = [
            MealEntry(name: "早餐", carbs: 150, protein: 80, fat: 50),
            MealEntry(name: "午餐", carbs: 100, protein: 70, fat: 20)
        ]
        return NutritionSummaryViewModel(user: sampleUser, meals: sampleMeals)
    }
}

// MARK: - Legacy compatibility
// Providing a typealias to maintain compatibility with existing code
typealias NutritionData = NutritionSummaryViewModel

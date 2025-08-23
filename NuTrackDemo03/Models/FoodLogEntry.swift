import Foundation

struct FoodLogEntry: Identifiable {
    let id = UUID()
    let timestamp: Int64
    let nutrition: NutritionInfo
}

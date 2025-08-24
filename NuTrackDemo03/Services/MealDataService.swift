//
//  MealDataService.swift
//  NuTrackDemo03
//
//  Created by Jules on 2025/8/24.
//

import Foundation
import SwiftData

/// A service class dedicated to handling data operations for `MealEntry` objects.
///
/// This service centralizes the logic for creating, updating, and deleting meal entries,
/// decoupling the data modification logic from the views. It requires a `ModelContext`
/// to interact with the SwiftData store.
class MealDataService {
    private let modelContext: ModelContext

    /// Initializes the service with the given `ModelContext`.
    /// - Parameter modelContext: The SwiftData model context to be used for data operations.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Creates a new `MealEntry` from the provided information and saves it to the data store.
    /// - Parameters:
    ///   - info: The `NutritionInfo` struct containing the meal's nutritional data.
    ///   - user: The `UserProfile` to associate the new meal with.
    func addMeal(info: NutritionInfo, for user: UserProfile) {
        let newEntry = MealEntry(
            name: info.name,
            carbs: info.carbs,
            protein: info.protein,
            fat: info.fat
        )
        newEntry.user = user
        modelContext.insert(newEntry)

        // It's good practice to explicitly save after an insertion
        // to ensure data consistency, though SwiftData often handles this automatically.
        try? modelContext.save()
    }

    /// Deletes a specific `MealEntry` from the data store.
    /// - Parameter meal: The `MealEntry` object to be deleted.
    func delete(meal: MealEntry) {
        modelContext.delete(meal)

        // Explicitly save to persist the deletion immediately.
        try? modelContext.save()
    }
}

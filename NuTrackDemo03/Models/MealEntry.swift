// /Models/MealEntry.swift

import Foundation
import SwiftData

@Model
final class MealEntry {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var carbs: Int
    var protein: Int
    var fat: Int
    
    var calories: Int {
        return (carbs * 4) + (protein * 4) + (fat * 9)
    }
    
    var user: UserProfile?
    
    init(id: UUID = UUID(), timestamp: Date = .now, carbs: Int, protein: Int, fat: Int) {
        self.id = id
        self.timestamp = timestamp
        self.carbs = carbs
        self.protein = protein
        self.fat = fat
    }
}

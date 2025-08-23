//
//  UserProfile.swift
//  NuTrackDemo03
//
//  Created by 訪客使用者 on 2025/8/1.
//

import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    
    // 可選體重（尚未填寫時為 nil）
    var weightInKg: Double?
    
    // 目標值（預設）
    var dailyCalorieGoal: Int
    var dailyCarbsGoal: Int
    var dailyProteinGoal: Int
    var dailyFatGoal: Int

    // 與 MealEntry 的反向關聯，刪除使用者時一併刪除其餐點
    @Relationship(deleteRule: .cascade, inverse: \MealEntry.user)
    var mealEntries: [MealEntry] = []

    init(id: UUID = UUID(),
         name: String,
         weightInKg: Double? = nil,
         dailyCalorieGoal: Int = 2000,
         dailyCarbsGoal: Int = 250,
         dailyProteinGoal: Int = 125,
         dailyFatGoal: Int = 56) {
        self.id = id
        self.name = name
        self.weightInKg = weightInKg
        self.dailyCalorieGoal = dailyCalorieGoal
        self.dailyCarbsGoal = dailyCarbsGoal
        self.dailyProteinGoal = dailyProteinGoal
        self.dailyFatGoal = dailyFatGoal
    }
}

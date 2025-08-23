// /Models/UserProfile.swift

import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    
    // 新增：儲存使用者的體重，可選(nil)代表尚未填寫
    var weightInKg: Double? 
    
    // 目標值：這些值最終將由使用者根據建議自行設定
    var dailyCalorieGoal: Int
    var dailyCarbsGoal: Int
    var dailyProteinGoal: Int
    var dailyFatGoal: Int

    // init 中的預設值，作為使用者完成個人化設定前的「初始值」
    init(id: UUID = UUID(),
         name: String,
         weightInKg: Double? = nil, // 體重可以在建立後再補上
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

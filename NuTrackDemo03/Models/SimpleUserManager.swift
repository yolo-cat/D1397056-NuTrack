//
//  SimpleUserManager.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2025/1/15.
//

import SwiftUI
import Foundation

/// 簡化的使用者狀態管理類別，用於概念驗證階段
class SimpleUserManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUsername: String = ""
    @Published var isLoading: Bool = false
    
    // 新增：用戶體重和營養目標
    @Published var userWeight: Double = 70.0
    @Published var carbsGoal: Double = 210.0
    @Published var proteinGoal: Double = 105.0
    @Published var fatGoal: Double = 63.0
    
    // UserDefaults 鍵值
    private let userDefaultsKeys = (
        isLoggedIn: "nu_track_is_logged_in",
        username: "nu_track_username",
        userWeight: "nu_track_user_weight",
        carbsGoal: "nu_track_carbs_goal",
        proteinGoal: "nu_track_protein_goal",
        fatGoal: "nu_track_fat_goal"
    )
    
    init() {
        checkStoredLogin()
        loadUserData()
    }
    
    /// 檢查已儲存的登入狀態
    func checkStoredLogin() {
        let storedLoginState = UserDefaults.standard.bool(forKey: userDefaultsKeys.isLoggedIn)
        let storedUsername = UserDefaults.standard.string(forKey: userDefaultsKeys.username) ?? ""
        
        if storedLoginState && !storedUsername.isEmpty {
            DispatchQueue.main.async {
                self.isLoggedIn = true
                self.currentUsername = storedUsername
            }
        }
    }
    
    /// 載入用戶資料
    private func loadUserData() {
        DispatchQueue.main.async {
            let savedWeight = UserDefaults.standard.double(forKey: self.userDefaultsKeys.userWeight)
            if savedWeight > 0 {
                self.userWeight = savedWeight
            }
            
            let savedCarbs = UserDefaults.standard.double(forKey: self.userDefaultsKeys.carbsGoal)
            if savedCarbs > 0 {
                self.carbsGoal = savedCarbs
            }
            
            let savedProtein = UserDefaults.standard.double(forKey: self.userDefaultsKeys.proteinGoal)
            if savedProtein > 0 {
                self.proteinGoal = savedProtein
            }
            
            let savedFat = UserDefaults.standard.double(forKey: self.userDefaultsKeys.fatGoal)
            if savedFat > 0 {
                self.fatGoal = savedFat
            }
        }
    }
    
    /// 使用者登入
    /// - Parameter username: 使用者名稱
    func login(username: String) {
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isLoading = true
        
        // 模擬登入過程的延遲
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 儲存到 UserDefaults
            UserDefaults.standard.set(true, forKey: self.userDefaultsKeys.isLoggedIn)
            UserDefaults.standard.set(trimmedUsername, forKey: self.userDefaultsKeys.username)
            
            // 更新狀態
            self.currentUsername = trimmedUsername
            self.isLoggedIn = true
            self.isLoading = false
        }
    }
    
    /// 使用者登出
    func logout() {
        // 清除 UserDefaults
        UserDefaults.standard.removeObject(forKey: userDefaultsKeys.isLoggedIn)
        UserDefaults.standard.removeObject(forKey: userDefaultsKeys.username)
        UserDefaults.standard.removeObject(forKey: userDefaultsKeys.userWeight)
        UserDefaults.standard.removeObject(forKey: userDefaultsKeys.carbsGoal)
        UserDefaults.standard.removeObject(forKey: userDefaultsKeys.proteinGoal)
        UserDefaults.standard.removeObject(forKey: userDefaultsKeys.fatGoal)
        
        // 重置狀態
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.currentUsername = ""
            self.isLoading = false
            self.userWeight = 70.0
            self.carbsGoal = 210.0
            self.proteinGoal = 105.0
            self.fatGoal = 63.0
        }
    }
    
    /// 快速登入功能（開發用）
    /// - Parameter username: 預設使用者名稱
    func quickLogin(username: String) {
        // 直接設定登入狀態，不需要延遲
        UserDefaults.standard.set(true, forKey: userDefaultsKeys.isLoggedIn)
        UserDefaults.standard.set(username, forKey: userDefaultsKeys.username)
        
        currentUsername = username
        isLoggedIn = true
        isLoading = false
    }
    
    // MARK: - 體重和營養目標管理

    /// 更新用戶體重
    /// - Parameter weight: 新的體重（公斤）
    func updateWeight(_ weight: Double) {
        guard isValid(weight: weight) else { return }
        
        DispatchQueue.main.async {
            self.userWeight = weight
            UserDefaults.standard.set(weight, forKey: self.userDefaultsKeys.userWeight)
        }
    }
    
    /// 根據體重更新營養目標
    func updateNutritionGoalsBasedOnWeight() {
        // 使用新的 HealthCalculatorService
        let proteinRec = HealthCalculatorService.getProteinRecommendation(weightInKg: userWeight)
        let fatRec = HealthCalculatorService.getFatRecommendation(weightInKg: userWeight)
        let carbsRec = HealthCalculatorService.getCarbsRecommendation(weightInKg: userWeight)

        DispatchQueue.main.async {
            self.carbsGoal = Double(carbsRec.suggested)
            self.proteinGoal = Double(proteinRec.suggested)
            self.fatGoal = Double(fatRec.suggested)
            
            self.saveNutritionGoals()
        }
    }
    
    /// 更新營養目標
    /// - Parameters:
    ///   - carbs: 碳水化合物目標（公克）
    ///   - protein: 蛋白質目標（公克）
    ///   - fat: 脂肪目標（公克）
    func updateNutritionGoals(carbs: Double, protein: Double, fat: Double) {
        DispatchQueue.main.async {
            self.carbsGoal = carbs
            self.proteinGoal = protein
            self.fatGoal = fat
            
            self.saveNutritionGoals()
        }
    }
    
    /// 儲存營養目標到 UserDefaults
    private func saveNutritionGoals() {
        UserDefaults.standard.set(carbsGoal, forKey: userDefaultsKeys.carbsGoal)
        UserDefaults.standard.set(proteinGoal, forKey: userDefaultsKeys.proteinGoal)
        UserDefaults.standard.set(fatGoal, forKey: userDefaultsKeys.fatGoal)
    }
    
    /// 獲取當前營養目標
    /// - Returns: 當前的每日營養目標
    func getCurrentNutritionGoals() -> DailyGoal {
        // 將 DailyGoal.custom 的邏輯內聯，移除對舊服務的依賴
        let totalCalories = (Int(carbsGoal) * 4) + (Int(proteinGoal) * 4) + (Int(fatGoal) * 9)
        
        return DailyGoal(
            calories: totalCalories,
            carbs: Int(carbsGoal),
            protein: Int(proteinGoal),
            fat: Int(fatGoal)
        )
    }

    // MARK: - Private Helpers

    private func isValid(weight: Double) -> Bool {
        return weight >= 30.0 && weight <= 300.0
    }
    
    /// 計算總熱量目標
    var totalCaloriesGoal: Int {
        return (Int(carbsGoal) * 4) + (Int(proteinGoal) * 4) + (Int(fatGoal) * 9)
    }
}

// MARK: - 預設使用者資料（開發用）
extension SimpleUserManager {
    static let sampleUsers = [
        "Alex Chen",
        "Jamie Wang",
        "Taylor Liu",
        "Casey Zhang"
    ]
}
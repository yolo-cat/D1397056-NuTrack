//
//  DataSeedingService.swift
//  NuTrackDemo03
//
//  Created by Gemini on 2025/8/23.
//

import Foundation
import SwiftData

/// 一次性的資料填充服務，用於在 App 首次啟動時，從本地 JSON 檔案讀取模擬資料並存入 SwiftData 資料庫。
final class DataSeedingService {
    
    /// 執行資料庫填充的主方法。
    /// - Parameter modelContext: SwiftData 的 Model Context。
    /// - Note: 此方法會先檢查資料庫中是否已有使用者資料，若有則會直接跳過，防止重複填充。
    @MainActor
    static func seedDatabase(modelContext: ModelContext) {
        // 0. 先清理舊的虛擬用戶資料（若存在）
        let bannedNames: Set<String> = ["測試使用者", "陳大文", "開發者", "林小美", "新用戶"]
        do {
            let allUsers = try modelContext.fetch(FetchDescriptor<UserProfile>())
            let toDelete = allUsers.filter { bannedNames.contains($0.name) }
            if !toDelete.isEmpty {
                toDelete.forEach { modelContext.delete($0) }
                try modelContext.save() // 先儲存刪除
                print("已清除虛擬用戶：\(toDelete.map { $0.name }.joined(separator: ", "))")
            }
        } catch {
            print("清理虛擬用戶時發生錯誤: \(error)")
        }
        
        // 1. 檢查資料庫是否已經填充過
        do {
            let descriptor = FetchDescriptor<UserProfile>()
            let existingUsers = try modelContext.fetch(descriptor)
            guard existingUsers.isEmpty else {
                print("資料庫已有使用者，跳過種子資料填充。")
                return
            }
        } catch {
            fatalError("檢查現有使用者時發生錯誤: \(error.localizedDescription)")
        }
        
        print("資料庫為空，開始填充種子資料...")
        
        // 2. 載入並解碼 JSON 資料
        guard let users: [MockUser] = load("mock_users.json") else { return }
        guard let mealData: MockMealData = load("mock_meals.json") else { return }
        
        // 3. 轉換並插入 UserProfile
        var userProfileMap: [UUID: UserProfile] = [:]
        for mockUser in users {
            let userProfile = UserProfile(
                id: mockUser.id,
                name: mockUser.name,
                weightInKg: mockUser.weightInKg
            )
            modelContext.insert(userProfile)
            userProfileMap[userProfile.id] = userProfile
        }
        
        // 4. 轉換、建立關聯並插入 MealEntry
        for mockMeal in mealData.meals {
            guard let userProfile = userProfileMap[mockMeal.userId] else {
                print("警告：找不到 ID 為 \(mockMeal.userId) 的使用者，跳過此餐點紀錄。")
                continue
            }
            
            let mealEntry = MealEntry(
                id: mockMeal.id,
                name: "餐點記錄", // Default name for seeded data
                timestamp: Date(timeIntervalSince1970: TimeInterval(mockMeal.timestamp) / 1000),
                carbs: mockMeal.nutrition.carbs,
                protein: mockMeal.nutrition.protein,
                fat: mockMeal.nutrition.fat
            )
            
            // 建立 UserProfile 和 MealEntry 之間的雙向關聯
            mealEntry.user = userProfile
            // SwiftData 會自動處理反向關聯，但如果模型中有定義，也可以手動添加
            // userProfile.mealEntries.append(mealEntry)
        }
        
        // 5. 儲存變更
        do {
            try modelContext.save()
            print("種子資料填充成功！")
        } catch {
            fatalError("儲存種子資料時發生錯誤: \(error.localizedDescription)")
        }
    }
    
    /// 從主 Bundle 中載入並解碼指定的 JSON 檔案。
    /// - Parameter filename: 要載入的檔名 (e.g., "data.json")。
    /// - Returns: 解碼後的物件，若失敗則返回 nil。
    private static func load<T: Decodable>(_ filename: String) -> T? {
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
            fatalError("在主 Bundle 中找不到檔案: \(filename)")
        }
        
        do {
            let data = try Data(contentsOf: file)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("無法載入或解碼檔案 \(filename): \(error.localizedDescription)")
        }
    }
}

// MARK: - JSON 對應的 Decodable 模型

private struct MockUser: Decodable {
    let id: UUID
    let name: String
    let weightInKg: Double?
}

private struct MockMealData: Decodable {
    let meals: [MockMeal]
}

private struct MockMeal: Decodable {
    let id: UUID
    let userId: UUID
    let timestamp: Int64
    let nutrition: MockNutrition
}

private struct MockNutrition: Decodable {
    let carbs: Int
    let protein: Int
    let fat: Int
}

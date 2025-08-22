//
//  JSONDataManager.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2024/8/23.
//

import Foundation

// MARK: - JSON Data Models

struct MealJSON: Codable {
    let id: String
    let timestamp: Int64
    let nutrition: NutritionJSON
    
    /// 轉換為 MealItem
    func toMealItem() -> MealItem {
        let nutritionInfo = NutritionInfo(
            calories: nutrition.calories,
            carbs: nutrition.carbs,
            protein: nutrition.protein,
            fat: nutrition.fat
        )
        
        return MealItem(id: id, name: "", timestamp: timestamp, nutrition: nutritionInfo)
    }
}

struct NutritionJSON: Codable {
    let carbs: Int
    let protein: Int
    let fat: Int
    let calories: Int
}

struct MockDataJSON: Codable {
    let meals: [MealJSON]
    let metadata: MetadataJSON
}

struct MetadataJSON: Codable {
    let version: String
    let lastUpdated: String
    let totalRecords: Int
    let dataSource: String
}

// MARK: - JSON Data Manager

class JSONDataManager {
    static let shared = JSONDataManager()
    private var cachedData: MockDataJSON?
    
    private init() {}
    
    /// 從 JSON 文件載入模擬資料
    func loadMockData() -> MockDataJSON? {
        if let cachedData = cachedData {
            return cachedData
        }
        
        guard let url = Bundle.main.url(forResource: "mock_meals", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("⚠️ 無法找到或讀取 mock_meals.json 文件")
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let mockData = try decoder.decode(MockDataJSON.self, from: data)
            cachedData = mockData
            print("✅ 成功載入 \(mockData.meals.count) 筆餐點記錄")
            return mockData
        } catch {
            print("❌ JSON 解析錯誤: \(error)")
            return nil
        }
    }
    
    /// 取得所有餐點記錄
    func getAllMeals() -> [MealItem] {
        guard let mockData = loadMockData() else { return [] }
        return mockData.meals.map { $0.toMealItem() }
    }
    
    /// 根據時段篩選餐點
    func getMealsByTimeCategory(_ category: TimeBasedCategory) -> [MealItem] {
        guard let mockData = loadMockData() else { return [] }
        return mockData.meals
            .map { $0.toMealItem() } // First, convert to MealItem
            .filter { $0.timeBasedCategory == category } // Then, filter using the computed property
    }
    
    /// 取得今日餐點記錄（根據日期）
    func getTodayMeals() -> [MealItem] {
        guard let mockData = loadMockData() else { return [] }
        return mockData.meals
            .map { $0.toMealItem() }
            .filter { Calendar.current.isDateInToday(Date(timeIntervalSince1970: TimeInterval($0.timestamp) / 1000)) }
    }
    
    /// 取得指定數量的最新記錄
    func getRecentMeals(limit: Int) -> [MealItem] {
        guard let mockData = loadMockData() else { return [] }
        return Array(mockData.meals
            .sorted { $0.timestamp > $1.timestamp }
            .prefix(limit)
            .map { $0.toMealItem() })
    }
    
    /// 模擬新增餐點記錄（實際應用中會寫入資料庫）
    func addMeal(nutrition: NutritionInfo) -> MealItem {
        let now = Date()
        let timestamp = Int64(now.timeIntervalSince1970 * 1000)
        let id = "\(timestamp)"
        
        // 建立 MealItem 並回傳（在真實應用中會儲存到資料庫）
        return MealItem(id: id, name: "", timestamp: timestamp, nutrition: nutrition)
    }
    
    /// 取得資料統計資訊
    func getDataStatistics() -> (totalMeals: Int, lastUpdated: String, version: String) {
        guard let mockData = loadMockData() else {
            return (0, "N/A", "N/A")
        }
        return (
            totalMeals: mockData.metadata.totalRecords,
            lastUpdated: mockData.metadata.lastUpdated,
            version: mockData.metadata.version
        )
    }
}

// MARK: - Convenience Extensions for Direct Access

extension JSONDataManager {
    /// 取得資料載入狀態的描述
    var dataLoadingStatus: String {
        let stats = getDataStatistics()
        return "已載入 \(stats.totalMeals) 筆記錄，版本 \(stats.version)"
    }
    
    /// 檢查資料是否成功載入
    var isDataLoaded: Bool {
        return loadMockData() != nil
    }
    
    /// Mock Data 兼容性 - 取得所有餐點
    var mockMeals: [MealItem] {
        return getAllMeals()
    }
    
    /// Mock Data 兼容性 - 取得今日記錄
    var todayEntries: [FoodLogEntry] {
        let meals = getRecentMeals(limit: 3)
        return meals.map { meal in
            FoodLogEntry(timestamp: meal.timestamp, nutrition: meal.nutrition)
        }
    }
    
    /// Mock Data 兼容性 - 產生營養資料樣本
    var nutritionSample: NutrientData {
        let meals = getRecentMeals(limit: 5)
        
        let totalCarbs = meals.reduce(0) { $0 + $1.nutrition.carbs }
        let goal = DailyGoal.standard
        
        return NutrientData(
            current: totalCarbs, goal: goal.carbs, unit: "g"
        )
    }
    
    /// 根據特定時段計算營養資料
    func nutritionSampleForTimeCategory(_ category: TimeBasedCategory) -> NutritionData {
        let meals = getMealsByTimeCategory(category)
        
        let totalCarbs = meals.reduce(0) { $0 + $1.nutrition.carbs }

        let goal = DailyGoal.standard
        
        return NutrientData(current: totalCarbs, goal: goal.carbs, unit: "g")
    }
    
    /// 根據時段取得飲食記錄
    func foodLogEntriesForTimeCategory(_ category: TimeBasedCategory) -> [FoodLogEntry] {
        let meals = getMealsByTimeCategory(category)
        return meals.map { meal in
            FoodLogEntry(timestamp: meal.timestamp, nutrition: meal.nutrition)
        }
    }
}

// MARK: - DateFormatter Extensions

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    static let HHmm: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
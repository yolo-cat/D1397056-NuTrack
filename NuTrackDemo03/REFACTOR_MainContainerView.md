
# Refactoring Plan: Main Container Views

## 1. 總體目標

本計畫旨在根據 `10_FE_STRATEGY.md` 中定義的架構，重構「主要容器視圖 (Main Container Views)」。核心目標是將 `NutritionTrackerView.swift` 轉變為一個職責單一、功能強大的 App 主儀表板容器。

此容器將專職負責：
1.  **資料管理**：作為資料的「單一來源 (Single Source of Truth)」，直接與 SwiftData 互動，獲取和計算當日營養數據。
2.  **狀態協調**：管理儀表板的 UI 狀態，例如呈現用於新增餐點的 Modal 視圖。
3.  **元件組合**：將底層的、可重用的「表現層」元件（如進度環、食物列表）組合起來，並向其單向提供所需資料。

## 2. 核心策略

重構將遵循 `10_FE_STRATEGY.md` 中闡述的 **資料驅動** 和 **職責分離** 原則。我們將充分利用 SwiftData 的 `@Query` 屬性包裝器來自動獲取和響應資料變化，並確保資料流的單向性，從而建立一個清晰、可預測且易於維護的視圖結構。

## 3. 重構步驟詳解

### 步驟 1：確立 `NutritionTrackerView` 的資料核心

**目標**：將資料查詢與計算邏輯集中在容器頂層，使其成為資料的唯一權威。

*   **引入 `@Query`**：
    *   在 `NutritionTrackerView` 中，使用 `@Query` 屬性包裝器來異步獲取當天的 `MealEntry` 列表。
    *   查詢需要包含兩個過濾條件 (Predicate)：
        1.  匹配當前登入使用者的 ID。
        2.  匹配今天的日期範圍（從今天凌晨 00:00 到午夜 23:59）。
    *   這將確保視圖只顯示相關資料，並在資料庫更新時自動刷新 UI。

*   **集中計算邏輯**：
    *   建立一系列 `private var` 計算屬性，直接基於從 `@Query` 獲取的 `mealEntries` 陣列來計算當日的營養總和（總熱量、碳水、蛋白質、脂肪）。
    *   這樣做可以將計算邏輯與 UI 渲染分離，並確保所有子元件都從同一來源獲取一致的計算結果。

```swift
// 預期的資料核心結構
struct NutritionTrackerView: View {
    // 由父層傳入當前使用者
    var user: UserProfile
    
    @Environment(\.modelContext) private var modelContext
    
    // 1. 使用 @Query 獲取核心資料
    @Query private var mealEntries: [MealEntry]
    
    // 2. 初始化時設定查詢過濾條件
    init(user: UserProfile) {
        self.user = user
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: .now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let userID = user.id
        
        self._mealEntries = Query(filter: #Predicate { 
            $0.userID == userID && $0.timestamp >= startOfDay && $0.timestamp < endOfDay 
        })
    }
    
    // 3. 集中計算營養總和
    private var totalCarbs: Int { mealEntries.reduce(0) { $0 + $1.carbs } }
    private var totalProtein: Int { mealEntries.reduce(0) { $0 + $1.protein } }
    private var totalFat: Int { mealEntries.reduce(0) { $0 + $1.fat } }
    private var totalCalories: Int { (totalCarbs * 4) + (totalProtein * 4) + (totalFat * 9) }
}
```

### 步驟 2：優化視圖組合與單向資料流

**目標**：將 `NutritionTrackerView` 的 `body` 簡化為一個純粹的佈局容器，負責組合子元件並向下傳遞資料。

*   **分解 `body`**：將 UI 拆分為 `10_FE_STRATEGY.md` 中定義的幾個獨立、可重用的元件：
    *   `HeaderView`
    *   `NutritionProgressSection`
    *   `TodayFoodLogView`
*   **實現單向資料流**：
    *   `NutritionTrackerView` 作為父視圖，將計算好的營養總和（如 `totalCalories`）以及目標值（如 `user.dailyCalorieGoal`）作為簡單的 `Int` 或 `String` 傳遞給子元件。
    *   子元件（如 `NutritionProgressSection`）只接收它們需要顯示的資料，而不直接存取整個 `UserProfile` 或 `MealEntry` 陣列。這使得子元件更加通用和可預測。

```swift
// 預期的 body 結構
var body: some View {
    VStack {
        // HeaderView 接收使用者名稱
        HeaderView(username: user.name)
        
        // NutritionProgressSection 接收計算後的總和與目標值
        NutritionProgressSection(
            totalCalories: totalCalories,
            calorieGoal: user.dailyCalorieGoal,
            totalCarbs: totalCarbs, /* ... etc ... */
        )
        
        // TodayFoodLogView 接收排序後的食物列表
        TodayFoodLogView(entries: mealEntries.sorted { $0.timestamp > $1.timestamp })
        
        // ... 其他元件 ...
    }
}
```

### 步驟 3：管理 Modal 呈現與資料回寫

**目標**：將新增營養記錄的流程，完全符合策略中定義的「容器視圖處理資料寫入」模式。

*   **使用 `.sheet` 呈現**：
    *   在 `NutritionTrackerView` 中新增一個 `@State` 變數，例如 `isAddingMeal`，來控制 `AddNutritionView` 的顯示與隱藏。
    *   使用 `.sheet(isPresented: $isAddingMeal)` 修飾符來呈現 `AddNutritionView`。
*   **實現回呼 (Callback)**：
    *   `AddNutritionView` 需要一個回呼閉包，例如 `onAdd: (NutritionInfo) -> Void`，它本身不處理資料庫操作。
    *   當使用者在 `AddNutritionView` 中點擊「儲存」時，它會呼叫這個回呼，將收集到的營養資訊（`NutritionInfo`）傳遞出去。
*   **在容器中處理寫入**：
    *   `NutritionTrackerView` 在 `.sheet` 的回呼中接收到 `NutritionInfo`。
    *   它會根據這些資訊建立一個完整的 `MealEntry` 物件（包含 `userID` 和 `timestamp`），然後使用 `modelContext.insert()` 將其寫入 SwiftData 資料庫。

```swift
// 預期的 Modal 處理邏輯
@State private var isAddingMeal = false

var body: some View {
    // ... 主要 UI ...
    .sheet(isPresented: $isAddingMeal) {
        AddNutritionView(onAdd: { nutritionInfo in
            // 1. 建立完整的 MealEntry 模型
            let newEntry = MealEntry(
                userID: user.id,
                timestamp: .now,
                carbs: nutritionInfo.carbs,
                protein: nutritionInfo.protein,
                fat: nutritionInfo.fat
            )
            
            // 2. 在容器視圖中寫入資料庫
            modelContext.insert(newEntry)
            
            // 3. 關閉 sheet
            isAddingMeal = false
        })
    }
}
```

## 4. 預期成果

完成重構後，`NutritionTrackerView` 將成為一個教科書級別的 SwiftUI 容器視圖：

*   **職責清晰**：它只做三件事：獲取資料、組合元件、處理寫入。
*   **高度內聚**：所有與主儀表板相關的資料邏輯都集中在此，易於查找和修改。
*   **低耦合**：子元件與資料來源解耦，變得更加可重用和易於測試。
*   **完全對齊架構**：完美實現了 `10_FE_STRATEGY.md` 中為「主要容器視圖」設定的設計目標。

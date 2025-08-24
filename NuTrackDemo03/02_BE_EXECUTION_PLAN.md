# Backend Execution Plan: SwiftData Migration & Service Refactoring

本文件基於 `00_BE_STRATEGY.md` 的總體策略與 `01_BE_IMPLEMENTATION.md` 的具體實施細則，制定出一個清晰、可執行的三階段計畫。

---

### **第一部分：建立模型與重構服務 (打地基)**

此階段對應 `01_BE_IMPLEMENTATION.md` 的第一、二部分。目標是建立起 SwiftData 的資料庫綱要 (Schema) 和重構計算邏輯，為後續功能打好基礎。

1.  **更新 SwiftData 模型**:
    *   修改 `/Models/UserProfile.swift`，加入 `weightInKg` 屬性。
    *   建立 `/Models/MealEntry.swift` 檔案，定義餐點記錄模型。
2.  **設定 Model Container**:
    *   在 `NuTrackDemo03App.swift` 中，註冊 `UserProfile` 和 `MealEntry` 兩個模型。
3.  **重構健康計算邏輯**:
    *   建立新的 `/Services/NutritionCalculatorService.swift` 檔案。
    *   將 `Extensions/WeightCalculations.swift` 中的所有計算方法，遷移到新的服務中。
    *   全域搜尋並替換舊方法的呼叫點。
    *   刪除舊的 `Extensions/WeightCalculations.swift` 檔案。

### **第二部分：資料庫種子資料填充 (填資料)**

此階段對應 `00_BE_STRATEGY.md` 的第二步驟。目標是將現有的 JSON 模擬資料，一次性匯入到新的 SwiftData 資料庫中。

1.  **建立資料匯入邏輯**:
    *   建立一個新的服務 (例如 `DataSeedingService`)，專門負責處理資料匯入。
2.  **讀取與轉換**:
    *   該服務將讀取 `mock_users.json` 和 `mock_meals.json`。
    *   將 JSON 資料轉換為 `UserProfile` 和 `MealEntry` 物件。
3.  **寫入資料庫**:
    *   將轉換後的物件，透過 SwiftData 的 `modelContext` 插入資料庫。
    *   確保此操作僅在 App 首次啟動且資料庫為空時執行一次。

### **第三部分：UI 層全面遷移 (接活水)**

此階段對應 `00_BE_STRATEGY.md` 的第三步驟。目標是讓 App 的所有視圖都改為從 SwiftData 讀取資料。

1.  **逐步替換資料源**:
    *   從最簡單的視圖開始 (例如 `TodayFoodLogView`)。
    *   移除所有對舊 `JSONDataManager` 的呼叫。
    *   使用 SwiftData 的 `@Query` 屬性包裝器，直接從資料庫獲取資料。
2.  **完成遷移**:
    *   對專案中所有使用到舊資料的視圖，重複上述替換步驟。
3.  **清理舊程式碼**:
    *   當確認沒有任何地方再使用 `JSONDataManager` 後，安全地刪除 `JSONDataManager.swift`、`mock_users.json` 和 `mock_meals.json` 檔案。

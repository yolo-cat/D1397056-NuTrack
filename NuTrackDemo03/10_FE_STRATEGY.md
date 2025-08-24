# Frontend Architecture Strategy

本文檔旨在闡述 NuTrack App 的前端 (UI) 架構設計，並說明其如何與以 SwiftData 為核心的後端策略對齊。

---

## 核心設計理念

前端架構遵循現代 SwiftUI 的最佳實踐，圍繞以下三個核心理念構建：

1.  **資料驅動 (Data-Driven)**：所有視圖都設計為後端資料的直觀反映。當 SwiftData 資料庫中的資料發生變化時，UI 會自動、響應式地更新，無需手動管理狀態。

2.  **職責分離 (Separation of Concerns)**：視圖被明確地劃分為不同的職責層次，確保了程式碼的高內聚和低耦合。

3.  **單向資料流 (Unidirectional Data Flow)**：資料主要從父視圖流向子視圖，而子視圖的變更則透過回呼 (Callbacks) 或綁定 (Bindings) 的方式通知父視圖，使狀態管理變得清晰可控。

---

## 視圖分類與職責

前端視圖根據其職責，主要分為以下三類：

### 1. 主要容器視圖 (Main Container Views)

這是 App 的核心場景，負責組合多個元件，並直接與 SwiftData 互動。

*   **`NewNutritionTrackerView.swift`**
    *   **職責**：App 的主儀表板，是登入後的第一個畫面。
    *   **與後端互動**：
        *   使用 `@Query` 屬性包裝器，根據當前使用者 ID 和日期，從資料庫中異步讀取 `MealEntry` 列表。
        *   計算當日的營養總和，並將其傳遞給子視圖（如 `NutritionProgressSection`）。
        *   透過 `.sheet` 修飾符來呈現 `AddNutritionView`，並在接收到回呼後，使用 `modelContext.insert()` 將新的 `MealEntry` 寫入資料庫。

### 2. 功能性頁面 (Functional Pages)

這些是執行特定任務的獨立頁面，通常包含較多的業務邏輯。

*   **`SimpleLoginView.swift`**
    *   **職責**：處理使用者登入與註冊。
    *   **與後端互動**：使用 `@Environment(\.modelContext)` 讀取資料庫上下文，透過 `FetchDescriptor` 查詢使用者是否存在，如果不存在則建立新使用者。

*   **`UserProfileView.swift`**
    *   **職責**：允許使用者檢視和修改個人資料與營養目標。
    *   **與後端互動**：使用 `@Bindable` 將 `UserProfile` 模型與 UI 控制項（如 `Slider`）進行雙向綁定，實現了對使用者目標的即時修改與自動儲存。

*   **`AddNutritionView.swift`**
    *   **職責**：提供一個乾淨的介面，讓使用者輸入單筆營養記錄。
    *   **與後端互動**：本身不直接與 SwiftData 互動。它是一個「啞元件 (Dumb Component)」，僅負責收集使用者輸入，並透過 `onNutritionAdded` 回呼將資料傳遞給父視圖 `NewNutritionTrackerView` 進行處理。

### 3. 可重用元件 (Reusable Components)

這些是純粹的「表現層」視圖，負責根據傳入的資料來顯示 UI，不包含業務邏輯。

*   `HeaderView.swift`
*   `NutritionProgressSection.swift`
*   `TodayFoodLogView.swift`

---

## 與後端策略的對齊

前端架構完美實現了 `00_BE_STRATEGY.md` 中「接活水」的目標，透過以下關鍵技術與 SwiftData 後端無縫整合：

| 目的 | 使用技術 | 應用範例 |
| :--- | :--- | :--- |
| **讀取資料** | `@Query` | `NewNutritionTrackerView` 中，用於獲取當日的餐點記錄。 |
| **更新資料** | `@Bindable` | `UserProfileView` 中，用於即時更新使用者的營養目標。 |
| **寫入資料** | `modelContext.insert()` | `NewNutritionTrackerView` 中，用於儲存一筆新的餐點記錄。 |

## 總結

本專案的前端遵循了以資料為中心、職責分離的現代化設計模式。透過充分利用 SwiftData 提供的屬性包裝器和 API，前端視圖得以用一種聲明式、高效率的方式與後端資料層互動，實現了穩定、可維護且易於擴展的 UI 架構。

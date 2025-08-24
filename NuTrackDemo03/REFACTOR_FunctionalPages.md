
# Refactoring Plan: Functional Pages

## 1. 總體目標

本計畫旨在根據 `10_FE_STRATEGY.md` 中定義的架構，對所有「功能性頁面 (Functional Pages)」進行審查和重構。目標是確保每一個頁面都精準地履行其特定職責，並以策略規定的方式與 SwiftData 資料層互動，從而強化應用的模組化和職責分離。

我們將逐一檢視以下三個核心頁面：

1.  `SimpleLoginView.swift`
2.  `UserProfileView.swift`
3.  `AddNutritionView.swift`

## 2. `SimpleLoginView.swift`：驗證與對齊

**策略定義**：作為一個獨立的登入/註冊模組，使用 `FetchDescriptor` 查詢或建立使用者，並透過回呼傳回結果。

**目前狀態**：該視圖的現有實作已高度符合策略定義。

**重構動作**：

*   **確認職責單一性**：確保此視圖除了透過 `onLoginSuccess` 回呼傳出 `UserProfile` 外，不與應用程式的其他部分產生耦合。
*   **驗證資料互動**：再次確認其 `handleLogin` 函式嚴格使用 `@Environment(\.modelContext)` 和 `FetchDescriptor` 來處理資料庫操作，沒有洩漏任何資料庫邏輯到外部。

**結論**：此視圖無需大規模重構。此階段的任務是**驗證**其設計，確保它是一個完美的、自給自足的「功能性頁面」範例。

## 3. `UserProfileView.swift`：擁抱 `@Bindable` 實現無縫更新

**策略定義**：使用 `@Bindable` 將 `UserProfile` 模型與 UI 控制項進行雙向綁定，實現即時、自動的資料儲存。

**目前狀態**：目前視圖使用多個 `@State` 變數作為中介來管理 UI 狀態，並在最後透過 `saveSettings()` 函式手動儲存，這與策略不完全一致。

**重構動作**：

1.  **引入 `@Bindable`**：
    *   將視圖的 `user` 屬性從 `var user: UserProfile` 修改為 `@Bindable var user: UserProfile`。這是實現無縫雙向綁定的關鍵。

2.  **移除冗餘的 `@State`**：
    *   刪除所有用於鏡像模型資料的本地 `@State` 變數，包括 `weightInput`, `carbsSliderValue`, `proteinSliderValue`, `fatSliderValue`。

3.  **直接綁定 UI 控制項**：
    *   將 `Slider`、`TextField` 等 UI 控制項直接綁定到 `user` 模型的屬性上。SwiftUI 和 SwiftData 將自動處理資料的更新和儲存。
    *   對於需要格式轉換的 `Double`（如體重），可以建立一個綁定轉換器 (Binding Transformer) 或在 `body` 中進行即時轉換。

    ```swift
    // 修改前 (使用 @State)
    // @State private var carbsSliderValue: Double
    // Slider(value: $carbsSliderValue, ...)

    // 修改後 (直接綁定 @Bindable)
    // Slider(value: $user.dailyCarbsGoal.doubleBinding, ...)
    // TextField("體重", text: $user.weightInKg.stringBinding)
    ```
    *註：`doubleBinding` 和 `stringBinding` 是需要自行擴展以處理類型轉換的計算屬性。*

4.  **簡化儲存邏輯**：
    *   由於資料是即時自動儲存的，`saveSettings()` 函式中的手動儲存邏輯可以被移除。此按鈕現在的職責僅剩下 `presentationMode.wrappedValue.dismiss()`，即關閉頁面。

**預期成果**：`UserProfileView` 的程式碼將大幅簡化，狀態管理變得極為輕鬆，完全體現了資料驅動的設計理念。

## 4. `AddNutritionView.swift`：貫徹「啞元件」模式

**策略定義**：作為一個「啞元件 (Dumb Component)」，僅負責收集使用者輸入，並透過回呼將資料傳遞給父視圖，**絕不直接與 SwiftData 互動**。

**目前狀態**：需要確保該視圖完全獨立於資料庫。

**重構動作**：

1.  **定義清晰的輸出合約 (Output Contract)**：
    *   在視圖中定義一個清晰的回呼屬性：`let onAdd: (NutritionInfo) -> Void`。
    *   建立一個簡單的、本地的 `struct NutritionInfo`，用來封裝使用者輸入的純資料（如碳水、蛋白質、脂肪），從而與核心的 `MealEntry` 模型解耦。

    ```swift
    // 在 AddNutritionView.swift 中定義
    struct NutritionInfo {
        var name: String
        var carbs: Int
        var protein: Int
        var fat: Int
    }
    ```

2.  **移除所有資料層存取**：
    *   **嚴格檢查並移除**任何 `@Environment(\.modelContext)` 的宣告。
    *   確保視圖中**沒有**任何 `modelContext.insert()` 或 `modelContext.save()` 等資料庫操作。

3.  **使用本地 `@State` 管理輸入**：
    *   使用 `@State` 變數來管理各個 `TextField` 的狀態，例如 `@State private var name: String = ""`。

4.  **重構儲存按鈕的行為**：
    *   按鈕的 `action` 現在只做三件事：
        1.  對本地 `@State` 變數進行基本的輸入驗證。
        2.  用驗證後的資料建立一個 `NutritionInfo` 實例。
        3.  呼叫 `onAdd(newNutritionInfo)` 回呼，將資料傳遞出去。

**預期成果**：`AddNutritionView` 將成為一個完全可重用、可獨立測試的 UI 元件，其行為由其父視圖完全掌控，完美實踐了職責分離原則。

## 5. 總結

完成本次重構後，每一個「功能性頁面」都將擁有明確的界線和單一的職責，其與資料層的互動方式將完全符合 `10_FE_STRATEGY.md` 的規範。這將極大地提升程式碼庫的穩定性、可測試性和長期可維護性。

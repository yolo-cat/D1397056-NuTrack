
# Refactoring Guidelines: Reusable Components

## 1. 總體目標

本指引旨在根據 `10_FE_STRATEGY.md` 中定義的架構，對所有「可重用元件 (Reusable Components)」進行審查和重構。核心目標是確保這些元件嚴格遵循「純粹表現層」的原則，即它們只負責根據傳入的資料來顯示 UI，不包含任何業務邏輯或資料庫互動。

我們將重點關注以下元件：

*   `HeaderView.swift`
*   `NutritionProgressSection.swift`
*   `TodayFoodLogView.swift`

## 2. 核心原則：純粹表現層 (Pure Presentation Layer)

可重用元件的核心原則是「啞元件 (Dumb Component)」或「表現層元件 (Presentational Component)」。這意味著它們：

1.  **只負責渲染 UI**：根據接收到的資料來顯示視覺元素。
2.  **不包含業務邏輯**：不執行資料計算、網路請求、資料庫操作或複雜的狀態管理。
3.  **不直接與 SwiftData 互動**：絕不使用 `@Environment(\.modelContext)`、`@Query` 或 `@Bindable`。
4.  **透過參數接收所有資料**：所有需要顯示的資料都必須作為 `let` 屬性從父視圖傳入。
5.  **透過回呼 (Callbacks) 向上傳遞事件**：如果元件需要與使用者互動（例如按鈕點擊），它應該定義一個回呼閉包，將事件通知給父視圖，由父視圖來處理業務邏輯。

## 3. 重構指引詳解

### 3.1. 資料輸入 (Data Input)

*   **使用 `let` 屬性**：所有從父視圖接收的資料都應定義為 `let` 屬性。這強調了資料的單向流動和不可變性。

    ```swift
    // 錯誤範例：使用 @State 或 @Binding 接收外部資料
    // @State var someValue: Int
    // @Binding var anotherValue: String

    // 正確範例：使用 let 接收外部資料
    let username: String
    let totalCalories: Int
    let entries: [MealEntry]
    ```

*   **傳遞原始資料或預處理資料**：根據元件的需求，可以傳遞原始資料模型（例如 `MealEntry` 陣列給 `TodayFoodLogView`）或已經由父視圖計算好的預處理資料（例如 `totalCalories` 給 `NutritionProgressSection`）。選擇哪種方式取決於元件的複雜度和通用性需求。

### 3.2. 移除業務邏輯 (Remove Business Logic)

*   **移除計算邏輯**：任何涉及資料計算的邏輯（例如計算總熱量、判斷進度百分比）都應該從可重用元件中移除，並上移到其父容器視圖中。

    ```swift
    // 錯誤範例：在可重用元件中進行計算
    // private var progressPercentage: Double { Double(current) / Double(goal) }

    // 正確範例：從父視圖接收計算好的結果
    let progressPercentage: Double
    ```

*   **移除資料庫互動**：確保元件中沒有任何 SwiftData 相關的程式碼，包括 `@Environment(\.modelContext)`、`@Query`、`@Bindable` 或任何 `modelContext` 的呼叫。

*   **移除複雜的狀態管理**：可重用元件應盡量避免使用 `@State`，除非是管理純粹的 UI 狀態（例如一個開關的 `isOn` 狀態，且該狀態不影響業務邏輯）。

### 3.3. 事件輸出 (Event Output)

*   **使用回呼閉包**：如果元件包含可互動的 UI 元素（例如按鈕），它應該定義一個回呼閉包來通知父視圖事件的發生。

    ```swift
    // 範例：HeaderView 中的按鈕點擊事件
    let onSaveTapped: () -> Void

    // 在按鈕的 action 中呼叫
    Button("保存", action: onSaveTapped)
    ```

*   **傳遞必要資訊**：回呼閉包可以選擇性地傳遞任何父視圖需要知道的資訊（例如，如果是一個列表中的項目被選中，可以傳遞該項目的 ID）。

### 3.4. 預覽 (Previews)

*   **獨立預覽**：由於可重用元件不依賴於外部環境或資料庫，它們應該能夠在 Xcode Previews 中獨立運行，只需提供模擬的 `let` 屬性值即可。

    ```swift
    #Preview {
        HeaderView(username: "測試用戶", onSaveTapped: { print("保存被點擊") })
    }
    ```

## 4. 針對特定元件的指引

*   **`HeaderView.swift`**：
    *   應接收 `username: String` 作為參數。
    *   如果包含按鈕（例如「保存」或「返回」），應定義相應的回呼閉包，例如 `onSaveTapped: () -> Void`。
    *   不應包含任何導航邏輯（例如 `presentationMode.wrappedValue.dismiss()`），這應由父視圖處理。

*   **`NutritionProgressSection.swift`**：
    *   應接收所有需要顯示的數值作為 `Int` 或 `Double` 參數，例如 `totalCalories: Int`, `calorieGoal: Int`, `totalCarbs: Int`, `carbsGoal: Int` 等。
    *   所有進度計算（例如百分比）都應在父視圖中完成並作為參數傳入。

*   **`TodayFoodLogView.swift`**：
    *   應接收 `entries: [MealEntry]` 作為參數。如果需要排序，應在父視圖中完成排序並傳入已排序的陣列。
    *   不應包含任何刪除或編輯 `MealEntry` 的邏輯，如果需要這些功能，應定義回呼閉包。

## 5. 預期成果

完成本次重構後，所有「可重用元件」將：

*   **高度可重用**：可以在應用程式的不同部分輕鬆使用，而無需修改其內部邏輯。
*   **易於測試**：由於其行為完全由輸入決定，單元測試將變得非常簡單。
*   **程式碼清晰**：職責分離將使程式碼庫更易於理解和維護。
*   **完全對齊架構**：完美實現了 `10_FE_STRATEGY.md` 中為「可重用元件」設定的設計目標。

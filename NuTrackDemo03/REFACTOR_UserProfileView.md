
# Refactoring Plan: `UserProfileView.swift`

## 1. 總體目標

本次重構旨在將 `UserProfileView` 的 UI/UX 提升至與 `SimpleLoginView` 一致的現代化、高質感的設計水平。我們將採用一致的佈局、視覺風格和元件化方法，以確保應用程式整體體驗的連貫性。同時，確保視圖能完整、直觀地展示並修改 `UserProfile` 模型中的所有相關資料。

## 2. 核心策略

*   **視覺風格統一**：引入 `SimpleLoginView` 中使用的背景漸層、主色調 (`primaryBlue`) 和字體層次，營造統一的品牌識別。
*   **元件化重構**：將 UI 分解為更小、更專注的子視圖 (`private var` computed properties)，提高程式碼的可讀性、可維護性和複用性。
*   **使用者體驗 (UX) 增強**：
    *   優化佈局，使資訊分區更清晰，視覺動線更流暢。
    *   提供更明確的視覺回饋，例如表單驗證、數值範圍提示等。
    *   將複雜的控制項（如滑桿）包裝在更具資訊性的容器中。
*   **資料模型對齊**：確保所有 `UserProfile` 中的可編輯欄位（體重、各營養素目標）都在 UI 上有對應的控制項，並確保資料流動的正確性。

## 3. 重構步驟詳解

### 步驟 1：採納一致的佈局與背景

**目標**：建立與 `SimpleLoginView` 相同的視覺基底。

*   **修改 `body` 結構**：
    *   在最外層使用 `ZStack`。
    *   將 `SimpleLoginView` 中的 `LinearGradient` 背景應用到 `ZStack` 的底層，取代目前的 `Color.backgroundGray.opacity(0.3)`，以實現全域一致的背景風格。
    *   保持 `ScrollView` 作為內容的主要容器。

```swift
// 預期修改後的 body 結構
var body: some View {
    ZStack {
        // 統一的背景漸層
        LinearGradient(
            gradient: Gradient(colors: [
                Color.backgroundGray.opacity(0.3),
                Color.primaryBlue.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        ScrollView {
            // ... 主要內容 ...
        }
    }
    .navigationBarHidden(true)
    // ... 其他修飾符 ...
}
```

### 步驟 2：元件化 UI 區塊

**目標**：將 UI 拆分為邏輯清晰、易於管理的區塊，提升程式碼可讀性。

*   **重構 `userInfoSection`**：此區塊目前混合了導覽列和用戶資訊，應將其拆分。
    *   建立 `private var headerView: some View`：專門負責頂部的「返回按鈕」、「頁面標題」和「保存按鈕」。
    *   建立 `private var userAvatarSection: some View`：負責顯示用戶頭像和名稱。
*   **完整實作子視圖**：取消註解並完整實作 `weightInputSection`、`nutritionGoalsSection`、`nutritionSlidersSection` 和 `totalCaloriesSection`。
*   **使用卡片式設計 (Card-like Design)**：為每個主要區塊（如體重、營養目標）應用統一的容器樣式，例如圓角背景、陰影和內邊距，使其看起來像獨立的「卡片」，增加介面的層次感和組織性。

```swift
// 預期的元件化結構
private var body: some View {
    // ... ZStack 與背景 ...
    ScrollView {
        VStack(spacing: 24) {
            headerView
            userAvatarSection
            weightInputSection
            nutritionSlidersSection
            totalCaloriesSection
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
    // ...
}

// 新增或重構的元件
private var headerView: some View { /* ... */ }
private var userAvatarSection: some View { /* ... */ }
private var weightInputSection: some View { /* ... */ }
private var nutritionSlidersSection: some View { /* ... */ }
private var totalCaloriesSection: some View { /* ... */ }
```

### 步驟 3：優化 UI 控制項與互動

**目標**：提升表單的易用性和視覺回饋。

*   **`weightInputSection`**：
    *   採用與 `SimpleLoginView` 中 `TextField` 類似的風格：圓角、背景色、陰影。
    *   在輸入框旁明確標示單位 "kg"。
    *   當 `showWeightValidationError` 觸發時，除了 Alert，也應在輸入框下方顯示紅色的錯誤提示文字，提供即時上下文回饋。
*   **`nutritionSlidersSection`**：
    *   將此區塊進一步拆分為三個獨立的滑桿元件，或使用 `VStack` 組織。
    *   為每個滑桿（碳水、蛋白質、脂肪）建立一個包含「標題」、「目前數值」、「滑桿」和「建議範圍」的複合元件。
    *   視覺上標示出 `NutritionCalculatorService` 提供的建議範圍（min/max），幫助使用者做出合理設定。
*   **`totalCaloriesSection`**：
    *   將總熱量顯示設計得更為突出。可以將其放置在一個視覺上獨立的卡片中，使用較大的字體和醒目的顏色，並加上 "預估總熱量" 的標題。

### 步驟 4：最終程式碼結構預覽

以下是重構後 `UserProfileView` 的結構預覽，展示了如何將各個部分組織起來。

```swift
// /Views/TabPages/UserProfileView.swift

import SwiftUI
import SwiftData

struct UserProfileView: View {
    @Bindable var user: UserProfile
    @Environment(\.presentationMode) var presentationMode
    
    // --- Local State ---
    @State private var weightInput: String
    @State private var carbsSliderValue: Double
    @State private var proteinSliderValue: Double
    @State private var fatSliderValue: Double
    @State private var showWeightValidationError = false

    // --- Initializer ---
    init(user: UserProfile) {
        self.user = user
        self._weightInput = State(initialValue: String(format: "%.1f", user.weightInKg ?? 0))
        self._carbsSliderValue = State(initialValue: Double(user.dailyCarbsGoal))
        self._proteinSliderValue = State(initialValue: Double(user.dailyProteinGoal))
        self._fatSliderValue = State(initialValue: Double(user.dailyFatGoal))
    }

    // --- Main Body ---
    var body: some View {
        ZStack {
            // 1. 統一背景
            LinearGradient(gradient: Gradient(colors: [Color.backgroundGray.opacity(0.3), Color.primaryBlue.opacity(0.1)]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    // 2. 元件化 UI
                    headerView
                    userAvatarSection
                    weightInputSection
                    nutritionSlidersSection
                    totalCaloriesSection
                    
                    Spacer()
                }
                .padding(20)
            }
        }
        .navigationBarHidden(true)
        .alert("體重無效", isPresented: $showWeightValidationError) { /* ... */ }
        .onTapGesture { hideKeyboard() }
    }

    // MARK: - UI Components
    
    private var headerView: some View {
        // 返回按鈕、標題、保存按鈕
    }
    
    private var userAvatarSection: some View {
        // 用戶頭像和名稱
    }
    
    private var weightInputSection: some View {
        // 體重輸入卡片，包含標題、TextField 和單位
    }
    
    private var nutritionSlidersSection: some View {
        // 包含三個營養素滑桿的大卡片
    }
    
    private var totalCaloriesSection: some View {
        // 顯示總熱量的摘要卡片
    }
    
    // MARK: - Helper Functions
    // ... (saveSettings, loadCurrentValues, etc.)
}

// MARK: - Child Views (Optional)
// 如果滑桿等元件變得複雜，可以將其提取為獨立的 struct View
// struct NutritionSliderView: View { ... }

// MARK: - Preview
#Preview {
    // ...
}
```

## 4. 預期成果

*   **UI/UX 一致性**：`UserProfileView` 將與 `SimpleLoginView` 和應用程式的其他部分無縫融合。
*   **程式碼品質提升**：程式碼將更具結構性、可讀性和可維護性。
*   **更佳的使用者體驗**：使用者將在一個更清晰、更美觀、更易於操作的介面中設定他們的個人資料。

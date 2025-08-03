# NuTrackDemo03 專案結構

## 📁 專案整體架構

```
NuTrackDemo03/
├── 📱 NuTrackDemo03App.swift                 # 應用程式入口點
├── 📊 Models/                                # 資料模型層
│   ├── NutritionModels.swift                # 核心營養資料結構
│   └── MockData.swift                       # 測試/展示資料
├── 🎨 Views/                                # 使用者介面層
│   ├── 👁️ NutritionTrackerView.swift        # 主要追蹤視圖
│   ├── Components/                          # 可重用 UI 組件
│   │   ├── CalorieRingView.swift            # 
│   │   ├── CustomTabView.swift              # 自定義標籤視圖
│   │   ├── HeaderView.swift                 #
│   │   ├── CNutritionProgressSection.swift  # 
│   │   └── TodayFoodLogView.swift           # 今日食物記錄組件
│   └── TabPages/                            # 各個分頁視圖
│       ├── AddMealView.swift                # 新增餐點頁面
│       ├── DiaryView.swift                  # 飲食日記頁面
│       ├── SettingsView.swift               # 設定頁面
│       └── TrendsView.swift                 # 趨勢分析頁面
├── 🛠️ Extensions/                           # 擴展功能
│    └── Color+NutritionTheme.swift          # 色彩主題
```

## 🏗️ 各層結構詳細說明

### 2. 應用程式核心層 (Application Core)

#### 2.1 應用程式入口點
**檔案：** [`NuTrackDemo03App.swift`](https://github.com/yolo-cat/1133-iOS-NutritionTracker/blob/main/NuTrackDemo03/NuTrackDemo03App.swift)

```swift
@main
struct NuTrackDemo03App: App {
    var body: some Scene {
        WindowGroup {
            NewNutritionTrackerView()
        }
    }
}
```

**用途：**
- **生命週期管理：** 作為 SwiftUI 應用程式的主要入口
- **場景配置：** 定義應用程式的視窗群組
- **根視圖設定：** 指定應用程式啟動時的初始視圖
- **全域設定：** 管理應用程式層級的配置

### 3. 資料模型層 (Data Models)
**路徑：** `Models/`

#### 3.1 核心資料結構
**檔案：** [`NutritionModels.swift`](https://github.com/yolo-cat/1133-iOS-NutritionTracker/blob/main/NuTrackDemo03/Models/NutritionModels.swift)

```swift
// 營養資訊核心結構
struct NutritionInfo {
    let calories: Int
    let carbs: Int
    let protein: Int
    let fat: Int
}

// 餐點類型定義
enum MealType: String, CaseIterable {
    case breakfast = "早餐"
    case lunch = "午餐" 
    case dinner = "晚餐"
}
```

**用途：**
- **資料抽象：** 定義應用程式的核心資料結構
- **型別安全：** 使用 Swift 強型別系統確保資料正確性
- **業務邏輯：** 包含營養計算和資料處理邏輯
- **可擴展性：** 提供清晰的資料模型擴展介面

#### 3.2 測試資料
**檔案：** [`MockData.swift`](https://github.com/yolo-cat/1133-iOS-NutritionTracker/blob/main/NuTrackDemo03/Models/MockData.swift)

```swift
extension MealItem {
    static let mockMeals: [MealItem] = [
        MealItem(name: "煎蛋", type: .breakfast, 
                time: "07:30", nutrition: NutritionInfo(...)),
        // 更多測試資料...
    ]
}
```

**用途：**
- **開發支援：** 提供開發階段的測試資料
- **原型驗證：** 支援功能原型的快速驗證
- **UI 測試：** 為介面測試提供一致性資料
- **展示用途：** 用於應用程式展示和演示

### 4. 使用者介面層 (User Interface)
**路徑：** `Views/`

#### 4.1 主要視圖控制器
**檔案：** [`NutritionTrackerView.swift`](https://github.com/yolo-cat/1133-iOS-NutritionTracker/blob/main/NuTrackDemo03/Views/NutritionTrackerView.swift)

```swift
struct NewNutritionTrackerView: View {
    @State private var nutritionData = NutritionData.sample
    @State private var foodEntries = FoodLogEntry.todayEntries
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 各個分頁的實現
        }
    }
}
```

**用途：**
- **導航架構：** 實作應用程式的主要導航結構
- **狀態管理：** 管理應用程式的全域狀態
- **視圖協調：** 協調各個子視圖之間的互動
- **資料流控制：** 控制資料在視圖間的流動

#### 4.2 可重用組件 (Components)
**路徑：** `Views/Components/`

##### [CustomTabView.swift](https://github.com/yolo-cat/1133-iOS-NutritionTracker/blob/main/NuTrackDemo03/Views/Components/CustomTabView.swift)
```swift
struct CustomTabView: View {
    @Binding var selectedTab: Int
    let onAddMeal: () -> Void
    
    // 自定義標籤列實現
    // 包含浮動新增按鈕
}
```

**用途：**
- **客製化導航：** 提供比標準 TabView 更靈活的導航選項
- **視覺設計：** 實作特殊的視覺效果（如浮動按鈕）
- **互動增強：** 提供更豐富的使用者互動體驗
- **可重用性：** 在多個地方重複使用的自定義組件

##### [TodayFoodLogView.swift](https://github.com/yolo-cat/1133-iOS-NutritionTracker/blob/main/NuTrackDemo03/Views/Components/TodayFoodLogView.swift)
```swift
struct TodayFoodLogView: View {
    let foodEntries: [FoodLogEntry]
    @State private var animatedItems: Set<UUID> = []
    
    // 今日食物記錄的顯示邏輯
    // 包含動畫效果
}
```

**用途：**
- **資料展示：** 專門展示今日食物攝取記錄
- **動畫效果：** 提供流暢的進入動畫
- **資訊架構：** 有組織地呈現複雜的營養資訊
- **使用者體驗：** 提升資料閱讀的視覺體驗

#### 4.3 功能頁面 (TabPages)
**路徑：** `Views/TabPages/`

##### [AddMealView.swift](https://github.com/yolo-cat/1133-iOS-NutritionTracker/blob/main/NuTrackDemo03/Views/TabPages/AddMealView.swift)
```swift
struct AddMealView: View {
    @State private var selectedMealType: MealType = .breakfast
    @State private var searchText = ""
    @State private var selectedFoods: [MealItem] = []
    
    let onMealAdded: (FoodLogEntry) -> Void
}
```

**功能特點：**
- **食物搜尋：** 實作食物搜尋和篩選功能
- **餐點分類：** 提供早餐/午餐/晚餐的分類選擇
- **批次選擇：** 支援多種食物的批次新增
- **即時反饋：** 提供即時的營養資訊計算

##### [DiaryView.swift](https://github.com/yolo-cat/1133-iOS-NutritionTracker/blob/main/NuTrackDemo03/Views/TabPages/DiaryView.swift)
```swift
struct DiaryView: View {
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    
    // 飲食日記的歷史檢視功能
}
```

**功能特點：**
- **歷史記錄：** 檢視過往任何日期的飲食記錄
- **日期選擇：** 直觀的日期選擇介面
- **統計概覽：** 週統計和趨勢展示
- **詳細分析：** 單日詳細營養分解

##### [SettingsView.swift](https://github.com/yolo-cat/1133-iOS-NutritionTracker/blob/main/NuTrackDemo03/Views/TabPages/SettingsView.swift)
```swift
struct SettingsView: View {
    @State private var dailyCalorieGoal = 1973
    @State private var carbsGoal = 120
    @State private var proteinGoal = 180
    // 各種設定選項
}
```

**功能特點：**
- **目標設定：** 個人化營養目標配置
- **通知管理：** 提醒和通知偏好設定
- **單位選擇：** 公制/英制單位切換
- **資料管理：** 備份、重置等資料操作

##### [TrendsView.swift](https://github.com/yolo-cat/1133-iOS-NutritionTracker/blob/main/NuTrackDemo03/Views/TabPages/TrendsView.swift)
```swift
struct TrendsView: View {
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: NutritionMetric = .calories
    
    // 趨勢分析和圖表展示
}
```

**功能特點：**
- **趨勢分析：** 長期營養攝取趨勢分析
- **圖表展示：** 視覺化的資料呈現
- **時間範圍：** 靈活的時間區間選擇
- **多維度分析：** 卡路里、碳水化合物、蛋白質等多角度分析

## 🎯 架構設計模式

### MVVM 架構實現
```
📱 View Layer (SwiftUI Views)
    ↕️ @State, @Binding, @ObservedObject
🧠 ViewModel Layer (State Management)
    ↕️ Business Logic & Data Processing  
📊 Model Layer (Data Structures)
```

### 組件化設計原則
```
🔄 可重用組件 (Components/)
├── CustomTabView - 自定義導航組件
├── TodayFoodLogView - 食物記錄展示組件
└── [更多組件] - 其他可重用 UI 元素

📄 頁面組件 (TabPages/)
├── AddMealView - 新增餐點功能頁
├── DiaryView - 歷史記錄頁面
├── SettingsView - 設定配置頁面
└── TrendsView - 數據分析頁面
```

### 資料流架構
```
用戶輸入 → View State → Model Update → UI Refresh
    ↑                                        ↓
    ←←←←←← Animation & Feedback ←←←←←←←←←←←←←←
```

## 🔧 技術特點與優勢

### 1. SwiftUI 現代化開發
- **宣告式語法：** 使用 SwiftUI 的宣告式程式設計範式
- **狀態驅動：** 透過 `@State` 實現響應式 UI 更新
- **組合式架構：** 高度模組化的視圖組件設計
- **跨平台相容：** 可輕鬆適配 iOS、macOS 等平台

### 2. 型別安全設計
- **強型別系統：** 利用 Swift 的型別系統防止程式錯誤
- **枚舉使用：** `MealType` 等枚舉確保資料一致性
- **協定導向：** 使用 `Identifiable` 等協定增強功能性
- **泛型支援：** 提供靈活且安全的資料處理

### 3. 效能最佳化
- **惰性載入：** 使用 `LazyVStack` 優化大量資料顯示
- **狀態管理：** 精確控制視圖重建時機
- **記憶體效率：** 值型別設計減少記憶體洩漏風險
- **動畫最佳化：** 使用 Core Animation 提供流暢體驗

## 📈 擴展性與維護性

### 1. 水平擴展能力
- **新增功能頁面：** 在 `TabPages/` 輕鬆添加新分頁
- **組件庫擴展：** 在 `Components/` 建立更多可重用組件
- **資料模型擴展：** 在 `Models/` 增加新的資料結構
- **測試覆蓋擴展：** 在測試層添加更完整的測試案例

### 2. 垂直整合準備
```swift
// 未來整合可能性
📡 Network Layer     - API 整合、雲端同步
💾 Persistence Layer - Core Data、SQLite
🔔 Notification Layer - 本地通知、推送通知
📊 Analytics Layer   - 使用者行為分析
```

### 3. 第三方整合空間
```swift
// 潛在整合點
🍎 HealthKit        - 健康資料整合
☁️ CloudKit/Firebase - 雲端資料同步  
📈 Charts Framework - 進階圖表功能
🤖 Core ML         - 食物識別 AI
```

## 📚 學習價值與建議

### 對 iOS 初學者：
1. **SwiftUI 基礎：** 學習現代 iOS UI 開發框架
2. **狀態管理：** 理解響應式程式設計概念
3. **資料建模：** 學習結構化資料設計
4. **組件化思維：** 培養模組化開發思維

### 對進階開發者：
1. **架構設計：** 研究 MVVM 在 SwiftUI 中的實現
2. **效能優化：** 分析大型應用的效能最佳化策略
3. **測試策略：** 學習 UI 測試和效能測試的最佳實踐
4. **可維護性：** 理解長期可維護的程式碼組織方式

## 🎨 設計哲學

### 單一責任原則
- 每個檔案專注於特定功能領域
- 清晰的介面定義和職責分離
- 高內聚、低耦合的設計原則

### 開放封閉原則  
- 對擴展開放：易於添加新功能和組件
- 對修改封閉：核心架構穩定不變
- 插件式架構支援功能模組化

### 依賴倒置原則
- 高層模組不依賴低層模組
- 抽象介面定義清晰的邊界
- 便於單元測試和模組替換

這個專案展示了現代 iOS 開發的最佳實踐，結構清晰、可維護性高，是學習 SwiftUI 和應用程式架構設計的優秀範例！

---
*注意：搜尋結果可能不完整，如需查看更多檔案結構詳情，請參考 [GitHub 程式碼搜尋](https://github.com/yolo-cat/1133-iOS-NutritionTracker/search?type=code)*

# 總體計畫：建立 SwiftData 持久層與個人化服務

本文檔旨在詳細記錄將 `NuTrackDemo03` 專案從既有的資料結構，全面升級至以 **SwiftData** 為核心，並包含 **個人化建議服務** 的現代化架構。

---

## 第一部分：建立 SwiftData 模型 (資料庫地基)

此階段的核心目標是建立資料庫的「綱要 (Schema)」，定義我們需要儲存哪些資料，以及資料之間的關聯。

### 1.1. 核心模型

- **`UserProfile`**: 代表一個獨立的使用者，儲存其個人資料（如體重）與最終由使用者確認的營養目標。
- **`MealEntry`**: 代表一筆具體的餐點記錄事件。

### 1.2. 模型關係

- **一對多 (One-to-Many)**: 一個 `UserProfile` 可以擁有 多筆 `MealEntry`。

### 1.3. 執行步驟

#### 步驟 1: 更新 `UserProfile` 模型

此模型現在需要包含 `weightInKg` 以支援個人化計算。

```swift
// /Models/UserProfile.swift

import Foundation
import SwiftData

@Model
final class UserProfile {
    @Attribute(.unique) var id: UUID
    var name: String
    
    // 新增：儲存使用者的體重，可選(nil)代表尚未填寫
    var weightInKg: Double? 
    
    // 目標值：這些值最終將由使用者根據建議自行設定
    var dailyCalorieGoal: Int
    var dailyCarbsGoal: Int
    var dailyProteinGoal: Int
    var dailyFatGoal: Int

    // init 中的預設值，作為使用者完成個人化設定前的「初始值」
    init(id: UUID = UUID(),
         name: String,
         weightInKg: Double? = nil, // 體重可以在建立後再補上
         dailyCalorieGoal: Int = 2000,
         dailyCarbsGoal: Int = 250,
         dailyProteinGoal: Int = 125,
         dailyFatGoal: Int = 56) {
        
        self.id = id
        self.name = name
        self.weightInKg = weightInKg
        self.dailyCalorieGoal = dailyCalorieGoal
        self.dailyCarbsGoal = dailyCarbsGoal
        self.dailyProteinGoal = dailyProteinGoal
        self.dailyFatGoal = dailyFatGoal
    }
}
```

#### 步驟 2: 建立 `MealEntry` 模型

```swift
// /Models/MealEntry.swift

import Foundation
import SwiftData

@Model
final class MealEntry {
    @Attribute(.unique) var id: UUID
    var timestamp: Date
    var carbs: Int
    var protein: Int
    var fat: Int
    
    var calories: Int {
        return (carbs * 4) + (protein * 4) + (fat * 9)
    }
    
    var user: UserProfile?
    
    init(id: UUID = UUID(), timestamp: Date = .now, carbs: Int, protein: Int, fat: Int) {
        self.id = id
        self.timestamp = timestamp
        self.carbs = carbs
        self.protein = protein
        self.fat = fat
    }
}
```

#### 步驟 3: 設定 App 的 Model Container

```swift
// NuTrackDemo03App.swift

import SwiftUI
import SwiftData

@main
struct NuTrackDemo03App: App {
    var body: some Scene {
        WindowGroup {
            SimpleLoginView() 
        }
        .modelContainer(for: [UserProfile.self, MealEntry.self])
    }
}
```

---

## 第二部分：重構核心服務 (個人化計算)

此階段的目標是將現有的計算邏輯 (`Extensions/WeightCalculations.swift`)，徹底重構至一個全新的、權責單一的服務 `NutritionCalculatorService` 中。

### 2.1. 重構策略：一步到位 (Rip & Replace)

我們將採用最徹底的重構方式，直接以新服務取代舊的實作，確保架構的清晰與一致性。

### 2.2. 執行步驟

#### 步驟 1: 建立整合式的 `NutritionCalculatorService`

建立新檔案 `/Services/NutritionCalculatorService.swift`。此單一檔案將包含計算服務所需的一切，包括其回傳的資料結構 `RecommendationRange`，以提高功能的內聚性。

```swift
// /Services/NutritionCalculatorService.swift

import Foundation

// 資料結構與服務邏輯整合在同一個檔案中
struct RecommendationRange {
    let min: Int
    let max: Int
    let suggested: Int
}

struct NutritionCalculatorService {

    static func getProteinRecommendation(weightInKg: Double) -> RecommendationRange {
        let minGramsPerKg = 1.6
        let maxGramsPerKg = 2.2
        let suggestedGramsPerKg = 1.8

        return RecommendationRange(
            min: Int(weightInKg * minGramsPerKg),
            max: Int(weightInKg * maxGramsPerKg),
            suggested: Int(weightInKg * suggestedGramsPerKg)
        )
    }

    static func getFatRecommendation(weightInKg: Double) -> RecommendationRange {
        let minGramsPerKg = 0.8
        let maxGramsPerKg = 1.2
        let suggestedGramsPerKg = 1.0

        return RecommendationRange(
            min: Int(weightInKg * minGramsPerKg),
            max: Int(weightInKg * maxGramsPerKg),
            suggested: Int(weightInKg * suggestedGramsPerKg)
        )
    }
    
    static func getCarbsRecommendation(proteinGoal: Int, fatGoal: Int, calorieGoal: Int) -> RecommendationRange {
        let proteinCalories = proteinGoal * 4
        let fatCalories = fatGoal * 9
        let carbsCalories = calorieGoal - proteinCalories - fatCalories
        let suggestedCarbs = max(0, carbsCalories / 4)
        
        return RecommendationRange(
            min: Int(Double(suggestedCarbs) * 0.9),
            max: Int(Double(suggestedCarbs) * 1.1),
            suggested: suggestedCarbs
        )
    }
}
```

#### 步驟 2: 全域搜尋並替換

1.  使用 Xcode 的全域搜尋功能 (Cmd+Shift+F)。
2.  搜尋所有在 `Extensions/WeightCalculations.swift` 中定義的舊方法名稱。
3.  將每一個找到的呼叫點，手動修改為對 `NutritionCalculatorService` 中對應新方法的呼叫。

#### 步驟 3: 刪除舊有實作

1.  在確認所有呼叫點都已成功替換後，**刪除 `Extensions/WeightCalculations.swift` 檔案**。
2.  如果 `Extensions` 資料夾已空，也一併將其刪除。

---

## 第三部分：使用者操作流程

重構完成後，建議的 UI 流程如下：

1.  **登入後檢查**：檢查 `userProfile.weightInKg` 是否有值。
2.  **引導設定**：若無，則引導使用者到設定頁面輸入體重。
3.  **計算與呈現**：呼叫 `NutritionCalculatorService` 取得建議範圍，並在 UI 上透過滑桿 (Slider) 等元件呈現給使用者。
4.  **儲存自訂目標**：使用者調整並確認後，將最終值儲存回 `userProfile` 的目標欄位中。

# 首次登入偵測與使用者設置流程實施報告

## 📋 需求說明

**原始需求（中文）：** 偵測使用者首次登入時，先進入UserProfileView設置基本資料。若不是首次登入，則直接進入NewNutritionTrackerView

**需求翻譯：** Detect when a user logs in for the first time, and first enter UserProfileView to set up basic information. If it's not their first login, go directly to NewNutritionTrackerView.

## 🎯 實施目標

1. **自動偵測首次使用者**：根據使用者資料完整性判斷是否為首次登入
2. **引導初始設置**：首次使用者必須完成基本資料設置才能進入主要功能
3. **無縫使用者體驗**：回訪使用者直接進入營養追蹤主界面
4. **最小化程式碼修改**：保持現有功能完整性，僅添加必要的流程控制

## 🔧 技術實施方案

### 1. 首次使用者偵測邏輯

**判斷條件：** `UserProfile.weightInKg == nil`

**邏輯說明：**
- 新建立的使用者帳號中，`weightInKg` 預設為 `nil`
- 完成初始設置後，此欄位會被設定為實際數值
- 使用此欄位作為判斷依據，確保設置流程只會執行一次

```swift
private var isFirstTimeUser: Bool {
    return user.weightInKg == nil
}
```

### 2. 應用程式流程控制

**修改檔案：** `NuTrackDemo03App.swift` - `MainAppView`

**流程邏輯：**
```
使用者登入 → 檢查 user.weightInKg
├── 如果 == nil → 顯示 UserProfileSetupView
└── 如果 != nil → 顯示 NewNutritionTrackerView
```

**程式碼實施：**
```swift
var body: some View {
    Group {
        if isFirstTimeUser {
            UserProfileSetupView(user: user) {
                // 完成設置後，隱藏設置界面
                showProfileSetup = false
            }
        } else {
            NewNutritionTrackerView(user: user)
        }
    }
    // ... 其他邏輯
}
```

### 3. 使用者設置界面

**新建檔案：** `UserProfileSetupView.swift`

**功能特點：**
- **體重輸入**：支援小數點，範圍驗證（30.0-300.0 kg）
- **營養目標設置**：可調整碳水化合物、蛋白質、脂肪目標
- **即時計算**：自動計算並顯示總熱量目標
- **資料驗證**：完整的輸入驗證和錯誤提示
- **SwiftData整合**：直接更新並保存UserProfile資料

**界面組件：**
1. 歡迎訊息區塊（個人化問候）
2. 體重輸入區塊（含範圍提示）
3. 營養目標設置區塊（滑桿控制）
4. 總熱量顯示區塊
5. 完成設置按鈕

## 📊 實施測試結果

### 邏輯驗證測試

```
Test 1 - New user (no weight): ✅ PASS
Test 2 - Existing user (has weight): ✅ PASS  
Test 3 - User with 0.0 weight: ✅ PASS
```

### 流程驗證

1. **新使用者流程：**
   - 登入 → 偵測 `weightInKg == nil` → 顯示設置界面
   - 完成設置 → 更新 `UserProfile` → 進入營養追蹤界面

2. **回訪使用者流程：**
   - 登入 → 偵測 `weightInKg != nil` → 直接顯示營養追蹤界面

## 🔒 資料完整性保障

### 設置完成檢查點

完成設置時會更新以下 UserProfile 欄位：
- `weightInKg`: 使用者輸入的體重值
- `dailyCarbsGoal`: 碳水化合物目標
- `dailyProteinGoal`: 蛋白質目標  
- `dailyFatGoal`: 脂肪目標
- `dailyCalorieGoal`: 計算得出的總熱量目標

### 資料持久化

使用 SwiftData 的 `modelContext.save()` 確保資料正確保存到本地資料庫。

## 📝 使用者體驗設計

### 視覺設計原則

- **一致性**：沿用應用程式既有的設計語言和色彩主題
- **清晰性**：每個設置步驟都有明確的說明和視覺回饋
- **引導性**：透過漸進式表單引導使用者完成設置

### 互動設計

- **即時驗證**：體重範圍即時檢查，按鈕狀態即時更新
- **視覺回饋**：滑桿調整時即時顯示數值和熱量變化
- **錯誤處理**：友善的錯誤訊息和重試機制

## 🚀 部署與維護

### 檔案修改清單

1. **修改檔案：**
   - `NuTrackDemo03App.swift` - 增加首次使用者檢查邏輯

2. **新增檔案：**
   - `UserProfileSetupView.swift` - 首次設置界面

### 向後相容性

- 既有使用者資料結構保持不變
- 現有功能完全保留，無破壞性修改
- 漸進式部署，不影響現有使用者體驗

### 未來擴展性

此實施為基礎架構提供了良好的擴展空間：
- 可輕鬆添加更多初始設置項目
- 支援多步驟設置流程
- 可依據業務需求調整首次使用者的判斷邏輯

## ✅ 實施完成確認

- [x] 首次使用者偵測邏輯實施完成
- [x] 使用者設置界面開發完成
- [x] 應用程式流程控制修改完成
- [x] 邏輯測試驗證通過
- [x] 技術文件撰寫完成

## 🎉 結論

此次實施成功達成了所有需求目標：

1. **準確偵測**：使用 `weightInKg == nil` 作為首次使用者判斷標準
2. **完整設置**：提供友善的初始設置界面，包含所有必要資料收集
3. **流暢體驗**：確保首次和回訪使用者都有適當的使用流程
4. **最小修改**：僅修改必要檔案，保持程式碼架構整潔

實施結果符合原始需求，為NuTrack應用程式提供了更好的使用者入門體驗。
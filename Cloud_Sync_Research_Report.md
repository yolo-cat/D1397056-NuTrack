
# 雲端同步方案研究報告：CloudKit vs. Supabase

## 1. 需求背景

為了提升 NuTrack 的價值並擴大使用者基礎，我們需要引入雲端同步功能，以滿足以下核心需求：
- **跨裝置同步 (Cross-Device Sync):** 使用者在 iPhone 上記錄的資料，應能無縫同步到他們的 iPad 或 Mac 電腦上。
- **跨平台支援 (Cross-Platform Support):** 為未來將 NuTrack 擴展到 Android 或 Web 平台預留可能性。
- **資料備份與恢復:** 使用者的寶貴健康資料應有雲端備份，避免因更換或遺失裝置而導致資料丟失。

本報告將評估 Apple CloudKit 和 Supabase 這兩個主流後端服務，並基於此提出三種不同的技術整合方案。

---

## 2. 核心技術評估

### Apple CloudKit

CloudKit 是 Apple 官方的後端即服務 (BaaS)，深度整合在 Apple 的生態系統中。

**優點 (Pros):**
- **與 SwiftData 完美整合:** 對於已使用 SwiftData 的專案，開啟 CloudKit 同步只需極少的程式碼。Apple 處理了絕大部分複雜的同步、合併和衝突解決邏輯。
- **無縫的使用者認證:** 自動使用裝置上登入的 iCloud 帳號，使用者無需額外註冊或登入，體驗極其順暢。
- **成本效益高:** 對於私有使用者資料，免費額度非常慷慨（與使用者的 iCloud 儲存空間掛鉤），對於絕大多數獨立開發者和中小型應用來說幾乎是免費的。
- **高度安全與隱私:** 資料儲存在 Apple 的伺服器上，享有與 iCloud 同等級別的安全和隱私保護，容易獲得使用者信任。

**缺點 (Cons):**
- **平台鎖定:** 這是其最大的缺點。CloudKit 主要服務於 Apple 生態（iOS, iPadOS, macOS, watchOS）。雖然有提供用於 Web 的 `CloudKit.js`，但功能有限且整合複雜，沒有官方的 Android SDK。
- **後端靈活性低:** 作為一個「黑盒」服務，開發者對後端環境的控制力較小，資料庫查詢能力不如傳統 SQL 資料庫強大。

### Supabase

Supabase 是一個開源的 Firebase 替代品，它將多個強大的開源工具（如 PostgreSQL, PostgREST, GoTrue 等）整合為一個統一的後端服務。

**優點 (Pros):**
- **真正的跨平台:** 提供適用於 Swift (iOS), Kotlin (Android), JavaScript (Web) 等多種語言的官方 SDK，是實現跨平台目標的理想選擇。
- **強大的資料庫:** 底層是功能完整的 PostgreSQL 資料庫，支援複雜的 SQL 查詢、關聯和事務，給予開發者極大的數據操作自由度。
- **開源與無鎖定:** 核心是開源的，如果未來有需要，可以將其遷移到自己的伺服器上進行私有化部署，避免被單一供應商綁定。
- **豐富的功能:** 除了資料庫，還內建了使用者認證、檔案儲存、邊緣函式 (Edge Functions) 等多種功能。

**缺點 (Cons):**
- **與 SwiftData 無法自動整合:** 你需要手動編寫所有同步邏輯。這包括將 SwiftData 模型對應到 PostgreSQL 表、處理網路請求、監聽遠端變更、解決資料衝突等，開發工作量遠大於 CloudKit。
- **需要獨立的使用者認證:** 使用者需要為 App 建立一個獨立的帳號（或使用第三方登入，如 Sign in with Apple），相較於 iCloud 自動登入，多了一個步驟。
- **成本模型:** 免費方案有一定限制，當使用者和資料量增長後，需要根據實際用量付費，成本可能高於 CloudKit。

---

## 3. 三種整合方案設計

### 方案一：Apple 生態系優先 (Apple Ecosystem First Approach)

此方案專注於為 Apple 使用者提供最極致、最無縫的體驗，暫不考慮非 Apple 平台。

- **核心技術:** **SwiftData + CloudKit**
- **實作思路:**
    1. 在 Xcode 的專案設定中，為 App 啟用 `iCloud` 能力，並選中 `CloudKit`。
    2. 在 App 的 `schema.xcdatamodeld` 中，為需要同步的 `UserProfile` 和 `MealEntry` 選擇一個 CloudKit 配置。
    3. 修改 `ModelContainer` 的初始化，啟用 CloudKit 同步。這通常只需要一行程式碼的改動。
        ```swift
        // 從
        let container = try ModelContainer(for: UserProfile.self, MealEntry.self)
        // 改為
        let container = try ModelContainer(for: UserProfile.self, MealEntry.self, configurations: ModelConfiguration(cloudKitDatabase: .automatic))
        ```
    4. Apple 的框架會自動處理後續所有的同步工作。

- **優點:**
    - **開發速度極快:** 幾行程式碼就能實現強大的跨裝置同步。
    - **使用者體驗最佳:** 無需額外登入，同步在背景自動發生。
    - **成本極低，穩定性高。**

- **缺點:**
    - **完全放棄非 Apple 平台:** 未來若要支援 Android，幾乎需要重寫整個後端和同步邏輯。

- **適用場景:**
    - 明確只服務 Apple 生態的精品應用。
    - 專案初期，希望以最小成本快速驗證市場，並提供頂級原生體驗。

### 方案二：跨平台優先 (Cross-Platform First Approach)

此方案將支援 Android 和 Web 作為核心目標，願意為此投入更多的開發資源。

- **核心技術:** **Supabase + SwiftData (作為本地快取)**
- **實作思路:**
    1. 在 Supabase 平台上建立專案，並設計與 `UserProfile`, `MealEntry` 對應的 PostgreSQL 資料表。
    2. 在 iOS App 中整合 `Supabase-swift` SDK。
    3. **將 SwiftData 的角色從「單一事實來源」降級為「離線本地快取」**。雲端的 Supabase 資料庫才是唯一的「單一事實來源」。
    4. 建立一個 `SyncService` 或 `Repository` 層，負責：
        - **使用者認證:** 實現註冊、登入（可整合 Sign in with Apple）。
        - **上傳:** 監聽本地 SwiftData 的變更（例如，使用 `NotificationCenter`），並將變更推送到 Supabase。
        - **下載:** 使用 Supabase 的 Realtime 功能訂閱遠端資料庫的變更，並將這些變更寫入到本地的 SwiftData 快取中。
        - **首次同步:** App 啟動時，從 Supabase 拉取最新資料以填充本地資料庫。

- **優點:**
    - **真正的跨平台能力:** 一旦完成，可以輕鬆地將同樣的邏輯應用到 Android 和 Web 客戶端。
    - **後端功能強大靈活。**

- **缺點:**
    - **開發複雜度劇增:** 需要手動處理網路、認證、衝突解決、離線支援等所有同步細節。
    - **使用者體驗稍損:** 需要額外的註冊/登入流程。

- **適用場景:**
    - 產品從一開始就有明確的跨平台戰略。
    - 團隊具備處理複雜後端同步邏輯的開發能力。

### 方案三：混合與抽象層策略 (Hybrid & Abstraction Layer Strategy)

此方案是專業軟體架構的體現，它追求**靈活性**和**未來適應性**，旨在將應用程式邏輯與特定的後端技術解耦。

- **核心技術:** **協定 (Protocol) + 依賴注入 (Dependency Injection)**
- **實作思路:**
    1. **定義抽象層:** 建立一個 `NutritionRepository` 協定，定義所有資料操作的介面，不關心其底層如何實現。
        ```swift
        protocol NutritionRepository {
            func getTodaysEntries() async throws -> [MealEntry]
            func saveEntry(_ entry: MealEntry) async throws
            func deleteEntry(_ entry: MealEntry) async throws
            // ... 其他介面
        }
        ```
    2. **讓 App 依賴於抽象:** 所有的 View 和業務邏輯，都只與 `NutritionRepository` 這個協定互動，而不知道具體是 CloudKit 還是 Supabase 在工作。
    3. **建立具體實現:**
        - `CloudKitRepository`: 遵循 `NutritionRepository` 協定，其內部使用方案一的邏輯（SwiftData + CloudKit 自動同步）來實現。
        - `SupabaseRepository`: 遵循 `NutritionRepository` 協定，其內部使用方案二的邏輯（呼叫 Supabase API）來實現。
    4. **依賴注入:** 在 App 啟動時，根據需要決定要使用哪個 Repository 的實例，並將其注入到需要它的地方。

- **優點:**
    - **極度靈活:** 未來可以輕易地從 CloudKit 遷移到 Supabase（或任何其他後端），只需替換掉具體的 Repository 實現，而無需改動大量的上層 UI 和業務邏輯。
    - **可測試性極高:** 在進行單元測試時，可以建立一個 `MockRepository`，輕鬆模擬各種網路和資料庫場景。
    - **關注點分離:** UI 層、業務邏輯層、資料持久層的職責非常清晰。

- **缺點:**
    - **初期架設複雜:** 需要預先設計好抽象層，對架構設計能力有一定要求。

- **適用場景:**
    - 長期維護的大型專案。
    - 對程式碼品質、可測試性和未來擴展性有高要求的團隊。
    - 專案初期不確定最終後端選型，希望保留未來選擇的權利。

---

## 4. 總結與建議

| 方案 | 開發難度 | 跨平台能力 | 使用者認證 | 維護成本 | 最佳使用情境 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **一：生態優先** | **低** | **無** (僅 Apple) | **極佳** (iCloud) | 低 | 快速開發，專注 Apple 生態的精品應用。 |
| **二：跨平台優先** | **高** | **極佳** | **良好** (需註冊) | 高 | 跨平台是核心商業目標。 |
| **三：抽象層策略** | **中等** | **極佳** | (取決於實現) | 中等 | 長期專案，追求架構的靈活性與健壯性。 |

### **建議**

對於 NuTrack 目前的階段，我提出以下建議路徑：

1.  **短期 (現在):** 採用 **方案一 (Apple 生態系優先)**。這能以最低的成本、最快的速度為現有使用者帶來極具價值的跨裝置同步功能，並能快速驗證市場反應。
2.  **長期 (未來):** 在開發過程中，**心中想著方案三的架構**。盡量將資料操作的邏輯與 View 分離（例如，透過我們之前討論的 Service 或 Repository 模式），即使一開始的實現是基於 CloudKit 的。
3.  **轉折點:** 如果未來某個時間點，進軍 Android/Web 的需求變得明確且迫切，由於你已經有了一個相對分離的架構，屆時再投入資源開發 `SupabaseRepository` 來替換或並行 `CloudKitRepository`，將會是一個平滑得多的過渡。

這個路徑兼顧了當前的開發效率和長期的架構彈性。

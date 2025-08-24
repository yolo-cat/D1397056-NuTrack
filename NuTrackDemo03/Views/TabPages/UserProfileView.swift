//
//  UserProfileView.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2025/1/15.
//

import SwiftUI
import SwiftData

struct UserProfileView: View {
    @Bindable var user: UserProfile
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    
    // 是否為首次登入導流到設定頁
    private let isFirstLogin: Bool
    // 首次登入完成時回呼（由 App 入口決定是否提供）
    private let onCompleteSetup: (() -> Void)?
    // 登出回呼
    private let onLogout: () -> Void
    
    // --- Local State for UI controls ---
    @State private var weightInput: String
    @State private var carbsSliderValue: Double
    @State private var proteinSliderValue: Double
    @State private var fatSliderValue: Double
    
    @FocusState private var isWeightFieldFocused: Bool
    
    @State private var showWeightValidationError = false
    @State private var isShowingDeleteAlert = false

    // --- Initializer ---
    init(user: UserProfile, isFirstLogin: Bool? = nil, onCompleteSetup: (() -> Void)? = nil, onLogout: @escaping () -> Void = {}) {
        self.user = user
        self.isFirstLogin = isFirstLogin ?? (user.weightInKg == nil)
        self.onCompleteSetup = onCompleteSetup
        self.onLogout = onLogout
        // Initialize state from the user model
        self._weightInput = State(initialValue: String(format: "%.1f", user.weightInKg ?? 70.0))
        self._carbsSliderValue = State(initialValue: Double(user.dailyCarbsGoal))
        self._proteinSliderValue = State(initialValue: Double(user.dailyProteinGoal))
        self._fatSliderValue = State(initialValue: Double(user.dailyFatGoal))
    }

    // --- Computed Properties for Dynamic Calculation ---
    private var totalCalories: Int {
        NutritionCalculatorService.calculateTotalCalories(
            carbs: carbsSliderValue,
            protein: proteinSliderValue,
            fat: fatSliderValue
        )
    }
    
    private var currentWeight: Double {
        Double(weightInput) ?? user.weightInKg ?? 70.0
    }
    
    private var isValidWeight: Bool {
        guard let w = Double(weightInput) else { return false }
        return w >= 30.0 && w <= 300.0
    }

    // --- Main Body ---
    var body: some View {
        ZStack {
            // 1. Unified background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.backgroundGray.opacity(0.3),
                    Color.primaryBlue.opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 30) {
                    // 2. Componentized UI
                    headerView
                    if isFirstLogin { welcomeSection }
                    userAvatarSection
                    weightInputSection
                    nutritionGoalsSection // Renamed from nutritionSlidersSection for clarity
                    totalCaloriesSection
                    
                    if !isFirstLogin {
                        deleteAccountSection
                            .padding(.top, 20)
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .scrollDismissesKeyboard(.immediately) // Improved keyboard handling
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("完成") {
                            isWeightFieldFocused = false
                        }
                    }
                }
            }
        }
        .onTapGesture {
            isWeightFieldFocused = false
        }
        .navigationBarHidden(true)
        .alert("體重無效", isPresented: $showWeightValidationError) {
            Button("確定", role: .cancel) {}
        } message: {
            Text("請輸入有效的體重範圍 (30.0 - 300.0 公斤)。")
        }
        .alert("確定要刪除帳號嗎？", isPresented: $isShowingDeleteAlert) {
            Button("確認刪除", role: .destructive, action: deleteUser)
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作將永久刪除您的所有資料，包含餐點紀錄，且無法復原。")
        }
        .onAppear {
            // 首次登入預先套用建議值
            if isFirstLogin { updateGoalsForWeight(forceApply: true) }
        }
        .onChange(of: weightInput) { _, _ in
            // 體重變更時：首次登入自動套用建議；非首次僅更新範圍，不覆蓋使用者設定
            updateGoalsForWeight(forceApply: isFirstLogin)
        }
    }

    // MARK: - UI Components
    
    private var headerView: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primaryBlue)
            }
            Spacer()
            Text(isFirstLogin ? "設置基本資料" : "用戶設置")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primaryBlue)
            Spacer()
            Button(isFirstLogin ? "完成" : "保存", action: saveSettings)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primaryBlue)
        }
    }
    
    private var welcomeSection: some View {
        VStack(spacing: 8) {
            Text("歡迎使用 NuTrack，\(user.name)！")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primaryBlue)
                .multilineTextAlignment(.center)
            Text("請先設置您的基本資料與每日營養目標")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.primaryBlue.opacity(0.08))
        .cornerRadius(12)
    }
    
    private var userAvatarSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(Color.primaryBlue.opacity(0.8))
            
            Text(user.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }
    
    private var weightInputSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("體重 (kg)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack {
                TextField("輸入體重", text: $weightInput)
                    .font(.system(size: 20, weight: .bold))
                    .keyboardType(.decimalPad)
                    .focused($isWeightFieldFocused)
                    .submitLabel(.done)
                    .onSubmit { isWeightFieldFocused = false }
                    .padding(15)
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                Text("kg")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            if showWeightValidationError || (!isValidWeight && isFirstLogin) {
                Text("請輸入有效的體重 (30.0 - 300.0)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .transition(.opacity.animation(.easeIn))
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.5))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var nutritionGoalsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("每日營養目標 (g)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            NutritionSliderView(
                label: "碳水化合物",
                value: $carbsSliderValue,
                recommendation: NutritionCalculatorService.getCarbsRecommendation(weightInKg: currentWeight),
                color: .carbsColor,
                disabled: !isValidWeight
            )
            
            NutritionSliderView(
                label: "蛋白質",
                value: $proteinSliderValue,
                recommendation: NutritionCalculatorService.getProteinRecommendation(weightInKg: currentWeight),
                color: .proteinColor,
                disabled: !isValidWeight
            )
            
            NutritionSliderView(
                label: "脂肪",
                value: $fatSliderValue,
                recommendation: NutritionCalculatorService.getFatRecommendation(weightInKg: currentWeight),
                color: .fatColor,
                disabled: !isValidWeight
            )
            
            if !isValidWeight {
                Text("請先輸入有效體重以取得建議與啟用滑桿")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.5))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var totalCaloriesSection: some View {
        VStack(spacing: 10) {
            Text("預估總熱量")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(totalCalories)")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.primaryBlue)
            
            Text("KCAL")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color.white.opacity(0.5))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var deleteAccountSection: some View {
        Button(role: .destructive) {
            isShowingDeleteAlert = true
        } label: {
            Label("刪除帳號", systemImage: "trash.fill")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .foregroundColor(.red)
                .cornerRadius(12)
        }
    }
    
    // MARK: - Helper Functions
    
    private func saveSettings() {
        guard let weight = Double(weightInput), isValid(weight: weight) else {
            showWeightValidationError = true
            return
        }
        
        showWeightValidationError = false
        
        // Directly modify the bindable user object. SwiftData handles the save.
        user.weightInKg = weight
        user.dailyCarbsGoal = Int(carbsSliderValue)
        user.dailyProteinGoal = Int(proteinSliderValue)
        user.dailyFatGoal = Int(fatSliderValue)
        user.dailyCalorieGoal = totalCalories
        
        // 儲存至資料庫
        try? modelContext.save()
        
        // 首次登入完成 -> 回呼；一般情況 -> 關閉
        if let onCompleteSetup {
            onCompleteSetup()
        } else {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func isValid(weight: Double) -> Bool {
        weight >= 30.0 && weight <= 300.0
    }
    
    private func deleteUser() {
        modelContext.delete(user)
        do {
            try modelContext.save()
            // Call the logout callback to trigger view switch in the main App
            onLogout()
        } catch {
            // For production, you might want to show an error alert to the user
            print("Failed to delete user and save context: \(error)")
        }
    }
    
    private func updateGoalsForWeight(forceApply: Bool) {
        guard isValidWeight, let w = Double(weightInput) else { return }
        let p = NutritionCalculatorService.getProteinRecommendation(weightInKg: w).suggested
        let f = NutritionCalculatorService.getFatRecommendation(weightInKg: w).suggested
        let c = NutritionCalculatorService.getCarbsRecommendation(weightInKg: w).suggested
        if forceApply || (carbsSliderValue == 0 && proteinSliderValue == 0 && fatSliderValue == 0) {
            proteinSliderValue = Double(p)
            fatSliderValue = Double(f)
            carbsSliderValue = Double(c)
        }
    }
}

// MARK: - Child View for Nutrition Slider
struct NutritionSliderView: View {
    let label: String
    @Binding var value: Double
    let recommendation: RecommendationRange
    let color: Color
    var disabled: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(value)) g")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Slider(value: $value, in: Double(recommendation.min)...Double(recommendation.max), step: 1)
                .tint(color)
                .disabled(disabled)
            
            HStack {
                Text("建議: \(recommendation.suggested)g")
                Spacer()
                Text("範圍: \(recommendation.min) - \(recommendation.max)g")
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
    }
}


// MARK: - Preview
#Preview {
    // Create an in-memory container for previewing
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    
    // Create a sample user and set initial goals
    let sampleUser = UserProfile(name: "測試用戶", weightInKg: 72.5)
    sampleUser.dailyCarbsGoal = 250
    sampleUser.dailyProteinGoal = 150
    sampleUser.dailyFatGoal = 60
    sampleUser.dailyCalorieGoal = 2140
    
    container.mainContext.insert(sampleUser)
    
    return UserProfileView(user: sampleUser, onLogout: { print("Preview logout action") })
        .modelContainer(container)
}

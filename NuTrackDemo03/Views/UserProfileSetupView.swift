//
//  UserProfileSetupView.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2025/1/15.
//

import SwiftUI
import SwiftData

/// 首次使用者設置基本資料的界面
struct UserProfileSetupView: View {
    let user: UserProfile
    let onSetupComplete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var weightInput: String = ""
    @FocusState private var isWeightFieldFocused: Bool
    @State private var carbsGoal: Double = 0
    @State private var proteinGoal: Double = 0
    @State private var fatGoal: Double = 0
    @State private var showValidationError = false
    @State private var errorMessage = ""
    
    private var isValidWeight: Bool {
        guard let weight = Double(weightInput), weight >= 30.0, weight <= 300.0 else {
            return false
        }
        return true
    }
    
    // 根據輸入體重動態取得建議範圍
    private var weightValue: Double? { Double(weightInput) }
    private var proteinRec: RecommendationRange? {
        guard isValidWeight, let w = weightValue else { return nil }
        return NutritionCalculatorService.getProteinRecommendation(weightInKg: w)
    }
    private var fatRec: RecommendationRange? {
        guard isValidWeight, let w = weightValue else { return nil }
        return NutritionCalculatorService.getFatRecommendation(weightInKg: w)
    }
    private var carbsRec: RecommendationRange? {
        guard isValidWeight, let w = weightValue else { return nil }
        return NutritionCalculatorService.getCarbsRecommendation(weightInKg: w)
    }

    private var totalCalories: Int {
        NutritionCalculatorService.calculateTotalCalories(
            carbs: carbsGoal,
            protein: proteinGoal,
            fat: fatGoal
        )
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundGray.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 歡迎標題
                        welcomeSection
                        
                        // 體重輸入區塊
                        weightInputSection
                        
                        // 營養目標設置區塊
                        nutritionGoalsSection
                        
                        // 總熱量顯示
                        totalCaloriesSection
                        
                        // 完成設置按鈕
                        completeSetupButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
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
        }
        .navigationBarHidden(true)
        .alert("輸入錯誤", isPresented: $showValidationError) { Button("確定", role: .cancel) { } } message: { Text(errorMessage) }
        // 體重變更時即時刷新建議與滑桿值（iOS 17 簽名）
        .onChange(of: weightInput) { _, _ in
            updateGoalsForWeight()
        }
    }
    
    // MARK: - View Components
    
    private var welcomeSection: some View {
        VStack(spacing: 16) {
            // 用戶頭像
            Circle()
                .fill(Color.primaryBlue)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundColor(.white)
                )
            
            VStack(spacing: 8) {
                Text("歡迎使用 NuTrack，\(user.name)！")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryBlue)
                    .multilineTextAlignment(.center)
                
                Text("設置基本資料")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
    
    private var weightInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("體重")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            HStack {
                TextField("請輸入體重", text: $weightInput)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                    .font(.body)
                    .focused($isWeightFieldFocused)
                    .submitLabel(.done)
                    .onSubmit { isWeightFieldFocused = false }
                Text("kg")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var nutritionGoalsSection: some View {
        let disabled = !isValidWeight
        return VStack(alignment: .leading, spacing: 16) {
            Text("每日營養目標")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // 碳水化合物滑桿
            macronutrientSlider(
                title: "碳水化合物",
                value: $carbsGoal,
                range: carbsRec.map { Double($0.min)...Double($0.max) } ?? (0...0),
                color: .carbsColor,
                unit: "g",
                recommended: carbsRec,
                disabled: disabled
            )
            
            // 蛋白質滑桿
            macronutrientSlider(
                title: "蛋白質",
                value: $proteinGoal,
                range: proteinRec.map { Double($0.min)...Double($0.max) } ?? (0...0),
                color: .proteinColor,
                unit: "g",
                recommended: proteinRec,
                disabled: disabled
            )
            
            // 脂肪滑桿
            macronutrientSlider(
                title: "脂肪",
                value: $fatGoal,
                range: fatRec.map { Double($0.min)...Double($0.max) } ?? (0...0),
                color: .fatColor,
                unit: "g",
                recommended: fatRec,
                disabled: disabled
            )
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func macronutrientSlider(
        title: String,
        value: Binding<Double>,
        range: ClosedRange<Double>,
        color: Color,
        unit: String,
        recommended: RecommendationRange?,
        disabled: Bool
    ) -> some View {
        let safeRange: ClosedRange<Double> = range.lowerBound < range.upperBound ? range : (0...1)
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Spacer()
                if disabled {
                    Text("- \(unit)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                } else {
                    Text("\(Int(value.wrappedValue)) \(unit)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                }
            }
            
            Slider(value: value, in: safeRange, step: 1)
                .tint(color)
                .disabled(disabled)
            
            if let rec = recommended {
                HStack(spacing: 12) {
                    Text("建議：\(rec.suggested) \(unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("範圍：\(rec.min) - \(rec.max) \(unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("請先輸入有效體重以取得建議")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var totalCaloriesSection: some View {
        VStack(spacing: 12) {
            Text("預估每日總熱量")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("\(totalCalories) 大卡")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primaryBlue)
        }
        .padding()
        .background(Color.primaryBlue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var completeSetupButton: some View {
        Button(action: completeSetup) {
            Text("完成設置")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isValidWeight ? Color.primaryBlue : Color.gray.opacity(0.5))
                )
        }
        .disabled(!isValidWeight)
        .padding(.top, 20)
    }
    
    // MARK: - Helper Functions
    
    private func completeSetup() {
        guard isValidWeight else {
            errorMessage = "請輸入有效的體重範圍（30.0 - 300.0 公斤）"
            showValidationError = true
            return
        }
        
        guard let weight = Double(weightInput) else {
            errorMessage = "體重格式不正確"
            showValidationError = true
            return
        }
        
        // 更新用戶資料
        user.weightInKg = weight
        user.dailyCarbsGoal = Int(carbsGoal)
        user.dailyProteinGoal = Int(proteinGoal)
        user.dailyFatGoal = Int(fatGoal)
        user.dailyCalorieGoal = totalCalories
        
        // 保存到數據庫
        do {
            try modelContext.save()
            onSetupComplete()
        } catch {
            errorMessage = "保存資料時發生錯誤：\(error.localizedDescription)"
            showValidationError = true
        }
    }
    
    private func updateGoalsForWeight() {
        guard isValidWeight, let w = Double(weightInput) else {
            carbsGoal = 0
            proteinGoal = 0
            fatGoal = 0
            return
        }
        let p = NutritionCalculatorService.getProteinRecommendation(weightInKg: w).suggested
        let f = NutritionCalculatorService.getFatRecommendation(weightInKg: w).suggested
        let c = NutritionCalculatorService.getCarbsRecommendation(weightInKg: w).suggested
        proteinGoal = Double(p)
        fatGoal = Double(f)
        carbsGoal = Double(c)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, MealEntry.self, configurations: config)
    
    let sampleUser = UserProfile(name: "預覽用戶")
    container.mainContext.insert(sampleUser)
    
    return UserProfileSetupView(user: sampleUser) {
        print("設置完成")
    }
    .modelContainer(container)
}

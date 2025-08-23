//
//  UserProfileView.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2025/1/15.
//

import SwiftUI

struct UserProfileView: View {
    @ObservedObject var userManager: SimpleUserManager
    @Environment(\.presentationMode) var presentationMode
    
    @State private var weightInput: String = ""
    @State private var carbsSliderValue: Double = 210
    @State private var proteinSliderValue: Double = 105
    @State private var fatSliderValue: Double = 63
    @State private var showLogoutAlert = false
    @State private var showWeightValidationError = false
    
    private var currentWeight: Double {
        Double(weightInput) ?? userManager.userWeight
    }
    
    private var weightRanges: (carbs: ClosedRange<Double>, protein: ClosedRange<Double>, fat: ClosedRange<Double>) {
        let proteinRec = HealthCalculatorService.getProteinRecommendation(weightInKg: currentWeight)
        let fatRec = HealthCalculatorService.getFatRecommendation(weightInKg: currentWeight)
        // 使用新的、僅依賴體重的方法
        let carbsRec = HealthCalculatorService.getCarbsRecommendation(weightInKg: currentWeight)
        
        return (
            carbs: Double(carbsRec.min)...Double(carbsRec.max),
            protein: Double(proteinRec.min)...Double(proteinRec.max),
            fat: Double(fatRec.min)...Double(fatRec.max)
        )
    }
    
    private var totalCalories: Int {
        // 直接計算，移除對舊服務的依賴
        return (Int(carbsSliderValue) * 4) + (Int(proteinSliderValue) * 4) + (Int(fatSliderValue) * 9)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundGray.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 用戶資料區塊
                        userInfoSection
                        
                        // 體重輸入區塊
                        weightInputSection
                        
                        // 智能營養目標區塊
                        nutritionGoalsSection
                        
                        // 營養素滑桿區塊
                        nutritionSlidersSection
                        
                        // 總熱量顯示
                        totalCaloriesSection
                        
                        // 登出按鈕
                        logoutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadCurrentValues()
        }
        .alert("體重範圍錯誤", isPresented: $showWeightValidationError) {
            Button("確定", role: .cancel) { }
        } message: {
            Text("請輸入有效的體重範圍（30.0 - 300.0 公斤）")
        }
        .alert("確認登出", isPresented: $showLogoutAlert) {
            Button("取消", role: .cancel) { }
            Button("登出", role: .destructive) {
                userManager.logout()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("您確定要登出 NuTrack 嗎？")
        }
    }
    
    // MARK: - View Components
    
    private var userInfoSection: some View {
        VStack(spacing: 16) {
            // 返回按鈕和標題
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primaryBlue)
                }
                
                Spacer()
                
                Text("用戶設置")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryBlue)
                
                Spacer()
                
                // 保存按鈕
                Button("保存") {
                    saveSettings()
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primaryBlue)
            }
            
            // 用戶頭像和名稱
            VStack(spacing: 12) {
                Circle()
                    .fill(Color.primaryBlue)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    )
                
                Text(userManager.currentUsername)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .padding(.vertical, 20)
    }
    
    private var weightInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("體重設置")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("體重")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("公斤")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    TextField("請輸入體重", text: $weightInput)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: weightInput) { newValue in
                            updateNutritionSlidersBasedOnWeight()
                        }
                    
                    Button("重設") {
                        updateNutritionGoalsFromWeight()
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.primaryBlue.opacity(0.1))
                    .foregroundColor(.primaryBlue)
                    .cornerRadius(6)
                }
                
                Text("有效範圍：30.0 - 300.0 公斤")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var nutritionGoalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("智能營養目標")
                .font(.headline).fontWeight(.semibold).foregroundColor(.primary)
            
            if isValid(weight: currentWeight) {
                VStack(spacing: 12) {
                    // 使用新的 HealthCalculatorService
                    let proteinRec = HealthCalculatorService.getProteinRecommendation(weightInKg: currentWeight)
                    let fatRec = HealthCalculatorService.getFatRecommendation(weightInKg: currentWeight)
                    let carbsRec = HealthCalculatorService.getCarbsRecommendation(weightInKg: currentWeight)
                    
                    HStack {
                        Text("基於 \(formatted(weight: currentWeight)) 公斤的建議目標：")
                            .font(.subheadline).foregroundColor(.secondary)
                        Spacer()
                    }
                    
                    HStack(spacing: 20) {
                        NutrientRecommendationCard(title: "碳水", value: carbsRec.suggested, unit: "g", color: .carbsColor)
                        NutrientRecommendationCard(title: "蛋白質", value: proteinRec.suggested, unit: "g", color: .proteinColor)
                        NutrientRecommendationCard(title: "脂肪", value: fatRec.suggested, unit: "g", color: .fatColor)
                    }
                }
            } else {
                Text("請輸入有效體重以獲得個人化建議")
                    .font(.subheadline).foregroundColor(.secondary).padding(.vertical, 12)
            }
        }
        .padding(.vertical, 16).padding(.horizontal, 20)
        .background(.white).cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var nutritionSlidersSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("營養素自定義調整")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // 碳水化合物滑桿
            NutrientSlider(
                title: "碳水化合物",
                value: $carbsSliderValue,
                range: weightRanges.carbs,
                color: .carbsColor,
                unit: "g"
            )
            
            // 蛋白質滑桿
            NutrientSlider(
                title: "蛋白質",
                value: $proteinSliderValue,
                range: weightRanges.protein,
                color: .proteinColor,
                unit: "g"
            )
            
            // 脂肪滑桿
            NutrientSlider(
                title: "脂肪",
                value: $fatSliderValue,
                range: weightRanges.fat,
                color: .fatColor,
                unit: "g"
            )
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var totalCaloriesSection: some View {
        VStack(spacing: 12) {
            Text("預估熱量")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("\(totalCalories)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primaryBlue)
            
            Text("卡路里 / 日")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // 熱量分佈
            HStack(spacing: 20) {
                let carbsCal = Int(carbsSliderValue) * 4
                let proteinCal = Int(proteinSliderValue) * 4
                let fatCal = Int(fatSliderValue) * 9
                
                CalorieDistributionCard(
                    title: "碳水",
                    calories: carbsCal,
                    percentage: totalCalories > 0 ? Double(carbsCal) / Double(totalCalories) * 100 : 0,
                    color: .carbsColor
                )
                
                CalorieDistributionCard(
                    title: "蛋白質",
                    calories: proteinCal,
                    percentage: totalCalories > 0 ? Double(proteinCal) / Double(totalCalories) * 100 : 0,
                    color: .proteinColor
                )
                
                CalorieDistributionCard(
                    title: "脂肪",
                    calories: fatCal,
                    percentage: totalCalories > 0 ? Double(fatCal) / Double(totalCalories) * 100 : 0,
                    color: .fatColor
                )
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 20)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var logoutSection: some View {
        Button(action: {
            showLogoutAlert = true
        }) {
            HStack {
                Image(systemName: "arrow.right.square")
                    .font(.title3)
                
                Text("登出")
                    .font(.headline)
                    .fontWeight(.medium)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.red)
            .cornerRadius(12)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Helper Functions
    
    private func loadCurrentValues() {
        weightInput = formatted(weight: userManager.userWeight)
        carbsSliderValue = userManager.carbsGoal
        proteinSliderValue = userManager.proteinGoal
        fatSliderValue = userManager.fatGoal
    }
    
    private func updateNutritionSlidersBasedOnWeight() {
        guard let weight = Double(weightInput), isValid(weight: weight) else { return }
        
        let ranges = self.weightRanges
        
        withAnimation(.easeInOut(duration: 0.3)) {
            carbsSliderValue = max(ranges.carbs.lowerBound, min(ranges.carbs.upperBound, carbsSliderValue))
            proteinSliderValue = max(ranges.protein.lowerBound, min(ranges.protein.upperBound, proteinSliderValue))
            fatSliderValue = max(ranges.fat.lowerBound, min(ranges.fat.upperBound, fatSliderValue))
        }
    }
    
    private func updateNutritionGoalsFromWeight() {
        guard let weight = Double(weightInput), isValid(weight: weight) else {
            showWeightValidationError = true
            return
        }
        
        // 使用新的 HealthCalculatorService
        let proteinRec = HealthCalculatorService.getProteinRecommendation(weightInKg: weight)
        let fatRec = HealthCalculatorService.getFatRecommendation(weightInKg: weight)
        let carbsRec = HealthCalculatorService.getCarbsRecommendation(weightInKg: weight)
        
        withAnimation(.easeInOut(duration: 0.5)) {
            carbsSliderValue = Double(carbsRec.suggested)
            proteinSliderValue = Double(proteinRec.suggested)
            fatSliderValue = Double(fatRec.suggested)
        }
    }
    
    private func saveSettings() {
        guard let weight = Double(weightInput), isValid(weight: weight) else {
            showWeightValidationError = true
            return
        }
        
        // 保存體重和營養目標
        userManager.updateWeight(weight)
        userManager.updateNutritionGoals(
            carbs: carbsSliderValue,
            protein: proteinSliderValue,
            fat: fatSliderValue
        )
        
        // 顯示保存成功動畫並返回
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    // 將舊 Extension 的邏輯整合為 View 的私有方法
    private func isValid(weight: Double) -> Bool {
        return weight >= 30.0 && weight <= 300.0
    }
    
    private func formatted(weight: Double) -> String {
        return String(format: "%.1f", weight)
    }
}

// MARK: - Supporting Views

struct NutrientRecommendationCard: View {
    let title: String
    let value: Int
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(value)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(unit)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct NutrientSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let color: Color
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(value)) \(unit)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Slider(value: $value, in: range, step: 1.0)
                .accentColor(color)
            
            HStack {
                Text("\(Int(range.lowerBound))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(range.upperBound))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct CalorieDistributionCard: View {
    let title: String
    let calories: Int
    let percentage: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(calories)")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text("\(Int(percentage))%")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(6)
    }
}

#Preview {
    UserProfileView(userManager: SimpleUserManager())
}

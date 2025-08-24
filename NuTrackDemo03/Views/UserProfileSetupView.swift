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
    @State private var carbsGoal: Double = 250
    @State private var proteinGoal: Double = 125
    @State private var fatGoal: Double = 56
    @State private var showValidationError = false
    @State private var errorMessage = ""
    
    private var isValidWeight: Bool {
        guard let weight = Double(weightInput), weight >= 30.0, weight <= 300.0 else {
            return false
        }
        return true
    }
    
    private var totalCalories: Int {
        Int((carbsGoal * 4) + (proteinGoal * 4) + (fatGoal * 9))
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
        .alert("輸入錯誤", isPresented: $showValidationError) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(errorMessage)
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
                
                Text("請設置您的基本資料，以獲得個人化的營養建議")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 20)
    }
    
    private var weightInputSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("體重 (公斤)")
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
            Text("建議範圍：30.0 - 300.0 公斤")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var nutritionGoalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("每日營養目標")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            // 碳水化合物滑桿
            macronutrientSlider(
                title: "碳水化合物",
                value: $carbsGoal,
                range: 100...400,
                color: .carbsColor,
                unit: "g"
            )
            
            // 蛋白質滑桿
            macronutrientSlider(
                title: "蛋白質",
                value: $proteinGoal,
                range: 50...200,
                color: .proteinColor,
                unit: "g"
            )
            
            // 脂肪滑桿
            macronutrientSlider(
                title: "脂肪",
                value: $fatGoal,
                range: 20...120,
                color: .fatColor,
                unit: "g"
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
        unit: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(Int(value.wrappedValue)) \(unit)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            Slider(value: value, in: range, step: 1)
                .tint(color)
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

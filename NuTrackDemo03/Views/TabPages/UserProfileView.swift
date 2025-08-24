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
    
    // --- Local State for UI controls ---
    @State private var weightInput: String
    @State private var carbsSliderValue: Double
    @State private var proteinSliderValue: Double
    @State private var fatSliderValue: Double
    
    @FocusState private var isWeightFieldFocused: Bool
    
    @State private var showWeightValidationError = false

    // --- Initializer ---
    init(user: UserProfile) {
        self.user = user
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
                    userAvatarSection
                    weightInputSection
                    nutritionGoalsSection // Renamed from nutritionSlidersSection for clarity
                    totalCaloriesSection
                    
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
            Text("用戶設置")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primaryBlue)
            Spacer()
            Button("保存", action: saveSettings)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primaryBlue)
        }
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
            
            if showWeightValidationError {
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
                color: .carbsColor
            )
            
            NutritionSliderView(
                label: "蛋白質",
                value: $proteinSliderValue,
                recommendation: NutritionCalculatorService.getProteinRecommendation(weightInKg: currentWeight),
                color: .proteinColor
            )
            
            NutritionSliderView(
                label: "脂肪",
                value: $fatSliderValue,
                recommendation: NutritionCalculatorService.getFatRecommendation(weightInKg: currentWeight),
                color: .fatColor
            )
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
        
        presentationMode.wrappedValue.dismiss()
    }
    
    private func isValid(weight: Double) -> Bool {
        weight >= 30.0 && weight <= 300.0
    }
}

// MARK: - Child View for Nutrition Slider
struct NutritionSliderView: View {
    let label: String
    @Binding var value: Double
    let recommendation: RecommendationRange
    let color: Color

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
            
            HStack {
                Text("建議: \(recommendation.min)g")
                Spacer()
                Text("\(recommendation.max)g")
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
    
    return UserProfileView(user: sampleUser)
        .modelContainer(container)
}

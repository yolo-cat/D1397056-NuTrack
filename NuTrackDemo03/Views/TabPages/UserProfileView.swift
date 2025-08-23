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
    
    // Local state for editing
    @State private var weightInput: String = ""
    @State private var carbsSliderValue: Double
    @State private var proteinSliderValue: Double
    @State private var fatSliderValue: Double
    
    @State private var showWeightValidationError = false

    // Initialize state from the model
    init(user: UserProfile) {
        self.user = user
        self._carbsSliderValue = State(initialValue: Double(user.dailyCarbsGoal))
        self._proteinSliderValue = State(initialValue: Double(user.dailyProteinGoal))
        self._fatSliderValue = State(initialValue: Double(user.dailyFatGoal))
    }
    
    private var currentWeight: Double {
        Double(weightInput) ?? user.weightInKg ?? 0
    }
    
    private var weightRanges: (carbs: ClosedRange<Double>, protein: ClosedRange<Double>, fat: ClosedRange<Double>) {
        let proteinRec = HealthCalculatorService.getProteinRecommendation(weightInKg: currentWeight)
        let fatRec = HealthCalculatorService.getFatRecommendation(weightInKg: currentWeight)
        let carbsRec = HealthCalculatorService.getCarbsRecommendation(weightInKg: currentWeight)
        
        return (
            carbs: Double(carbsRec.min)...Double(carbsRec.max),
            protein: Double(proteinRec.min)...Double(proteinRec.max),
            fat: Double(fatRec.min)...Double(fatRec.max)
        )
    }
    
    private var totalCalories: Int {
        return (Int(carbsSliderValue) * 4) + (Int(proteinSliderValue) * 4) + (Int(fatSliderValue) * 9)
    }
    
    var body: some View {
        ZStack {
            Color.backgroundGray.opacity(0.3).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    userInfoSection
                    weightInputSection
                    nutritionGoalsSection
                    nutritionSlidersSection
                    totalCaloriesSection
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: loadCurrentValues)
        .alert("體重範圍錯誤", isPresented: $showWeightValidationError) {
            Button("確定", role: .cancel) { }
        } message: {
            Text("請輸入有效的體重範圍（30.0 - 300.0 公斤）")
        }
    }
    
    // MARK: - View Components
    
    private var userInfoSection: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left").font(.title2).foregroundColor(.primaryBlue)
                }
                Spacer()
                Text("用戶設置").font(.title2).fontWeight(.bold).foregroundColor(.primaryBlue)
                Spacer()
                Button("保存", action: saveSettings)
                    .font(.subheadline).fontWeight(.medium).foregroundColor(.primaryBlue)
            }
            
            VStack(spacing: 12) {
                Circle().fill(Color.primaryBlue).frame(width: 80, height: 80)
                    .overlay(Image(systemName: "person.fill").font(.title).foregroundColor(.white))
                Text(user.name).font(.title3).fontWeight(.semibold).foregroundColor(.primary)
            }
        }
        .padding(.vertical, 20)
    }
    
    private var weightInputSection: some View { /* ... Omitted for brevity ... */ }
    private var nutritionGoalsSection: some View { /* ... Omitted for brevity ... */ }
    private var nutritionSlidersSection: some View { /* ... Omitted for brevity ... */ }
    private var totalCaloriesSection: some View { /* ... Omitted for brevity ... */ }
    
    // MARK: - Helper Functions
    
    private func loadCurrentValues() {
        self.weightInput = formatted(weight: user.weightInKg ?? 0)
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
        // Directly modify the bindable user object. SwiftData handles the save.
        user.weightInKg = weight
        user.dailyCarbsGoal = Int(carbsSliderValue)
        user.dailyProteinGoal = Int(proteinSliderValue)
        user.dailyFatGoal = Int(fatSliderValue)
        user.dailyCalorieGoal = totalCalories
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func isValid(weight: Double) -> Bool { weight >= 30.0 && weight <= 300.0 }
    private func formatted(weight: Double) -> String { String(format: "%.1f", weight) }
}

// MARK: - Re-implementing child views for clarity
extension UserProfileView {
    private var weightInputSection: some View { /* ... */ }
    private var nutritionGoalsSection: some View { /* ... */ }
    private var nutritionSlidersSection: some View { /* ... */ }
    private var totalCaloriesSection: some View { /* ... */ }
}


#Preview {
    // Create an in-memory container for previewing
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    
    // Create a sample user
    let sampleUser = UserProfile(name: "測試用戶", weightInKg: 72.5)
    container.mainContext.insert(sampleUser)
    
    return UserProfileView(user: sampleUser)
        .modelContainer(container)
}

//
//  NewNutritionTrackerView.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI
import SwiftData

struct NewNutritionTrackerView: View {
    let user: UserProfile
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var showAddNutrition = false
    
    private var mealEntries: [MealEntry] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        let userID = user.id
        let descriptor = FetchDescriptor<MealEntry>(
            predicate: #Predicate<MealEntry> {
                $0.user?.id == userID && $0.timestamp >= startOfToday && $0.timestamp < endOfToday
            },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // MARK: - Computed Properties
    
    private var nutritionData: NutritionSummaryViewModel {
        return NutritionSummaryViewModel(user: user, meals: mealEntries)
    }
    
    private var foodLogEntries: [MealEntry] {
        return mealEntries
    }
    
    // MARK: - Main Body
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                mainNutritionView
                addMealButton
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddNutrition) {
            AddNutritionView { nutritionInfo in
                addNutritionEntry(nutritionInfo)
            }
        }
    }
    
    // MARK: - View Components
    
    private var mainNutritionView: some View {
        ZStack {
            Color.backgroundGray.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 0) {
                HeaderView(user: user)
                ScrollView {
                    VStack(spacing: 24) {
                        NutritionProgressSection(nutritionData: nutritionData)
                        TodayFoodLogView(foodEntries: foodLogEntries)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 80) // Add padding for floating button
                }
            }
        }
    }
    
    private var addMealButton: some View {
        Button(action: { showAddNutrition = true }) {
            ZStack {
                Circle().fill(Color.primaryBlue).frame(width: 60, height: 60)
                    .shadow(color: .primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                Image(systemName: "plus").font(.title2).fontWeight(.bold).foregroundColor(.white)
            }
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - Helper Functions
    
    private func addNutritionEntry(_ nutritionInfo: NutritionInfo) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            let newEntry = MealEntry(
                name: nutritionInfo.name,
                carbs: nutritionInfo.carbs,
                protein: nutritionInfo.protein,
                fat: nutritionInfo.fat
            )
            newEntry.user = user
            modelContext.insert(newEntry)
        }
    }
}




#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, MealEntry.self, configurations: config)
    
    let sampleUser = UserProfile(name: "預覽用戶", weightInKg: 72.5)
    container.mainContext.insert(sampleUser)
    
    // Create some sample meal entries for the preview
    let sampleMeal1 = MealEntry(name: "早餐", carbs: 50, protein: 25, fat: 10)
    sampleMeal1.user = sampleUser
    container.mainContext.insert(sampleMeal1)
    
    let sampleMeal2 = MealEntry(name: "午餐", carbs: 30, protein: 15, fat: 5)
    sampleMeal2.user = sampleUser
    container.mainContext.insert(sampleMeal2)
    
    return NewNutritionTrackerView(user: sampleUser)
        .modelContainer(container)
}

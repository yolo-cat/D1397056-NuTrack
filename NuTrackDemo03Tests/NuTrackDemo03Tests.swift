//
//  NuTrackDemo03Tests.swift
//  NuTrackDemo03Tests
//
//  Created by 訪客使用者 on 2025/8/1.
//

import Testing
@testable import NuTrackDemo03

struct NuTrackDemo03Tests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test func testSimpleUserManagerLogin() async throws {
        let userManager = SimpleUserManager()
        
        // Initially should not be logged in
        #expect(userManager.isLoggedIn == false)
        #expect(userManager.currentUsername.isEmpty)
        
        // Test login
        userManager.quickLogin(username: "Test User")
        
        // Should be logged in after quick login
        #expect(userManager.isLoggedIn == true)
        #expect(userManager.currentUsername == "Test User")
        
        // Test logout
        userManager.logout()
        
        // Should be logged out
        #expect(userManager.isLoggedIn == false)
        #expect(userManager.currentUsername.isEmpty)
    }
    
    @Test func testUserDefaultsPersistence() async throws {
        let userManager1 = SimpleUserManager()
        
        // Login with first manager
        userManager1.quickLogin(username: "Persistent User")
        
        // Create new manager instance
        let userManager2 = SimpleUserManager()
        
        // Should automatically load stored login
        #expect(userManager2.isLoggedIn == true)
        #expect(userManager2.currentUsername == "Persistent User")
        
        // Clean up
        userManager2.logout()
    }
    
    // MARK: - Time-Based Categorization Tests
    
    @Test func testTimeBasedMealCategorization() async throws {
        // Test early morning
        let lateNightCategory = TimeBasedMealCategory.category(from: "02:30")
        #expect(lateNightCategory == .lateNight)
        
        // Test breakfast time
        let breakfastCategory = TimeBasedMealCategory.category(from: "07:30")
        #expect(breakfastCategory == .breakfast)
        
        // Test lunch time
        let lunchCategory = TimeBasedMealCategory.category(from: "12:30")
        #expect(lunchCategory == .lunch)
        
        // Test dinner time
        let dinnerCategory = TimeBasedMealCategory.category(from: "18:30")
        #expect(dinnerCategory == .dinner)
        
        // Test midnight snack time
        let midnightCategory = TimeBasedMealCategory.category(from: "23:30")
        #expect(midnightCategory == .midnightSnack)
    }
    
    @Test func testTimeBasedMealCategorizationEdgeCases() async throws {
        // Test edge cases
        #expect(TimeBasedMealCategory.category(from: "04:59") == .lateNight)
        #expect(TimeBasedMealCategory.category(from: "05:00") == .breakfast)
        #expect(TimeBasedMealCategory.category(from: "10:59") == .breakfast)
        #expect(TimeBasedMealCategory.category(from: "11:00") == .lunch)
        #expect(TimeBasedMealCategory.category(from: "15:59") == .lunch)
        #expect(TimeBasedMealCategory.category(from: "16:00") == .dinner)
        #expect(TimeBasedMealCategory.category(from: "22:59") == .dinner)
        #expect(TimeBasedMealCategory.category(from: "23:00") == .midnightSnack)
        
        // Test invalid input (should default to breakfast)
        #expect(TimeBasedMealCategory.category(from: "invalid") == .breakfast)
        #expect(TimeBasedMealCategory.category(from: "25:00") == .breakfast)
    }
    
    @Test func testMealItemTimeBasedCategory() async throws {
        // Test that MealItem correctly uses time-based categorization
        let breakfastMeal = MealItem(
            name: "煎蛋",
            time: "07:30",
            nutrition: NutritionInfo(calories: 155, carbs: 1, protein: 13, fat: 11)
        )
        
        #expect(breakfastMeal.timeBasedCategory == .breakfast)
        
        let lunchMeal = MealItem(
            name: "午餐",
            time: "12:30",
            nutrition: NutritionInfo(calories: 300, carbs: 20, protein: 25, fat: 10)
        )
        
        #expect(lunchMeal.timeBasedCategory == .lunch)
    }
    
    @Test func testFoodLogEntryTimeBasedCategory() async throws {
        // Test that FoodLogEntry correctly uses time-based categorization
        let breakfastEntry = FoodLogEntry(
            time: "07:30",
            nutrition: NutritionInfo(calories: 200, carbs: 20, protein: 15, fat: 8)
        )
        
        #expect(breakfastEntry.timeBasedCategory == .breakfast)
        
        let dinnerEntry = FoodLogEntry(
            time: "19:00",
            nutrition: NutritionInfo(calories: 400, carbs: 30, protein: 25, fat: 20)
        )
        
        #expect(dinnerEntry.timeBasedCategory == .dinner)
    }

    // MARK: - CalorieRingView Tests
    
    @Test func testNutritionProgressCalculation() async throws {
        // Test data with known progress values
        let testData = NutritionData(
            caloriesConsumed: 1000,
            caloriesBurned: 200,
            caloriesGoal: 2000,
            carbs: NutrientData(current: 60, goal: 120, unit: "g"),    // 50% progress
            protein: NutrientData(current: 90, goal: 180, unit: "g"), // 50% progress
            fat: NutrientData(current: 90, goal: 180, unit: "g")      // 50% progress
        )
        
        // Test individual progress calculations
        #expect(testData.carbs.progress == 0.5)
        #expect(testData.protein.progress == 0.5)
        #expect(testData.fat.progress == 0.5)
        
        // Test overall nutrition balance
        #expect(testData.totalNutrientProgress == 0.5)
    }
    
    @Test func testNutritionProgressOverGoal() async throws {
        // Test data with over-goal values
        let testData = NutritionData(
            caloriesConsumed: 2000,
            caloriesBurned: 200,
            caloriesGoal: 2000,
            carbs: NutrientData(current: 180, goal: 120, unit: "g"),  // 150% progress
            protein: NutrientData(current: 180, goal: 180, unit: "g"), // 100% progress
            fat: NutrientData(current: 90, goal: 180, unit: "g")      // 50% progress
        )
        
        // Test progress calculations
        #expect(testData.carbs.progress == 1.5)
        #expect(testData.protein.progress == 1.0)
        #expect(testData.fat.progress == 0.5)
        
        // Test overall nutrition balance
        #expect(testData.totalNutrientProgress == 1.0) // (1.5 + 1.0 + 0.5) / 3
    }
    
    @Test func testNutrientDataPercentageCalculation() async throws {
        let nutrientData = NutrientData(current: 75, goal: 150, unit: "g")
        
        // Test progress (should be 0.5)
        #expect(nutrientData.progress == 0.5)
        
        // Test percentage (should be 50)
        #expect(nutrientData.percentage == 50)
    }
    
    @Test func testNutrientDataZeroGoalEdgeCase() async throws {
        let nutrientData = NutrientData(current: 50, goal: 0, unit: "g")
        
        // Test progress with zero goal (should be 0.0 to avoid division by zero)
        #expect(nutrientData.progress == 0.0)
        
        // Test percentage with zero goal (should be 0)
        #expect(nutrientData.percentage == 0)
    }

}

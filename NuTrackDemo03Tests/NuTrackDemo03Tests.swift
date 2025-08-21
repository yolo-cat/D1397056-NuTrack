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

}

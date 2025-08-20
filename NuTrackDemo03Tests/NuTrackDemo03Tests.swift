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

}

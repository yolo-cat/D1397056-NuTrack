//
//  SimpleUserManager.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2025/1/15.
//

import SwiftUI
import Foundation

/// 簡化的使用者狀態管理類別，用於概念驗證階段
class SimpleUserManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUsername: String = ""
    @Published var isLoading: Bool = false
    
    // UserDefaults 鍵值
    private let userDefaultsKeys = (
        isLoggedIn: "nu_track_is_logged_in",
        username: "nu_track_username"
    )
    
    init() {
        checkStoredLogin()
    }
    
    /// 檢查已儲存的登入狀態
    func checkStoredLogin() {
        let storedLoginState = UserDefaults.standard.bool(forKey: userDefaultsKeys.isLoggedIn)
        let storedUsername = UserDefaults.standard.string(forKey: userDefaultsKeys.username) ?? ""
        
        if storedLoginState && !storedUsername.isEmpty {
            DispatchQueue.main.async {
                self.isLoggedIn = true
                self.currentUsername = storedUsername
            }
        }
    }
    
    /// 使用者登入
    /// - Parameter username: 使用者名稱
    func login(username: String) {
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isLoading = true
        
        // 模擬登入過程的延遲
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 儲存到 UserDefaults
            UserDefaults.standard.set(true, forKey: self.userDefaultsKeys.isLoggedIn)
            UserDefaults.standard.set(trimmedUsername, forKey: self.userDefaultsKeys.username)
            
            // 更新狀態
            self.currentUsername = trimmedUsername
            self.isLoggedIn = true
            self.isLoading = false
        }
    }
    
    /// 使用者登出
    func logout() {
        // 清除 UserDefaults
        UserDefaults.standard.removeObject(forKey: userDefaultsKeys.isLoggedIn)
        UserDefaults.standard.removeObject(forKey: userDefaultsKeys.username)
        
        // 重置狀態
        DispatchQueue.main.async {
            self.isLoggedIn = false
            self.currentUsername = ""
            self.isLoading = false
        }
    }
    
    /// 快速登入功能（開發用）
    /// - Parameter username: 預設使用者名稱
    func quickLogin(username: String) {
        // 直接設定登入狀態，不需要延遲
        UserDefaults.standard.set(true, forKey: userDefaultsKeys.isLoggedIn)
        UserDefaults.standard.set(username, forKey: userDefaultsKeys.username)
        
        currentUsername = username
        isLoggedIn = true
        isLoading = false
    }
}

// MARK: - 預設使用者資料（開發用）
extension SimpleUserManager {
    static let sampleUsers = [
        "Alex Chen",
        "Jamie Wang",
        "Taylor Liu",
        "Casey Zhang"
    ]
}
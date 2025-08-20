//
//  SimpleLoginView.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2025/1/15.
//

import SwiftUI

/// 簡潔的登入頁面，遵循 Apple SwiftUI 設計規範
struct SimpleLoginView: View {
    @ObservedObject var userManager: SimpleUserManager
    @State private var username: String = ""
    @State private var showQuickSelect: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景漸層
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.backgroundGray.opacity(0.3),
                        Color.primaryBlue.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 40) {
                        Spacer(minLength: 60)
                        
                        // Logo 區域
                        logoSection
                        
                        // 登入表單
                        loginFormSection
                        
                        // 快速選擇使用者（開發用）
                        if showQuickSelect {
                            quickSelectSection
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 32)
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .onTapGesture {
            isTextFieldFocused = false
        }
    }
    
    // MARK: - Logo Section
    
    private var logoSection: some View {
        VStack(spacing: 20) {
            // 圓環設計的 Logo
            ZStack {
                // 外圈
                Circle()
                    .stroke(Color.primaryBlue.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                // 內圈漸層
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.primaryBlue,
                                Color.carbsColor
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                // 中心圖標
                Image(systemName: "heart.fill")
                    .font(.title)
                    .foregroundColor(.primaryBlue)
            }
            
            // App 標題
            VStack(spacing: 8) {
                Text("NuTrack")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryBlue)
                
                Text("營養追蹤，健康生活")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Login Form Section
    
    private var loginFormSection: some View {
        VStack(spacing: 24) {
            // 歡迎文字
            VStack(spacing: 8) {
                Text("歡迎使用")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("請輸入您的使用者名稱開始使用")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // 使用者名稱輸入欄位
            VStack(alignment: .leading, spacing: 8) {
                Text("使用者名稱")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                TextField("請輸入您的名稱", text: $username)
                    .textFieldStyle(.roundedBorder)
                    .focused($isTextFieldFocused)
                    .font(.body)
                    .padding(.vertical, 4)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    .onSubmit {
                        if !username.isEmpty {
                            handleLogin()
                        }
                    }
            }
            
            // 開始使用按鈕
            Button(action: handleLogin) {
                HStack {
                    if userManager.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                    
                    Text(userManager.isLoading ? "登入中..." : "開始使用")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                            Color.gray.opacity(0.5) : Color.primaryBlue
                        )
                )
                .scaleEffect(userManager.isLoading ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: userManager.isLoading)
            }
            .disabled(username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || userManager.isLoading)
            
            // 開發用快速選擇切換
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showQuickSelect.toggle()
                }
            }) {
                HStack {
                    Image(systemName: showQuickSelect ? "chevron.up" : "chevron.down")
                        .font(.caption)
                    Text("快速選擇使用者")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - Quick Select Section
    
    private var quickSelectSection: some View {
        VStack(spacing: 16) {
            Text("快速選擇（開發用）")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(SimpleUserManager.sampleUsers, id: \.self) { user in
                    Button(action: {
                        username = user
                        userManager.quickLogin(username: user)
                    }) {
                        Text(user)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primaryBlue)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.primaryBlue.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.primaryBlue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Helper Functions
    
    private func handleLogin() {
        guard !username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isTextFieldFocused = false
        userManager.login(username: username)
    }
}

#Preview {
    SimpleLoginView(userManager: SimpleUserManager())
}
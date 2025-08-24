//
//  LoginView.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2025/1/15.
//

import SwiftUI
import SwiftData

/// 使用者登入與註冊視圖，已為 iOS 17 更新，並整合 SwiftData 的 @Query。
struct LoginView: View {
    var onLoginSuccess: (UUID) -> Void
    
    @Environment(\.modelContext) private var modelContext
    
    // 使用 @Query 直接從 SwiftData 獲取並排序使用者資料。
    // 當使用者資料新增或變更時，視圖會自動更新。
    // 使用者列表會根據最近登入時間排序，新使用者會顯示在最前面。
    @Query(sort: [SortDescriptor(\UserProfile.lastLoginAt, order: .reverse), SortDescriptor(\UserProfile.name)])
    private var existingUsers: [UserProfile]
    
    @State private var username: String = ""
    @State private var isLoading: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    
    // 計算屬性，用於判斷登入按鈕是否應被禁用，使邏輯更清晰。
    private var isLoginDisabled: Bool {
        username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundGradient
                
                ScrollView {
                    VStack(spacing: 40) {
                        Spacer(minLength: 60)
                        logoSection
                        loginFormSection
                        
                        if !existingUsers.isEmpty {
                            quickSelectSection
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 32)
                    .frame(minHeight: geometry.size.height) // 確保 VStack 至少與螢幕同高，以便垂直置中
                }
                // iOS 16+ 的現代寫法，捲動時自動隱藏鍵盤
                .scrollDismissesKeyboard(.interactively)
            }
        }
        .onAppear {
            // 視圖出現時，自動聚焦到文字輸入框，提升使用者體驗
            isTextFieldFocused = true
        }
    }
    
    // MARK: - View Components
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                .backgroundGray.opacity(0.3),
                .primaryBlue.opacity(0.1)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var logoSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.primaryBlue.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(
                        LinearGradient(gradient: Gradient(colors: [.primaryBlue, .carbsColor]), startPoint: .topLeading, endPoint: .bottomTrailing),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: "heart.fill")
                    .font(.title)
                    .foregroundColor(.primaryBlue)
            }
            
            VStack(spacing: 8) {
                Text("NuTrack")
                    .font(.largeTitle.weight(.bold))
                    .foregroundColor(.primaryBlue)
                Text("營養追蹤器")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var loginFormSection: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("使用者名稱")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                
                TextField("請輸入名稱", text: $username)
                    .focused($isTextFieldFocused)
                    .font(.body)
                    .padding(12)
                    // iOS 15+ 的寫法，提供背景形狀
                    .background(.background, in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    .onSubmit {
                        if !isLoginDisabled { handleLogin() }
                    }
            }
            
            Button(action: handleLogin) {
                // 使用 Label 來組合圖示和文字，更具語義化
                Label(
                    title: { Text(isLoading ? "登入中..." : "開始使用").fontWeight(.semibold) },
                    icon: {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.right")
                        }
                    }
                )
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            // iOS 15+ 的寫法，提供背景形狀
            .background(isLoginDisabled ? Color.gray.opacity(0.5) : Color.primaryBlue, in: RoundedRectangle(cornerRadius: 12))
            .disabled(isLoginDisabled)
            .animation(.easeInOut(duration: 0.2), value: isLoading)
        }
        .padding(.horizontal, 8)
    }
    
    private var quickSelectSection: some View {
        VStack(spacing: 16) {
            Text("快速登入（曾經使用過）")
                .font(.subheadline.weight(.medium))
                .foregroundColor(.secondary)
            
            // 使用 adaptive GridItem 讓網格能更好地適應不同螢幕寬度
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                ForEach(existingUsers) { user in
                    Button(action: { handleQuickSelect(user: user) }) {
                        Text(user.name)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primaryBlue)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .frame(maxWidth: .infinity)
                            .background(Color.primaryBlue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.primaryBlue.opacity(0.3), lineWidth: 1)
                            }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .transition(.opacity.animation(.easeInOut))
    }
    
    // MARK: - Helper Functions
    
    @MainActor
    private func handleLogin() {
        Task {
            let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedUsername.isEmpty else { return }
            
            isTextFieldFocused = false
            isLoading = true
            // 使用 defer 確保無論函式如何結束，isLoading 都會被重設
            defer { isLoading = false }
            
            // 模擬網路延遲，提供更真實的使用者體驗
            try? await Task.sleep(for: .seconds(0.5))
            
            let descriptor = FetchDescriptor<UserProfile>(predicate: #Predicate<UserProfile> { $0.name == trimmedUsername })
            
            do {
                let userToLogin: UserProfile
                if let existingUser = try modelContext.fetch(descriptor).first {
                    print("使用者 \(trimmedUsername) 已存在，直接登入。")
                    existingUser.lastLoginAt = Date()
                    userToLogin = existingUser
                } else {
                    print("使用者 \(trimmedUsername) 不存在，建立新使用者並登入。")
                    let newUser = UserProfile(name: trimmedUsername)
                    newUser.lastLoginAt = Date()
                    modelContext.insert(newUser)
                    userToLogin = newUser
                }
                
                try modelContext.save()
                onLoginSuccess(userToLogin.id)

            } catch {
                // 在真實應用中，這裡應該要向使用者顯示錯誤訊息
                print("登入或建立使用者時發生錯誤: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    private func handleQuickSelect(user: UserProfile) {
        user.lastLoginAt = Date()
        do {
            try modelContext.save()
            onLoginSuccess(user.id)
        } catch {
            print("快速登入時儲存失敗: \(error.localizedDescription)")
        }
    }
}

#Preview {
    // 這是現代 SwiftUI 的預覽最佳實踐。
    // 它建立一個記憶體內的資料容器，並注入範例資料，
    // 讓預覽不依賴於真實的裝置儲存。
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: UserProfile.self, MealEntry.self, configurations: config)
        
        // 注入一些測試使用者資料以供預覽
        let sampleUsers = [
            UserProfile(name: "測試用戶A"),
            UserProfile(name: "用戶B"),
            UserProfile(name: "訪客")
        ]
        sampleUsers.forEach { container.mainContext.insert($0) }
        
        return LoginView(onLoginSuccess: { _ in print("登入成功！") })
            .modelContainer(container)
    } catch {
        return Text("建立預覽失敗: \(error.localizedDescription)")
    }
}
//
//  SimpleLoginView.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2025/1/15.
//

import SwiftUI
import SwiftData

/// 簡潔的登入頁面，遵循 Apple SwiftUI 設計規範
struct SimpleLoginView: View {
    var onLoginSuccess: (UUID) -> Void
    @Environment(\.modelContext) private var modelContext
    
    @State private var username: String = ""
    @State private var isLoading: Bool = false
    @State private var existingUsers: [UserProfile] = []
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
                        logoSection
                        loginFormSection
                        if !existingUsers.isEmpty {
                            quickSelectSection
                        }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 32)
                    .frame(minHeight: geometry.size.height)
                }
            }
        }
        .onTapGesture { isTextFieldFocused = false }
        .task { loadExistingUsers() }
    }
    
    // MARK: - View Components
    
    private var logoSection: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle().stroke(Color.primaryBlue.opacity(0.2), lineWidth: 8).frame(width: 120, height: 120)
                Circle().stroke(LinearGradient(gradient: Gradient(colors: [.primaryBlue, .carbsColor]), startPoint: .topLeading, endPoint: .bottomTrailing), style: StrokeStyle(lineWidth: 6, lineCap: .round)).frame(width: 100, height: 100).rotationEffect(.degrees(-90))
                Image(systemName: "heart.fill").font(.title).foregroundColor(.primaryBlue)
            }
            VStack(spacing: 8) {
                Text("NuTrack").font(.largeTitle).fontWeight(.bold).foregroundColor(.primaryBlue)
                Text("營養追蹤器").font(.subheadline).foregroundColor(.secondary)
            }
        }
    }
    
    private var loginFormSection: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("使用者名稱").font(.subheadline).fontWeight(.medium).foregroundColor(.primary)
                TextField("請輸入名稱", text: $username)
                    .focused($isTextFieldFocused)
                    .font(.body)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    .onSubmit {
                        if !username.isEmpty { handleLogin() }
                    }
            }
            Button(action: handleLogin) {
                HStack {
                    if isLoading {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.right").font(.headline)
                    }
                    Text(isLoading ? "登入中..." : "開始使用").font(.headline).fontWeight(.semibold)
                }
                .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 12).fill(username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.5) : Color.primaryBlue))
                .scaleEffect(isLoading ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isLoading)
            }.disabled(username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
        }
        .padding(.horizontal, 8)
    }
    
    private var quickSelectSection: some View {
        VStack(spacing: 16) {
            Text("快速登入（曾經使用過）")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(existingUsers, id: \.id) { user in
                    Button(action: { handleQuickSelect(user: user) }) {
                        Text(user.name)
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
        .transition(.opacity)
    }
    
    // MARK: - Helper Functions
    
    private func loadExistingUsers() {
        do {
            // 讀取所有使用者，並依最近登入時間由新到舊排序（nil 視為最舊）
            let users = try modelContext.fetch(FetchDescriptor<UserProfile>())
            existingUsers = users.sorted { (lhs, rhs) in
                let l = lhs.lastLoginAt ?? .distantPast
                let r = rhs.lastLoginAt ?? .distantPast
                if l == r { return lhs.name < rhs.name }
                return l > r
            }
        } catch {
            print("讀取既有使用者失敗: \(error)")
            existingUsers = []
        }
    }
    
    @MainActor
    private func handleLogin() {
        Task { @MainActor in
            let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedUsername.isEmpty else { return }
            
            isTextFieldFocused = false
            isLoading = true
            
            // 模擬網路延遲
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            let descriptor = FetchDescriptor<UserProfile>(predicate: #Predicate<UserProfile> { $0.name == trimmedUsername })
            
            do {
                if let existingUser = try modelContext.fetch(descriptor).first {
                    print("使用者 \(trimmedUsername) 已存在，直接登入。")
                    existingUser.lastLoginAt = Date()
                    try modelContext.save()
                    onLoginSuccess(existingUser.id)
                } else {
                    print("使用者 \(trimmedUsername) 不存在，建立新使用者並登入。")
                    let newUser = UserProfile(name: trimmedUsername)
                    newUser.lastLoginAt = Date()
                    modelContext.insert(newUser)
                    try modelContext.save()
                    onLoginSuccess(newUser.id)
                }
            } catch {
                // 在真實應用中應處理錯誤
                print("登入或建立使用者時發生錯誤: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
    
    @MainActor
    private func handleQuickSelect(user: UserProfile) {
        user.lastLoginAt = Date()
        try? modelContext.save()
        onLoginSuccess(user.id)
    }
}

#Preview {
    SimpleLoginView(onLoginSuccess: { _ in print("登入成功！") })
        .modelContainer(for: [UserProfile.self, MealEntry.self])
}

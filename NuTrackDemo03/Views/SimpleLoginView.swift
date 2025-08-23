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
    var onLoginSuccess: (UserProfile) -> Void
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var username: String = ""
    @State private var isLoading: Bool = false
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
                        logoSection
                        loginFormSection
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
                Text("營養追蹤，健康生活").font(.subheadline).foregroundColor(.secondary)
            }
        }
    }
    
    private var loginFormSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("歡迎使用").font(.title2).fontWeight(.semibold).foregroundColor(.primary)
                Text("請輸入您的使用者名稱開始使用").font(.subheadline).foregroundColor(.secondary).multilineTextAlignment(.center)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("使用者名稱").font(.subheadline).fontWeight(.medium).foregroundColor(.primary)
                TextField("請輸入您的名稱", text: $username).textFieldStyle(.roundedBorder).focused($isTextFieldFocused).font(.body).padding(.vertical, 4).background(Color.white).cornerRadius(8).shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1).onSubmit { if !username.isEmpty { handleLogin() } }
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
            Button(action: { withAnimation(.easeInOut(duration: 0.3)) { showQuickSelect.toggle() } }) {
                HStack {
                    Image(systemName: showQuickSelect ? "chevron.up" : "chevron.down").font(.caption)
                    Text("快速選擇使用者").font(.caption)
                }.foregroundColor(.secondary)
            }
        }.padding(.horizontal, 8)
    }
    
    private var quickSelectSection: some View {
        VStack(spacing: 16) {
            Text("快速選擇（開發用）").font(.subheadline).fontWeight(.medium).foregroundColor(.secondary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(["陳大文", "林小美", "新用戶"], id: \.self) { user in
                    Button(action: { handleQuickSelect(user: user) }) {
                        Text(user).font(.subheadline).fontWeight(.medium).foregroundColor(.primaryBlue).padding(.vertical, 12).padding(.horizontal, 16).frame(maxWidth: .infinity)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.primaryBlue.opacity(0.1)).overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.primaryBlue.opacity(0.3), lineWidth: 1)))
                    }
                }
            }
        }.padding(.horizontal, 8).transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Helper Functions
    
    @MainActor
    private func handleLogin() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else { return }
        
        isTextFieldFocused = false
        isLoading = true
        
        // 模擬網路延遲
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let descriptor = FetchDescriptor<UserProfile>(predicate: #Predicate { $0.name == trimmedUsername })
            
            do {
                if let existingUser = try modelContext.fetch(descriptor).first {
                    print("使用者 \(trimmedUsername) 已存在，直接登入。")
                    onLoginSuccess(existingUser)
                } else {
                    print("使用者 \(trimmedUsername) 不存在，建立新使用者並登入。")
                    let newUser = UserProfile(name: trimmedUsername)
                    modelContext.insert(newUser)
                    try modelContext.save()
                    onLoginSuccess(newUser)
                }
            } catch {
                // 在真實應用中應處理錯誤
                print("登入或建立使用者時發生錯誤: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
    
    @MainActor
    private func handleQuickSelect(user: String) {
        self.username = user
        handleLogin()
    }
}

#Preview {
    SimpleLoginView(onLoginSuccess: { _ in print("登入成功！") })
        .modelContainer(for: [UserProfile.self, MealEntry.self])
}
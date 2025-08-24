//
//  NuTrackDemo03App.swift
//  NuTrackDemo03
//
//  Created by 訪客使用者 on 2025/8/1.
//

import SwiftUI
import SwiftData

@main
struct NuTrackDemo03App: App {
    @State private var currentUser: UserProfile?
    @State private var userPendingSetup: UserProfile?
    
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: UserProfile.self, MealEntry.self)
        } catch {
            fatalError("無法建立 ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let user = currentUser {
                    MainAppView(user: user, onLogout: {
                        withAnimation {
                            currentUser = nil
                            userPendingSetup = nil
                        }
                    })
                } else if let setupUser = userPendingSetup {
                    // 首次登入：使用整合後的 UserProfileView 並顯示歡迎文字
                    UserProfileView(user: setupUser, isFirstLogin: true, onCompleteSetup: {
                        withAnimation {
                            currentUser = setupUser
                            userPendingSetup = nil
                        }
                    })
                } else {
                    LoginView(onLoginSuccess: { userID in
                        let modelContext = modelContainer.mainContext
                        let fetched = try? modelContext.fetch(FetchDescriptor<UserProfile>(predicate: #Predicate<UserProfile> { $0.id == userID }))
                        if let user = fetched?.first {
                            withAnimation {
                                if user.weightInKg == nil {
                                    userPendingSetup = user
                                    currentUser = nil
                                } else {
                                    currentUser = user
                                    userPendingSetup = nil
                                }
                            }
                        }
                    })
                }
            }
            .animation(.easeInOut(duration: 0.4), value: currentUser?.id)
            .task { loadMostRecentUserIfExists() }
            // 暫時註解掉種子數據初始化
            // .onAppear {
            //     Task { @MainActor in
            //         DataSeedingService.seedDatabase(modelContext: modelContainer.mainContext)
            //     }
            // }
        }
        .modelContainer(modelContainer)
    }

    /// 若資料庫已有使用者，啟動時自動載入最近一次登入的使用者
    private func loadMostRecentUserIfExists() {
        let context = modelContainer.mainContext
        do {
            let users = try context.fetch(FetchDescriptor<UserProfile>())
            guard !users.isEmpty else { return }
            let sorted = users.sorted { (lhs, rhs) in
                let l = lhs.lastLoginAt ?? .distantPast
                let r = rhs.lastLoginAt ?? .distantPast
                if l == r { return lhs.name < rhs.name }
                return l > r
            }
            if let recent = sorted.first {
                withAnimation {
                    if recent.weightInKg == nil {
                        self.userPendingSetup = recent
                        self.currentUser = nil
                    } else {
                        self.currentUser = recent
                        self.userPendingSetup = nil
                    }
                }
            }
        } catch {
            print("啟動時載入最近使用者失敗: \(error)")
        }
    }
}

/// 主應用程式介面包裝器
struct MainAppView: View {
    let user: UserProfile
    let onLogout: () -> Void
    
    var body: some View {
        HomeView(user: user, onLogout: onLogout)
            .onShake {
                // 開發用：搖動裝置可以登出
                #if DEBUG
                onLogout()
                #endif
            }
    }
}

// MARK: - Shake Gesture Detection (開發用)
extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}

struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(DeviceShakeViewModifier(action: action))
    }
}

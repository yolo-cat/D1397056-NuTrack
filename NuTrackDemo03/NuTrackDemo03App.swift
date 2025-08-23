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
    @State private var hasSeededDatabase = false
    
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: UserProfile.self, MealEntry.self)
        } catch {
            print("無法建立 ModelContainer: \(error)")
            // 創建一個基本的容器作為備用
            do {
                modelContainer = try ModelContainer(for: UserProfile.self, MealEntry.self)
            } catch {
                fatalError("無法建立備用 ModelContainer: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if let user = currentUser {
                    MainAppView(user: user, onLogout: {
                        withAnimation {
                            currentUser = nil
                        }
                    })
                } else {
                    SimpleLoginView(onLoginSuccess: { userID in
                        let modelContext = modelContainer.mainContext
                        do {
                            let user = try modelContext.fetch(FetchDescriptor<UserProfile>(predicate: #Predicate<UserProfile> { $0.id == userID })).first
                            withAnimation {
                                currentUser = user
                            }
                        } catch {
                            print("獲取用戶時發生錯誤: \(error.localizedDescription)")
                        }
                    })
                }
            }
            .animation(.easeInOut(duration: 0.4), value: currentUser?.id)
            .onAppear {
                // 在 UI 出現後執行數據種子填充，避免阻塞 App 啟動，但只執行一次
                if !hasSeededDatabase {
                    hasSeededDatabase = true
                    Task { @MainActor in
                        DataSeedingService.seedDatabase(modelContext: modelContainer.mainContext)
                    }
                }
            }
        }
        .modelContainer(modelContainer)
    }
}

/// 主應用程式介面包裝器
struct MainAppView: View {
    let user: UserProfile
    let onLogout: () -> Void
    
    var body: some View {
        // NewNutritionTrackerView 也需要被重構以接收 UserProfile
        NewNutritionTrackerView(user: user)
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

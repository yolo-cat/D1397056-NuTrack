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
    
    private let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: UserProfile.self, MealEntry.self)
            Task { @MainActor in
                DataSeedingService.seedDatabase(modelContext: modelContainer.mainContext)
            }
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
                        }
                    })
                } else {
                    SimpleLoginView(onLoginSuccess: { user in
                        withAnimation {
                            currentUser = user
                        }
                    })
                }
            }
            .animation(.easeInOut(duration: 0.4), value: currentUser?.id)
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

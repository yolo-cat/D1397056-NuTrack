//
//  NuTrackDemo03App.swift
//  NuTrackDemo03
//
//  Created by 訪客使用者 on 2025/8/1.
//

import SwiftUI

@main
struct NuTrackDemo03App: App {
    @StateObject private var userManager = SimpleUserManager()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if userManager.isLoggedIn {
                    // 主應用程式介面
                    MainAppView(userManager: userManager)
                } else {
                    // 登入頁面
                    SimpleLoginView(userManager: userManager)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: userManager.isLoggedIn)
        }
    }
}

/// 主應用程式介面包裝器
struct MainAppView: View {
    @ObservedObject var userManager: SimpleUserManager
    
    var body: some View {
        NewNutritionTrackerView(userManager: userManager)
            .onShake {
                // 開發用：搖動裝置可以登出
                #if DEBUG
                userManager.logout()
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

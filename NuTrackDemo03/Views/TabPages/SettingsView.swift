//
//  SettingsView.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI

struct SettingsView: View {
    @State private var dailyCalorieGoal = 1973
    @State private var carbsGoal = 120
    @State private var proteinGoal = 180
    @State private var fatGoal = 179
    @State private var notificationsEnabled = true
    @State private var mealReminders = true
    @State private var waterReminder = true
    @State private var selectedUnit: Unit = .metric
    @State private var showResetAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundGray.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // User profile section
                        userProfileSection
                        
                        // Nutrition goals section
                        nutritionGoalsSection
                        
                        // Notification settings
                        notificationSettingsSection
                        
                        // App preferences
                        appPreferencesSection
                        
                        // Data management
                        dataManagementSection
                        
                        // About section
                        aboutSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("重置資料", isPresented: $showResetAlert) {
            Button("取消", role: .cancel) { }
            Button("重置", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("這將清除所有飲食記錄和設定，此操作無法復原。")
        }
    }
    
    private var userProfileSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("用戶資料")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                // Profile avatar
                Circle()
                    .fill(Color.primaryBlue.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundColor(.primaryBlue)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("營養追蹤使用者")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("nutrack@example.com")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("使用 NuTrack 已 30 天")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    // Handle profile edit
                }) {
                    Text("編輯")
                        .font(.caption)
                        .foregroundColor(Color.primaryBlue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.primaryBlue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var nutritionGoalsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("營養目標")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("重置為預設") {
                    resetNutritionGoals()
                }
                .font(.caption)
                .foregroundColor(.primaryBlue)
            }
            
            VStack(spacing: 16) {
                goalSlider(
                    title: "每日卡路里目標",
                    value: $dailyCalorieGoal,
                    range: 1200...3000,
                    unit: "卡",
                    color: .primaryBlue
                )
                
                goalSlider(
                    title: "碳水化合物",
                    value: $carbsGoal,
                    range: 50...300,
                    unit: "g",
                    color: .carbsColor
                )
                
                goalSlider(
                    title: "蛋白質",
                    value: $proteinGoal,
                    range: 50...250,
                    unit: "g",
                    color: .proteinColor
                )
                
                goalSlider(
                    title: "脂肪",
                    value: $fatGoal,
                    range: 50...250,
                    unit: "g",
                    color: .fatColor
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func goalSlider(title: String, value: Binding<Int>, range: ClosedRange<Int>, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(value.wrappedValue) \(unit)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
            }
            
            Slider(value: Binding(
                get: { Double(value.wrappedValue) },
                set: { value.wrappedValue = Int($0) }
            ), in: Double(range.lowerBound)...Double(range.upperBound), step: 1) {
                Text(title)
            }
            .accentColor(color)
        }
    }
    
    private var notificationSettingsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("通知設定")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                settingToggle(
                    title: "啟用通知",
                    subtitle: "接收飲食提醒和營養建議",
                    isOn: $notificationsEnabled,
                    icon: "bell.fill"
                )
                
                settingToggle(
                    title: "餐點提醒",
                    subtitle: "在用餐時間提醒記錄飲食",
                    isOn: $mealReminders,
                    icon: "clock.fill"
                )
                .disabled(!notificationsEnabled)
                .opacity(notificationsEnabled ? 1.0 : 0.5)
                
                settingToggle(
                    title: "喝水提醒",
                    subtitle: "定時提醒補充水分",
                    isOn: $waterReminder,
                    icon: "drop.fill"
                )
                .disabled(!notificationsEnabled)
                .opacity(notificationsEnabled ? 1.0 : 0.5)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func settingToggle(title: String, subtitle: String, isOn: Binding<Bool>, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.primaryBlue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
    
    private var appPreferencesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("應用程式偏好")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "ruler.fill")
                        .font(.title3)
                        .foregroundColor(.primaryBlue)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("單位制")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("選擇計量單位系統")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Picker("單位制", selection: $selectedUnit) {
                        ForEach(Unit.allCases, id: \.self) { unit in
                            Text(unit.displayName).tag(unit)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding(.vertical, 4)
                
                navigationRow(
                    title: "語言設定",
                    subtitle: "選擇應用程式語言",
                    icon: "globe.fill",
                    value: "繁體中文"
                )
                
                navigationRow(
                    title: "主題外觀",
                    subtitle: "選擇應用程式外觀主題",
                    icon: "paintbrush.fill",
                    value: "跟隨系統"
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func navigationRow(title: String, subtitle: String, icon: String, value: String) -> some View {
        Button(action: {
            // Handle navigation
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.primaryBlue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
    
    private var dataManagementSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("資料管理")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                actionButton(
                    title: "匯出資料",
                    subtitle: "將飲食記錄匯出為 CSV 檔案",
                    icon: "square.and.arrow.up.fill",
                    color: .primaryBlue
                ) {
                    // Handle export
                }
                
                actionButton(
                    title: "同步資料",
                    subtitle: "與 iCloud 同步飲食記錄",
                    icon: "icloud.fill",
                    color: .green
                ) {
                    // Handle sync
                }
                
                actionButton(
                    title: "重置所有資料",
                    subtitle: "清除所有飲食記錄和設定",
                    icon: "trash.fill",
                    color: .red
                ) {
                    showResetAlert = true
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func actionButton(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
    
    private var aboutSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("關於")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                navigationRow(
                    title: "應用程式版本",
                    subtitle: "檢查更新和版本資訊",
                    icon: "info.circle.fill",
                    value: "1.0.0"
                )
                
                navigationRow(
                    title: "使用條款",
                    subtitle: "查看服務條款和隱私政策",
                    icon: "doc.text.fill",
                    value: ""
                )
                
                navigationRow(
                    title: "意見回饋",
                    subtitle: "幫助我們改善 NuTrack",
                    icon: "envelope.fill",
                    value: ""
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helper Functions
    
    private func resetNutritionGoals() {
        withAnimation(.easeInOut(duration: 0.3)) {
            dailyCalorieGoal = 1973
            carbsGoal = 120
            proteinGoal = 180
            fatGoal = 179
        }
    }
    
    private func resetAllData() {
        // Handle data reset
        resetNutritionGoals()
        notificationsEnabled = true
        mealReminders = true
        waterReminder = true
        selectedUnit = .metric
    }
}

// MARK: - Supporting Types

enum Unit: CaseIterable {
    case metric, imperial
    
    var displayName: String {
        switch self {
        case .metric: return "公制"
        case .imperial: return "英制"
        }
    }
}

#Preview {
    SettingsView()
}

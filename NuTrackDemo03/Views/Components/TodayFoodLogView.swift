import SwiftUI
import Foundation

// MARK: - 時段分類枚舉
enum TimeBasedCategory: String, CaseIterable {
    case lateNight = "深夜"      // 00:00 - 05:59
    case breakfast = "早餐"      // 06:00 - 10:59
    case lunch = "午餐"          // 11:00 - 15:59
    case dinner = "晚餐"         // 16:00 - 21:59
    case midnightSnack = "宵夜"  // 22:00 - 23:59
    
    var icon: String {
        switch self {
        case .lateNight: return "moon.zzz.fill"
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "sunset.fill"
        case .midnightSnack: return "moon.fill"
        }
    }
    
    /// 統一的時間分類方法
    static func categorize(from date: Date) -> TimeBasedCategory {
        let hour = Calendar.current.component(.hour, from: date)
        
        switch hour {
        case 0..<6:
            return .lateNight
        case 6..<11:
            return .breakfast
        case 11..<16:
            return .lunch
        case 16..<22:
            return .dinner
        default:
            return .midnightSnack
        }
    }
}

//
//  TodayFoodLogView.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI

struct TodayFoodLogView: View {
    let foodEntries: [MealEntry]
    @State private var animatedItems: Set<UUID> = []
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("今日記錄")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                
                Text(todayDateString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(foodEntries.enumerated()), id: \.element.id) { index, entry in
                    FoodEntryRowView(entry: entry)
                        .scaleEffect(animatedItems.contains(entry.id) ? 1.0 : 0.8)
                        .opacity(animatedItems.contains(entry.id) ? 1.0 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
                            .delay(Double(index) * 0.1),
                            value: animatedItems.contains(entry.id)
                        )
                        .onAppear {
                            animatedItems.insert(entry.id)
                        }
                }
            }
        }
        .onAppear {
            // Trigger animations for all items
            for entry in foodEntries {
                animatedItems.insert(entry.id)
            }
        }
    }
    
    private var todayDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: Date())
    }
}

struct FoodEntryRowView: View {
    let entry: MealEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Time circle with meal type icon or nutrition icon
            ZStack {
                Circle()
                    .fill(entryColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                VStack(spacing: 2) {
                    Image(systemName: entryIcon)
                        .font(.caption)
                        .foregroundColor(entryColor)
                    
                    // 新增時段標籤
                    Text(timeBasedCategory.rawValue)
                        .font(.caption2)
                        .fontWeight(.light)
                        .foregroundColor(entryColor.opacity(0.8))
                        .lineLimit(1)
                }
            }
            
            // Food description
            VStack(alignment: .leading, spacing: 4) {
                Text(timeText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("\(entry.calories) 卡路里")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Percentage badge
            Text("\(entry.carbs)g")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(entryColor)
                .cornerRadius(12)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var timeBasedCategory: TimeBasedCategory {
        return TimeBasedCategory.categorize(from: entry.timestamp)
    }
    
    private var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: entry.timestamp)
    }
    
    private var entryColor: Color {
        switch timeBasedCategory {
        case .lateNight: return .purple
        case .breakfast: return .orange
        case .lunch: return .blue
        case .dinner: return .red
        case .midnightSnack: return .indigo
        }
    }
    
    private var entryIcon: String {
        return timeBasedCategory.icon
    }
}

#Preview {
    ScrollView {
        VStack {
            TodayFoodLogView(foodEntries: [
                MealEntry(timestamp: Date().addingTimeInterval(-3600), carbs: 50, protein: 20, fat: 10),
                MealEntry(timestamp: Date(), carbs: 70, protein: 30, fat: 15),
                MealEntry(timestamp: Date().addingTimeInterval(3600), carbs: 30, protein: 10, fat: 5)
            ])
                .padding()
            
            Spacer(minLength: 100)
        }
    }
}

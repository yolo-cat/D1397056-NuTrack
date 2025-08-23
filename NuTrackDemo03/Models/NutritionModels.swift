//
//  NutritionModels.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

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
    static func categorize(from timestamp: Int64) -> TimeBasedCategory {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000)
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

// MARK: - View-Specific Models

/// 營養素資料結構
struct NutrientData {
    var current: Int
    var goal: Int
    var unit: String
    
    var progress: Double {
        Double(current) / Double(goal)
    }
    
    var percentage: Int {
        Int(progress * 100)
    }
}

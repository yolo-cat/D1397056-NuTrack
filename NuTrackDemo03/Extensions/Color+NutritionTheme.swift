//
//  Color+NutritionTheme.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension Color {
    // Main theme colors as specified in CSS requirements
    static let primaryBlue = Color(hex: "#4A90E2")     // 主色調: #4A90E2 (藍色)
    static let carbsColor = Color(hex: "#A5D6A7")      // Carbs: #A5D6A7 (綠色)
    static let proteinColor = Color(hex: "#8DB4E3")    // Protein: #8DB4E3 (淡藍色)
    static let fatColor = Color(hex: "#F29494")        // Fat: #F29494 (粉紅色)
    static let accentOrange = Color(hex: "#FFAB91")    // 強調色: #FFAB91 (橘色)
    static let backgroundGray = Color(hex: "#f8f9fa")  // 背景: #f8f9fa (淺灰)
}
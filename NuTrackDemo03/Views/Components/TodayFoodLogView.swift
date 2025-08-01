//
//  TodayFoodLogView.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI

struct TodayFoodLogView: View {
    let foodEntries: [FoodLogEntry]
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
    let entry: FoodLogEntry
    
    var body: some View {
        HStack(spacing: 12) {
            // Time circle with meal type icon
            ZStack {
                Circle()
                    .fill(mealTypeColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                VStack(spacing: 2) {
                    Image(systemName: entry.type.icon)
                        .font(.caption)
                        .foregroundColor(mealTypeColor)
                    
                    Text(entry.time)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(mealTypeColor)
                }
            }
            
            // Food description
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("\(entry.totalCalories) 卡路里")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("佔 \(entry.caloriePercentage)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Percentage badge
            Text("\(entry.caloriePercentage)%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(mealTypeColor)
                .cornerRadius(12)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var mealTypeColor: Color {
        switch entry.type {
        case .breakfast: return .accentOrange
        case .lunch: return .primaryBlue
        case .dinner: return .fatColor
        }
    }
}

// MARK: - Animation Helper Extension

extension View {
    func animateOnAppear(delay: Double = 0) -> some View {
        self.scaleEffect(0.8)
            .opacity(0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0).delay(delay)) {
                    // Animation will be handled by the parent view
                }
            }
    }
}

#Preview {
    ScrollView {
        VStack {
            TodayFoodLogView(foodEntries: FoodLogEntry.todayEntries)
                .padding()
            
            Spacer(minLength: 100)
        }
    }
}
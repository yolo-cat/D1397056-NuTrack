import SwiftUI

//
//  TodayFoodLogView.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

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
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon(for: entry.timestamp))
                    .font(.caption)
                    .foregroundColor(.accentColor)
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
                .background(Color.accentColor)
                .cornerRadius(12)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: entry.timestamp)
    }
    
    private func icon(for date: Date) -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 0..<6:  return "moon.zzz.fill"
        case 6..<11: return "sunrise.fill"
        case 11..<16: return "sun.max.fill"
        case 16..<22: return "sunset.fill"
        default:     return "moon.fill"
        }
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
//
//  DiaryView.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI

struct DiaryView: View {
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundGray.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Date selector
                        dateSelectionSection
                        
                        // Weekly overview chart placeholder
                        weeklyOverviewSection
                        
                        // Detailed food log
                        detailedFoodLogSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("飲食日記")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var dateSelectionSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("選擇日期")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    showDatePicker.toggle()
                }) {
                    HStack {
                        Text(dateFormatter.string(from: selectedDate))
                            .font(.subheadline)
                            .foregroundColor(.primaryBlue)
                        
                        Image(systemName: "calendar")
                            .font(.subheadline)
                            .foregroundColor(.primaryBlue)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.primaryBlue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            if showDatePicker {
                DatePicker(
                    "選擇日期",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.wheel)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .animation(.easeInOut, value: showDatePicker)
    }
    
    private var weeklyOverviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("本週概覽")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("平均 1,850 卡")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Placeholder for weekly chart
            HStack(spacing: 8) {
                ForEach(0..<7) { day in
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.primaryBlue.opacity(Double.random(in: 0.3...1.0)))
                            .frame(height: CGFloat.random(in: 40...100))
                        
                        Text("週\(day + 1)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var detailedFoodLogSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("詳細記錄")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVStack(spacing: 12) {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    mealTypeSection(mealType)
                }
            }
        }
    }
    
    private func mealTypeSection(_ mealType: MealType) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: mealType.icon)
                    .font(.title3)
                    .foregroundColor(.primaryBlue)
                
                Text(mealType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("650 卡")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Sample food items for this meal type
            VStack(spacing: 8) {
                ForEach(sampleFoodsFor(mealType), id: \.self) { food in
                    HStack {
                        Text(food)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(Int.random(in: 100...300)) 卡")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func sampleFoodsFor(_ mealType: MealType) -> [String] {
        switch mealType {
        case .breakfast:
            return ["煎蛋", "全麥吐司", "無糖豆漿"]
        case .lunch:
            return ["雞胸肉沙拉", "糙米飯"]
        case .dinner:
            return ["香煎鮭魚", "蒸蔬菜"]
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter
    }
}

#Preview {
    DiaryView()
}

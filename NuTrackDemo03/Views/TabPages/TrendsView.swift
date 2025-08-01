//
//  TrendsView.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI

struct TrendsView: View {
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedMetric: NutritionMetric = .calories
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundGray.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Time range selector
                        timeRangeSelector
                        
                        // Main trend chart
                        trendChartSection
                        
                        // Nutrition metrics selector
                        nutritionMetricsSelector
                        
                        // Statistics summary
                        statisticsSummarySection
                        
                        // Achievement badges
                        achievementSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("趨勢分析")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var timeRangeSelector: some View {
        VStack(spacing: 16) {
            timeRangeHeader
            timeRangeButtons
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var timeRangeHeader: some View {
        HStack {
            Text("時間範圍")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
    }

    private var timeRangeButtons: some View {
        HStack(spacing: 12) {
            ForEach(TimeRange.allCases, id: \.self) { range in
                timeRangeButton(for: range)
            }
            Spacer()
        }
    }

    private func timeRangeButton(for range: TimeRange) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTimeRange = range
            }
        }) {
            Text(range.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(selectedTimeRange == range ? Color.white : Color.primaryBlue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selectedTimeRange == range ? Color.primaryBlue : Color.primaryBlue.opacity(0.1))
                .cornerRadius(20)
        }
    }
    private var trendChartSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("營養攝取趨勢")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("平均: \(averageValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Simplified trend chart
            trendChart
                .frame(height: 200)
                .animation(.easeInOut(duration: 1.0), value: selectedMetric)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var trendChart: some View {
        GeometryReader { geometry in
            let data = chartDataFor(selectedMetric)
            let maxValue = data.max() ?? 1
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                // Grid lines
                VStack {
                    ForEach(0..<5) { i in
                        if i > 0 {
                            Rectangle()
                                .fill(.gray.opacity(0.2))
                                .frame(height: 0.5)
                        }
                        Spacer()
                    }
                }
                
                // Chart line
                Path { path in
                    for (index, value) in data.enumerated() {
                        let x = width * CGFloat(index) / CGFloat(data.count - 1)
                        let y = height * (1 - CGFloat(value) / CGFloat(maxValue))
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(selectedMetric.color, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                
                // Data points
                ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                    Circle()
                        .fill(selectedMetric.color)
                        .frame(width: 8, height: 8)
                        .position(
                            x: width * CGFloat(index) / CGFloat(data.count - 1),
                            y: height * (1 - CGFloat(value) / CGFloat(maxValue))
                        )
                }
                
                // X-axis labels
                HStack {
                    ForEach(xAxisLabels, id: \.self) { label in
                        Text(label)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .position(x: width / 2, y: height + 15)
            }
        }
        .padding(.horizontal, 10)
    }
    
    private var nutritionMetricsSelector: some View {
        VStack(spacing: 16) {
            HStack {
                Text("營養指標")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(NutritionMetric.allCases, id: \.self) { metric in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedMetric = metric
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: metric.icon)
                                .font(.title2)
                                .foregroundColor(selectedMetric == metric ? .white : metric.color)
                            
                            Text(metric.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(selectedMetric == metric ? .white : metric.color)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(selectedMetric == metric ? metric.color : metric.color.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var statisticsSummarySection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("統計摘要")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                statisticCard("最高", value: "\(maxValue)", color: .green)
                statisticCard("最低", value: "\(minValue)", color: .red)
                statisticCard("平均", value: "\(averageValue)", color: .primaryBlue)
                statisticCard("目標達成", value: "\(achievementRate)%", color: .accentOrange)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func statisticCard(_ title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var achievementSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("成就徽章")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                achievementBadge("連續7天", icon: "flame.fill", isUnlocked: true)
                achievementBadge("營養均衡", icon: "leaf.fill", isUnlocked: true)
                achievementBadge("目標達成", icon: "target", isUnlocked: false)
                achievementBadge("健康飲食", icon: "heart.fill", isUnlocked: true)
                achievementBadge("完美一週", icon: "star.fill", isUnlocked: false)
                achievementBadge("堅持30天", icon: "crown.fill", isUnlocked: false)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func achievementBadge(_ title: String, icon: String, isUnlocked: Bool) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isUnlocked ? .primaryBlue : .gray)
            
            Text(title)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(isUnlocked ? .primary : .gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(isUnlocked ? Color.primaryBlue.opacity(0.1) : .gray.opacity(0.1))
        .cornerRadius(12)
        .opacity(isUnlocked ? 1.0 : 0.5)
    }
    
    // MARK: - Computed Properties
    
    private var averageValue: String {
        let data = chartDataFor(selectedMetric)
        let average = data.reduce(0, +) / data.count
        return "\(average)\(selectedMetric.unit)"
    }
    
    private var maxValue: String {
        let data = chartDataFor(selectedMetric)
        let max = data.max() ?? 0
        return "\(max)\(selectedMetric.unit)"
    }
    
    private var minValue: String {
        let data = chartDataFor(selectedMetric)
        let min = data.min() ?? 0
        return "\(min)\(selectedMetric.unit)"
    }
    
    private var achievementRate: Int {
        Int.random(in: 65...95)
    }
    
    private var xAxisLabels: [String] {
        switch selectedTimeRange {
        case .week:
            return ["週一", "週二", "週三", "週四", "週五", "週六", "週日"]
        case .month:
            return ["第1週", "第2週", "第3週", "第4週"]
        case .year:
            return ["1月", "3月", "5月", "7月", "9月", "11月"]
        }
    }
    
    private func chartDataFor(_ metric: NutritionMetric) -> [Int] {
        switch selectedTimeRange {
        case .week:
            return Array(0..<7).map { _ in Int.random(in: metric.range) }
        case .month:
            return Array(0..<4).map { _ in Int.random(in: metric.range) }
        case .year:
            return Array(0..<6).map { _ in Int.random(in: metric.range) }
        }
    }
}

// MARK: - Supporting Types

enum TimeRange: CaseIterable {
    case week, month, year
    
    var displayName: String {
        switch self {
        case .week: return "本週"
        case .month: return "本月"
        case .year: return "本年"
        }
    }
}

enum NutritionMetric: CaseIterable {
    case calories, carbs, protein, fat
    
    var displayName: String {
        switch self {
        case .calories: return "卡路里"
        case .carbs: return "碳水化合物"
        case .protein: return "蛋白質"
        case .fat: return "脂肪"
        }
    }
    
    var icon: String {
        switch self {
        case .calories: return "flame.fill"
        case .carbs: return "leaf.fill"
        case .protein: return "dumbbell.fill"
        case .fat: return "drop.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .calories: return .primaryBlue
        case .carbs: return .carbsColor
        case .protein: return .proteinColor
        case .fat: return .fatColor
        }
    }
    
    var unit: String {
        switch self {
        case .calories: return "卡"
        case .carbs, .protein, .fat: return "g"
        }
    }
    
    var range: ClosedRange<Int> {
        switch self {
        case .calories: return 1200...2200
        case .carbs: return 80...150
        case .protein: return 100...200
        case .fat: return 100...180
        }
    }
}

#Preview {
    TrendsView()
}

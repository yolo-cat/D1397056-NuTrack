//
//  NutritionTrackerView.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    let user: UserProfile
    let onLogout: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Query private var mealEntries: [MealEntry]
    
    @State private var showAddNutrition = false
    
    init(user: UserProfile, onLogout: @escaping () -> Void) {
        self.user = user
        self.onLogout = onLogout
        
        // Dynamically configure the @Query to fetch meal entries
        // for the current user and for today only.
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!
        let userID = user.id
        
        self._mealEntries = Query(
            filter: #Predicate<MealEntry> {
                $0.user?.id == userID && $0.timestamp >= startOfToday && $0.timestamp < endOfToday
            },
            sort: [SortDescriptor(\.timestamp, order: .reverse)]
        )
    }
    
    // MARK: - Computed Properties
    
    private var nutritionData: NutritionSummaryViewModel {
        return NutritionSummaryViewModel(user: user, meals: mealEntries)
    }
    
    private var foodLogEntries: [MealEntry] {
        return mealEntries
    }
    
    // MARK: - Main Body
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                mainNutritionView
                addMealButton
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showAddNutrition) {
            AddNutritionView { nutritionInfo in
                addNutritionEntry(nutritionInfo)
            }
        }
    }
    
    // MARK: - View Components
    
    private var mainNutritionView: some View {
        ZStack {
            Color.backgroundGray.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 0) {
                HeadView(user: user, onLogout: onLogout)
                ScrollView {
                    VStack(spacing: 24) {
                        ProgSect(nutritionData: nutritionData)
                        TodayLog(foodEntries: foodLogEntries)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 80) // Add padding for floating button
                }
            }
        }
    }
    
    private var addMealButton: some View {
        Button(action: { showAddNutrition = true }) {
            ZStack {
                Circle().fill(Color.primaryBlue).frame(width: 60, height: 60)
                    .shadow(color: .primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                Image(systemName: "plus").font(.title2).fontWeight(.bold).foregroundColor(.white)
            }
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - Helper Functions
    
    private func deleteMeal(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let mealToDelete = mealEntries[index]
                modelContext.delete(mealToDelete)
            }
            // 顯式保存刪除結果
            try? modelContext.save()
        }
    }
    
    private func addNutritionEntry(_ nutritionInfo: NutritionInfo) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            let newEntry = MealEntry(
                name: nutritionInfo.name,
                carbs: nutritionInfo.carbs,
                protein: nutritionInfo.protein,
                fat: nutritionInfo.fat
            )
            newEntry.user = user
            modelContext.insert(newEntry)
            // 顯式保存新增結果
            try? modelContext.save()
        }
    }
}

// MARK: - Components • Header (Top of screen)
struct HeadView: View {
    let user: UserProfile
    let onLogout: () -> Void
    
    var body: some View {
        HStack {
            Text("NuTrack")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primaryBlue)
            
            Spacer()
            
            NavigationLink(destination: UserProfileView(user: user, onLogout: onLogout)) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.primaryBlue)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                    
                    Text(user.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primaryBlue)
                        .lineLimit(1)
                }
            }
            .accessibilityLabel("用戶資料: \(user.name)")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview("HeadView") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    let sampleUser = UserProfile(name: "預覽用戶", weightInKg: 70)
    container.mainContext.insert(sampleUser)
    return NavigationStack { HeadView(user: sampleUser, onLogout: {}) }
        .modelContainer(container)
        .padding()
}

// MARK: - Components • Nutrition Progress (Section + Bar)
struct ProgSect: View {
    let nutritionData: NutritionData
    @State private var animationDelays: [Double] = [0, 0.2, 0.4]
    @State private var showProgress = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("今日營養進度")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 16) {
                ProgBar(
                    title: "碳水化合物",
                    nutrientData: nutritionData.carbs,
                    calorieInfo: nutritionData.macronutrientCaloriesDistribution.carbs,
                    color: .carbsColor,
                    showProgress: showProgress
                )
                .opacity(showProgress ? 1 : 0)
                .animation(.easeInOut(duration: 0.8).delay(animationDelays[0]), value: showProgress)
                
                ProgBar(
                    title: "蛋白質",
                    nutrientData: nutritionData.protein,
                    calorieInfo: nutritionData.macronutrientCaloriesDistribution.protein,
                    color: .proteinColor,
                    showProgress: showProgress
                )
                .opacity(showProgress ? 1 : 0)
                .animation(.easeInOut(duration: 0.8).delay(animationDelays[1]), value: showProgress)
                
                ProgBar(
                    title: "脂肪",
                    nutrientData: nutritionData.fat,
                    calorieInfo: nutritionData.macronutrientCaloriesDistribution.fat,
                    color: .fatColor,
                    showProgress: showProgress
                )
                .opacity(showProgress ? 1 : 0)
                .animation(.easeInOut(duration: 0.8).delay(animationDelays[2]), value: showProgress)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.backgroundGray.opacity(0.5))
        .cornerRadius(16)
        .onAppear { showProgress = true }
    }
}

struct ProgBar: View {
    let title: String
    let nutrientData: NutritionData.Nutrient
    let calorieInfo: Int
    let color: Color
    let showProgress: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(nutrientData.percentage)%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(color)
                }
            }
            
            HStack {
                Text("\(nutrientData.current)\(nutrientData.unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("•")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(calorieInfo) 卡")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("目標 \(nutrientData.goal)\(nutrientData.unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [color.opacity(0.7), color]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: showProgress ? geometry.size.width * min(nutrientData.progress, 1.0) : 0,
                            height: 12
                        )
                        .animation(.easeInOut(duration: 1.0), value: showProgress)
                    
                    if showProgress && nutrientData.progress > 0 {
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                            .position(
                                x: min(geometry.size.width * nutrientData.progress, geometry.size.width - 3),
                                y: 6
                            )
                            .animation(.easeInOut(duration: 1.0).delay(0.5), value: showProgress)
                    }
                }
            }
            .frame(height: 12)
        }
        .padding(.vertical, 6)
    }
}

#Preview("ProgSect") {
    ProgSect(nutritionData: .sample)
        .padding()
        .background(Color.white)
}

#Preview("ProgBar") {
    let nutrient = NutritionData.Nutrient(current: 120, goal: 200, unit: "g")
    return ProgBar(
         title: "碳水化合物",
         nutrientData: nutrient,
         calorieInfo: 480,
         color: .carbsColor,
         showProgress: true
     )
     .padding()
     .background(Color.white)
}

// MARK: - Components • Today Food Log (List + Row)
struct TodayLog: View {
    let foodEntries: [MealEntry]
    @State private var animatedItems: Set<UUID> = []
    @Environment(\.modelContext) private var modelContext
    
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
                    LogRow(entry: entry)
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
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                delete(entry)
                            } label: {
                                Label("刪除", systemImage: "trash")
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                delete(entry)
                            } label: {
                                Label("刪除", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .onAppear {
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
    
    private func delete(_ entry: MealEntry) {
        withAnimation {
            modelContext.delete(entry)
            // 顯式保存刪除結果
            try? modelContext.save()
        }
    }
}

struct LogRow: View {
    let entry: MealEntry
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon(for: entry.timestamp))
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }
            
            // 左側：餐點名稱、時間、熱量 VStack
            VStack(alignment: .leading, spacing: 4) {
                Text((entry.name ?? "").isEmpty ? timeText : (entry.name ?? ""))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                    .truncationMode(.tail)
                
                Text(timeText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text("\(entry.calories) 大卡")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Spacer()
            
            // 右側：膠囊群組
            if hasAnyMacro {
                HStack(spacing: 8) {
                    if entry.carbs > 0 { macroPill(value: entry.carbs, color: .carbsColor) }
                    if entry.protein > 0 { macroPill(value: entry.protein, color: .proteinColor) }
                    if entry.fat > 0 { macroPill(value: entry.fat, color: .fatColor) }
                }
                .layoutPriority(1)
            }
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
    
    // 任何一項宏量營養素是否存在
    private var hasAnyMacro: Bool { entry.carbs > 0 || entry.protein > 0 || entry.fat > 0 }
    
    // 三大營養膠囊：固定為 3 位數寬度，超過時縮放避免截斷
    private func macroPill(value: Int, color: Color) -> some View {
        ZStack {
            // 以 3 位數等寬數字作為隱形佔位，鎖定膠囊寬度
            Text("000")
                .font(.caption)
                .fontWeight(.bold)
                .monospacedDigit()
                .opacity(0)
            
            // 實際顯示的數值
            Text("\(value)")
                .font(.caption)
                .fontWeight(.bold)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color)
        .cornerRadius(12)
    }
}

#Preview("TodayLog") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, MealEntry.self, configurations: config)
    let u = UserProfile(name: "預覽用戶")
    container.mainContext.insert(u)
    let items: [MealEntry] = [
        MealEntry(name: "早餐", timestamp: Date().addingTimeInterval(-3600), carbs: 50, protein: 20, fat: 10),
        MealEntry(name: "午餐", timestamp: Date(), carbs: 70, protein: 30, fat: 15),
        MealEntry(name: "晚餐", timestamp: Date().addingTimeInterval(3600), carbs: 30, protein: 10, fat: 5)
    ]
    items.forEach { $0.user = u; container.mainContext.insert($0) }
    return ScrollView { TodayLog(foodEntries: items).padding() }
        .modelContainer(container)
}

#Preview("LogRow") {
    let entry = MealEntry(name: "優格+燕麥", timestamp: Date(), carbs: 35, protein: 15, fat: 8)
    return LogRow(entry: entry)
        .padding()
        .background(Color.white)
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, MealEntry.self, configurations: config)
    
    let sampleUser = UserProfile(name: "預覽用戶", weightInKg: 72.5)
    container.mainContext.insert(sampleUser)
    
    // Create some sample meal entries for the preview
    let sampleMeal1 = MealEntry(name: "早餐", carbs: 50, protein: 25, fat: 10)
    sampleMeal1.user = sampleUser
    container.mainContext.insert(sampleMeal1)
    
    let sampleMeal2 = MealEntry(name: "午餐", carbs: 30, protein: 15, fat: 5)
    sampleMeal2.user = sampleUser
    container.mainContext.insert(sampleMeal2)
    
    return HomeView(user: sampleUser, onLogout: { print("Preview logout action") })
        .modelContainer(container)
}

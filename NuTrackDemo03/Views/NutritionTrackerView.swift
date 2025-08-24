//
//  NutritionTrackerView.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI
import SwiftData

struct NewNutritionTrackerView: View {
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
                HeaderView(user: user, onLogout: onLogout)
                ScrollView {
                    VStack(spacing: 24) {
                        NutritionProgressSection(nutritionData: nutritionData)
                        TodayFoodLogView(foodEntries: foodLogEntries)
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
        }
    }
}

// MARK: - Components • Header (Top of screen)
struct HeaderView: View {
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

#Preview("HeaderView") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    let sampleUser = UserProfile(name: "預覽用戶", weightInKg: 70)
    container.mainContext.insert(sampleUser)
    return NavigationStack { HeaderView(user: sampleUser, onLogout: {}) }
        .modelContainer(container)
        .padding()
}

// MARK: - Components • Nutrition Progress (Section + Bar)
struct NutritionProgressSection: View {
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
                NutritionProgressBar(
                    title: "碳水化合物",
                    nutrientData: nutritionData.carbs,
                    calorieInfo: nutritionData.macronutrientCaloriesDistribution.carbs,
                    color: .carbsColor,
                    showProgress: showProgress
                )
                .opacity(showProgress ? 1 : 0)
                .animation(.easeInOut(duration: 0.8).delay(animationDelays[0]), value: showProgress)
                
                NutritionProgressBar(
                    title: "蛋白質",
                    nutrientData: nutritionData.protein,
                    calorieInfo: nutritionData.macronutrientCaloriesDistribution.protein,
                    color: .proteinColor,
                    showProgress: showProgress
                )
                .opacity(showProgress ? 1 : 0)
                .animation(.easeInOut(duration: 0.8).delay(animationDelays[1]), value: showProgress)
                
                NutritionProgressBar(
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

struct NutritionProgressBar: View {
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

#Preview("NutritionProgressSection") {
    NutritionProgressSection(nutritionData: .sample)
        .padding()
        .background(Color.white)
}

#Preview("NutritionProgressBar") {
    let nutrient = NutritionData.Nutrient(current: 120, goal: 200, unit: "g")
    return NutritionProgressBar(
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
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon(for: entry.timestamp))
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text((entry.name ?? "").isEmpty ? timeText : (entry.name ?? ""))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("\(timeText) • \(entry.calories) 卡路里")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
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

#Preview("TodayFoodLogView") {
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
    return ScrollView { TodayFoodLogView(foodEntries: items).padding() }
        .modelContainer(container)
}

#Preview("FoodEntryRowView") {
    let entry = MealEntry(name: "優格+燕麥", timestamp: Date(), carbs: 35, protein: 15, fat: 8)
    return FoodEntryRowView(entry: entry)
        .padding()
        .background(Color.white)
}

// MARK: - Components • Custom Tab (TabView + TabItem + Alternative Bar)
struct CustomTabView: View {
    @Binding var selectedTab: Int
    let onAddMeal: () -> Void
    
    var body: some View {
        ZStack {
            // Main tab view
            TabView(selection: $selectedTab) {
                // Home Tab
                Group { EmptyView() }
                    .tabItem { Image(systemName: "house.fill"); Text("Home") }
                    .tag(0)
                
                // Diary Tab
                Group { EmptyView() }
                    .tabItem { Image(systemName: "book.fill"); Text("Diary") }
                    .tag(1)
                
                // Spacer for center button
                Group { EmptyView() }
                    .tabItem { Image(systemName: ""); Text("") }
                    .tag(2)
                
                // Trends Tab
                Group { EmptyView() }
                    .tabItem { Image(systemName: "chart.line.uptrend.xyaxis"); Text("Trends") }
                    .tag(3)
                
                // Settings Tab
                Group { EmptyView() }
                    .tabItem { Image(systemName: "gearshape.fill"); Text("Settings") }
                    .tag(4)
            }
            .accentColor(Color.primaryBlue)
            
            // Floating Add Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            onAddMeal()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.primaryBlue)
                                .frame(width: 60, height: 60)
                                .shadow(color: Color.primaryBlue.opacity(0.3), radius: 10, x: 0, y: 5)
                            Image(systemName: "plus")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                    Spacer()
                }
                .padding(.bottom, 30)
            }
        }
    }
}

private struct _CustomTabPreviewWrapper: View {
    @State private var tab = 0
    var body: some View {
        CustomTabView(selectedTab: $tab, onAddMeal: {})
    }
}

#Preview("CustomTabView") {
    _CustomTabPreviewWrapper()
}

struct TabItem {
    let icon: String
    let title: String
    let tag: Int
}

extension TabItem {
    static let allTabs: [TabItem] = [
        TabItem(icon: "house.fill", title: "Home", tag: 0),
        TabItem(icon: "book.fill", title: "Diary", tag: 1),
        TabItem(icon: "plus.circle.fill", title: "Add", tag: 2),
        TabItem(icon: "chart.line.uptrend.xyaxis", title: "Trends", tag: 3),
        TabItem(icon: "gearshape.fill", title: "Settings", tag: 4)
    ]
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
    
    return NewNutritionTrackerView(user: sampleUser, onLogout: { print("Preview logout action") })
        .modelContainer(container)
}

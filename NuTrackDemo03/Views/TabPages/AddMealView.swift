//
//  AddMealView.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI

struct AddMealView: View {
    @State private var selectedMealType: MealType = .breakfast
    @State private var searchText = ""
    @State private var selectedFoods: [MealItem] = []
    @State private var showSuccessAnimation = false
    
    let onMealAdded: (FoodLogEntry) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundGray.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Meal type selector
                        mealTypeSelector
                        
                        // Food search section
                        foodSearchSection
                        
                        // Available foods
                        availableFoodsSection
                        
                        // Selected foods summary
                        if !selectedFoods.isEmpty {
                            selectedFoodsSummary
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Success animation overlay
                if showSuccessAnimation {
                    successAnimationOverlay
                }
            }
            .navigationTitle("新增餐點")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        addMeal()
                    }
                    .disabled(selectedFoods.isEmpty)
                    .foregroundColor(selectedFoods.isEmpty ? .gray : .primaryBlue)
                }
            }
        }
    }
    
    private var mealTypeSelector: some View {
        VStack(spacing: 16) {
            mealTypeHeader
            mealTypeButtons
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var mealTypeHeader: some View {
        HStack {
            Text("餐點類型")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
    }

    private var mealTypeButtons: some View {
        HStack(spacing: 12) {
            ForEach(MealType.allCases, id: \.self) { mealType in
                mealTypeButton(for: mealType)
            }
        }
    }

    private func mealTypeButton(for mealType: MealType) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedMealType = mealType
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: mealType.icon)
                    .font(.title2)
                    .foregroundColor(selectedMealType == mealType ? Color.white : Color.primaryBlue)
                
                Text(mealType.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(selectedMealType == mealType ? Color.white : Color.primaryBlue)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(selectedMealType == mealType ? Color.primaryBlue : Color.primaryBlue.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private var foodSearchSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("搜尋食物")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("輸入食物名稱...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var availableFoodsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("常見食物")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(filteredFoods, id: \.id) { food in
                    foodItemCard(food)
                }
            }
        }
    }
    
    private func foodItemCard(_ food: MealItem) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if selectedFoods.contains(where: { $0.id == food.id }) {
                    selectedFoods.removeAll { $0.id == food.id }
                } else {
                    selectedFoods.append(food)
                }
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(food.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if selectedFoods.contains(where: { $0.id == food.id }) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.primaryBlue)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(food.nutrition.calories) 卡路里")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("碳: \(food.nutrition.carbs)g")
                        Text("蛋: \(food.nutrition.protein)g")
                        Text("脂: \(food.nutrition.fat)g")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(selectedFoods.contains(where: { $0.id == food.id }) ? 
                        Color.primaryBlue.opacity(0.1) : .white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedFoods.contains(where: { $0.id == food.id }) ? 
                            Color.primaryBlue : .clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
    
    private var selectedFoodsSummary: some View {
        VStack(spacing: 16) {
            HStack {
                Text("已選擇 (\(selectedFoods.count))")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("總計 \(totalCalories) 卡")
                    .font(.subheadline)
                    .foregroundColor(.primaryBlue)
                    .fontWeight(.medium)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(selectedFoods, id: \.id) { food in
                    HStack {
                        Text(food.name)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(food.nutrition.calories) 卡")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFoods.removeAll { $0.id == food.id }
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.gray.opacity(0.1))
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
    
    private var successAnimationOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showSuccessAnimation = false
                    }
                }
            
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .scaleEffect(showSuccessAnimation ? 1.0 : 0.1)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showSuccessAnimation)
                
                Text("餐點新增成功！")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .opacity(showSuccessAnimation ? 1.0 : 0)
                    .animation(.easeInOut(duration: 0.3).delay(0.2), value: showSuccessAnimation)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 30)
            .background(.white)
            .cornerRadius(20)
            .shadow(radius: 20)
        }
    }
    
    private var filteredFoods: [MealItem] {
        let foods = MealItem.mockMeals.filter { $0.type == selectedMealType }
        if searchText.isEmpty {
            return foods
        } else {
            return foods.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private var totalCalories: Int {
        selectedFoods.reduce(0) { $0 + $1.nutrition.calories }
    }
    
    private func addMeal() {
        guard !selectedFoods.isEmpty else { return }
        
        let currentTime = timeFormatter.string(from: Date())
        let newEntry = FoodLogEntry(
            time: currentTime,
            meals: selectedFoods,
            type: selectedMealType
        )
        
        onMealAdded(newEntry)
        
        // Show success animation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showSuccessAnimation = true
        }
        
        // Reset form after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSuccessAnimation = false
                selectedFoods.removeAll()
                searchText = ""
            }
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}

#Preview {
    AddMealView { entry in
        print("Added meal: \(entry.description)")
    }
}

//
//  AddNutritionView.swift
//  NuTrackDemo03
//
//  Created by NuTrack on 2024/8/20.
//

import SwiftUI

// Local struct for encapsulating user input, decoupled from core MealEntry model
struct NutritionInfo {
    var name: String
    var carbs: Int
    var protein: Int
    var fat: Int
}

// Supply a struct to hold user input from the form
enum InputFieldFocus: Hashable { case name, carbs, protein, fat }

struct AddNutritionView: View {
    @State private var nameInput: String = ""
    @State private var carbsInput: String = ""
    @State private var proteinInput: String = ""
    @State private var fatInput: String = ""
    // 替換為 iOS 17 建議的 dismiss API
    @Environment(\.dismiss) private var dismiss
    // 新增：管理鍵盤焦點
    @FocusState private var focusedField: InputFieldFocus?
    
    let onNutritionAdded: (NutritionInfo) -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundGray.opacity(0.3)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Meal name input
                        mealNameSection
                        
                        // Nutrition input fields
                        nutritionInputSection
                        
                        // Calorie calculation preview
                        caloriePreviewSection
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle("記錄營養")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        addNutrition()
                    }
                    .disabled(!isInputValid)
                    .foregroundColor(isInputValid ? .primaryBlue : .gray)
                    .fontWeight(.medium)
                }
                
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        if focusedField == .fat {
                            Button("完成") {
                                focusedField = nil
                            }
                        } else {
                            Button("下一個") {
                                focusNextField()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.primaryBlue)
            
            Text("輸入三大營養素攝取量")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("輸入公克數，系統將自動計算熱量")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
    
    private var mealNameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("餐點名稱 (選填)")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            TextField("例如：雞胸肉沙拉", text: $nameInput)
                .font(.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit {
                    focusNextField()
                }
        }
        .padding(.horizontal, 20)
    }
    
    private var nutritionInputSection: some View {
        VStack(spacing: 16) {
            NutrientInputField(
                title: "碳水化合物",
                color: .carbsColor,
                value: $carbsInput,
                unit: "g",
                focus: $focusedField,
                field: .carbs
            )
            
            NutrientInputField(
                title: "蛋白質",
                color: .proteinColor,
                value: $proteinInput,
                unit: "g",
                focus: $focusedField,
                field: .protein
            )
            
            NutrientInputField(
                title: "脂肪",
                color: .fatColor,
                value: $fatInput,
                unit: "g",
                focus: $focusedField,
                field: .fat
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var caloriePreviewSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("熱量預覽")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(calculatedCalories) 卡")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryBlue)
            }
            
            // Calorie breakdown
//            VStack(spacing: 8) {
//                calorieBreakdownRow(title: "碳水化合物", grams: carbsGrams, caloriesPerGram: 4, color: .carbsColor)
//                calorieBreakdownRow(title: "蛋白質", grams: proteinGrams, caloriesPerGram: 4, color: .proteinColor)
//                calorieBreakdownRow(title: "脂肪", grams: fatGrams, caloriesPerGram: 9, color: .fatColor)
//            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .opacity(isInputValid ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.3), value: isInputValid)
    }
    
    private func calorieBreakdownRow(title: String, grams: Int, caloriesPerGram: Int, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(grams)g × \(caloriesPerGram) = \(grams * caloriesPerGram) 卡")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Computed Properties
    
    private var carbsGrams: Int {
        Int(carbsInput) ?? 0
    }
    
    private var proteinGrams: Int {
        Int(proteinInput) ?? 0
    }
    
    private var fatGrams: Int {
        Int(fatInput) ?? 0
    }
    
    private var calculatedCalories: Int {
        (carbsGrams * 4) + (proteinGrams * 4) + (fatGrams * 9)
    }
    
    private var isInputValid: Bool {
        carbsGrams > 0 || proteinGrams > 0 || fatGrams > 0
    }
    
    // MARK: - Actions
    
    private func focusNextField() {
        switch focusedField {
        case .name:
            focusedField = .carbs
        case .carbs:
            focusedField = .protein
        case .protein:
            focusedField = .fat
        case .fat, .none:
            // It's the last field or no field is focused, dismiss the keyboard
            focusedField = nil
        }
    }
    
    private func addNutrition() {
        guard isInputValid else { return }
        
        let nutritionInfo = NutritionInfo(
            name: nameInput,
            carbs: carbsGrams,
            protein: proteinGrams,
            fat: fatGrams
        )
        
        onNutritionAdded(nutritionInfo)
        
        // 直接關閉視圖，停用成功動畫
        dismiss()
    }
}

// MARK: - Nutrient Input Field Component

struct NutrientInputField: View {
    let title: String
    let color: Color
    @Binding var value: String
    let unit: String
    // 新增：父層傳入的焦點綁定與此欄位識別
    let focus: FocusState<InputFieldFocus?>.Binding
    let field: InputFieldFocus
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            TextField("0", text: $value)
                .keyboardType(.numberPad)
                .submitLabel(field == .fat ? .done : .next)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(color)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(color.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
                .focused(focus, equals: field)
                .onChange(of: value) { _, newValue in
                    // 僅允許數字字元，移除非數字輸入（含貼上內容）
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue { value = filtered }
                }
        }
    }
}

#Preview {
    AddNutritionView { nutrition in
        print("Added nutrition: \(nutrition)")
    }
}

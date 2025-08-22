# NuTrack Application Data Structures Documentation

This document provides a comprehensive overview of all data structures and their relationships in the NuTrack nutrition tracking iOS application.

## Core Nutrition Data Models (NutritionModels.swift)

### 1. NutritionInfo
Basic nutrition information structure that records nutritional components of food items.

```swift
struct NutritionInfo {
    let calories: Int     // Calories
    let carbs: Int       // Carbohydrates (grams)
    let protein: Int     // Protein (grams)
    let fat: Int         // Fat (grams)
}
```

**Initializers:**
- `init(calories: Int, carbs: Int, protein: Int, fat: Int)` - Direct specification of all nutrients
- `init(carbsGrams: Int, proteinGrams: Int, fatGrams: Int)` - Auto-calculates calories from macronutrient weights

**Purpose:** Records nutritional information for individual food items or meals

### 2. MealType
Meal type enumeration that categorizes meals into three daily categories.

```swift
enum MealType: String, CaseIterable {
    case breakfast = "早餐"
    case lunch = "午餐"
    case dinner = "晚餐"
}
```

**Properties:**
- `icon: String` - Returns corresponding system icon name for each meal type

**Purpose:** Categorizes meal types and provides UI icon support

### 3. MealItem
Meal information structure representing a single meal item.

```swift
struct MealItem: Identifiable {
    let id = UUID()
    let name: String           // Meal name
    let type: MealType        // Meal type
    let time: String          // Meal time
    let nutrition: NutritionInfo  // Nutrition information
}
```

**Purpose:** Represents specific meal items with complete nutrition and timing information

### 4. DailyGoal
Daily nutrition goal structure that defines user's daily nutritional intake targets.

```swift
struct DailyGoal {
    let calories: Int    // Calorie target
    let carbs: Int      // Carbohydrate target (grams)
    let protein: Int    // Protein target (grams)
    let fat: Int        // Fat target (grams)
}
```

**Static Properties:**
- `standard` - Default nutrition goals (1973 calories)

**Extension Methods:**
- `personalized(for weight: Double)` - Creates personalized goals based on weight
- `custom(carbs: Int, protein: Int, fat: Int)` - Creates goals from custom nutrients

**Purpose:** Sets and tracks daily nutritional intake goals

### 5. NutrientData
Nutrient data structure that tracks intake progress for individual nutrients.

```swift
struct NutrientData {
    var current: Int    // Current intake
    var goal: Int       // Target intake
    var unit: String    // Unit (usually "g")
}
```

**Computed Properties:**
- `progress: Double` - Intake progress (0.0 - 1.0)
- `percentage: Int` - Intake percentage

**Purpose:** Tracks progress for individual nutrients

### 6. NutritionData
Main nutrition data structure that integrates all nutrition tracking information.

```swift
struct NutritionData {
    var caloriesConsumed: Int    // Calories consumed
    var caloriesBurned: Int      // Calories burned
    var caloriesGoal: Int        // Calorie goal
    var carbs: NutrientData      // Carbohydrate data
    var protein: NutrientData    // Protein data
    var fat: NutrientData        // Fat data
}
```

**Computed Properties:**
- `remainingCalories: Int` - Remaining consumable calories
- `calorieProgress: Double` - Calorie intake progress
- `totalNutrientProgress: Double` - Average progress across all nutrients
- `macronutrientCaloriesDistribution` - Calorie distribution across macronutrients
- `macronutrientPercentages` - Percentage distribution of macronutrients

**Purpose:** Core data structure of the application, integrating all nutrition tracking functionality

## Food Logging and Mock Data (MockData.swift)

### 7. FoodLogEntry
Daily food log entry that records user's dietary journal.

```swift
struct FoodLogEntry: Identifiable {
    let id = UUID()
    let time: String              // Log time
    let meals: [MealItem]?        // Meal list (legacy format)
    let type: MealType?           // Meal type (legacy format)
    let nutrition: NutritionInfo? // Nutrition info (new format)
}
```

**Initializers:**
- `init(time: String, meals: [MealItem], type: MealType)` - Legacy meal-based constructor
- `init(time: String, nutrition: NutritionInfo)` - New direct nutrition constructor

**Computed Properties:**
- `totalCalories: Int` - Total calories
- `totalCarbs: Int` - Total carbohydrates
- `totalProtein: Int` - Total protein
- `totalFat: Int` - Total fat
- `caloriePercentage: Int` - Percentage of daily calorie goal
- `description: String` - Entry description

**Static Properties:**
- `todayEntries` - Sample daily food log entries

**Purpose:** Records user's daily dietary entries

### 8. Mock Data Extensions
Provides sample data for testing and development across various data structures.

**MealItem Extensions:**
- `mockMeals` - Mock meal data including breakfast (6 items), lunch (8 items), dinner (8 items)

**NutritionData Extensions:**
- `sample` - Sample nutrition data calculated from mock meals

## User Management (SimpleUserManager.swift)

### 9. SimpleUserManager
User state management class using ObservableObject pattern.

```swift
class SimpleUserManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUsername: String = ""
    @Published var isLoading: Bool = false
    @Published var userWeight: Double = 70.0
    @Published var carbsGoal: Double = 210.0
    @Published var proteinGoal: Double = 105.0
    @Published var fatGoal: Double = 63.0
}
```

**Private Properties:**
- `userDefaultsKeys` - UserDefaults key combinations

**Main Methods:**
- `checkStoredLogin()` - Checks stored login state
- `loadUserData()` - Loads user data
- `login(username: String)` - User login
- `logout()` - User logout
- `quickLogin(username: String)` - Quick login (development use)
- `updateWeight(_ weight: Double)` - Updates user weight
- `updateNutritionGoalsBasedOnWeight()` - Updates nutrition goals based on weight
- `updateNutritionGoals(carbs:protein:fat:)` - Updates nutrition goals
- `getCurrentNutritionGoals()` - Gets current nutrition goals

**Computed Properties:**
- `totalCaloriesGoal: Int` - Total calorie goal

**Static Properties:**
- `sampleUsers` - Sample user list

**Purpose:** Manages user login state, personal data, and nutrition goals

## Weight Calculation Utilities (WeightCalculations.swift)

### 10. Double Extension
Adds weight-related validation and formatting functionality to Double type.

```swift
extension Double {
    var isValidWeight: Bool        // Validates weight range (30.0-300.0 kg)
    var formattedWeight: String    // Formats weight display
}
```

### 11. WeightBasedNutrition
Weight-based nutrition calculation utility structure.

```swift
struct WeightBasedNutrition {
    // Static methods
    static func calculateBaseNutritionGoals(for weight: Double) -> (carbs: Int, protein: Int, fat: Int)
    static func calculateNutrientRanges(for weight: Double) -> (carbsRange: ClosedRange<Double>, proteinRange: ClosedRange<Double>, fatRange: ClosedRange<Double>)
    static func calculateTotalCalories(carbs: Int, protein: Int, fat: Int) -> Int
    static func validateNutrientValues(carbs: Int, protein: Int, fat: Int, for weight: Double) -> Bool
}
```

**Calculation Formulas:**
- Carbohydrates: 3g/kg body weight (range: 1-6g/kg)
- Protein: 1.5g/kg body weight (range: 0.8-2.2g/kg)
- Fat: 0.9g/kg body weight (range: 0.8-1g/kg)
- Calorie calculation: (carbs×4) + (protein×4) + (fat×9)

**Purpose:** Calculates personalized nutrition goals based on user weight

## Data Structure Relationships

```
NutritionData (Main Data Structure)
├── caloriesConsumed/Burned/Goal
├── carbs: NutrientData
├── protein: NutrientData
└── fat: NutrientData

FoodLogEntry (Food Logging)
├── meals: [MealItem] (Legacy)
│   └── MealItem
│       ├── type: MealType
│       └── nutrition: NutritionInfo
└── nutrition: NutritionInfo (New)

SimpleUserManager (User Management)
├── User State (login/loading)
├── Personal Data (weight)
└── Nutrition Goals (carbs/protein/fat)

DailyGoal (Daily Goals)
├── standard (Default goals)
├── personalized (Personalized goals)
└── custom (Custom goals)

WeightBasedNutrition (Calculation Tools)
└── Calculate nutrition goals from weight
```

## Usage Flow

1. **User Registration/Login**: `SimpleUserManager` manages user state
2. **Personal Data Setup**: Input weight, system calculates recommended nutrition goals via `WeightBasedNutrition`
3. **Daily Goal Creation**: Creates `DailyGoal` based on personal data
4. **Food Logging**: Select `MealItem` or directly input `NutritionInfo`, create `FoodLogEntry`
5. **Progress Tracking**: `NutritionData` integrates all data, calculates intake progress and remaining goals
6. **Data Persistence**: Store user settings and preferences via `UserDefaults`

## Technical Features

- **Type Safety**: Uses strongly-typed Swift structures and enumerations
- **Reactive Design**: `SimpleUserManager` uses `@Published` properties with SwiftUI
- **Computed Properties**: Extensive use of computed properties for real-time nutrition statistics
- **Extensibility**: Adds functionality to existing types through extensions
- **Data Validation**: Built-in validation logic for weight and nutrition values
- **Modular Design**: Clear separation of data models, user management, and calculation logic

This data structure design supports complete nutrition tracking functionality while maintaining code maintainability and extensibility.
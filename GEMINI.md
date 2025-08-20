# GEMINI.md

## Project Overview

This project is a nutrition tracking iOS application named "NuTrack". It is built with SwiftUI and focuses on providing a simple and intuitive interface for users to track their daily caloric intake and macronutrient distribution.

The application consists of two main tabs:

*   **Nutrition Tracking:** This is the main screen, which displays a summary of the user's daily nutrition goals. It features a prominent calorie ring that visualizes the consumption of carbohydrates, proteins, and fats. It also includes progress bars for each macronutrient and a log of today's food entries.
*   **Add Meal:** This screen allows users to add new food entries. The process is simplified by first selecting a meal type (Breakfast, Lunch, or Dinner) and then choosing from a predefined list of food items.

The core data models are defined in `NutritionModels.swift` and include structures for nutrition information, meal items, and daily goals. The application uses mock data for food items, which is defined in `MockData.swift`.

## Building and Running

To build and run this project, you will need Xcode and the iOS SDK.

1.  Open the `NuTrackDemo03.xcodeproj` file in Xcode.
2.  Select a target device (e.g., an iPhone simulator).
3.  Click the "Run" button to build and run the application.

### Testing

The project includes unit tests and UI tests.

*   **Unit Tests:** The unit tests are located in the `NuTrackDemo03Tests` directory. You can run them from the "Test" navigator in Xcode.
*   **UI Tests:** The UI tests are located in the `NuTrackDemo03UITests` directory. You can run them from the "Test" navigator in Xcode.

## Development Conventions

*   **Language:** The project is written in Swift.
*   **User Interface:** The user interface is built with SwiftUI.
*   **Code Style:** The code follows the standard Swift style guidelines.
*   **Data:** The application uses mock data for demonstration purposes. In a production environment, this would be replaced with a persistent data store.
*   **Localization:** The application is currently localized in Chinese.

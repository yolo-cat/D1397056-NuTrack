# GEMINI.md

## Project Overview

This project is a nutrition tracking iOS application named "NuTrack". It is built with SwiftUI and focuses on providing a simple and intuitive interface for users to track their daily caloric intake and macronutrient distribution.

The application consists of two main tabs:

*   **Nutrition Tracking:** This is the main screen, which displays a summary of the user's daily nutrition goals.
*   **Add Meal:** This screen allows users to add new food entries.

## Data Persistence (SwiftData)

The project utilizes Apple's **SwiftData** framework for all local data persistence, ensuring a robust and efficient data layer that is deeply integrated with SwiftUI.

### Core Models

The data architecture is centered around two primary models:

1.  **`UserProfile`**: Represents a single user of the app. It stores the user's name and their personalized daily nutrition goals (calories, carbs, protein, fat).
2.  **`MealEntry`**: Represents a single meal event. It records the nutritional information (carbs, protein, fat) and the specific timestamp of the meal.

These models share a **one-to-many relationship**: one `UserProfile` can have many `MealEntry` records, creating a structured and reliable way to manage user-specific data.

### Data Seeding

On the first launch, the application seeds its SwiftData database with initial mock data from local JSON files. This provides a set of default users and meal entries, allowing for immediate testing and demonstration of the app's features without requiring manual data entry.

## Building and Running

To build and run this project, you will need Xcode and the iOS SDK (targeting iOS 17+ for SwiftData compatibility).

1.  Open the `NuTrackDemo03.xcodeproj` file in Xcode.
2.  Select a target device (e.g., an iPhone simulator).
3.  Click the "Run" button to build and run the application.

## Development Conventions

*   **Language:** The project is written in Swift.
*   **User Interface:** The user interface is built with SwiftUI.
*   **Data Layer:** The project uses **SwiftData** for persistence. The database is seeded from local JSON files for initial data.
*   **Localization:** The application is currently localized in Chinese.

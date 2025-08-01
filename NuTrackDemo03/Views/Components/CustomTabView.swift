//
//  CustomTabView.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI

struct CustomTabView: View {
    @Binding var selectedTab: Int
    let onAddMeal: () -> Void
    
    var body: some View {
        ZStack {
            // Main tab view
            TabView(selection: $selectedTab) {
                // Home Tab
                Group {
                    EmptyView()
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
                
                // Diary Tab
                Group {
                    EmptyView()
                }
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Diary")
                }
                .tag(1)
                
                // Spacer for center button
                Group {
                    EmptyView()
                }
                .tabItem {
                    Image(systemName: "")
                    Text("")
                }
                .tag(2)
                
                // Trends Tab
                Group {
                    EmptyView()
                }
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Trends")
                }
                .tag(3)
                
                // Settings Tab
                Group {
                    EmptyView()
                }
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
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
                    .scaleEffect(selectedTab == 2 ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                    
                    Spacer()
                }
                .padding(.bottom, 30) // Adjust based on tab bar height
            }
        }
    }
}

// MARK: - Enhanced Tab Item Structure

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

// MARK: - Alternative Custom Tab Bar Implementation

struct AlternativeCustomTabBar: View {
    @Binding var selectedTab: Int
    let onAddMeal: () -> Void
    
    var body: some View {
        HStack {
            ForEach(TabItem.allTabs, id: \.tag) { tab in
                if tab.tag == 2 {
                    // Center floating add button
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            onAddMeal()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.primaryBlue)
                                .frame(width: 56, height: 56)
                                .shadow(color: Color.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "plus")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .scaleEffect(selectedTab == 2 ? 1.1 : 1.0)
                    .offset(y: -8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                } else {
                    // Regular tab items
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab.tag
                        }
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: tab.icon)
                                .font(.title3)
                                .foregroundColor(selectedTab == tab.tag ? Color.primaryBlue : .gray)
                            
                            Text(tab.title)
                                .font(.caption2)
                                .foregroundColor(selectedTab == tab.tag ? Color.primaryBlue : .gray)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    VStack {
        Spacer()
        
        CustomTabView(selectedTab: .constant(0)) {
            print("Add meal tapped")
        }
    }
    .background(Color.backgroundGray)
}

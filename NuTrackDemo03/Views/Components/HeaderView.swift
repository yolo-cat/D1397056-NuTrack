//
//  HeaderView.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            // Notification icon (left)
            Button(action: {
                // Handle notification action
            }) {
                Image(systemName: "bell.fill")
                    .font(.title2)
                    .foregroundColor(.primaryBlue)
            }
            .accessibilityLabel("通知")
            
            Spacer()
            
            // App title (center)
            Text("NuTrack")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primaryBlue)
            
            Spacer()
            
            // User avatar (right)
            Button(action: {
                // Handle profile action
            }) {
                Circle()
                    .fill(Color.primaryBlue)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.caption)
                            .foregroundColor(.white)
                    )
            }
            .accessibilityLabel("用戶資料")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HeaderView()
}

//
//  HeaderView.swift
//  SwiftUIDemo
//
//  Created by NuTrack on 2024/7/31.
//

import SwiftUI
import SwiftData

struct HeaderView: View {
    let user: UserProfile
    
    var body: some View {
        HStack {
//            Button(action: { /* 通知功能待實現 */ }) {
//                Image(systemName: "bell.fill")
//                    .font(.title2)
//                    .foregroundColor(.primaryBlue)
//            }
//            .accessibilityLabel("通知")
            
//            Spacer()
            
            Text("NuTrack")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primaryBlue)
            
            Spacer()
            
            NavigationLink(destination: UserProfileView(user: user)) {
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    let sampleUser = UserProfile(name: "預覽用戶")
    
    return HeaderView(user: sampleUser)
        .modelContainer(container)
}

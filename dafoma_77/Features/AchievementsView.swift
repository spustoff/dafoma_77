//
//  AchievementsView.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/29/25.
//

import SwiftUI

struct AchievementsView: View {
    @ObservedObject var achievementService: AchievementService
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCategory: Achievement.AchievementCategory?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#3e4464")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Stats header
                        statsHeader
                        
                        // Category filter
                        categoryFilter
                        
                        // Recently unlocked
                        if !achievementService.recentlyUnlocked.isEmpty {
                            recentlyUnlockedSection
                        }
                        
                        // Achievements list
                        achievementsList
                    }
                    .padding(20)
                    .padding(.bottom, 50)
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
    }
    
    private var statsHeader: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Total Points",
                value: "\(achievementService.totalPoints)",
                icon: "star.fill",
                color: "#fcc418"
            )
            
            StatCard(
                title: "Unlocked",
                value: "\(achievementService.unlockedCount)/\(achievementService.achievements.count)",
                icon: "trophy.fill",
                color: "#3cc45b"
            )
        }
    }
    
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryFilterButton(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                ForEach([Achievement.AchievementCategory.reading, .streak, .bookmarks, .notes, .exploration], id: \.self) { category in
                    CategoryFilterButton(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
        }
    }
    
    private var recentlyUnlockedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently Unlocked")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(achievementService.recentlyUnlocked) { achievement in
                        MiniAchievementCard(achievement: achievement)
                    }
                }
            }
        }
    }
    
    private var achievementsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(selectedCategory?.rawValue ?? "All Achievements")
                .font(.headline)
                .foregroundColor(.white)
            
            let filteredAchievements = selectedCategory != nil ?
                achievementService.getAchievementsByCategory(selectedCategory!) :
                achievementService.achievements
            
            ForEach(filteredAchievements) { achievement in
                AchievementCard(achievement: achievement)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(Color(hex: color))
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color(hex: "#fcc418") : Color.white.opacity(0.1))
                .foregroundColor(isSelected ? .black : .white)
                .cornerRadius(20)
        }
    }
}

struct MiniAchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(Color(hex: "#fcc418"))
            
            Text(achievement.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100, height: 100)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "#fcc418"), lineWidth: 2)
        )
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? 
                          Color(hex: "#fcc418").opacity(0.2) : 
                          Color.white.opacity(0.05))
                    .frame(width: 60, height: 60)
                
                Image(systemName: achievement.icon)
                    .font(.title2)
                    .foregroundColor(achievement.isUnlocked ? 
                                   Color(hex: "#fcc418") : 
                                   Color.white.opacity(0.3))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(achievement.title)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .white : .white.opacity(0.5))
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
                
                if !achievement.isUnlocked {
                    HStack {
                        ProgressView(value: achievement.progressPercentage)
                            .tint(Color(hex: "#3cc45b"))
                        
                        Text("\(achievement.currentProgress)/\(achievement.requirement)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                } else {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "#3cc45b"))
                        Text("Unlocked!")
                            .font(.caption)
                            .foregroundColor(Color(hex: "#3cc45b"))
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(achievement.isUnlocked ? 
                       Color(hex: "#fcc418").opacity(0.5) : 
                       Color.white.opacity(0.1), 
                       lineWidth: 1)
        )
    }
}

#Preview {
    AchievementsView(achievementService: AchievementService())
}


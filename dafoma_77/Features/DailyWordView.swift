//
//  DailyWordView.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/29/25.
//

import SwiftUI

struct DailyWordView: View {
    @ObservedObject var dailyWordService: DailyWordService
    let userService: UserService
    @Environment(\.presentationMode) var presentationMode
    @State private var showFullDefinition = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#3e4464")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header with streak
                        headerView
                        
                        // Daily word card
                        if let word = dailyWordService.dailyWord {
                            dailyWordCard(word: word)
                        }
                        
                        // Motivational message
                        motivationalMessage
                        
                        // Action button
                        actionButton
                    }
                    .padding(20)
                    .padding(.bottom, 50)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title)
                    .foregroundColor(Color(hex: "#fcc418"))
                
                Text("Word of the Day")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // Streak counter
            HStack(spacing: 30) {
                streakCard(
                    title: "Current Streak",
                    value: "\(dailyWordService.currentStreak)",
                    icon: "flame.fill",
                    color: "#fcc418"
                )
                
                streakCard(
                    title: "Best Streak",
                    value: "\(dailyWordService.longestStreak)",
                    icon: "trophy.fill",
                    color: "#3cc45b"
                )
            }
        }
        .padding(.vertical, 20)
    }
    
    private func streakCard(title: String, value: String, icon: String, color: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: color))
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
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
    
    private func dailyWordCard(word: KnowledgeEntry) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Category badge
            HStack {
                Image(systemName: word.category.icon)
                    .foregroundColor(Color(hex: word.category.color))
                
                Text(word.category.rawValue)
                    .font(.caption)
                    .foregroundColor(Color(hex: word.category.color))
                
                Spacer()
                
                if !dailyWordService.hasViewedToday {
                    Text("NEW")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "#fcc418"))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                }
            }
            
            // Word title
            Text(word.title)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(.white)
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // Definition
            VStack(alignment: .leading, spacing: 8) {
                Text("Definition")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#fcc418"))
                
                Text(word.definition)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineSpacing(6)
                    .lineLimit(showFullDefinition ? nil : 3)
                
                if word.definition.count > 150 {
                    Button(showFullDefinition ? "Show less" : "Show more") {
                        withAnimation {
                            showFullDefinition.toggle()
                        }
                    }
                    .font(.caption)
                    .foregroundColor(Color(hex: "#3cc45b"))
                }
            }
            
            // Example
            if !word.examples.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Example")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#3cc45b"))
                    
                    Text("\"" + word.examples[0] + "\"")
                        .font(.body)
                        .italic()
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(6)
                }
            }
            
            // Related terms
            if !word.relatedTerms.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Related Terms")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#fcc418"))
                    
                    HStack(spacing: 8) {
                        ForEach(word.relatedTerms.prefix(4), id: \.self) { term in
                            Text(term)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: word.category.color).opacity(0.2),
                    Color.white.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: word.category.color).opacity(0.3), lineWidth: 1)
        )
    }
    
    private var motivationalMessage: some View {
        VStack(spacing: 12) {
            if dailyWordService.hasViewedToday {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "#3cc45b"))
                    Text("Great job! You've learned today's word!")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color(hex: "#3cc45b").opacity(0.2))
                .cornerRadius(12)
            } else {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(Color(hex: "#fcc418"))
                    Text("Learn this word to continue your streak!")
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color(hex: "#fcc418").opacity(0.2))
                .cornerRadius(12)
            }
        }
    }
    
    private var actionButton: some View {
        Button(action: {
            if !dailyWordService.hasViewedToday {
                withAnimation {
                    dailyWordService.markAsViewed()
                }
            }
        }) {
            HStack {
                Image(systemName: dailyWordService.hasViewedToday ? "checkmark.circle.fill" : "book.fill")
                Text(dailyWordService.hasViewedToday ? "Learned!" : "Mark as Learned")
                    .fontWeight(.semibold)
            }
            .foregroundColor(dailyWordService.hasViewedToday ? .white : .black)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(dailyWordService.hasViewedToday ? Color.white.opacity(0.2) : Color(hex: "#fcc418"))
            .cornerRadius(16)
        }
        .disabled(dailyWordService.hasViewedToday)
    }
}


#Preview {
    DailyWordView(
        dailyWordService: DailyWordService(),
        userService: UserService()
    )
}


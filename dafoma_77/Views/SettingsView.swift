//
//  SettingsView.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/23/25.
//

import SwiftUI

struct SettingsView: View {
    let userService: UserService
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(userService: UserService) {
        self.userService = userService
        self._viewModel = StateObject(wrappedValue: SettingsViewModel(userService: userService))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: userService.preferences.selectedTheme.backgroundColor)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App info section
                        appInfoSection
                        
                        // Learning stats section
                        learningStatsSection
                        
                        // Statistics section
                        statisticsSection
                        
                        // Theme selection section
                        themeSection
                        
                        // Data management section
                        dataManagementSection
                        
                        // About section
                        aboutSection
                    }
                    .padding(20)
                    .padding(.bottom, 50)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(hex: "#fcc418"))
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
        .alert("Reset App", isPresented: $viewModel.showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                viewModel.resetApp()
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("This will reset all your data and return to the onboarding screen. This action cannot be undone.")
        }
        .alert("Clear Search History", isPresented: $viewModel.showingClearHistoryAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                viewModel.clearSearchHistory()
            }
        } message: {
            Text("This will permanently delete your search history.")
        }
    }
    
    private var appInfoSection: some View {
        VStack(spacing: 16) {
            // App icon and name
            VStack(spacing: 12) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color(hex: "#fcc418"))
                
                Text("KnowledgeVault")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Your comprehensive reference companion")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var learningStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Progress")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(Color(hex: "#fcc418"))
                    Text("Daily Word Streak")
                        .foregroundColor(.white)
                    Spacer()
                    Text("Check Daily Word feature!")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#3cc45b"))
                }
                .padding(.vertical, 8)
                
                HStack {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(Color(hex: "#3cc45b"))
                    Text("Achievements")
                        .foregroundColor(.white)
                    Spacer()
                    Text("View in Achievements")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#3cc45b"))
                }
                .padding(.vertical, 8)
                
                HStack {
                    Image(systemName: "square.stack.3d.up.fill")
                        .foregroundColor(Color(hex: "#fcc418"))
                    Text("Flashcard Mastery")
                        .foregroundColor(.white)
                    Spacer()
                    Text("Study with Flashcards")
                        .font(.caption)
                        .foregroundColor(Color(hex: "#3cc45b"))
                }
                .padding(.vertical, 8)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Activity")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 16) {
                StatisticCard(
                    title: "Bookmarks",
                    value: "\(viewModel.getBookmarksCount())",
                    icon: "bookmark.fill",
                    color: "#fcc418"
                )
                
                StatisticCard(
                    title: "Notes",
                    value: "\(viewModel.getNotesCount())",
                    icon: "note.text",
                    color: "#3cc45b"
                )
                
                StatisticCard(
                    title: "Searches",
                    value: "\(viewModel.getSearchCount())",
                    icon: "magnifyingglass",
                    color: "#fcc418"
                )
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var themeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Appearance")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                ForEach(UserPreferences.AppTheme.allCases, id: \.self) { theme in
                    ThemeSelectionRow(
                        theme: theme,
                        isSelected: viewModel.selectedTheme == theme,
                        onSelect: {
                            withAnimation {
                                viewModel.updateTheme(theme)
                            }
                        }
                    )
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Data Management")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                SettingsButton(
                    title: "Clear Search History",
                    icon: "trash",
                    color: "#ff6b6b",
                    action: {
                        viewModel.showClearHistoryAlert()
                    }
                )
                
                SettingsButton(
                    title: "Reset App",
                    icon: "arrow.clockwise",
                    color: "#ff6b6b",
                    action: {
                        viewModel.showResetAlert()
                    }
                )
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Version")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(viewModel.getAppVersion())
                        .foregroundColor(.white)
                }
                
                HStack {
                    Text("Build")
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(viewModel.getBuildNumber())
                        .foregroundColor(.white)
                }
                
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.vertical, 8)
                
                Text("KnowledgeVault aggregates useful dictionaries, encyclopedias, and knowledge bases in a single user-friendly interface, enabling quick access to authoritative information.")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineSpacing(4)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
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
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ThemeSelectionRow: View {
    let theme: UserPreferences.AppTheme
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                // Theme preview
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color(hex: theme.backgroundColor))
                        .frame(width: 20, height: 20)
                    
                    Circle()
                        .fill(Color(hex: theme.primaryColor))
                        .frame(width: 16, height: 16)
                    
                    Circle()
                        .fill(Color(hex: theme.secondaryColor))
                        .frame(width: 12, height: 12)
                }
                
                Text(theme.rawValue)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "#3cc45b"))
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsButton: View {
    let title: String
    let icon: String
    let color: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: color))
                    .frame(width: 20)
                
                Text(title)
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView(userService: UserService())
}



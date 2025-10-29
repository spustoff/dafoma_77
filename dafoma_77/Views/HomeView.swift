//
//  HomeView.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/23/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var dataService = DataService()
    @StateObject private var userService = UserService()
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var dailyWordService = DailyWordService()
    @StateObject private var achievementService = AchievementService()
    @StateObject private var flashcardService = FlashcardService()
    
    @State private var selectedEntry: KnowledgeEntry?
    @State private var showingSettings = false
    @State private var showingDailyWord = false
    @State private var showingAchievements = false
    @State private var showingFlashcards = false
    
    init() {
        let dataService = DataService()
        let userService = UserService()
        self._viewModel = StateObject(wrappedValue: HomeViewModel(dataService: dataService, userService: userService))
        self._dataService = StateObject(wrappedValue: dataService)
        self._userService = StateObject(wrappedValue: userService)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: userService.preferences.selectedTheme.backgroundColor)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Search bar
                    searchBarView
                    
                    // Category filter
                    categoryFilterView
                    
                    // Content
                    contentView
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingSettings) {
                SettingsView(userService: userService)
            }
            .sheet(item: $selectedEntry) { entry in
                ContentDetailView(entry: entry, userService: userService, dataService: dataService)
            }
            .sheet(isPresented: $showingDailyWord) {
                DailyWordView(dailyWordService: dailyWordService, userService: userService)
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView(achievementService: achievementService)
            }
            .sheet(isPresented: $showingFlashcards) {
                FlashcardView(flashcardService: flashcardService, entries: dataService.knowledgeEntries)
            }
            .onAppear {
                dailyWordService.generateDailyWord(from: dataService.knowledgeEntries)
                updateAchievements()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("KnowledgeVault")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Your comprehensive reference")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                HStack(spacing: 15) {
                    // Bookmarks filter toggle
                    Button(action: {
                        withAnimation {
                            viewModel.toggleBookmarksFilter()
                        }
                    }) {
                        Image(systemName: viewModel.showingBookmarksOnly ? "bookmark.fill" : "bookmark")
                            .font(.title2)
                            .foregroundColor(viewModel.showingBookmarksOnly ? Color(hex: "#fcc418") : .white)
                    }
                    
                    // Settings button
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Quick access features
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FeatureButton(
                        icon: "calendar.badge.clock",
                        title: "Daily Word",
                        color: "#fcc418",
                        badge: !dailyWordService.hasViewedToday ? "NEW" : nil
                    ) {
                        showingDailyWord = true
                    }
                    
                    FeatureButton(
                        icon: "trophy.fill",
                        title: "Achievements",
                        color: "#3cc45b",
                        badge: "\(achievementService.unlockedCount)"
                    ) {
                        showingAchievements = true
                    }
                    
                    FeatureButton(
                        icon: "square.stack.3d.up.fill",
                        title: "Flashcards",
                        color: "#fcc418",
                        badge: nil
                    ) {
                        showingFlashcards = true
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    private var searchBarView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.6))
                
                TextField("Search knowledge...", text: $viewModel.searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                
                if !viewModel.searchText.isEmpty {
                    Button(action: {
                        viewModel.clearSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            
            // Recent searches (when search is empty)
            if viewModel.searchText.isEmpty && !viewModel.getRecentSearches().isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.getRecentSearches(), id: \.self) { search in
                            Button(search) {
                                viewModel.selectRecentSearch(search)
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white.opacity(0.8))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
    }
    
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // All categories button
                CategoryButton(
                    title: "All",
                    icon: "square.grid.2x2",
                    isSelected: viewModel.selectedCategory == nil,
                    color: "#fcc418"
                ) {
                    withAnimation {
                        viewModel.selectCategory(nil)
                    }
                }
                
                // Category buttons
                ForEach(KnowledgeEntry.KnowledgeCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        title: category.rawValue,
                        icon: category.icon,
                        isSelected: viewModel.selectedCategory == category,
                        color: category.color
                    ) {
                        withAnimation {
                            viewModel.selectCategory(category)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 15)
    }
    
    private var contentView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                let entries = viewModel.getDisplayedEntries()
                
                if entries.isEmpty {
                    emptyStateView
                } else {
                    ForEach(entries) { entry in
                        EntryRowView(
                            entry: entry,
                            isBookmarked: viewModel.isBookmarked(entry),
                            onBookmarkTap: {
                                withAnimation {
                                    viewModel.toggleBookmark(for: entry)
                                }
                            },
                            onTap: {
                                userService.logEntryView(entryId: entry.id)
                                selectedEntry = entry
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: viewModel.showingBookmarksOnly ? "bookmark.slash" : "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.3))
            
            Text(viewModel.showingBookmarksOnly ? "No bookmarks yet" : "No results found")
                .font(.title2)
                .foregroundColor(.white.opacity(0.7))
            
            Text(viewModel.showingBookmarksOnly ? 
                 "Start bookmarking entries to see them here" : 
                 "Try adjusting your search or browse categories")
                .font(.body)
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
    
    private func updateAchievements() {
        // Update reading progress
        let viewedCount = userService.activities.filter { $0.action == .viewEntry }.count
        achievementService.checkReadingProgress(readCount: viewedCount)
        
        // Update streak
        achievementService.checkStreakProgress(streak: dailyWordService.currentStreak)
        
        // Update bookmarks
        achievementService.checkBookmarkProgress(bookmarkCount: userService.getBookmarksCount())
        
        // Update notes
        achievementService.checkNotesProgress(notesCount: userService.getNotesCount())
        
        // Update search
        achievementService.checkSearchProgress(searchCount: userService.getSearchCount())
    }
}

struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color(hex: color) : Color.white.opacity(0.1))
            .foregroundColor(isSelected ? .black : .white)
            .cornerRadius(20)
        }
    }
}

struct EntryRowView: View {
    let entry: KnowledgeEntry
    let isBookmarked: Bool
    let onBookmarkTap: () -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // Category icon
                Image(systemName: entry.category.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: entry.category.color))
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 6) {
                    // Title
                    Text(entry.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    // Definition preview
                    Text(entry.definition)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // Category and related terms
                    HStack {
                        Text(entry.category.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: entry.category.color).opacity(0.2))
                            .foregroundColor(Color(hex: entry.category.color))
                            .cornerRadius(8)
                        
                        if !entry.relatedTerms.isEmpty {
                            Text("• \(entry.relatedTerms.prefix(2).joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Spacer()
                    }
                }
                
                Spacer()
                
                // Bookmark button
                Button(action: onBookmarkTap) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.title3)
                        .foregroundColor(isBookmarked ? Color(hex: "#fcc418") : .white.opacity(0.5))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FeatureButton: View {
    let icon: String
    let title: String
    let color: String
    let badge: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(Color(hex: color))
                    
                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.black)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color(hex: color))
                            .cornerRadius(8)
                            .offset(x: 8, y: -8)
                    }
                }
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    HomeView()
}



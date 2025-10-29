//
//  UserService.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/23/25.
//

import Foundation

class UserService: ObservableObject {
    @Published var preferences = UserPreferences()
    @Published var activities: [UserActivity] = []
    
    private let userDefaultsKey = "UserPreferences"
    private let activitiesKey = "UserActivities"
    
    init() {
        loadPreferences()
        loadActivities()
    }
    
    // MARK: - Preferences Management
    
    func savePreferences() {
        if let encoded = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadPreferences() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            preferences = decoded
        }
    }
    
    // MARK: - Bookmarks Management
    
    func toggleBookmark(for entryId: UUID) {
        if preferences.bookmarkedEntries.contains(entryId) {
            preferences.bookmarkedEntries.remove(entryId)
            logActivity(.unbookmark, entryId: entryId)
        } else {
            preferences.bookmarkedEntries.insert(entryId)
            logActivity(.bookmark, entryId: entryId)
        }
        savePreferences()
    }
    
    func isBookmarked(_ entryId: UUID) -> Bool {
        return preferences.bookmarkedEntries.contains(entryId)
    }
    
    // MARK: - Notes Management
    
    func saveNote(for entryId: UUID, note: String) {
        if note.isEmpty {
            preferences.userNotes.removeValue(forKey: entryId)
        } else {
            preferences.userNotes[entryId] = note
            logActivity(.addNote, entryId: entryId)
        }
        savePreferences()
    }
    
    func getNote(for entryId: UUID) -> String {
        return preferences.userNotes[entryId] ?? ""
    }
    
    // MARK: - Search History
    
    func addToSearchHistory(_ query: String) {
        guard !query.isEmpty else { return }
        
        // Remove if already exists to avoid duplicates
        preferences.searchHistory.removeAll { $0 == query }
        
        // Add to beginning
        preferences.searchHistory.insert(query, at: 0)
        
        // Keep only last 20 searches
        if preferences.searchHistory.count > 20 {
            preferences.searchHistory = Array(preferences.searchHistory.prefix(20))
        }
        
        logActivity(.search, searchTerm: query)
        savePreferences()
    }
    
    func clearSearchHistory() {
        preferences.searchHistory.removeAll()
        savePreferences()
    }
    
    // MARK: - Theme Management
    
    func updateTheme(_ theme: UserPreferences.AppTheme) {
        preferences.selectedTheme = theme
        savePreferences()
    }
    
    // MARK: - Activity Logging
    
    private func logActivity(_ action: UserActivity.ActivityType, entryId: UUID? = nil, searchTerm: String? = nil) {
        let activity = UserActivity(
            timestamp: Date(),
            action: action,
            entryId: entryId,
            searchTerm: searchTerm
        )
        
        activities.insert(activity, at: 0)
        
        // Keep only last 100 activities
        if activities.count > 100 {
            activities = Array(activities.prefix(100))
        }
        
        saveActivities()
    }
    
    func logEntryView(entryId: UUID) {
        logActivity(.viewEntry, entryId: entryId)
    }
    
    private func saveActivities() {
        if let encoded = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(encoded, forKey: activitiesKey)
        }
    }
    
    private func loadActivities() {
        if let data = UserDefaults.standard.data(forKey: activitiesKey),
           let decoded = try? JSONDecoder().decode([UserActivity].self, from: data) {
            activities = decoded
        }
    }
    
    // MARK: - App Reset
    
    func resetAppToOnboarding() {
        // Clear all user data
        preferences = UserPreferences()
        activities.removeAll()
        
        // Clear UserDefaults
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        UserDefaults.standard.removeObject(forKey: activitiesKey)
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        
        savePreferences()
        saveActivities()
    }
    
    // MARK: - Statistics
    
    func getBookmarksCount() -> Int {
        return preferences.bookmarkedEntries.count
    }
    
    func getNotesCount() -> Int {
        return preferences.userNotes.count
    }
    
    func getSearchCount() -> Int {
        return activities.filter { $0.action == .search }.count
    }
}



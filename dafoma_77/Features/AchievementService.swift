//
//  AchievementService.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/29/25.
//

import Foundation

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requirement: Int
    var currentProgress: Int = 0
    var isUnlocked: Bool = false
    let category: AchievementCategory
    
    var progressPercentage: Double {
        return Double(currentProgress) / Double(requirement)
    }
    
    enum AchievementCategory: String, Codable {
        case reading = "Reading"
        case streak = "Streak"
        case bookmarks = "Bookmarks"
        case notes = "Notes"
        case exploration = "Exploration"
    }
}

class AchievementService: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var totalPoints: Int = 0
    @Published var unlockedCount: Int = 0
    @Published var recentlyUnlocked: [Achievement] = []
    
    private let achievementsKey = "UserAchievements"
    private let pointsKey = "TotalPoints"
    
    init() {
        loadAchievements()
    }
    
    private func createDefaultAchievements() -> [Achievement] {
        return [
            // Reading achievements
            Achievement(id: "read_1", title: "First Steps", description: "Read your first entry", icon: "book.fill", requirement: 1, category: .reading),
            Achievement(id: "read_10", title: "Knowledge Seeker", description: "Read 10 different entries", icon: "books.vertical.fill", requirement: 10, category: .reading),
            Achievement(id: "read_25", title: "Avid Reader", description: "Read 25 different entries", icon: "text.book.closed.fill", requirement: 25, category: .reading),
            Achievement(id: "read_50", title: "Scholar", description: "Read 50 different entries", icon: "graduationcap.fill", requirement: 50, category: .reading),
            
            // Streak achievements
            Achievement(id: "streak_3", title: "Getting Started", description: "3 day learning streak", icon: "flame.fill", requirement: 3, category: .streak),
            Achievement(id: "streak_7", title: "Week Warrior", description: "7 day learning streak", icon: "flame.circle.fill", requirement: 7, category: .streak),
            Achievement(id: "streak_30", title: "Dedicated Learner", description: "30 day learning streak", icon: "star.fill", requirement: 30, category: .streak),
            
            // Bookmark achievements
            Achievement(id: "bookmark_5", title: "Collector", description: "Bookmark 5 entries", icon: "bookmark.fill", requirement: 5, category: .bookmarks),
            Achievement(id: "bookmark_20", title: "Curator", description: "Bookmark 20 entries", icon: "bookmark.circle.fill", requirement: 20, category: .bookmarks),
            
            // Notes achievements
            Achievement(id: "notes_1", title: "Note Taker", description: "Add your first note", icon: "note.text", requirement: 1, category: .notes),
            Achievement(id: "notes_10", title: "Thoughtful Writer", description: "Add notes to 10 entries", icon: "square.and.pencil", requirement: 10, category: .notes),
            
            // Exploration achievements
            Achievement(id: "explore_all", title: "Explorer", description: "View all categories", icon: "globe", requirement: 8, category: .exploration),
            Achievement(id: "search_master", title: "Search Master", description: "Perform 50 searches", icon: "magnifyingglass", requirement: 50, category: .exploration)
        ]
    }
    
    func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: achievementsKey),
           let decoded = try? JSONDecoder().decode([Achievement].self, from: data) {
            achievements = decoded
        } else {
            achievements = createDefaultAchievements()
            saveAchievements()
        }
        
        totalPoints = UserDefaults.standard.integer(forKey: pointsKey)
        unlockedCount = achievements.filter { $0.isUnlocked }.count
    }
    
    func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(achievements) {
            UserDefaults.standard.set(encoded, forKey: achievementsKey)
        }
        UserDefaults.standard.set(totalPoints, forKey: pointsKey)
    }
    
    func updateProgress(for id: String, progress: Int) {
        guard let index = achievements.firstIndex(where: { $0.id == id }) else { return }
        
        var achievement = achievements[index]
        let wasUnlocked = achievement.isUnlocked
        
        achievement.currentProgress = min(progress, achievement.requirement)
        
        if !wasUnlocked && achievement.currentProgress >= achievement.requirement {
            achievement.isUnlocked = true
            unlockAchievement(achievement)
        }
        
        achievements[index] = achievement
        saveAchievements()
    }
    
    func checkReadingProgress(readCount: Int) {
        updateProgress(for: "read_1", progress: readCount)
        updateProgress(for: "read_10", progress: readCount)
        updateProgress(for: "read_25", progress: readCount)
        updateProgress(for: "read_50", progress: readCount)
    }
    
    func checkStreakProgress(streak: Int) {
        updateProgress(for: "streak_3", progress: streak)
        updateProgress(for: "streak_7", progress: streak)
        updateProgress(for: "streak_30", progress: streak)
    }
    
    func checkBookmarkProgress(bookmarkCount: Int) {
        updateProgress(for: "bookmark_5", progress: bookmarkCount)
        updateProgress(for: "bookmark_20", progress: bookmarkCount)
    }
    
    func checkNotesProgress(notesCount: Int) {
        updateProgress(for: "notes_1", progress: notesCount)
        updateProgress(for: "notes_10", progress: notesCount)
    }
    
    func checkSearchProgress(searchCount: Int) {
        updateProgress(for: "search_master", progress: searchCount)
    }
    
    func checkCategoryExploration(categoriesViewed: Int) {
        updateProgress(for: "explore_all", progress: categoriesViewed)
    }
    
    private func unlockAchievement(_ achievement: Achievement) {
        let points = calculatePoints(for: achievement)
        totalPoints += points
        unlockedCount += 1
        
        recentlyUnlocked.insert(achievement, at: 0)
        if recentlyUnlocked.count > 5 {
            recentlyUnlocked.removeLast()
        }
        
        saveAchievements()
    }
    
    private func calculatePoints(for achievement: Achievement) -> Int {
        switch achievement.category {
        case .reading: return achievement.requirement * 10
        case .streak: return achievement.requirement * 20
        case .bookmarks: return achievement.requirement * 5
        case .notes: return achievement.requirement * 15
        case .exploration: return 100
        }
    }
    
    func getAchievementsByCategory(_ category: Achievement.AchievementCategory) -> [Achievement] {
        return achievements.filter { $0.category == category }
    }
}


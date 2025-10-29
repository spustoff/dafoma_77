//
//  DailyWordService.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/29/25.
//

import Foundation

class DailyWordService: ObservableObject {
    @Published var dailyWord: KnowledgeEntry?
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var hasViewedToday: Bool = false
    
    private let userDefaultsPrefix = "DailyWord_"
    private let streakKey = "CurrentStreak"
    private let longestStreakKey = "LongestStreak"
    private let lastViewedDateKey = "LastViewedDate"
    
    init() {
        loadStreak()
    }
    
    func generateDailyWord(from entries: [KnowledgeEntry]) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Используем день года как seed для консистентности
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1
        let year = calendar.component(.year, from: today)
        let seed = year * 1000 + dayOfYear
        
        // Генерируем индекс на основе seed
        let index = seed % entries.count
        dailyWord = entries[index]
        
        checkAndUpdateStreak()
    }
    
    func markAsViewed() {
        guard !hasViewedToday else { return }
        
        hasViewedToday = true
        let today = Date()
        UserDefaults.standard.set(today, forKey: userDefaultsPrefix + lastViewedDateKey)
        
        // Обновляем серию
        currentStreak += 1
        if currentStreak > longestStreak {
            longestStreak = currentStreak
            UserDefaults.standard.set(longestStreak, forKey: userDefaultsPrefix + longestStreakKey)
        }
        UserDefaults.standard.set(currentStreak, forKey: userDefaultsPrefix + streakKey)
    }
    
    private func checkAndUpdateStreak() {
        guard let lastViewed = UserDefaults.standard.object(forKey: userDefaultsPrefix + lastViewedDateKey) as? Date else {
            hasViewedToday = false
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastViewedDay = calendar.startOfDay(for: lastViewed)
        
        let daysDifference = calendar.dateComponents([.day], from: lastViewedDay, to: today).day ?? 0
        
        if daysDifference == 0 {
            hasViewedToday = true
        } else if daysDifference == 1 {
            hasViewedToday = false
        } else {
            // Серия прервана
            currentStreak = 0
            hasViewedToday = false
            UserDefaults.standard.set(0, forKey: userDefaultsPrefix + streakKey)
        }
    }
    
    private func loadStreak() {
        currentStreak = UserDefaults.standard.integer(forKey: userDefaultsPrefix + streakKey)
        longestStreak = UserDefaults.standard.integer(forKey: userDefaultsPrefix + longestStreakKey)
    }
    
    func resetStreak() {
        currentStreak = 0
        UserDefaults.standard.set(0, forKey: userDefaultsPrefix + streakKey)
    }
}


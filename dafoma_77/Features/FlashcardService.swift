//
//  FlashcardService.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/29/25.
//

import Foundation

struct FlashcardSession: Codable {
    let id = UUID()
    let date: Date
    let cardsStudied: Int
    let correctAnswers: Int
    let duration: TimeInterval
    
    var accuracy: Double {
        return cardsStudied > 0 ? Double(correctAnswers) / Double(cardsStudied) : 0
    }
}

struct CardProgress: Codable {
    let entryId: UUID
    var timesReviewed: Int = 0
    var correctCount: Int = 0
    var lastReviewed: Date?
    var masteryLevel: Int = 0 // 0-5
    
    var accuracy: Double {
        return timesReviewed > 0 ? Double(correctCount) / Double(timesReviewed) : 0
    }
}

class FlashcardService: ObservableObject {
    @Published var cardProgress: [UUID: CardProgress] = [:]
    @Published var sessions: [FlashcardSession] = []
    @Published var totalCardsStudied: Int = 0
    @Published var averageAccuracy: Double = 0
    
    private let progressKey = "FlashcardProgress"
    private let sessionsKey = "FlashcardSessions"
    
    init() {
        loadProgress()
    }
    
    func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: progressKey),
           let decoded = try? JSONDecoder().decode([UUID: CardProgress].self, from: data) {
            cardProgress = decoded
        }
        
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([FlashcardSession].self, from: data) {
            sessions = decoded
            updateStatistics()
        }
    }
    
    func saveProgress() {
        if let encoded = try? JSONEncoder().encode(cardProgress) {
            UserDefaults.standard.set(encoded, forKey: progressKey)
        }
        
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
    }
    
    func recordAnswer(for entryId: UUID, isCorrect: Bool) {
        var progress = cardProgress[entryId] ?? CardProgress(entryId: entryId)
        progress.timesReviewed += 1
        if isCorrect {
            progress.correctCount += 1
            progress.masteryLevel = min(5, progress.masteryLevel + 1)
        } else {
            progress.masteryLevel = max(0, progress.masteryLevel - 1)
        }
        progress.lastReviewed = Date()
        cardProgress[entryId] = progress
        saveProgress()
    }
    
    func completeSession(cardsStudied: Int, correctAnswers: Int, duration: TimeInterval) {
        let session = FlashcardSession(
            date: Date(),
            cardsStudied: cardsStudied,
            correctAnswers: correctAnswers,
            duration: duration
        )
        
        sessions.insert(session, at: 0)
        if sessions.count > 50 {
            sessions = Array(sessions.prefix(50))
        }
        
        updateStatistics()
        saveProgress()
    }
    
    private func updateStatistics() {
        totalCardsStudied = sessions.reduce(0) { $0 + $1.cardsStudied }
        
        if !sessions.isEmpty {
            let totalAccuracy = sessions.reduce(0.0) { $0 + $1.accuracy }
            averageAccuracy = totalAccuracy / Double(sessions.count)
        }
    }
    
    func getDueCards(from entries: [KnowledgeEntry]) -> [KnowledgeEntry] {
        let now = Date()
        let calendar = Calendar.current
        
        return entries.filter { entry in
            guard let progress = cardProgress[entry.id] else { return true }
            
            guard let lastReviewed = progress.lastReviewed else { return true }
            
            let daysSinceReview = calendar.dateComponents([.day], from: lastReviewed, to: now).day ?? 0
            let reviewInterval = getReviewInterval(for: progress.masteryLevel)
            
            return daysSinceReview >= reviewInterval
        }
    }
    
    private func getReviewInterval(for masteryLevel: Int) -> Int {
        switch masteryLevel {
        case 0: return 0  // New card
        case 1: return 1  // 1 day
        case 2: return 3  // 3 days
        case 3: return 7  // 1 week
        case 4: return 14 // 2 weeks
        case 5: return 30 // 1 month
        default: return 0
        }
    }
    
    func getProgress(for entryId: UUID) -> CardProgress? {
        return cardProgress[entryId]
    }
    
    func getMasteredCardsCount() -> Int {
        return cardProgress.values.filter { $0.masteryLevel >= 4 }.count
    }
}


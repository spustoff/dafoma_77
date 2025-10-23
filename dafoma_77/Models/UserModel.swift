//
//  UserModel.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/23/25.
//

import Foundation

struct UserPreferences: Codable {
    var selectedTheme: AppTheme = .default
    var bookmarkedEntries: Set<UUID> = []
    var userNotes: [UUID: String] = [:]
    var searchHistory: [String] = []
    var hasCompletedOnboarding: Bool = false
    
    enum AppTheme: String, CaseIterable, Codable {
        case `default` = "Default"
        case highContrast = "High Contrast"
        case darkMode = "Dark Mode"
        
        var backgroundColor: String {
            switch self {
            case .default: return "#3e4464"
            case .highContrast: return "#000000"
            case .darkMode: return "#1c1c1e"
            }
        }
        
        var primaryColor: String {
            switch self {
            case .default, .darkMode: return "#fcc418"
            case .highContrast: return "#ffffff"
            }
        }
        
        var secondaryColor: String {
            switch self {
            case .default, .darkMode: return "#3cc45b"
            case .highContrast: return "#ffff00"
            }
        }
    }
}

struct UserActivity: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let action: ActivityType
    let entryId: UUID?
    let searchTerm: String?
    
    enum ActivityType: String, Codable {
        case search = "Search"
        case bookmark = "Bookmark"
        case unbookmark = "Unbookmark"
        case addNote = "Add Note"
        case viewEntry = "View Entry"
    }
}

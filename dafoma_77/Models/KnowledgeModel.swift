//
//  KnowledgeModel.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/23/25.
//

import Foundation

struct KnowledgeEntry: Identifiable, Codable, Hashable {
    let id = UUID()
    let title: String
    let definition: String
    let category: KnowledgeCategory
    let relatedTerms: [String]
    let etymology: String?
    let examples: [String]
    var isBookmarked: Bool = false
    var userNotes: String = ""
    
    enum KnowledgeCategory: String, CaseIterable, Codable {
        case dictionary = "Dictionary"
        case encyclopedia = "Encyclopedia"
        case science = "Science"
        case history = "History"
        case literature = "Literature"
        case technology = "Technology"
        case philosophy = "Philosophy"
        case arts = "Arts"
        
        var icon: String {
            switch self {
            case .dictionary: return "book.closed"
            case .encyclopedia: return "books.vertical"
            case .science: return "atom"
            case .history: return "clock"
            case .literature: return "text.book.closed"
            case .technology: return "laptopcomputer"
            case .philosophy: return "brain.head.profile"
            case .arts: return "paintbrush"
            }
        }
        
        var color: String {
            switch self {
            case .dictionary, .encyclopedia: return "#fcc418"
            case .science, .technology: return "#3cc45b"
            case .history, .literature: return "#fcc418"
            case .philosophy, .arts: return "#3cc45b"
            }
        }
    }
}

struct SearchResult: Identifiable {
    let id = UUID()
    let entry: KnowledgeEntry
    let matchType: MatchType
    
    enum MatchType {
        case title
        case definition
        case relatedTerm
    }
}

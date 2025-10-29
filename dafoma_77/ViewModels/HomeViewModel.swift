//
//  HomeViewModel.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/23/25.
//

import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [SearchResult] = []
    @Published var selectedCategory: KnowledgeEntry.KnowledgeCategory?
    @Published var isSearching = false
    @Published var showingBookmarksOnly = false
    
    private let dataService: DataService
    private let userService: UserService
    private var cancellables = Set<AnyCancellable>()
    
    init(dataService: DataService, userService: UserService) {
        self.dataService = dataService
        self.userService = userService
        
        setupSearchBinding()
    }
    
    private func setupSearchBinding() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchText in
                self?.performSearch(searchText)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(_ query: String) {
        isSearching = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            
            if query.isEmpty {
                self.searchResults = []
            } else {
                self.searchResults = self.dataService.searchEntries(query: query)
                if !self.searchResults.isEmpty {
                    self.userService.addToSearchHistory(query)
                }
            }
            
            self.isSearching = false
        }
    }
    
    func getDisplayedEntries() -> [KnowledgeEntry] {
        var entries: [KnowledgeEntry]
        
        if !searchText.isEmpty {
            entries = searchResults.map { $0.entry }
        } else if let category = selectedCategory {
            entries = dataService.getEntriesByCategory(category)
        } else {
            entries = dataService.knowledgeEntries
        }
        
        if showingBookmarksOnly {
            entries = entries.filter { userService.isBookmarked($0.id) }
        }
        
        return entries
    }
    
    func toggleBookmark(for entry: KnowledgeEntry) {
        userService.toggleBookmark(for: entry.id)
    }
    
    func isBookmarked(_ entry: KnowledgeEntry) -> Bool {
        return userService.isBookmarked(entry.id)
    }
    
    func clearSearch() {
        searchText = ""
        selectedCategory = nil
    }
    
    func selectCategory(_ category: KnowledgeEntry.KnowledgeCategory?) {
        selectedCategory = category
        searchText = ""
    }
    
    func toggleBookmarksFilter() {
        showingBookmarksOnly.toggle()
    }
    
    func getBookmarkedEntries() -> [KnowledgeEntry] {
        return dataService.knowledgeEntries.filter { userService.isBookmarked($0.id) }
    }
    
    func getRecentSearches() -> [String] {
        return Array(userService.preferences.searchHistory.prefix(5))
    }
    
    func selectRecentSearch(_ search: String) {
        searchText = search
    }
}



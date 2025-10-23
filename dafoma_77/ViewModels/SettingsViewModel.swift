//
//  SettingsViewModel.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/23/25.
//

import Foundation

class SettingsViewModel: ObservableObject {
    @Published var selectedTheme: UserPreferences.AppTheme
    @Published var showingResetAlert = false
    @Published var showingClearHistoryAlert = false
    
    private let userService: UserService
    
    init(userService: UserService) {
        self.userService = userService
        self.selectedTheme = userService.preferences.selectedTheme
    }
    
    func updateTheme(_ theme: UserPreferences.AppTheme) {
        selectedTheme = theme
        userService.updateTheme(theme)
    }
    
    func showResetAlert() {
        showingResetAlert = true
    }
    
    func showClearHistoryAlert() {
        showingClearHistoryAlert = true
    }
    
    func resetApp() {
        userService.resetAppToOnboarding()
    }
    
    func clearSearchHistory() {
        userService.clearSearchHistory()
    }
    
    func getBookmarksCount() -> Int {
        return userService.getBookmarksCount()
    }
    
    func getNotesCount() -> Int {
        return userService.getNotesCount()
    }
    
    func getSearchCount() -> Int {
        return userService.getSearchCount()
    }
    
    func getAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    func getBuildNumber() -> String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

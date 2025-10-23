//
//  OnboardingViewModel.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/23/25.
//

import Foundation

class OnboardingViewModel: ObservableObject {
    @Published var currentPage = 0
    
    let onboardingPages = [
        OnboardingPage(
            title: "Welcome to KnowledgeVault",
            subtitle: "Your comprehensive reference companion",
            description: "Access dictionaries, encyclopedias, and knowledge bases all in one beautifully designed app. Discover, learn, and expand your knowledge effortlessly.",
            imageName: "books.vertical.fill",
            primaryColor: "#fcc418"
        ),
        OnboardingPage(
            title: "Explore and Bookmark",
            subtitle: "Save what matters most",
            description: "Bookmark your favorite entries for quick access. Organize your personal knowledge library and never lose track of important information.",
            imageName: "bookmark.fill",
            primaryColor: "#3cc45b"
        ),
        OnboardingPage(
            title: "Enhanced Learning with Notes",
            subtitle: "Make it personal",
            description: "Add your own notes and annotations to any entry. Create connections, add context, and build your personalized learning experience.",
            imageName: "note.text",
            primaryColor: "#fcc418"
        )
    ]
    
    var isLastPage: Bool {
        currentPage == onboardingPages.count - 1
    }
    
    var canGoBack: Bool {
        currentPage > 0
    }
    
    func nextPage() {
        if currentPage < onboardingPages.count - 1 {
            currentPage += 1
        }
    }
    
    func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
    
    func skipToEnd() {
        currentPage = onboardingPages.count - 1
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let primaryColor: String
}

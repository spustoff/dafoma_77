//
//  OnboardingView.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/23/25.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#3e4464")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                HStack {
                    ForEach(0..<viewModel.onboardingPages.count, id: \.self) { index in
                        Circle()
                            .fill(index <= viewModel.currentPage ? Color(hex: "#fcc418") : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
                    }
                }
                .padding(.top, 20)
                
                // Content
                TabView(selection: $viewModel.currentPage) {
                    ForEach(0..<viewModel.onboardingPages.count, id: \.self) { index in
                        OnboardingPageView(page: viewModel.onboardingPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: viewModel.currentPage)
                
                // Navigation buttons
                HStack {
                    // Back button
                    Button(action: {
                        withAnimation {
                            viewModel.previousPage()
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(25)
                    }
                    .opacity(viewModel.canGoBack ? 1 : 0)
                    .disabled(!viewModel.canGoBack)
                    
                    Spacer()
                    
                    // Skip button (only show on first two pages)
                    if !viewModel.isLastPage {
                        Button("Skip") {
                            withAnimation {
                                viewModel.skipToEnd()
                            }
                        }
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                    
                    Spacer()
                    
                    // Next/Get Started button
                    Button(action: {
                        if viewModel.isLastPage {
                            hasCompletedOnboarding = true
                        } else {
                            withAnimation {
                                viewModel.nextPage()
                            }
                        }
                    }) {
                        HStack {
                            Text(viewModel.isLastPage ? "Get Started" : "Next")
                            if !viewModel.isLastPage {
                                Image(systemName: "chevron.right")
                            }
                        }
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#fcc418"))
                        .cornerRadius(25)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Icon
            Image(systemName: page.imageName)
                .font(.system(size: 80))
                .foregroundColor(Color(hex: page.primaryColor))
                .padding(.bottom, 20)
            
            // Title
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            // Subtitle
            Text(page.subtitle)
                .font(.title2)
                .foregroundColor(Color(hex: page.primaryColor))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            // Description
            Text(page.description)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

// Color extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    OnboardingView()
}



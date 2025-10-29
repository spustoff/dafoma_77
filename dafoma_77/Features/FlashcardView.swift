//
//  FlashcardView.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/29/25.
//

import SwiftUI

struct FlashcardView: View {
    @ObservedObject var flashcardService: FlashcardService
    let entries: [KnowledgeEntry]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentIndex = 0
    @State private var showAnswer = false
    @State private var correctCount = 0
    @State private var startTime = Date()
    @State private var sessionCards: [KnowledgeEntry] = []
    @State private var isSessionComplete = false
    @State private var cardRotation: Double = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#3e4464")
                    .ignoresSafeArea()
                
                if isSessionComplete {
                    sessionCompleteView
                } else if sessionCards.isEmpty {
                    noCardsView
                } else {
                    VStack(spacing: 24) {
                        // Progress bar
                        progressBar
                        
                        // Card
                        flashcard
                        
                        // Controls
                        if showAnswer {
                            answerButtons
                        } else {
                            showAnswerButton
                        }
                        
                        // Stats
                        sessionStats
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Flashcards")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if !isSessionComplete && !sessionCards.isEmpty {
                            endSession()
                        }
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text(isSessionComplete ? "Done" : "Back")
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
        .onAppear {
            initializeSession()
        }
    }
    
    private func initializeSession() {
        sessionCards = flashcardService.getDueCards(from: entries).shuffled()
        if sessionCards.count > 15 {
            sessionCards = Array(sessionCards.prefix(15))
        }
        startTime = Date()
    }
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Card \(currentIndex + 1) of \(sessionCards.count)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("\(Int(Double(currentIndex) / Double(sessionCards.count) * 100))%")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(Color(hex: "#fcc418"))
                        .frame(width: geometry.size.width * (Double(currentIndex) / Double(sessionCards.count)), height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
    
    private var flashcard: some View {
        let card = sessionCards[currentIndex]
        
        return ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(hex: card.category.color).opacity(0.3),
                            Color.white.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: card.category.color), lineWidth: 2)
                )
            
            VStack(spacing: 24) {
                // Category badge
                HStack {
                    Image(systemName: card.category.icon)
                        .foregroundColor(Color(hex: card.category.color))
                    Text(card.category.rawValue)
                        .font(.caption)
                        .foregroundColor(Color(hex: card.category.color))
                    
                    Spacer()
                    
                    if let progress = flashcardService.getProgress(for: card.id) {
                        HStack(spacing: 4) {
                            ForEach(0..<5) { index in
                                Circle()
                                    .fill(index < progress.masteryLevel ? Color(hex: "#fcc418") : Color.white.opacity(0.2))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
                
                Spacer()
                
                if !showAnswer {
                    // Question side
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: "#fcc418"))
                        
                        Text(card.title)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("What does this mean?")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                    }
                } else {
                    // Answer side
                    VStack(alignment: .leading, spacing: 16) {
                        Text(card.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Divider()
                            .background(Color.white.opacity(0.3))
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(card.definition)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .lineSpacing(6)
                                
                                if !card.examples.isEmpty {
                                    Text("Example:")
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "#3cc45b"))
                                    
                                    Text("\"" + card.examples[0] + "\"")
                                        .font(.caption)
                                        .italic()
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(24)
        }
        .frame(height: 400)
        .rotation3DEffect(.degrees(cardRotation), axis: (x: 0, y: 1, z: 0))
    }
    
    private var showAnswerButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6)) {
                cardRotation = 180
                showAnswer = true
            }
        }) {
            HStack {
                Image(systemName: "eye.fill")
                Text("Show Answer")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.black)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color(hex: "#fcc418"))
            .cornerRadius(16)
        }
    }
    
    private var answerButtons: some View {
        HStack(spacing: 16) {
            Button(action: {
                recordAnswer(isCorrect: false)
            }) {
                VStack {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                    Text("Wrong")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.red.opacity(0.3))
                .cornerRadius(16)
            }
            
            Button(action: {
                recordAnswer(isCorrect: true)
            }) {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                    Text("Correct")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color(hex: "#3cc45b").opacity(0.3))
                .cornerRadius(16)
            }
        }
    }
    
    private var sessionStats: some View {
        HStack(spacing: 30) {
            VStack {
                Text("\(correctCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#3cc45b"))
                Text("Correct")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack {
                Text("\(currentIndex - correctCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                Text("Wrong")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            VStack {
                let accuracy = currentIndex > 0 ? Int(Double(correctCount) / Double(currentIndex) * 100) : 0
                Text("\(accuracy)%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#fcc418"))
                Text("Accuracy")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var sessionCompleteView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "#3cc45b"))
            
            Text("Session Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 16) {
                StatRow(title: "Cards Studied", value: "\(sessionCards.count)")
                StatRow(title: "Correct Answers", value: "\(correctCount)")
                StatRow(title: "Accuracy", value: "\(Int(Double(correctCount) / Double(sessionCards.count) * 100))%")
                
                let duration = Date().timeIntervalSince(startTime)
                let minutes = Int(duration) / 60
                let seconds = Int(duration) % 60
                StatRow(title: "Time", value: "\(minutes)m \(seconds)s")
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            
            Text("Great job! Keep studying to master all entries.")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(20)
    }
    
    private var noCardsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "#fcc418"))
            
            Text("All Caught Up!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("You've reviewed all due cards. Come back later for more practice!")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private func recordAnswer(isCorrect: Bool) {
        let card = sessionCards[currentIndex]
        flashcardService.recordAnswer(for: card.id, isCorrect: isCorrect)
        
        if isCorrect {
            correctCount += 1
        }
        
        withAnimation(.spring(response: 0.6)) {
            if currentIndex < sessionCards.count - 1 {
                currentIndex += 1
                showAnswer = false
                cardRotation = 0
            } else {
                endSession()
            }
        }
    }
    
    private func endSession() {
        let duration = Date().timeIntervalSince(startTime)
        flashcardService.completeSession(
            cardsStudied: currentIndex + 1,
            correctAnswers: correctCount,
            duration: duration
        )
        isSessionComplete = true
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    FlashcardView(
        flashcardService: FlashcardService(),
        entries: []
    )
}


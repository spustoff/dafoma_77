//
//  ContentDetailView.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/23/25.
//

import SwiftUI

struct ContentDetailView: View {
    let entry: KnowledgeEntry
    let userService: UserService
    let dataService: DataService
    
    @Environment(\.presentationMode) var presentationMode
    @State private var userNote: String
    @State private var isBookmarked: Bool
    @State private var showingNoteEditor = false
    @State private var relatedEntries: [KnowledgeEntry] = []
    
    init(entry: KnowledgeEntry, userService: UserService, dataService: DataService) {
        self.entry = entry
        self.userService = userService
        self.dataService = dataService
        self._userNote = State(initialValue: userService.getNote(for: entry.id))
        self._isBookmarked = State(initialValue: userService.isBookmarked(entry.id))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: userService.preferences.selectedTheme.backgroundColor)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        headerView
                        
                        // Main content
                        mainContentView
                        
                        // Etymology section
                        if let etymology = entry.etymology {
                            etymologyView(etymology)
                        }
                        
                        // Examples section
                        if !entry.examples.isEmpty {
                            examplesView
                        }
                        
                        // Related terms
                        if !entry.relatedTerms.isEmpty {
                            relatedTermsView
                        }
                        
                        // User notes section
                        notesView
                        
                        // Related entries
                        if !relatedEntries.isEmpty {
                            relatedEntriesView
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 50)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: toggleBookmark) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .foregroundColor(isBookmarked ? Color(hex: "#fcc418") : .white)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
        .onAppear {
            loadRelatedEntries()
        }
        .sheet(isPresented: $showingNoteEditor) {
            NoteEditorView(note: $userNote, onSave: saveNote)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: entry.category.icon)
                    .font(.title)
                    .foregroundColor(Color(hex: entry.category.color))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.category.rawValue)
                        .font(.caption)
                        .foregroundColor(Color(hex: entry.category.color))
                    
                    Text(entry.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
        }
    }
    
    private var mainContentView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Definition")
                .font(.headline)
                .foregroundColor(Color(hex: "#fcc418"))
            
            Text(entry.definition)
                .font(.body)
                .foregroundColor(.white)
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func etymologyView(_ etymology: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Etymology")
                .font(.headline)
                .foregroundColor(Color(hex: "#3cc45b"))
            
            Text(etymology)
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(4)
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var examplesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Examples")
                .font(.headline)
                .foregroundColor(Color(hex: "#fcc418"))
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(entry.examples.enumerated()), id: \.offset) { index, example in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.body)
                            .foregroundColor(Color(hex: "#fcc418"))
                        
                        Text(example)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .lineSpacing(4)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var relatedTermsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related Terms")
                .font(.headline)
                .foregroundColor(Color(hex: "#3cc45b"))
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(entry.relatedTerms, id: \.self) { term in
                    Text(term)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "#3cc45b").opacity(0.2))
                        .foregroundColor(Color(hex: "#3cc45b"))
                        .cornerRadius(16)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var notesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your Notes")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#fcc418"))
                
                Spacer()
                
                Button(userNote.isEmpty ? "Add Note" : "Edit Note") {
                    showingNoteEditor = true
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(hex: "#fcc418"))
                .foregroundColor(.black)
                .cornerRadius(16)
            }
            
            if !userNote.isEmpty {
                Text(userNote)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(4)
            } else {
                Text("No notes yet. Add your personal thoughts or connections!")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.5))
                    .italic()
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    private var relatedEntriesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related Entries")
                .font(.headline)
                .foregroundColor(Color(hex: "#3cc45b"))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(relatedEntries.prefix(5)) { relatedEntry in
                        RelatedEntryCard(entry: relatedEntry)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    private func toggleBookmark() {
        withAnimation {
            isBookmarked.toggle()
            userService.toggleBookmark(for: entry.id)
        }
    }
    
    private func saveNote() {
        userService.saveNote(for: entry.id, note: userNote)
    }
    
    private func loadRelatedEntries() {
        relatedEntries = dataService.getRelatedEntries(for: entry)
    }
}

struct RelatedEntryCard: View {
    let entry: KnowledgeEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: entry.category.icon)
                    .font(.caption)
                    .foregroundColor(Color(hex: entry.category.color))
                
                Spacer()
            }
            
            Text(entry.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .lineLimit(2)
            
            Text(entry.definition)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(3)
        }
        .padding(12)
        .frame(width: 120, height: 100)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}

struct NoteEditorView: View {
    @Binding var note: String
    let onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#3e4464")
                    .ignoresSafeArea()
                
                VStack {
                    TextEditor(text: $note)
                        .foregroundColor(.white)
                        .background(Color.clear)
                        .padding()
                }
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(hex: "#fcc418"))
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentDetailView(
        entry: KnowledgeEntry(
            title: "Serendipity",
            definition: "The occurrence and development of events by chance in a happy or beneficial way.",
            category: .dictionary,
            relatedTerms: ["fortune", "luck", "chance"],
            etymology: "Coined by Horace Walpole in 1754",
            examples: ["Example 1", "Example 2"]
        ),
        userService: UserService(),
        dataService: DataService()
    )
}

//
//  DataService.swift
//  KnowledgeVaultRoad
//
//  Created by Вячеслав on 10/23/25.
//

import Foundation

class DataService: ObservableObject {
    @Published var knowledgeEntries: [KnowledgeEntry] = []
    @Published var isLoading = false
    
    init() {
        loadKnowledgeData()
    }
    
    private func loadKnowledgeData() {
        // Real dictionary and encyclopedia data
        knowledgeEntries = [
            // Dictionary entries
            KnowledgeEntry(
                title: "Serendipity",
                definition: "The occurrence and development of events by chance in a happy or beneficial way; a pleasant surprise.",
                category: .dictionary,
                relatedTerms: ["fortune", "luck", "chance", "coincidence"],
                etymology: "Coined by Horace Walpole in 1754, from the Persian fairy tale 'The Three Princes of Serendip'",
                examples: ["The discovery of penicillin was a serendipity that revolutionized medicine.", "Meeting my business partner at that coffee shop was pure serendipity."]
            ),
            KnowledgeEntry(
                title: "Ephemeral",
                definition: "Lasting for a very short time; transitory.",
                category: .dictionary,
                relatedTerms: ["temporary", "fleeting", "transient", "momentary"],
                etymology: "From Greek ephēmeros, meaning 'lasting only a day'",
                examples: ["The beauty of cherry blossoms is ephemeral, lasting only a few weeks.", "Social media trends are often ephemeral, disappearing as quickly as they appear."]
            ),
            KnowledgeEntry(
                title: "Ubiquitous",
                definition: "Present, appearing, or found everywhere; omnipresent.",
                category: .dictionary,
                relatedTerms: ["omnipresent", "pervasive", "universal", "widespread"],
                etymology: "From Latin ubique meaning 'everywhere'",
                examples: ["Smartphones have become ubiquitous in modern society.", "The ubiquitous nature of plastic pollution affects every corner of our planet."]
            ),
            
            // Science entries
            KnowledgeEntry(
                title: "Photosynthesis",
                definition: "The process by which green plants and some other organisms use sunlight to synthesize foods with the aid of chlorophyll pigments.",
                category: .science,
                relatedTerms: ["chlorophyll", "glucose", "carbon dioxide", "oxygen"],
                etymology: "From Greek photos (light) and synthesis (putting together)",
                examples: ["Photosynthesis is essential for life on Earth as it produces oxygen.", "The equation for photosynthesis is: 6CO₂ + 6H₂O + light energy → C₆H₁₂O₆ + 6O₂"]
            ),
            KnowledgeEntry(
                title: "Quantum Entanglement",
                definition: "A physical phenomenon where pairs or groups of particles interact in ways such that the quantum state of each particle cannot be described independently.",
                category: .science,
                relatedTerms: ["quantum mechanics", "superposition", "Bell's theorem", "non-locality"],
                etymology: "Term coined by Erwin Schrödinger in 1935",
                examples: ["Einstein famously called quantum entanglement 'spooky action at a distance'.", "Quantum entanglement is being used to develop quantum computers and secure communication systems."]
            ),
            
            // Technology entries
            KnowledgeEntry(
                title: "Machine Learning",
                definition: "A method of data analysis that automates analytical model building using algorithms that iteratively learn from data.",
                category: .technology,
                relatedTerms: ["artificial intelligence", "neural networks", "deep learning", "algorithms"],
                etymology: "Term coined by Arthur Samuel in 1959",
                examples: ["Machine learning powers recommendation systems on streaming platforms.", "Medical diagnosis is being revolutionized by machine learning algorithms."]
            ),
            KnowledgeEntry(
                title: "Blockchain",
                definition: "A distributed ledger technology that maintains a continuously growing list of records, called blocks, linked and secured using cryptography.",
                category: .technology,
                relatedTerms: ["cryptocurrency", "distributed ledger", "cryptography", "decentralization"],
                etymology: "Conceptualized by Satoshi Nakamoto in 2008",
                examples: ["Bitcoin uses blockchain technology to maintain transaction records.", "Supply chain management is being improved through blockchain transparency."]
            ),
            
            // History entries
            KnowledgeEntry(
                title: "Renaissance",
                definition: "A period in European history marking the transition from the Middle Ages to modernity, covering roughly the 14th to 17th centuries.",
                category: .history,
                relatedTerms: ["humanism", "reformation", "art", "science"],
                etymology: "From French renaissance, meaning 'rebirth'",
                examples: ["The Renaissance saw the works of Leonardo da Vinci and Michelangelo.", "The printing press, invented during the Renaissance, revolutionized the spread of knowledge."]
            ),
            KnowledgeEntry(
                title: "Industrial Revolution",
                definition: "The transition to new manufacturing processes in Europe and the United States from about 1760 to 1840.",
                category: .history,
                relatedTerms: ["steam engine", "factory system", "urbanization", "mechanization"],
                etymology: "Term popularized by Arnold Toynbee in the 1880s",
                examples: ["The Industrial Revolution transformed agrarian societies into industrial ones.", "Steam-powered machinery revolutionized textile production during this period."]
            ),
            
            // Literature entries
            KnowledgeEntry(
                title: "Metaphor",
                definition: "A figure of speech that describes an object or action in a way that isn't literally true, but helps explain an idea or make a comparison.",
                category: .literature,
                relatedTerms: ["simile", "analogy", "figurative language", "symbolism"],
                etymology: "From Greek metaphora, meaning 'transfer'",
                examples: ["'Life is a journey' is a common metaphor.", "Shakespeare's 'All the world's a stage' is one of literature's most famous metaphors."]
            ),
            KnowledgeEntry(
                title: "Allegory",
                definition: "A story, poem, or picture that can be interpreted to reveal a hidden meaning, typically a moral or political one.",
                category: .literature,
                relatedTerms: ["symbolism", "parable", "metaphor", "moral"],
                etymology: "From Greek allegoria, meaning 'speaking otherwise'",
                examples: ["George Orwell's 'Animal Farm' is an allegory about the Russian Revolution.", "Plato's 'Allegory of the Cave' illustrates the nature of knowledge and reality."]
            ),
            
            // Philosophy entries
            KnowledgeEntry(
                title: "Existentialism",
                definition: "A philosophical theory emphasizing the existence of the individual person as a free and responsible agent determining their own development.",
                category: .philosophy,
                relatedTerms: ["free will", "authenticity", "absurdism", "phenomenology"],
                etymology: "From Latin existentia, meaning 'existence'",
                examples: ["Jean-Paul Sartre was a leading figure in existentialist philosophy.", "The phrase 'existence precedes essence' is central to existentialist thought."]
            ),
            KnowledgeEntry(
                title: "Stoicism",
                definition: "An ancient Greek philosophical school teaching that virtue, the highest good, is based on knowledge and that the wise live in harmony with divine reason.",
                category: .philosophy,
                relatedTerms: ["virtue ethics", "reason", "acceptance", "resilience"],
                etymology: "From Greek stoa, referring to the painted porch where the philosophy was taught",
                examples: ["Marcus Aurelius practiced Stoic philosophy as Roman Emperor.", "Stoicism teaches acceptance of what cannot be changed while focusing on what can be controlled."]
            ),
            
            // Arts entries
            KnowledgeEntry(
                title: "Impressionism",
                definition: "An art movement characterized by relatively small, thin, yet visible brush strokes, open composition, and emphasis on accurate depiction of light.",
                category: .arts,
                relatedTerms: ["plein air", "light", "color", "brushwork"],
                etymology: "Named after Claude Monet's painting 'Impression, Sunrise' (1872)",
                examples: ["Claude Monet and Pierre-Auguste Renoir were leading Impressionist painters.", "Impressionist works often depicted everyday scenes with emphasis on changing light conditions."]
            ),
            KnowledgeEntry(
                title: "Baroque",
                definition: "An artistic style that used exaggerated motion and clear detail to produce drama, exuberance, and grandeur in sculpture, painting, architecture, and music.",
                category: .arts,
                relatedTerms: ["ornate", "dramatic", "grandeur", "counter-reformation"],
                etymology: "From Portuguese barroco, meaning 'irregular pearl'",
                examples: ["Caravaggio's dramatic use of light and shadow exemplifies Baroque painting.", "Bach's compositions represent the pinnacle of Baroque music."]
            )
        ]
    }
    
    func searchEntries(query: String) -> [SearchResult] {
        guard !query.isEmpty else { return [] }
        
        var results: [SearchResult] = []
        let lowercaseQuery = query.lowercased()
        
        for entry in knowledgeEntries {
            // Title match
            if entry.title.lowercased().contains(lowercaseQuery) {
                results.append(SearchResult(entry: entry, matchType: .title))
            }
            // Definition match
            else if entry.definition.lowercased().contains(lowercaseQuery) {
                results.append(SearchResult(entry: entry, matchType: .definition))
            }
            // Related terms match
            else if entry.relatedTerms.contains(where: { $0.lowercased().contains(lowercaseQuery) }) {
                results.append(SearchResult(entry: entry, matchType: .relatedTerm))
            }
        }
        
        return results
    }
    
    func getEntriesByCategory(_ category: KnowledgeEntry.KnowledgeCategory) -> [KnowledgeEntry] {
        return knowledgeEntries.filter { $0.category == category }
    }
    
    func getRelatedEntries(for entry: KnowledgeEntry) -> [KnowledgeEntry] {
        return knowledgeEntries.filter { otherEntry in
            otherEntry.id != entry.id &&
            (otherEntry.category == entry.category ||
             entry.relatedTerms.contains(where: { term in
                 otherEntry.title.lowercased().contains(term.lowercased()) ||
                 otherEntry.relatedTerms.contains(where: { $0.lowercased().contains(term.lowercased()) })
             }))
        }
    }
}

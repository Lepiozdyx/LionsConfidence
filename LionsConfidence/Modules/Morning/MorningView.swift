import SwiftUI
import SwiftData

struct Affirmation {
    let title: String
    let icon: String
    let color: Color
    let quote: String
    let animalIcon: String
    let strength: Strengths
}

let affirmations: [Affirmation] = [
    Affirmation(title: "Charisma", icon: "✨", color: Color(red: 1.0, green: 0.6, blue: 0.2), quote: "You lead the way – even when you are silent.", animalIcon: "🦁", strength: .charisma),
    Affirmation(title: "Creativity", icon: "🎨", color: Color(red: 0.8, green: 0.4, blue: 1.0), quote: "Your ideas are born where others see emptiness.", animalIcon: "🐸", strength: .creativity),
    Affirmation(title: "Loyalty", icon: "👑", color: Color(red: 1.0, green: 0.8, blue: 0.2), quote: "You remain yourself – even when the world demands compromises.", animalIcon: "🦁", strength: .loyalty),
    Affirmation(title: "Determination", icon: "⚡", color: Color(red: 1.0, green: 0.5, blue: 0.2), quote: "You act – even when you doubt. That is strength.", animalIcon: "⚡", strength: .determination),
    Affirmation(title: "Wisdom", icon: "💡", color: Color(red: 0.4, green: 0.6, blue: 1.0), quote: "You see the essence – where others notice only the surface.", animalIcon: "🦉", strength: .wisdom),
    Affirmation(title: "Empathy", icon: "💗", color: Color(red: 1.0, green: 0.4, blue: 0.6), quote: "You feel others – and that is your superpower.", animalIcon: "🤲", strength: .empathy),
    Affirmation(title: "Growth", icon: "🌱", color: Color(red: 0.4, green: 0.8, blue: 0.4), quote: "You change – not because you must, but because you live.", animalIcon: "🛡️", strength: .growth),
    Affirmation(title: "Resilience", icon: "🏔️", color: Color(red: 0.3, green: 0.3, blue: 0.3), quote: "You endure – and in this is your quiet victory every day.", animalIcon: "🪨", strength: .resilience)
]

struct MorningView: View {
    @Query var mornings: [MorningModel]
    @Environment(\.modelContext) var context
    @State private var selectedStrengths: Set<Strengths> = []
    @State private var showAffirmationModal = false
    @State private var todayAffirmation: Affirmation?
    
    var todayMorning: MorningModel? {
        let calendar = Calendar.current
        return mornings.first { calendar.isDateInToday($0.date) }
    }
    
    var randomAffirmation: Affirmation {
        affirmations.randomElement() ?? affirmations[0]
    }
    
    var selectedCount: Int {
        selectedStrengths.count
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Good morning!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("What makes you strong today?")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 24) {
                        HStack {
                            Spacer()
                            Text("Selected: \(selectedCount)/2")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                AffirmationCard(
                                    affirmation: affirmations[0],
                                    isSelected: selectedStrengths.contains(affirmations[0].strength),
                                    action: {
                                        toggleStrength(affirmations[0].strength)
                                    }
                                )
                                
                                AffirmationCard(
                                    affirmation: affirmations[1],
                                    isSelected: selectedStrengths.contains(affirmations[1].strength),
                                    action: {
                                        toggleStrength(affirmations[1].strength)
                                    }
                                )
                            }
                            
                            HStack(spacing: 12) {
                                AffirmationCard(
                                    affirmation: affirmations[2],
                                    isSelected: selectedStrengths.contains(affirmations[2].strength),
                                    action: {
                                        toggleStrength(affirmations[2].strength)
                                    }
                                )
                                
                                AffirmationCard(
                                    affirmation: affirmations[3],
                                    isSelected: selectedStrengths.contains(affirmations[3].strength),
                                    action: {
                                        toggleStrength(affirmations[3].strength)
                                    }
                                )
                            }
                            
                            HStack(spacing: 12) {
                                AffirmationCard(
                                    affirmation: affirmations[4],
                                    isSelected: selectedStrengths.contains(affirmations[4].strength),
                                    action: {
                                        toggleStrength(affirmations[4].strength)
                                    }
                                )
                                
                                AffirmationCard(
                                    affirmation: affirmations[5],
                                    isSelected: selectedStrengths.contains(affirmations[5].strength),
                                    action: {
                                        toggleStrength(affirmations[5].strength)
                                    }
                                )
                            }
                            
                            HStack(spacing: 12) {
                                AffirmationCard(
                                    affirmation: affirmations[6],
                                    isSelected: selectedStrengths.contains(affirmations[6].strength),
                                    action: {
                                        toggleStrength(affirmations[6].strength)
                                    }
                                )
                                
                                AffirmationCard(
                                    affirmation: affirmations[7],
                                    isSelected: selectedStrengths.contains(affirmations[7].strength),
                                    action: {
                                        toggleStrength(affirmations[7].strength)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        if todayMorning == nil {
                            Button(action: {
                                todayAffirmation = randomAffirmation
                                showAffirmationModal = true
                            }) {
                                Text("Get Affirmation")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(red: 1.0, green: 0.6, blue: 0.2))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal, 20)
                        } else {
                            Button(action: {}) {
                                Text("Get Affirmation")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                                    .cornerRadius(12)
                            }
                            .disabled(true)
                            .padding(.horizontal, 20)
                        }
                        
                        Spacer(minLength: 20)
                    }
                }
            }
            
            if showAffirmationModal, let affirmation = todayAffirmation {
                AffirmationModal(
                    affirmation: affirmation,
                    isPresented: $showAffirmationModal,
                    onAccept: {
                        saveMorning()
                        showAffirmationModal = false
                    }
                )
            }
        }
    }
    
    func toggleStrength(_ strength: Strengths) {
        if selectedStrengths.contains(strength) {
            selectedStrengths.remove(strength)
        } else if selectedStrengths.count < 2 {
            selectedStrengths.insert(strength)
        }
    }
    
    func saveMorning() {
        let newMorning = MorningModel(
            date: Date(),
            wasAffermation: true,
            strengths: Array(selectedStrengths)
        )
        context.insert(newMorning)
        try? context.save()
        
        selectedStrengths = []
    }
}

struct AffirmationCard: View {
    let affirmation: Affirmation
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(affirmation.icon)
                    .font(.system(size: 32))
                    .frame(width: 56, height: 56)
                    .background(affirmation.color.opacity(0.15))
                    .cornerRadius(12)
                
                Text(affirmation.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? affirmation.color : Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}

struct AffirmationModal: View {
    let affirmation: Affirmation
    @Binding var isPresented: Bool
    let onAccept: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Text(affirmation.animalIcon)
                        .font(.system(size: 64))
                    
                    VStack(spacing: 12) {
                        Text("Your Affirmation")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(affirmation.color)
                        
                        Text("\"\(affirmation.quote)\"")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
                .background(Color.white)
                .cornerRadius(20)
                
                Button(action: onAccept) {
                    Text("Accept")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(affirmation.color)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding()
            .padding(.top, 80.fitH)
        }
    }
}

#Preview {
    MorningView()
        .modelContainer(for: MorningModel.self, inMemory: true)
}

import SwiftData
import Foundation

@Model
class MorningModel {
    var id = UUID()
    
    var date: Date
    var wasAffermation: Bool
    var strengths: [Strengths]
    
    init(id: UUID = UUID(), date: Date, wasAffermation: Bool, strengths: [Strengths]) {
        self.id = id
        self.date = date
        self.wasAffermation = wasAffermation
        self.strengths = strengths
    }
}

enum Strengths: String, CaseIterable, Codable {
    case charisma, creativity, loyalty, determination, wisdom, empathy, growth, resilience
}

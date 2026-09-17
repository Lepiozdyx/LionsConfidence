import Foundation
import SwiftData

@Model
class LogModel {
    var id = UUID()
    
    var text: String
    var date: Date
    var mode: YinYangMode
    
    init(id: UUID = UUID(), text: String, date: Date, mode: YinYangMode) {
        self.id = id
        self.text = text
        self.date = date
        self.mode = mode
    }
}

enum YinYangMode: String, CaseIterable, Codable {
    case gtrength, growth
}

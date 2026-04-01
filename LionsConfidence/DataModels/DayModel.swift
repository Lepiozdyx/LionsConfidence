import SwiftData
import Foundation

@Model
class DayModel {
    var id = UUID()
    
    var dayDate: Date
    
    var peakHoursStart: Date
    var peakHoursEnd: Date
    
    var fatigueHoursStart: Date
    var fatigueHoursEnd: Date
    
    init(id: UUID = UUID(), dayDate: Date, peakHoursStart: Date, peakHoursEnd: Date, fatigueHoursStart: Date, fatigueHoursEnd: Date) {
        self.id = id
        self.dayDate = dayDate
        self.peakHoursStart = peakHoursStart
        self.peakHoursEnd = peakHoursEnd
        self.fatigueHoursStart = fatigueHoursStart
        self.fatigueHoursEnd = fatigueHoursEnd
    }
}

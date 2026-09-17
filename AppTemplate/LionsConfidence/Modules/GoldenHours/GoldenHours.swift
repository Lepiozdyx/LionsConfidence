import SwiftUI
import SwiftData

struct GoldenHours: View {
    @Query var days: [DayModel]
    @Environment(\.modelContext) var context
    
    @State private var showPeakForm = false
    @State private var showFatigueForm = false
    @State private var selectedPeakStart: Date = Date()
    @State private var selectedPeakEnd: Date = Date()
    @State private var selectedFatigueStart: Date = Date()
    @State private var selectedFatigueEnd: Date = Date()
    @State private var errorMessage: String = ""
    
    var todayDay: DayModel? {
        let calendar = Calendar.current
        return days.first { calendar.isDateInToday($0.dayDate) }
    }
    
    var isPeakLogged: Bool {
        guard let day = todayDay else { return false }
        return day.peakHoursStart != day.peakHoursEnd
    }
    
    var isFatigueLogged: Bool {
        guard let day = todayDay else { return false }
        return day.fatigueHoursStart != day.fatigueHoursEnd
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Golden Hours")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                Text("Track your daily energy cycles to find your rhythm.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 24)
            
            ScrollView {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Today's Timeline")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        
                        TimelineView(todayDay: todayDay)
                    }
                    .padding(.horizontal, 20)
                    
                    if !errorMessage.isEmpty {
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                
                                Text(errorMessage)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                    }
                    
                    if showPeakForm {
                        TimeRangeForm(
                            title: "Add Peak Hours",
                            icon: "☀️",
                            startTime: $selectedPeakStart,
                            endTime: $selectedPeakEnd,
                            onCancel: {
                                showPeakForm = false
                                errorMessage = ""
                            },
                            onSave: { savePeakHours() }
                        )
                        .padding(.horizontal, 20)
                    } else if showFatigueForm {
                        TimeRangeForm(
                            title: "Add Fatigue Hours",
                            icon: "🌙",
                            startTime: $selectedFatigueStart,
                            endTime: $selectedFatigueEnd,
                            onCancel: {
                                showFatigueForm = false
                                errorMessage = ""
                            },
                            onSave: { saveFatigueHours() }
                        )
                        .padding(.horizontal, 20)
                    } else {
                        VStack(spacing: 12) {
                            if !isPeakLogged {
                                LogButton(
                                    icon: "☀️",
                                    title: "Log Peak",
                                    subtitle: "High energy, focus, charisma",
                                    isPeak: true,
                                    action: {
                                        selectedPeakStart = Date()
                                        selectedPeakEnd = Date().addingTimeInterval(3600)
                                        showPeakForm = true
                                        errorMessage = ""
                                    }
                                )
                            } else if let day = todayDay {
                                LoggedButton(
                                    icon: "☀️",
                                    title: "Log Peak",
                                    startTime: day.peakHoursStart,
                                    endTime: day.peakHoursEnd,
                                    isPeak: true,
                                    onEdit: {
                                        selectedPeakStart = day.peakHoursStart
                                        selectedPeakEnd = day.peakHoursEnd
                                        showPeakForm = true
                                        errorMessage = ""
                                    }
                                )
                            }
                            
                            if !isFatigueLogged {
                                LogButton(
                                    icon: "🌙",
                                    title: "Log Fatigue",
                                    subtitle: "Rest, recovery, downtime",
                                    isPeak: false,
                                    action: {
                                        selectedFatigueStart = Date()
                                        selectedFatigueEnd = Date().addingTimeInterval(3600)
                                        showFatigueForm = true
                                        errorMessage = ""
                                    }
                                )
                            } else if let day = todayDay {
                                LoggedButton(
                                    icon: "🌙",
                                    title: "Log Fatigue",
                                    startTime: day.fatigueHoursStart,
                                    endTime: day.fatigueHoursEnd,
                                    isPeak: false,
                                    onEdit: {
                                        selectedFatigueStart = day.fatigueHoursStart
                                        selectedFatigueEnd = day.fatigueHoursEnd
                                        showFatigueForm = true
                                        errorMessage = ""
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 20)
                }
            }
        }
        .background(Color.white)
    }
    
    func checkOverlap() -> Bool {
        guard let day = todayDay else { return false }
        
        let peakStart = selectedPeakStart
        let peakEnd = selectedPeakEnd
        let fatigueStart = selectedFatigueStart
        let fatigueEnd = selectedFatigueEnd
        
        let peakRange = peakStart..<peakEnd
        let fatigueRange = fatigueStart..<fatigueEnd
        
        if peakRange.overlaps(fatigueRange) {
            errorMessage = "Peak and Fatigue hours cannot overlap"
            return true
        }
        
        return false
    }
    
    func savePeakHours() {
        if checkOverlap() {
            return
        }
        
        if let existingDay = todayDay {
            existingDay.peakHoursStart = selectedPeakStart
            existingDay.peakHoursEnd = selectedPeakEnd
        } else {
            let newDay = DayModel(
                dayDate: Date(),
                peakHoursStart: selectedPeakStart,
                peakHoursEnd: selectedPeakEnd,
                fatigueHoursStart: Date(),
                fatigueHoursEnd: Date()
            )
            context.insert(newDay)
        }
        try? context.save()
        showPeakForm = false
        errorMessage = ""
    }
    
    func saveFatigueHours() {
        if checkOverlap() {
            return
        }
        
        if let existingDay = todayDay {
            existingDay.fatigueHoursStart = selectedFatigueStart
            existingDay.fatigueHoursEnd = selectedFatigueEnd
        } else {
            let newDay = DayModel(
                dayDate: Date(),
                peakHoursStart: Date(),
                peakHoursEnd: Date(),
                fatigueHoursStart: selectedFatigueStart,
                fatigueHoursEnd: selectedFatigueEnd
            )
            context.insert(newDay)
        }
        try? context.save()
        showFatigueForm = false
        errorMessage = ""
    }
}

struct TimelineView: View {
    let todayDay: DayModel?
    
    var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        ForEach(0..<24, id: \.self) { index in
                            TimelineHour(hour: index, todayDay: todayDay)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        ForEach(0..<24, id: \.self) { index in
                            Text(String(format: "%02d:00", index))
                                .font(.system(size: 10, weight: .regular))
                                .foregroundColor(.gray)
                                .frame(width: 50, alignment: .center)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

struct TimelineHour: View {
    let hour: Int
    let todayDay: DayModel?
    
    var backgroundColor: Color {
        guard let day = todayDay else { return Color(red: 0.95, green: 0.95, blue: 0.95) }
        
        let calendar = Calendar.current
        let hourDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
        
        let isPeakHour = hourDate >= day.peakHoursStart && hourDate < day.peakHoursEnd
        let isFatigueHour = hourDate >= day.fatigueHoursStart && hourDate < day.fatigueHoursEnd
        
        if isPeakHour {
            return Color(red: 1.0, green: 0.85, blue: 0.2)
        } else if isFatigueHour {
            return Color(red: 0.6, green: 0.4, blue: 1.0)
        }
        
        return Color(red: 0.95, green: 0.95, blue: 0.95)
    }
    
    var icon: String {
        guard let day = todayDay else { return "" }
        
        let calendar = Calendar.current
        let hourDate = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: Date())!
        
        if hourDate >= day.peakHoursStart && hourDate < day.peakHoursEnd {
            return "✨"
        } else if hourDate >= day.fatigueHoursStart && hourDate < day.fatigueHoursEnd {
            return "💤"
        }
        
        return ""
    }
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
                
                Text(icon)
                    .font(.system(size: 16))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
        }
    }
}

struct LogButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let isPeak: Bool
    let action: () -> Void
    
    var colorText: Color {
        title == "Log Peak" ? .white : .black
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 20))
                    .frame(width: 40, height: 40)
                    .background(isPeak ? Color.black : Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(colorText)
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isPeak ? .black : Color(red: 0.8, green: 0.8, blue: 0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isPeak ? Color.black : Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isPeak ? Color.clear : Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
            )
        }
    }
}

struct LoggedButton: View {
    let icon: String
    let title: String
    let startTime: Date
    let endTime: Date
    let isPeak: Bool
    let onEdit: () -> Void
    
    var timeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 20))
                    .frame(width: 40, height: 40)
                    .background(isPeak ? Color.black : Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text(timeRange)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isPeak ? Color.black : Color(red: 0.8, green: 0.8, blue: 0.8))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
            )
        }
    }
}

struct TimeRangeForm: View {
    let title: String
    let icon: String
    @Binding var startTime: Date
    @Binding var endTime: Date
    let onCancel: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Text(icon)
                    .font(.system(size: 20))
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                    
                    DatePicker(
                        "",
                        selection: $startTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("End")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                    
                    DatePicker(
                        "",
                        selection: $endTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                }
            }
            
            HStack(spacing: 12) {
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                        .cornerRadius(12)
                }
                
                Button(action: onSave) {
                    Text("Save Range")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 1.0, green: 0.6, blue: 0.2))
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
        )
    }
}

#Preview {
    GoldenHours()
        .modelContainer(for: DayModel.self, inMemory: true)
}

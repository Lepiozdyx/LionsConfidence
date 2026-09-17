import SwiftUI
import SwiftData

struct StatView: View {
    @Query var days: [DayModel]
    @Query var logs: [LogModel]
    @Query var mornings: [MorningModel]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Patterns")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Discover your monthly rhythms and balances.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 24) {
                        EnergyByDayCard(days: days)
                        StrengthsOfMonthCard(logs: logs, mornings: mornings)
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

struct EnergyByDayCard: View {
    let days: [DayModel]
    
    var hasData: Bool {
        !days.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Energy by Day")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.85, blue: 0.2))
                            .frame(width: 8, height: 8)
                        
                        Text("Peak")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(red: 0.2, green: 0.5, blue: 1.0))
                            .frame(width: 8, height: 8)
                        
                        Text("Fatigue")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            if hasData {
                EnergyChartView(days: days)
                    .frame(height: 200)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                    
                    Text("No data yet")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("Start logging your energy patterns")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
                )
        )
    }
}

struct EnergyChartView: View {
    let days: [DayModel]
    
    var peakHours: [Int] {
        let calendar = Calendar.current
        let thisMonth = calendar.dateComponents([.month, .year], from: Date())
        
        return days.filter { day in
            let dayComponents = calendar.dateComponents([.month, .year], from: day.dayDate)
            return dayComponents.month == thisMonth.month && dayComponents.year == thisMonth.year
        }
        .map { day in
            calendar.component(.hour, from: day.peakHoursStart)
        }
        .sorted()
    }
    
    var fatigueHours: [Int] {
        let calendar = Calendar.current
        let thisMonth = calendar.dateComponents([.month, .year], from: Date())
        
        return days.filter { day in
            let dayComponents = calendar.dateComponents([.month, .year], from: day.dayDate)
            return dayComponents.month == thisMonth.month && dayComponents.year == thisMonth.year
        }
        .map { day in
            calendar.component(.hour, from: day.fatigueHoursStart)
        }
        .sorted()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(16..<30, id: \.self) { day in
                    VStack(spacing: 4) {
                        Capsule()
                            .fill(Color(red: 1.0, green: 0.85, blue: 0.2))
                            .frame(height: CGFloat.random(in: 20...60))
                        
                        Capsule()
                            .fill(Color(red: 0.2, green: 0.5, blue: 1.0))
                            .frame(height: CGFloat.random(in: 20...60))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 120)
            
            HStack(spacing: 0) {
                Text("20:00")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("16")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("29")
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.gray)
            }
        }
    }
}

struct StrengthsOfMonthCard: View {
    let logs: [LogModel]
    let mornings: [MorningModel]
    
    var hasData: Bool {
        !mornings.isEmpty
    }
    
    var strengthStats: [(name: String, icon: String, color: Color, percentage: Int)] {
        let strengthsData: [(Strengths, String, String, Color)] = [
            (.charisma, "Charisma", "✨", Color(red: 1.0, green: 0.6, blue: 0.2)),
            (.determination, "Determination", "⚡", Color(red: 1.0, green: 0.5, blue: 0.2)),
            (.creativity, "Creativity", "🎨", Color(red: 0.8, green: 0.4, blue: 1.0)),
            (.loyalty, "Loyalty", "👑", Color(red: 1.0, green: 0.8, blue: 0.2)),
            (.empathy, "Empathy", "💗", Color(red: 1.0, green: 0.4, blue: 0.6)),
            (.growth, "Growth", "🌱", Color(red: 0.4, green: 0.8, blue: 0.4)),
            (.wisdom, "Wisdom", "💡", Color(red: 0.4, green: 0.6, blue: 1.0)),
            (.resilience, "Resilience", "🏔️", Color(red: 0.3, green: 0.3, blue: 0.3))
        ]
        
        return strengthsData.map { strength, name, icon, color in
            let count = mornings.reduce(0) { total, morning in
                total + (morning.strengths.contains(strength) ? 1 : 0)
            }
            let percentage = mornings.isEmpty ? 0 : (count * 100) / mornings.count
            return (name: name, icon: icon, color: color, percentage: percentage)
        }
        .sorted { $0.percentage > $1.percentage }
    }
    
    var topStrength: (name: String, percentage: Int)? {
        strengthStats.first.map { ($0.name, $0.percentage) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Strengths of the Month")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                
                if let top = topStrength {
                    Text("You most frequently choose \(top.name.lowercased()) (\(top.percentage)%)")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            
            if hasData {
                VStack(spacing: 20) {
                    DonutChartView(stats: strengthStats)
                        .frame(height: 160)
                    
                    VStack(spacing: 8) {
                        ForEach(strengthStats, id: \.name) { stat in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(stat.color)
                                    .frame(width: 12, height: 12)
                                
                                Text(stat.name)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Text("\(stat.percentage)%")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "chart.pie")
                        .font(.system(size: 32))
                        .foregroundColor(.gray)
                    
                    Text("No data yet")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("Start logging your strengths in the morning")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
                )
        )
    }
}

struct DonutChartView: View {
    let stats: [(name: String, icon: String, color: Color, percentage: Int)]
    
    var body: some View {
        ZStack {
            ForEach(0..<stats.count, id: \.self) { index in
                let stat = stats[index]
                let startAngle = calculateStartAngle(for: index)
                let endAngle = startAngle + (Double(stat.percentage) / 100.0 * 360)
                
                ZStack {
                    Circle()
                        .trim(from: CGFloat(startAngle / 360), to: CGFloat(endAngle / 360))
                        .stroke(stat.color, lineWidth: 24)
                }
                .rotationEffect(.degrees(-90))
            }
            
            Circle()
                .fill(Color.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(60)
        }
    }
    
    func calculateStartAngle(for index: Int) -> Double {
        var angle: Double = 0
        for i in 0..<index {
            angle += Double(stats[i].percentage) / 100.0 * 360
        }
        return angle
    }
}

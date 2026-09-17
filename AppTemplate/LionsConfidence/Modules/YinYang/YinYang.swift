import SwiftUI
import SwiftData

struct YinYang: View {
    @Query var logs: [LogModel]
    @Environment(\.modelContext) var context
    @State private var showAddForm = false
    @State private var selectedMode: YinYangMode = .gtrength
    @State private var logText: String = ""
    @State private var editingLog: LogModel?
    @State private var showEditForm = false
    
    var strengthCount: Int {
        logs.filter { $0.mode == .gtrength }.count
    }
    
    var growthCount: Int {
        logs.filter { $0.mode == .growth }.count
    }
    
    var totalCount: Int {
        logs.count
    }
    
    var strengthPercentage: Int {
        guard totalCount > 0 else { return 50 }
        return (strengthCount * 100) / totalCount
    }
    
    var growthPercentage: Int {
        guard totalCount > 0 else { return 50 }
        return (growthCount * 100) / totalCount
    }
    
    var sortedLogs: [LogModel] {
        logs.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Two Lions")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Balance your strengths and areas for growth.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 16) {
                            YinYangCircle(
                                strengthPercentage: strengthPercentage,
                                growthPercentage: growthPercentage
                            )
                            .frame(height: 240)
                            
                            HStack(spacing: 16) {
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color(red: 1.0, green: 0.85, blue: 0.2))
                                        .frame(width: 12, height: 12)
                                    
                                    Text("Strength \(strengthPercentage)%")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                                
                                HStack(spacing: 6) {
                                    Circle()
                                        .fill(Color(red: 0.8, green: 0.8, blue: 0.8))
                                        .frame(width: 12, height: 12)
                                    
                                    Text("Growth \(growthPercentage)%")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(sortedLogs, id: \.id) { log in
                                ZStack {
                                    LogCard(log: log)
                                    
                                    HStack {
                                        Spacer()
                                        
                                        HStack(spacing: 8) {
                                            Button {
                                                editingLog = log
                                                logText = log.text
                                                selectedMode = log.mode
                                                showEditForm = true
                                            } label: {
                                                Image("editBtn")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 28.fitH)
                                            }
                                            
                                            Button(role: .destructive) {
                                                context.delete(log)
                                                try? context.save()
                                            } label: {
                                                Image("delBtn")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 28.fitH)
                                            }
                                        }
                                        .padding(.trailing, 12)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Button(action: { showAddForm = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Add to Circle")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 1.0, green: 0.6, blue: 0.2))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer(minLength: 20)
                    }
                }
            }
            .hideKeyboardOnTap()
            
            if showAddForm {
                AddLogModal(
                    isPresented: $showAddForm,
                    selectedMode: $selectedMode,
                    logText: $logText,
                    onSave: { saveLog() }
                )
            }
            
            if showEditForm {
                EditLogModal(
                    isPresented: $showEditForm,
                    selectedMode: $selectedMode,
                    logText: $logText,
                    onSave: { updateLog() }
                )
            }
        }
    }
    
    func saveLog() {
        guard !logText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let newLog = LogModel(text: logText, date: Date(), mode: selectedMode)
        context.insert(newLog)
        try? context.save()
        
        logText = ""
        selectedMode = .gtrength
        showAddForm = false
    }
    
    func updateLog() {
        guard !logText.trimmingCharacters(in: .whitespaces).isEmpty,
              let log = editingLog else { return }
        
        log.text = logText
        log.mode = selectedMode
        try? context.save()
        
        logText = ""
        selectedMode = .gtrength
        editingLog = nil
        showEditForm = false
    }
}

struct YinYangCircle: View {
    let strengthPercentage: Int
    let growthPercentage: Int
    
    var rotationAngle: Double {
        let balance = Double(strengthPercentage - growthPercentage)
        return balance * 0.36
    }
    
    var body: some View {
        ZStack {
            Image("yinYang")
                .resizable()
                .scaledToFit()
                .rotationEffect(.degrees(rotationAngle))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct LogCard: View {
    let log: LogModel
    
    var icon: String {
        log.mode == .gtrength ? "🦁" : "🦁"
    }
    
    var iconColor: Color {
        log.mode == .gtrength ? Color(red: 1.0, green: 0.85, blue: 0.2) : Color(red: 0.8, green: 0.8, blue: 0.8)
    }
    
    var modeTitle: String {
        log.mode == .gtrength ? "Strength" : "Growth"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 20))
                    .frame(width: 40, height: 40)
                    .background(iconColor.opacity(0.15))
                    .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(log.text)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    Text(log.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.9, green: 0.9, blue: 0.9), lineWidth: 1)
        )
    }
}

struct AddLogModal: View {
    @Binding var isPresented: Bool
    @Binding var selectedMode: YinYangMode
    @Binding var logText: String
    let onSave: () -> Void
    
    var modeIcon: String {
        selectedMode == .gtrength ? "🦁" : "🦁"
    }
    
    var modeTitle: String {
        selectedMode == .gtrength ? "Strength" : "Growth"
    }
    
    var characterCount: Int {
        logText.count
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    HStack(spacing: 8) {
                        Text(modeIcon)
                            .font(.system(size: 16))
                        
                        Text("Log \(modeTitle)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedMode == .gtrength ?
                        "What did you do well? What are your strengths?" :
                        "What caused difficulties? What did you learn?")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $logText)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.black)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 120)
                        
                        if logText.isEmpty {
                            Text(selectedMode == .gtrength ?
                                "Write about your strength..." :
                                "Write about your growth...")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(8)
                    
                    HStack {
                        Spacer()
                        
                        Text("\(characterCount) / 280")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 16)
                
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Button(action: { selectedMode = .gtrength }) {
                            HStack(spacing: 6) {
                                Text("🦁")
                                    .font(.system(size: 14))
                                
                                Text("Strength")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(selectedMode == .gtrength ? .white : .gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedMode == .gtrength ?
                                Color(red: 1.0, green: 0.85, blue: 0.2) :
                                Color(red: 0.95, green: 0.95, blue: 0.95))
                            .cornerRadius(8)
                        }
                        
                        Button(action: { selectedMode = .growth }) {
                            HStack(spacing: 6) {
                                Text("🦁")
                                    .font(.system(size: 14))
                                
                                Text("Growth")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(selectedMode == .growth ? .white : .gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedMode == .growth ?
                                Color(red: 0.8, green: 0.8, blue: 0.8) :
                                Color(red: 0.95, green: 0.95, blue: 0.95))
                            .cornerRadius(8)
                        }
                    }
                    
                    Button(action: onSave) {
                        Text("+ Add to Circle")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 1.0, green: 0.6, blue: 0.2))
                            .cornerRadius(8)
                    }
                    .disabled(logText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .hideKeyboardOnTap()
            .background(Color.white)
            .cornerRadius(16)
            .padding(20)
        }
    }
}

struct EditLogModal: View {
    @Binding var isPresented: Bool
    @Binding var selectedMode: YinYangMode
    @Binding var logText: String
    let onSave: () -> Void
    
    var modeIcon: String {
        selectedMode == .gtrength ? "🦁" : "🦁"
    }
    
    var modeTitle: String {
        selectedMode == .gtrength ? "Strength" : "Growth"
    }
    
    var characterCount: Int {
        logText.count
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            
            VStack(spacing: 16) {
                HStack {
                    HStack(spacing: 8) {
                        Text(modeIcon)
                            .font(.system(size: 16))
                        
                        Text("Edit \(modeTitle)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(selectedMode == .gtrength ?
                        "What did you do well? What are your strengths?" :
                        "What caused difficulties? What did you learn?")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $logText)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.black)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 120)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                    .cornerRadius(8)
                    
                    HStack {
                        Spacer()
                        
                        Text("\(characterCount) / 280")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 16)
                
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Button(action: { selectedMode = .gtrength }) {
                            HStack(spacing: 6) {
                                Text("🦁")
                                    .font(.system(size: 14))
                                
                                Text("Strength")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(selectedMode == .gtrength ? .white : .gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedMode == .gtrength ?
                                Color(red: 1.0, green: 0.85, blue: 0.2) :
                                Color(red: 0.95, green: 0.95, blue: 0.95))
                            .cornerRadius(8)
                        }
                        
                        Button(action: { selectedMode = .growth }) {
                            HStack(spacing: 6) {
                                Text("🦁")
                                    .font(.system(size: 14))
                                
                                Text("Growth")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(selectedMode == .growth ? .white : .gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedMode == .growth ?
                                Color(red: 0.8, green: 0.8, blue: 0.8) :
                                Color(red: 0.95, green: 0.95, blue: 0.95))
                            .cornerRadius(8)
                        }
                    }
                    
                    Button(action: onSave) {
                        Text("Save Changes")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(red: 1.0, green: 0.6, blue: 0.2))
                            .cornerRadius(8)
                    }
                    .disabled(logText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .hideKeyboardOnTap()
            .background(Color.white)
            .cornerRadius(16)
            .padding(20)
        }
    }
}

#Preview {
    YinYang()
        .modelContainer(for: LogModel.self, inMemory: true)
}

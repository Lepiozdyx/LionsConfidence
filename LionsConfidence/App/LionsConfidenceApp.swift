import SwiftUI
import SwiftData

@main
struct LionsConfidenceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabBarView()
            .preferredColorScheme(.light)
            .modelContainer(for: [
                DayModel.self,
                MorningModel.self,
                LogModel.self,
            ])
    }
}

#Preview {
    ContentView()
}

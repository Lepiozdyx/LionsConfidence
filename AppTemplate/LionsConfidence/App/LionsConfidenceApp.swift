import SwiftUI
import SwiftData

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

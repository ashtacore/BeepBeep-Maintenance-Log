import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            GarageListView()
                .tabItem { Label("Garage", systemImage: "car.fill") }
            
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
    }
}

#Preview {
    ContentView()
        // Inject the dummy data container we created earlier
        .modelContainer(PreviewSampleData.container)
}

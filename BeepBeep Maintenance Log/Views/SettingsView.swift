import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    // Fetch only archived cars
    @Query(filter: #Predicate<Vehicle> { $0.isArchived }) private var archivedVehicles: [Vehicle]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Archived Vehicles") {
                    if archivedVehicles.isEmpty {
                        Text("No archived vehicles").foregroundStyle(.secondary)
                    } else {
                        ForEach(archivedVehicles) { vehicle in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(vehicle.title)
                                    Text("Archived").font(.caption).foregroundStyle(.orange)
                                }
                                Spacer()
                                Button("Restore") {
                                    vehicle.isArchived = false
                                    vehicle.sortOrder = 9999
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .onDelete(perform: deletePermanently)
                    }
                }
                
                Section("About") {
                    Text("Vehicle Tracker v1.0")
                }
            }
            .navigationTitle("Settings")
        }
    }
    
    // Delete from database permanently
    private func deletePermanently(offsets: IndexSet) {
        for index in offsets {
            let vehicle = archivedVehicles[index]
            modelContext.delete(vehicle)
        }
    }
}

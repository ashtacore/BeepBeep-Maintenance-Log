import SwiftUI
import SwiftData

struct GarageListView: View {
    @Environment(\.modelContext) private var modelContext
    // Query only unarchived cars
    @Query(filter: #Predicate<Vehicle> { !$0.isArchived }, sort: \Vehicle.year, order: .reverse) private var vehicles: [Vehicle]
    
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(vehicles) { vehicle in
                    NavigationLink(destination: VehicleDetailView(vehicle: vehicle)) {
                        VStack(alignment: .leading) {
                            Text(vehicle.title).font(.headline)
                            Text("\(vehicle.records.count) records").font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete(perform: archiveVehicles) // Swipe to archive
                .onMove(perform: moveVehicles)      // Reorder
            }
            .navigationTitle("My Garage")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton() // Standard SwiftUI Edit/Done button
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddVehicleView()
            }
        }
    }

    // Instead of deleting permanently here, we just set isArchived = true
    private func archiveVehicles(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                vehicles[index].isArchived = true
            }
        }
    }
    
    private func moveVehicles(from source: IndexSet, to destination: Int) {
        // Note: SwiftData sorting is usually based on descriptors.
        // For manual reordering, you would typically add a 'sortOrder' Int property to your Model.
    }
}

#Preview {
    GarageListView()
        .modelContainer(PreviewSampleData.container)
}

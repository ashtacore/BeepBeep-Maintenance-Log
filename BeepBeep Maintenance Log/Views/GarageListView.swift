import SwiftUI
import SwiftData

struct GarageListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Vehicle> { !$0.isArchived }, sort: \Vehicle.sortOrder) private var vehicles: [Vehicle]
    
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
                    EditButton()
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

    // We don't want to make deletions easy. Any "deleted" cars will be moved to archive
    private func archiveVehicles(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                vehicles[index].isArchived = true
            }
        }
    }
    
    private func moveVehicles(from source: IndexSet, to destination: Int) {
        var updatedVehicleList = vehicles
        updatedVehicleList.move(fromOffsets: source, toOffset: destination)
        
        for (index, vehicle) in updatedVehicleList.enumerated() {
            vehicle.sortOrder = index
        }
    }
}

#Preview {
    GarageListView()
        .modelContainer(PreviewSampleData.container)
}

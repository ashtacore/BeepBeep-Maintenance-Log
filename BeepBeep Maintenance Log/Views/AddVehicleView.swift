import SwiftUI
import SwiftData

struct AddVehicleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query(filter: #Predicate<Vehicle> { !$0.isArchived }, sort: \Vehicle.sortOrder, order: .reverse) private var vehicles: [Vehicle]
    
    @State private var make = ""
    @State private var model = ""
    @State private var year = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Year", text: $year).keyboardType(.numberPad)
                TextField("Make", text: $make)
                TextField("Model", text: $model)
            }
            .navigationTitle("Add Vehicle")
            .toolbar {
                Button("Save") {
                    let newCar = Vehicle(make: make, model: model, year: year, sortOrder: vehicles.first?.sortOrder.advanced(by: 1) ?? 0)
                    modelContext.insert(newCar)
                    dismiss()
                }
                .disabled(make.isEmpty || model.isEmpty)
            }
        }
    }
}

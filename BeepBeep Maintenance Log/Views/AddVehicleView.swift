import SwiftUI
import SwiftData

struct AddVehicleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
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
                    let newCar = Vehicle(make: make, model: model, year: year)
                    modelContext.insert(newCar)
                    dismiss()
                }
                .disabled(make.isEmpty || model.isEmpty)
            }
        }
    }
}

import SwiftUI
import SwiftData

@MainActor
class PreviewSampleData {
    static let container: ModelContainer = {
        do {
            // 1. configuration: isStoredInMemoryOnly = true ensures we don't write to the real disk
            let schema = Schema([Vehicle.self, MaintenanceRecord.self])
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [config])
            
            // 2. Add some dummy data
            let car1 = Vehicle(make: "Toyota", model: "Tacoma", year: "2018", sortOrder: 0)
            let car2 = Vehicle(make: "Ford", model: "Mustang", year: "1967", sortOrder: 1)
            let car3 = Vehicle(make: "Nissan", model: "Frontier", year: "2011", sortOrder: 2)
            let car4 = Vehicle(make: "Jeep", model: "Wrangler", year: "2022", sortOrder: 3)
            car2.isArchived = true
            
            container.mainContext.insert(car1)
            container.mainContext.insert(car2)
            container.mainContext.insert(car3)
            container.mainContext.insert(car4)
            
            // 3. Add a record to the first car
            let record = MaintenanceRecord(
                title: "Oil Change",
                details: "Replaced with synthetic oil 5W-30",
                mileage: 45000
            )
            car1.records.append(record)
            
            return container
        } catch {
            fatalError("Failed to create preview container: \(error.localizedDescription)")
        }
    }()
    
    // Helper to get a single vehicle for Detail Views
    static var vehicle: Vehicle {
        let context = container.mainContext
        let vehicle = try? context.fetch(FetchDescriptor<Vehicle>()).first
        return vehicle ?? Vehicle(make: "Test", model: "Car", year: "2024", sortOrder: 0)
    }
}

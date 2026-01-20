import SwiftData
import SwiftUI

@Model
class Vehicle {
    var make: String
    var model: String
    var year: String
    var isArchived: Bool = false
    // Relationship: One vehicle has many records
    // .cascade means if you delete the car, the records are deleted too
    @Relationship(deleteRule: .cascade) var records: [MaintenanceRecord] = []
    
    // Computed property for easy display
    var title: String {
        "\(year) \(make) \(model)"
    }
    
    init(make: String, model: String, year: String) {
        self.make = make
        self.model = model
        self.year = year
    }
}

import SwiftData
import SwiftUI

@Model
class Vehicle {
    var make: String
    var model: String
    var year: String
    var sortOrder: Int
    var isArchived: Bool = false
    
    
    @Relationship(deleteRule: .cascade) var records: [MaintenanceRecord] = []
    
    // Computed property for easy display
    var title: String {
        "\(year) \(make) \(model)"
    }
    
    init(make: String, model: String, year: String, sortOrder: Int) {
        self.make = make
        self.model = model
        self.year = year
        self.sortOrder = sortOrder
    }
}

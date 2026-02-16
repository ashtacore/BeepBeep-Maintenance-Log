import SwiftData
import SwiftUI

@Model
class Vehicle {
    var make: String
    var model: String
    var year: String
    var sortOrder: Int
    var isArchived: Bool = false
    var nickname: String?
    
    
    @Relationship(deleteRule: .cascade) var records: [MaintenanceRecord] = []
    
    // Computed property for easy display
    var title: String {
        "\(year) \(make) \(model)"
    }
    
    // Display title with nickname if available
    var displayTitle: String {
        if let nickname, !nickname.isEmpty {
            return "\(title) (\(nickname))"
        }
        return title
    }
    
    init(make: String, model: String, year: String, sortOrder: Int, nickname: String? = nil) {
        self.make = make
        self.model = model
        self.year = year
        self.sortOrder = sortOrder
        self.nickname = nickname
    }
}

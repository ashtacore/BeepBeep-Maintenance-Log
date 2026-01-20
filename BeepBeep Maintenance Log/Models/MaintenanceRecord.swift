import SwiftData
import SwiftUI

@Model
class MaintenanceRecord {
    var title: String
    var details: String
    var mileage: Int
    var date: Date
    
    // Attachments
    @Attribute(.externalStorage) var imageData: Data?
    @Attribute(.externalStorage) var pdfData: Data? // New PDF storage
    
    init(title: String, details: String, mileage: Int, date: Date = Date(), imageData: Data? = nil, pdfData: Data? = nil) {
        self.title = title
        self.details = details
        self.mileage = mileage
        self.date = date
        self.imageData = imageData
        self.pdfData = pdfData
    }
}

import SwiftUI
import SwiftData

struct VehicleDetailView: View {
    @Bindable var vehicle: Vehicle
    @State private var searchText = ""
    @State private var showAddRecord = false
    
    // Filter records based on search text
    var filteredRecords: [MaintenanceRecord] {
        if searchText.isEmpty {
            return vehicle.records.sorted { $0.date > $1.date }
        } else {
            return vehicle.records.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.details.localizedCaseInsensitiveContains(searchText)
            }.sorted { $0.date > $1.date }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredRecords) { record in
                VStack(alignment: .leading, spacing: 8) {
                                    Text(record.title).font(.headline)
                                    Text(record.details).font(.subheadline)
                                    
                                    // Attachments Row
                                    if record.imageData != nil || record.pdfData != nil {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack {
                                                // View Image
                                                if let imageData = record.imageData, let uiImage = UIImage(data: imageData) {
                                                    NavigationLink(destination: Image(uiImage: uiImage).resizable().scaledToFit()) {
                                                        AttachmentIcon(icon: "photo", label: "Photo")
                                                    }
                                                }
                                                
                                                // View PDF
                                                if let pdfData = record.pdfData {
                                                    NavigationLink(destination: PDFKitView(data: pdfData)) {
                                                        AttachmentIcon(icon: "doc.text.fill", label: "PDF")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
            }
        }
        .searchable(text: $searchText, prompt: "Search log...")
        .navigationTitle(vehicle.title)
        .toolbar {
            Button("Add Log") { showAddRecord = true }
        }
        .sheet(isPresented: $showAddRecord) {
            AddMaintenanceRecordView(vehicle: vehicle)
        }
    }
}

// Just a little styling helper for the buttons
struct AttachmentIcon: View {
    var icon: String
    var label: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(label)
        }
        .font(.caption)
        .padding(6)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        // We use the static 'vehicle' from our helper which is already linked to the container
        VehicleDetailView(vehicle: PreviewSampleData.vehicle)
    }
}

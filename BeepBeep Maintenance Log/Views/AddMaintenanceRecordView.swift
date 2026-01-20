import SwiftUI
import SwiftData
import PhotosUI
import UniformTypeIdentifiers

struct AddMaintenanceRecordView: View {
    @Environment(\.dismiss) private var dismiss
    var vehicle: Vehicle
    
    // Form Fields
    @State private var title = ""
    @State private var details = ""
    @State private var mileage: Int?
    @State private var date = Date()
    
    // Image Handling
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    // PDF Handling
    @State private var showFilePicker = false
    @State private var selectedPdfData: Data?
    @State private var pdfName: String = "" // Just for display in UI

    // (Include the 'suggestions' logic from the previous response here)

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    // (Include Title/Mileage/Date fields from previous response)
                    TextField("Title", text: $title)
                    TextField("Mileage", value: $mileage, format: .number)
                }
                
                Section("Attachments") {
                    // 1. Photo Picker
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        HStack {
                            Label("Attach Photo", systemImage: "photo")
                            Spacer()
                            if selectedImageData != nil {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            }
                        }
                    }
                    
                    // 2. PDF Picker Button
                    Button {
                        showFilePicker = true
                    } label: {
                        HStack {
                            Label("Attach PDF Document", systemImage: "doc.text.fill")
                            Spacer()
                            if selectedPdfData != nil {
                                Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            }
                        }
                    }
                    
                    if !pdfName.isEmpty {
                        Text("Selected: \(pdfName)").font(.caption).foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("New Record")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newRecord = MaintenanceRecord(
                            title: title,
                            details: details,
                            mileage: mileage ?? 0,
                            date: date,
                            imageData: selectedImageData,
                            pdfData: selectedPdfData
                        )
                        vehicle.records.append(newRecord)
                        dismiss()
                    }
                }
            }
            // Logic to convert Photo Picker to Data
            .onChange(of: selectedItem) {
                Task {
                    if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
            // Logic to open Files App
            .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.pdf]) { result in
                switch result {
                case .success(let url):
                    // Security: Access the security scoped resource
                    guard url.startAccessingSecurityScopedResource() else { return }
                    defer { url.stopAccessingSecurityScopedResource() }
                    
                    if let data = try? Data(contentsOf: url) {
                        selectedPdfData = data
                        pdfName = url.lastPathComponent
                    }
                case .failure(let error):
                    print("Error selecting file: \(error.localizedDescription)")
                }
            }
        }
    }
}

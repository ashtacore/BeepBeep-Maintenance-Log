import SwiftUI
import SwiftData

struct AddVehicleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.nhtsaService) private var nhtsaService
    
    @Query(filter: #Predicate<Vehicle> { !$0.isArchived }, sort: \Vehicle.sortOrder, order: .reverse) private var vehicles: [Vehicle]
    
    @State private var selectedMake: NHTSAMake?
    @State private var selectedModel: NHTSAModel?
    @State private var selectedYear: Int?
    
    @State private var makes: [NHTSAMake] = []
    @State private var models: [NHTSAModel] = []
    @State private var isLoadingMakes = false
    @State private var isLoadingModels = false
    @State private var errorMessage: String?
    
    @State private var showMakePicker = false
    @State private var showModelPicker = false
    
    @State private var vinText = ""
    @State private var isDecodingVIN = false
    @State private var vinErrorMessage: String?
    
    @State private var nickname = ""
    
    // Generate years from current year down to 1900
    private var availableYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return Array((1900...currentYear + 1).reversed())
    }
    
    // Check if a vehicle with the same year, make, and model already exists
    private var duplicateExists: Bool {
        guard let make = selectedMake,
              let model = selectedModel,
              let year = selectedYear else {
            return false
        }
        return vehicles.contains { vehicle in
            vehicle.make.lowercased() == make.makeName.lowercased() &&
            vehicle.model.lowercased() == model.modelName.lowercased() &&
            vehicle.year == String(year)
        }
    }
    
    // Nickname is required when duplicate exists
    private var isNicknameRequired: Bool {
        duplicateExists
    }
    
    // Form is valid when all required fields are filled
    private var isFormValid: Bool {
        guard selectedMake != nil, selectedModel != nil, selectedYear != nil else {
            return false
        }
        if isNicknameRequired {
            return !nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return true
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // VIN Decode Section
                Section {
                    HStack {
                        TextField("Enter VIN", text: $vinText)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                        
                        if isDecodingVIN {
                            ProgressView()
                        } else {
                            Button("Decode") {
                                Task {
                                    await decodeVIN()
                                }
                            }
                            .disabled(vinText.trimmingCharacters(in: .whitespacesAndNewlines).count != 17)
                        }
                    }
                    
                    if let vinErrorMessage {
                        Text(vinErrorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                } header: {
                    Text("VIN Lookup (Optional)")
                } footer: {
                    Text("Enter your 17-character VIN to auto-fill vehicle details")
                }
                
                Section("Vehicle Details") {
                    // Year Picker
                Picker("Year", selection: $selectedYear) {
                    Text("Select Year").tag(nil as Int?)
                    ForEach(availableYears, id: \.self) { year in
                        Text(String(year)).tag(year as Int?)
                    }
                }
                
                // Make Picker Button
                if isLoadingMakes {
                    HStack {
                        Text("Make")
                        Spacer()
                        ProgressView()
                    }
                } else {
                    Button {
                        showMakePicker = true
                    } label: {
                        HStack {
                            Text("Make")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(selectedMake?.makeName ?? "Select Make")
                                .foregroundStyle(selectedMake == nil ? .secondary : .primary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(makes.isEmpty)
                }
                
                // Model Picker Button
                if isLoadingModels {
                    HStack {
                        Text("Model")
                        Spacer()
                        ProgressView()
                    }
                } else {
                    Button {
                        showModelPicker = true
                    } label: {
                        HStack {
                            Text("Model")
                                .foregroundStyle(.primary)
                            Spacer()
                            Text(selectedModel?.modelName ?? "Select Model")
                                .foregroundStyle(selectedModel == nil ? .secondary : .primary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(models.isEmpty || selectedMake == nil || selectedYear == nil)
                }
                
                if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.caption)
                    }
                }
                
                // Nickname Section
                Section {
                    TextField("Nickname", text: $nickname)
                } header: {
                    HStack {
                        Text("Nickname")
                        if isNicknameRequired {
                            Text("(Required)")
                                .foregroundStyle(.red)
                        } else {
                            Text("(Optional)")
                        }
                    }
                } footer: {
                    if isNicknameRequired {
                        Text("A vehicle with the same year, make, and model already exists. Please add a nickname to distinguish them.")
                    } else {
                        Text("Add a nickname to help identify this vehicle")
                    }
                }
            }
            .navigationTitle("Add Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveVehicle()
                    }
                    .disabled(!isFormValid)
                }
            }
            .task {
                await loadMakes()
            }
            .onChange(of: selectedYear) { _, _ in
                // Reset model when year changes
                selectedModel = nil
                models = []
                Task {
                    await loadModelsIfNeeded()
                }
            }
            .onChange(of: selectedMake) { _, _ in
                // Reset model when make changes
                selectedModel = nil
                models = []
                Task {
                    await loadModelsIfNeeded()
                }
            }
            .sheet(isPresented: $showMakePicker) {
                SearchablePickerView(
                    title: "Select Make",
                    items: makes,
                    selection: $selectedMake,
                    itemTitle: { $0.makeName }
                )
            }
            .sheet(isPresented: $showModelPicker) {
                SearchablePickerView(
                    title: "Select Model",
                    items: models,
                    selection: $selectedModel,
                    itemTitle: { $0.modelName }
                )
            }
        }
    }
    
    private func loadMakes() async {
        isLoadingMakes = true
        errorMessage = nil
        
        do {
            let fetchedMakes = try await nhtsaService.getAllMakes()
            // Sort makes alphabetically
            makes = fetchedMakes.sorted { $0.makeName.localizedCaseInsensitiveCompare($1.makeName) == .orderedAscending }
        } catch {
            errorMessage = "Failed to load makes: \(error.localizedDescription)"
        }
        
        isLoadingMakes = false
    }
    
    private func loadModelsIfNeeded() async {
        guard let make = selectedMake, let year = selectedYear else {
            return
        }
        
        isLoadingModels = true
        errorMessage = nil
        
        do {
            let fetchedModels = try await nhtsaService.getModelsForMakeYear(make: make.makeName, year: year)
            // Remove duplicates by model name and sort alphabetically
            var seenNames = Set<String>()
            models = fetchedModels
                .filter { seenNames.insert($0.modelName.lowercased()).inserted }
                .sorted { $0.modelName.localizedCaseInsensitiveCompare($1.modelName) == .orderedAscending }
        } catch {
            errorMessage = "Failed to load models: \(error.localizedDescription)"
        }
        
        isLoadingModels = false
    }
    
    private func saveVehicle() {
        guard let make = selectedMake,
              let model = selectedModel,
              let year = selectedYear else {
            return
        }
        
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newCar = Vehicle(
            make: make.makeName,
            model: model.modelName,
            year: String(year),
            sortOrder: vehicles.first?.sortOrder.advanced(by: 1) ?? 0,
            nickname: trimmedNickname.isEmpty ? nil : trimmedNickname
        )
        modelContext.insert(newCar)
        dismiss()
    }
    
    private func decodeVIN() async {
        isDecodingVIN = true
        vinErrorMessage = nil
        
        do {
            let result = try await nhtsaService.decodeVIN(vinText)
            
            // Set the year
            if let year = Int(result.modelYear) {
                selectedYear = year
            }
            
            // Find and select the matching make
            if let matchingMake = makes.first(where: { $0.makeName.localizedCaseInsensitiveCompare(result.make) == .orderedSame }) {
                selectedMake = matchingMake
                
                // Wait for models to load, then select the matching model
                try await Task.sleep(for: .milliseconds(500))
                await loadModelsIfNeeded()
                
                if let matchingModel = models.first(where: { $0.modelName.localizedCaseInsensitiveCompare(result.model) == .orderedSame }) {
                    selectedModel = matchingModel
                }
            }
        } catch let error as NHTSAError {
            switch error {
            case .invalidVIN(let message):
                vinErrorMessage = message
            default:
                vinErrorMessage = "Failed to decode VIN. Please try again."
            }
        } catch {
            vinErrorMessage = "Failed to decode VIN. Please try again."
        }
        
        isDecodingVIN = false
    }
}

// MARK: - Searchable Picker View

struct SearchablePickerView<Item: Hashable>: View {
    let title: String
    let items: [Item]
    @Binding var selection: Item?
    let itemTitle: (Item) -> String
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    private var filteredItems: [Item] {
        if searchText.isEmpty {
            return items
        }
        return items.filter { itemTitle($0).localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            List(filteredItems, id: \.self) { item in
                Button {
                    selection = item
                    dismiss()
                } label: {
                    HStack {
                        Text(itemTitle(item))
                            .foregroundStyle(.primary)
                        Spacer()
                        if selection == item {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

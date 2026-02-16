import Foundation

struct NHTSAMake: Codable, Hashable {
    let makeId: Int
    let makeName: String
    
    enum CodingKeys: String, CodingKey {
        case makeId = "Make_ID"
        case makeName = "Make_Name"
    }
}

struct NHTSAModel: Codable, Hashable {
    let makeId: Int
    let makeName: String
    let modelId: Int
    let modelName: String
    
    enum CodingKeys: String, CodingKey {
        case makeId = "Make_ID"
        case makeName = "Make_Name"
        case modelId = "Model_ID"
        case modelName = "Model_Name"
    }
}

struct NHTSAMakesResponse: Codable {
    let count: Int
    let message: String
    let results: [NHTSAMake]
    
    enum CodingKeys: String, CodingKey {
        case count = "Count"
        case message = "Message"
        case results = "Results"
    }
}

struct NHTSAModelsResponse: Codable {
    let count: Int
    let message: String
    let results: [NHTSAModel]
    
    enum CodingKeys: String, CodingKey {
        case count = "Count"
        case message = "Message"
        case results = "Results"
    }
}

struct NHTSAVINResult: Codable {
    let make: String
    let model: String
    let modelYear: String
    let errorCode: String
    let errorText: String
    
    enum CodingKeys: String, CodingKey {
        case make = "Make"
        case model = "Model"
        case modelYear = "ModelYear"
        case errorCode = "ErrorCode"
        case errorText = "ErrorText"
    }
    
    /// Returns true if the VIN decode was successful (error code 0 means no error)
    var isValid: Bool {
        // Error codes can be comma-separated; "0" means success
        let codes = errorCode.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        return codes.contains("0") && !make.isEmpty && !model.isEmpty && !modelYear.isEmpty
    }
}

struct NHTSAVINResponse: Codable {
    let count: Int
    let message: String
    let results: [NHTSAVINResult]
    
    enum CodingKeys: String, CodingKey {
        case count = "Count"
        case message = "Message"
        case results = "Results"
    }
}

enum NHTSAError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noData
    case invalidResponse
    case invalidVIN(String)
}

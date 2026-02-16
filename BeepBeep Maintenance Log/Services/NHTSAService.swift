import Foundation

class NHTSAService: NHTSAServiceProtocol {
    // Singleton instance
    static let shared = NHTSAService()
    
    private let baseURL = "https://vpic.nhtsa.dot.gov/api/vehicles"
    private let session: URLSession
    
    // Cache storage
    private var makesCache: [NHTSAMake]?
    private var modelsCache: [String: [NHTSAModel]] = [:]
    
    // Actor for thread-safe cache access
    private actor CacheActor {
        var makes: [NHTSAMake]?
        var models: [String: [NHTSAModel]] = [:]
        
        func getMakes() -> [NHTSAMake]? {
            return makes
        }
        
        func setMakes(_ makes: [NHTSAMake]) {
            self.makes = makes
        }
        
        func getModels(for key: String) -> [NHTSAModel]? {
            return models[key]
        }
        
        func setModels(_ models: [NHTSAModel], for key: String) {
            self.models[key] = models
        }
        
        func clearAll() {
            makes = nil
            models = [:]
        }
    }
    
    private let cache = CacheActor()
    
    /// Initialize with a custom URLSession (useful for testing)
    /// For production use, prefer using the shared singleton
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    /// Fetches all vehicle makes from the NHTSA database
    /// Results are cached after the first successful fetch
    /// - Returns: An array of NHTSAMake objects
    /// - Throws: NHTSAError if the request fails
    func getAllMakes() async throws -> [NHTSAMake] {
        // Check cache first
        if let cachedMakes = await cache.getMakes() {
            return cachedMakes
        }
        
        let urlString = "\(baseURL)/GetAllMakes?format=json"
        
        guard let url = URL(string: urlString) else {
            throw NHTSAError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NHTSAError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let makesResponse = try decoder.decode(NHTSAMakesResponse.self, from: data)
            
            // Cache the results
            await cache.setMakes(makesResponse.results)
            
            return makesResponse.results
            
        } catch let error as DecodingError {
            throw NHTSAError.decodingError(error)
        } catch let error as NHTSAError {
            throw error
        } catch {
            throw NHTSAError.networkError(error)
        }
    }
    
    /// Fetches all models for a specific make and year
    /// Results are cached by make-year combination
    /// - Parameters:
    ///   - make: The vehicle make (e.g., "Honda", "Toyota")
    ///   - year: The model year (e.g., 2020)
    /// - Returns: An array of NHTSAModel objects
    /// - Throws: NHTSAError if the request fails
    func getModelsForMakeYear(make: String, year: Int) async throws -> [NHTSAModel] {
        // Create cache key
        let cacheKey = "\(make.lowercased())-\(year)"
        
        // Check cache first
        if let cachedModels = await cache.getModels(for: cacheKey) {
            return cachedModels
        }
        
        // URL encode the make name to handle spaces and special characters
        guard let encodedMake = make.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            throw NHTSAError.invalidURL
        }
        
        let urlString = "\(baseURL)/GetModelsForMakeYear/make/\(encodedMake)/modelyear/\(year)?format=json"
        
        guard let url = URL(string: urlString) else {
            throw NHTSAError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NHTSAError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let modelsResponse = try decoder.decode(NHTSAModelsResponse.self, from: data)
            
            // Cache the results
            await cache.setModels(modelsResponse.results, for: cacheKey)
            
            return modelsResponse.results
            
        } catch let error as DecodingError {
            throw NHTSAError.decodingError(error)
        } catch let error as NHTSAError {
            throw error
        } catch {
            throw NHTSAError.networkError(error)
        }
    }
    
    /// Clears all cached data
    /// Call this if you need to force a refresh of the data
    func clearCache() {
        Task {
            await cache.clearAll()
        }
    }
    
    /// Decodes a VIN using the NHTSA DecodeVinValuesExtended endpoint
    /// - Parameter vin: The Vehicle Identification Number to decode
    /// - Returns: An NHTSAVINResult containing make, model, and year
    /// - Throws: NHTSAError if the request fails or VIN is invalid
    func decodeVIN(_ vin: String) async throws -> NHTSAVINResult {
        let cleanVIN = vin.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        guard cleanVIN.count == 17 else {
            throw NHTSAError.invalidVIN("VIN must be exactly 17 characters")
        }
        
        let urlString = "\(baseURL)/DecodeVinValuesExtended/\(cleanVIN)?format=json"
        
        guard let url = URL(string: urlString) else {
            throw NHTSAError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NHTSAError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            let vinResponse = try decoder.decode(NHTSAVINResponse.self, from: data)
            
            guard let result = vinResponse.results.first else {
                throw NHTSAError.noData
            }
            
            guard result.isValid else {
                throw NHTSAError.invalidVIN(result.errorText)
            }
            
            return result
            
        } catch let error as DecodingError {
            throw NHTSAError.decodingError(error)
        } catch let error as NHTSAError {
            throw error
        } catch {
            throw NHTSAError.networkError(error)
        }
    }
}

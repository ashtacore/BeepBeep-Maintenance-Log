import SwiftUI

protocol NHTSAServiceProtocol {
    func getAllMakes() async throws -> [NHTSAMake]
    func getModelsForMakeYear(make: String, year: Int) async throws -> [NHTSAModel]
    func decodeVIN(_ vin: String) async throws -> NHTSAVINResult
    func clearCache()
}

private struct NHTSAServiceKey: EnvironmentKey {
    static let defaultValue: NHTSAServiceProtocol = NHTSAService.shared
}

extension EnvironmentValues {
    var nhtsaService: NHTSAServiceProtocol {
        get { self[NHTSAServiceKey.self] }
        set { self[NHTSAServiceKey.self] = newValue }
    }
}

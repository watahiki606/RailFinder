import Foundation
import Turf


class GeoJSONCache {
    static let shared = GeoJSONCache()
    private(set) var cachedGeoJSON: FeatureCollection?
    
    private init() {}
    
    func clearCache() {
        cachedGeoJSON = nil
    }
    
    func loadGeoJSON(from fileName: String) {
        guard cachedGeoJSON == nil else {
            return
        }
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "geojson") else {
            logger.info("File not found.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let geoJson = try JSONDecoder().decode(FeatureCollection.self, from: data)
            cachedGeoJSON = geoJson
            logger.info("loaded from geoJSON")
        } catch {
            logger.info("Error loading geoJSON: \(error)")
        }
    }
}

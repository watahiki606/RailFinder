import Foundation
import Turf


class GeoJSONCache {
    static let shared = GeoJSONCache()
    private(set) var cachedGeoJSON: FeatureCollection?
    
    private init() {
        self.loadGeoJSON()
    }
    
    func clearCache() {
        cachedGeoJSON = nil
    }
    
    func loadGeoJSON() {
           guard let url = Bundle.main.url(forResource: "N02-20_Station", withExtension: "geojson") else {
               logger.info("N02-20_Station.geojson not found.")
               return
           }

           do {
               let data = try Data(contentsOf: url)
               let geoJson = try JSONDecoder().decode(FeatureCollection.self, from: data)
               cachedGeoJSON = geoJson
           } catch {
               logger.info("Error loading GeoJSON: \(error)")
           }
       }
}

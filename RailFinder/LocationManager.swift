import Foundation
import CoreLocation
import Turf

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    @Published var lastLocation: CLLocation? {
        didSet {
            logger.info("\(String(describing: self.lastLocation))")
            findNearestStation()
        }
    }
    @Published var nearestStation: String = "" {
        didSet {
            logger.info("\(String(describing: self.nearestStation))")
        }
    }
    @Published var isLoading: Bool = false
    var isUpdating: Bool = false
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    func startUpdatingLocation() {
        isUpdating = true
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isUpdating = true
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard  isUpdating else { return }
        lastLocation = locations.last
        locationManager.stopUpdatingLocation()
        isUpdating = false
        
    }
    
    func findNearestStation() {
        logger.info("func find ")
        isLoading = true
        guard let location = lastLocation else {
            isLoading = false
            return
        }
        guard let url = Bundle.main.url(forResource: "N02-20_Station", withExtension: "geojson") else {
            logger.error("N02-20_Station.geojsonが見つかりません。")
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let geoJson = try JSONDecoder().decode(FeatureCollection.self, from: data)
            
            let nearestFeature = searchNearestFeature(from: geoJson.features, at: location)
            
            if let nearestFeature = nearestFeature {
                let stationName = nearestFeature.stationName ?? "不明な駅"
                DispatchQueue.main.async {
                    self.nearestStation = "最寄り駅: \(stationName)"
                }
                isLoading = false
            } else {
                DispatchQueue.main.async {
                    self.nearestStation = "最寄り駅が見つかりませんでした。"
                }
                isLoading = false
            }
        } catch {
            logger.error("エラー: \(error)")
            DispatchQueue.main.async {
                self.nearestStation = "エラーが発生しました。"
            }
            isLoading = false
        }
    }
    
    func searchNearestFeature(from features: [Feature], at location: CLLocation) -> Feature? {
        let currentLocation = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        var minDistance = Double.greatestFiniteMagnitude
        var nearestFeature: Feature?
        
        for feature in features {
            switch feature.geometry {
            case .multiLineString(let mulitiLineString):
                let multiLineStringCoordinates = mulitiLineString.coordinates
                for lineString in multiLineStringCoordinates {
                    for coordinate in lineString {
                        let coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        let stationLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        let distance = stationLocation.distance(from: currentLocation)
                        if distance < minDistance {
                            minDistance = distance
                            nearestFeature = feature
                        }
                    }
                }
            default:
                continue
            }
        }
        
        return nearestFeature
    }
    
}



import Foundation
import CoreLocation
import Turf
import WatchConnectivity

struct AlertEntity {
    let title: String
    let message: String
    let actionText: String
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    var actionText: String {
        get {
            return "Go to settings"
        }
    }
    
    @Published var alert: AlertEntity?
    @Published var requireAuth = false
    @Published var lastLocation: CLLocation? {
        didSet {
            findNearestStation()
        }
    }
    @Published var nearestStation: String = "" {
        didSet {
            WatchCommunication.shared.sendNearestStation(nearestStation)
        }
    }
    
    var isUpdating: Bool = false
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
    }
    
    
    func startUpdatingLocation() {
        logger.info("func start updating location")
        
        logger.info("\(String(describing:self.locationManager.authorizationStatus))")
        switch self.locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isUpdating = true
            nearestStation = ""
            locationManager.startUpdatingLocation()
        case .notDetermined:
            logger.info("notDetermined")
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            logger.info("denied")
            alert = AlertEntity(title: "Please allow Settings", message: "Location information is not allowed. Please allow Settings - Privacy to retrieve the location of your app.", actionText: actionText)
            DispatchQueue.main.async() {
                self.requireAuth = true
            }
        case .restricted:
            logger.info("restricted")
            alert = AlertEntity(title: "Please allow Settings", message: "Location information is not allowed by the constraints specified on the device.", actionText: actionText)
            DispatchQueue.main.async() {
                self.requireAuth = true
            }
            
        @unknown default:
            alert = AlertEntity(title: "Please allow Settings", message: "An unknown error has occurred.", actionText: actionText)
            DispatchQueue.main.async() {
                self.requireAuth = true
            }
        }
    }
    
    func stopUpdatingLocation() {
        logger.info("func stop updating location")
        locationManager.stopUpdatingLocation()
    }
    
    private func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) throws {
        logger.info("changed Auth")
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            self.startUpdatingLocation()
        case .notDetermined:
            logger.info("notDetermined")
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            logger.info("denied")
            alert = AlertEntity(title: "Please allow Settings", message: "Location information is not allowed. Please allow Settings - Privacy to retrieve the location of your app.", actionText: "Go to settings")
            DispatchQueue.main.async() {
                self.requireAuth = true
            }
        case .restricted:
            logger.info("restricted")
            alert = AlertEntity(title: "Please allow Settings", message: "Location information is not allowed by the constraints specified on the device.", actionText: "Go to settings")
            DispatchQueue.main.async() {
                self.requireAuth = true
            }
            
        @unknown default:
            alert = AlertEntity(title: "Please allow Settings", message: "An unknown error has occurred.", actionText: "Go to settings")
            DispatchQueue.main.async() {
                self.requireAuth = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        logger.info("func location manager")
        guard  isUpdating else { return }
        lastLocation = locations.last
        locationManager.stopUpdatingLocation()
        isUpdating = false
    }
    
    func findNearestStation() {
        logger.info("func find nearest station")
        guard let location = lastLocation else {
            return
        }
        
        guard let cachedGeoJSON = GeoJSONCache.shared.cachedGeoJSON else {
            logger.error("GeoJSONCache is empty.")
            return
        }
        
        let nearestFeature = searchNearestFeature(from: cachedGeoJSON.features, at: location)
        
        if let nearestFeature = nearestFeature {
            let stationName = nearestFeature.stationName ?? "Unknown station"
            DispatchQueue.main.async() {
                self.nearestStation = "\(stationName)"
            }
        } else {
            DispatchQueue.main.async {
                self.nearestStation = "Nearest station not found."
            }
        }
    }
    
    
    
    func searchNearestFeature(from features: [Feature], at location: CLLocation) -> Feature? {
        logger.info("func search nearest feature")
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



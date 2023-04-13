//
//  StationInfoViewModel.swift
//  RailFinder
//
//  Created by 綿引慎也 on 2023/04/13.
//

import Foundation
import Combine
import CoreLocation


let stationInfoUrl = "https://express.heartrails.com/api/json?method=getStations&x=135.0&y=35.0"

struct StationInfo: Codable {
    let response: StationResponse
}

struct StationResponse: Codable {
    let station: [Station]
}

struct Station: Codable {
    let name: String
    let prefecture: String
    let line: String
    let x: Double
    let y: Double
    let postal: String
    let distance: String
    let prev: String?
    let next: String?
}

class StationInfoViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var stationInfos = [Station]()
    private var cancellables = Set<AnyCancellable>()
    private let locationManager = CLLocationManager()
    override init() {
            super.init()
            
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    
    func fetchStationInfo() {
        guard let url = URL(string: stationInfoUrl) else { return }
        guard let location = locationManager.location else { return }
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [
            URLQueryItem(name: "method", value: "getStations"),
            URLQueryItem(name: "x", value: "\(location.coordinate.longitude)"),
            URLQueryItem(name: "y", value: "\(location.coordinate.latitude)")
        ]
        
        let request = URLRequest(url: urlComponents.url!)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: StationInfo.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] stationInfo in
                self?.stationInfos = stationInfo.response.station
            })
            .store(in: &cancellables)
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        fetchStationInfo()
        locationManager.stopUpdatingLocation()
    }
}

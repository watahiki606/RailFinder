import SwiftUI
import os

let logger = Logger(subsystem: "com.railfinder", category: "app")


@main
struct Railfinder_Watch_AppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some Scene {
        WindowGroup {
            NearestStationView()
        }
        .onChange(of: scenePhase) { scene in
            switch scene {
            case .active:
                logger.info("scenePhase: active")
                locationManager.startUpdatingLocation()
            case .inactive:
                logger.info("scenePhase: inactive")
            case .background:
                logger.info("scenePhase: background")
            @unknown default: break
            }
        }
    }
}

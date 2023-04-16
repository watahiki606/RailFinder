import SwiftUI
import os

let logger = Logger(subsystem: "com.railfinder", category: "app")

@main
struct RailFinderApp: App {
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            NearestStationView()
        }
        .onChange(of: scenePhase) { scene in
            switch scene {
            case .active:
                logger.info("scenePhase: active")
            case .inactive:
                logger.info("scenePhase: inactive")
            case .background:
                logger.info("scenePhase: background")
            @unknown default: break
            }
        }
    }
}

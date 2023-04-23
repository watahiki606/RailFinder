import SwiftUI
import os
import WatchConnectivity


let logger = Logger(subsystem: "com.railfinder", category: "app")


@main
struct Railfinder_Watch_AppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var watchCommunication = WatchCommunication()

    var body: some Scene {
        WindowGroup {
            ContentView(watchCommunication: watchCommunication)
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

import SwiftUI
import os

let logger = Logger(subsystem: "com.railfinder", category: "app")

@main
struct RailFinderApp: App {
    init() {
          checkAppVersionAndUpdateCacheIfNeeded()
      }
    
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var locationManager = LocationManager.shared
    @StateObject private var watchCommunication = WatchCommunication()

    
    var body: some Scene {
        WindowGroup {
            NearestStationView()
                .environmentObject(watchCommunication)
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
    
    func checkAppVersionAndUpdateCacheIfNeeded() {
          let currentAppVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
          let savedAppVersion = UserDefaults.standard.string(forKey: "appVersion")

          if savedAppVersion != currentAppVersion {
              // アプリがアップデートされた場合、キャッシュをクリア
              GeoJSONCache.shared.clearCache()

              // 現在のバージョン情報を UserDefaults に保存
              UserDefaults.standard.setValue(currentAppVersion, forKey: "appVersion")
          }
      }
}

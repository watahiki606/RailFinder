import SwiftUI
import CoreLocation
import WatchConnectivity


struct NearestStationView: View {
    @StateObject private var locationManager = LocationManager.shared
    
    
    
    var body: some View {
        VStack {
            Spacer()
            if !locationManager.nearestStation.isEmpty {
                Text(locationManager.nearestStation)
                    .textSelection(.enabled)
                    .padding()
            } else if !locationManager.requireAuth {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            Button(action: {
                locationManager.startUpdatingLocation()
            }, label: {
                HStack {
                    Image(systemName: "train.side.front.car")
                    Text("Search")
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .font(.headline)
            })
            .padding()
            .buttonStyle(BorderlessButtonStyle())
            .foregroundColor(Color.white)
            .background(Color.blue)
            .cornerRadius(8)
            .padding()
            Spacer()
        }
        .alert(
            locationManager.alert?.title ?? "",
            isPresented: $locationManager.requireAuth,
            presenting: locationManager.alert
        ) { entity in
            Button(entity.actionText) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        } message: { entity in
            Text(entity.message)
        }
    }
}


class WatchCommunication: NSObject, WCSessionDelegate, ObservableObject {
    private let  locationManager = LocationManager.shared
    static let shared = WatchCommunication()
    
    func sendNearestStation(_ station: String) {
        if WCSession.default.activationState == .activated {
            let message = ["nearestStation": station]
            WCSession.default.sendMessage(message, replyHandler: { response in
                logger.info("iPhone received response")
            }, errorHandler: { error in
                logger.info("Error sending message: \(error.localizedDescription)")
            })
        } else {
            logger.info("WCSession is not activated.")
        }
    }
    
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    override init() {
        super.init()
        if WCSession.default.activationState != .activated {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            logger.info("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            logger.info("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let action = message["action"] as? String, action == "startUpdatingLocation" {
            LocationManager.shared.startUpdatingLocation()
            replyHandler(["execute": "success"])
        }
    }
}



struct NearestStationView_Previews: PreviewProvider {
    
    static var previews: some View {
        let shared = LocationManager.shared
        shared.nearestStation = "京都"
        return Group {
            NearestStationView()
        }
    }
}

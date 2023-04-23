import SwiftUI
import WatchConnectivity


struct ContentView: View {
    @ObservedObject var watchCommunication = WatchCommunication()
    
    
    var body: some View {
        VStack {
            Spacer()
            if !watchCommunication.nearestStation.isEmpty {
                Text(watchCommunication.nearestStation)
                    .padding()
            }
            if watchCommunication.isSearching {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            Button(action: {
                watchCommunication.nearestStation = ""
                watchCommunication.isSearching = true
                watchCommunication.sendMessageToiPhone()
            }, label: {
                HStack {
                    Image(systemName: "train.side.front.car")
                    Text("Search")
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .font(.headline)
            })
            .disabled(watchCommunication.isSearching)
            .padding()
            .buttonStyle(BorderlessButtonStyle())
            .foregroundColor(Color.white)
            .background(Color.blue)
            .cornerRadius(8)
            .padding()
            
            Spacer()
        }
    }
}


class WatchCommunication: NSObject, WCSessionDelegate, ObservableObject {
    @Published var nearestStation: String = "" {
        didSet {
            if !nearestStation.isEmpty {
                DispatchQueue.main.async {
                    self.isSearching = false
                }
            }
        }
    }
    
    @Published var isSearching = false
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            logger.info("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            logger.info("WCSession activated with state: \(activationState.rawValue)")
        }
        if activationState != .activated {
            logger.info("WCSession activation failed: \(String(describing: error?.localizedDescription))")
        }
    }
    
    
    override init() {
        super.init()
        if WCSession.default.activationState != .activated {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func sendMessageToiPhone() {
        logger.info("watch send message to iPhone")
        if WCSession.default.isReachable {
            let message = ["action": "startUpdatingLocation"]
            WCSession.default.sendMessage(message, replyHandler: { response in
                logger.info("watch received \(response)")
            }, errorHandler: { error in
                logger.info("Error sending message: \(error.localizedDescription)")
            })
        } else {
            logger.info("iPhone is not reachable.")
        }
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let nearestStation = message["nearestStation"] as? String {
            logger.info("watch received nearestStation: \(nearestStation)")
            DispatchQueue.main.async {
                self.nearestStation = nearestStation
            }
            replyHandler(["status": "success"])
        } else {
            DispatchQueue.main.async {
                self.nearestStation = "Error: Data not received correctly."
            }
            replyHandler(["status": "error"])
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        
    }
}


struct ContentView_Previews: PreviewProvider {
    static var watchCommunication = WatchCommunication()
    static var previews: some View {
        ContentView(watchCommunication: watchCommunication)
    }
}

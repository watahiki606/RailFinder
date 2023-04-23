//
//  ContentView.swift
//  Railfinder Watch App
//
//  Created by 綿引慎也 on 2023/04/22.
//

import SwiftUI
import WatchConnectivity


struct ContentView: View {
    @ObservedObject var watchCommunication = WatchCommunication()

    var body: some View {
        VStack {
            Button(action: {
                watchCommunication.sendMessageToiPhone()
            }) {
                Text("search")
            }

            Text(watchCommunication.nearestStation)
        }
    }
}


class WatchCommunication: NSObject, WCSessionDelegate, ObservableObject {
    @Published var nearestStation: String = ""

    
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
        if WCSession.default.isReachable {
            nearestStation = "Loading..."
            let message = ["action": "startUpdatingLocation"]
            WCSession.default.sendMessage(message, replyHandler: { response in
                DispatchQueue.main.async {
                    if let result = response["nearestStation"] as? String {
                        self.nearestStation = result
                    }
                }
            }, errorHandler: { error in
                logger.info("Error sending message: \(error.localizedDescription)")
            })
        } else {
            logger.info("iPhone is not reachable.")
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        if let nearestStation = message["nearestStation"] as? String {
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
    
    // WCSessionDelegate methods
    // ...
    func sessionReachabilityDidChange(_ session: WCSession) {
        // ここにコードを追加することもできますが、このデリゲートメソッドは空である必要はありません。
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

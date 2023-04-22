import SwiftUI
import CoreLocation
struct NearestStationView: View {
    @StateObject private var locationManager = LocationManager.shared
    
    
    
    var body: some View {
        VStack {
            Spacer()
            if !locationManager.nearestStation.isEmpty {
                Text(locationManager.nearestStation)
#if os(iOS)
                    .textSelection(.enabled)
#else
#endif
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
#if os(iOS)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
#else
#endif
            }
        } message: { entity in
            Text(entity.message)
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

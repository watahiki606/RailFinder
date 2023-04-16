import SwiftUI
import CoreLocation

struct NearestStationView: View {
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some View {
        ZStack {
            if (!locationManager.isLoading) {
                VStack {
                    Text(locationManager.nearestStation)
                        .padding()
                    
                    HStack{
                        Image(systemName: "train.side.front.car")
                        Button("最寄り駅を検索")  {
                            locationManager.startUpdatingLocation()
                        }
                    }
                }
                
            } else {
                ProgressView("searching...")
                    .progressViewStyle(CircularProgressViewStyle())
                
            }
        }
        
        .onAppear {
            locationManager.requestPermission()
        }
    }
}


struct FullScreenButtonView: View {
    let action: () -> Void
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    action()
                }
        }
    }
}


struct NearestStationView_Previews: PreviewProvider {
    static var previews: some View {
        NearestStationView()
    }
}

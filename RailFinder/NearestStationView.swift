import SwiftUI
import CoreLocation
struct NearestStationView: View {
    @StateObject private var locationManager = LocationManager.shared
    
    var body: some View {
        ZStack {
            if (locationManager.isLoading) {
                ProgressView("searching...")
                    .progressViewStyle(CircularProgressViewStyle())
                
            } else {
                VStack {
                    Spacer()
                    Text(locationManager.nearestStation)
                        .padding()
                    Button(action: {
                        locationManager.startUpdatingLocation()
                    }, label: {
                        HStack {
                            Image(systemName: "train.side.front.car")
                            Text("検索")
                        }
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .font(.headline)
                        .cornerRadius(10)
                    })
                    .padding()
                    
                    Spacer()
                }
                .onAppear {
                    locationManager.requestPermission()
                }
            }
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

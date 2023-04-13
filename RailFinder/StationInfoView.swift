//
//  StationInfoView.swift
//  RailFinder
//
//  Created by 綿引慎也 on 2023/04/13.
//

import Foundation
import SwiftUI

struct StationInfoView: View {
    @ObservedObject var viewModel = StationInfoViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.stationInfos, id: \.name) { stationInfo in
                VStack(alignment: .leading) {
                    Text(stationInfo.name)
                        .font(.headline)
                    Text("\(stationInfo.prefecture) - \(stationInfo.line)")
                        .font(.subheadline)
                }
            }
            .navigationBarTitle("Station Info")
            .onAppear {
                viewModel.fetchStationInfo()
            }
        }
    }
}

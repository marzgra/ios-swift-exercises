//
//  MapView.swift
//  Task4
//
//  Created by Grażyna Marzec on 13/08/2023.
//

import Foundation
import MapKit
import SwiftUI

struct MapView: View {
    var location: String = ""
    
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.510357, longitude: -0.116773),
        span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
    )
    
    var body: some View {
        Map(coordinateRegion: $region)
    }
    
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

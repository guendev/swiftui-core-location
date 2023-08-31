//
//  ContentView.swift
//  core-location
//
//  Created by Guen on 29/08/2023.
//

import SwiftUI
import CoreLocation
import CoreLocationUI
import MapKit

struct ContentView: View {
    
    @StateObject var locationManager: LocationManager = .init()
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
                    
            Map(coordinateRegion: $locationManager.region, showsUserLocation: true, annotationItems: locationManager.coffeShops) { shop in
                
                MapMarker(coordinate: shop.mapItem.placemark.coordinate, tint: .purple)
                
            }
            
            LocationButton(.currentLocation) {
                locationManager.manager.requestLocation()
            }
            .frame(width: 250, height: 50)
            .symbolVariant(.fill)
            .foregroundColor(.white)
            .tint(.purple)
            .clipShape(Capsule())
            .padding()
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Location manager
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var manager = CLLocationManager()
    
    // region
    @Published var region: MKCoordinateRegion = .init()
    
    // coffe shops
    @Published var coffeShops: [Shop] = []
    
    override init() {
        super.init()
        manager.delegate = self
    }
 
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else {
            return
        }
        
        region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        async {
            await fetchCoffeShop()
        }
    }
    
    func fetchCoffeShop() async {
        do {
            
            let request = MKLocalSearch.Request()
            request.region = region
            request.naturalLanguageQuery = "Coffe shop"
            
            let query = MKLocalSearch(request: request)
            
            let response = try await query.start()
            
            self.coffeShops = response.mapItems.compactMap { item in
                return Shop(mapItem: item)
            }
            
        } catch {
            print(error)
        }
    }
}

// Sample model
struct Shop: Identifiable {
    var id = UUID().uuidString
    var mapItem: MKMapItem
}

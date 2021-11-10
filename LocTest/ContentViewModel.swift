//
//  ContentViewModel.swift
//  LocTest
//
//  Created by Arjit Bose on 10/29/21.
//

import Foundation
import MapKit

final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    var locationManager: CLLocationManager? //Question mark signifies optional variable because it needs permission
    
    func checkIfLocationServicesIsEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            //checkLocationAuthorization() is called automatically via Apple's locationManagerDidChangeAuthorization method (see bottom)
            locationManager!.delegate = self
        }
        else{
            print("Show alert to let user know")
        }
    }
    
    private func checkLocationAuthorization(){
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            print("Status not determined")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location is restricted likely due to parental controls")
        case .denied:
            print("You have denied this app location permission. Go into settings to change it")
        case .authorizedAlways, .authorizedWhenInUse:
            print("Location authorized")
        @unknown default:
            break
        }

    }
    //we need to constantly check if we have permission, because the user can disable location services outside the app
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            checkLocationAuthorization()
    }
    
}


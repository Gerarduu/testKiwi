//
//  AppDelegate.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import UIKit
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupLocManager()
        // Override point for customization after application launch.
        return true
    }
    
    func setupLocManager() {
        locationManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func setupFirstScreen() {
        //Delay in order to let the Location PopUp be removed from the View
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            Navigation.shared.setSplash()
        }
    }
}

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
            setupFirstScreen()
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else {
            print("Err")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locVal = manager.location?.coordinate else {return}
        Preferences.setPrefsLatitude(value: String(format: "%.2f", locVal.latitude))
        Preferences.setPrefsLongitude(value: String(format: "%.2f", locVal.longitude))
    }
}


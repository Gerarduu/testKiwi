//
//  AppDelegate.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import UIKit
import CoreLocation
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var locationManager: CLLocationManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        appHasAlreadyLaunched()
        setupLocManager()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if UIApplication.shared.keyWindow?.rootViewController == nil {
            setupLocManager()
        }
    }
    
    func setupLocManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func setupFirstScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.8) {
            Navigation.shared.setSplash()
        }
    }
    
    private func appHasAlreadyLaunched() {
        if let hasAlreadyLaunched = Preferences.getPrefsHasAlreadyLaunched() {
            if hasAlreadyLaunched {
                Preferences.setPrefsHasAlreadyLaunched(value: true)
            }
            else {
                Preferences.setPrefsAppFirstLaunchedTime(value: Date())
            }
        }
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = FlightManager.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
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
            setupFirstScreen()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locVal = manager.location?.coordinate else {return}
        Preferences.setPrefsLatitude(value: String(format: "%.2f", locVal.latitude))
        Preferences.setPrefsLongitude(value: String(format: "%.2f", locVal.longitude))
    }
}


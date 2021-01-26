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
        FlightCacheManager.shared.start()
        appHasAlreadyLaunched()
        setupLocManager()
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        /// When compiling on Xcode 12.3 (didn't check other versions), when the location prompt appears,
        /// if the user blocks the screen before defining his location, and then goes to the App again,
        /// the location promt doesn't appear again. So in order to solve that, I'm setting up the
        /// location manager again.
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
        //Delay in order to let the Location PopUp be removed from the View, in case FakeSplashVC has to show another pop-up with an error.
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
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: kFlightContainer)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
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
            debugPrint("delegate_first")
            setupFirstScreen() /// Will use user coordinates
        } else if CLLocationManager.authorizationStatus() == .notDetermined {
            debugPrint("delegate_second")
            locationManager.requestAlwaysAuthorization()
        } else {
            debugPrint("delegate_third")
            setupFirstScreen() /// Will use specific coordinates depending on App's language
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locVal = manager.location?.coordinate else {return}
        Preferences.setPrefsLatitude(value: String(format: "%.2f", locVal.latitude))
        Preferences.setPrefsLongitude(value: String(format: "%.2f", locVal.longitude))
    }
}


//
//  FlightCacheManager.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation
import CoreData
import UIKit

class FlightCacheManager {
    
    static let shared = FlightCacheManager()
    
    private var managedContext: NSManagedObjectContext?
    private var flightEntity: NSEntityDescription?
    private var persistentContainer: NSPersistentContainer?
    
    @objc
    func start() {
        if let delegate = (UIApplication.shared.delegate as? AppDelegate) {
            managedContext = delegate.persistentContainer.viewContext
            persistentContainer = delegate.persistentContainer
            flightEntity = NSEntityDescription.entity(forEntityName: kFlightEntity, in: managedContext!)
        }
    }
    
    func saveFlightId(flight: Flight) {
        
        guard let flightEntity = flightEntity else {return}
        
        let flightEn = NSManagedObject(entity: flightEntity, insertInto: managedContext)
        flightEn.setValue(flight.id, forKey: kFlightId)
        flightEn.setValue(flight.dTime, forKey: kFlightDtime)
        flightEn.setValue(flight.aTime, forKey: kFlightATime)
        flightEn.setValue(flight.flyDuration, forKey: kFlightFlyDuration)
        flightEn.setValue(flight.flyFrom, forKey: kFlightFlyFrom)
        flightEn.setValue(flight.cityFrom, forKey: kFlightCityFrom)
        flightEn.setValue(flight.flyTo, forKey: kFlightFlyTo)
        flightEn.setValue(flight.cityTo, forKey: kFlightCityTo)
        flightEn.setValue(flight.mapIdto, forKey: kFlightMapIdto)
        flightEn.setValue(flight.deepLink, forKey: kFlightDeepLink)
        
        persistentContainer?.performBackgroundTask { (context) in
            do {
                try context.save()
            } catch let error as NSError {
                print("Could not save file. \(error), \(error.userInfo)")
            }
        }
    }
    
    func getCachedFlights() -> [Flight] {
        
        var flights = [Flight]()
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: kFlightEntity)
            
        do {
            guard let managedFlights = try (managedContext?.fetch(fetchRequest)) else {
                return []
            }
            
            for flight in managedFlights {
                let cachedFlight = Flight.init(
                    id: flight.value(forKey: kFlightId) as? String,
                    dTime: flight.value(forKey: kFlightDtime) as? Int,
                    aTime: flight.value(forKey: kFlightATime) as? Int,
                    flyDuration: flight.value(forKey: kFlightFlyDuration) as? String,
                    flyFrom: flight.value(forKey: kFlightFlyFrom) as? String,
                    cityFrom: flight.value(forKey: kFlightCityFrom) as? String,
                    flyTo: flight.value(forKey: kFlightFlyTo) as? String,
                    cityTo: flight.value(forKey: kFlightCityTo) as? String,
                    mapIdto: flight.value(forKey: kFlightMapIdto) as? String,
                    deepLink: flight.value(forKey: kFlightDeepLink) as? URL
                )
                
                flights.append(cachedFlight)
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return flights
    }
    
    func deleteFlight(flight: Flight) {
        do {
            guard let id = flight.id else {
                print("malformedId")
                return
            }
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: kFlightEntity)
            fetchRequest.predicate = NSPredicate(format: "id = %@", id)
            
            let obj = try managedContext?.fetch(fetchRequest)
            
            let flightToDelete = obj?[0]
            
            managedContext?.delete(flightToDelete!)
            
            try managedContext?.save()
            
            
        } catch let error as NSError {
            print("Could not delete comic. \(error), \(error.userInfo)")
        }
    }
}

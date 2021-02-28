//
//  FlightCacheManager.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation
import CoreData
import UIKit

class FlightManager: NSObject {
    
    static let shared = FlightManager()
    private var flightEntity: NSEntityDescription?
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: kFlightContainer)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveFlights(flights: Set<Flight>, finish: @escaping () -> Void) {
        
        let context = FlightManager.persistentContainer.viewContext
        
        guard let flightEntity = NSEntityDescription.entity(forEntityName: kFlightEntity, in: context) else { return }
        
        context.perform {
            for (i,flight) in flights.enumerated() {
                let flightEn = NSManagedObject(entity: flightEntity, insertInto: context)
                flightEn.setValue(flight.id, forKey: kFlightId)
                flightEn.setValue(flight.dTime, forKey: kFlightDtime)
                flightEn.setValue(flight.aTime, forKey: kFlightATime)
                flightEn.setValue(flight.flyDuration, forKey: kFlightFlyDuration)
                flightEn.setValue(flight.flyFrom, forKey: kFlightFlyFrom)
                flightEn.setValue(flight.cityFrom, forKey: kFlightCityFrom)
                flightEn.setValue(flight.flyTo, forKey: kFlightFlyTo)
                flightEn.setValue(flight.cityTo, forKey: kFlightCityTo)
                flightEn.setValue(flight.price, forKey: kPrice)
                flightEn.setValue(flight.mapIdto, forKey: kFlightMapIdto)
                flightEn.setValue(flight.deepLink, forKey: kFlightDeepLink)
                if i == flights.count-1 {
                    finish()
                }
            }
            
            do {
                try context.save()
            } catch let error as NSError {
                debugPrint("Could not save file. \(error), \(error.userInfo)")
            }
        }
    }
    
    func getCachedFlights(finish: @escaping ([Flight], Error?) -> Void) {
        
        let context = FlightManager.persistentContainer.viewContext
         
        context.perform {
            
            var flights = [Flight]()
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: kFlightEntity)
                
            do {
                let managedFlights = try (context.fetch(fetchRequest))
                 
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
                        price: flight.value(forKey: kPrice) as? Int,
                        mapIdto: flight.value(forKey: kFlightMapIdto) as? String,
                        deepLink: flight.value(forKey: kFlightDeepLink) as? URL
                    )
                    
                    flights.append(cachedFlight)
                }
                
            } catch let error as NSError {
                debugPrint("Could not fetch. \(error), \(error.userInfo)")
                finish([Flight](), error)
            }
            
            finish(flights,nil)
        }
    }
    
    func deleteFlight(flight: Flight) {
            
        let context = FlightManager.persistentContainer.viewContext
            
        context.perform {
            do {
                guard let id = flight.id else {
                    return
                }
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: kFlightEntity)
                fetchRequest.predicate = NSPredicate(format: "id = %@", id)
                
                let obj = try context.fetch(fetchRequest)
                
                let flightToDelete = obj[0]
                
                context.delete(flightToDelete)
                
                try context.save()
                
            } catch let error as NSError {
                debugPrint("Could not delete file. \(error), \(error.userInfo)")
            }
        }
    }
}

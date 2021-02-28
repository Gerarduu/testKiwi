//
//  FlightCacheManager.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation
import CoreData

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
        
        context.perform {
            for (i,flightModel) in flights.enumerated() {
                let flight = FlightObject(context: context)
                flight.id = flightModel.id
                flight.dTime = flightModel.dTime as NSNumber?
                flight.aTime = flightModel.aTime as NSNumber?
                flight.flyDuration = flightModel.flyDuration
                flight.flyFrom = flightModel.flyFrom
                flight.cityFrom = flightModel.cityFrom
                flight.flyTo = flightModel.flyTo
                flight.cityTo = flightModel.cityTo
                flight.price = flightModel.price as NSNumber?
                flight.mapIdTo = flightModel.mapIdto
                flight.deepLink = flightModel.deepLink
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
    
    func getCachedFlights() -> [FlightObject]? {
        let context = FlightManager.persistentContainer.viewContext
        let items = try? context.fetch(FlightObject.fetchRequest()) as? [FlightObject]
        return items
    }
    
    func deleteFlight(flight: FlightObject) {
            
        let context = FlightManager.persistentContainer.viewContext
            
        context.perform {
            do {
                context.delete(flight)
                try context.save()
            } catch let error as NSError {
                debugPrint("Could not delete file. \(error), \(error.userInfo)")
            }
        }
    }
}

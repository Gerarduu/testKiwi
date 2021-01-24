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
            DispatchQueue.main.async {
                self.managedContext = delegate.persistentContainer.viewContext
                self.persistentContainer = delegate.persistentContainer
                self.flightEntity = NSEntityDescription.entity(forEntityName: kFlightEntity, in: self.managedContext!)
            }
        }
    }
    
    func saveFlightId(flight: Flight) {
        
        managedContext?.perform {
            
            if Thread.isMainThread{
                print("saveFlightInMain")
            } else {
                print("saveFlightInBG")
            }
            
            guard let flightEntity = self.flightEntity else {return}
            
            let flightEn = NSManagedObject(entity: flightEntity, insertInto: self.managedContext)
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
            
            do {
                try self.managedContext?.save()
            } catch let error as NSError {
                print("Could not save file. \(error), \(error.userInfo)")
            }
        }
    }
    
    func getCachedFlights(finish: @escaping ([Flight], Error?) -> Void) {
        
        managedContext?.perform {
            
            if Thread.isMainThread{
                print("getInMain")
            } else {
                print("getInBG")
            }
        
            var flights = [Flight]()
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: kFlightEntity)
                
            do {
                guard let managedFlights = try (self.managedContext?.fetch(fetchRequest)) else {
                    finish([Flight](),AppError.generic)
                    return
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
                finish([Flight](), error)
            }
            
            finish(flights,nil)
        }
    }
    
    func deleteFlight(flight: Flight) {
        
        managedContext?.perform {
            
            if Thread.isMainThread{
                print("DelInMain")
            } else {
                print("DelInBG")
            }
            
            do {
                guard let id = flight.id else {
                    print("malformedId")
                    return
                }
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: kFlightEntity)
                fetchRequest.predicate = NSPredicate(format: "id = %@", id)
                
                let obj = try self.managedContext?.fetch(fetchRequest)
                
                let flightToDelete = obj?[0]
                
                self.managedContext?.delete(flightToDelete!)
                
                try self.managedContext?.save()
                
            } catch let error as NSError {
                print("Could not delete file. \(error), \(error.userInfo)")
            }
        }
    }
}

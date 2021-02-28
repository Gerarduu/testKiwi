//
//  Flights+CoreDataClass.swift
//  testKiwi
//
//  Created by Gerard Riera  on 28/02/2021.
//

import Foundation
import CoreData

extension FlightObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FlightObject> {
        return NSFetchRequest<FlightObject>(entityName: kFlightEntity)
    }
    
    @NSManaged public var id: String?
    @NSManaged public var dTime: NSNumber?
    @NSManaged public var aTime: NSNumber?
    @NSManaged public var flyDuration: String?
    @NSManaged public var flyFrom: String?
    @NSManaged public var cityFrom: String?
    @NSManaged public var flyTo: String?
    @NSManaged public var cityTo: String?
    @NSManaged public var price: NSNumber?
    @NSManaged public var mapIdTo: String?
    @NSManaged public var deepLink: URL?
}

extension FlightObject: Identifiable {
}

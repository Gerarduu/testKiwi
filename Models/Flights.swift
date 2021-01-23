//
//  Flights.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation

struct FlightsRoot: Codable {
    var data: [Flight]?
}
 
struct Flight: Codable {
    
    var id: String?
    var dTime: Int?
    var aTime: Int?
    var flyDuration: String?
    var flyFrom: String?
    var cityFrom: String?
    var flyTo: String?
    var cityTo: String?
    var mapIdto: String?
    var deepLink: URL?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case dTime = "dTime"
        case aTime = "aTime"
        case flyDuration = "fly_duration"
        case flyFrom = "flyFrom"
        case cityFrom = "cityFrom"
        case flyTo = "flyTo"
        case cityTo = "cityTo"
        case mapIdto = "mapIdTo"
        case deepLink = "deep_link"
    }
}

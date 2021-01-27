//
//  APIRouter.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation

enum APIRouter {
    
    /// Flights
    case flights
    
    var method: String {
        switch self {
            case .flights : return kHTTPMethodGet
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .flights:
            var lat: String = ""
            var lon: String = ""
            
            if let latTemp = Preferences.getPrefsLatitude(), let lonTemp = Preferences.getPrefsLongitude() {
                lat = latTemp
                lon = lonTemp
            } else {
                if let curLanguage = Bundle.main.preferredLocalizations.first {
                    switch curLanguage {
                    case "es":
                        lat = kEsLat
                        lon = kEsLon
                    case "ca":
                        lat = kCatLat
                        lon = kCatLon
                    default:
                        lat = kCatLat
                        lon = kCatLon
                    }
                } else {
                    lat = kCatLat
                    lon = kCatLon
                }
            }
            
            let parameters = [
                URLQueryItem(name: kLocale, value: "en"),
                URLQueryItem(name: kV, value: "3"),
                URLQueryItem(name: kSort, value: "popularity"),
                URLQueryItem(name: kFlyFrom, value: "\(lat)-\(lon)-250km"),
                URLQueryItem(name: kTo, value: "anywhere"),
                URLQueryItem(name: kFeatureName, value: "aggregateResults"),
                URLQueryItem(name: kDateFrom, value: "01/02/2021"),
                URLQueryItem(name: kDateTo, value: "31/12/2022"),
                URLQueryItem(name: kTypeFlight, value: "oneway"),
                URLQueryItem(name: kOneForCity, value: "1"),
                URLQueryItem(name: kAdults, value: "1"),
                URLQueryItem(name: kLimit, value: "200"),
                URLQueryItem(name: kPartner, value: "picky")
            ]
            return parameters
        }
    }
    
    static let baseURLString = kBaseURL
    
    var path: String {
        switch self {
            case .flights: return kFlightsPath
        }
    }
    
    var headers: [String: String]? {
        var headers: [String: String] = [:]
        if let curLanguage = Bundle.main.preferredLocalizations.first {
            switch curLanguage {
            case "es":
                headers["Accept-Language"] = "es"
            case "ca":
                headers["Accept-Language"] = "ca"
            default:
                headers["Accept-Language"] = "en"
            }
        }
        else {
            headers["Accept-Language"] = "en"
        }
        return headers
    }
    
    func asURLRequest() -> URLRequest? {
        var components = URLComponents(string: APIRouter.baseURLString+path)
        components?.queryItems = queryItems
        
        guard let url = components?.url else {return nil}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.allHTTPHeaderFields = headers
        
        return urlRequest
    }
}

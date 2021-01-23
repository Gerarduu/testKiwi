//
//  Preferences.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation

class Preferences {
    // MARK: - Get Set User's Latitude
    static func getPrefsLatitude() -> String? {
        return UserDefaults.standard.string(forKey: kPrefsLatitude)
    }
    
    static func setPrefsLatitude(value: String?) {
        UserDefaults.standard.set(value, forKey: kPrefsLatitude)
    }
    
    // MARK: - Get Set User's Longitude
    static func getPrefsLongitude() -> String? {
        return UserDefaults.standard.string(forKey: kPrefsLongitude)
    }
    
    static func setPrefsLongitude(value: String?) {
        UserDefaults.standard.set(value, forKey: kPrefsLongitude)
    }
}

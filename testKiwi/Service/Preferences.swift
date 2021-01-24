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
    
    // MARK: - App has already launched
    static func getPrefsHasAlreadyLaunched() -> Bool? {
        return UserDefaults.standard.bool(forKey: kPrefsHasAlreadyLaunched)
    }
    
    static func setPrefsHasAlreadyLaunched(value: Bool?) {
        UserDefaults.standard.set(value, forKey: kPrefsHasAlreadyLaunched)
    }
    
    // MARK: - App first time launch time
    static func getPrefsAppFirstLaunchedTime() -> Date? {
        return UserDefaults.standard.value(forKey: kPrefsAppFirstLaunchedTime) as? Date
    }
    
    static func setPrefsAppFirstLaunchedTime(value: Date?) {
        UserDefaults.standard.set(value, forKey: kPrefsAppFirstLaunchedTime)
    }
}

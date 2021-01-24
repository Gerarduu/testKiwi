//
//  String+Utils.swift
//  testKiwi
//
//  Created by Gerard Riera  on 23/01/2021.
//

import Foundation

import Foundation

extension String {
    /// Returns a language localized version of the given string.
    /// - returns: The language localized string.
    var localized: String {
        let auxString = (self as NSString).replacingOccurrences(of: "\0", with: "")
        return NSLocalizedString(auxString, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
}

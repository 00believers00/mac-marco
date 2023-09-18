//
//  String.swift
//  marco
//
//  Created by ap on 9/2/2566 BE.
//

import Foundation
extension String {
    
    // MARK: - RegexType
    enum RegexType {
        case none
        case mobileNumberWithItalianCode    // Example: "+39 3401234567"
        case email                          // Example: "foo@example.com"
        case minLetters(_ letters: Int)     // Example: "Al"
        case minDigit(_ digits: Int)        // Example: "0612345"
        case onlyLetters                    // Example: "ABDEFGHILM"
        case onlyNumbers                    // Example: "132543136"
        case onlyDouble                    // Example: "132543.136"
        case noSpecialChars                 // Example: "Malago'": OK - "Malagò": KO
        
        fileprivate var pattern: String {
            switch self {
            case .none:
                return ""
            case .mobileNumberWithItalianCode:
                return #"^(\+39 )\d{9,}$"#
            case .email:
                return #"^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$"#
            case .minLetters(let letters):
                return #"^\D{"# + "\(letters)" + #",}$"#
            case .minDigit(let digits):
                return #"^(\d{"# + "\(digits)" + #",}){1}$"#
            case .onlyLetters:
                return #"^[A-Za-z]+$"#
            case .onlyNumbers:
                return #"^[0-9]"#
            case .onlyDouble:
                return #"^[0-9\-\.+]"#
            case .noSpecialChars:
                return #"^[A-Za-z0-9\s+\\\-\/?:().,']+$"#
            }
        }
    }
    
    // MARK: - Validation
    /// Perform a regex falidation of the string
    /// - Parameter regexType: enum type of the regex to use
    /// - Returns: the result of the test
    func isValidation(regex type: RegexType) -> Bool {
        
        switch type {
        case .none : return true
        default    : break
        }
        
        let pattern = type.pattern
        guard let gRegex = try? NSRegularExpression(pattern: pattern) else {
            return false
        }
        
        let characters = self.split(separator: "")
        var results:[Bool] = []
        for char in characters{
            
            let range = NSRange(location: 0, length: char.utf16.count)
            
            if gRegex.firstMatch(in: String(char), options: [], range: range) != nil {
                results.append(true)
            }else{
                results.append(false)
            }
        }
        
        return !results.contains(false)
    }
}


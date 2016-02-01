//
//  NSErrorExtention.swift
//  INFO915_IoT
//
//  Created by François Caillet on 01/02/2016.
//  Copyright © 2016 François Caillet. All rights reserved.
//

import Foundation

public enum ErrorType: Int {
    
    case Unknown = 1
    case NotAuthenticated = 2
    case UnexpectedFormat = 6
    
    func localizedUserInfo() -> [String: String] {
        var localizedDescription: String = ""
        let localizedFailureReasonError: String = ""
        let localizedRecoverySuggestionError: String = ""
        
        switch self {
        case UnexpectedFormat:
            localizedDescription = NSLocalizedString("It looks like our servers are not returning the right thing. Is your Brokl app up-to-date ?", comment: "Error message")
        case Unknown:
            localizedDescription = NSLocalizedString("Error.Unknown", comment: "Unknown error")
        case NotAuthenticated:
            localizedDescription = NSLocalizedString("Error.NotAuthenticated", comment: "User not authenticated")
        }
        return [
            NSLocalizedDescriptionKey: localizedDescription,
            NSLocalizedFailureReasonErrorKey: localizedFailureReasonError,
            NSLocalizedRecoverySuggestionErrorKey: localizedRecoverySuggestionError
        ]
    }
}

public let ProjectErrorDomain = "ProjectErrorDomain"

extension NSError {
    
    public convenience init(type: ErrorType) {
        self.init(domain: ProjectErrorDomain, code: type.rawValue, userInfo: type.localizedUserInfo())
    }
}
//
//  Home.swift
//  INFO915_IoT
//
//  Created by François Caillet on 01/02/2016.
//  Copyright © 2016 François Caillet. All rights reserved.
//

import Foundation

class Home: NSObject, NSCoding{
    let identifier:String!
    let firstName:String?
    let lastName:String?
    var email:String?
    
    init?(json:NSDictionary) {
        self.email = json.valueForKeyPath("email") as? String
        self.identifier = json.valueForKeyPath("_id") as? String
        self.firstName = json.valueForKeyPath("username.first") as? String
        self.lastName = json.valueForKeyPath("username.last") as? String
        super.init()
        if self.identifier == nil {
            return nil
        }
    }
    
    @objc internal required init?(coder aDecoder: NSCoder) {
        self.email = aDecoder.decodeObjectForKey("email") as? String
        self.identifier = aDecoder.decodeObjectForKey("identifier") as? String
        self.firstName = aDecoder.decodeObjectForKey("firstName") as? String
        self.lastName = aDecoder.decodeObjectForKey("lastName") as? String
        super.init()
        if self.identifier == nil {
            return nil
        }
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        if let email = email {
            aCoder.encodeObject(email, forKey:"email")
        }
        aCoder.encodeObject(identifier, forKey: "identifier")
        if let firstName = firstName {
            aCoder.encodeObject(firstName, forKey: "firstName")
        }
        if let lastName = lastName {
            aCoder.encodeObject(lastName, forKey: "lastName")
        }
    }
    
    
    var URLString:String {
        return Config.rootURL.URLByAppendingPathComponent(String(format:"home/%@", self.identifier)).absoluteString
    }
    
    var URL:NSURL {
        return NSURL(string:URLString)!
    }
    
    var fullName:String {
        get {
            if let firstName = firstName, lastName = lastName {
                return String(format:"%@ %@", firstName, lastName)
            }
            if let firstName = firstName {
                return firstName
            }
            if let lastName = lastName {
                return lastName
            }
            return ""
        }
    }
    
    
}
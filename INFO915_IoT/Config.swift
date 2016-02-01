//
//  Config.swift
//  INFO915_IoT
//
//  Created by François Caillet on 01/02/2016.
//  Copyright © 2016 François Caillet. All rights reserved.
//

import Foundation

class Config: NSObject {
    
    class var rootURL: NSURL{
        #if DEBUG
            return NSURL(string: "")!
            #else
            return NSURL(string: "")!
        #endif
    }
    
}
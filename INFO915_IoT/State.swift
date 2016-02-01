//
//  State.swift
//  INFO915_IoT
//
//  Created by François Caillet on 01/02/2016.
//  Copyright © 2016 François Caillet. All rights reserved.
//

import Foundation

class State: NSObject{
    
    var light: Light?
    var on: Bool?
    var bri: Int?
    var bue: String?
    var sat: Int?
    var effect: String?
    var xy: [Float]?
    var ct: Int?
    var alert: String?
    var colormode: String?
    var reachable: Bool?
    
    init?(light: Light, json: NSDictionary) {
        self.light = light
        self.on = json.valueForKey("on") as? Bool
    }
    
    
}
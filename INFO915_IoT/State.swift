//
//  State.swift
//  INFO915_IoT
//
//  Created by François Caillet on 01/02/2016.
//  Copyright © 2016 François Caillet. All rights reserved.
//

import Foundation
import Alamofire

class State: NSObject{
    
    var light: Light?
    var on: Bool?
    var bri: Int?
    var hue: Int?
    var sat: Int?
    var effect: String?
    var xy: [Double]?
    var ct: Int?
    var alert: String?
    var colormode: String?
    var reachable: Bool?
    
    init?(light: Light, json: NSDictionary) {
        self.light = light
        self.on = json.valueForKey("on") as? Bool
        self.bri = json.valueForKey("bri") as? Int
        self.hue = json.valueForKey("hue") as? Int
        self.sat = json.valueForKey("sat") as? Int
        self.effect = json.valueForKey("effect") as? String
        self.xy = json.valueForKey("xy") as? [Double]
        self.ct = json.valueForKey("ct") as? Int
        self.alert = json.valueForKey("alert") as? String
        self.colormode = json.valueForKey("colormode") as? String
        self.reachable = json.valueForKey("reachable") as? Bool
    }
    
    func lightSwitch(completion:((NSError?) -> Void)){
        var parameters: [String:AnyObject]
        if light!.state!.on! {
            parameters = ["id": light!.identifier!, "on" : false]
        }else{
            parameters = ["id": light!.identifier!, "on" : true]
        }
        Alamofire.request(.POST, Config.rootURL.URLByAppendingPathComponent("light"), parameters: parameters).validate()
            .responseJSON { response in
                if response.result.isSuccess {
                    print("traitement...")
                    //-TODO
                }
                completion(nil)
            }

    }
    
    
    
}
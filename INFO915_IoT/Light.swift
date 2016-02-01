//
//  Light.swift
//  INFO915_IoT
//
//  Created by François Caillet on 01/02/2016.
//  Copyright © 2016 François Caillet. All rights reserved.
//

import Foundation
import Alamofire


class Light: NSObject{
    
    var home: Home!
    var uniqueid: String?
    var type: String?
    var modelid: String?
    var name: String?
    var manufacturername: String?
    var swversion: String?
    var state: State?
    
    init?(home:Home) {
        self.home = home
        super.init()
    }
    
    static func instantiate(home: Home, json: NSDictionary) -> Light? {
        return Light(home:home, json:json)
    }
    
    init?(home: Home, json:NSDictionary) {
        self.uniqueid = json.valueForKeyPath("uniqueid") as? String
        self.type = json.valueForKeyPath("type") as? String
        self.modelid = json.valueForKey("modelid") as? String
        self.name = json.valueForKey("name") as? String
        self.manufacturername = json.valueForKey("manufacturername") as? String
        self.swversion = json.valueForKey("swversion") as? String
        
        super.init()
        
        if let stateJson = json.valueForKey("state") as? NSDictionary{
            if let state = State(light: self, json: stateJson) {
                self.state = state
            }
        }
        if self.uniqueid == nil {
            return nil
        }
    }
    
    
    var URL:NSURL? {
        if let uniqueid = uniqueid {
            return home.URL.URLByAppendingPathComponent(String(format:"light/%@", uniqueid))
        }
        return nil
    }
    
    var json:NSDictionary {
        let result = NSMutableDictionary()
        if let type = type {
            result["type"] = type
        }
        if let modelid = self.modelid {
            result["modelid"] = modelid
        }
        if let name = self.name {
            result["name"] = name
        }
        if let manufacturername = self.manufacturername {
            result["manufacturername"] = manufacturername
        }
        if let swversion = self.swversion {
            result["swversion"] = swversion
        }
        return result
    }
    
    class func fetchAll(home:Home, completion:(([NSDictionary], NSError?) -> Void)) {
        
        Alamofire.request(.GET, home.URL.URLByAppendingPathComponent("light")).validate().responseJSON{response in switch response.result {
            case .Success(let jsons):
                if let jsons = jsons as? [NSDictionary] {
                    completion(jsons, nil)
                } else {
                    completion([], NSError(type: .UnexpectedFormat))
                }
            case .Failure(let error):
                    completion([], error as NSError)
            }
        }
    }

    
}

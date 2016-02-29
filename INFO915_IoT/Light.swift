//
//  Light.swift
//  INFO915_IoT
//
//  Created by François Caillet on 01/02/2016.
//  Copyright © 2016 François Caillet. All rights reserved.
//

import Foundation
import Alamofire


private let LightCatalogInstance = Light.Catalog(slug:"lights")

final class Light: NSObject, CatalogObject {
    
    //var home: Home!
    var identifier: String?
    var uniqueid: String?
    var type: String?
    var modelid: String?
    var name: String?
    var manufacturername: String?
    var swversion: String?
    var state: State?
    
    override init(/*home:Home*/) {
        //self.home = home
        super.init()
    }
    
    static func instantiate(/*home: Home,*/ json: NSDictionary) -> Light? {
        return Light(/*home:home,*/ json:json)
    }
    
    init?(/*home: Home, */json:NSDictionary) {
        self.identifier = String(json.valueForKeyPath("id") as! Int)
        self.uniqueid = json.valueForKeyPath("data.uniqueid") as? String
        self.type = json.valueForKeyPath("data.type") as? String
        self.modelid = json.valueForKeyPath("data.modelid") as? String
        self.name = json.valueForKeyPath("data.name") as? String
        self.manufacturername = json.valueForKeyPath("data.manufacturername") as? String
        self.swversion = json.valueForKeyPath("data.swversion") as? String
        
        
        
        super.init()
        
        if let stateJson = json.valueForKeyPath("data.state") as? NSDictionary{
            if let state = State(light: self, json: stateJson) {
                self.state = state
            }
        }
        if self.identifier == nil {
            return nil
        }
    }
    
    
    var URL:NSURL? {
        if let uniqueid = identifier {
            return Config.rootURL.URLByAppendingPathComponent(String(format:"light/%@", uniqueid))
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
    static func fetchAll(completion:(([NSDictionary], NSError?) -> Void)) {
        Alamofire.request(.GET, Config.rootURL.URLByAppendingPathComponent("light")).validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let jsons):
                    if let jsons = jsons as? [NSDictionary] {
                        completion(jsons, nil)
                    }
                default:
                    print("default")
                    
                }
                
        }
    }
    
    class var objects:Light.Catalog {
        return LightCatalogInstance
    }
    
    class Catalog : ObjectCatalog<Light> {
        override init(slug:String) {
            super.init(slug:slug)
        }
    }
    
    
}

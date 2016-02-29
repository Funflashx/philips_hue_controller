//
//  ObjectCatalog.swift
//  INFO915_IoT
//
//  Created by François Caillet on 15/02/2016.
//  Copyright © 2016 François Caillet. All rights reserved.
//

import Foundation
import UIKit

protocol CatalogObject: class, Hashable {
    var identifier:String? { get }
    static func instantiate(/*home:Home, */json:NSDictionary) -> Self?
    static func fetchAll(/*home:Home, */completion:(([NSDictionary], NSError?) -> Void))
}

let CatalogUpdatedNotification = "CatalogUpdatedNotification"

class ObjectCatalog<T:CatalogObject>: NSObject {
    let slug:String
    
    init(slug:String) {
        self.slug = slug
        super.init()
    }
    
    private var defaultsKey:String {
        return String(format:"", slug)
    }
    
    private func readDefaults() -> [NSDictionary]? {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let data = defaults.objectForKey(defaultsKey) as? NSData {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [NSDictionary]
            } catch {
                NSLog("Could not read saved %@ catalog: %@", self.slug, error as NSError)
            }
        }
        return nil
    }
    
    private var cache:[T] = []
    
    var all:[T] {
        return cache
    }
    
    func withIdentifiers(identifiers:Set<String>) -> Set<T> {
        var result = Set<T>()
        for object in all {
            if let identifier = object.identifier {
                if identifiers.contains(identifier) {
                    result.insert(object)
                }
            }
            
        }
        return result
    }
    func withOrderedIdentifiers(identifiers:[String]) -> [T] {
        var result:[T] = []
        for object in all {
            if let identifier = object.identifier {
                if identifiers.contains(identifier) {
                    result.append(object)
                }
            }
            
        }
        return result
    }
    
    func update() {
        //if let home = User.currentUser.home {
        T.fetchAll({jsons, error in
            if let error = error {
                NSLog("Could not update %@ catalog: %@", self.slug, error)
                return
            }
            
            var objects:[T] = []
            for json in jsons {
                if let object = T.instantiate(json) {
                    objects.append(object)
                }
            }
            
            self.cache = objects
            self.save(jsons)
            self.notifyUpdate()
        })
        //}
    }
    
    func localCreation(obj:T, json:NSDictionary) {
        var jsons:[NSDictionary]!
        if let savedJsons = readDefaults() {
            jsons = savedJsons
        } else {
            jsons = []
        }
        
        jsons.insert(json, atIndex: 0)
        save(jsons)
        cache.insert(obj, atIndex: 0)
        notifyUpdate()
    }
    
    private func save(jsons:[NSDictionary]) {
        // Save in NSUserDefaults as JSON String
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(jsons, options: [])
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setObject(data, forKey: self.defaultsKey)
            defaults.synchronize()
        } catch {
            NSLog("Could not save %@ catalog: %@", self.slug, error as NSError)
        }
        
        
    }
    
    func notifyUpdate() {
        NSNotificationCenter.defaultCenter().postNotificationName(CatalogUpdatedNotification, object: self)
        NSLog("%@ catalog updated.", self.slug)
    }
    
    
    
}

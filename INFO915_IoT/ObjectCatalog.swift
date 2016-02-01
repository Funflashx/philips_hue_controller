//
//  ObjectCatalog.swift
//  INFO915_IoT
//
//  Created by François Caillet on 01/02/2016.
//  Copyright © 2016 François Caillet. All rights reserved.
//

import Foundation
import CoreSpotlight
protocol CatalogObject: class, Hashable {
    var identifier:String? { get }
    static func instantiate(company:Company, json:NSDictionary) -> Self?
    static func fetchAll(company:Company, completion:(([NSDictionary], NSError?) -> Void))
}

let CatalogUpdatedNotification = "CatalogUpdatedNotification"

class ObjectCatalog<T:CatalogObject>: NSObject {
    let slug:String
    
    init(slug:String) {
        self.slug = slug
        super.init()
        
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: Selector("userChanged:"), name: UserLoggedInNotification, object: nil)
        center.addObserver(self, selector: Selector("userChanged:"), name: UserLoggedOutNotification, object: nil)
        
        // Load from cache
        
        if let jsons = readDefaults() {
            for json in jsons {
                if let company = User.currentUser.company, object = T.instantiate(company, json:json) {
                    cache.append(object)
                }
            }
        }
        
        
    }
    
    private var defaultsKey:String {
        return String(format:"com.calopea.brokl.app.%@", slug)
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
        
        if let company = User.currentUser.company {
            T.fetchAll(company, completion: {jsons, error in
                if let error = error {
                    NSLog("Could not update %@ catalog: %@", self.slug, error)
                    return
                }
                
                var objects:[T] = []
                for json in jsons {
                    if let object = T.instantiate(company, json: json) {
                        objects.append(object)
                    }
                }
                
                self.cache = objects
                self.save(jsons)
                self.notifyUpdate()
            })
        }
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
    
    func localDeletion(obj:T) {
        if let jsons = readDefaults(), company = User.currentUser.company {
            save(jsons.filter({T.instantiate(company, json:$0) != obj}))
        }
        cache = cache.filter({$0 != obj})
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
        #if DEBUG
            NSLog("%@ catalog updated.", self.slug)
        #endif
    }
    
    func userChanged(notification:NSNotification) {
        let user = User.currentUser
        if user.isLoggedIn {
            update()
        } else {
            
            var identifiersToRemoveFromSpotlight:[String] = []
            for o in self.all {
                if let indexable = o as? IndexableItem, identifier = o.identifier {
                    identifiersToRemoveFromSpotlight.append(identifier)
                }
            }
            if identifiersToRemoveFromSpotlight.count > 0 {
                CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithIdentifiers(identifiersToRemoveFromSpotlight, completionHandler: {error in
                    if let error = error {
                        NSLog("Error deindexing items: %@", error)
                    }
                })
            }
            
            
            
            cache = []
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.removeObjectForKey(self.defaultsKey)
            defaults.synchronize()
            NSNotificationCenter.defaultCenter().postNotificationName(CatalogUpdatedNotification, object: self)
            
        }
    }
    
}

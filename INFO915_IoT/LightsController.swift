//
//  LightsController.swift
//  INFO915_IoT
//
//  Created by François Caillet on 15/02/2016.
//  Copyright © 2016 François Caillet. All rights reserved.
//

import UIKit

private func sortedLights(lights:[Light]) -> [Light] {
    return lights.sort({l1, l2 in
        return l1.name!.lowercaseString < l2.name!.lowercaseString
    })
}

class LightsController: UITableViewController{
    
    private var lights:[Light] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storeData(Light.objects.all)
        
        
        // Notifications
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: Selector("catalogUpdated:"), name: CatalogUpdatedNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func storeData(lights:[Light]){
        self.lights = sortedLights(lights)
    }
    
    func catalogUpdated(notification:NSNotification) {
        if let catalog = notification.object as? Light.Catalog {
            self.storeData(catalog.all)
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("LightCell", forIndexPath: indexPath)
        cell.textLabel?.text = lights[indexPath.row].name! //+ String(lights[indexPath.row].state?.on)
        return cell
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lights.count
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.lights[indexPath.row].state?.lightSwitch({_ in })
    }
    
    //height of cells
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 90
    }
    
    
    
}

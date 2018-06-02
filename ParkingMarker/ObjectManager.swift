//
//  ObjectManager.swift
//  ParkingMarker
//
//  Created by Jonathan Yee on 5/31/18.
//  Copyright © 2018 Jonathan Yee. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class ObjectManager {
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func createLocation(marker: CLLocationCoordinate2D, title: String){
        print("<> createLocation <>")
        let item = NSEntityDescription.insertNewObject(forEntityName: "Location", into: managedObjectContext) as! Location
        item.createdAt = Date()
        if title.count == 0 {
            item.title = "Unnamed Location"
        } else {
            item.title = title
        }
        item.latitude = marker.latitude
        item.longitude = marker.longitude
        saveCoreData()
    }
    
    func fetchAllLocation() -> [Location] {
        print("<> fetchAllLocation <>")
        var array: [Location] = []
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        do {
            let result = try managedObjectContext.fetch(request)
            array = result as! [Location]
        } catch {
            print("Error: \(error)")
        }
        return array
    }
    
    func deleteLocation(location: Location){
        print("<> deleteLocation <>")
        managedObjectContext.delete(location)
        saveCoreData()
    }
    
    func saveCoreData(){
        print("<> saveCoreData <>")
        do {
            try managedObjectContext.save()
        } catch {
            print("There was an error: \(error)")
        }
    }
    
    func editLocation(object: Location, title: String){
        print("<> editLocation <>")
        object.title = title
        saveCoreData()
    }
    
}

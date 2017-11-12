//
//  Pin.swift
//  VirtualTourist
//
//  Created by Taylor Masterson on 11/12/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class Pin: NSManagedObject {
    
    class func findOrCreatePin(lat: Double, lng: Double, in context: NSManagedObjectContext) throws -> Pin
    {
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        request.predicate = NSPredicate(format: "lat = %@ and lng = %@", lat, lng)
        
        do {
            let pins = try context.fetch(request)
            if pins.count > 0 {
                assert(pins.count == 1, "Pin.findOrCreatePin failed")
                return pins[0]
            }
        } catch {
            throw error
        }
        
        let pin = Pin(context: context)
        pin.lat = lat
        pin.lng = lng
        pin.creationDate = NSDate() as Date
        pin.hasPhotos = false
        return pin
    }
}

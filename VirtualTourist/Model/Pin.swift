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
    
    convenience init(lat: Double, lng: Double, in context: NSManagedObjectContext) {
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: ent, insertInto: context)
            self.lat = lat
            self.lng = lng
            self.hasPhotos = false
            self.creationDate = NSDate() as Date
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
    class func findOrCreatePin(lat: Double, lng: Double, in context: NSManagedObjectContext) throws -> Pin {
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
    
    func getBBoxString() -> String {
        let bottomLeftLat = max(self.lat - Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.0)
        let bottomLeftLng = max(self.lng - Flickr.SearchBBoxHalfWidth, Flickr.SearchLngRange.0)
        let topRightLat = min(self.lat + Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.1)
        let topRightLng = min(self.lng + Flickr.SearchBBoxHalfWidth, Flickr.SearchLngRange.1)
        
        return "\(bottomLeftLng),\(bottomLeftLat),\(topRightLng),\(topRightLat)"
    }
}

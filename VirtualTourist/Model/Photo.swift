//
//  Photo.swift
//  VirtualTourist
//
//  Created by Taylor Masterson on 11/12/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {

    class func findOrCreatePhoto(title: String, image_url: String, pin: Pin, in context: NSManagedObjectContext) throws -> Photo {
    
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "image_url = %@", image_url)
        do {
            let photos = try context.fetch(request)
            if photos.count > 0 {
                assert(photos.count == 1, "Photo.findOrCreatePhoto failed")
                return photos[0]
            }
        } catch {
            throw error
        }
        
        let photo = Photo(context: context)
        photo.title = title
        photo.image_url = URL(string: image_url)
        photo.pin = try? Pin.findOrCreatePin(lat: pin.lat, lng: pin.lng, in: context)
        return photo
    }
}

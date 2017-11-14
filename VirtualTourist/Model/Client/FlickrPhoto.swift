//
//  FlickrPhoto.swift
//  VirtualTourist
//
//  Created by Taylor Masterson on 11/13/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import Foundation

public struct FlickrPhoto {
    public let title: String
    public let imageURL: URL
//    public let image: NSData?
    
    init?(data: NSDictionary?) {
        guard
            let title = data?.value(forKeyPath: FlickrKey.title) as! String?,
            let imageURL = URL(string: data?.value(forKeyPath: FlickrKey.imageURL) as! String)
            else {
                return nil
        }
        
        self.title = title
        self.imageURL = imageURL
//        self.image = FlickrPhoto.mediaItem(from: data?.url(forKeyPath: FlickrKey.imageURL))
    }
    
//    private static func mediaItem(from imageData: URL?) -> NSData {
//
//        result.value(forKey: "photo") as? NSData
//
//        if let data = imageData.value(forKey: "photo") as? NSData
//        return mediaItems
//    }
    
    
    struct FlickrKey {
        static let title = "title"
        static let imageURL = "url_m"
    }
}

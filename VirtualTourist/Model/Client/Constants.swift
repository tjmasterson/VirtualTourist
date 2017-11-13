//
//  Constants.swift
//  VirtualTourist
//
//  Created by Taylor Masterson on 11/12/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import Foundation

public struct Flickr {
    static let APIScheme = "https"
    static let APIHost = "api.flickr.com"
    static let APIPath = "/services/rest"
    
    static let SearchBBoxHalfWidth = 1.0
    static let SearchBBoxHalfHeight = 1.0
    static let SearchLatRange = (-90.0, 90.0)
    static let SearchLngRange = (-180.0, 180.0)
}

public struct FlickrParamKeys {
    static let Method = "method"
    static let APIKey = "api_key"
    static let NoJSONCallback = "nojsoncallback"
    static let Text = "text"
    static let Format = "format"
    static let SafeSearch = "safe_search"
    static let Page = "page"
}

public struct FlickrParamValues {
    static let SearchMethod = "flickr.photos.search"
    static let APIKey = "3089e5bf1bf8ad9f0de159a6343e9753"
    static let ResponseFormat = "json"
    static let DisableJSONCallback = "1" // 1 == yes
    static let MediumURL = "url_m"
    static let UseSafeSearch = "1"
}

public struct FlickrResponseKeys {
    static let Status = "stat" // ???
    static let Photos = "photos"
    static let Photo = "photo"
    static let Title = "title"
    static let MediumURL = "url_m"
    static let Pages = "pages"
    static let Total = "total"
}

public struct FlickrResponseValues {
    static let OKStatus = "ok"
}

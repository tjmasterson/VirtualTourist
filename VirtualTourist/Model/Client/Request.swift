//
//  Request.swift
//  VirtualTourist
//
//  Created by Taylor Masterson on 11/13/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit
import Foundation

public class Request: NSObject {
    public let parameters: [String:String]
    public let session = URLSession.shared
    public let searchMethod = FlickrParamValues.SearchMethod
    public let apiKey = FlickrParamValues.APIKey
    public let responseFormat = FlickrParamValues.ResponseFormat
    public let diableJSONCallback = FlickrParamValues.DisableJSONCallback
    public let mediumURL = FlickrParamValues.MediumURL
    public let withExtension: String? = nil
    
    // designated initializer
    public init(_ parameters: Dictionary<String, String> = [:]) {
        var params = parameters
        params[FlickrParamKeys.Method] = searchMethod
        params[FlickrParamKeys.APIKey] = apiKey
        params[FlickrParamKeys.Format] = responseFormat
        params[FlickrParamKeys.NoJSONCallback] = diableJSONCallback
        params[FlickrParamKeys.Extras] = mediumURL
        self.parameters = params
    }
    
    public func fetchFlickrPhotos(_ handler: @escaping ([FlickrPhoto]) -> Void) {
        let _ = performRequest(withExtension) { (results, error) in
            var flickrPhotos = [FlickrPhoto]()
            var allPhotos: NSArray?

            if let dictionary = results as? NSDictionary {
                if
                    let photosCollectionData = dictionary[FlickrResponseKeys.PhotosCollectionData] as? NSDictionary,
                    let photos = photosCollectionData[FlickrResponseKeys.PhotosCollection] as? NSArray {
                    allPhotos = photos
                } else if let photo = FlickrPhoto(data: dictionary) {
                    flickrPhotos = [photo]
                }
            } else if let array = results as? NSArray {
                allPhotos = array
            }
            
            if allPhotos != nil {
                for photoData in allPhotos! {
                    if let photo = FlickrPhoto(data: photoData as? NSDictionary) {
                        flickrPhotos.append(photo)
                    }
                }
            }
            
            handler(flickrPhotos)
        }
    }

    public func performRequest(_ method: String?, _ completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionTask {
        let url = urlFromParams(parameters, withPathExtension: method)
        let request = requestWithHeaders(url, method: "GET")
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard error == nil else {
                self.sendError(error as! String, task: "taskForGet", handler: completionHandler)
                return
            }
            
            guard self.responseInSuccessRange(response, task: "taskForGet", handler: completionHandler) else {
                return
            }
            
            guard let data = self.dataFromResponse(data, task: "taskForGet", handler: completionHandler) else {
                return
            }

            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandler)

        }

        task.resume()

        return task
    }
    
    private func sendError(_ errorString: String, task: String, handler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        let userInfo = [NSLocalizedDescriptionKey: errorString]
        handler(nil, NSError(domain: task, code: 1, userInfo: userInfo))
    }
    
    private func responseInSuccessRange(_ response: URLResponse?, task: String, handler: (_ result: AnyObject?, _ error: NSError?) -> Void) -> Bool {
        let successRange: Range<Int> = 200..<300
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, successRange ~= statusCode else {
            self.sendError("There was an erro with the request, returned status code outside of success range", task: task, handler: handler)
            return false
        }
        return true
    }
    
    private func dataFromResponse(_ data: Data?, task: String, handler: (_ result: AnyObject?, _ error: NSError?) -> Void) -> Data? {
        guard data != nil else {
            sendError("There was no data returned by request", task: task, handler: handler)
            return nil
        }
        return data
    }
    
    private func urlFromParams(_ params: [String: String], withPathExtension: String?) -> URL {
        var urlComponents = URLComponents()
        urlComponents.scheme = Flickr.APIScheme
        urlComponents.host = Flickr.APIHost
        urlComponents.path = Flickr.APIPath + (withPathExtension ?? "")
        urlComponents.queryItems = [URLQueryItem]()
        
        for (key, value) in params {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            urlComponents.queryItems!.append(queryItem)
        }
        
        return urlComponents.url!
    }
    
    private func requestWithHeaders(_ url: URL, method: String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method
        
        return request
    }
    
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            print("at the json \(error)")
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }

        completionHandlerForConvertData(parsedResult, nil)
    }
    
}

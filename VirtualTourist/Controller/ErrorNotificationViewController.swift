//
//  ErrorNotificationViewController.swift
//  VirtualTourist
//
//  Created by Taylor Masterson on 11/12/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit
import Foundation

class ErrorNotificationViewController: UIViewController {
    
    func notify(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func log(_ message: Any) {
        debugPrint("Major Error: \(message)")
    }
}

extension ErrorNotificationViewController {
    
    class func sharedInstance() -> ErrorNotificationViewController {
        struct Singleton {
            static var sharedInstance = ErrorNotificationViewController()
        }
        return Singleton.sharedInstance
    }
}

//
//  PinsViewController.swift
//  VirtualTourist
//
//  Created by Taylor Masterson on 11/12/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PinsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    var selectedPin: Pin?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var longPressGesture: UILongPressGestureRecognizer!
    
    @IBAction func mapViewLongPressed(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
            case UIGestureRecognizerState.began:
                let annotation = MKPointAnnotation()
                let touchPoint = sender.location(in: mapView)
                let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
                annotation.coordinate = coordinate
                mapView.addAnnotation(annotation)
            
            case UIGestureRecognizerState.ended:
                let touchPoint = sender.location(in: mapView)
                let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
                let lat = coordinate.latitude
                let lng = coordinate.longitude
                createPin(lat: lat, lng: lng)
                performSegue(withIdentifier: "PinSelected", sender: self)
            default:
                break
            }
    }
    
    private func createPin(lat: Double, lng: Double) {
        print("starting database load")
        if let context = container?.viewContext {
            selectedPin = try? Pin.findOrCreatePin(lat: lat, lng: lng, in: context)
            do {
                try context.save()
            } catch {
                print(error)
            }
            print("done loading database")
            self.printDatabaseStatistics()
        }
    }
    
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                if Thread.isMainThread {
                    print("on main thread")
                } else {
                    print("off main thread")
                }
                if let pinCount = try? context.count(for: Pin.fetchRequest()) {
                    print("\(pinCount) pins")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        longPressGesture.delegate = self
        mapView.delegate = self
        mapView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        plotPins()
    }
    /*
     * Plot all fetched pins on map view
     */
    func plotPins() {
        if let pins: [Pin] = fetchPins() {
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: pin.lat, longitude: pin.lng)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    /*
     * Init vars and segue to PhotosViewController
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "PinSelected" {
            let viewController = segue.destination as! PhotosViewController
            viewController.selectedPin = selectedPin
            viewController.container = container
            
        }
    }
    
}

extension PinsViewController {
    
    /*
     * Use lat and lng to fetch an existing pin from the database
     */
    func getPin(lat: CLLocationDegrees, lng: CLLocationDegrees) -> Pin? {
        let fetchRequest = createPinFilterFetchRequest(format: "lat = %@ and lng = %@", arguments: [lat, lng])
        let pins: [Pin]? = fetchPins(fetchRequest: fetchRequest)
        return pins?.last
    }
    
    /*
     * Create NSFetchRequest with search parameters (lat and lng) to be used in getPin()
     */
    func createPinFilterFetchRequest(format: String, arguments: [Double]?) -> NSFetchRequest<Pin> {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: format, argumentArray: arguments)
        return fetchRequest
    }
    
    /*
     * Fetch all saved pins from database
     */
    func fetchPins(fetchRequest: NSFetchRequest<Pin>? = nil) -> [Pin]? {
        var pins: [Pin]?
        let fetchReq: NSFetchRequest<Pin> = fetchRequest ??  Pin.fetchRequest()
        if let context = container?.viewContext {
            do {
                pins = try context.fetch(fetchReq)
            } catch {
                ErrorNotificationViewController.sharedInstance().notify(message: "There was a problem finding the Pin")
            }
        } else {
            ErrorNotificationViewController.sharedInstance().log("fetchPins: cound not find context")
        }
        return pins
    }
}

extension PinsViewController: MKMapViewDelegate {
    
    /*
     * Customize pins to be plotted in the map view
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        if let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView {
            pinView.annotation = annotation
            return pinView
        } else {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView.canShowCallout = false
            pinView.pinTintColor = .red
            return pinView
        }
    }
    
    /*
     * Listen for user click on existing pin, fetch pin, and segue to photo album
     */
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let annotationCoordinates: CLLocationCoordinate2D = (view.annotation?.coordinate)!
        
        let pin = self.getPin(lat: annotationCoordinates.latitude, lng: annotationCoordinates.longitude)
        if pin != nil {
            selectedPin = pin
            performSegue(withIdentifier: "PinSelected", sender: self)
        } else {
            print("error getting pin")
        }
    }
}

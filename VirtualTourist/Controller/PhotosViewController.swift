//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Taylor Masterson on 11/12/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotosViewController: UIViewController {
    
    var blockOperations: [() -> Void] = []
    
    var selectedPin: Pin? {
        didSet {
            updateUI()   
        }
    }
    
    var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer {
        didSet {
            updateUI()
        }
    }
    
    var fetchedResultsController : NSFetchedResultsController<Photo>? {
        didSet {
            fetchedResultsController?.delegate = self
            self.collectionView?.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.delegate = self
        setupMapView()
        loadOrSearchForPhotos()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        container?.performBackgroundTask { [weak self] context in
//            print("this is trying to save")
//            context.perform {
//                do {
//                    try Photo.saveImageDataForPhotos(withPin: (self?.selectedPin)!, in: (self?.selectedPin!.managedObjectContext)!)
//                } catch {
//                    print(error)
//                }
//                
//            }
//        }
//    }
    
    func loadOrSearchForPhotos() {
        printDatabaseStatistics()
        let pinPhotosCount = selectedPin?.photos?.count ?? 0
        if pinPhotosCount <=  0 {
            searchForFlickrPhotos()
        }
    }
    
    func updateUI() {
        if let context = container?.viewContext {
            let request: NSFetchRequest<Photo> = Photo.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(
                key: "creationDate",
                ascending: true
                )]
            request.predicate = NSPredicate(format: "pin = %@", selectedPin!)
            fetchedResultsController = NSFetchedResultsController<Photo>(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )
            fetchedResultsController?.delegate = self
            try? fetchedResultsController?.performFetch()
            collectionView?.reloadData()
        }
    }
    
    func flickrRequest() -> Request? {
        if let bBox = selectedPin?.getBBoxString() {
            let parameters = [FlickrParamKeys.BoundingBox: bBox]
            return Request(parameters)
        }
        return nil
    }
    
    func searchForFlickrPhotos() {
        if let request = flickrRequest() {
            request.fetchFlickrPhotos { [weak self] photos in
                if photos.count > 0 {
                  self?.updateDatabase(with: photos)
                }
            }
        }
    }
    
    func updateDatabase(with photos: [FlickrPhoto]) {
        container?.performBackgroundTask { [weak self] context in
            context.perform {
                for photoData in photos {
                    let photo = Photo(url: photoData.imageURL, title: photoData.title, in: (self?.selectedPin!.managedObjectContext)!)
                    photo.pin = self?.selectedPin!
                }
                try? context.save()
            }
        }
    }
    
    private func printDatabaseStatistics() {
        if let context = container?.viewContext {
            context.perform {
                let request: NSFetchRequest<Photo> = Photo.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(
                    key: "title",
                    ascending: true,
                    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:))
                    )]
                request.predicate = NSPredicate(format: "pin = %@", self.selectedPin!)
                let results = try? context.fetch(request)
                var count = 0
                for photo in results! {
                    if photo.image != nil {
                        count += 1
                    }
                }
                print(count)
            }
        }
    }

    func setupFlowLayout() {
        let space: CGFloat = 3
        let dimension = (view.frame.width - 2 * space) / 3
        
        flowLayout.minimumLineSpacing = space
        flowLayout.minimumInteritemSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }

}



extension PhotosViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView!.canShowCallout = false
        pinView!.pinTintColor = .red
        return pinView
    }
    
    /*
     * Setup map to disable user interaction and plot the pin
     */
    func setupMapView() {
        if selectedPin != nil {
            let annotation = MKPointAnnotation()
            let centerCoordinate = CLLocationCoordinate2D(latitude: (selectedPin?.lat)!, longitude: (selectedPin?.lng)!)
            annotation.coordinate = centerCoordinate
            let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            let region = MKCoordinateRegion(center: centerCoordinate, span: span)
            
            mapView.addAnnotation(annotation)
            mapView.setRegion(region, animated: true)
            mapView.regionThatFits(region)
            mapView.isUserInteractionEnabled = false
        }
    }
}

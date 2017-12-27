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
    var selectedPin: Pin?
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
    @IBOutlet weak var newCollectionButton: UIButton!
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func newCollectionButtonPressed(_ sender: UIButton) {
        newCollectionButton.isEnabled = false
        let parameters = selectedPin?.buildNewCollectionParams()
        if parameters != nil, let context = container?.viewContext {
            
            let indexPaths = collectionView.indexPathsForVisibleItems
            for indexPath in indexPaths {
                let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
                cell.imageView.image = UIImage(named: "defaultimage")
            }
            
            let photos = fetchedResultsController?.fetchedObjects
            for photo in photos! {
                context.delete(photo)
            }
            try? context.save()
            updateUI()
        }
        searchForFlickrPhotos(parameters)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        mapView.delegate = self
        newCollectionButton.isEnabled = false
        setupMapView()
        loadOrSearchForPhotos()
    }
    
    /*
     * Load existing photos or execute a new search
     */
    func loadOrSearchForPhotos() {
        let pinPhotosCount = selectedPin?.photos?.count ?? 0
        if pinPhotosCount <=  0 {
            searchForFlickrPhotos()
        } else {
            newCollectionButton.isEnabled = true
        }
    }
    
    /*
     *  Perform the NSFetchRequest for all the photos associated with a pin and reload the UICollectionView
     */
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
    
    /*
     * Build the request for photos, optionally passing page number for a new collection of photos
     */
    func flickrRequest(_ parameters: [String: String]?) -> Request? {
        if let bBox = selectedPin?.getBBoxString() {
            var params = [FlickrParamKeys.BoundingBox: bBox]
            if parameters != nil {
                params.merge(parameters!) { (current, _) in current }
            }
            return Request(params)
        }
        return nil
    }
    
    /*
     * Execute the search for photos
     */
    func searchForFlickrPhotos(_ parameters: [String: String]? = nil) {
        if let request = flickrRequest(parameters) {
            request.fetchFlickrPhotos { [weak self] (photos, metaData) in
                DispatchQueue.main.async {
                    self?.newCollectionButton.isEnabled = true
                }
                if photos.count > 0 {
                    self?.updateDatabase(with: photos, and: metaData)
                }
            }
        }
    }
    
    /*
     * Save all photos for a pin and update the page number used to make the request for photos
     */
    func updateDatabase(with photos: [FlickrPhoto], and metaData: NSDictionary) {
        if let context = container?.viewContext {
            context.perform {
                for photoData in photos {
                    let photo = try? Photo.findOrCreatePhoto(title: photoData.title, image_url: photoData.imageURL, pin: self.selectedPin!, in: context)
                    photo!.pin = self.selectedPin!
                    self.selectedPin!.page = Int64(metaData["page"] as! Int)
                    self.selectedPin!.pages = Int64(metaData["pages"] as! Int)
                }
                try? context.save()
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

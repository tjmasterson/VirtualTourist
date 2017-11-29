//
//  PhotosCollectionViewController.swift
//  VirtualTourist
//
//  Created by Taylor Masterson on 11/13/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit

extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = self.fetchedResultsController?.object(at: indexPath)
        let context = container?.viewContext
        context?.delete(photo!)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        cell.imageView.image = UIImage(named: "defaultimage")
        cell.activityIndicator.startAnimating()
        
        let photo = self.fetchedResultsController?.object(at: indexPath)
        
        if photo?.image != nil {
            cell.activityIndicator.stopAnimating()
            cell.imageView.image = UIImage(data: (photo?.image)! as Data)
        } else if photo?.image == nil {
            container?.performBackgroundTask { context in
                let url = photo?.image_url
                if let imageData = NSData(contentsOf: url!), let image = UIImage(data: imageData as Data) {
                    DispatchQueue.main.async {
                        cell.imageView.image = image
                        cell.activityIndicator.stopAnimating()
                    }
                }
            }
        }
        
        cell.activityIndicator.stopAnimating()
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width / 3.0
        let collectionViewHeight = collectionViewWidth

        return CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0,0,0,0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

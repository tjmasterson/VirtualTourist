//
//  PhotosCollectionViewController.swift
//  VirtualTourist
//
//  Created by Taylor Masterson on 11/13/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit

extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
    //        if let index = selectedIndexes.index(of: indexPath) {
    //            selectedIndexes.remove(at: index)
    //            cell.colorPanel.isHidden = true
    //        } else {
    //            cell.colorPanel.isHidden = false
    //            selectedIndexes.append(indexPath)
    //        }
    //    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        
        cell.imageView.image = UIImage(named: "defaultimage")
        cell.activityIndicator.startAnimating()
        cell.imageView.contentMode = .scaleAspectFit
        
        let photo = self.fetchedResultsController?.object(at: indexPath) as? Photo
        
        if Thread.isMainThread {
            print("outside on main thread")
        } else {
            print("outside off main thread")
        }
        if photo?.image == nil {
            let url = photo?.image_url
            container?.performBackgroundTask { [weak self] context in
                
                if Thread.isMainThread {
                    print("inside on main thread")
                } else {
                    print("inside off main thread")
                }
                if let imageData = NSData(contentsOf: url!), let image = UIImage(data: imageData as Data) {
                    DispatchQueue.main.async {
                        if Thread.isMainThread {
                            print("inside inside on main thread")
                        } else {
                            print("inside inside off main thread")
                        }
                        
                        cell.imageView.image = image
                        cell.activityIndicator.stopAnimating()
                    }
                } else {
                    cell.activityIndicator.stopAnimating()
                }
            }
        } else {
            cell.activityIndicator.stopAnimating()
            cell.imageView.image = UIImage(data: (photo?.image)! as Data)
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            print("numberofitemsinsection", sections[section].numberOfObjects)
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width/3.0
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

//
//  FetchedResultsViewController.swift
//  VirtualTourist
//
//  Created by Taylor Masterson on 11/12/17.
//  Copyright © 2017 Taylor Masterson. All rights reserved.
//

import UIKit
import CoreData

extension PhotosViewController: NSFetchedResultsControllerDelegate {
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            print("will change content")
        }
    //
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            print("did change content")
        }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            collectionView?.insertSections(set)
        case .delete:
            collectionView?.deleteSections(set)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("here is the type")
        print(type)

        switch type {
            case .insert:
                print("inserting item now")
                print(collectionView)
                collectionView?.insertItems(at: [newIndexPath!])
            case .delete:
                collectionView?.deleteItems(at: [indexPath!])
            case .move:
                let operations: [BlockOperation] = [
                    BlockOperation(block: { self.collectionView.deleteItems(at: [indexPath!])}),
                    BlockOperation(block: { self.collectionView.insertItems(at: [newIndexPath!])})
                ]
                collectionView?.performBatchUpdates({
                    for operation in operations {
                        operation.start()
                    }
                }, completion: nil)
            case .update:
                collectionView?.reloadItems(at: [indexPath!])
        }
    }
    
}



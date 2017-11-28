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
        print("will controllerWillChangeContent")
        blockOperations.removeAll()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("did controllerDidChangeContent, blockOperations count: \(blockOperations.count)")
        collectionView?.performBatchUpdates({
            for operation in blockOperations {
                operation()
            }
        }, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let set = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            blockOperations.append({ self.collectionView?.insertSections(set) })
        case .delete:
            blockOperations.append({ self.collectionView?.deleteSections(set) })
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                blockOperations.append({ self.collectionView?.insertItems(at: [newIndexPath!]) })
            case .delete:
                blockOperations.append({ self.collectionView?.deleteItems(at: [indexPath!]) })
            case .move:
                blockOperations.append({ self.collectionView?.deleteItems(at: [indexPath!])})
                blockOperations.append({ self.collectionView?.insertItems(at: [newIndexPath!])})
            case .update:
                blockOperations.append({ self.collectionView?.reloadItems(at: [indexPath!]) })
        }
    }
    
}



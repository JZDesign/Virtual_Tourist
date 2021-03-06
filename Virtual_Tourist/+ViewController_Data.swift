//
//  +ViewController.swift
//  Virtual_Tourist
//
//  Created by JacobRakidzich on 8/6/17.
//  Copyright © 2017 Jacob Rakidzich. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension UIViewController {
    
    
    // MARK: get context for COREDATA
    
    
    // Get Stack
    
    func stack() -> CoreDataStack {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.stack
    }
    
    // Get FetchedRequestController
    // returns FRController based on coredata entity name with an optional sort predicate
    
    func fetchedResultsController(entityName: String, withPredicate: NSPredicate?) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.sortDescriptors = []
        if withPredicate != nil {
            fetchRequest.predicate = withPredicate
        }
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack().privateContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    
    // Load data
    
    func loadManagedObject(entityName: String, withPredicate: NSPredicate?) -> [NSManagedObject]? {
        var managedObjects: [NSManagedObject] = []
        var shouldReturn = false
        stack().privateContext.performAndWait {
            do {
            
                let fetchedRC = self.fetchedResultsController(entityName: entityName, withPredicate: withPredicate)
                try fetchedRC.performFetch()
                let count = try fetchedRC.managedObjectContext.count(for: fetchedRC.fetchRequest)
                for item in 0..<count {
                    managedObjects.append(fetchedRC.object(at: IndexPath(row: item, section: 0)) as! NSManagedObject)
                }
            
                shouldReturn = true
                
            } catch {
                shouldReturn = false
            }
        }
        
        if shouldReturn {
            return managedObjects
        } else {
            return nil
        }
       
        
        
    }
    
    // MARK: Reset Data
    
    func resetData() {
        PinDataSource.sharedInstance.photos.removeAll()
    }
    
    
}

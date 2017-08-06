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
    
    func getContext() -> NSManagedObjectContext?  {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            return context
        }
        print("no Context")
        return nil
    }

}

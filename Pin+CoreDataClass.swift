//
//  Pin+CoreDataClass.swift
//  Virtual_Tourist
//
//  Created by JacobRakidzich on 9/3/17.
//  Copyright © 2017 Jacob Rakidzich. All rights reserved.
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {

    
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: entity, insertInto: context)
            self.latitude   = latitude
            self.longitude  = longitude
        } else {
            fatalError("Unable To Find Entity Name!")
        }
    }
    
    
}

//
//  Photo+CoreDataClass.swift
//  Virtual_Tourist
//
//  Created by JacobRakidzich on 8/21/17.
//  Copyright © 2017 Jacob Rakidzich. All rights reserved.
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    convenience init(imageData: NSData?, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: entity, insertInto: context)
            self.photo = imageData
        } else {
            fatalError("Unable To Find Entity Name!")
        }
    }
}

//
//  Photo+CoreDataProperties.swift
//  Virtual_Tourist
//
//  Created by JacobRakidzich on 9/10/17.
//  Copyright © 2017 Jacob Rakidzich. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var photo: NSData?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}

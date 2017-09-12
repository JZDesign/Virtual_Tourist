//
//  AppDelegate.swift
//  Virtual_Tourist
//
//  Created by JacobRakidzich on 7/30/17.
//  Copyright © 2017 Jacob Rakidzich. All rights reserved.
//

/*
 
 convenience init(imageData: NSData?, url: String?, context: NSManagedObjectContext) {
 if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
 self.init(entity: entity, insertInto: context)
 self.photo = imageData
 self.url = url
 } else {
 fatalError("Unable To Find Entity Name!")
 }
 }
 
 convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
 if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
 self.init(entity: entity, insertInto: context)
 self.latitude   = latitude
 self.longitude  = longitude
 } else {
 fatalError("Unable To Find Entity Name!")
 }
 }
 
 */



import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let stack = CoreDataStack(modelName: "Virtual_Tourist")!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    
}


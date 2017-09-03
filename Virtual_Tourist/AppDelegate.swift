//
//  AppDelegate.swift
//  Virtual_Tourist
//
//  Created by JacobRakidzich on 7/30/17.
//  Copyright © 2017 Jacob Rakidzich. All rights reserved.
//

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


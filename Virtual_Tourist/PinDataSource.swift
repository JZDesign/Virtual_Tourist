//
//  PinDataSource.swift
//  Virtual_Tourist
//
//  Created by JacobRakidzich on 8/6/17.
//  Copyright © 2017 Jacob Rakidzich. All rights reserved.
//

import Foundation

import UIKit

class PinDataSource {
    var pin = Pin()
    var photos = [Photo]()
    static let sharedInstance = PinDataSource()
    private init() {}
}

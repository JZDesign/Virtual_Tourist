//
//  CollectionViewCell.swift
//  Virtual_Tourist
//
//  Created by JacobRakidzich on 8/6/17.
//  Copyright © 2017 Jacob Rakidzich. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageview: UIImageView!
    var activityIndicator = ActivityIndicator(text:"")
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.addSubview(activityIndicator)
        if imageview.image == nil {
            activityIndicator.show()
        } else {
            activityIndicator.hide()
        }
    }
}

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
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func initWithURL(_ url: NSURL) {
        
        let request = URLRequest(url: URL(string: url.absoluteString!)!)
        Client.sharedInstance().doPhotoDownload(request: request, completion: { (completed, error) in
            if completed {
                
            } else {
                print(error)
            }
        }) // end doPhotoDownload()
        
    }
    
    func initWithData(_ data: Data?) {
        if let image = UIImage(data: data!) {
            self.imageview.image = image
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidesWhenStopped = true
        }
    }

}

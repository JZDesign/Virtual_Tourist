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
    
    
    func initWithPhoto(_ photo: Photo) {
        self.activityIndicator.hidesWhenStopped = true
        // do photo Download
        self.downloadPhoto(photo: photo)
        
    }
    
   
    func downloadPhoto(photo: Photo) {
        let request = URLRequest(url: URL(string: photo.url!)!)
        Client.sharedInstance().doPhotoDownload(request: request, photo: photo, completion: { (completed, error) in
            if completed {
                if let image = UIImage(data: photo.photo! as Data) {
                    DispatchQueue.main.async {
                        self.imageview.image = image
                        self.activityIndicator.stopAnimating()
                    }
                } else {
                    print("Could not get image from data")
                }
            } else { // not completed
                print(error?.localizedDescription ?? "ERROR! Could not doPhotoDownload")

            }
        }) // end doPhotoDownload()
        
    }
    
}

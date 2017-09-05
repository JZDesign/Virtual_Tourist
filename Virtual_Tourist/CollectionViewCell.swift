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
        if photo.photo != nil {
            self.imageview.image = UIImage(data: photo.photo as! Data)
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        } else {
            self.initWithURL(photo, completion: { (completion, error) in
                if completion {
                    self.initWithData(photo.photo as! Data, completion: { (completed, error) in
                        if completed {
                            DispatchQueue.main.async {
                                self.activityIndicator.stopAnimating()
                            }
                        } else {
                            print(error?.localizedDescription)
                        }
                    })
                } else {
                    print(error?.localizedDescription)
                }
            })
        }
    }
    
    func initWithURL(_ photo: Photo, completion: @escaping(_ completed: Bool, _ error: NSError?)-> Void) {
        
        let request = URLRequest(url: URL(string: photo.url!)!)
        Client.sharedInstance().doPhotoDownload(request: request, photo: photo, completion: { (completed, error) in
            if completed {
                completion(true, nil)
            } else {
                completion(false,error)
            }
        }) // end doPhotoDownload()
        
    }
    
    func initWithData(_ data: Data?, completion: @escaping(_ completed: Bool, _ error: NSError?)-> Void) {
        if let image = UIImage(data: data!) {
            DispatchQueue.main.async {
                self.imageview.image = image
            }
            completion(true, nil)
        } else {
            completion(false, NSError(domain: "initWithData", code: 1, userInfo: nil))
        }
    }

}

//
//  TouristViewController.swift
//  Virtual_Tourist
//
//  Created by JacobRakidzich on 8/2/17.
//  Copyright © 2017 Jacob Rakidzich. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TouristViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    

    
    @IBOutlet var collectionView: UICollectionView!
    let cellID = "cellID"
    let touringPin = PinDataSource.sharedInstance.pin
    var totalCount = 0
    
    // MARK: LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.backItem?.backBarButtonItem?.title = "Done"
        self.navigationItem.backBarButtonItem?.style = UIBarButtonItemStyle.done
        // check for data in core data, if available set cell data
        // if unavailable pull from Flikr, save, then display.
        if let count = touringPin.photos?.count {
            if count == 0 {
                Client.sharedInstance().setSearchParam(touringPin.latitude as! Double, touringPin.longitude as! Double, completion: { (result, error) in
                    if error != nil {
                        print(error)
                    } else {
                        self.totalCount = (result?.count)!
                        PinDataSource.sharedInstance.urls = result!
                        for url in (result?.enumerated())! {
                            let request = URLRequest(url: URL(string: url.element.absoluteString!)!)
                            Client.sharedInstance().doPhotoDownload(request: request, completion: { (completed, error) in
                                if completed {
                                    DispatchQueue.main.async {
                                        self.collectionView.reloadData()
                                    }
                                } else {
                                    print(error)
                                }
                            }) // end doPhotoDownload()
                        } // end for statement
                        self.collectionView.reloadData()
                    } // end if error ELSE
                }) // end setSearchParam()
            } else {
                totalCount = count
                LoadPhotos()
            }
        } // end if let count = touringPin.photos count
    } // end view did load



 
 
    // MARK: COLLECTION VIEW
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = PinDataSource.sharedInstance.photos.count
        if count > 0 {
            return count
        }
        return 0
        //return totalCount
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CollectionViewCell
        cell.activityIndicator.startAnimating()
        cell.initWithData(PinDataSource.sharedInstance.photos[indexPath.row].photo as! Data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //showImageDisplay(UIImage(data: PinDataSource.sharedInstance.photos[indexPath.row].photo as! Data)!)
    }


    // MARK: Core Data
    
    func LoadPhotos() {
        PinDataSource.sharedInstance.photos = []
        if let savedPhotos = loadManagedObject(entityName: "Photo", withPredicate: NSPredicate(format: "pin = %@", argumentArray: [touringPin])) {
            for item in savedPhotos {
                let photo = item as! Photo
                PinDataSource.sharedInstance.photos.append(photo)
            }
        }
        self.collectionView.reloadData()

    
    }
    
   
    
   
    
}

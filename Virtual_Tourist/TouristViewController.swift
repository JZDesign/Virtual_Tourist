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
    

    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var collectionView: UICollectionView!
    let cellID = "cellID"
    let touringPin = PinDataSource.sharedInstance.pin
    // placeholder for cell count... may not use
    var totalCount = 0
    
    // MARK: LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // reset data
        PinDataSource.sharedInstance.photos = []
        PinDataSource.sharedInstance.urls = []
        
        // add pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(touringPin.latitude), longitude: CLLocationDegrees(touringPin.longitude))
        self.mapView.addAnnotation(annotation)
        self.mapView.centerCoordinate = annotation.coordinate
        
        
        
        // check for data in core data, if available set cell data
        // if unavailable pull from Flikr, save, then display.
        
        // TODO: move download to an action and call the action
        if let count = touringPin.photos?.count {
            if count == 0 {
                Client.sharedInstance().setSearchParam(touringPin.latitude as! Double, touringPin.longitude as! Double, completion: { (result, error) in
                    if error != nil {
                        print(error)
                    } else {
                        
                        for url in (result?.enumerated())! {
                            
                        
                            let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: self.stack().context) as! Photo
                            photo.url = url.element.absoluteString
                            photo.pin = PinDataSource.sharedInstance.pin
                            do {
                                try (self.stack().context.save())
                            } catch let err {
                                print(err)
                            }
                        
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                            
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



    // MARK: MapView
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinview = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pinview.pinTintColor = .purple
        pinview.annotation = annotation
        return pinview
    }
 
 
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
        cell.initWithPhoto(PinDataSource.sharedInstance.photos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: Delete cells and the core data attached to them
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
    
   
    @IBAction func doNewPhotosButton(_ sender: Any) {
    }
    
   
    
}

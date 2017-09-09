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
    

    // MARK: Outlets
    @IBOutlet var collectionButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var collectionView: UICollectionView!
    
    // MARK: Properties
    // reuseID
    let cellID = "cellID"
    // active Pin Annotation
    let touringPin = PinDataSource.sharedInstance.pin
    var selectedCells: [Int] = []
    var isSelected: Bool = false
    
    
    
    // MARK: LifeCycle
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // reset data
        resetData()
        
        collectionView.allowsMultipleSelection = true
        
        
        
        // add pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(touringPin.latitude), longitude: CLLocationDegrees(touringPin.longitude))
        self.mapView.addAnnotation(annotation)
        self.mapView.centerCoordinate = annotation.coordinate
        
        // check for data in core data, if available set cell data
        // if unavailable pull from Flikr, save, then display.
        
        if let count = touringPin.photos?.count {
            if count == 0 {
                doNewPhotosButton(self)
                
            } else {
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
        return PinDataSource.sharedInstance.photos.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CollectionViewCell
        cell.activityIndicator.startAnimating()
        cell.initWithPhoto(PinDataSource.sharedInstance.photos[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isSelected {
            isSelected = true
            collectionButton.titleLabel?.text = "  Delete  Selected  "
        }
        
        let cell = collectionView.cellForItem(at: indexPath)
        DispatchQueue.main.async {
            cell?.contentView.alpha = 0.7
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        DispatchQueue.main.async {
            cell?.contentView.alpha = 1.0
        }
        
        if collectionView.indexPathsForSelectedItems == nil {
            print("Nil")
        } else {
            if collectionView.indexPathsForSelectedItems!.count == 0 {
                isSelected = false
                collectionButton.titleLabel?.text = "   New Collection   "
            }
        }
        
    }

    
    func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }

    // MARK: Core Data
    
    func LoadPhotos() {
        resetData()
        if let savedPhotos = loadManagedObject(entityName: "Photo", withPredicate: NSPredicate(format: "pin = %@", argumentArray: [touringPin])) {
            for item in savedPhotos {
                let photo = item as! Photo
                PinDataSource.sharedInstance.photos.append(photo)
            }
        }
        self.collectionView.reloadData()

    
    }
    
    func deletePhotosWithCompletion(completion: @escaping (_ completed: Bool) -> Void) {
        for item in PinDataSource.sharedInstance.photos {
            stack().privateContext.delete(item)
        }
        resetData()
        
        self.reloadCollectionView()
        completion(true)

    }
    
    func deleteSelected(completion: @escaping (_ completed: Bool) -> Void) {
        if let selected = collectionView.indexPathsForSelectedItems {
            for item in selected {
                selectedCells.append(item.row)
                collectionView.deselectItem(at: item, animated: false)
                collectionView.cellForItem(at: item)?.contentView.alpha = 1
            }
            
        }
        
        if selectedCells.count > 0 {
            for item in selectedCells {
                let photo = PinDataSource.sharedInstance.photos[item]
                stack().privateContext.delete(photo)
                do {
                    try self.stack().saveContext()
                } catch {
                    print("Could not remove phot")
                }
            }
        }
        completion(true)
    }
    
    // MARK: Actions
   
    @IBAction func doNewPhotosButton(_ sender: Any) {
        if isSelected {
            deleteSelected(completion: { (completed) in
                if completed {
                    self.LoadPhotos()
                    self.selectedCells.removeAll()
                    self.isSelected = false
                }
            })
        } else {
            newCollection()
        }
        
    }
    
    
    func newCollection() {
        // empty PinDataSource properties and delete existing data
        deletePhotosWithCompletion { (completed) in
            if completed {
                // doDownload
                Client.sharedInstance().setSearchParam(self.touringPin.latitude as! Double, self.touringPin.longitude as! Double, completion: { (result, error) in
                    if error != nil {
                        print(error)
                    } else {
                        for url in (result?.enumerated())! {
                            // create photo managed object and persist
                            let photo = NSEntityDescription.insertNewObject(forEntityName: "Photo", into: self.stack().privateContext) as! Photo
                            photo.url = url.element.absoluteString
                            photo.pin = PinDataSource.sharedInstance.pin
                            // add photo to datasource for use in the collection view.
                            PinDataSource.sharedInstance.photos.append(photo)
                            do {
                                try (self.stack().privateContext.save())
                            } catch let err {
                                print(err)
                            }
                            self.reloadCollectionView()
                        } // end for statement
                        self.reloadCollectionView()
                    } // end if error ELSE
                }) // end setSearchParam()
            } // end Completed
        } // end deletePhotosWithCompletion
    }
        
        
   
    
}

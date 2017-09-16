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
    var touringPin = Pin()
    var selectedCells: [Int] = []
    var isSelected: Bool = false
    
    // MARK: LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionButton.isEnabled = true
        collectionButton.isUserInteractionEnabled = true
        
        collectionView.allowsMultipleSelection = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // reset data
        resetData()
       
        // add pin
        
        self.stack().privateContext.performAndWait({
            self.touringPin = PinDataSource.sharedInstance.pin
        })
        
        stack().privateContext.performAndWait {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.touringPin.latitude), longitude: CLLocationDegrees(self.touringPin.longitude))
            
            self.mapView.addAnnotation(annotation)
            self.mapView.centerCoordinate = annotation.coordinate
            
            // check for data in core data, if available set cell data
            // if unavailable pull from Flikr, save, then display.
            
            if let count = self.touringPin.photos?.count {
                if count == 0 {
                    self.doNewPhotosButton(self)
                    
                } else {
                    self.LoadPhotos()
                }
            } // end if let count = touringPin.photos count
        }

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
        cell.activityIndicator.hidesWhenStopped = true
        cell.activityIndicator.startAnimating()
        
        stack().privateContext.perform ({
            
            if let photo = PinDataSource.sharedInstance.photos[indexPath.row].photo  {
                
                cell.imageview.image = UIImage(data: photo as Data)
                cell.activityIndicator.stopAnimating()
            } else {
                
                let photo = PinDataSource.sharedInstance.photos[indexPath.row]
                let request = URLRequest(url: URL(string: photo.url!)!)
                Client.sharedInstance().doPhotoDownload(request: request, photo: photo, completion: { (completed, error) in
                    if completed {
                        
                        if let image = UIImage(data: photo.photo as! Data) {
                            DispatchQueue.main.async {
                                cell.imageview.image = image
                                cell.activityIndicator.stopAnimating()
                            }
                        } else {
                            print("Could not get image from data")
                        }
                    } else { // not completed
                        print(error?.localizedDescription ?? "ERROR! Could not doPhotoDownload")
                        
                    }
                }) // end doPhotoDownload()
            }
        })
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isSelected {
            isSelected = true
            collectionButton.setTitle("  Delete  Selected  ", for: .normal)
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
                resetButton()
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
        reloadCollectionView()
    
    }
    
    func deletePhotosWithCompletion(completion: @escaping (_ completed: Bool) -> Void) {
        let photos = PinDataSource.sharedInstance.photos
        
        // clear collection view
        self.resetData()
        self.reloadCollectionView()
        for item in photos{
            stack().privateContext.perform {
                self.stack().privateContext.delete(item)
                do {
                    try self.stack().saveContext()
                } catch {
                    print("Could not remove photo")
                }
            }
        }
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
                stack().privateContext.perform {
                    self.stack().privateContext.delete(photo)
                    do {
                        try self.stack().saveContext()
                    } catch {
                        print("Could not remove phot")
                    }
                }
                
            }
        }
        completion(true)
    }
    
    // MARK: Actions
    
    func resetButton() {
        collectionButton.isEnabled = true
        collectionButton.isUserInteractionEnabled = true
        collectionButton.setTitle("   New Collection   ", for: .normal)
    }
   
    @IBAction func doNewPhotosButton(_ sender: Any) {
        // Disable button to prevent concurrent operations that lead to coredata errors and crashes
        collectionButton.isEnabled = false
        collectionButton.isUserInteractionEnabled = false
        collectionButton.setTitle("     Loading...     ", for: .disabled)

        if isSelected {
            deleteSelected(completion: { (completed) in
                if completed {
                    self.LoadPhotos()
                    self.selectedCells.removeAll()
                    self.isSelected = false
                    self.resetButton()
                }
            })
        } else {

            newCollection(completion: { (completed) in
                if completed {
                    self.reloadCollectionView()
                    // enable button after delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
                        self.resetButton()
                    })
                }
            })
        }
        
    }
    
    
    func newCollection(completion: @escaping (_ completed: Bool) -> Void) {
        // empty PinDataSource properties and delete existing data
        deletePhotosWithCompletion( completion: { (completed) in
            if completed {
                
                // doDownload
                self.stack().privateContext.performAndWait ({
                    Client.sharedInstance().setSearchParam(self.touringPin.latitude as! Double, self.touringPin.longitude as! Double, completion: { (result, error) in
                        if error != nil {
                            print(error)
                        } else {
                            
                            for url in (result?.enumerated())! {
                                // create photo managed object and persist
                                self.stack().privateContext.performAndWait {
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

                                } // end privateContext.perform
                        
                            } // end for statement
                            
                        } // end if error ELSE
                    }) // end setSearchParam()
                })// end privatecontext.performAndWait
                
            } // end Completed
            
        }) // end deletePhotosWithCompletion
        completion(true)
    }
    
  
}

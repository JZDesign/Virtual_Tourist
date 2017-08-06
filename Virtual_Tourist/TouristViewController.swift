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
    
    
    
    
    let indicator = ActivityIndicator(text:"Loading")

    @IBOutlet var collectionView: UICollectionView!
    let cellID = "cellID"
    let touringPin = PinDataSource.sharedInstance.pin
    
    
    
    // MARK: LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.view.addSubview(indicator)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.show()

        // TODO: check for data in core data, if available set cell data
        // if unavailable pull from Flikr, save, then display.
        if let count = PinDataSource.sharedInstance.pin.photos?.count {
            

            if count == 0 {
                Client.sharedInstance().setSearchParam(touringPin.latitude as! Double, touringPin.longitude as! Double, completion: { (result, error) in
                    if error != nil {
                        print(error)
                    } else {
                        print(result)
                        self.collectionView.reloadData()
                        
                    }
                    self.indicator.hide()
                })
            } else {
                loadData()
            }
        }
        // Do any additional setup after loading the view.
    }

  

 
    
    // MARK: COLLECTION VIEW DATA SOURCE
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // TODO: CHANGE TO ACTUAL PHOTO COUNT
        if let count = PinDataSource.sharedInstance.pin.photos?.count {
            return count
        }
        return 0
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // TODO: Pull cell data and display
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CollectionViewCell
        
        cell.imageview.image = UIImage(data: PinDataSource.sharedInstance.photos[indexPath.row].photo as! Data)

        
        return cell
    }


    // MARK: Core Data
    
    func loadData() {
        
        if let context = getContext() {
            PinDataSource.sharedInstance.photos = []
            if let savedPhotos = fetchPotos() {
                for pic in savedPhotos {
                    
                    // display saved pics
                    PinDataSource.sharedInstance.photos.append(pic)
                   
                }
            }
        }
        indicator.hide()
    }

    private func fetchPotos() -> [Photo]? {
        if let context = getContext() {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Photo")
            do {
                return try context.fetch(request) as? [Photo]
            } catch let err {
                print(err)
            }
        }
        return nil
    }

    
    // MARK: Actions
    
    @IBAction func doDoneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

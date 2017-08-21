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
    
    
    
    // MARK: LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        PinDataSource.sharedInstance.photos = []
        
        // check for data in core data, if available set cell data
        // if unavailable pull from Flikr, save, then display.
        if let count = PinDataSource.sharedInstance.pin.photos?.count {
            if count == 0 {
                Client.sharedInstance().setSearchParam(touringPin.latitude as! Double, touringPin.longitude as! Double, completion: { (result, error) in
                    if error != nil {
                        print(error)
                    } else {
                        print(result)
                        for url in (result?.enumerated())! {
                            let request = URLRequest(url: URL(string: url.element.absoluteString!)!)
                            let task = URLSession.shared.downloadTask(with: request, completionHandler: { url, response, error in
                                if let error = error {
                                    print(error)
                                } else {
                                    let data = try! Data(contentsOf: url!)
                                    let delegate = UIApplication.shared.delegate as? AppDelegate
                                    if let context = delegate?.persistentContainer.viewContext {
                                        let photo =  NSEntityDescription.insertNewObject(forEntityName: "Photo", into: context) as! Photo
                                        photo.photo = data as NSData
                                        photo.pin = PinDataSource.sharedInstance.pin
                                        PinDataSource.sharedInstance.photos.append(photo)
                                        do {
                                            try (context.save())
                                            DispatchQueue.main.async {
                                                self.collectionView.reloadData()
                                            }
                                        } catch let err {
                                            print(err)
                                        }
                                    }

                                    }
                                    print("photo downloaded")
                                
                            }) 
                            task.resume()
                            
                        }
                        self.collectionView.reloadData()
                    }
                })
            } else {
                loadData()
            }
        }
    }



 
 
    // MARK: COLLECTION VIEW
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = PinDataSource.sharedInstance.pin.photos?.count {
            return count
        }
        return 0
    }
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CollectionViewCell
        cell.backgroundColor = .lightGray
        let ai = ActivityIndicator(text:"")
        cell.addSubview(ai)
        ai.show()
        if let image = UIImage(data: PinDataSource.sharedInstance.photos[indexPath.row].photo as! Data) {
            cell.imageview.image = image
            ai.hide()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //showImageDisplay(UIImage(data: PinDataSource.sharedInstance.photos[indexPath.row].photo as! Data)!)
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

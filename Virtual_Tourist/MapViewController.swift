//
//  MapViewController.swift
//  Virtual_Tourist
//
//  Created by JacobRakidzich on 7/30/17.
//  Copyright © 2017 Jacob Rakidzich. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

    let indicator = ActivityIndicator(text:"Loading")
    
    var pinAnnotationView:MKPinAnnotationView!
    var pointAnnotation:MKPointAnnotation!
    
    
    var annotation:MKAnnotation!
   
    var longRecognizer = UILongPressGestureRecognizer()
    
    
    var pins = [Pin]()

    
    
    @IBOutlet var mapView: MKMapView!
    
    // location manager to find user location
    var locationManager = CLLocationManager()

    
    override func viewWillAppear(_ animated: Bool) {
        self.view.addSubview(indicator)
        indicator.hide()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // load previously saved pins
        loadData()
        
        // init long gesture recognizer
        longRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longGesture(sender:)))
        longRecognizer.delegate = self
        mapView.addGestureRecognizer(longRecognizer)
    
    }

    // MARK: MAP VIEW

    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let id = "pin"
        self.annotation = annotation
        
        var pinview = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKPinAnnotationView
        if pinview == nil {
            pinview = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
            pinview!.canShowCallout = true
            pinview!.pinTintColor = .green
            pinview!.canShowCallout = false
            //pinview!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        } else {
            pinview!.annotation = annotation
        }
        
        pinview?.animatesDrop = true
        return pinview
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //print(view.annotation?.coordinate)
        Client.sharedInstance().setSearchParam(view.annotation?.coordinate.latitude as! Double, view.annotation?.coordinate.longitude as! Double)
    }
    
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        view.removeGestureRecognizer(view.gestureRecognizers!.first!)
    }
       
    
    // remove current pins
    
    func removePins() {
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    
    // MARK: GESTURE RECOGNIZER
    
    func longGesture(sender: UILongPressGestureRecognizer? = nil) {
        if ((sender?.state == UIGestureRecognizerState.ended) || (sender?.state == UIGestureRecognizerState.changed) || (sender?.state == UIGestureRecognizerState.failed) ) {
        } else {
            // create pin for display
            let pin = longRecognizer.location(in: mapView)
            let pinLocation = mapView.convert(pin, toCoordinateFrom: mapView)
            let pinAnnotation = MKPointAnnotation()
            pinAnnotation.coordinate = pinLocation
            self.annotation = pinAnnotation
        
            // save pin to core data
            let lat = annotation?.coordinate.latitude as! Double
            let lon = annotation?.coordinate.longitude as! Double
            
            if let context = getContext() {
                var pin =  NSEntityDescription.insertNewObject(forEntityName: "Pin", into: context) as! Pin
                pin.latitude = lat
                pin.longitude = lon
                pins.append(pin)
                do {
                    try (context.save())
                } catch let err {
                    print(err)
                }
            }
            
            // display pins
            mapView.addAnnotation(self.annotation)
    
        }
        
    }
    
    
    

    // MARK: get context for COREDATA
    
    func getContext() -> NSManagedObjectContext?  {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext {
            return context
        }
        print("no Context")
        return nil
    }

    
    func loadData() {
        
        if let context = getContext() {
            
            if let savedPins = fetchPins() {
                for pin in savedPins {
                    pins.append(pin)
                    // display saved pins
                    
                    let lat = CLLocationDegrees(pin.latitude)
                    let long = CLLocationDegrees(pin.longitude)
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }

    
    private func fetchPins() -> [Pin]? {
        if let context = getContext() {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Pin")
            do {
                return try context.fetch(request) as? [Pin]
            } catch let err {
                print(err)
            }
        }
        return nil
    }

}

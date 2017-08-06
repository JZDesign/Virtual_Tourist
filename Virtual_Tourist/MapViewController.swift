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

    
    
    
    // MARK: life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.addSubview(indicator)
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.show()
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
        // customize annotiations in map view
        // set callout to false to allow interaction with annotation titles and callout left or right
        self.annotation = annotation
        var pinview = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKPinAnnotationView
        if pinview == nil {
            pinview = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
            pinview!.canShowCallout = true
            pinview!.pinTintColor = .green
            pinview!.canShowCallout = false
            
        } else {
            pinview!.annotation = annotation
        }
        
        pinview?.animatesDrop = true
        return pinview
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //print(view.annotation?.coordinate)
        
        if let savedPins = fetchPins() {
            for pin in savedPins {
                pins.append(pin)
                // display saved pins
                
                let lat = pin.latitude
                let long = pin.longitude
                if (view.annotation?.coordinate.latitude == lat) && (view.annotation?.coordinate.longitude == long) {
                    PinDataSource.sharedInstance.pin = pin
                }
            }
        }
        performSegue(withIdentifier: "segue", sender: self)
        
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
    
    
    

    // MARK: Core Data functionality
    
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
        indicator.hide()
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

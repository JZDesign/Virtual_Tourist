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

    
    // Pin
    var pinAnnotationView:MKPinAnnotationView!
    var pointAnnotation:MKPointAnnotation!
    var annotation:MKAnnotation!
    // Gesture
    var longRecognizer = UILongPressGestureRecognizer()
    // location manager to find user location
    var locationManager = CLLocationManager()
    // pin holder
    var pins = [Pin]()

    // is editing
    var isEditingPins: Bool = false
    
    
    // OUTLETS
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var editButton: UIBarButtonItem!
    
    
    
    
    // MARK: life cycle
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // load previously saved pins
        if let savedPins = loadManagedObject(entityName: "Pin", withPredicate: nil) {
            for item in savedPins {
                let pin = item as! Pin
                pins.append(pin)
                // display saved pins
               
                var annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude))
                self.mapView.addAnnotation(annotation)
            }

        }
        
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
            pinview!.pinTintColor = .purple
            pinview!.canShowCallout = false
            
        } else {
            pinview!.annotation = annotation
        }
        
        pinview?.animatesDrop = true
        return pinview
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        for pin in pins {

            if (view.annotation?.coordinate.latitude == pin.latitude) && (view.annotation?.coordinate.longitude == pin.longitude) {
                PinDataSource.sharedInstance.pin = pin
            }
            
        }
        if isEditingPins {
            stack().privateContext.delete(PinDataSource.sharedInstance.pin)
            do {
                try stack().saveContext()
            } catch {
                print("Could not delete pin")
            }
            mapView.removeAnnotation(view.annotation as! MKAnnotation)
        } else {
            performSegue(withIdentifier: "segue", sender: self)
        }
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
            do {
                let newPin = Pin(latitude: annotation?.coordinate.latitude as! Double, longitude: annotation?.coordinate.longitude as! Double, context: stack().privateContext)
                try stack().saveContext()
                pins.append(newPin)
            } catch {
                print("Save pins failed")
            }
            
            
            // display pins
            mapView.addAnnotation(self.annotation)
    
        }
        
    }
    
    // MARK: Actions
    
    @IBAction func doEditButton(_ sender: Any) {
        if !isEditingPins {
            isEditingPins = true
            editButton.title = "Done"
            
        } else {
            isEditingPins = false
            editButton.title = "Edit"
        }
        // TODO: Select and Delete Pins
        // TODO: display Label "Tap Pins To Delete" 
    }
   
}

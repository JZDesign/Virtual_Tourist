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

    // MARK: Properties
    
    
    // Pin
    var pointAnnotation:MKPointAnnotation!
    var annotation:MKAnnotation!
    var annotationArray: [MKAnnotation] = []
    // Gesture
    var longRecognizer = UILongPressGestureRecognizer()
    // location manager to find user location
    var locationManager = CLLocationManager()
    // pin holder
    var pins = [Pin]()

    // is editing
    var isEditingPins: Bool = false
    
    // MARK: Constraints
    @IBOutlet var mapViewBottomLayout: NSLayoutConstraint!
    @IBOutlet var mapViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var tapPinsBottom: NSLayoutConstraint!
    
    // OUTLETS
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var editButton: UIBarButtonItem!
    
    
    // MARK: life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // fix bug that prevents you from clicking on the pin you just left detail view of
        annotationArray = mapView.annotations
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(annotationArray)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // directory path
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))

        // load previously saved pins
        if let savedPins = loadManagedObject(entityName: "Pin", withPredicate: nil) {
            for item in savedPins {
                let pin = item as! Pin
                pins.append(pin)
                // display saved pins
                stack().privateContext.performAndWait {
                    var annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(pin.latitude), longitude: CLLocationDegrees(pin.longitude))
                    self.mapView.addAnnotation(annotation)
                }
                
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
        pinview?.isDraggable = true
        return pinview
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        for pin in pins {
            // set global pin
            stack().privateContext.performAndWait {
                if (view.annotation?.coordinate.latitude == pin.latitude) && (view.annotation?.coordinate.longitude == pin.longitude) {
                    PinDataSource.sharedInstance.pin = pin
                }
            }
            
        }
        // delete pin if editing
        if isEditingPins {
            self.stack().privateContext.perform {
                self.stack().privateContext.delete(PinDataSource.sharedInstance.pin)
                do {
                    try self.stack().saveContext()
                } catch {
                    print("Could not delete pin")
                }
            }
            
            mapView.removeAnnotation(view.annotation as! MKAnnotation)
        } else {
            // else send to collection view
            performSegue(withIdentifier: "segue", sender: self)
        }
    }
    
    
   
    
    // remove current pins
    
    func removePins() {
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    
    // MARK: GESTURE RECOGNIZER
    
    func longGesture(sender: UILongPressGestureRecognizer? = nil) {
        // if you just use .begin the user can accidentally place inifinitely many pins with one long press on simulator
        let pin = sender!.location(in: mapView)
        if (sender?.state == UIGestureRecognizerState.began ) {
            let pinLocation = mapView.convert(pin, toCoordinateFrom: mapView)
            let pinAnnotation = MKPointAnnotation()
            pinAnnotation.coordinate = pinLocation
            self.annotation = pinAnnotation
        } else if (sender?.state == UIGestureRecognizerState.changed) {
            let pinLocation = mapView.convert(pin, toCoordinateFrom: mapView)
            let pinAnnotation = MKPointAnnotation()
            pinAnnotation.coordinate = pinLocation
            self.annotation = pinAnnotation
        } else {
        
            
            
        
            // save pin to core data
            stack().privateContext.performAndWait {
                do {
                    let newPin = Pin(latitude: self.annotation?.coordinate.latitude as! Double, longitude: self.annotation?.coordinate.longitude as! Double, context: self.stack().privateContext)
                    try self.stack().saveContext()
                    self.pins.append(newPin)
                } catch {
                    print("Save pins failed")
                }

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
            // use constraints to animate view
            UIView.setAnimationCurve(UIViewAnimationCurve.easeInOut)
            UIView.animate(withDuration: 0.5) {
                self.mapViewTopConstraint.constant = 0
                self.mapViewBottomLayout.constant = 100
                self.tapPinsBottom.constant = 0
                self.view.layoutIfNeeded()
                
            }
            
            
        } else {
            isEditingPins = false
            editButton.title = "Edit"
            // use constraints to animate view
            UIView.setAnimationCurve(UIViewAnimationCurve.easeInOut)
            UIView.animate(withDuration: 0.5) {
                self.tapPinsBottom.constant = -100
                self.mapViewTopConstraint.constant = 0
                self.mapViewBottomLayout.constant = 0
                
                self.view.layoutIfNeeded()
            }
        }
    }
   
}

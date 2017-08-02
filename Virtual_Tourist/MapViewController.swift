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
        
        let lat = pinview!.annotation?.coordinate.latitude as! Double
        let lon = pinview!.annotation?.coordinate.longitude as! Double
        
        if let context = getContext() {
            var pin =  NSEntityDescription.insertNewObject(forEntityName: "Pin", into: context) as! Pin
            pin.latitude = lat
            pin.longitude = lon 
            pins.append(pin)
        }
        
        print(pins.count)
        pinview?.animatesDrop = true
        return pinview
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(view.annotation?.coordinate)
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
            let pin = longRecognizer.location(in: mapView)
            let pinLocation = mapView.convert(pin, toCoordinateFrom: mapView)
            let pinAnnotation = MKPointAnnotation()
            pinAnnotation.coordinate = pinLocation
            self.annotation = pinAnnotation
        
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


}

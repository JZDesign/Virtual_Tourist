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
    // tap recognition to add pins
    var tapRecognizer = UITapGestureRecognizer()
    var longRecognizer = UILongPressGestureRecognizer()
    // location manager to find user location
    
    
    var pins = [Pin]()

    
    
    @IBOutlet var mapView: MKMapView!
    
    var locationManager = CLLocationManager()

    
    override func viewWillAppear(_ animated: Bool) {
        self.view.addSubview(indicator)
        indicator.hide()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        longRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.longGesture(sender:)))
        
        // initialize tap
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler(sender:)))
        tapRecognizer.delegate = self
        mapView.addGestureRecognizer(tapRecognizer)
    
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
            pinview!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
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
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            print(view.annotation?.coordinate)
//            let app = UIApplication.shared
//            if let toOpen = view.annotation?.subtitle! {
//                
//                // create mutable object to edit links
//                var open = toOpen
//                // remove spaces to prevent crash
//                if open.range(of: " ") != nil{
//                    open = open.replacingOccurrences(of: " ", with: "")
//                }
//                // set prefix to aid safari
//                if (open.range(of: "://") != nil){
//                    app.open(URL(string: open)!, options: [:] , completionHandler: nil)
//                } else {
//                    app.open(URL(string: "http://\(open)")!, options: [:] , completionHandler: nil)
//                }
            
            }
        
    }
    
    
    
    
    
    // remove current pins
    
    func removePins() {
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
    
    
    // MARK: GESTURE RECOGNIZER
    
    func longGesture(sender: UILongPressGestureRecognizer? = nil) {
        
    }
    
    // Tap Recognizer
    
    func tapGestureHandler(sender: UITapGestureRecognizer? = nil) {
        //removePins()
        // use tap to pin location
        let pin = tapRecognizer.location(in: mapView)
        let pinLocation = mapView.convert(pin, toCoordinateFrom: mapView)
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = pinLocation
        self.annotation = pinAnnotation
        
        mapView.addAnnotation(self.annotation)
        //print(annotation.coordinate)
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

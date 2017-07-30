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

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var mapView: MKMapView!
    
    var annotation:MKAnnotation!
    // tap recognition to add pins
    var tapRecognizer = UITapGestureRecognizer()
    
    var pins = [Pin]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // initialize tap
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapGestureHandler(sender:)))
        tapRecognizer.delegate = self
        mapView.addGestureRecognizer(tapRecognizer)
    
    }

    // MARK: MAP VIEW
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        // set annotation data
        self.annotation = annotation
        
        
        // get location string based on pin geolocation
        self.geoString {
            
            print("OK")
        }
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        // display pin
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .green
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        pinView?.animatesDrop = true
        return pinView
    }

    
    
    
    // MARK: GESTURE RECOGNIZER
    // find location string
    // modified from https://stackoverflow.com/questions/38977692/how-to-get-location-name-from-default-annotations-mapkit-in-ios
    
    func geoString(completed: @escaping () -> ())  {
        //set location
        let location = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        // initialize geocoder to reverse engineer location string
        let reverseLocation = CLGeocoder()
        // variable to store result
        var result = ""
        reverseLocation.reverseGeocodeLocation(location) { (placemarks, error) in
            var placemark: CLPlacemark!
            // read placemark closest to user location
            placemark = placemarks?[0]
            print(placemark.addressDictionary)
            
            
            completed()
        }
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
    }
    
    
    


}

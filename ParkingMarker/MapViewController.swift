//
//  MapViewController.swift
//  ParkingMarker
//
//  Created by Jonathan Yee on 5/31/18.
//  Copyright © 2018 Jonathan Yee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.showsUserLocation = true
        mapView.delegate = self
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake((carLocation?.latitude)!, (carLocation?.longitude)!)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        mapView.showsCompass = true
        
        let annotation = MKPointAnnotation()
        let centerCoordinate = CLLocationCoordinate2D(latitude: (carLocation?.latitude)!, longitude: (carLocation?.longitude)!)
        annotation.coordinate = centerCoordinate
        annotation.title = carLocation?.title
        mapView.addAnnotation(annotation)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    var carLocation: Location?
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        print("@@ backButtonPressed @@")
        dismiss(animated: true, completion: nil)
    }
    
}//End Class

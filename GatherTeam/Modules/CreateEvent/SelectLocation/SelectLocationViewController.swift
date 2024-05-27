//
//  SelectLocationViewController.swift
//  GatherTeam
//
//  Created by Nikita on 31.12.2023.
//

import Foundation
import MapKit
import UIKit

class SelectLocationViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    var selectedLocation: CLLocationCoordinate2D?
    
    var selectedLocationCompletion: ((CLLocationCoordinate2D?) -> ())?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mapView.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        let gestureZ = UILongPressGestureRecognizer(target: self, action: #selector(self.revealRegionDetailsWithLongPressOnMap(sender:)))
        mapView.addGestureRecognizer(gestureZ)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: false)
        }
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began { return }
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        setPinUsingMKPlacemark(location: locationCoordinate)
    }
    
    func setPinUsingMKPlacemark(location: CLLocationCoordinate2D) {
        selectedLocation = location
        mapView.removeAnnotations(mapView.annotations)
        let pin = MKPlacemark(coordinate: location)
        let coordinateRegion = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 800, longitudinalMeters: 800)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.addAnnotation(pin)
    }
    
    @IBAction func selectLocationPressed(_ sender: UIButton) {
        selectedLocationCompletion?(selectedLocation)
        self.navigationController?.popViewController(animated: true)
    }
}

extension SelectLocationViewController : MKMapViewDelegate { }

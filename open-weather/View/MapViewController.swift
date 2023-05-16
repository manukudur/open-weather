//
//  File.swift
//  open-weather
//
//  Created by Manoj Kumar on 08/05/23.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        mapView.delegate = self
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            render(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
    @IBAction func locationPressed(_ sender: UIBarButtonItem) {
        removeAllAnnotations()
        locationManager.requestLocation()
    }
}

extension MapViewController: MKMapViewDelegate {
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        if self.mapView.annotations.count >= 1 {
            removeAllAnnotations()
        } else {
            addPoint(coordinate)
        }
    }
    
    func removeAllAnnotations() {
        let allAnnotations = self.mapView.annotations
        if allAnnotations.count >= 1 {
            self.mapView.removeAnnotations(allAnnotations)
        }
    }
    
    func render(_ location: CLLocation) {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        addPoint(coordinate)
    }
    
    func addPoint(_ coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
          if let annotation = view.annotation {
              self.latitude = annotation.coordinate.latitude
              self.longitude = annotation.coordinate.longitude
              performSegue(withIdentifier: "detailView", sender: self)
          }
      }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailView" {
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.latitude = latitude
            destinationVC.longitude = longitude
        }
    }
    
}

//
//  ViewController.swift
//  Sprk+
//
//  Created by Carlo Saraniti on 7/12/19.
//  Copyright © 2019 Carlo Saraniti. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CDYelpFusionKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var region = MKCoordinateRegion()
    let locationManager = CLLocationManager()
    var mapItems = [MKMapItem]()
    var selectedMapItem = MKMapItem()
    var yelpAPIClient = CDYelpAPIClient(apiKey: "Eyyj7cp9X622nkhFQvhJiJRP_h26M-JANYmm87SIWYsr-uKJG8hDxsxGKksxTE3s0GZW209md3OhFQ372NbV4ERuq-C1THUSys_9TipBBLERLWybn59t2Ggt00UqXXYx")
    var keyWord = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        mapView.delegate = self
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first!
        let center = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        
        keyWord = "pizza"   //entry for searching with key words
        
        // search using Apple Map
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = keyWord
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let response = response {
                for mapItem in response.mapItems {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = mapItem.placemark.coordinate
                    annotation.title = mapItem.name! + "Apple Map"
                    self.mapView.addAnnotation(annotation)
                    self.mapItems.append(mapItem)
                }
            }
        }
        
        // search using Yelp API
        yelpAPIClient.searchBusinesses(byTerm: keyWord, location: nil, latitude: 42.0557, longitude: -87.6743, radius: nil, categories: nil, locale: nil, limit: nil, offset: nil, sortBy: nil, priceTiers: nil, openNow: nil, openAt: nil, attributes: nil) { (response) in
            if let response = response,
                let businesses = response.businesses,
                businesses.count > 0 {
                print(businesses)
                for item in businesses{
                    let latitude = item.coordinates?.latitude
                    let longitude = item.coordinates?.longitude
                    let coordinate = CLLocationCoordinate2D (latitude: latitude!, longitude: longitude!)
                    let mPlacemark = MKPlacemark(coordinate: coordinate)
                    let mItem = MKMapItem(placemark: mPlacemark)
                    let annotation2 = MKPointAnnotation()
                    annotation2.coordinate = mItem.placemark.coordinate
                    annotation2.title = item.name! + "Yelp"
                    self.mapView.addAnnotation(annotation2)
                    self.mapItems.append(mItem)
                }
            }
        }
        
        yelpAPIClient.autocompleteBusinesses(byText: "pizza", latitude: 42.0557, longitude: -87.6743, locale: nil) { (response) in
            if let response = response,
                let businesses = response.businesses,
                businesses.count > 0 {
                print(businesses)
                for item in businesses{
                    
                }
            }
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin")
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pinView")
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = UIButton(type: .infoLight)
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        for mapItem in mapItems {
            if mapItem.placemark.coordinate.latitude == view.annotation?.coordinate.latitude && mapItem.placemark.coordinate.longitude == view.annotation?.coordinate.longitude {
                selectedMapItem = mapItem
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DestinationDetailsViewController {
            destination.selectedMapItem = selectedMapItem
        }
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        performSegue(withIdentifier: "ShowLocationDetailsSegue", sender: nil)
    }
    
}

